# UIKitPlus State vNext Plan

Status: `IN PROGRESS — S1-S5 accepted`

Owner scope: `GLOBAL STATE ARCHITECTURE DEBT`

Primary frameworks:
- UIKitPlus
- SwifDroid
- SwifWeb
- standalone `State` package

Primary user-facing reference:
- SwifDroid `docs/state.md`

Primary implementation reference for Swift 6 strict concurrency:
- `SwifDroid/droid/Sources/Droid/State.swift`

Primary implementation reference for listener lifecycle improvements:
- current UIKitPlus `Classes/Structs/State.swift`
- current UIKitPlus `Classes/Structs/StateListener.swift`
- current UIKitPlus `Classes/Structs/StatesHolder.swift`
- current UIKitPlus `Classes/Protocols/StateBindingOwner.swift`

---

## 1. Purpose

This document records the detailed future plan for repairing and unifying `@State` in UIKitPlus.

This is not an immediate implementation task.

The immediate first major source milestone is:

```text
Migrate UIKitPlus to Swift 6 strict concurrency.
```

Only after UIKitPlus has a stable Swift 6 strict-concurrency baseline should this `State vNext` plan be implemented.

The goal of `State vNext` is not merely to fix UIKitPlus. The goal is to define one shared cross-framework `@State` model for:

```text
SwifDroid + SwifWeb + UIKitPlus
```

and eventually move that model into the standalone `State` package, then consume it from each framework.

---

## 2. Non-Negotiable Principles

### 2.1 Developer experience must remain simple

The external developer experience must remain aligned with the SwifDroid `docs/state.md` model.

A user should continue writing simple declarative code:

```swift
@State var text = "Hello, World!"

UTextView($text)

UButton("Change Text") {
    text = "Text Updated!"
}
```

or equivalent framework-specific APIs.

The user should not need to understand internal listener routing, holder boxes, token registries, or cleanup plumbing when using built-in framework views.

### 2.2 Built-in views must manage listener ownership internally

For standard framework-provided views and controls:

```text
No user-visible `.hold(in:)` should be required.
```

Examples that must remain simple:

```swift
UTextView($title)

ULabel($count.map { "Count: \($0)" })

UButton("Toggle") {
    enabled.toggle()
}
```

The framework is responsible for attaching listeners and releasing them when the view/control/controller is deallocated.

### 2.3 Custom views should use one explicit public lifecycle API

For custom views/controllers/services that manually attach listeners, the public API should be:

```swift
listener.hold(in: self)
```

`hold(in:)` remains the preferred public lifecycle API.

S5 removed the obsolete `holdIfOwned(by:)` helper and all production call sites.
Protocol-extension call sites now use the explicit internal bridge
`holdInStateBindingOwnerIfAvailable(_:)`; concrete owners use direct
`.hold(in: stateBindingHolder)`.

### 2.4 `removeListeners()` is the canonical API

**Implemented (S1).** `removeListeners()` is now the sole bulk listener cleanup API.
`removeAllListeners()` was removed from UIKitPlus source and tests.
Accepted by commit `586fde8`.

### 2.5 `@State` must become Swift 6 strict-concurrency compatible

UIKitPlus must migrate toward the SwifDroid concurrency envelope:

```swift
@MainActor
@propertyWrapper
public final class State<Value: Sendable>: @MainActor Stateable, StatesHolder, Sendable
```

The exact final declaration may differ after ADR review, but the direction is mandatory:

- main-actor isolation for UI-bound state;
- `Value: Sendable` where feasible;
- `State` itself `Sendable` or `@unchecked Sendable` only with documented justification;
- listener closures actor-aware;
- framework UI mutation paths isolated to the main actor;
- no hidden cross-actor UI mutation.

---

## 3. Current Known UIKitPlus Deviations from Desired DX

This section records differences between current UIKitPlus and the SwifDroid `docs/state.md` developer experience.

**S1-S5 are now resolved.** Items 3.1–3.5 are implemented/accepted. S6 remains the next State vNext planning task.

### 3.1 `listenDistinct` — IMPLEMENTED (S2)

**Status**: Implemented and accepted by commit `d2ce34c`.

Desired DX:

