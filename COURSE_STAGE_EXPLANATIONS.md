# Swift Concurrency Course — Stage-by-Stage Explanations

This document explains every stage defined in `CONCURRENCY_COURSE_PROMPT.md`.
It is based on the prompt itself plus the matching implementation in `swift-concurrency-elements/ContentView.swift` and, for Stage 19, the test files in `swift-concurrency-elementsTests/Stage19/`.

---

## Stage 0 — Concurrency laboratory

### Explanation
Stage 0 sets up the mental model for the whole course. The point is not to memorize thread behavior, but to start thinking in terms of **tasks**, **executors**, and **isolation domains**. The experiment begins inside UI-isolated code, starts a `Task { }`, suspends with `Task.yield()`, and then resumes while still respecting `MainActor` ownership.

The key lesson is that suspension does **not** mean “the code is now free to mutate UI from anywhere.” The task may suspend and resume, but the UI state still belongs to `MainActor`.

### Representative snippet
```swift
Task {
    record("Task { } started from MainActor-isolated code")
    await Task.yield()
    record("Task resumed after suspension")
}
```

### Mental model
**Task → Executor → Isolation domain**

A task is the unit of work, an executor decides where that work runs, and isolation defines what state that work is allowed to touch.

### Takeaways
- Prefer thinking about **isolation** over raw threads.
- `await` introduces suspension, not permission to ignore actor ownership.
- Compiler diagnostics in strict concurrency mode are teaching tools, not noise.

---

## Stage 1 — async/await execution semantics

### Explanation
Stage 1 shows that `async`/`await` does not automatically mean parallelism. If you `await` two async functions one after the other, they run sequentially. If you use `async let`, they can overlap as child tasks.

The code compares two approaches:
- `let user = try await fetchUser(); let posts = try await fetchPosts()`
- `async let user = fetchUser(); async let posts = fetchPosts()`

Both functions suspend with `Task.sleep`, making the timing difference visible. The sequential version takes about twice as long because each await finishes before the next one starts.

### Representative snippet
```swift
async let user = fetchUser()
async let posts = fetchPosts()
let (loadedUser, loadedPosts) = try await (user, posts)
```

### Mental model
`await` marks a **suspension point**. It does not mean “run on a background thread.”

### Takeaways
- Sequential `await` is still sequential.
- `async let` creates structured child tasks that can overlap.
- Code before the first suspension runs synchronously in the current context.

---

## Stage 2 — Tasks and task hierarchy

### Explanation
Stage 2 teaches that not all tasks are born equal. A child task created with `Task { }` inherits important context from its parent, while `Task.detached` deliberately starts fresh.

The experiment records inherited task-local values, priority, and cancellation behavior. A parent task sets a trace ID, then spawns both an inherited child and a detached task. The child sees the inherited trace ID and priority; the detached task does not inherit that same structured context.

### Representative snippet
```swift
let child = Task {
    await childWork(label: "Task { } child", inheritedTraceID: Stage2Context.traceID)
}

let detached = Task.detached(priority: .background) {
    let detachedTraceID = Stage2Context.traceID
    let detachedPriority = Task.currentPriority
    return "Task.detached summary — traceID: \(detachedTraceID), priority: \(detachedPriority)"
}
```

### Mental model
`Task { }` is a **child inside the family tree**. `Task.detached` is a **new root task**.

### Takeaways
- `Task { }` inherits actor context, priority, task-local values, and cancellation linkage.
- `Task.detached` does not inherit structured context the same way.
- Detached work should be explicit because it weakens structure and ownership.

---

## Stage 3 — Cancellation

### Explanation
Stage 3 teaches that cancellation in Swift is **cooperative**. Cancelling a task does not forcibly stop arbitrary work. The task has to either hit a suspension point that throws cancellation or explicitly check for cancellation.

The stage compares two loaders:
- one that catches cancellation and keeps going anyway
- one that calls `Task.checkCancellation()` and exits promptly

It also demonstrates `withTaskCancellationHandler`, which is where cleanup logic belongs.

### Representative snippet
```swift
for step in 1...4 {
    try Task.checkCancellation()
    record("Cooperative version step \(step) started")
    try await Task.sleep(for: .milliseconds(1000))
}
```

### Mental model
Cancellation is a **stop requested** sign, not a kill switch.

### Takeaways
- Cancellation must be observed to matter.
- `Task.checkCancellation()` is the sharpest way to fail fast.
- Cleanup belongs in `withTaskCancellationHandler`.
- Ignoring cancellation is sometimes useful for demos, but usually wrong in real code.

