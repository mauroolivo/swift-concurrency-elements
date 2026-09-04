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
    @State private var stage8Model = Stage8LabModel()
    @State private var stage9Model = Stage9LabModel()
    @State private var stage10Model = Stage10LabModel()
    @State private var stage11Model = Stage11LabModel()
    @State private var stage12Model = Stage12LabModel()
    @State private var stage13Model = Stage13LabModel()

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

                Section("Stage 8 — Swift 6 Strict Concurrency Migration") {
                    Text("Old service layer → explicit isolation model")
                        .font(.headline)

                    Text("Inspect a legacy shape with static shared, DispatchQueue, mutable class models, completions, and delegates; then run the migrated actor + async API.")

                    Button("Run Legacy Diagnostic Walkthrough") {
                        stage8Model.runLegacyDiagnosticWalkthrough()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(stage8Model.isRunning)

                    Button(stage8Model.isRunning ? "Running…" : "Run Migrated Service Experiment") {
                        stage8Model.runMigratedServiceExperiment()
                    }
                    .buttonStyle(.bordered)
                    .disabled(stage8Model.isRunning)
                }

                Section("Stage 8 Log") {
                    if stage8Model.events.isEmpty {
                        ContentUnavailableView(
                            "No events yet",
                            systemImage: "wrench.and.screwdriver",
                            description: Text("Run the diagnostic walkthrough first, then run the migrated service and compare the isolation boundaries.")
                        )
                    } else {
                        ForEach(stage8Model.events) { event in
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

                Section("Stage 9 — Modern Swift Execution and Default Isolation") {
                    Text("Caller context vs explicit concurrent execution")
                        .font(.headline)

                    Text("Compare an async helper that stays in the caller's isolation context with an explicitly concurrent CPU-style image transform.")

                    Button(stage9Model.isRunning ? "Running…" : "Run Default Isolation Experiment") {
                        stage9Model.runDefaultIsolationExperiment()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(stage9Model.isRunning)

                    Button(stage9Model.isRunning ? "Running…" : "Run Explicit Concurrent Transform") {
                        stage9Model.runConcurrentTransformExperiment()
                    }
                    .buttonStyle(.bordered)
                    .disabled(stage9Model.isRunning)
                }

                Section("Stage 9 Log") {
                    if stage9Model.events.isEmpty {
                        ContentUnavailableView(
                            "No events yet",
                            systemImage: "cpu",
                            description: Text("Run the default isolation experiment first, predict which work stays with MainActor, then compare the concurrent transform.")
                        )
                    } else {
                        ForEach(stage9Model.events) { event in
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

                Section("Stage 10 — Region-Based Isolation and sending") {
                    Text("Transfer ownership of a non-Sendable value")
                        .font(.headline)

                    Text("Move a unique mutable buffer into concurrent work with sending, then compare that with sharing a non-Sendable reference.")

                    Button(stage10Model.isRunning ? "Running…" : "Run sending Transfer Experiment") {
                        stage10Model.runSendingTransferExperiment()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(stage10Model.isRunning)

                    Button("Explain Broken Use-After-Send Sample") {
                        stage10Model.explainBrokenUseAfterSendSample()
                    }
                    .buttonStyle(.bordered)
                    .disabled(stage10Model.isRunning)
                }

                Section("Stage 10 Log") {
                    if stage10Model.events.isEmpty {
                        ContentUnavailableView(
                            "No events yet",
                            systemImage: "arrowshape.turn.up.right.circle",
                            description: Text("Run the sending transfer experiment, then optionally enable STAGE10_BROKEN to inspect the use-after-transfer diagnostic.")
                        )
                    } else {
                        ForEach(stage10Model.events) { event in
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

                Section("Stage 11 — Isolated Parameters and Isolation Forwarding") {
                    Text("Split awaits vs actor-isolated transaction")
                        .font(.headline)

                    Text("Compare a logical operation split across multiple cross-actor awaits with a single API that forwards actor isolation through an isolated parameter.")

                    Button(stage11Model.isRunning ? "Running…" : "Run Split-Await Sequence") {
                        stage11Model.runSplitAwaitSequenceExperiment()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(stage11Model.isRunning)

                    Button(stage11Model.isRunning ? "Running…" : "Run Isolated Transaction Experiment") {
                        stage11Model.runIsolatedTransactionExperiment()
                    }
                    .buttonStyle(.bordered)
                    .disabled(stage11Model.isRunning)

                    Button("Explain #isolation Forwarding Sample") {
                        stage11Model.explainIsolationForwardingSample()
                    }
                    .buttonStyle(.bordered)
                    .disabled(stage11Model.isRunning)
                }

                Section("Stage 11 Log") {
                    if stage11Model.events.isEmpty {
                        ContentUnavailableView(
                            "No events yet",
                            systemImage: "lock.open.trianglebadge.exclamationmark",
                            description: Text("Run the split-await sequence first, then compare with the isolated transaction API and inspect the actor audit trail order.")
                        )
                    } else {
                        ForEach(stage11Model.events) { event in
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

                Section("Stage 12 — Isolated Protocol Conformances") {
                    Text("MainActor-isolated Equatable view model")
                        .font(.headline)

                    Text("Compare a MainActor-isolated class inside a generic Equatable helper, then inspect why a nonisolated conformance would be a problem under Swift 6 strict concurrency.")

                    Button(stage12Model.isRunning ? "Running…" : "Run Isolated Conformance Experiment") {
                        stage12Model.runIsolatedConformanceExperiment()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(stage12Model.isRunning)

                    Button("Explain Broken Nonisolated Conformance Sample") {
                        stage12Model.explainBrokenNonisolatedSample()
                    }
                    .buttonStyle(.bordered)
                    .disabled(stage12Model.isRunning)
                }

                Section("Stage 12 Log") {
                    if stage12Model.events.isEmpty {
                        ContentUnavailableView(
                            "No events yet",
                            systemImage: "text.badge.checkmark",
                            description: Text("Run the isolated conformance experiment, then inspect the generic helper and the Sendable snapshot note.")
                        )
                    } else {
                        ForEach(stage12Model.events) { event in
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

                Section("Stage 13 — AsyncSequence") {
                    Text("Asynchronous streams and async iteration")
                        .font(.headline)

                    Text("Bridge a callback-style download into AsyncThrowingStream, then watch a buffered sensor stream drop intermediate values when the consumer lags behind.")

                    Button(stage13Model.isRunning ? "Running…" : "Run Progress Stream Experiment") {
                        stage13Model.runProgressStreamExperiment()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(stage13Model.isRunning)

                    Button(stage13Model.isRunning ? "Running…" : "Run Failing Stream Experiment") {
                        stage13Model.runFailingStreamExperiment()
                    }
                    .buttonStyle(.bordered)
                    .disabled(stage13Model.isRunning)

                    Button(stage13Model.isRunning ? "Running…" : "Run Buffered Sensor Stream Experiment") {
                        stage13Model.runBufferedSensorStreamExperiment()
                    }
                    .buttonStyle(.bordered)
                    .disabled(stage13Model.isRunning)

                    Button("Cancel Stage 13 Experiment") {
                        stage13Model.cancelExperiment()
                    }
                    .buttonStyle(.bordered)
                    .disabled(!stage13Model.isRunning)
                }

                Section("Stage 13 Log") {
                    if stage13Model.events.isEmpty {
                        ContentUnavailableView(
                            "No events yet",
                            systemImage: "waveform.path.ecg",
                            description: Text("Run a stream experiment and inspect how values arrive over time, how buffering affects delivery, and how cancellation terminates the producer.")
                        )
                    } else {
                        ForEach(stage13Model.events) { event in
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

private struct Stage8ImageRequest: Identifiable, Sendable {
    let id: Int
    let url: URL
}

private struct Stage8ImageSnapshot: Identifiable, Sendable {
    let id: Int
    let url: URL
    let bytes: Int
    let revision: Int

    var summary: String {
        "image #\(id), bytes: \(bytes), revision: \(revision)"
    }
}

private struct Stage8MigrationResult: Sendable {
    let snapshots: [Stage8ImageSnapshot]
    let cachedIDs: [Int]
}

private struct Stage9IsolationProbe: Sendable {
    let label: String
    let suspendedOnce: Bool
    let isolationNote: String

    var summary: String {
        "\(label): suspended once = \(suspendedOnce), isolation note = \(isolationNote)"
    }
}

private struct Stage9ImagePayload: Identifiable, Sendable {
    let id: Int
    let name: String
    let pixelCount: Int
    let seed: Int
}

private struct Stage9TransformReport: Sendable {
    let imageName: String
    let checksum: Int
    let yieldedDuringTransform: Bool
    let isolationNote: String

    var summary: String {
        "\(imageName): checksum \(checksum), yielded = \(yieldedDuringTransform), isolation note = \(isolationNote)"
    }
}

private struct Stage10BufferDigest: Sendable {
    let label: String
    let byteCount: Int
    let checksum: Int
    let mutationCount: Int

    var summary: String {
        "\(label): \(byteCount) bytes, checksum \(checksum), mutations performed after transfer: \(mutationCount)"
    }
}

private struct Stage11TransactionReport: Sendable {
    enum Mode: Sendable {
        case splitAwait
        case isolatedTransaction
    }

    let owner: String
    let mode: Mode
    let succeeded: Bool
    let finalValue: Int?
    let note: String

    var summary: String {
        let modeLabel = mode == .splitAwait ? "split-await" : "isolated-transaction"

        if succeeded {
            return "\(modeLabel) owner \(owner) succeeded, final value: \(finalValue ?? -1)"
        } else {
            return "\(modeLabel) owner \(owner) failed: \(note)"
        }
    }
}

private struct Stage12GalleryItem: Identifiable, Sendable, Equatable {
    let id: Int
    let title: String
    let isPinned: Bool

    var label: String {
        isPinned ? "\(title) 📌" : title
    }
}

private struct Stage12GallerySnapshot: Sendable {
    let title: String
    let selectedTitle: String
    let itemCount: Int

    var summary: String {
        "\(title): selected \(selectedTitle), \(itemCount) items"
    }
}

private enum Stage11DatabaseError: Error, Sendable {
    case transactionAlreadyActive(activeOwner: String, requestedOwner: String)
    case noActiveTransaction(requestedOwner: String)
    case ownerMismatch(activeOwner: String, requestedOwner: String)
}

extension Stage11DatabaseError: CustomStringConvertible {
    var description: String {
        switch self {
        case .transactionAlreadyActive(let activeOwner, let requestedOwner):
            "transactionAlreadyActive(active: \(activeOwner), requested: \(requestedOwner))"
        case .noActiveTransaction(let requestedOwner):
            "noActiveTransaction(requested: \(requestedOwner))"
        case .ownerMismatch(let activeOwner, let requestedOwner):
            "ownerMismatch(active: \(activeOwner), requested: \(requestedOwner))"
        }
    }
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

private nonisolated final class Stage10Buffer {
    var bytes: [UInt8]
    private(set) var mutationCount = 0

    init(bytes: [UInt8]) {
        self.bytes = bytes
    }

    var count: Int {
        bytes.count
    }

    func invertEveryFourthByte() {
        guard !bytes.isEmpty else { return }

        for index in stride(from: 0, to: bytes.count, by: 4) {
            bytes[index] = 255 &- bytes[index]
            mutationCount += 1
        }
    }

    func checksum() -> Int {
        bytes.reduce(0) { partial, byte in
            (partial &* 31 &+ Int(byte)) % 1_000_003
        }
    }
}

private actor Stage11Database {
    private var values: [String: Int] = [:]
    private var activeTransactionOwner: String?
    private var auditTrailEntries: [String] = []

    func reset() {
        values.removeAll()
        activeTransactionOwner = nil
        auditTrailEntries.removeAll()
    }

    func begin(owner: String) throws {
        if let activeTransactionOwner {
            throw Stage11DatabaseError.transactionAlreadyActive(
                activeOwner: activeTransactionOwner,
                requestedOwner: owner
            )
        }

        activeTransactionOwner = owner
        auditTrailEntries.append("begin(owner: \(owner))")
    }

    func upsert(key: String, value: Int, owner: String) throws {
        try ensureActiveOwner(owner)
        values[key] = value
        auditTrailEntries.append("upsert(owner: \(owner), key: \(key), value: \(value))")
    }

    func increment(key: String, by delta: Int, owner: String) throws {
        try ensureActiveOwner(owner)
        values[key, default: 0] += delta
        auditTrailEntries.append("increment(owner: \(owner), key: \(key), delta: \(delta), now: \(values[key, default: 0]))")
    }

    func commit(owner: String) throws -> Int {
        try ensureActiveOwner(owner)
        activeTransactionOwner = nil
        let transactionCount = values.count
        auditTrailEntries.append("commit(owner: \(owner), trackedKeys: \(transactionCount))")
        return transactionCount
    }

    func value(for key: String) -> Int {
        values[key, default: 0]
    }

    func auditTrail() -> [String] {
        auditTrailEntries
    }

    func withTransaction<R: Sendable>(
        owner: String,
        _ body: @Sendable (isolated Stage11Database) throws -> R
    ) throws -> R {
        try begin(owner: owner)

        do {
            let result = try body(self)
            _ = try commit(owner: owner)
            return result
        } catch {
            activeTransactionOwner = nil
            auditTrailEntries.append("rollback(owner: \(owner), reason: \(error))")
            throw error
        }
    }

    private func ensureActiveOwner(_ owner: String) throws {
        guard let activeTransactionOwner else {
            throw Stage11DatabaseError.noActiveTransaction(requestedOwner: owner)
        }

        guard activeTransactionOwner == owner else {
            throw Stage11DatabaseError.ownerMismatch(
                activeOwner: activeTransactionOwner,
                requestedOwner: owner
            )
        }
    }
}

private nonisolated enum Stage2Context {
    @TaskLocal static var traceID: String = "unassigned"
}

#if STAGE8_BROKEN
private final class Stage8LegacyImageRecord {
    let id: Int
    let url: URL
    var bytes: Int

    init(id: Int, url: URL, bytes: Int) {
        self.id = id
        self.url = url
        self.bytes = bytes
    }
}

private protocol Stage8LegacyImageServiceDelegate: AnyObject {
    func legacyService(_ service: Stage8LegacyImageService, didUpdate record: Stage8LegacyImageRecord)
}

private final class Stage8LegacyImageService {
    static let shared = Stage8LegacyImageService()

    private let queue = DispatchQueue(label: "stage8.legacy.image-service", attributes: .concurrent)
    private var records: [Int: Stage8LegacyImageRecord] = [:]

    weak var delegate: Stage8LegacyImageServiceDelegate?

    func fetchImage(id: Int, completion: @escaping (Stage8LegacyImageRecord) -> Void) {
        queue.asyncAfter(deadline: .now() + .milliseconds(250)) {
            let record = self.records[id] ?? Stage8LegacyImageRecord(
                id: id,
                url: URL(string: "https://example.com/images/legacy-\(id).png")!,
                bytes: 32_000
            )

            record.bytes += 1_000
            self.records[id] = record

            completion(record)
            self.delegate?.legacyService(self, didUpdate: record)
        }
    }
}
#endif

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

private actor Stage8ImageRepository {
    private var snapshots: [Int: Stage8ImageSnapshot] = [:]
    private var nextRevision = 1

    func removeAll() {
        snapshots.removeAll()
        nextRevision = 1
    }

    func snapshot(for request: Stage8ImageRequest) async -> Stage8ImageSnapshot {
        if let cached = snapshots[request.id] {
            return cached
        }

        try? await Task.sleep(for: .milliseconds(250 + request.id * 100))

        let snapshot = Stage8ImageSnapshot(
            id: request.id,
            url: request.url,
            bytes: 40_000 + request.id * 8_000,
            revision: nextRevision
        )

        nextRevision += 1
        snapshots[request.id] = snapshot

        return snapshot
    }

    func cachedIDs() -> [Int] {
        snapshots.keys.sorted()
    }
}

private nonisolated struct Stage8MigratedImageService: Sendable {
    let repository: Stage8ImageRepository

    func loadGallery(_ requests: [Stage8ImageRequest]) async -> Stage8MigrationResult {
        await repository.removeAll()

        let snapshots = await withTaskGroup(of: Stage8ImageSnapshot.self) { group in
            for request in requests {
                group.addTask {
                    await repository.snapshot(for: request)
                }
            }

            var loaded: [Stage8ImageSnapshot] = []

            for await snapshot in group {
                loaded.append(snapshot)
            }

            return loaded.sorted { $0.id < $1.id }
        }

        let cachedIDs = await repository.cachedIDs()
        return Stage8MigrationResult(snapshots: snapshots, cachedIDs: cachedIDs)
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

private nonisolated(nonsending) func stage9CallerContextProbe(label: String) async -> Stage9IsolationProbe {
    await Task.yield()

    return Stage9IsolationProbe(
        label: label,
        suspendedOnce: true,
        isolationNote: "nonisolated(nonsending) does not claim independent concurrent execution"
    )
}

@concurrent private nonisolated func stage9DecodeAndTransform(_ payload: Stage9ImagePayload) async -> Stage9TransformReport {
    var checksum = payload.seed
    var yieldedDuringTransform = false

    for index in 0..<payload.pixelCount {
        checksum = (checksum &* 31 &+ index &+ payload.id) % 1_000_003

        if index > 0, index.isMultiple(of: 60_000) {
            yieldedDuringTransform = true
            await Task.yield()
        }
    }

    return Stage9TransformReport(
        imageName: payload.name,
        checksum: checksum,
        yieldedDuringTransform: yieldedDuringTransform,
        isolationNote: "@concurrent nonisolated transform used only Sendable input and local state"
    )
}

@concurrent private nonisolated func stage10ConsumeBuffer(_ buffer: sending Stage10Buffer, label: String) async -> Stage10BufferDigest {
    buffer.invertEveryFourthByte()
    await Task.yield()

    return Stage10BufferDigest(
        label: label,
        byteCount: buffer.count,
        checksum: buffer.checksum(),
        mutationCount: buffer.mutationCount
    )
}

private nonisolated func stage11RunSplitAwaitSequence(
    on database: Stage11Database,
    owner: String,
    key: String,
    seed: Int
) async -> Stage11TransactionReport {
    do {
        try await database.begin(owner: owner)
        await Task.yield()

        try await database.upsert(key: key, value: seed, owner: owner)
        await Task.yield()

        try await database.increment(key: key, by: 5, owner: owner)
        await Task.yield()

        _ = try await database.commit(owner: owner)
        let finalValue = await database.value(for: key)

        return Stage11TransactionReport(
            owner: owner,
            mode: .splitAwait,
            succeeded: true,
            finalValue: finalValue,
            note: ""
        )
    } catch {
        return Stage11TransactionReport(
            owner: owner,
            mode: .splitAwait,
            succeeded: false,
            finalValue: nil,
            note: String(describing: error)
        )
    }
}

private func stage11ApplyDelta(
    on database: isolated Stage11Database,
    owner: String,
    key: String,
    seed: Int
) throws -> Int {
    // This helper runs inside the actor's isolation domain, so no await is needed here.
    try database.upsert(key: key, value: seed, owner: owner)
    try database.increment(key: key, by: 5, owner: owner)
    return database.value(for: key)
}

private nonisolated func stage11RunIsolatedTransaction(
    on database: Stage11Database,
    owner: String,
    key: String,
    seed: Int
) async -> Stage11TransactionReport {
    do {
        let finalValue = try await database.withTransaction(owner: owner) { isolatedDatabase in
            try stage11ApplyDelta(on: isolatedDatabase, owner: owner, key: key, seed: seed)
        }

        return Stage11TransactionReport(
            owner: owner,
            mode: .isolatedTransaction,
            succeeded: true,
            finalValue: finalValue,
            note: ""
        )
    } catch {
        return Stage11TransactionReport(
            owner: owner,
            mode: .isolatedTransaction,
            succeeded: false,
            finalValue: nil,
            note: String(describing: error)
        )
    }
}

@MainActor
private final class Stage12GalleryViewModel {
    let identifier: Int
    var title: String
    var selectedIndex: Int
    var items: [Stage12GalleryItem]

    init(identifier: Int, title: String, selectedIndex: Int, items: [Stage12GalleryItem]) {
        self.identifier = identifier
        self.title = title
        self.selectedIndex = selectedIndex
        self.items = items
    }

    var selectedItem: Stage12GalleryItem {
        items[selectedIndex]
    }

    func snapshot() -> Stage12GallerySnapshot {
        Stage12GallerySnapshot(
            title: title,
            selectedTitle: selectedItem.label,
            itemCount: items.count
        )
    }
}

@MainActor
extension Stage12GalleryViewModel: Equatable {
    static func == (lhs: Stage12GalleryViewModel, rhs: Stage12GalleryViewModel) -> Bool {
        lhs.identifier == rhs.identifier
            && lhs.title == rhs.title
            && lhs.selectedIndex == rhs.selectedIndex
            && lhs.items == rhs.items
    }
}

@MainActor
@Observable
private final class Stage12LabModel {
    private(set) var events: [LabEvent] = []
    private(set) var isRunning = false

    func runIsolatedConformanceExperiment() {
        guard !isRunning else { return }

        events.removeAll()
        isRunning = true

        Task {
            defer {
                isRunning = false
            }

            let primary = Stage12GalleryViewModel(
                identifier: 1,
                title: "Featured",
                selectedIndex: 1,
                items: [
                    Stage12GalleryItem(id: 1, title: "Avatar", isPinned: false),
                    Stage12GalleryItem(id: 2, title: "Hero", isPinned: true),
                    Stage12GalleryItem(id: 3, title: "Badge", isPinned: false)
                ]
            )

            let duplicate = Stage12GalleryViewModel(
                identifier: 1,
                title: "Featured",
                selectedIndex: 1,
                items: [
                    Stage12GalleryItem(id: 1, title: "Avatar", isPinned: false),
                    Stage12GalleryItem(id: 2, title: "Hero", isPinned: true),
                    Stage12GalleryItem(id: 3, title: "Badge", isPinned: false)
                ]
            )

            let different = Stage12GalleryViewModel(
                identifier: 2,
                title: "Library",
                selectedIndex: 0,
                items: [
                    Stage12GalleryItem(id: 4, title: "Backdrop", isPinned: true),
                    Stage12GalleryItem(id: 5, title: "Thumbnail", isPinned: false)
                ]
            )

            record("Concept: a MainActor-isolated reference type can conform to Equatable, but the witness still belongs to the MainActor isolation domain")
            record("Prediction: should a generic helper that uses == stay on MainActor when the conformance is isolated?")

            let primaryMatchesDuplicate = stage12AreEqual(primary, duplicate)
            let primaryMatchesDifferent = stage12AreEqual(primary, different)

            record("Generic Equatable helper result — primary vs duplicate: \(primaryMatchesDuplicate)")
            record("Generic Equatable helper result — primary vs different: \(primaryMatchesDifferent)")

            let matchingCount = stage12CountMatches(primary, in: [primary, duplicate, different])
            record("Generic Equatable helper counted \(matchingCount) matching isolated view models")

            let snapshot = primary.snapshot()
            record("Sendable snapshot for cross-boundary work: \(snapshot.summary)")
            record("The view model itself remains MainActor-isolated; if you need to move data elsewhere, snapshot the value you need instead of shipping the class around")
            record("Observation: isolated protocol conformances keep protocol requirements honest about actor ownership instead of pretending the implementation is freely cross-thread")
        }
    }

    func explainBrokenNonisolatedSample() {
        guard !isRunning else { return }

        events.removeAll()
        record("Broken sample is intentionally behind the STAGE12_BROKEN compilation flag")
        record("If enabled, a nonisolated helper would try to compare Stage12GalleryViewModel values from outside MainActor")
        record("Expected diagnostic: the Equatable witness is isolated, so the comparison must happen inside the MainActor isolation domain")
        record("Do not fix this by making == nonisolated unless the implementation stops touching actor-isolated state")
        record("Optional inspection: add -DSTAGE12_BROKEN to Other Swift Flags and rebuild to see the compiler explain the isolation mismatch")
    }

    @MainActor
    private func stage12AreEqual<T: Equatable>(_ lhs: T, _ rhs: T) -> Bool {
        lhs == rhs
    }

    @MainActor
    private func stage12CountMatches<T: Equatable>(_ probe: T, in values: [T]) -> Int {
        values.filter { $0 == probe }.count
    }

    private func record(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        let context = "time: \(timestamp) · isolation: MainActor · thread diagnostic: \(Thread.isMainThread ? "main" : "not main")"
        let event = LabEvent(message: message, context: context)

        events.append(event)
        print("[Stage 12] \(message) — \(context)")
    }
}

#if STAGE12_BROKEN
nonisolated private func stage12BrokenGenericEquality(_ lhs: Stage12GalleryViewModel, _ rhs: Stage12GalleryViewModel) -> Bool {
    lhs == rhs
}
#endif

#if STAGE10_BROKEN
@MainActor
private func stage10BrokenUseAfterSendExample() async -> Int {
    let buffer = Stage10Buffer(bytes: Array(0..<128).map(UInt8.init))
    let digest = await stage10ConsumeBuffer(buffer, label: "broken sample")

    print("Digest after transfer: \(digest.summary)")

    // Expected Swift 6 diagnostic when STAGE10_BROKEN is enabled:
    // using 'buffer' here attempts to access a non-Sendable reference after its region was transferred.
    return buffer.count
}
#endif

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

@MainActor
@Observable
private final class Stage8LabModel {
    private(set) var events: [LabEvent] = []
    private(set) var isRunning = false

    private let service = Stage8MigratedImageService(repository: Stage8ImageRepository())

    func runLegacyDiagnosticWalkthrough() {
        guard !isRunning else { return }

        events.removeAll()

        record("Concept: migrate an old service by choosing ownership and isolation, not by silencing warnings")
        record("Legacy shape: static shared singleton, DispatchQueue, mutable class records, escaping completion handler, weak delegate")
        record("Prediction: if STAGE8_BROKEN is enabled, which values cross from the queue closure back to UI isolation?")

        record("Diagnostic 1 — static shared mutable service: any isolation domain can reach the same reference and mutate shared records")
        record("Refactor 1 — Stage8ImageRepository is an actor; it owns cache and revision state behind serialized actor isolation")

        record("Diagnostic 2 — DispatchQueue closure captures non-Sendable self, completion, delegate, and mutable records")
        record("Refactor 2 — replace queue callbacks with async functions; suspension is explicit at await points")

        record("Diagnostic 3 — Stage8LegacyImageRecord is a mutable class passed across domains")
        record("Refactor 3 — return Stage8ImageSnapshot, an immutable Sendable value type")

        record("Diagnostic 4 — delegate callbacks do not encode UI isolation")
        record("Refactor 4 — the MainActor view model awaits the service and mutates UI state only on MainActor")

        record("Optional inspection: add -DSTAGE8_BROKEN to Other Swift Flags to compile the legacy sample and inspect Swift 6 diagnostics")
    }

    func runMigratedServiceExperiment() {
        guard !isRunning else { return }

        events.removeAll()
        isRunning = true

        Task {
            defer {
                isRunning = false
            }

            let requests = [
                Stage8ImageRequest(id: 1, url: URL(string: "https://example.com/images/migration-avatar.png")!),
                Stage8ImageRequest(id: 2, url: URL(string: "https://example.com/images/migration-hero.png")!),
                Stage8ImageRequest(id: 3, url: URL(string: "https://example.com/images/migration-badge.png")!)
            ]

            record("Migrated service experiment started")
            record("MainActor view model created \(requests.count) Sendable image requests")
            record("Calling async service API; repository mutable state belongs to Stage8ImageRepository actor")

            let result = await service.loadGallery(requests)

            for snapshot in result.snapshots {
                record("Loaded Sendable snapshot: \(snapshot.summary)")
            }

            record("Repository cached IDs after load: \(result.cachedIDs.map(String.init).joined(separator: ", "))")
            record("Experiment finished — no shared mutable class model, no callback queue hop, no delegate ambiguity")
        }
    }

    private func record(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        let context = "time: \(timestamp) · isolation: MainActor · thread diagnostic: \(Thread.isMainThread ? "main" : "not main")"
        let event = LabEvent(message: message, context: context)

        events.append(event)
        print("[Stage 8] \(message) — \(context)")
    }
}

@MainActor
@Observable
private final class Stage9LabModel {
    private(set) var events: [LabEvent] = []
    private(set) var isRunning = false

    func runDefaultIsolationExperiment() {
        guard !isRunning else { return }

        events.removeAll()
        isRunning = true

        Task {
            defer {
                isRunning = false
            }

            record("Concept: with this project setting, app declarations are MainActor-isolated unless we explicitly choose otherwise")
            record("Prediction: will awaiting a nonisolated(nonsending) helper force this task away from MainActor?")

            let probe = await stage9CallerContextProbe(label: "nonisolated(nonsending) helper called from MainActor task")

            record(probe.summary)
            record("Observation target: the helper has no access to Stage9LabModel state, but it stays in the caller's execution context rather than declaring CPU work elsewhere")
            record("Mental model: task inherits MainActor isolation; await is a suspension point, not a command to run in the background")
        }
    }

    func runConcurrentTransformExperiment() {
        guard !isRunning else { return }

        events.removeAll()
        isRunning = true

        Task {
            defer {
                isRunning = false
            }

            let payloads = [
                Stage9ImagePayload(id: 1, name: "avatar decode", pixelCount: 180_000, seed: 17),
                Stage9ImagePayload(id: 2, name: "hero transform", pixelCount: 220_000, seed: 29),
                Stage9ImagePayload(id: 3, name: "thumbnail filter", pixelCount: 140_000, seed: 41)
            ]

            record("Concurrent transform experiment started from MainActor-isolated UI model")
            record("Prediction: which state crosses the boundary? Only Sendable Stage9ImagePayload values, not the UI model")
            record("Calling @concurrent nonisolated transform functions with async let")

            async let first = stage9DecodeAndTransform(payloads[0])
            async let second = stage9DecodeAndTransform(payloads[1])
            async let third = stage9DecodeAndTransform(payloads[2])

            let reports = await [first, second, third]

            for report in reports {
                record(report.summary)
            }

            record("Transform reports returned to MainActor before mutating events")
            record("Design rule: keep UI ownership on MainActor; move Sendable inputs/results across the boundary for explicit concurrent work")
        }
    }

    private func record(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        let context = "time: \(timestamp) · isolation: MainActor · thread diagnostic: \(Thread.isMainThread ? "main" : "not main")"
        let event = LabEvent(message: message, context: context)

        events.append(event)
        print("[Stage 9] \(message) — \(context)")
    }
}

@MainActor
@Observable
private final class Stage10LabModel {
    private(set) var events: [LabEvent] = []
    private(set) var isRunning = false

    func runSendingTransferExperiment() {
        guard !isRunning else { return }

        events.removeAll()
        isRunning = true

        Task {
            defer {
                isRunning = false
            }

            record("Concept: a non-Sendable reference can sometimes move safely if ownership is transferred, not shared")
            record("Prediction: after passing the buffer to a sending parameter, should this MainActor task keep using that same reference?")

            let bytes = Array(0..<192).map { UInt8($0 % 256) }
            let buffer = Stage10Buffer(bytes: bytes)

            record("Created non-Sendable Stage10Buffer on MainActor with \(buffer.count) bytes")
            record("Transferring the buffer into @concurrent nonisolated work via a sending parameter")

            let digest = await stage10ConsumeBuffer(buffer, label: "transferred buffer")

            record(digest.summary)
            record("After transfer, this task uses only the Sendable digest result, not the original non-Sendable buffer reference")
            record("Mental model: region-based isolation can prove a one-way move even when the class itself is not broadly Sendable")
        }
    }

    func explainBrokenUseAfterSendSample() {
        guard !isRunning else { return }

        events.removeAll()

        record("Broken sample is intentionally behind the STAGE10_BROKEN compilation flag")
        record("If enabled, it transfers a Stage10Buffer with sending and then tries to read buffer.count afterward")
        record("Prediction: Swift should reject that because the original isolation region no longer owns the transferred reference")
        record("This is different from Sendable: the buffer class is still non-Sendable; the safe operation is a one-way ownership transfer")
    }

    private func record(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        let context = "time: \(timestamp) · isolation: MainActor · thread diagnostic: \(Thread.isMainThread ? "main" : "not main")"
        let event = LabEvent(message: message, context: context)

        events.append(event)
        print("[Stage 10] \(message) — \(context)")
    }
}

@MainActor
@Observable
private final class Stage11LabModel {
    private(set) var events: [LabEvent] = []
    private(set) var isRunning = false

    func runSplitAwaitSequenceExperiment() {
        guard !isRunning else { return }

        events.removeAll()
        isRunning = true

        Task {
            defer {
                isRunning = false
            }

            let database = Stage11Database()
            await database.reset()

            record("Concept: a logical operation split into begin/update/commit creates multiple cross-actor suspension points")
            record("Prediction: while owner A is suspended after begin, can owner B run and observe partially-complete transaction state?")

            async let first = stage11RunSplitAwaitSequence(on: database, owner: "A", key: "hero", seed: 10)
            async let second = stage11RunSplitAwaitSequence(on: database, owner: "B", key: "hero", seed: 40)

            let reports = await [first, second]
            for report in reports {
                record(report.summary)
            }

            record("Actor audit trail for split-await sequence:")
            for entry in await database.auditTrail() {
                record("audit: \(entry)")
            }

            record("Observation: actor isolation serialized each entry, but the multi-step invariant spanned several awaits")
        }
    }

    func runIsolatedTransactionExperiment() {
        guard !isRunning else { return }

        events.removeAll()
        isRunning = true

        Task {
            defer {
                isRunning = false
            }

            let database = Stage11Database()
            await database.reset()

            record("Concept: isolation forwarding lets one API run a complete operation inside the actor domain")
            record("Prediction: does the isolated helper need await for actor methods once it receives an isolated Stage11Database?")

            async let first = stage11RunIsolatedTransaction(on: database, owner: "A", key: "hero", seed: 10)
            async let second = stage11RunIsolatedTransaction(on: database, owner: "B", key: "hero", seed: 40)

            let reports = await [first, second]
            for report in reports {
                record(report.summary)
            }

            record("Actor audit trail for isolated transaction API:")
            for entry in await database.auditTrail() {
                record("audit: \(entry)")
            }

            record("Observation: each transaction body ran as one actor-isolated operation with no intermediate await hops")
        }
    }

    func explainIsolationForwardingSample() {
        guard !isRunning else { return }

        events.removeAll()
        record("#isolation sample shape: func transaction(on database: isolated Stage11Database = #isolation) { ... }")
        record("Meaning: caller can forward its current actor isolation explicitly when the API supports it")
        record("Use this for APIs that should stay in an existing isolation domain, not for work that must run concurrently elsewhere")
    }

    private func record(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        let context = "time: \(timestamp) · isolation: MainActor · thread diagnostic: \(Thread.isMainThread ? "main" : "not main")"
        let event = LabEvent(message: message, context: context)

        events.append(event)
        print("[Stage 11] \(message) — \(context)")
    }
}

private struct Stage13DownloadProgress: Identifiable, Sendable {
    let step: Int
    let totalSteps: Int
    let bytesDownloaded: Int

    var id: Int { step }

    var fractionCompleted: Double {
        Double(step) / Double(totalSteps)
    }

    var summary: String {
        let percentage = Int((fractionCompleted * 100).rounded())
        return "progress step \(step)/\(totalSteps) — \(bytesDownloaded) bytes (\(percentage)%)"
    }
}

private struct Stage13SensorSample: Identifiable, Sendable {
    let sequence: Int
    let temperatureCelsius: Double
    let humidityPercent: Int
    let timestamp: Date

    var id: Int { sequence }

    var summary: String {
        let time = timestamp.formatted(date: .omitted, time: .standard)
        return "sample \(sequence) — \(temperatureCelsius.formatted(.number.precision(.fractionLength(1))))°C, \(humidityPercent)% humidity, time: \(time)"
    }
}

private enum Stage13StreamError: Error, Sendable, CustomStringConvertible {
    case cancelled
    case failed(step: Int)

    var description: String {
        switch self {
        case .cancelled:
            "cancelled"
        case .failed(let step):
            "failed(step: \(step))"
        }
    }
}

@MainActor
private final class Stage13LegacyDownloadService {
    private var task: Task<Void, Never>?

    func start(
        assetName: String,
        failAtStep: Int?,
        progress: @escaping @Sendable (Stage13DownloadProgress) -> Void,
        completion: @escaping @Sendable (Result<Void, Stage13StreamError>) -> Void
    ) {
        task?.cancel()

        task = Task {
            let totalSteps = 6

            for step in 1...totalSteps {
                if Task.isCancelled {
                    completion(.failure(.cancelled))
                    return
                }

                try? await Task.sleep(for: .milliseconds(180))

                if Task.isCancelled {
                    completion(.failure(.cancelled))
                    return
                }

                let bytesDownloaded = step * 18_000
                progress(
                    Stage13DownloadProgress(
                        step: step,
                        totalSteps: totalSteps,
                        bytesDownloaded: bytesDownloaded
                    )
                )

                if let failAtStep, step == failAtStep {
                    completion(.failure(.failed(step: step)))
                    return
                }
            }

            completion(.success(()))
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}

private func stage13DownloadProgressStream(
    assetName: String,
    failAtStep: Int? = nil
) -> AsyncThrowingStream<Stage13DownloadProgress, Error> {
    let service = Stage13LegacyDownloadService()

    return AsyncThrowingStream(bufferingPolicy: .bufferingNewest(2)) { continuation in
        service.start(
            assetName: assetName,
            failAtStep: failAtStep,
            progress: { continuation.yield($0) },
            completion: { result in
                switch result {
                case .success:
                    continuation.finish()
                case .failure(let error):
                    continuation.finish(throwing: error)
                }
            }
        )

        continuation.onTermination = { @Sendable _ in
            Task { @MainActor in
                service.cancel()
            }
        }
    }
}

private func stage13BufferedSensorStream() -> AsyncStream<Stage13SensorSample> {
    AsyncStream(bufferingPolicy: .bufferingNewest(3)) { continuation in
        let producer = Task {
            for sequence in 1...10 {
                if Task.isCancelled {
                    break
                }

                try? await Task.sleep(for: .milliseconds(90))

                continuation.yield(
                    Stage13SensorSample(
                        sequence: sequence,
                        temperatureCelsius: 21.0 + Double(sequence) * 0.3,
                        humidityPercent: 42 + sequence,
                        timestamp: Date()
                    )
                )
            }

            continuation.finish()
        }

        continuation.onTermination = { @Sendable _ in
            producer.cancel()
        }
    }
}

@MainActor
@Observable
private final class Stage13LabModel {
    private(set) var events: [LabEvent] = []
    private(set) var isRunning = false

    private var experimentTask: Task<Void, Never>?

    func runProgressStreamExperiment() {
        startExperiment {
            self.record("Progress stream experiment started")
            self.record("Bridging a callback-style download into AsyncThrowingStream with bufferingNewest(2)")
            self.record("Prediction: if the consumer slows down, will every intermediate progress update still be delivered?")

            do {
                var observedSteps: [Int] = []

                for try await progress in stage13DownloadProgressStream(assetName: "hero.png") {
                    observedSteps.append(progress.step)
                    self.record(progress.summary)

                    if progress.step == 2 {
                        self.record("Consumer intentionally pauses here to let the producer outrun the buffer")
                        try? await Task.sleep(for: .milliseconds(360))
                    } else {
                        try? await Task.sleep(for: .milliseconds(120))
                    }
                }

                self.record("Stream finished after observing steps: \(observedSteps.map(String.init).joined(separator: ", "))")
                self.record("Takeaway: AsyncStream buffers values independently of the consumer, but buffering policy decides which values survive pressure")
            } catch {
                self.record("Progress stream failed with error: \(error)")
            }
        }
    }

    func runFailingStreamExperiment() {
        startExperiment {
            self.record("Failing stream experiment started")
            self.record("Prediction: what does the consumer see when the legacy callback API reports an error mid-stream?")

            do {
                var observedSteps: [Int] = []

                for try await progress in stage13DownloadProgressStream(assetName: "broken-hero.png", failAtStep: 4) {
                    observedSteps.append(progress.step)
                    self.record(progress.summary)
                }

                self.record("Unexpectedly finished without error; observed steps: \(observedSteps.map(String.init).joined(separator: ", "))")
            } catch {
                self.record("Consumer caught stream error: \(error)")
                self.record("AsyncThrowingStream cleanly propagated the error from the callback-driven producer")
            }
        }
    }

    func runBufferedSensorStreamExperiment() {
        startExperiment {
            self.record("Buffered sensor stream experiment started")
            self.record("Producer emits temperature samples every 90ms while the consumer pauses for 220ms between reads")
            self.record("Prediction: which sequence numbers will be missing once bufferingNewest(3) starts dropping older values?")

            var observedSequences: [Int] = []

            for await sample in stage13BufferedSensorStream() {
                if let previous = observedSequences.last, sample.sequence > previous + 1 {
                    self.record("Buffer dropped \(sample.sequence - previous - 1) intermediate samples before sequence \(sample.sequence)")
                }

                observedSequences.append(sample.sequence)
                self.record(sample.summary)

                try? await Task.sleep(for: .milliseconds(220))
            }

            self.record("Sensor stream finished after observing sequences: \(observedSequences.map(String.init).joined(separator: ", "))")
            self.record("Takeaway: the producer and consumer are decoupled; buffering policy is part of the API contract")
        }
    }

    func cancelExperiment() {
        guard let experimentTask else { return }

        record("Cancel requested for Stage 13 task")
        experimentTask.cancel()
    }

    private func startExperiment(_ operation: @escaping @MainActor () async -> Void) {
        guard experimentTask == nil else { return }

        events.removeAll()
        isRunning = true

        experimentTask = Task {
            defer {
                isRunning = false
                experimentTask = nil
            }

            await operation()
        }
    }

    private func record(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        let context = "time: \(timestamp) · isolation: MainActor · thread diagnostic: \(Thread.isMainThread ? "main" : "not main")"
        let event = LabEvent(message: message, context: context)

        events.append(event)
        print("[Stage 13] \(message) — \(context)")
    }
}

#Preview {
    ContentView()
}
