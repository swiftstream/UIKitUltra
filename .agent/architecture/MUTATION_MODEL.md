# Mutation Model

## Metadata
- Layer: Cross-Layer
- Depends On Layers: DSL, Runtime, Platform
- Primary Runtime Artifacts: fluent setters, state/listener callbacks, `InnerState` write-through, gesture callbacks, `ForEach` diffs, constraint-state links

## Purpose

Define authoritative mutation sources, propagation order, and known safety hazards.

## Invariants

### MU1: Mutation Sources Are Explicit

Primary mutation entry points:
- fluent setters,
- state listener callbacks,
- `InnerState` write-through assignments,
- gesture/action callbacks,
- `ForEach` diff handlers,
- constraint state listeners.

### MU2: Synchronous Propagation Is Default

State/listener updates run synchronously on assignment unless delayed by external platform/event/lifecycle timing.

### MU3: Deferred Paths Are Explicit

Deferred mutation exists in declared runtime paths (for example, pre-constraint activation on `movedToSuperview` and tag-based relative retry).

### MU4: No Implicit Global Batch Engine

UIKitPlus does not provide an implicit repository-wide mutation transaction engine. `beginTrigger`/`endTrigger` are explicit hooks, not automatic batching.

## Ordering Guarantees

- `State` mutation ordering follows `STATE_SYSTEM.md`.
- Common property-binding flow is: apply current value immediately, then react to future listener callbacks.
- `ForEach` diff handlers run from subscribed listener flow.
- Constraint constant updates occur through state-listener callbacks in `PreConstraint`.
- macOS `ViewController` notification handlers register once per notification
  name, filter the native event against the current window at delivery time,
  and append repeated callbacks in registration order. [FC5][MU3][PA3]

## Hazards

1. Duplicate listeners from repeated chain setup.
2. Duplicate observers from repeated notification wiring.
3. Re-entrant writes in bidirectional synchronization paths.
4. Repeated binding setup without dedup protections.

## Forbidden Patterns

- Claiming deterministic total ordering across all UI platform event sources.
- Hiding mutation behind undocumented helper calls.
- Introducing implicit global mutation batching semantics.
- Assuming synchronous logical mutation implies immediate visual/layout realization.

## Integration Rules

- New mutation path must document timing (`immediate` vs `deferred`).
- Two-way synchronization paths must declare recursion guards.
- Observer/listener lifecycle expectations must be explicit.

## Contract Posture (Synchronized with State and Runtime Models)

1. Logical state/listener propagation is synchronous.
2. Layout/render realization may be deferred by UIKit/AppKit lifecycle and runloop.
3. There is no global determinism across all UI/event paths.
4. Visual state may lag logical mutation.

## Audit Implications

Mutation-sensitive patches must verify:
- source-of-mutation clarity,
- propagation ordering assumptions,
- duplicate-registration safety,
- deferred-path correctness.
