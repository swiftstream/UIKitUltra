# macOS UList / TextKit 2 Row Contract

## Metadata
- Layer: Cross-Layer
- Depends On: `MACOS_ULIST_NSTABLEVIEW.md` (`UL1`–`UL10`)
- Scope: application-owned rich, variable-height TextKit 2 rows in macOS `UList`
- IDs: `UTK1`–`UTK8`

## Purpose

Load this document only when a macOS `UList` row uses TextKit 2, such as a
chat message containing paragraphs, lists, links, and code blocks.

For TextKit 2 row work, this document is the primary owner and `MACOS_ULIST_NSTABLEVIEW.md` is its required generic-list dependency. Do not load `LAYER_MODEL.md` by default; add one further supporting contract only when the task genuinely crosses that boundary.

Generic `UList` remains content-agnostic. AppKit owns native table behavior,
UIKitUltra owns generic list composition and cell hosting, and the application
row owns its TextKit 2 objects, measurement, reflow, and height callback.

Reference shape:

```text
UList -> UForEach -> application row -> persistent TextKit 2 body
```

## Invariants

### UTK1 — Keep ownership split

Follow `UL1`–`UL10`. `UList` must not create, measure, cache, or refresh TextKit
content. The row owns content-specific work; AppKit owns native scrolling,
clipping, reuse, row frames, column width, and automatic heights.

### UTK2 — Keep one persistent TextKit 2 graph per materialized row

Use one stock `NSTextView(usingTextLayoutManager: true)` and its
`NSTextContentStorage`, `NSTextLayoutManager`, and `NSTextContainer` for the
row lifetime. Reflow the same graph when width changes; do not create a second
measurement engine or replace the graph per resize tick.

### UTK3 — Complete initial layout before returning the row

Install the complete attributed content, lay out the full document range, and
accept only finite geometry that reaches document end. Return a complete row
with valid constraints and an initial height for the current pixel-aligned
content width.

Do not rely on attachment, viewport entry, scrolling, or retries to finish the
first layout.

### UTK4 — Scrolling and recycling are layout-inert

At unchanged content and width, attach, detach, clipping, reuse, and viewport
entry/exit must not remeasure TextKit or mutate row height.

Reject scroll observers, `viewDidMoveToWindow` measurement, timers, polling,
and `needsLayout`/`needsDisplay` correctness loops.

### UTK5 — Reflow only for real width changes

During live resize, compare the actual pixel-aligned TextKit content width.
Skip unchanged widths, update the existing text container synchronously, and
change the local height only when geometry differs by at least one backing
pixel. Run one final pass when live resize ends.

### UTK6 — Report height changes through the native table contract

Carry stable application row identity, reject stale-generation callbacks, and
coalesce changed identities before targeted
`noteHeightOfRows(withIndexesChanged:)` with zero animation.

Do not use `reloadData()`, a parallel `heightOfRow`, generic height caches, or
manual row/cell frames.

### UTK7 — Refresh a partially clipped materialized viewport narrowly

During live resize, after targeted native height invalidation, a materialized
TextKit row that is partially clipped above should refresh its current viewport
through the existing layout manager:

```swift
textLayoutManager.textViewportLayoutController.layoutViewport()
```

This narrow refresh prevents visible complex content such as code blocks from
remaining clipped at the bottom during live resize. It is not a whole-document
layout pass, display loop, or guarantee that every ordinary paragraph repaint
becomes immediate in every AppKit viewport state.

Do not add forced display, backing-layer invalidation, transaction flushing,
retries, polling, or whole-list work around this call.

### UTK8 — Require rendered acceptance

Builds and unit tests prove compilation/contracts only. Validate in a rendered
app with enough rich variable-height rows to force recycling:

- long paragraphs, links, lists, and code blocks;
- fully visible and partially clipped-above rows;
- slow/fast scrolling, reversals, and inertial stops;
- slow/rapid narrow-wide live resize and immediate post-resize scrolling;
- normal/fullscreen and supported scale/appearance changes.

Reject missing or clipped rich content, height correction at unchanged width,
scroll jumps, resize stutter, unintended animation, or a second sizing engine.

## Diagnosis Order

1. Was the row complete before first display?
2. Did scrolling/recycling trigger measurement?
3. Did the real pixel-aligned content width change?
4. Did the persistent TextKit graph produce finite complete geometry?
5. Did a stable identity reach targeted native height invalidation?
6. Is only the current partially clipped viewport stale after native geometry
   is already correct?

Do not begin by changing generic `UList`, forcing display, or adding caches.
