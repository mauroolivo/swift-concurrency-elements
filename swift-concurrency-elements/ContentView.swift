import SwiftUI

struct ContentView: View {
    @State private var stage0Model = Stage0LabModel()
    @State private var stage1Model = Stage1LabModel()
    @State private var stage2Model = Stage2LabModel()
    @State private var stage3Model = Stage3LabModel()
    @State private var stage4Model = Stage4LabModel()
    @State private var stage5Model = Stage5LabModel()
    @State private var stage6Model = Stage6LabModel()
    @State private var stage7Model = Stage7LabModel()

    var body: some View {
        NavigationStack {
            List {
                Section("Stage 0 — Concurrency Laboratory") {
                    Text("Mental model")
                        .font(.headline)

                    Text("Task → Executor → Isolation domain")
                        .font(.system(.body, design: .monospaced))

                    Button("Run Stage 0 Experiment") {
                        stage0Model.runExperiment()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Section("Stage 0 Log") {
                    if stage0Model.events.isEmpty {
                        ContentUnavailableView(
                            "No events yet",
                            systemImage: "play.circle",
                            description: Text("Run the experiment, then inspect the order of events in Xcode's console and here in the app.")
                        )
                    } else {
                        ForEach(stage0Model.events) { event in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.message)
                                    .font(.body)

                                Text(event.context)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Stage 1 — async/await Execution") {
                    Text("Sequential async calls")
                        .font(.headline)

                    Text("Compare sequential await with async let. Each simulated operation takes about one second.")

                    Button(stage1Model.isRunning ? "Running…" : "Run Sequential Experiment") {
                        stage1Model.runSequentialExperiment()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(stage1Model.isRunning)

                    Button(stage1Model.isRunning ? "Running…" : "Run async let Experiment") {
                        stage1Model.runAsyncLetExperiment()
                    }
                    .buttonStyle(.bordered)
                    .disabled(stage1Model.isRunning)
                }

                Section("Stage 1 Log") {
                    if stage1Model.events.isEmpty {
                        ContentUnavailableView(
                            "No events yet",
                            systemImage: "clock",
                            description: Text("Run the sequential experiment and compare the timestamps with the console output.")
                        )
                    } else {
                        ForEach(stage1Model.events) { event in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.message)
                                    .font(.body)

                                Text(event.context)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Stage 2 — Task Hierarchy") {
                    Text("Task inheritance vs Task.detached")
                        .font(.headline)

                    Text("Watch task-local values, actor context, and cancellation behavior diverge.")

                    Button(stage2Model.isRunning ? "Running…" : "Run Hierarchy Experiment") {
                        stage2Model.runHierarchyExperiment()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(stage2Model.isRunning)

                    Button("Cancel Hierarchy Experiment") {
                        stage2Model.cancelHierarchyExperiment()
                    }
                    .buttonStyle(.bordered)
                    .disabled(!stage2Model.isRunning)
                }

                Section("Stage 2 Log") {
                    if stage2Model.events.isEmpty {
                        ContentUnavailableView(
                            "No events yet",
                            systemImage: "square.stack.3d.up",
                            description: Text("Run the hierarchy experiment, then optionally cancel it before the window closes.")
                        )
                    } else {
                        ForEach(stage2Model.events) { event in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.message)
                                    .font(.body)

                                Text(event.context)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Stage 3 — Cancellation") {
                    Text("Cooperative cancellation")
                        .font(.headline)

                    Text("Compare an operation that ignores cancellation with one that checks for it and runs cleanup via withTaskCancellationHandler.")

                    Button(stage3Model.isRunning ? "Running…" : "Run Ignoring Cancellation Experiment") {
                        stage3Model.runIgnoringCancellationExperiment()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(stage3Model.isRunning)

                    Button(stage3Model.isRunning ? "Running…" : "Run Cooperative Cancellation Experiment") {
                        stage3Model.runCooperativeCancellationExperiment()
                    }
                    .buttonStyle(.bordered)
                    .disabled(stage3Model.isRunning)

                    Button("Cancel Stage 3 Experiment") {
                        stage3Model.cancelExperiment()
                    }
                    .buttonStyle(.bordered)
                    .disabled(!stage3Model.isRunning)
                }

                Section("Stage 3 Log") {
                    if stage3Model.events.isEmpty {
                        ContentUnavailableView(
                            "No events yet",
                            systemImage: "nosign",
                            description: Text("Run one of the cancellation experiments, then cancel it and observe which work stops and which work keeps going.")
                        )
                    } else {
                        ForEach(stage3Model.events) { event in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.message)
                                    .font(.body)

                                Text(event.context)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Stage 4 — Task Groups") {
                    Text("Dynamic batch loading")
                        .font(.headline)

                    Text("Load a variable-size collection with withThrowingTaskGroup and watch results arrive in completion order.")

                    Button(stage4Model.isRunning ? "Running…" : "Run Task Group Experiment") {
                        stage4Model.runTaskGroupExperiment()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(stage4Model.isRunning)

                    Button("Cancel Stage 4 Experiment") {
                        stage4Model.cancelTaskGroupExperiment()
                    }
                    .buttonStyle(.bordered)
                    .disabled(!stage4Model.isRunning)
                }

                Section("Stage 4 Log") {
                    if stage4Model.events.isEmpty {
                        ContentUnavailableView(
                            "No events yet",
                            systemImage: "square.stack.3d.down.right",
                            description: Text("Run the task-group batch loader, then cancel it to observe cancellation propagation through the group.")
                        )
                    } else {
                        ForEach(stage4Model.events) { event in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.message)
                                    .font(.body)

                                Text(event.context)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Stage 5 — Actors and Isolation") {
                    Text("Actor-isolated cache")
                        .font(.headline)

                    Text("Use an ImageCache actor to protect mutable cache state. Cross-actor reads and writes require await; nonisolated immutable metadata does not.")

                    Button(stage5Model.isRunning ? "Running…" : "Run Actor Cache Experiment") {
                        stage5Model.runActorCacheExperiment()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(stage5Model.isRunning)
                }

                Section("Stage 5 Log") {
                    if stage5Model.events.isEmpty {
                        ContentUnavailableView(
                            "No events yet",
                            systemImage: "shippingbox",
                            description: Text("Run the actor cache experiment and watch which operations require await across the actor boundary.")
                        )
                    } else {
                        ForEach(stage5Model.events) { event in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.message)
                                    .font(.body)

                                Text(event.context)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Stage 6 — Actor Reentrancy") {
                    Text("Logical races across await")
                        .font(.headline)

                    Text("Run two withdrawals against one actor. Actor isolation prevents data races, but the intentionally flawed operation can still overdraw after suspension.")

                    Button(stage6Model.isRunning ? "Running…" : "Run Broken Reentrancy Experiment") {
                        stage6Model.runReentrancyExperiment()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(stage6Model.isRunning)

                    Button(stage6Model.isRunning ? "Running…" : "Run Fixed Reentrancy Experiment") {
                        stage6Model.runFixedReentrancyExperiment()
                    }
                    .buttonStyle(.bordered)
                    .disabled(stage6Model.isRunning)

                    Button(stage6Model.isRunning ? "Running…" : "Run Duplicate Image Request Experiment") {
                        stage6Model.runDuplicateImageRequestExperiment()
                    }
                    .buttonStyle(.bordered)
                    .disabled(stage6Model.isRunning)

                    Button(stage6Model.isRunning ? "Running…" : "Run Deduplicated Image Request Experiment") {
                        stage6Model.runDeduplicatedImageRequestExperiment()
                    }
                    .buttonStyle(.bordered)
                    .disabled(stage6Model.isRunning)
                }

                Section("Stage 6 Log") {
                    if stage6Model.events.isEmpty {
                        ContentUnavailableView(
                            "No events yet",
                            systemImage: "arrow.trianglehead.2.clockwise.rotate.90",
                            description: Text("Run the reentrancy experiment and predict whether both withdrawals can observe the same pre-await balance.")
                        )
                    } else {
                        ForEach(stage6Model.events) { event in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.message)
                                    .font(.body)

                                Text(event.context)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Stage 7 — Sendable") {
                    Text("Values crossing isolation boundaries")
                        .font(.headline)

                    Text("Compare immutable value types, actor references, mutable reference types, and @Sendable closures under Swift 6 strict concurrency checking.")

                    Button(stage7Model.isRunning ? "Running…" : "Run Sendable Experiment") {
                        stage7Model.runSendableExperiment()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(stage7Model.isRunning)

                    Button(stage7Model.isRunning ? "Running…" : "Run @unchecked Sendable Experiment") {
                        stage7Model.runUncheckedSendableExperiment()
                    }
                    .buttonStyle(.bordered)
                    .disabled(stage7Model.isRunning)
                }

                Section("Stage 7 Log") {
                    if stage7Model.events.isEmpty {
                        ContentUnavailableView(
                            "No events yet",
                            systemImage: "paperplane",
                            description: Text("Run the Sendable experiment and inspect which values are safe to move across task and actor boundaries.")
                        )
                    } else {
                        ForEach(stage7Model.events) { event in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.message)
                                    .font(.body)

                                Text(event.context)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Concurrency Lab")
        }
    }
}

private struct LabEvent: Identifiable {
    let id = UUID()
    let message: String
    let context: String
}

private struct CourseUser {
    let id: Int
    let name: String
}

private struct CoursePost: Identifiable {
    let id: Int
    let title: String
}

private struct Stage4LoadItem: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let delayMilliseconds: Int
}

private struct CachedImage: Identifiable, Sendable {
    let url: URL
    let bytes: Int

    var id: URL { url }
}

private struct Stage6WithdrawalResult: Sendable {
    let label: String
    let approved: Bool
    let balanceUsedForDecision: Int
    let balanceAfterMutation: Int

    var summary: String {
        if approved {
            "Withdrawal \(label) approved — decision balance: \(balanceUsedForDecision), balance after mutation: \(balanceAfterMutation)"
        } else {
            "Withdrawal \(label) denied — decision balance: \(balanceUsedForDecision)"
        }
    }
}

private struct Stage6ImageRequestResult: Sendable {
    enum Source: Sendable {
        case cacheHit
        case newDownload(Int)
        case sharedInProgress
    }

    let label: String
    let source: Source
    let image: CachedImage

    var summary: String {
        switch source {
        case .cacheHit:
            "Request \(label) returned cached image, bytes: \(image.bytes)"
        case .newDownload(let downloadNumber):
            "Request \(label) performed underlying download #\(downloadNumber), bytes: \(image.bytes)"
        case .sharedInProgress:
            "Request \(label) shared existing in-progress download, bytes: \(image.bytes)"
        }
    }
}

private struct Stage7ImageMetadata: Sendable {
    let url: URL
    let byteCount: Int
    let tags: [String]
}

private struct Stage7SendableSummary: Sendable {
    let messages: [String]
}

private final class Stage7MutableImageBox {
    var byteCount: Int

    init(byteCount: Int) {
        self.byteCount = byteCount
    }
}

private nonisolated final class Stage7ImmutableImageConfiguration: Sendable {
    let preferredScale: Int
    let format: String

    init(preferredScale: Int, format: String) {
        self.preferredScale = preferredScale
        self.format = format
    }
}

private nonisolated final class Stage7LockedImageCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var value = 0

    func increment() -> Int {
        lock.lock()
        defer { lock.unlock() }

        value += 1
        return value
    }

    func snapshot() -> Int {
        lock.lock()
        defer { lock.unlock() }

        return value
    }
}

private nonisolated enum Stage2Context {
    @TaskLocal static var traceID: String = "unassigned"
}

private func simulateStage4Load(_ item: Stage4LoadItem) async throws -> String {
    print("[Stage 4] \(item.name) started — planned delay: \(item.delayMilliseconds)ms")

    try Task.checkCancellation()
    try await Task.sleep(for: .milliseconds(item.delayMilliseconds))
    try Task.checkCancellation()

    let result = "\(item.name) loaded after \(item.delayMilliseconds)ms"
    print("[Stage 4] \(result)")
    return result
}

private actor ImageCache {
    nonisolated let name = "Stage 5 ImageCache"

    private var storage: [URL: CachedImage] = [:]

    func image(for url: URL) -> CachedImage? {
        storage[url]
    }

    func insert(_ image: CachedImage) {
        storage[image.url] = image
    }

    func removeAll() {
        storage.removeAll()
    }

    func count() -> Int {
        storage.count
    }
}

private actor BankAccount {
    private var balance: Int

    init(balance: Int) {
        self.balance = balance
    }

    func currentBalance() -> Int {
        balance
    }

    func withdraw(_ amount: Int, label: String) async -> Stage6WithdrawalResult {
        let observedBalance = balance

        guard balance >= amount else {
            return Stage6WithdrawalResult(
                label: label,
                approved: false,
                balanceUsedForDecision: observedBalance,
                balanceAfterMutation: balance
            )
        }

        await authorizeStage6Withdrawal(label: label)

        balance -= amount

        return Stage6WithdrawalResult(
            label: label,
            approved: true,
            balanceUsedForDecision: observedBalance,
            balanceAfterMutation: balance
        )
    }

    func withdrawAfterRevalidation(_ amount: Int, label: String) async -> Stage6WithdrawalResult {
        await authorizeStage6Withdrawal(label: label)

        let decisionBalance = balance

        guard decisionBalance >= amount else {
            return Stage6WithdrawalResult(
                label: label,
                approved: false,
                balanceUsedForDecision: decisionBalance,
                balanceAfterMutation: balance
            )
        }

        balance -= amount

        return Stage6WithdrawalResult(
            label: label,
            approved: true,
            balanceUsedForDecision: decisionBalance,
            balanceAfterMutation: balance
        )
    }
}

private actor NaiveImagePipeline {
    private var cache: [URL: CachedImage] = [:]
    private var downloadCount = 0

    func image(for url: URL, label: String) async -> Stage6ImageRequestResult {
        if let cached = cache[url] {
            return Stage6ImageRequestResult(
                label: label,
                source: .cacheHit,
                image: cached
            )
        }

        let image = await simulateStage6ImageDownload(from: url, label: label)

        downloadCount += 1
        cache[url] = image

        return Stage6ImageRequestResult(
            label: label,
            source: .newDownload(downloadCount),
            image: image
        )
    }

    func totalUnderlyingDownloads() -> Int {
        downloadCount
    }
}

private actor DeduplicatingImagePipeline {
    private enum Entry {
        case inProgress(Task<CachedImage, Never>)
        case ready(CachedImage)
    }

    private var entries: [URL: Entry] = [:]
    private var downloadCount = 0

    func image(for url: URL, label: String) async -> Stage6ImageRequestResult {
        if let entry = entries[url] {
            switch entry {
            case .ready(let image):
                return Stage6ImageRequestResult(
                    label: label,
                    source: .cacheHit,
                    image: image
                )

            case .inProgress(let task):
                let image = await task.value
                return Stage6ImageRequestResult(
                    label: label,
                    source: .sharedInProgress,
                    image: image
                )
            }
        }

        let task = Task {
            await simulateStage6ImageDownload(from: url, label: label)
        }

        entries[url] = .inProgress(task)

        let image = await task.value

        downloadCount += 1
        entries[url] = .ready(image)

        return Stage6ImageRequestResult(
            label: label,
            source: .newDownload(downloadCount),
            image: image
        )
    }

    func totalUnderlyingDownloads() -> Int {
        downloadCount
    }
}

private actor Stage7AuditLog {
    private var records: [String] = []

    func append(_ record: String) {
        records.append(record)
    }

    func snapshot() -> [String] {
        records
    }
}

private nonisolated func authorizeStage6Withdrawal(label: String) async {
    print("[Stage 6] Authorization requested for withdrawal \(label)")
    try? await Task.sleep(for: .milliseconds(500))
    print("[Stage 6] Authorization completed for withdrawal \(label)")
}

private nonisolated func simulateStage6ImageDownload(from url: URL, label: String) async -> CachedImage {
    print("[Stage 6] Request \(label) started underlying image download")
    try? await Task.sleep(for: .milliseconds(500))
    print("[Stage 6] Request \(label) completed underlying image download")
    return CachedImage(url: url, bytes: 64_000)
}

@MainActor
@Observable
private final class Stage0LabModel {
    private(set) var events: [LabEvent] = []

    func runExperiment() {
        events.removeAll()

        record("Button action entered UI-isolated state")

        Task {
            record("Task { } started from MainActor-isolated code")
            record("About to suspend with Task.yield()")

            await Task.yield()

            record("Task resumed after suspension")
            record("UI state is still mutated only inside the MainActor isolation domain")
        }
    }

    private func record(_ message: String) {
        let context = "isolation: MainActor · thread diagnostic: \(Thread.isMainThread ? "main" : "not main")"
        let event = LabEvent(message: message, context: context)

        events.append(event)
        print("[Stage 0] \(message) — \(context)")
    }
}

@MainActor
@Observable
private final class Stage1LabModel {
    private(set) var events: [LabEvent] = []
    private(set) var isRunning = false

    func runSequentialExperiment() {
        events.removeAll()
        isRunning = true

        Task {
            let start = Date()

            do {
                record("Sequential experiment started")

                let user = try await fetchUser()
                let posts = try await fetchPosts()

                let elapsed = Date().timeIntervalSince(start)
                record("Finished: \(user.name), \(posts.count) posts, elapsed: \(elapsed.formatted(.number.precision(.fractionLength(2))))s")
            } catch {
                record("Failed with error: \(error)")
            }

            isRunning = false
        }
    }

    func runAsyncLetExperiment() {
        events.removeAll()
        isRunning = true

        Task {
            let start = Date()

            do {
                record("async let experiment started")

                async let user = fetchUser()
                async let posts = fetchPosts()

                record("Both async let child tasks have been declared")

                let (loadedUser, loadedPosts) = try await (user, posts)

                let elapsed = Date().timeIntervalSince(start)
                record("Finished: \(loadedUser.name), \(loadedPosts.count) posts, elapsed: \(elapsed.formatted(.number.precision(.fractionLength(2))))s")
            } catch {
                record("Failed with error: \(error)")
            }

            isRunning = false
        }
    }

    private func fetchUser() async throws -> CourseUser {
        record("fetchUser() entered — synchronous work before first await")

        try await Task.sleep(for: .seconds(1))

        record("fetchUser() resumed after suspension")
        return CourseUser(id: 1, name: "Blob")
    }

    private func fetchPosts() async throws -> [CoursePost] {
        record("fetchPosts() entered — synchronous work before first await")

        try await Task.sleep(for: .seconds(1))

        record("fetchPosts() resumed after suspension")
        return [
            CoursePost(id: 1, title: "Structured concurrency"),
            CoursePost(id: 2, title: "Actor isolation")
        ]
    }

    private func record(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        let context = "time: \(timestamp) · isolation: MainActor · thread diagnostic: \(Thread.isMainThread ? "main" : "not main")"
        let event = LabEvent(message: message, context: context)

        events.append(event)
        print("[Stage 1] \(message) — \(context)")
    }
}

@MainActor
@Observable
private final class Stage2LabModel {
    private(set) var events: [LabEvent] = []
    private(set) var isRunning = false

    private var experimentTask: Task<Void, Never>?

    func runHierarchyExperiment() {
        guard experimentTask == nil else { return }

        events.removeAll()
        isRunning = true

        let traceID = UUID().uuidString.prefix(8)

        experimentTask = Task(priority: .userInitiated) {
            defer {
                isRunning = false
                experimentTask = nil
            }

            await Stage2Context.$traceID.withValue(String(traceID)) {
                record("Parent task started")
                record("Parent context — traceID: \(Stage2Context.traceID), priority: \(Task.currentPriority)")

                let child = Task {
                    await childWork(label: "Task { } child", inheritedTraceID: Stage2Context.traceID)
                }

                let detached = Task.detached(priority: .background) {
                    let detachedTraceID = Stage2Context.traceID
                    let detachedPriority = Task.currentPriority

                    print("[Stage 2] Task.detached started — traceID: \(detachedTraceID), priority: \(detachedPriority)")

                    var outcome = "Task.detached summary — traceID: \(detachedTraceID), priority: \(detachedPriority)"

                    do {
                        for step in 1...4 {
                            try Task.checkCancellation()
                            print("[Stage 2] Task.detached step \(step) — traceID: \(Stage2Context.traceID)")
                            try await Task.sleep(for: .milliseconds(250))
                        }

                        outcome += ", completed normally"
                    } catch {
                        outcome += ", cancelled: \(error)"
                    }

                    print("[Stage 2] \(outcome)")
                    return outcome
                }

                record("Spawned child and detached tasks")

                do {
                    try await Task.sleep(for: .seconds(2))
                    record("Parent sleep window completed")

                    let childSummary = await child.value
                    record("Child summary: \(childSummary)")

                    let detachedSummary = await detached.value
                    record("Detached summary: \(detachedSummary)")
                } catch is CancellationError {
                    record("Parent observed cancellation")
                    let detachedSummary = await detached.value
                    record("Detached summary after parent cancellation: \(detachedSummary)")
                } catch {
                    record("Parent failed with error: \(error)")
                }

                record("Parent task finished")
            }
        }
    }

    func cancelHierarchyExperiment() {
        guard let experimentTask else { return }

        record("Cancel requested for parent task")
        experimentTask.cancel()
    }

    private func childWork(label: String, inheritedTraceID: String) async -> String {
        record("\(label) started — traceID: \(inheritedTraceID), priority: \(Task.currentPriority)")

        do {
            for step in 1...4 {
                try Task.checkCancellation()
                record("\(label) step \(step) — traceID: \(Stage2Context.traceID)")
                try await Task.sleep(for: .milliseconds(250))
            }

            let summary = "\(label) summary — traceID: \(Stage2Context.traceID), completed normally"
            record(summary)
            return summary
        } catch {
            let summary = "\(label) summary — traceID: \(Stage2Context.traceID), cancelled: \(error)"
            record(summary)
            return summary
        }
    }

    private func record(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        let context = "time: \(timestamp) · isolation: MainActor · thread diagnostic: \(Thread.isMainThread ? "main" : "not main")"
        let event = LabEvent(message: message, context: context)

        events.append(event)
        print("[Stage 2] \(message) — \(context)")
    }
}

@MainActor
@Observable
private final class Stage3LabModel {
    private(set) var events: [LabEvent] = []
    private(set) var isRunning = false

    private var experimentTask: Task<Void, Never>?

    func runIgnoringCancellationExperiment() {
        guard experimentTask == nil else { return }

        events.removeAll()
        isRunning = true

        experimentTask = Task {
            defer {
                isRunning = false
                experimentTask = nil
            }

            let start = Date()
            record("Ignoring-cancellation experiment started")

            let result = await loadImageWhileIgnoringCancellation()
            let elapsed = Date().timeIntervalSince(start)

            record("Finished: \(result), elapsed: \(elapsed.formatted(.number.precision(.fractionLength(2))))s")
        }
    }

    func runCooperativeCancellationExperiment() {
        guard experimentTask == nil else { return }

        events.removeAll()
        isRunning = true

        experimentTask = Task {
            defer {
                isRunning = false
                experimentTask = nil
            }

            let start = Date()

            do {
                try await withTaskCancellationHandler(operation: {
                    record("Cooperative cancellation experiment started")
                    let image = try await loadImageCooperatively()
                    let elapsed = Date().timeIntervalSince(start)
                    record("Finished: \(image), elapsed: \(elapsed.formatted(.number.precision(.fractionLength(2))))s")
                }, onCancel: {
                    Task { @MainActor in
                        self.record("Cancellation handler ran — cleaning up image load")
                    }
                })
            } catch {
                record("Failed with error: \(error)")
            }
        }
    }

    func cancelExperiment() {
        guard let experimentTask else { return }

        record("Cancel requested for Stage 3 task")
        experimentTask.cancel()
    }

    private func loadImageWhileIgnoringCancellation() async -> String {
        record("Ignoring version entered — cancellation will be observed but not respected")

        for step in 1...4 {
            do {
                record("Ignoring version step \(step) started")
                try await Task.sleep(for: .milliseconds(3000))
                record("Ignoring version step \(step) completed")
            } catch {
                record("Ignoring version step \(step) was cancelled, but the error is intentionally ignored")
            }
        }

        return "Avatar image loaded despite cancellation"
    }

    private func loadImageCooperatively() async throws -> String {
        record("Cooperative version entered — cancellation will be checked explicitly")

        for step in 1...4 {
            try Task.checkCancellation()
            record("Cooperative version step \(step) started")
            try await Task.sleep(for: .milliseconds(1000))
            record("Cooperative version step \(step) completed")
        }

        return "Avatar image loaded cooperatively"
    }

    private func record(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        let context = "time: \(timestamp) · isolation: MainActor · thread diagnostic: \(Thread.isMainThread ? "main" : "not main")"
        let event = LabEvent(message: message, context: context)

        events.append(event)
        print("[Stage 3] \(message) — \(context)")
    }
}

@MainActor
@Observable
private final class Stage4LabModel {
    private(set) var events: [LabEvent] = []
    private(set) var isRunning = false

    private var experimentTask: Task<Void, Never>?

    func runTaskGroupExperiment() {
        guard experimentTask == nil else { return }

        events.removeAll()
        isRunning = true

        let items: [Stage4LoadItem] = [
            Stage4LoadItem(name: "Avatar", delayMilliseconds: 900),
            Stage4LoadItem(name: "Thumbnail", delayMilliseconds: 200),
            Stage4LoadItem(name: "Hero", delayMilliseconds: 700),
            Stage4LoadItem(name: "Badge", delayMilliseconds: 400),
            Stage4LoadItem(name: "Backdrop", delayMilliseconds: 1000)
        ]

        experimentTask = Task {
            defer {
                isRunning = false
                experimentTask = nil
            }

            let start = Date()

            do {
                record("Task group experiment started")
                record("Input order: \(items.map(\.name).joined(separator: ", "))")

                let completionOrder = try await loadAssets(items)
                let elapsed = Date().timeIntervalSince(start)

                record("Completion order: \(completionOrder.joined(separator: ", "))")
                record("Finished: \(completionOrder.count) assets, elapsed: \(elapsed.formatted(.number.precision(.fractionLength(2))))s")
            } catch is CancellationError {
                record("Task group experiment cancelled")
            } catch {
                record("Failed with error: \(error)")
            }
        }
    }

    func cancelTaskGroupExperiment() {
        guard let experimentTask else { return }

        record("Cancel requested for Stage 4 task")
        experimentTask.cancel()
    }

    private func loadAssets(_ items: [Stage4LoadItem]) async throws -> [String] {
        try await withThrowingTaskGroup(of: String.self) { group in
            for item in items {
                group.addTask {
                    try await simulateStage4Load(item)
                }
            }

            var completionOrder: [String] = []

            for try await result in group {
                completionOrder.append(result)
                record("Received completion: \(result)")
            }

            return completionOrder
        }
    }

    private func record(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        let context = "time: \(timestamp) · isolation: MainActor · thread diagnostic: \(Thread.isMainThread ? "main" : "not main")"
        let event = LabEvent(message: message, context: context)

        events.append(event)
        print("[Stage 4] \(message) — \(context)")
    }
}

@MainActor
@Observable
private final class Stage5LabModel {
    private(set) var events: [LabEvent] = []
    private(set) var isRunning = false

    private let cache = ImageCache()
    private let avatarURL = URL(string: "https://example.com/images/avatar.png")!

    func runActorCacheExperiment() {
        guard !isRunning else { return }

        events.removeAll()
        isRunning = true

        Task {
            defer {
                isRunning = false
            }

            record("Actor cache experiment started")
            record("Read nonisolated actor metadata without await: \(cache.name)")

            await cache.removeAll()
            record("Cleared cache through cross-actor call")

            let firstLookup = await cache.image(for: avatarURL)
            record("First lookup result: \(describe(firstLookup))")

            let downloaded = try? await downloadAvatar(from: avatarURL)

            if let downloaded {
                await cache.insert(downloaded)
                record("Inserted downloaded image through actor-isolated mutation")
            }

            let secondLookup = await cache.image(for: avatarURL)
            let cacheCount = await cache.count()

            record("Second lookup result: \(describe(secondLookup))")
            record("Cache count after insert: \(cacheCount)")
            record("Experiment finished — cache state was mutated only inside the ImageCache actor")
        }
    }

    private func downloadAvatar(from url: URL) async throws -> CachedImage {
        record("Simulated download started outside the cache actor")
        try await Task.sleep(for: .milliseconds(700))
        record("Simulated download completed; now we have a Sendable value to pass into the actor")
        return CachedImage(url: url, bytes: 42_000)
    }

    private func describe(_ image: CachedImage?) -> String {
        guard let image else { return "cache miss" }
        return "cache hit, bytes: \(image.bytes)"
    }

    private func record(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        let context = "time: \(timestamp) · isolation: MainActor · thread diagnostic: \(Thread.isMainThread ? "main" : "not main")"
        let event = LabEvent(message: message, context: context)

        events.append(event)
        print("[Stage 5] \(message) — \(context)")
    }
}

@MainActor
@Observable
private final class Stage6LabModel {
    private(set) var events: [LabEvent] = []
    private(set) var isRunning = false

    func runReentrancyExperiment() {
        guard !isRunning else { return }

        events.removeAll()
        isRunning = true

        Task {
            defer {
                isRunning = false
            }

            let account = BankAccount(balance: 100)

            record("Reentrancy experiment started with balance: 100")
            record("Launching two 80-unit withdrawals with async let")

            async let first = account.withdraw(80, label: "A")
            async let second = account.withdraw(80, label: "B")

            let (firstResult, secondResult) = await (first, second)
            let finalBalance = await account.currentBalance()

            record(firstResult.summary)
            record(secondResult.summary)
            record("Final balance: \(finalBalance)")

            if finalBalance < 0 {
                record("Bug exposed: actor isolation prevented a data race, but did not protect the check-then-mutate invariant across await")
            } else {
                record("No overdraft observed this run; run again and inspect where suspension allows reentrancy")
            }
        }
    }

    func runFixedReentrancyExperiment() {
        guard !isRunning else { return }

        events.removeAll()
        isRunning = true

        Task {
            defer {
                isRunning = false
            }

            let account = BankAccount(balance: 100)

            record("Fixed reentrancy experiment started with balance: 100")
            record("Launching two 80-unit withdrawals that revalidate after await")

            async let first = account.withdrawAfterRevalidation(80, label: "A")
            async let second = account.withdrawAfterRevalidation(80, label: "B")

            let (firstResult, secondResult) = await (first, second)
            let finalBalance = await account.currentBalance()

            record(firstResult.summary)
            record(secondResult.summary)
            record("Final balance: \(finalBalance)")

            if finalBalance >= 0 {
                record("Fix confirmed: the balance decision was made after authorization, inside the actor, using current state")
            } else {
                record("Unexpected overdraft; inspect the fixed method because the invariant is still broken")
            }
        }
    }

    func runDuplicateImageRequestExperiment() {
        guard !isRunning else { return }

        events.removeAll()
        isRunning = true

        Task {
            defer {
                isRunning = false
            }

            let pipeline = NaiveImagePipeline()
            let url = URL(string: "https://example.com/images/hero.png")!

            record("Duplicate image request experiment started")
            record("Launching two requests for the same URL against a naive actor pipeline")

            async let first = pipeline.image(for: url, label: "A")
            async let second = pipeline.image(for: url, label: "B")

            let (firstResult, secondResult) = await (first, second)
            let totalDownloads = await pipeline.totalUnderlyingDownloads()

            record(firstResult.summary)
            record(secondResult.summary)
            record("Total underlying downloads: \(totalDownloads)")

            if totalDownloads > 1 {
                record("Bug exposed: both requests observed a cache miss before either stored the downloaded image")
            } else {
                record("No duplicate observed this run; run again and inspect the cache-miss await window")
            }
        }
    }

    func runDeduplicatedImageRequestExperiment() {
        guard !isRunning else { return }

        events.removeAll()
        isRunning = true

        Task {
            defer {
                isRunning = false
            }

            let pipeline = DeduplicatingImagePipeline()
            let url = URL(string: "https://example.com/images/hero.png")!

            record("Deduplicated image request experiment started")
            record("Launching two requests for the same URL against a pipeline that stores in-progress work")

            async let first = pipeline.image(for: url, label: "A")
            async let second = pipeline.image(for: url, label: "B")

            let (firstResult, secondResult) = await (first, second)
            let totalDownloads = await pipeline.totalUnderlyingDownloads()

            record(firstResult.summary)
            record(secondResult.summary)
            record("Total underlying downloads: \(totalDownloads)")

            if totalDownloads == 1 {
                record("Fix confirmed: the second request reused the in-progress task instead of starting another download")
            } else {
                record("Unexpected duplicate; inspect where the in-progress entry is stored")
            }
        }
    }

    private func record(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        let context = "time: \(timestamp) · isolation: MainActor · thread diagnostic: \(Thread.isMainThread ? "main" : "not main")"
        let event = LabEvent(message: message, context: context)

        events.append(event)
        print("[Stage 6] \(message) — \(context)")
    }
}

@MainActor
@Observable
private final class Stage7LabModel {
    private(set) var events: [LabEvent] = []
    private(set) var isRunning = false

    func runSendableExperiment() {
        guard !isRunning else { return }

        events.removeAll()
        isRunning = true

        Task {
            defer {
                isRunning = false
            }

            let metadata = Stage7ImageMetadata(
                url: URL(string: "https://example.com/images/stage7.png")!,
                byteCount: 128_000,
                tags: ["sendable", "value", "image"]
            )
            let auditLog = Stage7AuditLog()
            let scaleFactor = 2

            let describe: @Sendable (Stage7ImageMetadata) async -> String = { metadata in
                try? await Task.sleep(for: .milliseconds(250))
                return "@Sendable closure processed \(metadata.url.lastPathComponent) at scale \(scaleFactor)x"
            }

            record("Sendable experiment started")
            record("Immutable struct prepared: \(metadata.url.lastPathComponent), bytes: \(metadata.byteCount)")
            record("Stage7ImageMetadata is Sendable because its stored properties are Sendable values")

            let summary = await Task.detached(priority: .utility) { [metadata, auditLog, describe] in
                await auditLog.append("Detached task received Sendable metadata for \(metadata.url.lastPathComponent)")

                let closureResult = await describe(metadata)
                await auditLog.append(closureResult)

                await auditLog.append("Actor reference crossed the task boundary; its mutable records stayed actor-isolated")

                return Stage7SendableSummary(messages: await auditLog.snapshot())
            }.value

            for message in summary.messages {
                record(message)
            }

            let mutableBox = Stage7MutableImageBox(byteCount: 128_000)
            record("Created mutable reference type locally: byteCount = \(mutableBox.byteCount)")
            record("Diagnostic example, not compiled here: capturing Stage7MutableImageBox in Task.detached would be rejected because shared mutable class state is not Sendable")
            record("Diagnostic example, not compiled here: an @Sendable closure that mutates a captured var counter would be rejected")
            record("Experiment finished — Sendable is about safe movement across isolation domains, not about background threads")
        }
    }

    func runUncheckedSendableExperiment() {
        guard !isRunning else { return }

        events.removeAll()
        isRunning = true

        Task {
            defer {
                isRunning = false
            }

            let configuration = Stage7ImmutableImageConfiguration(
                preferredScale: 3,
                format: "HEIF"
            )
            let counter = Stage7LockedImageCounter()

            record("@unchecked Sendable experiment started")
            record("Immutable final class crossed safely: scale \(configuration.preferredScale)x, format: \(configuration.format)")
            record("Locked counter uses @unchecked Sendable because the compiler cannot inspect the NSLock invariant")
            record("Invariant: every read and write of counter.value must happen while holding the same lock")

            async let first: String = incrementCounter(counter, label: "A")
            async let second: String = incrementCounter(counter, label: "B")
            async let third: String = incrementCounter(counter, label: "C")

            let summaries = await [first, second, third]
            let finalValue = counter.snapshot()

            for summary in summaries {
                record(summary)
            }

            record("Final locked counter value: \(finalValue)")
            record("@unchecked Sendable is a manual proof. If any access skips the lock, the conformance becomes a lie.")
        }
    }

    private nonisolated func incrementCounter(_ counter: Stage7LockedImageCounter, label: String) async -> String {
        try? await Task.sleep(for: .milliseconds(100))
        let value = counter.increment()
        return "Task \(label) incremented locked counter to \(value)"
    }

    private func record(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        let context = "time: \(timestamp) · isolation: MainActor · thread diagnostic: \(Thread.isMainThread ? "main" : "not main")"
        let event = LabEvent(message: message, context: context)

        events.append(event)
        print("[Stage 7] \(message) — \(context)")
    }
}

#Preview {
    ContentView()
}
