import Foundation
import Testing

@Suite("Stage 19 - Testing concurrent systems")
struct Stage19ConcurrentSystemTests {
    // Two callers for the same URL should share one underlying request.
    @Test("duplicateRequestsShareUnderlyingWork")
    func duplicateRequestsShareUnderlyingWork() async {
        let pipeline = Stage19TestImagePipeline()
        let url = URL(string: "https://example.com/shared.png")!

        let firstTask = Task { await pipeline.loadImage(from: url) }
        let secondTask = Task { await pipeline.loadImage(from: url) }

        await pipeline.loader.awaitPendingCount(atLeast: 1)

        let payload = Stage19NetworkPayload(url: url, byteCount: 42_000, seed: 11)
        await pipeline.loader.completeNext(for: url, result: .success(payload))

        let firstFetch = await firstTask.value
        let secondFetch = await secondTask.value
        let metrics = await pipeline.metrics()

        let sources = Set([firstFetch.source, secondFetch.source])

        #expect(metrics.networkRequests == 1)
        #expect(metrics.newWorkStarts == 1)
        #expect(metrics.sharedInFlightHits == 1)
        #expect(sources == Set([.newWork, .sharedInFlight]))
    }

    // Cancelling the waiting task should cancel underlying work and allow clean retry.
    @Test("cancellationPropagates")
    func cancellationPropagates() async {
        let pipeline = Stage19TestImagePipeline()
        let url = URL(string: "https://example.com/cancel.png")!

        let task = Task {
            try await pipeline.loadImageThrowing(from: url)
        }

        await pipeline.loader.awaitPendingCount(atLeast: 1)
        task.cancel()

        do {
            _ = try await task.value
            Issue.record("Expected CancellationError")
        } catch is CancellationError {
            // Expected.
        } catch {
            Issue.record("Expected CancellationError, got \(String(describing: error))")
        }

        let metrics = await pipeline.metrics()
        #expect(metrics.cancellations == 1)

        let retryTask = Task { await pipeline.loadImage(from: url) }
        await pipeline.loader.awaitPendingCount(atLeast: 1)
        await pipeline.loader.completeNext(
            for: url,
            result: .success(Stage19NetworkPayload(url: url, byteCount: 21_000, seed: 7))
        )

        let retryFetch = await retryTask.value
        let retryMetrics = await pipeline.metrics()

        #expect(retryFetch.source == .newWork)
        #expect(retryMetrics.networkRequests == 2)
    }

    // Failed in-flight entries must be evicted so the next request starts new work.
    @Test("failedRequestIsRemovedFromInFlightCache")
    func failedRequestIsRemovedFromInFlightCache() async {
        let pipeline = Stage19TestImagePipeline()
        let url = URL(string: "https://example.com/fail-once.png")!

        let firstTask = Task { await pipeline.loadImage(from: url) }
        await pipeline.loader.awaitPendingCount(atLeast: 1)
        await pipeline.loader.completeNext(for: url, result: .failure(Stage19TestError.scriptedFailure))

        let firstFetch = await firstTask.value
        #expect({
            if case .failed = firstFetch.source { return true }
            return false
        }())

        let secondTask = Task { await pipeline.loadImage(from: url) }
        await pipeline.loader.awaitPendingCount(atLeast: 1)
        await pipeline.loader.completeNext(
            for: url,
            result: .success(Stage19NetworkPayload(url: url, byteCount: 33_000, seed: 9))
        )

        let secondFetch = await secondTask.value
        let metrics = await pipeline.metrics()

        #expect(secondFetch.source == .newWork)
        #expect(metrics.networkRequests == 2)
    }

    // A cached value should return without creating a second network request.
    @Test("cachedValueAvoidsNetworkRequest")
    func cachedValueAvoidsNetworkRequest() async {
        let pipeline = Stage19TestImagePipeline()
        let url = URL(string: "https://example.com/cached.png")!

        let firstTask = Task { await pipeline.loadImage(from: url) }
        await pipeline.loader.awaitPendingCount(atLeast: 1)
        await pipeline.loader.completeNext(
            for: url,
            result: .success(Stage19NetworkPayload(url: url, byteCount: 55_000, seed: 13))
        )

        let firstFetch = await firstTask.value
        let secondFetch = await pipeline.loadImage(from: url)
        let metrics = await pipeline.metrics()

        #expect(firstFetch.source == .newWork)
        #expect(secondFetch.source == .cacheHit)
        #expect(metrics.networkRequests == 1)
    }

    // Bounded batch loading should never exceed the configured in-flight limit.
    @Test("boundedLoaderDoesNotExceedConcurrencyLimit")
    func boundedLoaderDoesNotExceedConcurrencyLimit() async {
        let pipeline = Stage19TestImagePipeline()
        let urls = (1...5).map { URL(string: "https://example.com/img-\($0).png")! }

        let batchTask = Task {
            await pipeline.loadBatchBounded(urls, maxConcurrent: 2)
        }

        await pipeline.loader.awaitPendingCount(atLeast: 2)
        var metrics = await pipeline.metrics()

        #expect(metrics.maxInFlightNetworkRequests == 2)
        #expect(metrics.networkRequests == 2)

        for index in 0..<urls.count {
            let url = urls[index]
            await pipeline.loader.completeNext(
                for: url,
                result: .success(Stage19NetworkPayload(url: url, byteCount: 10_000 + index, seed: index + 1))
            )
            if index < urls.count - 2 {
                await pipeline.loader.awaitTotalRequests(atLeast: index + 3)
            }
        }

        let results = await batchTask.value
        metrics = await pipeline.metrics()

        #expect(results.count == urls.count)
        #expect(metrics.maxInFlightNetworkRequests <= 2)
    }

    // Deterministically orchestrates actor reentrancy across a suspension point.
    @Test("actorReentrancyOrchestratedDeterministically")
    func actorReentrancyOrchestratedDeterministically() async {
        let inventory = Stage19Inventory(stock: 1)
        let gate = Stage19ReentrancyGate()

        let taskA = Task {
            await inventory.reserveOneIfAvailable(gate: gate)
        }

        await gate.waitUntilTaskAReadState()

        let taskBConsumed = await inventory.consumeOneImmediately()
        #expect(taskBConsumed)

        await gate.resumeTaskA()

        let taskAReserved = await taskA.value
        let finalStock = await inventory.currentStock()

        #expect(taskAReserved)
        #expect(finalStock == -1)
    }
}