---

## Stage 4 — Structured concurrency and task groups

### Explanation
Stage 4 introduces task groups for workloads where the number of child tasks is dynamic. Instead of hardcoding a fixed number of `async let` bindings, the stage builds a group, adds one task per asset, and collects results as they finish.

The important observation is that **completion order is not input order**. The fastest item returns first, regardless of where it appeared in the original array.

### Representative snippet
```swift
try await withThrowingTaskGroup(of: String.self) { group in
    for item in items {
        group.addTask {
            try await simulateStage4Load(item)
        }
    }

    for try await result in group {
        completionOrder.append(result)
    }
}
```

### Mental model
A task group is a **dynamic bag of child tasks** whose lifetime stays bound to the parent.

### Takeaways
- Use task groups when the child count is data-driven.
- Results arrive in completion order.
- Parent cancellation propagates into the group.
- This is structured concurrency, not “fire and forget.”

---

## Stage 5 — Actors and isolation

### Explanation
Stage 5 introduces actors as a way to protect mutable shared state. The example is an `ImageCache` actor. Reads and writes to the cache go through actor methods, so mutation is serialized by the actor.

The stage also shows an important exception: truly immutable actor metadata can be marked `nonisolated`, which means callers can read it without `await`.

### Representative snippet
```swift
record("Read nonisolated actor metadata without await: \(cache.name)")

await cache.removeAll()
let firstLookup = await cache.image(for: avatarURL)
await cache.insert(downloaded)
```

### Mental model
An actor is a **single owner of mutable state**.

### Takeaways
- Cross-actor access requires `await`.
- Actor isolation prevents data races on owned mutable state.
- `nonisolated` is appropriate for immutable data that truly needs no actor protection.

---

## Stage 6 — Actor reentrancy

### Explanation
Stage 6 is one of the most important stages in the course. It teaches that actor isolation prevents **data races**, but it does **not** automatically prevent **logical races**.

The bank-account example checks balance, awaits authorization, and then subtracts funds. Two withdrawals can both observe the pre-withdrawal balance before either one commits the change. The result is a broken invariant even though no low-level data race occurred.

The stage then applies the same idea to duplicate image requests. A naive actor pipeline can start duplicate underlying downloads if two calls both observe a cache miss before either stores the result. The fix is to store **in-flight work** and let later callers await the same task.

### Representative snippet
```swift
async let first = pipeline.image(for: url, label: "A")
async let second = pipeline.image(for: url, label: "B")

let totalDownloads = await pipeline.totalUnderlyingDownloads()
```

### Mental model
Every `await` inside an actor is a **reentrancy window**.

### Takeaways
- Actors serialize entry, not whole multi-step intent across suspensions.
- Re-check state after an `await` if earlier assumptions matter.
- Deduplicating in-flight work is a classic reentrancy-safe pattern.

---

## Stage 7 — Sendable

### Explanation
Stage 7 explains what it means for data to safely cross isolation boundaries. `Sendable` is about whether a value can be transferred or shared without introducing unsynchronized shared mutable state.

The code demonstrates several cases:
- immutable value types are naturally good candidates for `Sendable`
- actor references can cross boundaries because the actor still owns its mutable state
- mutable classes are not automatically safe to send
- `@Sendable` closures are restricted in what they can capture
- `@unchecked Sendable` is a manual promise that you must uphold with invariants like locking

### Representative snippet
```swift
let describe: @Sendable (Stage7ImageMetadata) async -> String = { metadata in
    try? await Task.sleep(for: .milliseconds(250))
    return "@Sendable closure processed \(metadata.url.lastPathComponent) at scale \(scaleFactor)x"
}
```

### Mental model
`Sendable` means **safe across isolation boundaries**, not “background-thread friendly.”

### Takeaways
- Immutable value types are the easiest things to send.
- Mutable reference types are dangerous unless protected.
- `@unchecked Sendable` is a proof obligation, not a convenience feature.
- `@Sendable` closures cannot freely capture mutable shared state.

---

## Stage 8 — Swift 6 strict concurrency migration

### Explanation
Stage 8 takes common pre-concurrency architecture patterns and shows how Swift 6 flags them. The legacy shape includes a shared singleton, callback queues, mutable class records, and delegate-style communication.

