import Foundation

public enum Stage19TestError: Error, Sendable {
    case scriptedFailure
}

public struct Stage19NetworkPayload: Sendable {
    public let url: URL
    public let byteCount: Int
    public let seed: Int

    public nonisolated init(url: URL, byteCount: Int, seed: Int) {
        self.url = url
        self.byteCount = byteCount
        self.seed = seed
    }
}

public struct Stage19DecodedImage: Sendable, Equatable {
    public let url: URL
    public let byteCount: Int
    public let checksum: Int

    public nonisolated init(url: URL, byteCount: Int, checksum: Int) {
        self.url = url
        self.byteCount = byteCount
        self.checksum = checksum
    }
}

public enum Stage19FetchSource: Sendable, Equatable, Hashable {
    case cacheHit
    case newWork
    case sharedInFlight
    case failed(String)
}

public struct Stage19PipelineFetch: Sendable, Equatable {
    public let url: URL
    public let source: Stage19FetchSource
    public let image: Stage19DecodedImage?

    public nonisolated init(url: URL, source: Stage19FetchSource, image: Stage19DecodedImage?) {
        self.url = url
        self.source = source
        self.image = image
    }
}

public actor Stage19ImageCache {
    private var storage: [URL: Stage19DecodedImage] = [:]

    public init() {}

    public func image(for url: URL) -> Stage19DecodedImage? {
        storage[url]
    }

    public func insert(_ image: Stage19DecodedImage, for url: URL) {
        storage[url] = image
    }

    public func removeAll() {
        storage.removeAll()
    }
}

public actor Stage19ControlledNetworkLoader {
    private struct PendingRequest {
        let id: Int
        let url: URL
        let continuation: CheckedContinuation<Stage19NetworkPayload, Error>
    }

    private var nextID = 0
    private var pending: [Int: PendingRequest] = [:]
    private var pendingOrder: [Int] = []

    private var totalRequests = 0
    private var inFlightRequests = 0
    private var maxInFlightRequests = 0
    private var cancellations = 0

    private var pendingCountWaiters: [(Int, CheckedContinuation<Void, Never>)] = []
    private var totalRequestWaiters: [(Int, CheckedContinuation<Void, Never>)] = []

    public init() {}

    public func loadPayload(for url: URL) async throws -> Stage19NetworkPayload {
        let requestID = nextID
        nextID += 1

        totalRequests += 1
        inFlightRequests += 1
        maxInFlightRequests = max(maxInFlightRequests, inFlightRequests)
        notifyTotalRequestWaitersIfReady()

        return try await withTaskCancellationHandler(
            operation: {
                defer { inFlightRequests -= 1 }

                return try await withCheckedThrowingContinuation { continuation in
                    let request = PendingRequest(id: requestID, url: url, continuation: continuation)
                    pending[requestID] = request
                    pendingOrder.append(requestID)
                    notifyPendingCountWaitersIfReady()
                }
            },
            onCancel: {
                Task {
                    await self.cancelPendingRequest(id: requestID)
                }
            }
        )
    }

    public func completeNext(result: Result<Stage19NetworkPayload, Error>) {
        guard let requestID = pendingOrder.first else { return }
        resumePendingRequest(id: requestID, result: result)
    }

    public func completeNext(for url: URL, result: Result<Stage19NetworkPayload, Error>) {
        guard let requestID = pendingOrder.first(where: { pending[$0]?.url == url }) else { return }
        resumePendingRequest(id: requestID, result: result)
    }

    public func awaitPendingCount(atLeast expectedCount: Int) async {
        if pendingOrder.count >= expectedCount { return }

        await withCheckedContinuation { continuation in
            pendingCountWaiters.append((expectedCount, continuation))
        }
    }

    public func awaitTotalRequests(atLeast expectedCount: Int) async {
        if totalRequests >= expectedCount { return }

        await withCheckedContinuation { continuation in
            totalRequestWaiters.append((expectedCount, continuation))
        }
    }

    public func metrics() -> (totalRequests: Int, maxInFlightRequests: Int, cancellations: Int, pendingRequests: Int) {
        (
            totalRequests: totalRequests,
            maxInFlightRequests: maxInFlightRequests,
            cancellations: cancellations,
            pendingRequests: pendingOrder.count
        )
    }

    private func cancelPendingRequest(id: Int) {
        guard let request = pending.removeValue(forKey: id) else { return }
        pendingOrder.removeAll { $0 == id }
        cancellations += 1
        request.continuation.resume(throwing: CancellationError())
        notifyPendingCountWaitersIfReady()
    }

    private func resumePendingRequest(id: Int, result: Result<Stage19NetworkPayload, Error>) {
        guard let request = pending.removeValue(forKey: id) else { return }
        pendingOrder.removeAll { $0 == id }

        switch result {
        case .success(let payload):
            request.continuation.resume(returning: payload)
        case .failure(let error):
            request.continuation.resume(throwing: error)
        }

        notifyPendingCountWaitersIfReady()
    }

    private func notifyPendingCountWaitersIfReady() {
        var remainingWaiters: [(Int, CheckedContinuation<Void, Never>)] = []

        for (expectedCount, continuation) in pendingCountWaiters {
            if pendingOrder.count >= expectedCount {
                continuation.resume()
            } else {
                remainingWaiters.append((expectedCount, continuation))
            }
        }

        pendingCountWaiters = remainingWaiters
    }

    private func notifyTotalRequestWaitersIfReady() {
        var remainingWaiters: [(Int, CheckedContinuation<Void, Never>)] = []

        for (expectedCount, continuation) in totalRequestWaiters {
            if totalRequests >= expectedCount {
                continuation.resume()
            } else {
                remainingWaiters.append((expectedCount, continuation))
            }
        }

        totalRequestWaiters = remainingWaiters
    }
}

