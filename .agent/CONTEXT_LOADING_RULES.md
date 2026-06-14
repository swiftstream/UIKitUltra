# Context Loading Rules

Use progressive context expansion. Do not load all docs by default.

## Mandatory Entry Order

1. `AGENTS.md`
2. `.agent/ARCH_INDEX.md`
3. `.agent/architecture/LAYER_MODEL.md`

## Guardrails

1. Never bulk-load all architecture docs by default.
2. Default max active architecture docs: `3`.
3. Prefer one domain doc + one contract doc.
4. Load source files only after contract context is clear.
5. Prefer targeted symbol/file reads over repository-wide scans.
6. Keep skills scoped to task domain.

## Recommended Minimal Slice

- `LAYER_MODEL.md`
- one domain doc (`STATE_SYSTEM`, `LAYOUT_SYSTEM`, etc.)
- one contract doc (`FLUENT_CHAIN_CONTRACT`, `EXTENSION_SYSTEM`, `RUNTIME_MODEL`, `MUTATION_MODEL`)

## Source Navigation Rule

For tasks touching source files, read `.agent/SOURCE_MAP.md` after architecture routing. Use the source map to identify likely source owners before broad grep or broad file reads. Update `.agent/SOURCE_MAP.md` when source topology or ownership changes.

## Escalation Rule

Exceed the 3-doc budget only when:
- task is clearly cross-layer,
- one contract is insufficient to remove ambiguity,
- additional docs are required for safety.

When escalating, document why.
