# Development Phases

All tasks follow `PLAN -> IMPLEMENT -> AUDIT`.

## PLAN

No file mutation in this phase.

Required outputs:
- exact files to edit,
- architecture IDs and docs in scope,
- layer impact (`DSL`, `Runtime`, `Platform`, `Cross-Layer`),
- mutation-flow impact,
- extension collision risk,
- fluent chain risk,
- state propagation risk,
- platform leakage risk,
- documentation synchronization targets,
- architecture-ID tags on each risk/decision statement (for example: `[ST12][MU04][FC02]`).

Blocking conditions:
- missing architecture contract,
- unresolved contract conflict,
- undocumented cross-layer change,
- planning output without architecture-ID grounding.

## IMPLEMENT

Rules:
- implement approved scope only,
- preserve existing architecture contracts,
- do not introduce undocumented runtime behavior,
- do not perform hidden contract changes,
- avoid broad unrelated refactors.

Required discipline:
- keep fluent `Self` chains intact,
- keep listener wiring explicit,
- keep extension behavior composable,
- keep platform conditionals isolated,
- record implementation notes with architecture-ID tags for each behavior-affecting change.

## AUDIT

Mandatory checks before closure:
1. Chain Contract Validation:
- `FLUENT_CHAIN_CONTRACT.md` compliance.

2. State Propagation Correctness:
- `STATE_SYSTEM.md` and `MUTATION_MODEL.md` compliance.

3. Extension Collision Check:
- `EXTENSION_SYSTEM.md` and `EXTENSION_RULES.md` compliance.

4. Runtime Consistency:
- `RUNTIME_MODEL.md` and `LAYOUT_SYSTEM.md` compliance.

5. Platform Boundary Safety:
- `PLATFORM_ABSTRACTION.md` compliance.

6. Documentation Sync:
- all affected `.agent` docs updated and cross-linked.
7. Traceability Enforcement:
- each audit finding includes architecture-ID tags,
- audit output without architecture references is incomplete.