public actor Stage19DownloadCoordinator {
    private struct InFlight {
        let id: Int
        let task: Task<Stage19DecodedImage, Error>
        var waiters: Int
    }

    private enum Entry {
        case inProgress(InFlight)
        case ready(Stage19DecodedImage)
    }

    public struct Counters: Sendable {
        public let newWorkStarts: Int
        public let sharedInFlightHits: Int

        public init(newWorkStarts: Int, sharedInFlightHits: Int) {
            self.newWorkStarts = newWorkStarts
            self.sharedInFlightHits = sharedInFlightHits
        }
    }

    private var entries: [URL: Entry] = [:]
    private var nextInFlightID = 0
    private var newWorkStarts = 0
    private var sharedInFlightHits = 0

    private let cache: Stage19ImageCache
    private let loader: Stage19ControlledNetworkLoader

    public init(cache: Stage19ImageCache, loader: Stage19ControlledNetworkLoader) {
        self.cache = cache
        self.loader = loader
    }

     public func image(for url: URL) async throws -> Stage19PipelineFetch {
        if let cached = await cache.image(for: url) {
            return Stage19PipelineFetch(url: url, source: .cacheHit, image: cached)
        }

        if let entry = entries[url] {
            switch entry {
            case .ready(let image):
                return Stage19PipelineFetch(url: url, source: .cacheHit, image: image)
            case .inProgress(var inFlight):
                sharedInFlightHits += 1
                inFlight.waiters += 1
                entries[url] = .inProgress(inFlight)
                return try await awaitSharedResult(for: url, inFlight: inFlight, source: .sharedInFlight)
            }
        }

        let inFlightID = nextInFlightID
        nextInFlightID += 1

        let sharedTask = Task { [cache, loader] in
            let payload = try await loader.loadPayload(for: url)
            let decoded = Stage19DecodedImage(
                url: payload.url,
                byteCount: payload.byteCount,
                checksum: payload.seed * 31 + payload.byteCount
            )
            await cache.insert(decoded, for: url)
            return decoded
        }

        let inFlight = InFlight(id: inFlightID, task: sharedTask, waiters: 1)
        entries[url] = .inProgress(inFlight)
        newWorkStarts += 1

        return try await awaitSharedResult(for: url, inFlight: inFlight, source: .newWork)
    }

    public func counters() -> Counters {
        Counters(newWorkStarts: newWorkStarts, sharedInFlightHits: sharedInFlightHits)
    }

    public func reset() {
        entries.removeAll()
        nextInFlightID = 0
        newWorkStarts = 0
        sharedInFlightHits = 0
    }

    private func awaitSharedResult(for url: URL, inFlight: InFlight, source: Stage19FetchSource) async throws -> Stage19PipelineFetch {
        do {
            let image = try await withTaskCancellationHandler(
                operation: {
                    try await inFlight.task.value
                },
                onCancel: {
                    Task {
                        await self.cancelWaiter(for: url, inFlightID: inFlight.id)
                    }
                }
            )

            finalizeSuccess(for: url, inFlightID: inFlight.id, image: image)
            return Stage19PipelineFetch(url: url, source: source, image: image)
        } catch {
            finalizeFailure(for: url, inFlightID: inFlight.id)
            throw error
        }
    }

    private func cancelWaiter(for url: URL, inFlightID: Int) {
        guard case .inProgress(var inFlight)? = entries[url], inFlight.id == inFlightID else { return }

        inFlight.waiters -= 1

        if inFlight.waiters <= 0 {
            inFlight.task.cancel()
            entries[url] = nil
        } else {
            entries[url] = .inProgress(inFlight)
        }
    }

    private func finalizeSuccess(for url: URL, inFlightID: Int, image: Stage19DecodedImage) {
        guard case .inProgress(let inFlight)? = entries[url], inFlight.id == inFlightID else { return }
        entries[url] = .ready(image)
    }

    private func finalizeFailure(for url: URL, inFlightID: Int) {
        guard case .inProgress(let inFlight)? = entries[url], inFlight.id == inFlightID else { return }
        entries[url] = nil
    }
}

