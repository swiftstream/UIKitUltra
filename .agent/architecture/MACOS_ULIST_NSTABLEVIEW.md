# macOS UList / NSTableView Contract

## Metadata
- Layer: Cross-Layer
- Depends On: Runtime, Layout, Platform
- Source: `Classes/Views/MacOS/MacOS+List.swift`
- IDs: `UL1`–`UL10`

## Purpose

Authoritative contract for macOS `UList` and its native `NSTableView` backing.
Load this document for row hosting, self-sizing, recycling, scrolling,
automatic row heights, or live resize.

Ownership is intentionally split:

- AppKit owns native scrolling, clipping, reuse, column width, row frames,
  automatic heights, and live window resize;
- UIKitPlus owns section/diff composition and one edge-constrained declarative
  root per visible cell;
- the application row owns content-specific measurement and reflow.

## Invariants

### UL1 — Preserve the native width graph

Width flows through:

`NSClipView -> NSTableView -> NSTableColumn -> cell -> declarative root`

Keep native table/column autoresizing and four cell-edge root constraints.
Do not add a `UList.layout()` frame loop or fit columns during live resize.

### UL2 — AppKit owns virtualization and automatic heights

Keep one native table column, `usesAutomaticRowHeights = true`, and native
dynamic/inertial scrolling. Never replace virtualization with an eager stack
or mutate heights merely because rows enter or leave the viewport.

### UL3 — One current root per visible cell

Cell reconfiguration deactivates old constraints, removes the old root,
attaches one new root, and activates four edge constraints.

Do not speculate with overlapping roots, forced descendant layout, snapshots,
placeholders, or row-root caches without an independently reproduced generic
framework defect.

### UL4 — Builders return complete rows

The row builder must return a complete hierarchy with valid constraints and a
deterministic intrinsic or explicit height. UIKitPlus does not finish or
measure application content after construction.

### UL5 — Recycling is not resize

Attach, detach, reuse, clipping, viewport entry/exit, and inertial scrolling
must not trigger measurement or height correction at unchanged content and
width.

Reject attach-time measurement, `viewDidMoveToWindow` verification, retries in
`.eventTracking`, and `needsLayout`/`needsDisplay` correctness loops.

### UL6 — Live resize is continuous and native

Preserve the current table/list while width changes. Let the native width graph
update visible rows continuously. Do not freeze until mouse-up, debounce visual
updates, or rebuild the complete list per pixel.

### UL7 — Content-specific sizing belongs to the row owner

Custom rows may reflow only when their actual pixel-aligned width changes.
They must skip unchanged widths, update local constraints only for real height
changes, and never remeasure because of scrolling or recycling.

TextKit, WebKit, image, editor, and other content systems remain their own
single layout authority; generic `UList` must not add a parallel engine.

### UL8 — Height changes are targeted

Application-owned legitimate height changes should use stable row identity,
reject stale-generation callbacks, coalesce indexes, and call targeted
`noteHeightOfRows(withIndexesChanged:)`.

Use `NSAnimationContext.duration = 0` unless row growth is intentionally a
product animation. Do not use `reloadData()` or a generic height cache as a
sizing mechanism.

### UL9 — Preserve targeted `UForEach` mutations

Keep balanced begin/end updates, targeted insert/remove/reload operations,
weak list captures, and list-scoped listener ownership. Do not replace normal
diff handling with unconditional full reloads.

### UL10 — Rendered acceptance is mandatory

Source changes affecting this contract require focused/full tests plus rendered
validation with enough variable-height rows to force recycling:

- slow and fast scrolling in both directions;
- reversals and inertial stops at both ends;
- slow and rapid narrow/wide live resize;
- immediate scrolling after resize;
- normal, narrow, wide, and fullscreen modes;
- content sentinels that reveal late, missing, stale, or incomplete rows.

Reject blank/stale rows, late content, height correction at unchanged width,
scroll jumps, unintended height animation, resize rebuild stutter, or
post-resize recycling regressions. Builds and unit tests alone are insufficient.

## Framework Non-Goals

Do not add speculatively:

- responsive-scrolling opt-out;
- forced layout on every reuse;
- simultaneous old/new roots;
- row/root snapshots or caches;
- row-height caches or polling;
- custom table-frame synchronization;
- width-driven complete-list reconstruction;
- application-specific content measurement;
- production test hooks.

Exceptions require generic reproduction, explicit approval, focused tests,
profiling, and synchronized contract updates.

## Diagnosis Order

1. Does the application row change height at unchanged width?
2. Does attachment/recycling trigger delayed measurement?
3. Is the whole list rebuilt for width changes?
4. Are native height changes animated unintentionally?
5. Is initial row content incomplete?
6. Are stale callbacks targeting current rows?
7. Do new rows use stale column width?
8. Has generic `UList` acquired a second layout/height/rendering system?

Do not begin by changing `_UListCell`, disabling responsive scrolling, forcing
layout, or adding caches before application-row lifecycle is proven correct.

## Current Golden Framework Posture

- native one-column `NSTableView`;
- native width autoresizing and automatic row heights;
- targeted `UForEach` mutations;
- one declarative root per visible cell;
- no custom live-resize or height engine;
- no responsive-scrolling override;
- no forced descendant layout during reuse;
- no application-specific measurement.
