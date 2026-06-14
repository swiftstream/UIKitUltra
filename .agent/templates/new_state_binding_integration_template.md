# Template: New State Binding Integration

Use this template for APIs that bind runtime or DSL behavior to `State` or `InnerState`.

## Pre-Checks

1. `STATE_SYSTEM.md`
2. `MUTATION_MODEL.md`
3. `FLUENT_CHAIN_CONTRACT.md`
4. relevant domain doc (`LAYOUT_SYSTEM.md`, `VIEW_COMPOSITION.md`, etc.)
5. `RUNTIME_MODEL.md`

## Binding Stub

- Binding target:
- Source state type:
- Direction: one-way / two-way
- Listener attachment location:
- Recursion guard strategy:
- Repeat-call strategy:

## Safety Requirements

- Preserve mutation ordering assumptions.
- Distinguish derivation (`map`) from synchronization (`merge`, two-way map).
- Explicitly document if repeated calls add listeners.
- For `InnerState`, preserve write-through parent behavior.

## Audit Notes

- Propagation correctness validated.
- Recursion protection validated.
- Runtime/lifecycle assumptions documented.
