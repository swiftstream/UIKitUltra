---
name: uikitultra-visual-ui-diagnostics
description: Diagnose rendered UIKitUltra UI defects using objective screenshots/recordings, temporary non-layout-affecting visual markers, and native UIKit/AppKit geometry. Use when visibility, clipping, viewport reach, hierarchy ownership, scrolling, resize, or actual rendered boundaries are ambiguous from source/logs/tests alone.
license: LICENSE.txt
---

# Diagnose Rendered UIKitUltra UI

Use this skill when a UIKitUltra interface behaves visually differently from what source, logs, tests, or expected geometry suggest.

This skill owns **diagnostic procedure only**. It does not define UIKitUltra architecture and does not authorize framework mutation by itself.

## Use it for questions such as

- Is the target view, row, or control actually rendered?
- Where is its true visible boundary?
- Is it clipped, occluded, outside the viewport, or simply mismeasured?
- Did a scroll view really reach the expected edge?
- Which UIKit/AppKit/native container owns the visible geometry?
- Does rendered output disagree with `frame`, `bounds`, constraints, or logged state?
- Does resize, reuse, scrolling, tab/window movement, or State propagation produce a transient defect?
- Does the problem belong to the consuming app, UIKitUltra, the native framework, or the interaction between them?

Do not instrument visually when source/native state already proves the issue conclusively. Do not use instrumentation as a substitute for a focused reproduction.

## Core principle

Prefer objective rendered evidence when the disputed fact is visual.

A unique temporary marker answers:

**what actually rendered, and where?**

Native/runtime geometry answers:

**why did it render there?**

Use both when possible.

## Evidence-first loop

```text
define one objective visual question
→ identify the exact UIKitUltra/native target
→ choose non-layout-affecting instrumentation
→ assign a unique marker/color and record its meaning
→ reproduce under controlled conditions
→ capture screenshot or recording
→ inspect native/runtime geometry
→ correlate marker and geometry
→ classify the real owner/root cause
→ remove diagnostic instrumentation
→ verify the production repository/source is clean of debug UI
```

Change one diagnostic variable at a time when practical.

## Instrumented visual markers

When presence or a boundary is ambiguous, temporarily mark the exact existing target in a disposable/debug-instrumented build.

Good targets include:

- bounds of a suspected container, row, or cell;
- top/bottom edge of the final visible item;
- scroll/clip viewport boundary;
- content view versus native host boundary;
- parent and child regions whose ownership is disputed;
- an existing view whose clipping, placement, z-order, or scroll relationship is unclear.

Marker rules:

- use a unique high-contrast color not otherwise present on the tested screen;
- maintain a short legend such as `magenta = row root`, `cyan = viewport`;
- prefer a thin border/edge marker when a fill would obscure useful content;
- do not add spacer views, constraints, padding, hierarchy nodes, or hit-test owners merely to draw the marker if that can alter the geometry under investigation;
- prefer instrumentation that does not affect intrinsic content size, Auto Layout, fitting size, scroll content size, reuse, or hit testing;
- if instrumentation changes the behavior being measured, discard that evidence and choose a different technique;
- use multiple colors only when each answers a distinct comparison question.

A diagnostic marker is evidence, never a candidate production fix.

## Repository and source safety

For read-only verification, keep the real source repository read-only whenever possible.

If temporary source instrumentation is required:

- prefer a disposable copy/build area;
- record exactly what was instrumented;
- do not stage or commit debug colors, borders, labels, overlays, logging, or helper code;
- remove/discard all instrumentation after evidence is captured.

If the task explicitly allows working-copy instrumentation, the final production diff must prove that every diagnostic-only change was removed.

Never turn a marker or debug overlay into a workaround simply because it made the defect observable.

## UIKit geometry correlation

When UIKit is involved, inspect only values relevant to the hypothesis, for example:

- `UIView.frame` and `bounds`;
- `convert(_:to:)` / `convert(_:from:)` for common-coordinate comparison;
- `window` attachment;
- `safeAreaInsets`;
- `intrinsicContentSize` and fitting size when sizing is disputed;
- `UIScrollView.contentOffset`, `contentSize`, `bounds`, and `adjustedContentInset`;
- model/presentation-layer geometry only when animation state is relevant.