```swift
$selectedCountry.listenDistinct { newValue in
    print("Country changed to \(newValue)")
}

$selectedCountry.listenDistinct { oldValue, newValue in
    print("Country changed from \(oldValue) to \(newValue)")
}
```

Current UIKitPlus status:

```text
Implemented:
- `Stateable where Value: Equatable` now has `listenDistinct` overloads.
- `InnerState where InnerValue: Equatable` delegates `listenDistinct` to projected state.
- `CodableState` receives `listenDistinct` through `Stateable`.
- Accepted by commit `d2ce34c`.
```

API surface:

```swift
public extension Stateable where Value: Equatable {
    @discardableResult
    func listenDistinct(_ listener: @escaping (_ value: Value) -> Void) -> StateListener

    @discardableResult
    func listenDistinct(_ listener: @escaping (_ old: Value, _ new: Value) -> Void) -> StateListener
}
```

Semantics:

```text
If old == new, listener is not called.
If old != new, listener is called exactly once in normal listener order.
```

Acceptance tests: ✅

- setting same value does not call `listenDistinct`;
- setting different value calls once;
- old/new overload receives correct values;
- returned token supports `.hold(in:)` and `.cancel()`;
- `listenDistinct` works with `StatesHolder` cleanup;
- `InnerState.listenDistinct` delegates correctly;
- `CodableState.listenDistinct` delegates correctly.

### 3.2 `StateValuable` — IMPLEMENTED, core API migration DEFERRED (S3)

**Status**: Minimal API implemented and accepted by commit `2650186`.
UIKitPlus core API migration deferred per Strategy D.

Desired DX from `state.md`:

```swift
func text<S: StateValuable>(_ value: S) where S.Value == String
```

This allows one API to accept both:

```swift
TitleView().text("Hello")
TitleView().text($titleText)
```

Current UIKitPlus status:

```text
Implemented:
- `StateValuable` protocol exists.
- `State`, `CodableState`, `InnerState`, `String`, `Bool`, `Int`, and `Double` conform.
- Accepted by commit `2650186`.

StateValuable is currently intended for custom user components and examples.
UIKitPlus core API migration is deferred.
```

Reference:

```text
.artifacts/planning/statevaluable-overload-ambiguity-audit.md
Strategy D — Do not migrate UIKitPlus core APIs yet.
```

Why deferred:

- Bool APIs risk overload ambiguity (15+ protocol families accept Bool);
- text APIs are blocked by AnyString/LocalizedString complexity;
- color/font APIs should wait for concurrency ADR;
- existing tests rely on current overloads.

Required API:

```swift
public protocol StateValuable {
    associatedtype Value

    var simpleValue: Value { get }
    var stateValue: State<Value>? { get }
}

extension State: StateValuable {
    public var simpleValue: Value { wrappedValue }
    public var stateValue: State<Value>? { self }
}
```

Base value conformances: `String`, `Bool`, `Int`, `Double` (not Float, CGFloat, URL, Data, etc.).

Preferred custom view pattern:

```swift
class TitleView: UView {
    func text<S: StateValuable>(_ value: S) -> Self where S.Value == String {
        updateLabel(value.simpleValue)

        value.stateValue?
            .listenDistinct { [weak self] newValue in
                self?.updateLabel(newValue)
            }
            .hold(in: self)

        return self
    }
}
```

Acceptance tests: ✅

- static value path applies immediately and creates no listener;
- state value path applies immediately and updates later;
- returned listener is held in the owner;
- no overload ambiguity with existing framework APIs;
- examples from `state.md` compile with UIKitPlus naming.

### 3.3 `removeListeners()` — IMPLEMENTED, CANONICAL (S1)

**Status**: Implemented and accepted by commit `586fde8`.
`removeAllListeners()` was removed; `removeListeners()` is now the sole canonical API.

Desired DX:

```swift
@State var value: String = "Initial"
value.removeListeners()
```

Current UIKitPlus status:

```text
Implemented:
- `removeListeners()` is now the canonical bulk listener cleanup API.
- `removeAllListeners()` was removed from UIKitPlus source/tests.
- Accepted by commit `586fde8`.

Do not reintroduce `removeAllListeners()`.
Docs and user examples should use only `removeListeners()`.
```

API surface:

```swift
public func removeListeners()
```

