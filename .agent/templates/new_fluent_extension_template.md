# Template: New Fluent Extension

Use this template for `DeclarativeProtocol+Feature.swift` additions.

## Pre-Checks

1. `FLUENT_CHAIN_CONTRACT.md`
2. `EXTENSION_SYSTEM.md`
3. domain architecture doc (for example `LAYOUT_SYSTEM.md` or `GESTURE_SYSTEM.md`)
4. `MUTATION_MODEL.md` if mutation/listener behavior is introduced

## Extension Stub

- Feature domain:
- File path pattern: `DeclarativeProtocol+Feature.swift`
- Method signatures:
- Return contract: `Self`
- Side effects:
- Repeat-call behavior:
- Platform guards:

## Safety Requirements

- In-place mutation only; no copy-return chain semantics.
- Explicit side-effect declaration (state listener, observer, recognizer, constraint, etc.).
- Overload collision scan completed.
- Platform-conditional exclusivity validated.

## Audit Notes

- Chain contract validated.
- Extension precedence/collision reviewed.
- Related architecture docs updated.
