# Layout System

## Metadata
- Layer: Runtime
- Depends On Layers: DSL, Platform
- Primary Runtime Artifacts: `PreConstraint`, `PropertiesInternal` pre-constraint arrays, `activateSolo`, `activateSuper`, `activateRelative`, `movedToSuperview`, `linkStates`

## Purpose

Define the current Apple UIKitPlus constraint DSL runtime: pre-constraint
storage, deferred activation, relative/tag resolution, and state-backed
constant propagation over UIKit/AppKit Auto Layout.

## Invariants

### LY1: Pre-Constraint Classes of Ownership

Constraints are tracked in three channels:
- solo
- super
- relative

Each channel has `notApplied` and `applied` collections.

### LY2: Deferred Activation Is First-Class

If superview/context is unavailable, constraints are stored and activated later (typically from `movedToSuperview`).

### LY3: Relative Constraints Support Tag Resolution

Relative constraints can target views by tag via `PreConstraintViewable`; unresolved tags are retried through notification-based reactivation.

### LY4: Constraint Constants Can Be State-Backed

`PreConstraint.value.listen` updates actual constraint constants and triggers layout refresh on superview.

### LY5: Constraint-State Links Exist for Core Attributes

`linkStates` synchronizes internal dimension/position states with constraint value states for tracked attributes.

### LY6: Current Constraint Runtime Is Apple-Scoped

`PreConstraint`, `NSLayoutConstraint`, deferred activation, and the existing
constraint-state graph remain the Apple UIKit/AppKit layout runtime. M1 does
not generalize them into a cross-toolkit solver. Future GTK/Qt/WinUI layout
must map honest shared intent onto each toolkit's native layout/container
primitives under `NB9`, while preserving current Apple semantics unchanged.
[NB9]

## Forbidden Patterns

- Treating layout activation as immediate-only.
- Introducing hidden duplicate constraints without explicit replacement/deactivation handling.
- Bypassing pre-constraint lifecycle for features intended to support deferred activation.
- Silent cross-hierarchy tag search semantics changes.
- Reusing the Apple `PreConstraint` / `NSLayoutConstraint` engine as a hidden
  universal GTK/Qt/WinUI layout solver. [NB9]

## Integration Rules

- New layout DSL methods must declare whether behavior is solo/super/relative.
- New relative APIs must define unresolved-target behavior.
- State-backed layout APIs must explicitly document listener and lifecycle impact.

## Audit Implications

Layout patches must validate:
- deferred activation correctness,
- duplicate constraint replacement behavior,
- tag-based relative resolution consistency,
- state-constant propagation safety.
