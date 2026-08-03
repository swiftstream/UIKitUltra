# Platform Abstraction

## Metadata
- Layer: Platform
- Depends On Layers: Runtime
- Primary Runtime Artifacts: `BaseView`, `BaseViewController`, `UColor`, `UFont`, `UGestureRecognizer`, `_UImage`, `_STV`, conditional view/controller implementations

## Purpose

Define how UIKitPlus unifies UIKit/AppKit while preserving explicit platform-specific behavior.

## Glass Effect Mapping

- macOS 26+ maps directly to the native `UGlassEffectView: NSGlassEffectView` implementation. [PA1][PA3]
- iOS/iPadOS 26+ use native `UIGlassEffect` and `UIGlassContainerEffect` objects. tvOS 26+ exposes the same native effect fluent extensions because the installed SDK/compiler accepts those APIs. [PA1][PA2][PA3]
- UIKit Glass effects are installed through the existing `UVisualEffectView`; UIKitPlus provides no synthetic UIKit Glass view or wrapper effect. [PA2][PA3]
- Native `UIVisualEffectView` installation may copy a supplied effect. UIKitPlus does not promise supplied-effect identity after installation; the supported contract is the installed native effect type and copied public configuration. [PA1][PA2][PA3]
- `UIView.cornerConfiguration` is exposed by a generic declarative modifier on supported UIKit platforms. [PA2][PA3]
- Mac Catalyst follows the iOS source branch. A dedicated macabi typecheck was not validated in the current toolchain because the compiler failed before source checking with `no such module 'UIKit'`. [PA1][PA3]
- visionOS and watchOS are excluded from this feature. [PA1][PA3]

## Invariants

### PA1: Conditional Compilation Is Authoritative

Platform surface differences are represented explicitly with compile-time conditionals, not runtime guessing.

### PA2: Shared Aliases Anchor Cross-Platform DSL

Core aliases (`BaseView`, `UColor`, etc.) provide shared entry points for DSL/runtime code.

### PA3: Platform-Specific APIs Stay Scoped

Platform-only behavior must stay behind platform conditionals and not leak into shared contracts unintentionally.

### PA4: Native List Platform Mapping

iOS/tvOS `UList` uses `UITableView`; macOS `UList` uses `NSScrollView` plus
view-based `NSTableView`. The macOS implementation uses one headerless,
`.plain`-styled column and native automatic row sizing. `.plain` intentionally
supplies no hidden full-width row padding; callers own visual content insets.
The public high-level intent remains `UList`, while native implementation
details remain platform-explicit. [PA4][PA5][VC5]

### PA5: Native Wrapper First, UIKitPlus Conventions Second

Existing UIKitPlus engineering approaches are authoritative. Before adding a
new class or behavior, inspect comparable UIKitPlus implementations and reuse
their fluent API shape, composition model, state/listener ownership, platform
split, naming, lifecycle, and documentation conventions.

Every new feature is delivered in at least two explicit stages:

1. **Native declarative wrapper** — expose the relevant UIKit/AppKit type,
   property, delegate, data-source, constraint, or lifecycle capability through
   a simple declarative UIKitPlus surface with native semantics intact.
2. **UIKitPlus convenience layer** — add ergonomic state bindings, fluent
   modifiers, builders, mappings, callbacks, composition helpers, or other
   conveniences only by following the established patterns already used by
   analogous UIKitPlus classes.

The second stage extends the native wrapper; it must not replace native behavior
with a parallel runtime.

A new engineering approach, coordination model, lifecycle mechanism, or
abstraction pattern is not an implementation detail an agent may invent. It
requires a written design proposal and explicit approval from the UIKitPlus
author before source mutation.

Edge cases must not be hidden inside compensating heuristics or private hacks.
When callers need control beyond the default native mapping, UIKitPlus should
provide a clean, optional, composable public declarative API through which the
caller explicitly selects or configures that behavior. The default path remains
simple, native, and predictable.

## Forbidden Patterns

- Calling UIKit-only APIs from shared code without guards.
- Calling AppKit-only APIs from shared code without guards.
- Hiding platform-specific behavior under shared names without documentation.
- Designing a new internal approach before inspecting and exhausting analogous
  UIKitPlus patterns already present in the repository.
- Collapsing the native-wrapper stage and convenience stage into opaque behavior
  whose native semantics cannot be identified or controlled by the caller.
- Building parallel layout, resize, scrolling, animation, cell-reuse, or diffing
  engines when UIKit/AppKit already owns the behavior.
- Repeatedly mutating native frames or invalidating native layout from wrapper
  code to compensate for an incorrect declarative constraint graph.
- Globally suppressing native animations as a substitute for choosing the
  correct native API or exposing an explicit declarative option.
- Hiding edge-case heuristics in private implementation when a clean public
  opt-in declarative control can express the requirement.
- Introducing a new engineering pattern without prior written approval from the
  UIKitPlus author.

## Integration Rules

- Before designing a new API, identify and document the analogous UIKitPlus
  classes and the established conventions being reused.
- New functionality must plan and review the native declarative wrapper stage
  separately from the UIKitPlus convenience stage.
- New shared abstractions must declare platform mappings.
- New platform-only APIs must document non-availability on other targets.
- Wrapper implementations must first express behavior through native UIKit or
  AppKit APIs, hierarchy, constraints, delegates, data sources, and lifecycle.
- UIKitPlus conveniences must be composed from established library mechanisms
  and remain layered on top of the native wrapper.
- A genuinely new engineering approach requires a written proposal, explicit
  alternatives, compatibility impact, and approval from the UIKitPlus author
  before implementation.
- Edge-case controls should be public, optional, declarative, composable, and
  explicit at the call site; they must not complicate or silently alter the
  default native path.
- Contract docs must be updated when abstraction boundaries move.

## Audit Implications

Platform patches must verify:
- conditional completeness,
- no leakage across platform boundaries,
- stable shared alias behavior for existing DSL/runtime code.
