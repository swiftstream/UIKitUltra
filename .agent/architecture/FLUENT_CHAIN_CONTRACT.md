# Fluent Chain Contract

## Metadata
- Layer: Cross-Layer
- Depends On Layers: DSL, Runtime, Platform
- Primary Runtime Artifacts: `Self`-returning protocol extensions, reference-semantic objects, chainable setter/binding methods

## Purpose

Define the non-negotiable contract for UIKitPlus fluent APIs.

## Invariants

### FC1: Return Type Invariant

Chainable methods must return `Self`.

### FC2: Mutation Model Invariant

UIKitPlus fluent APIs mutate existing reference objects in place. They do not create immutable copies.

### FC3: Reference-Semantic Identity

A chain expression operates on the same underlying instance (`declarativeView` identity remains stable).

### FC4: Guarded Fallback Pattern

Protocol-extension implementations may use guarded internal casts (`guard let s = self as? _Protocol else { return self }`) and must still preserve chain continuity.

### FC5: Side-Effect Boundary Clarity

Chain methods must make side effects explicit:
- value assignment,
- listener registration,
- observer registration,
- recognizer/constraint attachment.

## Idempotency Policy

### FC6: Value Setter Expectation

Setters for scalar/object values should be idempotent for repeated same-value calls where feasible.

### FC7: Listener/Binding Attachment Is Not Inherently Idempotent

Methods that attach listeners or observers are additive by default unless explicit dedup logic is implemented.

### FC8: Repeat-Call Handling Must Be Declared

If repeat calls are unsafe or additive, the method contract must state this behavior.

## Method Classification

### FC9: Pure Setters

Pure setters overwrite current state/property values and are expected to be idempotent for repeated same-input calls where feasible.

### FC10: Wiring Methods

Wiring methods attach listeners, observers, bindings, gesture callbacks, or notification side effects.

Wiring behavior must be one of:
- guarded against duplicate attachment,
- deduplicated explicitly,
- intentionally additive with explicit ownership/lifecycle,
- explicitly documented as unsafe for repeated invocation.

## Forbidden Patterns

- Returning new instances from chain setters without explicit new-type API contract.
- Silent object replacement inside fluent chain methods.
- Undocumented additive listener behavior in frequently repeated chains.
- Claiming SwiftUI value-view semantics for UIKitPlus chain APIs.

## Anti-Pattern Examples

- Repeated `onTapGesture`/binding-style chain calls that install new callbacks on each invocation without guard/dedup.
- Hidden listener setup inside methods named as pure value setters.
- Re-entered fluent configuration paths that silently accumulate listeners/observers.
- Additive side effects that are real but undocumented in method contract text.

## Integration Rules

- New chain methods must declare: mutation type, side effects, repeat-call behavior.
- Binding methods must document synchronization direction (one-way vs two-way).
- Chain methods crossing into runtime lifecycle behavior must reference `RUNTIME_MODEL.md`.
- Wiring methods must declare ownership and teardown strategy when installation may repeat.

## Audit Implications

Any chain API patch must pass this checklist:
1. `Self` return preserved.
2. In-place mutation model preserved.
3. Side effects declared.
4. Idempotency policy identified.
5. Repeat-call listener behavior validated.
6. Wiring method duplicate-registration strategy validated.
