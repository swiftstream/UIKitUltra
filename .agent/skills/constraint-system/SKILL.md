---
name: constraint-system
description: Change or review UIKitUltra constraint DSL and activation behavior inside the UIKitUltra source repository. Use for PreConstraint, solo/super/relative constraints, deferred activation, State-backed constants, and tag-based relative resolution; not for ordinary downstream layout usage.
---

# Maintain the UIKitUltra Constraint System

Use this LOCAL contributor skill when changing UIKitUltra constraint implementation or built-in constraint DSL behavior.

## Load the smallest decision-complete context

1. Assume root/architecture/skill routing already selected this skill and `LAYOUT_SYSTEM.md`; do not re-read `AGENTS.md`/`SKILL_INDEX.md` unless that context is genuinely missing or stale.
2. Use [`LAYOUT_SYSTEM.md`](../../architecture/LAYOUT_SYSTEM.md) as the primary architecture owner.
3. Add only the supporting contract needed by the change:
   - [`RUNTIME_MODEL.md`](../../architecture/RUNTIME_MODEL.md) for deferred activation/lifecycle;
   - [`STATE_SYSTEM.md`](../../architecture/STATE_SYSTEM.md) for State-backed constants;
   - [`MUTATION_MODEL.md`](../../architecture/MUTATION_MODEL.md) for re-entrant/update flows;
   - [`FLUENT_CHAIN_CONTRACT.md`](../../architecture/FLUENT_CHAIN_CONTRACT.md) for public fluent API changes.
4. Use [`SOURCE_MAP.md`](../../SOURCE_MAP.md) only if the affected source location/ownership is not already known.

Do not bulk-load every supporting owner merely because constraints can touch them.

## Plan checklist

- Classify the affected channel: solo, super, relative, or mixed.
- Identify the current activation owner and whether `movedToSuperview`/deferred activation is involved.
- Check relative/tag resolution and `AddedViewWithTag` retry behavior when applicable.
- Check State listener/link ownership when constants are reactive.
- Record public fluent/State-surface effects before mutation.

## Implementation rules

- Keep pre-constraint queue ownership explicit (`notApplied*` / `applied*`).
- Preserve existing activation helpers when deferred behavior is required.
- Keep replacement/deactivation semantics explicit; do not leave duplicate active constraints hidden behind convenience APIs.
- Preserve explicit listener ownership for State-backed constants.
- Do not introduce a second layout/activation engine to compensate for a local edge case.

## Audit

Verify the final source/diff against the selected architecture owners and prove:

- no hidden constraint duplication or orphaned deactivation path;
- relative/tag constraints retain retry and eventual activation behavior;
- immediate and deferred activation remain consistent;
- State propagation follows the current State contract when in scope;
- fluent `Self` semantics remain intact for changed public APIs;
- unrelated source and governance are untouched.

Stop and re-plan if the change requires a new layout lifecycle/ownership mechanism rather than an implementation inside the existing constraint architecture.