The migrated design replaces that with actor-owned state, async APIs, and immutable snapshots returned to UI code. The message is that migration should begin with **ownership and isolation design**, not with silencing warnings.

### Representative snippet
```swift
record("Legacy shape: static shared singleton, DispatchQueue, mutable class records, escaping completion handler, weak delegate")
record("Refactor 1 — Stage8ImageRepository is an actor")
record("Refactor 3 — return Stage8ImageSnapshot, an immutable Sendable value type")
```

### Mental model
Migration is an **architecture rewrite of ownership boundaries**, not a search-and-replace exercise.

### Takeaways
- Shared mutable singletons often have no clear isolation owner.
- Callback queues hide boundary crossings that `await` makes explicit.
- Prefer actors for mutable service state.
- Prefer immutable snapshots over passing mutable reference models around.

---

## Stage 9 — Modern Swift execution and default isolation

### Explanation
Stage 9 explores newer execution and isolation tools, especially the distinction between work that should remain in the caller’s context and work that should be explicitly concurrent.

The stage contrasts:
- `nonisolated(nonsending)` helpers that do not capture actor state and stay in the caller’s execution context
- `@concurrent nonisolated` helpers that perform explicit concurrent work on `Sendable` input

This is an important design stage because it teaches you not to assume every helper should “go off main.” Some helpers just need to avoid actor state; others are true parallel computation.

### Representative snippet
```swift
let probe = await stage9CallerContextProbe(label: "nonisolated(nonsending) helper called from MainActor task")

async let first = stage9DecodeAndTransform(payloads[0])
async let second = stage9DecodeAndTransform(payloads[1])
async let third = stage9DecodeAndTransform(payloads[2])
```

### Mental model
`nonisolated(nonsending)` means **don’t touch actor state**. `@concurrent` means **this work is intentionally eligible to run concurrently elsewhere**.

### Takeaways
- `await` does not inherently move execution off `MainActor`.
- Use `@concurrent` for real CPU work on `Sendable` data.
- Keep UI ownership on `MainActor`; move only the data that needs transformation.

---

## Stage 10 — Region-based isolation and sending

### Explanation
Stage 10 teaches a subtle but powerful idea: a type does not need to be broadly `Sendable` if the compiler can prove a **one-way ownership transfer**. The `sending` model is about moving a value, not sharing it.

The example creates a non-Sendable `Stage10Buffer`, passes it into concurrent work, and then only uses the returned `Sendable` digest. The important safety rule is that the original region must stop using the transferred reference.

### Representative snippet
```swift
let buffer = Stage10Buffer(bytes: bytes)
let digest = await stage10ConsumeBuffer(buffer, label: "transferred buffer")
record("After transfer, this task uses only the Sendable digest result")
```

### Mental model
This is **move semantics for isolation**: “I can hand it off if I promise not to keep using it.”

### Takeaways
- `Sendable` and ownership transfer are related but not identical.
- `sending` supports safe movement of non-Sendable references.
- Use-after-transfer should be treated as a correctness bug.

---

## Stage 11 — Isolated parameters and isolation forwarding

### Explanation
Stage 11 shows how to run a multi-step logical operation inside an actor’s isolation domain without splitting it across multiple external awaits.

The stage compares two approaches:
- a split sequence like begin/update/commit with separate cross-actor awaits
- an isolated transaction helper where the actor forwards isolated access into one closure-style operation

This reduces suspension points and narrows the opportunity for reentrancy bugs.

### Representative snippet
```swift
async let first = stage11RunSplitAwaitSequence(on: database, owner: "A", key: "hero", seed: 10)
async let second = stage11RunSplitAwaitSequence(on: database, owner: "B", key: "hero", seed: 40)
```

And the isolated-transaction version:
```swift
async let first = stage11RunIsolatedTransaction(on: database, owner: "A", key: "hero", seed: 10)
async let second = stage11RunIsolatedTransaction(on: database, owner: "B", key: "hero", seed: 40)
```

### Mental model
A split-await sequence is a **transaction in pieces**. An isolated parameter gives you a **transaction as one actor-owned operation**.

### Takeaways
- `isolated` parameters can reduce needless actor hops.
- Fewer suspension points usually means fewer reentrancy hazards.
- `#isolation` is about forwarding an existing isolation domain, not about creating concurrency.

---

## Stage 12 — Isolated protocol conformances

### Explanation
Stage 12 teaches that protocol conformance is part of your isolation architecture. In the example, `Stage12GalleryViewModel` is a `@MainActor`-isolated reference type whose `Equatable` implementation reads `title`, `selectedIndex`, and `items`.

