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
- macOS `ViewController` window notifications may be configured before view
  attachment. Observers are registered once per notification name and filter
  delivery against the current `view.window`; repeated callbacks are additive,
  and selector observers are removed during teardown. [RT1][PA1][PA3][FC5][MU3]
- macOS multiline `UText`: configuration preserves native intrinsic sizing and
  delegates width resolution to Auto Layout constraints. Callers can lower
  horizontal compression resistance through the existing declarative modifier
  when text should wrap within constrained space. UIKitPlus does not persist
  provisional width, read a superview width, or run a parallel measurement
  lifecycle. Text-style mutations invalidate intrinsic sizing.
  [RT1][PA1][PA3][FC5]

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

### RT7: Native Menu Retains Declarative Action Owners

UIKitPlus-created macOS menus use a private `_NSMenu: NSMenu` whose Swift
storage strongly retains the declarative `MenuItem` wrappers for the lifetime
of the native menu. This preserves closure targets when AppKit retains only the
native `NSMenu`, including main menus, submenus, status-item menus, contextual
menus, popup menus, and Dock-menu returns. [RT7][PA1][PA3]

The ownership direction is native menu -> storage -> declarative menu items.
Do not restore reverse `_MenuItem`/`MenuItemHelper` root references to
`MenuItem`; releasing the native menu must release the declarative action
owners. [RT7][PA1][PA3]

### RT8: Native List Owns Scoped Diff Composition

A native `UList` owns its ordered section descriptors. A macOS `.forEach`
section retains its `AnyForEach`, and that `ForEach` owns its scoped begin,
listener, and end `StateListener` registrations. Native table cells own only
their currently hosted declarative row root. Reconfiguration synchronously
deactivates and releases the old root constraints, removes the old root,
attaches one newly built root, and activates exactly four native cell-edge
constraints. The generic runtime does not overlap roots, force descendant
layout, cache row views, override responsive scrolling, or measure
application-specific content. [RT8][PA4][MU3]

The ownership direction is list -> section -> ForEach -> scoped listeners and
table -> visible cell -> wrapper root -> current declarative row. Native edge
constraints propagate the AppKit-owned cell width through the wrapper to each
top-level row. The document view follows its clip view through native width
autoresizing, and the table/column autoresizing policies propagate width changes
to cells. `UList` does not override `layout()` for resizing, call column fitting
methods during live resize, or maintain a second resize or height-invalidation
engine. AppKit owns live resize, cell frames, reuse, and automatic row heights.
The macOS table uses `.plain` style, so this native width graph has no hidden
full-width row padding; visual insets are explicit caller constraints.
Diff callbacks capture the list weakly, and releasing the list releases its
scoped `ForEach` listener ownership. [RT8][VC5][ST6][PA4][PA5]

The complete macOS list lifecycle, self-sizing, recycling, live-resize,
height-invalidation, validation, and framework-escalation contract is owned by
`MACOS_ULIST_NSTABLEVIEW.md` (`UL1`–`UL10`). [RT8][UL1][UL10]

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
- no hidden regressions in ForEach or trait-driven updates,
- one subscription per list-owned ForEach and targeted native row operations,
- row-root replacement removes prior roots and constraints,
- no listener/list retain cycle,
- closure-based menu actions survive wrapper release while native-menu ownership exists, [RT7][PA1][PA3]
- releasing the native menu releases declarative wrappers. [RT7][PA1][PA3]
