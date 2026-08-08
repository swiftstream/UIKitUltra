# Template: New Fluent Extension

Use this template for `DeclarativeProtocol+Feature.swift` additions.

## Pre-Checks

1. `LAYER_MODEL.md`
2. `FLUENT_CHAIN_CONTRACT.md`
3. `EXTENSION_SYSTEM.md`

Load `STATE_SYSTEM.md` plus `state_binding_skill.md` for a bindable value setter
and any other domain/mutation contract only through documented context-budget
escalation.

## Extension Stub

- Feature domain:
- File path pattern: `DeclarativeProtocol+Feature.swift`
- Method signatures:
- Return contract: `Self`
- Side effects:
- Repeat-call behavior:
- Platform guards:
- ST8 classification for each value-setting method: bindable / non-bindable
- State companion signature or reviewed non-bindable rationale:
- Autocomplete surface: explicit concrete overloads / FC11 generic exception
- `///` DocC summary for every public overload:

## Safety Requirements

- In-place mutation only; no copy-return chain semantics.
- Explicit side-effect declaration (state listener, observer, recognizer, constraint, etc.).
- Value setters satisfy ST8, FC11, and FC12.
- Overload collision scan completed.
- Platform-conditional exclusivity validated.

## Audit Notes

- Chain contract validated.
- ST8/FC11/FC12 validated when a value setter is in scope.
- Extension precedence/collision reviewed.
- Related architecture docs updated.
