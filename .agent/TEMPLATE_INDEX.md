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

## Context Rule Before Using a Template

Template use does not reset architecture routing.

1. Keep the primary owner already selected through `ARCH_INDEX.md`.
2. Add only the supporting contract(s) the concrete template/task needs, staying within the normal three-architecture-doc budget.
3. Load `LAYER_MODEL.md` only when the layer boundary itself is unclear or changing.
4. Escalate beyond the default budget only when genuinely necessary and documented.
