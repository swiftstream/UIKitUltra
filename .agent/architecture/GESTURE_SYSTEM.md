# Gesture System

## Metadata
- Layer: Runtime
- Depends On Layers: DSL, Platform
- Primary Runtime Artifacts: gesture wrapper objects, `GestureTrackable`, `GestureRecognizerable`, `_GestureTracker`, `_GestureDelegator`

## Purpose

Define how UIKitPlus gesture APIs expose fluent wrappers, state tracking, and delegate composition without breaking chain semantics.

## Invariants

### GS1: Gesture APIs Are Chainable

Gesture setup methods return `Self` to remain fluent with other DSL modifiers.

### GS2: State Tracking Is Explicit

`trackState` and state-binding gesture methods explicitly bridge recognizer state into closures or `State` objects.

### GS3: Delegate Composition Uses Explicit Delegator

Delegate behavior is routed through `_GestureDelegator`, which can forward to outer delegate when local handlers are absent.

### GS4: Platform Conditionals Are Required

Gesture API availability and behavior differences are controlled by platform conditionals (`os(macOS)`, `tvOS`, etc.).

## Forbidden Patterns

- Hidden recognizer creation without documented attachment behavior.
- Overriding delegate behavior in a way that silently blocks outer delegate fallback.
- Cross-platform gesture API unification that ignores platform capability differences.

## Integration Rules

- New gesture wrappers must provide explicit state and delegate behavior contracts.
- New gesture extension overloads must avoid ambiguity with existing variants.
- If gestures bind to `State`, repeat-call listener behavior must be documented.

## Audit Implications

Gesture patches must verify:
- chain continuity,
- delegate fallback correctness,
- state propagation correctness,
- platform-conditional integrity.
