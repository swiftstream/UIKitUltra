# Template: New Fluent Extension

Use this template for `DeclarativeProtocol+Feature.swift` additions.

## Pre-Checks

Use `FLUENT_CHAIN_CONTRACT.md` as the primary owner.

Add only what the feature needs:

- `EXTENSION_SYSTEM.md` for extension placement/collision behavior;
- `STATE_SYSTEM.md` plus `.agent/skills/state-binding/SKILL.md` for a bindable value setter;
- `LAYER_MODEL.md` only if the change genuinely crosses/changes layer boundaries.

Load any additional domain/mutation owner only through normal context-budget escalation.

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
