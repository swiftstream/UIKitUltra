# Constraint System Skill

## Purpose

Use this skill for constraint DSL and activation flow changes, including `PreConstraint`, solo/super/relative APIs, state-backed constraint constants, and tag-based relative resolution.

## Minimum Context

1. `.agent/architecture/LAYER_MODEL.md`
2. `.agent/architecture/LAYOUT_SYSTEM.md`
3. `.agent/architecture/RUNTIME_MODEL.md`
4. `.agent/architecture/STATE_SYSTEM.md`
5. `.agent/architecture/MUTATION_MODEL.md`
6. `.agent/architecture/FLUENT_CHAIN_CONTRACT.md`

## Plan Checklist

- Identify whether changes target solo, super, relative, or mixed constraint channels.
- Validate deferred activation impact (`movedToSuperview`).
- Validate tag-resolution and notification retry impact (`AddedViewWithTag`).
- Validate state-link impact (`linkStates`, `merge(with:)`).

## Implementation Rules

- Keep pre-constraint queue ownership explicit (`notApplied*` / `applied*`).
- Do not bypass activation helpers when deferred behavior is required.
- Document duplicate constraint replacement/deactivation semantics.
- For state-backed constants, preserve explicit listener behavior.

## Audit Checklist

1. No hidden constraint duplication or unresolved deactivation paths.
2. Relative/tag constraints preserve retry and eventual activation behavior.
3. Constraint-state propagation remains aligned with `STATE_SYSTEM.md`.
4. Runtime consistency maintained between immediate and deferred activation paths.
