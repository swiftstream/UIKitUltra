# Platform Abstraction

## Metadata
- Layer: Platform
- Depends On Layers: Runtime
- Primary Runtime Artifacts: `BaseView`, `BaseViewController`, `UColor`, `UFont`, `UGestureRecognizer`, `_UImage`, `_STV`, conditional view/controller implementations

## Purpose

Define how UIKitUltra preserves UIKit/AppKit-native Apple behavior while exposing a universal DSL across GTK, Qt, Win, Android, and TUI under `NATIVE_BACKENDS.md`. Active source uses the final `UIKitUltra` / `Ultra*` identity scheme and UIKitUltra-owned Windows paths use `Win` / `WinRuntime`; historical evidence may retain legacy `UIKitPlus` or UIKitUltra-owned `WinUI` spellings where historically accurate. Final backend naming is defined by `NATIVE_BACKENDS.md`.

The broad production implementation remains Apple-backed. M2 has an audited GTK owned generator plus real-native primitive/runtime slice; Qt/Win/Android/TUI remain implementation-gated. Apple aliases are compatibility anchors, while foreign backends use their own UIKitUltra-owned wrapper/runtime bases rather than stretching UIKit/AppKit types into a fake universal hierarchy.

## Current Package/Platform Boundary

The package/platform boundary is physically explicit:

- `Package.swift` keeps package/repository identity `UIKitUltra` while exposing the primary public module/product `Ultra`;
- `UltraCore`, `UltraQtRuntime`, and `UltraWinRuntime` remain current internal runtime identities for their present lanes;
- H3 Wave C has completed the GTK production cutover: the external
  native-foundation package/product/module `UltraGTK` replaces the former
  root-owned `UltraGTKRuntime` / `UltraGTKCore` split;
- Linux backend selection remains compile-time explicit through `UltraGTK` / `UltraQt` SwiftPM traits and `Sources/Kit/Exports/BackendSelection.swift` diagnostics;
- Windows selects `UltraWinRuntime` with a platform-conditional dependency;
- Apple `BaseView` remains `NSView` / `UIView`; selected GTK Linux lowers the same semantic role to the external `GTKView` foundation without changing Apple superclass relationships;
- M1 historically introduced `UIKitPlusGTK` / `UIKitPlusQt` / `UIKitPlusWinUI` structural skeletons; those names are historical evidence, not current manifest identity;
- current source contains no live root-owned GTK runtime/adapter ownership
  roots; UIKitUltra keeps the public Linux façade while external `UltraGTK`
  owns the native hierarchy/runtime/generated/C-bridge foundation.

The package structure scopes the existing Apple abstraction; it does not
broaden `BaseView` or other UIKit/AppKit aliases into non-Apple types.
[NB1][NB4][NB6][NB7][NB12]

## Glass Effect Mapping

- macOS 26+ maps directly to the native `UGlassEffectView: NSGlassEffectView` implementation. [PA1][PA3]
- iOS/iPadOS 26+ use native `UIGlassEffect` and `UIGlassContainerEffect` objects. tvOS 26+ exposes the same native effect fluent extensions because the installed SDK/compiler accepts those APIs. [PA1][PA2][PA3]
- UIKit Glass effects are installed through the existing `UVisualEffectView`; UIKitUltra provides no synthetic UIKit Glass view or wrapper effect. [PA2][PA3]
- Native `UIVisualEffectView` installation may copy a supplied effect. UIKitUltra does not promise supplied-effect identity after installation; the supported contract is the installed native effect type and copied public configuration. [PA1][PA2][PA3]
- `UIView.cornerConfiguration` is exposed by a generic declarative modifier on supported UIKit platforms. [PA2][PA3]
- Mac Catalyst follows the iOS source branch. A dedicated macabi typecheck was not validated in the current toolchain because the compiler failed before source checking with `no such module 'UIKit'`. [PA1][PA3]
- visionOS and watchOS are excluded from this feature. [PA1][PA3]

## Invariants

### PA1: Conditional Compilation Is Authoritative

Platform surface differences are represented explicitly with compile-time conditionals, not runtime guessing.

### PA2: Apple Native Types Anchor Compatibility; Shared Semantics May Extend Beyond Apple

Current Apple aliases such as `BaseView`, `UColor`, and related UIKit/AppKit bridge types remain compatibility anchors for the Apple implementation. Apple superclass relationships must not be replaced with synthetic portable base classes merely for backend symmetry.

The *semantic role* may become cross-backend, however. For example `BaseView` may resolve to a backend-owned `GTKView`, `QtView`, `WinView`, `AndroidView`, or `TUIView` on the corresponding build, while Apple continues to resolve to the existing native `NSView` / `UIView` basis. The backend base must be an honest generic view/container for that backend; Android plain `View` is not sufficient for `UView` if child composition would be lost. [NB13]

Shared value vocabulary such as color, control state, image/resource, insets, alignment, and content mode may use Apple typealiases/zero-friction bridges where source compatibility benefits, with backend-owned realizations elsewhere. Exact value-type APIs require their own compatibility review. [NB14][NB16]

