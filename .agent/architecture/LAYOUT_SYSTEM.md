# Layout System

## Metadata
- Layer: Runtime
- Depends On Layers: DSL, Platform
- Primary Runtime Artifacts: `PreConstraint`, `PropertiesInternal` pre-constraint arrays, `activateSolo`, `activateSuper`, `activateRelative`, `movedToSuperview`, `linkStates`

## Purpose

Define the current Apple UIKitUltra constraint DSL runtime: pre-constraint
storage, deferred activation, relative/tag resolution, and state-backed
constant propagation over UIKit/AppKit Auto Layout, plus the durable future/research direction for UIKitUltra cross-backend semantic layout intent across Apple, GTK, Qt, Win, Android, and TUI.

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

`PreConstraint`, `NSLayoutConstraint`, deferred activation, and the existing constraint-state graph remain the Apple UIKit/AppKit layout runtime. They are not generalized into a cross-toolkit solver.

Unified UIKitUltra layout must map honest shared intent onto each backend's real mechanism while preserving current Apple semantics unchanged: GTK/Qt/Win native layout primitives, Android parent-owned `LayoutParams`/ViewGroup mechanisms, and UIKitUltra-owned TUI cell layout. [NB9][NB13]

### LY7: Cross-Backend Shared Semantic Intent, Not Shared GUI Solver (ACTIVE RESEARCH DIRECTION)

Cross-backend layout parity should represent portable UIKitUltra layout intent/constraint semantics and lower each intent to the honest backend mechanism. It must not reuse Apple `NSLayoutConstraint` as a hidden universal engine and must not introduce a UIKitUltra-owned cross-toolkit GUI solver without a new explicit architecture decision. [NB9]

TUI is intentionally different: UIKitUltra owns TUI cell layout because the terminal provides no native widget/layout engine. This does not authorize reusing that TUI layout engine for GUI backends. [NB18]

This remains research direction, not an implemented Unified Layout IR or broad cross-backend constraint implementation.

### LY8: Exact-Native Lowering First (FUTURE/RESEARCH)

When a semantic maps exactly to a simple native property/container primitive,
use that mechanism. The accepted example is E1.1 GTK parameterless
`centerInSuperview()`: same GtkBox with native `halign=center` and
`valign=center`. That narrow slice is not evidence that broad Apple Auto Layout
parity already exists and must not be overstated into a general GtkConstraintLayout
or portable constraint IR claim. [NB9]

### LY9: Deferred Declaration Before Parent Remains Required (FUTURE/RESEARCH)

The future shared semantic layer must preserve declaration-before-parent as a
first-class capability: layout intent can be created while no parent exists,
remain stored semantically, and materialize through backend-native behavior when
a compatible parent appears. This requirement comes from existing Apple
UIKitUltra pre-constraint behavior (LY2) and must not be dropped when designing
shared layout semantics.

### LY10: Automatic Detach/Reparent Persistence Is Not Frozen (OPEN/RESEARCH)

Do not claim automatic detach/reparent persistence. Current Apple behavior is
not established as automatically surviving `parent A -> detach -> parent B`.
Before universal reparent semantics are frozen, execute an Apple executable
compatibility probe for:

```text
configure before parent
attach parent A
remove from A
attach parent B
observe automatic survival/reactivation vs explicit deapplyAllConstraints requirement
```

`deapplyAllConstraints()` exists, but automatic removal-time invocation is not
established. Any deliberate improvement beyond current Apple behavior requires
explicit compatibility review and must not silently change Apple semantics.

### LY11: Broad Backend Layout Expansion Ordering

D01 live acceptance and the complete public convenience census (E0) are accepted. The next shared layout gate is `NATIVE-ULAYOUT-001` Unified Layout Constraint Architecture research.

Broad GTK/Qt/Win/Android/TUI layout convenience expansion waits for that shared architecture result. After it is accepted, backend implementation may proceed in isolated parallel lanes under `PARALLEL_DEVELOPMENT.md` rather than a single serial backend sequence.

Narrow already-accepted E1.1 GTK center equivalence is historical evidence and is not blocked retroactively by open reparent research.

### LY12: Android and TUI Are Mandatory Unified-Layout Inputs

`NATIVE-ULAYOUT-001` must treat Android and TUI as first-class evidence, not future add-ons.

Android requirements include:

- parent-owned `LayoutParams` semantics;
- generic `UView` must remain a true child-containing container;
- `FrameLayout` vs custom `ViewGroup` vs ConstraintLayout-informed ownership must be decided by semantic fit rather than naming symmetry;
- declaration-before-parent/deferred intent must lower correctly once the eventual parent/container is known.

TUI requirements include:

- cell/EGC-based dimensions rather than pixels;
- intrinsic/min/natural sizing;
- stack/grid/flex-like placement;
- terminal resize;
- clipping and scroll viewports;
- focus/pointer hit-test geometry;
- capability-aware images whose layout still has deterministic cell bounds.

A common semantic layout contract must support these requirements without forcing GUI backends through a TUI layout solver or forcing TUI through Apple constraints.

## Forbidden Patterns

- Treating layout activation as immediate-only.
- Introducing hidden duplicate constraints without explicit replacement/deactivation handling.
- Bypassing pre-constraint lifecycle for features intended to support deferred activation.
- Silent cross-hierarchy tag search semantics changes.
- Reusing the Apple `PreConstraint` / `NSLayoutConstraint` engine as a hidden
  universal GTK/Qt/WinUI layout solver. [NB9]
- Claiming automatic detach/reparent persistence, portable constraint IR
  implementation, general GtkConstraintLayout implementation, or a custom
  universal layout solver as current architecture. [LY7][LY8][LY10]

## Integration Rules

- New layout DSL methods must declare whether behavior is solo/super/relative.
- New relative APIs must define unresolved-target behavior.
- State-backed layout APIs must explicitly document listener and lifecycle impact.
- Future shared layout APIs must lower platform-neutral semantic intent to real
  native toolkit mechanisms and must not pre-authorize a cross-toolkit solver.
- Broad E1 parity work requires D01, E0 census, and Unified Layout research first.

## Audit Implications

Layout patches must validate:
- deferred activation correctness,
- duplicate constraint replacement behavior,
- tag-based relative resolution consistency,
- state-constant propagation safety.
- that reparent/universal-constraint claims remain research-scoped until the
  Apple parent A -> detach -> parent B probe exists.
