# View Composition Skill

## Purpose

Use this skill for changes to `BodyBuilder`, `BodyBuilderItem`, `View+Body`, `View+Add`, `ForEach`, stack composition, and insertion/removal behavior.

## Minimum Context

1. `.agent/architecture/LAYER_MODEL.md`
2. `.agent/architecture/VIEW_COMPOSITION.md`
3. `.agent/architecture/RUNTIME_MODEL.md`
4. `.agent/architecture/MUTATION_MODEL.md`
5. `.agent/architecture/FLUENT_CHAIN_CONTRACT.md`

## Plan Checklist

- Identify affected composition entry points (`body`, `addItem`, `add(views:at:)`, stack add path).
- Classify layer impact (`DSL`, `Runtime`, `Cross-Layer`).
- Check whether `ForEach` subscriptions or diff handling change.
- Check for listener accumulation risk on repeated setup.

## Implementation Rules

- Preserve object identity; do not introduce value-view copy semantics.
- Keep insertion ordering behavior explicit and documented.
- If changing `ForEach` subscriptions, document begin/listener/end trigger flow.
- Treat diff `modifications` handling as explicit policy; do not imply unsupported behavior.

## Audit Checklist

1. Chain continuity preserved for composition-facing fluent methods.
2. `ForEach` updates remain safe for insertions/deletions (and modifications if implemented).
3. No hidden lifecycle regressions in view/stack insertion flows.
4. Runtime model docs updated if update timing changes.