public struct Stage19TestImagePipeline: Sendable {
    public let cache: Stage19ImageCache
    public let loader: Stage19ControlledNetworkLoader
    public let coordinator: Stage19DownloadCoordinator

    public init(
        cache: Stage19ImageCache = Stage19ImageCache(),
        loader: Stage19ControlledNetworkLoader = Stage19ControlledNetworkLoader()
    ) {
        self.cache = cache
        self.loader = loader
        coordinator = Stage19DownloadCoordinator(cache: cache, loader: loader)
    }

    public func loadImage(from url: URL) async -> Stage19PipelineFetch {
        do {
            return try await coordinator.image(for: url)
        } catch {
            return Stage19PipelineFetch(url: url, source: .failed(String(describing: error)), image: nil)
        }
    }

    public func loadImageThrowing(from url: URL) async throws -> Stage19PipelineFetch {
        try await coordinator.image(for: url)
    }

    public func loadBatchBounded(_ urls: [URL], maxConcurrent: Int) async -> [Stage19PipelineFetch] {
        let limit = max(1, maxConcurrent)
        var iterator = urls.enumerated().makeIterator()

        return await withTaskGroup(of: (Int, Stage19PipelineFetch).self) { group in
            var ordered: [Stage19PipelineFetch?] = Array(repeating: nil, count: urls.count)

            for _ in 0..<limit {
                guard let (index, url) = iterator.next() else { break }
                group.addTask {
                    (index, await loadImage(from: url))
                }
            }

            while let (index, fetch) = await group.next() {
                ordered[index] = fetch

                if let (nextIndex, nextURL) = iterator.next() {
                    group.addTask {
                        (nextIndex, await loadImage(from: nextURL))
                    }
                }
            }

            return ordered.compactMap { $0 }
        }
    }

    public func metrics() async -> (
        newWorkStarts: Int,
        sharedInFlightHits: Int,
        networkRequests: Int,
        maxInFlightNetworkRequests: Int,
        cancellations: Int
    ) {
        let counters = await coordinator.counters()
        let loaderMetrics = await loader.metrics()

        return (
            newWorkStarts: counters.newWorkStarts,
            sharedInFlightHits: counters.sharedInFlightHits,
            networkRequests: loaderMetrics.totalRequests,
            maxInFlightNetworkRequests: loaderMetrics.maxInFlightRequests,
            cancellations: loaderMetrics.cancellations
        )
    }
}

public actor Stage19ReentrancyGate {
    private var didCheck = false
    private var checkWaiters: [CheckedContinuation<Void, Never>] = []

    private var isResumed = false
    private var resumeWaiters: [CheckedContinuation<Void, Never>] = []

    public init() {}

    public func signalTaskAReadState() {
        didCheck = true
        let waiters = checkWaiters
        checkWaiters.removeAll()
        for waiter in waiters {
            waiter.resume()
        }
    }

    public func waitUntilTaskAReadState() async {
        if didCheck { return }

        await withCheckedContinuation { continuation in
            checkWaiters.append(continuation)
        }
    }

    public func waitUntilResumed() async {
        if isResumed { return }

        await withCheckedContinuation { continuation in
            resumeWaiters.append(continuation)
        }
    }

    public func resumeTaskA() {
        isResumed = true
        let waiters = resumeWaiters
        resumeWaiters.removeAll()
        for waiter in waiters {
            waiter.resume()
        }
    }
}

public actor Stage19Inventory {
    private var stock: Int

    public init(stock: Int) {
        self.stock = stock
    }

    public func reserveOneIfAvailable(gate: Stage19ReentrancyGate) async -> Bool {
        guard stock > 0 else { return false }

        await gate.signalTaskAReadState()
        await gate.waitUntilResumed()

        stock -= 1
        return true
    }

    public func consumeOneImmediately() -> Bool {
        guard stock > 0 else { return false }
        stock -= 1
        return true
    }

    public func currentStock() -> Int {
        stock
    }
}
