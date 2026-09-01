---
name: view-composition
description: Change or review UIKitPlus view composition internals inside the UIKitPlus source repository. Use for BodyBuilder, BodyBuilderItem, View+Body, View+Add, ForEach, stack insertion/removal, subscriptions, and composition diff behavior; not for ordinary downstream view construction.
---

# Maintain UIKitPlus View Composition

Use this LOCAL contributor skill for built-in composition/runtime source work.

## Load the smallest decision-complete context

1. Start from UIKitPlus `AGENTS.md` and [`SKILL_INDEX.md`](../../SKILL_INDEX.md).
2. Use [`VIEW_COMPOSITION.md`](../../architecture/VIEW_COMPOSITION.md) as the primary owner.
3. Add only the supporting contract the change needs:
   - [`RUNTIME_MODEL.md`](../../architecture/RUNTIME_MODEL.md) for insertion/update lifecycle;
   - [`MUTATION_MODEL.md`](../../architecture/MUTATION_MODEL.md) for subscriptions/diff callbacks;
   - [`FLUENT_CHAIN_CONTRACT.md`](../../architecture/FLUENT_CHAIN_CONTRACT.md) for changed public composition APIs.
4. Use [`SOURCE_MAP.md`](../../SOURCE_MAP.md) before broad source discovery.

## Plan checklist

- Identify affected composition entrypoints such as `body`, `addItem`, `add(views:at:)`, stack add paths, or `ForEach`.
- Classify the impact as DSL, runtime, or cross-layer.
- Identify subscription/diff handling changes and repeated-setup listener risk.
- Preserve explicit insertion/removal ordering and object identity.

## Implementation rules

- Preserve reference/object identity; do not introduce value-view copy semantics.
- Keep insertion ordering explicit and consistent with current composition ownership.
- If changing `ForEach` subscriptions, keep begin/listener/end update flow and listener ownership explicit.
- Treat diff `modifications` handling as explicit policy; do not imply support that is not implemented.
- Do not add a second composition/runtime model to compensate for one local edge case.

## Audit

Verify:

- fluent composition-facing chain continuity remains intact;
- `ForEach` insertions/deletions and any intentionally supported modifications remain safe;
- no hidden lifecycle regression appears in view/stack insertion/removal;
- repeated setup does not silently accumulate listeners/subscriptions;
- runtime docs change only if durable update timing/ownership actually changed;
- unrelated source/governance remains untouched.

Stop and re-plan if the work requires a new composition ownership/lifecycle mechanism rather than an implementation inside current UIKitPlus architecture.