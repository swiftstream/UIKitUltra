# Template: New Declarative View

Use this template before implementing a new DSL view type.

## Pre-Checks

1. Confirm layer impact in `LAYER_MODEL.md`.
2. Confirm root contract requirements in `DECLARATIVE_PROTOCOL.md`.
3. Confirm chain safety in `FLUENT_CHAIN_CONTRACT.md`.
4. Confirm runtime lifecycle obligations in `RUNTIME_MODEL.md`.
5. Confirm platform exposure in `PLATFORM_ABSTRACTION.md`.

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
