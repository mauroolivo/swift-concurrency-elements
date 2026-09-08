# Why withCheckedContinuation Detection Works (and Crashes)

## How Checked Continuations Detect and Enforce

`withCheckedContinuation` maintains **internal state** to track whether the continuation has been resumed:

```swift
// Internally Swift tracks:
private var resumptionCount = 0  // Starts at 0
private var value: T?            // The value once resumed

func resume(returning value: T) {
    if resumptionCount > 0 {
        // VIOLATION DETECTED: Already resumed once!
        // Swift's checked continuation crashes here to enforce the contract
        fatalError("Swift Concurrency error: continuation resumed more than once")
    }
    resumptionCount = 1
    self.value = value
    wakeUpSuspendedFunction()
}
```

## The Real Behavior: Crash on Double-Resume

When you call `continuation.resume()` a **second time**:
- ✅ **Checked continuation detects** the violation immediately
- ❌ **Crashes the program** with a fatal error
- 🛑 This is intentional—it enforces the "resume exactly once" contract

**Why crash instead of ignore?**
- Silently ignoring a double-resume would hide a serious bug in your callback API
- A crash during development makes the bug obvious
- Checked continuations prioritize **correctness over robustness** (as they should)
- You *want* to know about this during testing, not have it hide silently

### 2. **Never-Resume is Silent**
The *harder* problem that checked continuations **cannot detect**:
```swift
await withCheckedContinuation { continuation in
    // This callback never calls continuation.resume()
    print("Started but will never resume...")
}
// Waits forever... how can checked continuation detect this?
```

Why? Because Swift can't know:
- Has the callback run yet?
- Is the callback still pending?
- Did the callback forget to resume, or is it intentionally delayed?
- Did the callback crash before calling resume?

There's no timeout mechanism inside the continuation itself.

## The Resume-Twice Detection at Runtime

When you run the Stage 14 experiment for "Run Resume Twice Bug":

```
[Stage 14] Buggy callback firing first resume
→ Async function returns with first value
→ Caller receives result and continues
→ UI updates with the value

[Stage 14] Buggy callback firing second resume
→ Runtime detects: "already resumed"
→ **CRASH** with fatal error
→ Debug your callback API immediately!
```

This is the **intended behavior**. The crash forces you to fix the bug during development.

## Detection Methods Comparison

| Scenario | Checked Continuation | Behavior |
|----------|---------------------|----------|
| Resume twice | ✅ **Yes** | **Fatal crash** to enforce the contract |
| Never resume | ❌ **No** (not possible without timeout) | Hangs silently waiting forever |
| Resume once (correct) | ✅ **Yes** | Success, no issues |

## Why Crash on Double-Resume?

Checked continuations crash because:

1. **Enforces correctness over robustness**
   - The "resume exactly once" contract is non-negotiable
   - If you violate it, the program must fail loudly
   - Silent ignoring would hide a serious bug

2. **Makes bugs obvious during development**
   ```swift
   let result = await withCheckedContinuation { continuation in
       doSomethingAsync {
           continuation.resume(returning: value1)  // ✅ First resume OK
           // ...later...
           continuation.resume(returning: value2)  // ❌ FATAL ERROR!
           // Program crashes here, developer sees bug immediately
       }
   }
   ```

3. **Prevents undefined behavior**
   - With unsafe continuations, a double resume causes unpredictable memory corruption
   - With checked continuations, a double resume causes a predictable, catchable crash
   - This is much better than silent memory corruption

## Practical Implications

### Default to `withCheckedContinuation`
- Catches double-resume bugs with console diagnostics
- Zero runtime cost if callback is correct
- Helps you debug legacy callback APIs

### Use `withUnsafeContinuation` only when:
- You've proven the callback resumes exactly once
- You've measured that checked overhead matters
- You fully control the callback implementation

## How to Detect Never-Resume Bugs

Since checked continuations can't detect hanging, add your own timeout:

```swift
async let result = withCheckedContinuation { continuation in
    callbackAPI { value in
        continuation.resume(returning: value)
    }
}

async let timeout = Task {
    try await Task.sleep(for: .seconds(5))
    throw TimeoutError()
}

do {
    return try await result  // Or try await timeout
} catch {
    print("Continuation never resumed within 5 seconds!")
}
```

## Summary

✅ **Checked continuations DO detect double-resume** → **fatal crash**  
✅ **This enforces the contract** and catches bugs during development  
❌ **They CAN'T detect never-resume** without external timeout logic  
✅ **This design is intentional**—strict correctness over silent failures

---

**Best Practice:** Start with `withCheckedContinuation` for development and debugging. If the callback tries to resume twice, you'll get a crash that forces you to fix the bug. Only migrate to unsafe continuations if:
1. You've thoroughly tested that the callback resumes exactly once
2. Profiling shows checked overhead is a real bottleneck
3. You're certain of the callback contract and can't modify it
