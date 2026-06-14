# State Binding Skill

## Purpose

Use this skill for changes to `State`, `InnerState`, mapped states, merge behavior, and DSL methods that bind UI/runtime behavior to state.

## Minimum Context

1. `.agent/architecture/LAYER_MODEL.md`
2. `.agent/architecture/STATE_SYSTEM.md`
3. `.agent/architecture/MUTATION_MODEL.md`
4. `.agent/architecture/RUNTIME_MODEL.md`
5. `.agent/architecture/FLUENT_CHAIN_CONTRACT.md`

## Plan Checklist

- Classify binding direction: one-way derivation vs two-way synchronization.
- Identify recursion guards (`backwardChanged`, merge guard flags) impact.
- Identify listener lifecycle and repeat-call accumulation risk.
- Identify runtime points where listeners are attached.

## Implementation Rules

- Preserve `State` mutation order (`old -> assign -> begin -> listeners -> end`).
- Do not claim listener registration is idempotent unless dedup logic exists.
- Keep synchronization boundaries explicit: derivation (`map`) vs synchronization (`merge`, two-way map).
- For `InnerState`, preserve write-through parent semantics and projected propagation.

## Audit Checklist

1. State propagation ordering assumptions are valid.
2. Recursion protection remains correct for two-way bindings.
3. Repeated setup does not silently multiply listeners without documentation.
4. Contract docs updated for any binding semantics change.
