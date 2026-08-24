import SwiftUI

struct ContentView: View {
    @State private var model = Stage0LabModel()

    var body: some View {
        NavigationStack {
            List {
                Section("Stage 0 — Concurrency Laboratory") {
                    Text("Mental model")
                        .font(.headline)

                    Text("Task → Executor → Isolation domain")
                        .font(.system(.body, design: .monospaced))

                    Button("Run Stage 0 Experiment") {
                        model.runExperiment()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Section("Log") {
                    if model.events.isEmpty {
                        ContentUnavailableView(
                            "No events yet",
                            systemImage: "play.circle",
                            description: Text("Run the experiment, then inspect the order of events in Xcode's console and here in the app.")
                        )
                    } else {
                        ForEach(model.events) { event in
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

#Preview {
    ContentView()
}
