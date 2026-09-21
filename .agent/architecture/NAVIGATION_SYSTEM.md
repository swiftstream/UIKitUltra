# Navigation System

## Metadata
- Layer: Runtime
- Depends On Layers: DSL, Platform
- Primary Runtime Artifacts: `NavigationController` (iOS/macOS variants), `NavigationControllerable`, navigation transition extensions

## Purpose

Define UIKitUltra navigation wrappers and their platform-specific behaviors.

## Invariants

### NV1: Navigation Is Platform-Conditional

Navigation implementations diverge across iOS and macOS and must remain explicitly separated.

### NV2: Chainable Configuration API

Navigation configuration methods (`style`, `tint`, `enableSwipeBack`, etc.) remain chainable and mutate current controller instance.

### NV3: Gesture-Based Swipe Back Contract

On iOS, swipe-back behavior is controlled through recognizer delegate gating (`viewControllers.count > 1 && isSwipeBackEnabled`).

### NV4: Transition Helpers Are Explicit

Custom push/pop transitions are explicit extension methods and should not alter core navigation semantics implicitly.

## Forbidden Patterns

- Assuming a shared runtime implementation for iOS and macOS navigation behavior.
- Introducing hidden global navigation state.
- Breaking chainable configuration conventions.

## Integration Rules

- New navigation APIs must declare platform availability.
- Behavioral changes must include compatibility notes for both platform variants.
- Transition helper changes must preserve explicit opt-in behavior.

## Audit Implications

Navigation patches must verify:
- platform-specific behavior consistency,
- chain contract compliance,
- no hidden lifecycle regressions in controller setup.