Acceptance tests: ✅

- `removeListeners()` removes begin triggers, listeners, and end triggers;
- held listener tokens are invalidated;
- manual `cancel()` after `removeListeners()` is safe/no-op.

### 3.4 Multi-state `.and(...)` chain — IMPLEMENTED (S4)

**Status**: Implemented and accepted by commits `10583f7` + `d6be11c`.

Desired DX:

```swift
@State var a = true
@State var b = true
@State var c = 15

TextView("Hey")
    .visibility($a.and($b).and($c).map { a, b, c in
        a && b && c == 15 ? .visible : .gone
    })
```

Current UIKitPlus status:

```text
Implemented:
- `CombinedState3`
- `CombinedState4`
- `CombinedState5`
- `CombinedState6`
- `CombinedState7`
- chained `.and(...)` works up to 7 states;
- `map` closures support 3...7 positional values.

Accepted by:
- 10583f7 🛠 Add multi-state State mapping
- d6be11c 🧪 Strengthen State combined lifecycle tests
```

Lifecycle evidence:

- mapped State owns upstream listener tokens;
- source subscriptions are released through existing `StatesHolder` lifecycle;
- stronger tests cover token counts, expression stop after deinit, `releaseStates`, non-retention, and token deallocation for representative arities 3 and 7.

Acceptance tests: ✅

- `$a.and($b).map { a, b in ... }` compiles and updates;
- `$a.and($b).and($c).map { a, b, c in ... }` compiles and updates;
- up to 7 states compiles and updates;
- nested map composition remains supported;
- listener cleanup works for all source states.

### 3.5 `holdIfOwned(by:)` cleanup — ACCEPTED (S5)

**Status**: Implemented and accepted.

`holdIfOwned(by:)` was an internal transition helper used while protocol
extensions did not always have direct access to a `stateBindingHolder`.

S5 resolved this by:

- adding `holdInStateBindingOwnerIfAvailable(_:)` for protocol-extension routing;
- migrating protocol call sites to that explicit bridge;
- migrating concrete owners to `.hold(in: stateBindingHolder)`;
- removing the obsolete `holdIfOwned(by:)` helper and its characterization test.

Current invariant:

- `Classes` and `Tests` have zero `holdIfOwned` references;
- `holdInStateBindingOwnerIfAvailable(_:)` remains internal;
- public lifecycle docs should continue to present `.hold(in:)` only.

---

## 4. Desired Public API Surface

The final shared State package should support this external surface.

### 4.1 Basic state

```swift
@State var text = "Hello"

TextView($text)
```

### 4.2 Mapping one state

```swift
@State var count = 0

TextView($count.map { "Count: \($0)" })
```

### 4.3 Mapping two states

```swift
@State var one = true
@State var two = true

TextView("Hey")
    .visibility($one.and($two).map { one, two in
        one && two ? .visible : .gone
    })
```

### 4.4 Mapping up to seven states

```swift
@State var a = true
@State var b = true
@State var c = 15

TextView("Hey")
    .visibility($a.and($b).and($c).map { a, b, c in
        a && b && c == 15 ? .visible : .gone
    })
```

### 4.5 Unlimited composition with nested maps

```swift
$one.and($two).map { one, two in
    one && two
}
.and($three)
.map { combined, three in
    combined && three
}
```

### 4.6 Merge / two-way binding

```swift
class SomeSubview: View {
    @State var enabled = true

    func enabled(_ state: State<Bool>) -> Self {
        $enabled.merge(with: state).hold(in: self)
        return self
    }
}
```

### 4.7 Reset

```swift
@State var counter = 0
counter.reset()
```

### 4.8 Listeners

```swift
$selected.listen {
    print("Changed")
}

$selected.listen { newValue in
    print("Changed to \(newValue)")
}

$selected.listen { oldValue, newValue in
    print("Changed from \(oldValue) to \(newValue)")
}
```

### 4.9 Distinct listeners

```swift
$selected.listenDistinct { newValue in
    print("Actually changed to \(newValue)")
}

$selected.listenDistinct { oldValue, newValue in
    print("Actually changed from \(oldValue) to \(newValue)")
}
```

### 4.10 Listener management

```swift
let listener = $status.listen { newValue in
    print(newValue)
}

listener.cancel()
```

