# Template Index

Templates are governance scaffolds. They are used to draft safe changes before touching source files.

## Templates

- New declarative view:
  - `.agent/templates/new_declarative_view_template.md`
  - Use when adding a new `BaseView`-backed DSL type.

- New fluent extension:
  - `.agent/templates/new_fluent_extension_template.md`
  - Use when adding chainable API in `DeclarativeProtocol+Feature.swift`.

- New gesture wrapper:
  - `.agent/templates/new_gesture_wrapper_template.md`
  - Use when adding recognizer wrappers or gesture delegation paths.

- New state binding integration:
  - `.agent/templates/new_state_binding_integration_template.md`
  - Use when binding UI or constraints to `State`/`InnerState`.

## Required Contract Checks Before Using Any Template

1. `LAYER_MODEL.md` for layer impact.
2. `FLUENT_CHAIN_CONTRACT.md` for chain invariants.
3. `STATE_SYSTEM.md` and `MUTATION_MODEL.md` when listeners/bindings are involved.
4. `RUNTIME_MODEL.md` when lifecycle/deferred behavior is involved.
5. `EXTENSION_SYSTEM.md` when introducing or changing extension APIs.
