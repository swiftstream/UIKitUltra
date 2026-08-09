# macOS Native Window Tabs

Architecture authority for `WindowTab`, `WindowTabForEach`, and
`WindowTabGroup`. The implementation is split by semantic responsibility:
`MacOS+WindowTabTopology.swift`, `MacOS+WindowTabRuntime.swift`,
`MacOS+WindowTab.swift`, `MacOS+WindowTabForEach.swift`, and
`MacOS+WindowTabGroup.swift`.

## WT-001 — AppKit group is the presentation primitive

Project tabs are represented by AppKit `NSWindow` tab groups. UIKitPlus owns
the declarative topology and lifecycle bridge, but it does not replace the
native tab bar with a horizontal button list. Native AppKit reorder, drag-out,
reattach, close, plus, and overview behavior remain the interaction surface.

## WT-002 — Metadata is eager; content is lazy

`WindowTab` creates its native `NSWindow` and all `NSWindowTab` metadata when
the source item is registered. Its content controller is created only when the
group first selects that tab. `materialize()` is idempotent and retains the
existing controller, so switching, detaching, and reattaching a tab preserve
its local scroll, draft, selection, and responder state. Removing a source item
is the explicit release boundary for that controller. During materialization
UIKitPlus also preserves the window's existing AppKit frame; installing a
content controller must never resize or recenter a tab that is already
presented or restored from autosave. The wrapper covers every mutable
`NSWindowTab` property: title, attributed title, tooltip, and accessory view.

## WT-003 — Topology is a reference-backed state invariant

`WindowTabTopology` is the complete logical state of group order, tab order,
selection, and active group. Its constructor rejects duplicate group IDs,
duplicate tab IDs, empty groups, and selections outside their group. A
`WindowTabGroup` accepts either an internally created `UState` or an exact
caller-owned `UState<WindowTabTopology<ID>>`; every topology write is applied
to AppKit and native changes are reconciled back to that same state.

## WT-004 — Source arrays are the two-way collection invariant

`WindowTabForEach` accepts an exact `UState<[Item]>` (plus a concrete array
convenience initializer), requires stable `Identable` identity, and keeps one
`WindowTab` instance per item ID. Source additions register metadata without
materializing content; source removals close and release the corresponding
window. Native reorder writes back to the source array. Source changes report
explicit `WindowTabMove` values before topology application, so reorder is
identity-preserving rather than an all-items reload. Duplicate IDs fail fast
with a precondition before reconciliation; this prevents ambiguous native
window ownership. `ConfigureHandler` runs once per stable identity. The
optional `UpdateHandler` runs after initial registration and after every source
assignment, including same-ID replacement, and is reserved for repeatable
scalar metadata updates; state bindings belong in `ConfigureHandler`.

## WT-005 — Native detach and close are policy-preserving

Native drag-out is reconciled as a new logical group while retaining the same
tab/window/controller object. Native close asks `closeAllowed`; a denied close
beeps and leaves topology and source state unchanged. A source-array removal is
an explicit force-close and is allowed to release the tab after the source
authoritatively removed it. Tab windows set `isReleasedWhenClosed = false`,
detach their delegate proxy before teardown, and retain tab/window wrappers
through the current AppKit close callback before releasing them on the next
main-runloop turn; this prevents AppKit from messaging or releasing a dangling
wrapper during `windowWillClose`. The proxy owns only close/plus selectors;
`responds(to:)` and Objective-C fast forwarding preserve every other selector
implemented by the caller's original `NSWindowDelegate`.

## WT-006 — Every bindable fluent setter has an autocomplete-friendly pair

Each new bindable tab/window fluent setter exposes a concrete value overload
and a matching concrete `UState` overload. This is intentional: an Xcode user
must see whether a method accepts `String`, `String?`, `Bool`, `NSView?`, or
another exact native type without opening `Stateable`/`StateValuable` generic
constraints. The state overload must apply its current `wrappedValue`
immediately, listen one-way to future writes, weakly capture the tab/window,
retain the listener through the owner state-binding holder, and document
additive repeat-call behavior and teardown. The scalar overload is listener
free. Frame persistence follows the same pair: `frameAutosaveName(_:)` accepts
an explicit AppKit autosave key or its exact state, and installing the key
restores the saved frame while continuing to save later user moves/resizes.
Configuration-only AppKit properties (`NSOpenPanel.identifier` and
`directoryURL`) intentionally remain scalar-only because AppKit may overwrite
them while a panel is running. Live panel/alert properties expose the same
direct/state pair and retain listeners in the UIKitPlus wrapper, not the native
object.

## WT-007 — Framework wrappers own native presentation plumbing

`OpenPanel` and `Alert` provide the UIKitPlus-first native folder-picker and
quit-confirmation boundary used by applications. They expose the relevant
AppKit configuration, result, action, and presentation surfaces, with concrete
value/state overloads for mutable live properties and scalar-only
configuration exceptions. Modal/modeless completion APIs return native
responses and selected URLs without introducing an application-specific
controller.

## Validation

`MacOSWindowTabsDeclarativeTests` is the focused contract suite for topology
invariants, lazy materialization, live state bindings, identity-preserving
source replacement/moves, delegate forwarding, native group/overview access,
and modal wrapper state behavior. Native rendered-app acceptance remains the
application's responsibility.
