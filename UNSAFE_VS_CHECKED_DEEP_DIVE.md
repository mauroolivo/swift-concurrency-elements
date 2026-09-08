# Why Both Checked and Unsafe Continuations Crash on Double Resume

## The Reality

Both `withCheckedContinuation` and `withUnsafeContinuation` crash when you resume them twice. The difference is **not whether they crash**, but **how they crash**.

## Internal State Tracking

Both continuations track internal state:

```swift
// Both internally track:
private var resumptionState: ContinuationState
  case notResumed
  case resumed
  case invalid  // Already resumed
```

## The Difference: Diagnostics vs Silence

### withCheckedContinuation (Crashes with Diagnostic)
```swift
func resume(returning value: T) {
    guard resumptionState == .notResumed else {
        // CHECKED: Print helpful diagnostic
        fatalError("Swift Concurrency: resuming a continuation more than once is undefined behavior")
    }
    resumptionState = .resumed
    wakeUpFunction(value)
}
```

**Result on double resume:**
- ✅ Crashes immediately
- ✅ Clear error message telling you what went wrong
- ✅ Easy to debug during development

### withUnsafeContinuation (Crashes Without Diagnostic)
```swift
func resume(returning value: T) {
    // UNSAFE: No check—just try to resume
    // But the underlying state still gets corrupted!
    resumptionState = .resumed  // This may double-write
    wakeUpFunction(value)        // This may double-wake
}
```

**Result on double resume:**
- ❌ Crashes (or exhibits undefined behavior)
- ❌ No diagnostic message
- ❌ Harder to debug—you don't know it's a double-resume bug

## Why Both Crash in Practice

The crash happens because:

1. **First resume** wakes up the suspended function and delivers the value
2. **Second resume** attempts to:
   - Wake an already-woken function
   - Overwrite already-delivered state
   - Corrupt memory/internal structures

Even without the checked wrapper, violating the "resume exactly once" contract causes undefined behavior that typically manifests as a crash.

## The "Undefined Behavior" Myth

People often think unsafe continuations:
- Silently ignore double resumes
- Let the program continue with corrupted state
- Only cause subtle bugs later

**Reality:** Most of the time, they crash immediately, just less gracefully.

**However**, the "undefined" part means:
- Sometimes it crashes with no diagnostic
- Sometimes it crashes with a cryptic error
- In rare cases (with specific timing/optimization), it might silently corrupt
- You can't predict behavior without deep knowledge of the implementation

## The Key Difference

| Aspect | Checked | Unsafe |
|--------|---------|--------|
| Double resume detection | ✅ Yes | ✅ Yes (but by accident) |
| Crashes on double resume | ✅ Yes | ✅ Yes (usually) |
| Helpful diagnostic message | ✅ Yes | ❌ No |
| Developer debugging experience | ✅ Clear | ❌ Confusing |
| Undefined behavior guarantee | ❌ No | ✅ Yes |

## Why Use Unsafe Then?

If unsafe crashes too, why use it at all?

1. **Performance**: Checked continuations have a tiny bit more overhead (state checking)
2. **When you're 100% sure**: After thorough testing, if the callback provably resumes exactly once
3. **Legacy code**: Sometimes you're wrapping old code you can't modify

But **don't use unsafe expecting it to silently handle mistakes**—it won't.

## Practical Conclusion

```swift
// Start here—always
let result = await withCheckedContinuation { continuation in
    // If callback is wrong, you get a clear diagnostic
}

// Only move here after proving callback is correct
let result = await withUnsafeContinuation { continuation in
    // If callback is wrong, you get undefined behavior with no message
}
```

The "unsafe" doesn't mean "more permissive"—it means "I'm responsible for the contract, and if I break it, all bets are off."
