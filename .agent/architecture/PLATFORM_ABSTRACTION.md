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

## Forbidden Patterns

- Calling UIKit-only APIs from shared code without guards.
- Calling AppKit-only APIs from shared code without guards.
- Hiding platform-specific behavior under shared names without documentation.

## Integration Rules

- New shared abstractions must declare platform mappings.
- New platform-only APIs must document non-availability on other targets.
- Contract docs must be updated when abstraction boundaries move.

## Audit Implications

Platform patches must verify:
- conditional completeness,
- no leakage across platform boundaries,
- stable shared alias behavior for existing DSL/runtime code.
