# State Binding Skill

## Purpose

Use this skill for changes to `State`, `InnerState`, mapped states, merge
behavior, DSL methods that bind UI/runtime behavior to state, and every new or
materially changed fluent value setter that must be classified under ST8.

## Minimum Context

1. `.agent/architecture/LAYER_MODEL.md`
2. `.agent/architecture/STATE_SYSTEM.md`
3. `.agent/architecture/FLUENT_CHAIN_CONTRACT.md`

Load `MUTATION_MODEL.md` only for bidirectional, re-entrant, or multi-state
mutation. Load `RUNTIME_MODEL.md` only for lifecycle/deferred behavior. Record
either addition as a context-budget escalation.

## Plan Checklist

- Record the ST8 classification and overload pair or non-bindable rationale.
- Declare direction, assignment policy, listener ownership, repeat behavior,
  and teardown.
- Record any FC11 generic exception and plan FC12 DocC per public overload.
- For two-way synchronization, identify recursion guards and load
  `MUTATION_MODEL.md` through escalation.

## Implementation Rules

- Preserve `State` mutation order (`old -> assign -> begin -> listeners -> end`).
- Implement fluent setters exactly as classified by ST8 and documented by
  FC11/FC12.
- Do not claim listener registration is idempotent unless dedup logic exists.
- Keep synchronization boundaries explicit: derivation (`map`) vs synchronization (`merge`, two-way map).
- For `InnerState`, preserve write-through parent semantics and projected propagation.

## Audit Checklist

1. State propagation ordering assumptions are valid.
2. ST8 classification, initial application, ownership, repeat behavior, and
   teardown are correct.
3. FC11 discoverability and FC12 per-overload DocC are satisfied.
4. Recursion protection is correct when two-way synchronization is in scope.
5. Contract docs are updated only for an actual binding semantics change.