### 4.11 Automatic cleanup

```swift
class CustomView: View {
    init(_ state: State<String>) {
        super.init()

        state.listenDistinct { [weak self] newValue in
            self?.updateLabel(newValue)
        }
        .hold(in: self)
    }
}
```

### 4.12 Remove listeners

```swift
@State var value = "Initial"
value.removeListeners()
```

### 4.13 Universal value

```swift
func text<S: StateValuable>(_ value: S) -> Self where S.Value == String {
    updateLabel(value.simpleValue)

    value.stateValue?
        .listenDistinct { [weak self] newValue in
            self?.updateLabel(newValue)
        }
        .hold(in: self)

    return self
}
```

---

## 5. Swift 6 Strict Concurrency Migration Plan

This is the first major prerequisite before implementing `State vNext`.

### 5.1 Goal

Move UIKitPlus toward Swift 6 strict-concurrency compatibility while preserving the external `@State` DX.

### 5.2 Reference

Use SwifDroid as the initial concurrency reference:

```swift
@MainActor
@propertyWrapper
public final class State<Value: Sendable>: @MainActor Stateable, StatesHolder, Sendable
```

### 5.3 Required investigation before source changes

Audit UIKitPlus for:

```text
@State usage with non-Sendable values
State<Value> public API exposure
State in protocol constraints
State in type-erased wrappers
AnyString / LocalizedString / UColor / UImage Sendable status
UIKit/AppKit object values stored in State
closure Sendability requirements
MainActor isolation of view mutation paths
```

### 5.4 Expected source-impact categories

#### Category A — Safe value states

Examples:

```text
Bool
Int
Double
CGFloat
String
Enums with Sendable payloads
```

Expected to migrate easily.

#### Category B — Framework value wrappers

Examples:

```text
UColor
UImage
AnyString
LocalizedString
UFont
UInsets
```

Need explicit Sendable audit. Some may need:

```swift
@unchecked Sendable
```

only if thread-safety and main-actor usage are documented.

#### Category C — UIKit/AppKit reference objects

Examples:

```text
UIView
NSView
UIImage
NSImage
UIColor
NSColor
NSAttributedString / NSMutableAttributedString
```

Need careful handling. Many are not naturally Sendable. The preferred model is main-actor confinement, not unsafe cross-actor transfer.

#### Category D — Custom user reference types

Potential source break:

```swift
@State var object = SomeClass()
```

If `SomeClass` is not Sendable, strict concurrency migration may fail.

Required documentation:

```text
`@State` values should be Sendable.
For non-Sendable reference objects, keep them outside State or isolate them explicitly.
```

### 5.5 Concurrency design decisions needed

Before implementation, write an ADR deciding:

1. Should `State<Value>` require `Value: Sendable` immediately?
2. Should there be a migration grace period with `State<Value>` plus warnings/docs?
3. Should UIKitPlus define `@MainActor State<Value>` but delay `Value: Sendable`?
4. Should closure parameters be `@MainActor` / `@Sendable`?
5. Should `StateListener` be a class, struct, Sendable, or @unchecked Sendable?
6. Should `StatesHolderValuesBox` be `@unchecked Sendable`?
7. How should UIKit/AppKit reference values be handled?
8. Is `open class State` still needed, or should it become `final class` like SwifDroid?

### 5.6 Initial preferred direction

Preferred target, pending ADR:

```swift
@MainActor
@propertyWrapper
public final class State<Value: Sendable>: Stateable, StatesHolder, Sendable
```

Potential compatibility concern:

```text
UIKitPlus currently has `open class State<Value>`.
Changing `open` to `final` is source-breaking for users who subclass State.
Need audit to determine if subclassing is intentionally supported.
```

If source compatibility matters, consider:

```swift
@MainActor
@propertyWrapper
open class State<Value: Sendable>: Stateable, StatesHolder, @unchecked Sendable
```

but this is less strict and must be justified.

### 5.7 Concurrency acceptance tests

Add tests/build checks for:

- Swift 6 language mode build;
- strict concurrency diagnostics;
- `@State` mutation on main actor;
- listener callbacks execute on expected actor;
- UI-bound listeners do not cross actor boundaries;
- Sendable value states compile;
- representative framework value states compile;
- non-Sendable value diagnostics are documented.

