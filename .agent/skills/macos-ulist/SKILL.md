---
name: macos-ulist
description: Change or review UIKitPlus macOS UList/NSTableView source behavior inside the UIKitPlus repository. Use for row hosting, self-sizing, recycling, scrolling, automatic heights, live resize, and TextKit 2 row interactions under the UL/UTK architecture contracts; not as a general downstream table-view guide.
---

# Maintain macOS UList / NSTableView

Use this LOCAL contributor skill for UIKitPlus's built-in macOS `UList` implementation.

Architecture authority remains [`MACOS_ULIST_NSTABLEVIEW.md`](../../architecture/MACOS_ULIST_NSTABLEVIEW.md) (`UL1`–`UL10`). Load [`MACOS_ULIST_TEXTKIT2.md`](../../architecture/MACOS_ULIST_TEXTKIT2.md) (`UTK1`–`UTK8`) only when TextKit 2 application rows are involved.

## Load

1. Start from UIKitPlus `AGENTS.md`, [`SKILL_INDEX.md`](../../SKILL_INDEX.md), and [`LAYER_MODEL.md`](../../architecture/LAYER_MODEL.md).
2. Load `MACOS_ULIST_NSTABLEVIEW.md` as the primary domain owner.
3. Choose one final supporting architecture document only when needed:
   - TextKit 2 row: `MACOS_ULIST_TEXTKIT2.md`;
   - lifecycle/reuse/diffs: [`RUNTIME_MODEL.md`](../../architecture/RUNTIME_MODEL.md);
   - constraints/height propagation: [`LAYOUT_SYSTEM.md`](../../architecture/LAYOUT_SYSTEM.md);
   - update callbacks: [`MUTATION_MODEL.md`](../../architecture/MUTATION_MODEL.md).
4. Use [`SOURCE_MAP.md`](../../SOURCE_MAP.md) before broad source discovery.

Do not exceed the normal architecture budget without explicit escalation.

## Before editing

- classify the real owner: generic `UList`, AppKit, or application row [UL1][UL7];
- verify native table width propagation and automatic-height ownership [UL1][UL2];
- verify the row is complete before first display [UL4];
- verify recycling is not performing measurement [UL5];
- verify width changes are not rebuilding the whole list [UL6].

Do not modify generic `_UListCell` merely because one consuming application's content system renders badly. For TextKit 2 rows, keep measurement/reflow in the application row and follow `UTK1`–`UTK8`.

## Guardrails

Preserve one native table column, one current root per cell, four edge constraints, automatic heights, native scrolling, and targeted `UForEach` mutations [UL1][UL2][UL3][UL9].

Reject speculative scrolling opt-outs, forced layout during reuse, dual-root hosting, measurement caches/polling, generic content measurement, and width-driven full-list rebuilds unless the architecture is separately re-opened and approved.

## Validation

Run the focused/full validation required by the current source task. When UL10 applies, rendered recycling and continuous live resize must both pass; success in only one mode is insufficient. TextKit 2 application-row work also requires the UTK8 rendered gate.

For ambiguous rendered geometry, use the current repository's visual-diagnostics route as a separate verification procedure; do not turn visual instrumentation into UList production behavior.

## Audit

Report with applicable `UL*` and `UTK*` tags:

- final framework/AppKit/application ownership boundary;
- native width/height ownership preserved;
- no scroll/recycling measurement;
- continuous live resize without full rebuild;
- targeted/nonanimated height invalidation when applicable;
- targeted diffs/listener ownership preserved;
- rendered acceptance result;
- synchronized durable docs only where ownership facts changed;
- clean task scope.

Stop when a public API or generic framework change is required without explicit approval, or when evidence localizes the defect to one consuming application's content system.