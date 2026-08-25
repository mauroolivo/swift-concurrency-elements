# Swift Concurrency Deep Dive

This repository is a hands-on Swift Concurrency lab built around a small SwiftUI iOS app.

The goal is to explore Swift 6 concurrency concepts by iterating through small, focused exercises and observing how tasks, executors, actors, cancellation, task groups, and sendability behave in real code.

> Important: this repo is designed to be used with Copilot or another AI assistant. Give the assistant `CONCURRENCY_COURSE_PROMPT.md` and let it work through the curriculum step by step.

## What’s in the repo

- `swift-concurrency-elements/` — the Xcode app project
- `CONCURRENCY_COURSE_PROMPT.md` — the curriculum/instructions for the lab
- `README.md` — this guide

## How to use the prompt

1. Open `CONCURRENCY_COURSE_PROMPT.md`.
2. Pass the prompt to Copilot or your preferred AI assistant.
3. Let the assistant follow the markdown instructions one stage at a time.
4. In Xcode, run the `swift-concurrency-elements` scheme when the current stage tells you to.
5. When you are ready to move on, say `next`.

Before starting, clean `ContentView.swift` back to the stage 0 baseline if needed. The prompt expects the assistant to reconstruct the file step by step.

The prompt is designed to be followed sequentially. Do not skip ahead unless the instructions explicitly say to do so.

## Quick start

1. Open `swift-concurrency-elements.xcodeproj` in Xcode.
2. Select the `swift-concurrency-elements` scheme.
3. Run on an iOS Simulator.
4. Tap the buttons in the app to observe the logging for each stage.
5. Let the AI rebuild `ContentView.swift` incrementally according to the prompt.

## Stage overview

- **Stage 0 — Concurrency laboratory**: Swift 6 mode, strict concurrency, default actor isolation, and a baseline mental model.
- **Stage 1 — async/await execution semantics**: sequential `await`, suspension points, and `async let`.
- **Stage 2 — Tasks and task hierarchy**: `Task {}` vs `Task.detached`, task-local values, priority, and cancellation inheritance.
- **Stage 3 — Cancellation**: cooperative cancellation, cancellation points, and `withTaskCancellationHandler`.
- **Stage 4 — Structured concurrency and task groups**: `async let`, `withTaskGroup`, `withThrowingTaskGroup`, completion order, and cancellation propagation.
- **Stage 5 — Actors and isolation**: actor-protected mutable state and cross-actor calls.
- **Stage 6 — Actor reentrancy**: how suspension can allow logical races inside an actor.
- **Stage 7 — Sendable**: `Sendable`, `@Sendable`, and when `@unchecked Sendable` is justified.
- **Stage 8 — Swift 6 strict concurrency migration**: modernizing old-style APIs under strict checking.
- **Stage 9 — Modern Swift execution and default isolation**: `nonisolated`, `nonisolated(nonsending)`, and `@concurrent` where relevant.
- **Stage 10 — Region-based isolation and sending**: ownership transfer with `sending`.
- **Stage 11 — Isolated parameters and isolation forwarding**: `isolated` parameters, `#isolation`, and fewer hops.
- **Stage 12 — Isolated protocol conformances**: protocol requirements and actor-isolated types.
- **Stage 13 — AsyncSequence**: streams with `AsyncStream` and `AsyncThrowingStream`.
- **Stage 14 — Continuations**: bridging callback APIs with checked continuations.
- **Stage 15 — Synchronization primitives below actors**: `Mutex` vs actor-based design.
- **Stage 16 — MainActor and UI architecture**: UI-facing models and actor boundaries.
- **Stage 17 — Executors and performance**: scheduling, hops, blocking, and cost.
- **Stage 18 — Final `ConcurrentImagePipeline`**: a production-style concurrency architecture.
- **Stage 19 — Testing concurrent systems**: deterministic concurrency testing with Swift Testing.

## Notes

- The lab is intentionally incremental.
- The exercises are meant to be observed, predicted, and explained — not just compiled.
- Compiler diagnostics are part of the curriculum.

## License

No license has been specified yet.