Do not compare frames from unrelated coordinate spaces without conversion.

## AppKit geometry correlation

When AppKit is involved, inspect only values relevant to the hypothesis, for example:

- `NSView.frame` and `bounds`;
- `convert(_:to:)` / `convert(_:from:)`;
- `visibleRect`;
- `window` attachment;
- `intrinsicContentSize` and `fittingSize`;
- `NSScrollView.contentView` / `NSClipView.bounds`;
- table/row/cell frames and reuse state when `NSTableView` is involved.

For scrolling defects, distinguish content/document extent from viewport size and the current clip bounds.

## Runtime / LLDB evidence

When a runtime inspector is available, capture the smallest values that test the current hypothesis.

Useful evidence may include:

- actual class/type identity;
- view/window hierarchy ownership;
- hidden/alpha/layer state;
- frame/bounds/visible rectangle;
- scroll offset/content extent/insets;
- constraints relevant to one disputed axis;
- lifecycle/reuse state;
- UIKitUltra State/listener value when the visual question depends on it.

Avoid giant hierarchy/log dumps without a specific question. A small set of values paired with the rendered marker is usually stronger evidence.

## Screenshot and recording discipline

Record the reproduction environment when relevant:

- platform/OS and target;
- device/window size and scale;
- orientation;
- scroll position, selection, or State required to reproduce;
- resize/interaction sequence for transient defects.

When comparing captures:

- use explicit timestamps or sequence numbers;
- order evidence by that timestamp/sequence, not upload/tool-return order;
- distinguish baseline and instrumented captures;
- do not claim a pixel/point measurement that was not actually established.

A maintainer-provided screenshot or recording is valid rendered evidence for what is visible. Geometry/runtime conclusions still require their own evidence.

## Classify the real owner before proposing a fix

A problem visible through UIKitUltra does not automatically belong in the UIKitUltra framework.

Classify the failing owner as one of:

- consuming application composition/content;
- UIKitUltra wrapper/modifier/state/layout behavior;
- native UIKit/AppKit behavior;
- interaction between those layers.

For application-specific symptoms, instrument the smallest application/native boundary first. Modify generic UIKitUltra only after evidence shows that the reusable framework contract is actually wrong or missing and the relevant project governance allows that change.

When working inside a UIKitUltra source checkout, obey that checkout's current architecture/governance and domain-specific implementation rules before changing framework source. This public diagnostic skill does not replace those local owners.

## High-value diagnostic patterns

### Boundary proof

Mark the exact edge the viewport is expected to reach. If the marker is visible, the viewport reached that rendered boundary. If not, correlate the result with native scroll/clip geometry before guessing why.

### Parent versus child isolation

Give an existing parent and child different markers. This distinguishes parent clipping/placement from child sizing/content defects without adding layout elements.

### Hierarchy binary search

When ownership is unclear, move one marker outward or inward through existing native containers across separate runs. Stop at the first layer whose rendered boundary diverges from expected geometry.

### Resize or transient defect

Use a recording plus geometry samples at defined interaction/resize points. A static screenshot cannot prove continuous behavior by itself.

## Report contract

A useful visual diagnostic report contains:

```text
objective question
reproduction environment
suspected layer / owner
instrumentation location
marker legend
rendered observation
native/runtime geometry observation
correlation / conclusion
app-vs-framework-vs-native ownership classification
remaining uncertainty
cleanup proof
final repository/source state
```

Clearly distinguish:

- directly observed rendered evidence;
- directly inspected source/Git evidence;
- runtime/LLDB evidence;
- inference derived from those facts.

Do not state stronger conclusions than the evidence supports.

## Stop conditions

Stop and report instead of widening scope when:

- the defect cannot be reproduced under the stated conditions;
- instrumentation changes the geometry/behavior being measured;
- required UI/runtime evidence is unavailable and no trusted verifier can obtain it;
- evidence localizes the issue outside the authorized task scope;
- a framework fix would require a new public API/architecture contract that has not been reviewed;
- final cleanup cannot prove diagnostic instrumentation is absent from production source.

A successful diagnosis ends with objective evidence and clean production source, not with debug UI left behind.