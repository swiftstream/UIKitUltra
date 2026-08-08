# State System

## Metadata
- Layer: Runtime
- Depends On Layers: DSL, Platform
- Primary Runtime Artifacts: `State`, `InnerState`, `CombinedState`, `ExpressableState` mappings, `merge(with:)`, ordered/snapshot listener dispatch

## Purpose

Define UIKitPlus state as a reference-based reactive engine used by fluent APIs, constraints, gestures, and composition updates.

## Invariants

### ST1: `State` Is Reference-Semantic

`State<Value>` is a class (`@propertyWrapper`) and is shared by reference.

### ST2: Mutation Lifecycle Is Ordered and Synchronous

For `wrappedValue` assignment, runtime order is:
1. capture old value,
2. assign new value (`_wrappedValue = newValue`),
3. run `beginTriggers` in registration order,
4. run listeners in registration order,
5. run `endTriggers` in registration order.

### ST3: Mapping Supports Derived and Bidirectional States

- One-way maps derive state via expression closures.
- Bidirectional map constructor supports reverse writes and uses `backwardChanged` recursion guard.

### ST4: Merge Has Loop Prevention

`merge(with:)` synchronizes two states using dual guard flags (`justSetExternal`, `justSetInternal`) to avoid infinite ping-pong loops.
`merge(with:)` also performs an initial synchronization (`self.wrappedValue = state.wrappedValue`) before wiring listeners.

### ST5: Combined State Is Explicit

`and(_:)` creates `CombinedState`, enabling mapped derivations from two upstream states.

### ST6: Listener Registration Is Additive

Listeners/triggers append to ordered registrations and persist until removed via `removeListeners()` or object lifecycle teardown.

There is no automatic cleanup guarantee unless owning code explicitly provides cleanup.

### ST7: `InnerState` Is Write-Through + Projected

`InnerState<Value, InnerValue>` writes directly through parent key path and maintains projected inner state updates.

### ST8: Bindable Fluent Setters Require a State Surface

Every new or materially changed fluent value setter must be classified during
planning as either bindable or non-bindable.

A setter is bindable when its argument controls a property that can
meaningfully change after the chain is built. A bindable UIKitPlus core API
ships explicit scalar/object and compatible `State`/`UState` overloads in the
same patch. Omitting the state overload requires an explicit reviewed rationale
that the input is command-like, event-like, construction-only, or otherwise
not semantically bindable. Unrelated legacy setters remain out of scope.

The state overload must:

1. apply `wrappedValue` immediately through the scalar/object setter;
2. propagate future assignments one-way with ordinary `listen`, unless a
   different direction or `listenDistinct` policy is explicitly documented;
3. weakly capture a shorter-lived UI/runtime owner and retain the token through
   `.hold(in: stateBindingHolder)` or
   `.holdInStateBindingOwnerIfAvailable(...)`;
4. preserve ST6 additive registration unless deduplication is explicit, and
   document repeat-call and teardown behavior; and
5. leave the scalar/object overload listener-free.

Generic `Stateable`/`StateValuable` core setters remain an FC11 exception while
the migration in `.agent/STATE_VNEXT_PLAN.md` is deferred.

## Mapping and Binding Semantics

- `map(expression)` creates derived states recalculated on source updates.
- Bidirectional mapping updates source state from mapped state writes (`expressionFrom`).
- `TextBindable` and similar APIs should be treated as synchronization hooks, not ownership transfer.

## InnerState Semantics

- `wrappedValue` writes mutate parent `State<Value>` at the key path.
- Parent updates propagate to inner projected state.
- `InnerState` listener propagation has two channels:
  1. direct `InnerState.listen` listeners,
  2. projected `$innerState` listeners.
- Inner-state listener registrations are additive; repeated setup can duplicate callbacks.

## Mutation Hazards

1. Duplicate listener registration from repeated fluent calls.
2. Re-entrant writes when listeners mutate upstream states without guards.
3. Accidental many-to-many synchronization loops when merge/mapped states are chained carelessly.

## Listener Lifecycle and Memory Safety

- Listener registrations are additive and can grow silently under repeated attachment.
- No automatic cleanup is guaranteed for listeners/bindings unless owning code removes or scopes them.
- Closure captures in long-lived listener paths should use weak ownership by default when owner lifetime is shorter than state lifetime.
- Repeated-registration paths must declare ownership, guard/dedup strategy, and teardown strategy where applicable.

## High-Risk Repeated-Registration Contexts

Repeated listener/binding installation is especially dangerous in:
- setup/lifecycle paths,
- repeated fluent configuration paths,
- repeated composition/body rebuild paths,
- repeated observer installation paths.

In these contexts, contract text must state:
- who owns the registration,
- how duplicates are prevented or accepted,
- how/when teardown occurs,
- risk when repeated invocation is not prevented.

## Forbidden Patterns

- Assuming listener attachment is idempotent by default.
- Registering repeated listeners in frequently re-entered lifecycle paths without dedup strategy.
- Storing duplicated authoritative state where derived state is sufficient.
- Hiding two-way binding behavior behind one-way naming.
- Hidden binding setup in chains likely to run more than once.
- Undeclared additive listener side effects in repeated configuration.

## Anti-Pattern Examples

- Registering `state.listen` inside a method commonly called from repeated fluent configuration without any guard.
- Re-attaching lifecycle listeners on every setup entry and never tearing them down.
- Implicit two-way synchronization installation without declaring recursion boundaries.
- Allowing `InnerState`/projected-state listeners to grow across repeated setup/rebuild cycles silently.

## Extension Rules

- Apply ST8 to every new or materially changed fluent value setter before
  implementation.
- Document the scalar/object and state overload separately under FC12.
- Extension methods that attach listeners must document repeat-call behavior.
- If repeat calls are expected, add explicit guard/dedup strategy.
- Prefer explicit synchronization boundaries between derivation (`map`) and bidirectional sync.
- If a method exposes two-way sync semantics, recursion guard behavior must be declared.
- Listener wiring in repeated runtime contexts must declare ownership and teardown expectations.

## Contract Posture (Synchronized with Runtime and Mutation Models)

1. Logical state/listener propagation is synchronous.
2. Layout/render realization may be deferred by UIKit/AppKit lifecycle and runloop.
3. There is no global determinism across all UI/event paths.
4. Visual state may lag logical mutation.

## Audit Implications

State-sensitive patches must verify:
- complete scalar/object + State surface for every bindable setter in scope,
- immediate initial application through the scalar/object path,
- mutation order assumptions,
- recursion guard correctness,
- listener lifecycle safety,
- no unintended synchronization loops.

## State vNext corrective status

- SwifDroid is the canonical reference for the State API shape.
- UIKitPlus must preserve its local improvements:
  - `public typealias UState = State`
  - `removeListeners()`
  - `listenDistinct(...)` on `Stateable`
  - ordered/snapshot listener dispatch
  - improved `StateListener` class lifecycle
  - holder invalidation and targeted release
  - `InnerState`
  - `CodableState`
  - `StateBindingOwner`
- The previous `SharedState`/`SwiftState` extraction track is invalid and stopped.
- `/Users/imike/Development/State` must not be rebuilt until UIKitPlus State is finalized.
- UIKitPlus must not depend on `/Users/imike/Development/State` until that package is rebuilt and validated.