### PA3: Platform-Specific APIs Stay Scoped

Platform-only behavior must stay behind platform conditionals and not leak into shared contracts unintentionally.

### PA4: Native List Platform Mapping

iOS/tvOS `UList` uses `UITableView`; macOS `UList` uses `NSScrollView` plus
view-based `NSTableView`. The macOS implementation uses one headerless,
`.plain`-styled column and native automatic row sizing. `.plain` intentionally
supplies no hidden full-width row padding; callers own visual content insets.
The public high-level intent remains `UList`, while native implementation
details remain platform-explicit. [PA4][PA5][VC5]

### PA5: Native Wrapper First, UIKitUltra Conventions Second

Existing UIKitUltra engineering approaches are authoritative. Before adding a
new class or behavior, inspect comparable UIKitUltra implementations and reuse
their fluent API shape, composition model, state/listener ownership, platform
split, naming, lifecycle, and documentation conventions.

Every new feature is delivered in at least two explicit stages:

1. **Native declarative wrapper** — expose the relevant UIKit/AppKit or
   backend-native type, property, delegate, data-source, constraint, or
   lifecycle capability through a simple declarative UIKitUltra surface with
   native semantics intact. Direct/native-style wrapper capability remains
   first-class.
2. **UIKitUltra convenience layer** — add ergonomic state bindings, fluent
   modifiers, builders, mappings, callbacks, composition helpers, or other
   conveniences only by following the established patterns already used by
   analogous UIKitUltra classes. Fluent/declarative/reactive convenience is
   additive, not mandatory-only.

The second stage extends the native wrapper; it must not replace native behavior
with a parallel runtime. Supported wrapper users must not be forced into
convenience-only DSL. Public direct initializers and property-style access should
remain available where safe and consistent with native ownership.

The backend escape-hatch API shape is now architecture-accepted, though not broadly implemented yet. Explicit backend modules add top-level backend wrapper types and the corresponding rare direct escape on the same authoritative object path:

```text
.gtk { ... }
.qt { ... }
.win { ... }
.android { ... }
.tui { ... }
```

Normal `import Ultra` must remain a clean universal DSL; explicit backend imports are opt-in. [NB4][NB15]

A new engineering approach, coordination model, lifecycle mechanism, or
abstraction pattern is not an implementation detail an agent may invent. It
requires a written design proposal and explicit approval from the UIKitUltra
author before source mutation.

Edge cases must not be hidden inside compensating heuristics or private hacks.
When callers need control beyond the default native mapping, UIKitUltra should
provide a clean, optional, composable public declarative API through which the
caller explicitly selects or configures that behavior. The default path remains
simple, native, and predictable.

### PA6: Foreign Backends Follow `NB*` Architecture

GTK/libadwaita, Qt/KF6, Win over WinUI 3, Android Views/Material, and TUI are governed by `NATIVE_BACKENDS.md`.

GUI backends preserve one authoritative host-native object path. TUI uses the UIKitUltra-owned retained terminal hierarchy because no host-native widget hierarchy exists. Common `U*` types may inherit backend-owned Swift wrappers, but backend-specific convenience surface belongs to explicit backend modules so ordinary `import Ultra` remains clean. [NB1][NB2][NB4][NB13][NB15][NB18]

Current production GTK architecture uses the external `UltraGTK` native
foundation below `Ultra`, with one authoritative GTK object/runtime path and
no `UltraGTK -> Ultra` reverse dependency. The former root-owned
`UltraGTKRuntime` / `UltraGTKCore` split is historical only. Broad
Qt/Win/Android/TUI production implementation remains future/parallel-lane work
and support claims remain gated by NB12.

## Forbidden Patterns

- Calling UIKit-only APIs from shared code without guards.
- Calling AppKit-only APIs from shared code without guards.
- Hiding platform-specific behavior under shared names without documentation.
- Designing a new internal approach before inspecting and exhausting analogous
  UIKitUltra patterns already present in the repository.
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
  UIKitUltra author.
- Forcing supported wrapper capabilities into convenience-only DSL when
  direct/native-style wrapper access remains first-class.
- Promising raw GTK/Qt/WinUI types in common cross-platform API signatures.
- Treating the exact native escape-hatch public API shape as already frozen or
  implemented.

## Integration Rules

- Before designing a new API, identify and document the analogous UIKitUltra
  classes and the established conventions being reused.
- New functionality must plan and review the native declarative wrapper stage
  separately from the UIKitUltra convenience stage.
- New shared abstractions must declare platform mappings.
- New platform-only APIs must document non-availability on other targets.
- Wrapper implementations must first express behavior through native UIKit or
  AppKit APIs, hierarchy, constraints, delegates, data sources, and lifecycle.
- UIKitUltra conveniences must be composed from established library mechanisms
  and remain layered on top of the native wrapper.
- A genuinely new engineering approach requires a written proposal, explicit
  alternatives, compatibility impact, and approval from the UIKitUltra author
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
