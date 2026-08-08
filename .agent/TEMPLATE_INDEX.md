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
  - Use as the primary template for `State`/`InnerState` bindings and ST8
    setter classification; consult the fluent-extension template only when
    extension-specific collision analysis is required.

## Required Contract Checks Before Using Any Template

1. `LAYER_MODEL.md` for layer impact.
2. One task-specific domain doc.
3. One task-specific contract doc.
4. Any additional architecture doc only through documented context-budget
   escalation.