---

## 6. Shared State Package Plan

### 6.1 Current problem

The standalone `State` package is old and not currently suitable as canonical.

Known missing pieces:

```text
@MainActor
Sendable
StateListener token lifecycle
StatesHolder
TempStatesHolder
hold(in:)
listenDistinct
StateValuable
multi-state and/map
removeListeners()
modern bidirectional map guard
```

### 6.2 Desired final architecture

Create State vNext in standalone package:

```text
State package
  ├─ State
  ├─ StateListener
  ├─ StatesHolder
  ├─ TempStatesHolder
  ├─ StateValuable
  ├─ CombinedState / multi-state composition
  ├─ InnerState if proven framework-independent
  └─ optional framework adapters if needed
```

Then migrate:

```text
SwifDroid -> depends on State package
SwifWeb   -> depends on State package
UIKitPlus -> depends on State package
```

### 6.3 Framework-specific boundaries

The shared State package must not import:

```text
UIKit
AppKit
Android/JNI frameworks
Web framework APIs
```

Framework-specific integrations should live in framework packages:

```text
UIKitPlus: UIKit/AppKit binding adapters
SwifDroid: Android View binding adapters
SwifWeb: DOM/Web binding adapters
```

### 6.4 Migration order

Recommended order:

1. Finish UIKitPlus governance docs commit.
2. Run independent 52-commit audit.
3. Migrate UIKitPlus to Swift 6 strict concurrency.
4. Write State ADR comparing SwifDroid, UIKitPlus, SwifWeb, and standalone State.
5. Implement State vNext in standalone State package.
6. Add compatibility shims where needed.
7. Migrate one framework first, likely SwifDroid or UIKitPlus depending on audit result.
8. Migrate remaining frameworks.
9. Update all docs, especially `state.md`, to describe the shared external DX.

---

## 7. UIKitPlus Implementation Tracks After Strict Concurrency

### Track 1 — State API parity with `state.md`

**S1-S4 completed.** Remaining:

```text
✅ removeListeners() — canonical API (S1, 586fde8)
✅ listenDistinct — additive Equatable listener API (S2, d2ce34c)
✅ StateValuable minimal API — custom components only (S3, 2650186)
✅ CombinedState3...7 — additive multi-state mapping (S4, 10583f7 + d6be11c)
❌ StateValuable UIKitPlus core API migration — deferred (Strategy D)
```

### Track 2 — Listener lifecycle simplification

**Completed (S5).**

```text
✅ holdIfOwned(by:) obsolete helper removed.
✅ Protocol extensions use holdInStateBindingOwnerIfAvailable(_:).
✅ Concrete owners use direct .hold(in: stateBindingHolder).
✅ Classes/Tests have zero holdIfOwned references.
```

### Track 3 — Built-in view automatic cleanup audit

For every built-in API accepting `State`:

```text
Initial value applied immediately.
Listener updates future values.
Listener does not retain view strongly.
Listener is owned by view/controller lifetime.
No user-visible `.hold(in:)` required.
```

### Track 4 — Custom view documentation

Update docs to use only:

```swift
state.listenDistinct { [weak self] newValue in
    self?.update(newValue)
}
.hold(in: self)
```

### Track 5 — API naming cleanup

**Completed (S1).**

```text
✅ removeListeners() is now canonical.
✅ removeAllListeners() has been removed.
```

### Track 6 — Cross-framework docs sync

Update:

```text
SwifDroid docs/state.md
UIKitPlus docs/state.md or equivalent
SwifWeb docs/state.md or equivalent
State package README/docs
```

All examples must use the same conceptual API.

---

## 8. Required Audits Before State vNext Implementation

### 8.1 UIKitPlus 52-commit audit

Do not push `origin/master` until this is complete.

Focus areas:

```text
State.swift
StateListener.swift
StatesHolder.swift
InnerState.swift
ExpressableState.swift
StateBindingOwner.swift
all `.hold(in: stateBindingHolder)` call sites
all `.hold(in:)` call sites
all State.listen registrations
all State.merge usages
all built-in view State overloads
```

Outputs:

```text
commit-scope audit
runtime behavior audit
test coverage audit
State lifecycle audit
public DX audit
strict concurrency readiness audit
```

