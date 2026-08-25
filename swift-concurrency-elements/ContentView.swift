import SwiftUI

struct ContentView: View {
    @State private var stage0Model = Stage0LabModel()
    @State private var stage1Model = Stage1LabModel()
    @State private var stage2Model = Stage2LabModel()
    @State private var stage3Model = Stage3LabModel()
    @State private var stage4Model = Stage4LabModel()

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

#Preview {
    ContentView()
}
