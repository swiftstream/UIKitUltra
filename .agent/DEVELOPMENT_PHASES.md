# Development Phases

All tasks follow `PLAN -> IMPLEMENT -> AUDIT`.

## PLAN

No file mutation in this phase.

Required outputs:
- exact files to edit,
- architecture IDs and docs in scope,
- layer impact (`DSL`, `Runtime`, `Platform`, `Cross-Layer`),
- analogous existing UIKitPlus classes and the concrete engineering patterns to reuse,
- an explicit Stage 1 plan for the simple native UIKit/AppKit declarative wrapper,
- an explicit Stage 2 plan for UIKitPlus conveniences built from established library mechanisms,
- mutation-flow impact,
- extension collision risk,
- fluent chain risk,
- state propagation risk,
- platform leakage risk,
- proposed public opt-in declarative controls for edge cases, when needed,
- confirmation that no new engineering approach is being introduced, or a separate written proposal awaiting explicit author approval,
- documentation synchronization targets,
- architecture-ID tags on each risk/decision statement (for example: `[ST12][MU04][FC02]`).

Blocking conditions:
- missing architecture contract,
- unresolved contract conflict,
- undocumented cross-layer change,
- no analogous UIKitPlus implementation review,
- native-wrapper and UIKitPlus-convenience stages are not separated,
- a new engineering approach is proposed without explicit author approval,
- an edge case is handled by hidden heuristics when a public declarative control is appropriate,
- planning output without architecture-ID grounding.

## IMPLEMENT

Rules:
- implement approved scope only,
- implement the simple native declarative wrapper before adding UIKitPlus conveniences,
- build conveniences only from established UIKitPlus patterns identified during planning,
- preserve existing architecture contracts,
- do not introduce undocumented runtime behavior,
- do not perform hidden contract changes,
- do not introduce a new engineering approach without explicit author approval,
- do not hide edge-case behavior in private heuristics when an optional public declarative control is appropriate,
- avoid broad unrelated refactors.

Required discipline:
- keep Stage 1 native semantics visible and auditable,
- keep Stage 2 conveniences layered on top of Stage 1 rather than replacing it,
- keep fluent `Self` chains intact,
- keep listener wiring explicit,
- keep extension behavior composable,
- keep platform conditionals isolated,
- make edge-case controls explicit, optional, public, declarative, and composable,
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

6. UIKitPlus Engineering Conformance:
- analogous existing classes were identified and their established patterns were followed,
- Stage 1 remains a clear native UIKit/AppKit declarative wrapper,
- Stage 2 conveniences are layered through existing UIKitPlus mechanisms,
- no unapproved engineering approach or hidden compensating subsystem was introduced,
- edge cases use explicit public opt-in declarative controls where custom caller behavior is required.

7. Documentation Sync:
- all affected `.agent` docs updated and cross-linked.
8. Traceability Enforcement:
- each audit finding includes architecture-ID tags,
- audit output without architecture references is incomplete.
