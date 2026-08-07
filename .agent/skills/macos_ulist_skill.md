# macOS UList / NSTableView Skill

Compact operational checklist. Architecture authority:
`architecture/MACOS_ULIST_NSTABLEVIEW.md` (`UL1`–`UL10`), extended by
`architecture/MACOS_ULIST_TEXTKIT2.md` (`UTK1`–`UTK8`) only for TextKit 2 rows.

## Load

1. `AGENTS.md`
2. `.agent/ARCH_INDEX.md`
3. `.agent/architecture/LAYER_MODEL.md`
4. `MACOS_ULIST_NSTABLEVIEW.md`
5. Choose one final architecture document:
   - TextKit 2 rows: `MACOS_ULIST_TEXTKIT2.md`;
   - other rows: at most one supporting contract when needed:
     - `RUNTIME_MODEL.md` for lifecycle/reuse/diffs;
     - `LAYOUT_SYSTEM.md` for constraints/height propagation;
     - `MUTATION_MODEL.md` for update callbacks.
6. `.agent/SOURCE_MAP.md`

Do not bulk-load supporting contracts or exceed the three-document
architecture budget without documented escalation.

## Before Editing

- classify the owner: generic `UList`, AppKit, or application row [UL1][UL7];
- verify native width propagation and automatic heights [UL1][UL2];
- verify the row is complete before first display [UL4];
- verify recycling does not trigger measurement [UL5];
- verify width changes do not rebuild the whole list [UL6].

Do not modify `_UListCell` from an application-only rendering symptom.
For TextKit 2 rows, keep measurement/reflow in the application row and follow
`UTK1`–`UTK8`.

## Guardrails

Preserve one native table column, one current root per cell, four edge
constraints, automatic heights, native scrolling, and targeted `UForEach`
mutations [UL1][UL2][UL3][UL9].

Reject speculative responsive-scrolling opt-out, forced layout on reuse,
dual-root hosting, caches, polling, generic content measurement, and
width-driven full-list rebuilds [UL3][UL6][UL7].

## Validation

Run focused/full tests when source changes, then rendered recycling + continuous
live-resize validation from `UL10`. Scrolling and live resize must be accepted
together; success in only one mode fails. TextKit 2 rows also require `UTK8`.

## Audit

Report with `UL*` tags and applicable `UTK*` tags:

- final ownership boundary;
- native width/height ownership preserved;
- no scroll/recycling measurement;
- continuous live resize without full rebuild;
- targeted/nonanimated height invalidation when applicable;
- targeted diffs/listener ownership preserved;
- rendered acceptance result;
- synchronized docs and clean scope.

Stop when a public API or generic framework change is required without explicit
approval, or when the defect cannot be reproduced outside one application
content system.
