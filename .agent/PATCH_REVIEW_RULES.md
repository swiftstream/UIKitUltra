# Patch Review Rules

Every implementation patch must pass architecture-contract review.

All review outputs must include architecture-ID tags (for example: `[ST12][MU04][FC02]`).

## Review Pipeline

1. Scope Validation
- patch touches only intended files,
- no unrelated broad formatting/refactors.

2. Chain Contract Validation
- check against `.agent/architecture/FLUENT_CHAIN_CONTRACT.md`.
- verify `Self` chain behavior and reference-semantic assumptions are preserved.

3. State and Mutation Validation
- check against `.agent/architecture/STATE_SYSTEM.md` and `.agent/architecture/MUTATION_MODEL.md`.
- verify propagation ordering assumptions, listener safety, recursion guards, and no hidden sync loops.

4. Extension Safety Validation
- check against `.agent/architecture/EXTENSION_SYSTEM.md`.
- verify no overload ambiguity, no precedence traps, no undeclared cross-cutting side effects.

5. Runtime Consistency Validation
- check against `.agent/architecture/RUNTIME_MODEL.md`.
- verify lifecycle-dependent behavior (deferred constraints, observer flows, ForEach diffs) remains coherent.

6. Layout and Platform Validation
- check against `LAYOUT_SYSTEM.md` and `PLATFORM_ABSTRACTION.md`.
- verify no implicit platform leakage and no unsafe constraint behavior changes.

7. Documentation Synchronization
- update affected `.agent` docs and indexes.
8. Traceability Validation
- every review finding must include architecture-ID tags,
- missing architecture references fail review enforcement.

## Documentation Sync

- update `.agent/SOURCE_MAP.md` when stable source ownership changes;
- update `.agent/TECH_DEBT.md` when new stable debt is discovered;
- update `.agent/TASKS.md` when task status changes.

## Rejection Triggers

Reject patch if it introduces:
- chain contract break,
- undocumented state propagation change,
- extension conflict risk,
- runtime lifecycle inconsistency,
- platform leakage,
- unsynchronized architecture docs,
- review artifacts without architecture-ID traceability.
