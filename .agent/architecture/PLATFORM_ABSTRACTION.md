# Platform Abstraction

## Metadata
- Layer: Platform
- Depends On Layers: Runtime
- Primary Runtime Artifacts: `BaseView`, `BaseViewController`, `UColor`, `UFont`, `UGestureRecognizer`, `_UImage`, `_STV`, conditional view/controller implementations

## Purpose

Define how UIKitPlus unifies UIKit/AppKit while preserving explicit platform-specific behavior.

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
