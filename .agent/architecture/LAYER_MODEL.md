# Layer Model

## Metadata
- Layer: Cross-Layer
- Depends On Layers: DSL, Runtime, Platform
- Primary Runtime Artifacts: `DeclarativeProtocol`, `State`, `InnerState`, `PreConstraint`, `ForEach`, `BaseView` aliases

## Purpose

Define the authoritative 3-layer architecture used to reason about UIKitPlus changes:
1. DSL Layer
2. Runtime Layer
3. Platform Layer

This model prevents architectural drift and forces explicit cross-layer impact analysis.

## Invariants

### LC1: Layer Roles Are Stable

- DSL Layer defines fluent API surface and composition contracts.
- Runtime Layer defines state propagation, constraint application, lifecycle-timed activation, and mutation flows.
- Platform Layer defines current UIKit/AppKit conditionals and bridge aliases,
  plus physical backend ownership/selection boundaries for future native
  GTK/Qt/WinUI implementations. [NB4]

### LC2: Cross-Layer Docs Are Mandatory for Shared Contracts

The following documents are cross-layer contract authorities:
- `FLUENT_CHAIN_CONTRACT.md`
- `EXTENSION_SYSTEM.md`
- `MUTATION_MODEL.md`

### LC3: Layer-Aware Planning Is Required

Any task touching more than one layer is a cross-layer task and must include explicit risk analysis in PLAN.

## Layer Membership

### DSL Layer

Primary artifacts:
- `DeclarativeProtocol`
- protocol-based fluent APIs in `Sources/Kit/Protocols/*`
- extension surface in `Sources/Kit/Extensions/DeclarativeProtocol+*.swift`
- result builders (`BodyBuilder`, `GesturesBuilder`)

### Runtime Layer

Primary artifacts:
- `State`, `InnerState`, mapped and merged states
- `Properties`, `PropertiesInternal`
- `PreConstraint` and activation flows
- `movedToSuperview` deferred activation
- `ForEach` diff/subscription update path
- gesture tracker/delegator callback pipelines

M1 physically moves the proven portable State nucleus into the SwiftPM `UIKitPlusCore`
target. That target is an implementation/package boundary inside the existing
Runtime Layer; it does not create a fourth conceptual architecture layer.
[NB4]

### Platform Layer

Primary artifacts:
- conditional aliases and wrappers (`BaseView`, `UColor`, `UFont`, `UGestureRecognizer`, `_STV`)
- UIKit/AppKit split implementations
- platform-specific navigation/controller wrappers
- internal backend target boundaries `UIKitPlusGTK`, `UIKitPlusQt`, and
  `UIKitPlusWinUI`, which remain behavior-empty in M1
- compile-time backend selection/facade routing in
  `Sources/Kit/Exports/BackendSelection.swift`

The existing Apple wrappers remain current production platform artifacts.
Future non-Apple controls remain governed by `NATIVE_BACKENDS.md` and must not
be inferred from the mere existence of package targets. [NB2][NB4][NB12]

## Dependency Direction

### Allowed Dependency Flow

- DSL -> Runtime: fluent APIs can bind to runtime contracts (`State`, `PreConstraint`, `ForEach`).
- DSL -> Platform: DSL uses shared platform aliases (`BaseView`, `UColor`, etc.) and explicit platform guards.
- Runtime -> Platform: runtime activation/lifecycle code can call platform APIs through conditional compilation and aliases.

### Forbidden Dependency Flow

- Platform -> DSL: platform bridge files must not depend on DSL extension policy or chain semantics.
- Runtime reinterpretation from DSL-only changes without contract updates.

## Change Classification

### Local-Layer Change

A change is local when behavior and contracts stay inside one layer and do not alter cross-layer expectations.

### Cross-Layer Change

A change is cross-layer when it modifies:
- fluent API behavior that alters runtime propagation,
- runtime behavior that changes platform exposure requirements,
- platform abstraction boundaries that alter DSL/runtime call surfaces.

## Forbidden Patterns

- Treating UIKitPlus as SwiftUI-style value-semantic builder architecture.
- Introducing undocumented cross-layer behavior.
- Changing runtime-layer semantics from DSL-layer API changes without contract updates.
- Embedding platform-specific behavior in shared DSL methods without explicit conditional guards.

## Integration Rules

- DSL changes that alter state/listener behavior must reference Runtime contracts.
- Runtime changes that alter fluent behavior must reference Fluent Chain contract.
- Platform changes must document affected DSL/Runtime APIs and conditional exposure.

## Audit Implications

Every patch must answer:
- Which layer(s) changed?
- Is this local-layer or cross-layer?
- Which cross-layer contract docs were validated?