That means the `Equatable` witness itself belongs to the `MainActor` isolation domain. Generic helpers using `==` also need to respect that isolation. The stage explicitly warns against trying to “fix” this by marking things `nonisolated` unless the implementation genuinely stops touching actor-isolated state.

### Representative snippet
```swift
@MainActor
extension Stage12GalleryViewModel: Equatable {
    static func == (lhs: Stage12GalleryViewModel, rhs: Stage12GalleryViewModel) -> Bool {
        lhs.identifier == rhs.identifier
            && lhs.title == rhs.title
            && lhs.selectedIndex == rhs.selectedIndex
            && lhs.items == rhs.items
    }
}
```

### Mental model
If the implementation must read actor-owned state, the conformance must **live where that state lives**.

### Takeaways
- Protocol requirements must respect isolation.
- Generic code using isolated conformances may also need matching isolation.
- Snapshot values are the right way to cross boundaries when the original type is actor-isolated.

---

## Stage 13 — AsyncSequence

### Explanation
Stage 13 bridges callback-driven or producer-driven APIs into async streams. It uses `AsyncThrowingStream` for download progress and `AsyncStream` for sensor samples.

The most important lesson is that the producer and consumer are **decoupled**, and the buffering policy becomes part of the API contract. If the consumer is slow and the stream uses `.bufferingNewest`, some intermediate values may be dropped.

### Representative snippet
```swift
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
}
```

### Mental model
An async stream is a **producer-consumer pipeline with explicit buffering rules**.

### Takeaways
- `AsyncStream` and `AsyncThrowingStream` are great callback bridges.
- Buffering behavior affects correctness and UX.
- Cancellation and termination handling belong in the stream setup.

---

## Stage 14 — Continuations

### Explanation
Stage 14 focuses on converting callback APIs into async functions with continuations. The success case uses `withCheckedContinuation` correctly. Then the stage shows two bugs:
- resuming twice
- never resuming

The checked continuation catches the first bug loudly. The second bug causes a hang because no continuation can infer whether a callback is still pending or forgotten forever.

### Representative snippet
```swift
return await withCheckedContinuation { continuation in
    Task.detached {
        try? await Task.sleep(for: .milliseconds(500))
        continuation.resume(returning: result)
    }
}
```

And the intentional bug:
```swift
continuation.resume(returning: result)
continuation.resume(returning: secondResult) // crash
```

### Mental model
A continuation is a **one-shot promise to resume exactly once**.

### Takeaways
- Start with checked continuations.
- Double resume is a correctness violation and should fail loudly.
- Never-resume bugs need external timeouts or test harnesses to detect.
- “Unsafe” means fewer protections, not more freedom.

---

## Stage 15 — Synchronization primitives below actors

### Explanation
Stage 15 compares a `Mutex`-protected synchronous counter to an actor-backed counter. Both can keep the count correct across concurrent workers, but they expose different APIs and have different tradeoffs.

The mutex version keeps mutation inside a tiny synchronous critical section. The actor version turns each mutation into an async hop. The stage does not say one is universally better; it teaches when each tool fits.

### Representative snippet
```swift
nonisolated func increment(worker: String) -> Int {
    storage.withLock { state in
        state.total += 1
        state.lastWorker = worker
        return state.total
    }
}
```

And the actor version:
```swift
func increment(worker: String) -> Int {
    total += 1
    lastWorker = worker
    return total
}
```

### Mental model
Mutex = **small synchronous lock**. Actor = **owned asynchronous state machine**.

### Takeaways
- Use a mutex for tiny synchronous critical sections.
- Use actors when the protected API is naturally async or may grow into async behavior.
- Both can provide correctness; the right boundary depends on the design.

---

## Stage 16 — MainActor and UI architecture

### Explanation
Stage 16 centers UI architecture around `MainActor`. It shows three patterns for UI updates:
- direct mutation inside `@MainActor` code
- `Task { @MainActor in }`
- `MainActor.run`

It also demonstrates the right separation for expensive work: decode and transform data off the UI actor, then come back once to update visible state.

### Representative snippet
```swift
self.statusMessage = "1/3 direct @MainActor mutation"

await Task { @MainActor in
    self.statusMessage = "2/3 Task { @MainActor in } mutation"
}.value

await MainActor.run {
    self.statusMessage = fetchedLabel
}
```

