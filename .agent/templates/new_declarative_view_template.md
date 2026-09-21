# Template: New Declarative View

Use this template before implementing a new DSL view type.

## Pre-Checks

Use `DECLARATIVE_PROTOCOL.md` as the primary owner. Add only the support actually needed:

- `PLATFORM_ABSTRACTION.md` for platform/native exposure;
- `RUNTIME_MODEL.md` for lifecycle hooks;
- `FLUENT_CHAIN_CONTRACT.md` when the new type also introduces/materially changes fluent API;
- `LAYER_MODEL.md` only when the layer boundary itself is unclear or changing.

Stay within the normal three-architecture-doc budget unless the task genuinely requires documented escalation.

## Design Stub

- View type name:
- Base class (`BaseView` alias target):
- Platform scope:
- DSL ownership file(s):
- Runtime hooks used (`_setup`, `movedToSuperview`, trait hooks):

## Contract Checklist

- Provides `declarativeView` identity contract.
- Provides `properties` storage.
- Supports required internal bridge (`DeclarativeProtocolInternal`) if constraints/state links are needed.
- Does not introduce value-copy behavior.
- Documents listener/observer wiring points.

## Audit Notes

- Chain behavior preserved.
- Runtime behavior explicit.
- Platform boundaries documented.
