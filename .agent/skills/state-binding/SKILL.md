---
name: state-binding
description: Change or review UIKitPlus State/InnerState internals and built-in State-backed fluent APIs inside the UIKitPlus source repository. Use for mapped/merged state, listener ownership, ST8 setter classification, FC11/FC12 API contracts, and synchronization behavior; not for ordinary downstream State usage.
---

# Maintain UIKitPlus State Binding

Use this LOCAL contributor skill for changes to `State`, `InnerState`, mapped/merged state behavior, and built-in fluent setters that bind UIKitPlus UI/runtime properties to State.

## Load the smallest decision-complete context

1. Start from UIKitPlus `AGENTS.md` and [`SKILL_INDEX.md`](../../SKILL_INDEX.md).
2. Use [`STATE_SYSTEM.md`](../../architecture/STATE_SYSTEM.md) as the primary owner.
3. Load [`FLUENT_CHAIN_CONTRACT.md`](../../architecture/FLUENT_CHAIN_CONTRACT.md) when a public fluent setter is added or materially changed.
4. Add [`MUTATION_MODEL.md`](../../architecture/MUTATION_MODEL.md) only for bidirectional/re-entrant/multi-state mutation.
5. Add [`RUNTIME_MODEL.md`](../../architecture/RUNTIME_MODEL.md) only for lifecycle/deferred ownership.
6. Use [`SOURCE_MAP.md`](../../SOURCE_MAP.md) before broad source discovery.

Record any architecture-budget escalation rather than bulk-loading mutation/runtime contracts by default.

## Plan checklist

- Record ST8 classification for every new/materially changed fluent value setter: bindable or reviewed non-bindable rationale.
- Declare direction, initial assignment policy, listener ownership, repeated-call behavior, and teardown.
- Record any FC11 generic exception and plan FC12 declaration-adjacent DocC for public overloads.
- For two-way synchronization, identify recursion guards and mutation ordering before implementation.

## Implementation rules

- Preserve State mutation order: old value -> assign -> begin -> listeners -> end.
- Implement fluent setters exactly as classified under ST8 and the current fluent contract.
- Do not claim listener registration is idempotent unless explicit deduplication exists.
- Keep derivation (`map`) distinct from synchronization (`merge`, two-way mapping).
- Preserve `InnerState` write-through parent semantics and projected propagation.
- Keep listener/token ownership explicit and teardown-safe.

## Audit

Verify:

- State propagation ordering assumptions are correct;
- ST8 classification, initial application, listener ownership, repeat behavior, and teardown match implementation;
- FC11 discoverability and FC12 per-overload DocC are satisfied where applicable;
- recursion protection is sound for two-way synchronization;
- fluent `Self`/reference semantics remain intact;
- architecture docs are changed only when the actual binding contract changed;
- unrelated source/governance remains untouched.

Stop and re-plan if the work requires a new State ownership/lifecycle model rather than an implementation inside current State architecture.