### Mental model
UI state should have **one obvious owner**: `MainActor`.

### Takeaways
- `@MainActor` should be the default home for UI state.
- `Task { }` inherits caller isolation; `Task.detached` does not.
- Heavy transforms should usually happen away from `MainActor`.
- Return `Sendable` results to the UI boundary and update state once.

---

## Stage 17 — Executors and performance

### Explanation
Stage 17 explains that async syntax alone does not guarantee good runtime behavior. The first experiment contrasts a bad async function that calls blocking `sleep(2)` with a good one that suspends via `Task.sleep`.

The second experiment shows that task creation has overhead. For very tiny work items, an inline loop can beat spawning thousands of child tasks.

The third experiment records task priority behavior for parent, child, and detached work.

### Representative snippet
```swift
self.record("Starting bad async function (sleep(2)) on MainActor")
await stage17BadAsyncFunction()

self.record("Starting good async function (Task.sleep) on MainActor")
await stage17GoodAsyncFunction()
```

### Mental model
Async is about **suspension and scheduling**, not magic parallel speedups.

### Takeaways
- Blocking a cooperative executor is still blocking.
- Task creation is not free.
- Priority is a scheduling hint and inherits differently in child vs detached tasks.
- Measure before assuming more concurrency is faster.

---

## Stage 18 — Final ConcurrentImagePipeline

### Explanation
Stage 18 is the integration stage. It combines the course ideas into a fuller system: cache, in-flight deduplication, network loading, concurrent decode, bounded prefetching, retry behavior, and cancellation behavior.

The stage shows several realistic scenarios:
- duplicate requests share in-flight work
- bounded batch loading caps in-flight pressure
- failures propagate and are evicted so later retries can succeed
- one cancelled waiter does not necessarily destroy shared work for other waiters

### Representative snippet
```swift
async let first = self.pipeline.loadImage(from: avatar)
async let second = self.pipeline.loadImage(from: hero)
async let third = self.pipeline.loadImage(from: avatar)

let fetches = await [first, second, third]
```

And bounded loading:
```swift
let fetches = await self.pipeline.loadBatchBounded(urls, maxConcurrent: 2)
```

### Mental model
Think in layers: **cache → coordinator → loader → decoder → UI consumer**.

### Takeaways
- Store in-flight tasks to deduplicate duplicate callers.
- Bound concurrency to control pressure.
- Evict failed in-flight entries so retries start clean work.
- Cancellation semantics must be designed, not assumed.

---

## Stage 19 — Testing concurrent systems

### Explanation
Stage 19 moves from building concurrent systems to testing them deterministically. Instead of depending on sleeps and timing luck, the test lab creates controllable test doubles.

The `Stage19ControlledNetworkLoader` stores pending continuations and lets tests manually complete them in a chosen order. The tests verify deduplication, cancellation, cache hits, concurrency limits, and even actor reentrancy behavior.

This is important because real concurrent bugs are often hard to reproduce unless the test harness can deliberately create the relevant interleaving.

### Representative snippet
```swift
let firstTask = Task { await pipeline.loadImage(from: url) }
let secondTask = Task { await pipeline.loadImage(from: url) }

await pipeline.loader.awaitPendingCount(atLeast: 1)
await pipeline.loader.completeNext(for: url, result: .success(payload))
```

And the controlled loader pattern:
```swift
return try await withCheckedThrowingContinuation { continuation in
    let request = PendingRequest(id: requestID, url: url, continuation: continuation)
    pending[requestID] = request
    pendingOrder.append(requestID)
}
```

### Mental model
Good concurrency tests use **gates and scripted completions**, not arbitrary delays.

### Takeaways
- Deterministic orchestration is better than sleep-based testing.
- Controlled continuations make interleavings reproducible.
- Test cancellation, deduplication, cache hits, retry behavior, and reentrancy separately.
- Stage 19 turns concurrency behavior into something you can verify on purpose.

---

## Final course arc

The stages form a progression:

1. Understand tasks, suspension, and isolation.
2. Learn structure, cancellation, actors, reentrancy, and Sendability.
3. Apply newer Swift isolation features like `sending`, `isolated`, and isolated conformances.
4. Bridge real-world APIs with streams and continuations.
5. Compare synchronization tools.
6. Build a complete concurrent pipeline.
7. Learn how to test it deterministically.

If you want, the next step I can do is generate a **companion cheatsheet table** from this file with one-row summaries for stages 0–19.