### 8.2 SwifDroid State audit

Focus areas:

```text
@MainActor model
Sendable constraints
StateListener struct design
StatesHolder release model
backwardChanged bidirectional guard
CombinedState3...7
StateValuable/listenDistinct presence
state docs compatibility
```

### 8.3 SwifWeb State audit

Required because final State package must serve all three frameworks.

Focus areas:

```text
Does SwifWeb have its own State implementation?
Does it depend on standalone State package?
Does it use @MainActor or browser/event-loop isolation?
Does it expose the same user-facing API?
```

### 8.4 Standalone State package audit

Focus areas:

```text
current API
missing listener token lifecycle
missing concurrency annotations
missing holder model
missing docs
migration feasibility
```

---

## 9. Push Lock

Do not push UIKitPlus `master` to `origin` until all of the following are complete:

1. governance docs committed locally;
2. independent 52-commit audit completed and accepted;
3. critical regressions from the 52-commit audit either fixed or explicitly deferred;
4. State vNext migration risk documented;
5. Swift 6 strict-concurrency migration plan accepted.

Local commits may continue only under audit-gated workflow.

---

## 10. Acceptance Criteria for State vNext

State vNext is not complete until:

### External DX

- examples from SwifDroid `docs/state.md` compile or have equivalent framework-specific versions;
- `@State`, `$state`, `map`, `and`, `merge`, `reset`, `listen`, `listenDistinct`, `hold(in:)`, `cancel`, `removeListeners`, and `StateValuable` are documented consistently;
- built-in views require no manual listener management;
- custom views use `.hold(in:)` only;
- `holdIfOwned(by:)` is fully removed.

### Runtime behavior

- no listener leaks in built-in view state bindings;
- no premature listener cancellation;
- bidirectional map avoids feedback loops;
- merge avoids feedback loops;
- listener cancellation is idempotent;
- removeListeners invalidates held tokens safely;
- multi-state mapped states release source listeners on deinit.

### Strict concurrency

- Swift 6 strict concurrency build passes;
- main-actor UI mutation rules are explicit;
- State value Sendability rules are explicit;
- closure isolation is explicit;
- framework-specific non-Sendable wrappers are audited.

### Cross-framework consistency

- SwifDroid, SwifWeb, and UIKitPlus share the same public conceptual State API;
- standalone State package is the source of truth or there is an accepted ADR explaining why not;
- docs across frameworks do not contradict each other.

---

## 11. State vNext Slice Status

| Slice | Status | Commit / Artifact | Notes |
|---|---|---|---|
| S0 Readiness Audit | Accepted | state-vnext-readiness-audit.md | initial audit |
| S1 removeListeners canonical | Accepted | 586fde8 | canonical API; removeAllListeners removed |
| S2 listenDistinct | Accepted | d2ce34c | additive Equatable listener API |
| S3 StateValuable minimal API | Accepted | 2650186 | custom components only for now |
| S3B StateValuable UIKitPlus API migration audit | Accepted / deferred | statevaluable-overload-ambiguity-audit.md | Strategy D — do not migrate core APIs yet |
| S4 CombinedState3...7 | Accepted | 10583f7 + d6be11c | additive multi-state mapping + lifecycle tests |
| S5 holdIfOwned cleanup | Accepted | holdifowned-audit.md + 92f9163 + 5b4c30b + ff3628c + 531e93c + 561ae57 + 2f5b880 + f7546bb + 4fb53a1 + 3a0af89 + 930181d + c83b9f9 + 9733831 | obsolete helper removed; Classes/Tests zero |
| S6 State concurrency envelope ADR | **Pending** | — | next State vNext task after S5 cleanup |
| S7 shared State package ADR | **Pending** | — | later |

---

## 12. Next Recommended Task

**S6 — State concurrency envelope ADR**

S5 is complete. The next State vNext task is to write an ADR for the
Swift 6 concurrency envelope before changing `State` declarations.

The ADR should decide:

- whether `State` becomes `@MainActor`;
- whether `Value: Sendable` is required;
- whether `State` itself is `Sendable` or `@unchecked Sendable`;
- how listener closures are isolated;
- what migration path avoids breaking existing UIKitPlus APIs.
