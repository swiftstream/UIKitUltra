# Runtime Model

## Metadata
- Layer: Runtime
- Depends On Layers: DSL, Platform
- Primary Runtime Artifacts: `UView._setup`, `_StackView._setup`, `ViewController._setup`, `movedToSuperview`, `PreConstraint` activation, `ForEach.subscribeToChanges`

## Purpose

Define how UIKitPlus applies configuration over object lifecycle, including deferred behavior and update propagation.

## Invariants

### RT1: Setup-Then-Build Lifecycle

Representative runtime lifecycle patterns:
- `UView`: init -> `_setup()` -> `body { body }` -> `buildView()`.
- `_StackView`: init -> `_setup()`.
- `ViewController`: init -> `_setup()` -> `body { body }` -> `buildUI()`.

### RT2: Deferred Constraint Activation

Constraints queued before superview attachment are activated from `movedToSuperview` via solo/super/relative activation passes.

### RT3: Relative Constraint Retry Model

Unresolved relative constraints by tag can register notification-based retry using `AddedViewWithTag`.

### RT4: State-Driven Constraint Constant Updates

`PreConstraint.value.listen` updates the underlying constraint constant and triggers layout refresh.

### RT5: Composition Update Lifecycle

`ForEach` subscriptions use begin/listener/end triggers and diff-based insert/delete propagation into subviews/arrangedSubviews.

### RT6: Trait/Appearance Hooks

Views with trait handlers route trait changes to registered handlers; behavior differs by platform and OS version availability.

## Property and Configuration Timing

- Chain value setters usually apply current value immediately to runtime object state.
- State-based chain setters typically apply `state.wrappedValue` immediately, then attach listeners for future updates.
- Repeated calls to listener-attaching APIs are additive unless explicit dedup logic is implemented.

## Constraint Creation Timing

- Constraint intent is declared at chain-call time by creating `PreConstraint` records.
- Actual `NSLayoutConstraint` creation can be immediate (if hierarchy is ready) or deferred (`movedToSuperview` activation passes).
- Relative constraints may stay deferred until tag lookup succeeds.

## ForEach Runtime Notes

- `subscribeToChanges` wires begin/listener/end callbacks through the source `State<[Item]>`.
- Base insertion paths apply deletions and insertions immediately when listener callbacks fire.
- Diff `modifications` are computed by `ForEach`, but default base handlers may ignore them unless explicit handling is added by owning runtime code.

## Repeated-Registration Hazard Contexts

High-risk contexts for duplicate listener/observer installation:
- setup/lifecycle paths (`_setup`, move/attach lifecycle hooks),
- repeated fluent configuration paths,
- repeated composition/body rebuild paths,
- repeated observer installation paths (for example, notification-based retry wiring).

Required contract language in these contexts:
- ownership of each registration,
- guard/dedup strategy,
- teardown strategy where applicable,
- explicit risk when repeated invocation is allowed.

## Forbidden Patterns

- Assuming all configuration is applied immediately at declaration time.
- Ignoring deferred activation lifecycle when adding new layout APIs.
- Introducing observer registration paths without lifecycle teardown strategy when long-lived.
- Assuming global deterministic ordering across unrelated UI event sources.
- Repeated runtime setup that installs additional listeners/observers without bounds.

## Integration Rules

- New runtime features must declare immediate vs deferred behavior.
- Lifecycle hooks must remain explicit and platform-aware.
- Update propagation paths must document ordering assumptions.
- Repeated-registration behavior must be declared and bounded in lifecycle-sensitive code paths.

## Contract Posture (Synchronized with State and Mutation Models)

1. Logical state/listener propagation is synchronous.
2. Layout/render realization may be deferred by UIKit/AppKit lifecycle and runloop.
3. There is no global determinism across all UI/event paths.
4. Visual state may lag logical mutation.

## Audit Implications

Runtime patches must verify:
- lifecycle ordering compatibility,
- deferred activation correctness,
- observer/listener propagation safety,
- no hidden regressions in ForEach or trait-driven updates.
