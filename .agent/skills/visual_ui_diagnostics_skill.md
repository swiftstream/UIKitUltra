# Visual UI Diagnostics Skill

Reusable verification skill for rendered UIKit/AppKit/UIKitPlus defects that are ambiguous from source, logs, tests, or geometry alone. It is intentionally general-purpose and is not owned by `UList`, `NSTableView`, or any other single UI domain.

This skill owns **diagnostic procedure only**. The task's selected architecture owner remains authoritative for framework semantics, lifecycle, layout, state, and platform behavior.

## Use This Skill When

Use it for questions such as:

- is the target view/row/control actually rendered on screen?;
- where is its real visible boundary?;
- is the target clipped, occluded, outside the viewport, or merely mismeasured?;
- did a scroll container actually reach the intended edge?;
- which native container owns the visible geometry?;
- does the rendered result diverge from `frame`/`bounds`/constraint/log expectations?;
- does resize, reuse, scrolling, tab/window movement, or state propagation produce a transient visual defect?;
- a coordinator/reviewer needs rendered evidence but lacks direct runtime/UI inspection capability.

Do not use visual instrumentation when source/native state already proves the issue conclusively, or as a substitute for a focused reproduction.

## Context Loading

For a dedicated diagnostic/verification step:

1. `AGENTS.md`;
2. the primary architecture owner already selected for the defect;
3. only one supporting architecture contract when needed;
4. `.agent/VALIDATION_RULES.md`;
5. this skill;
6. the exact source/runtime surface needed to interpret the evidence.

When this skill is loaded in a dedicated verification step, it **replaces the implementation skill for that step**. Do not load both merely because the original task used another skill.

If verification is delegated, follow `DEVELOPMENT_ORCHESTRATION.md` and `ARTIFACTS_WORKFLOW.md` and read only the active verification artifact.

## Core Diagnostic Principle

Prefer objective rendered evidence over inference when the question is visual.

A unique temporary marker proves **what and where the UI actually rendered**.

Native/runtime geometry explains **why it rendered there**.

Use both when possible.

Do not keep extending logging when a safe temporary marker plus screenshot can answer the question directly.

## Evidence-First Loop

```text
define one objective visual question
+→ identify the exact native/UIKitPlus target
+→ choose non-layout-affecting instrumentation
+→ assign a unique marker/color and record its meaning
+→ reproduce under controlled window/device/state conditions
+→ capture screenshot/recording
+→ inspect native geometry/runtime values
+→ correlate rendered marker with geometry
+→ classify owner/root cause
+→ discard instrumentation
+→ verify clean real-repository state
```

Change only one diagnostic variable at a time when practical.

## Instrumented Visual Markers

When a target boundary/presence is visually ambiguous, temporarily mark the exact target in a disposable/debug-instrumented build.

Good targets include:

- bounds of a suspected container/cell;
- bottom/top edge of the final visible row;
- viewport/clip-view boundary;
- content view vs native host boundary;
- two competing layout regions using two different markers;
- a view whose existence, clipping, z-order, or scroll position is uncertain.

Marker rules:

- use a unique high-contrast color not otherwise present on the tested screen;
- maintain a short marker legend, for example `magenta = row root`, `cyan = clip viewport`;
- prefer a thin border/edge marker when a full fill could hide useful content;
- do not add constraints, spacer views, padding, or hierarchy nodes merely to draw a marker when those could alter the geometry being diagnosed;
- prefer visual changes that do not affect intrinsic content size, Auto Layout, fitting size, scroll content size, or hit testing;
- if the marker changes the behavior/geometry, the evidence is invalid and the instrumentation technique must be changed;
- use multiple colors only when each answers a distinct comparison question.

The diagnostic marker is evidence, never a candidate production fix.

## Repository Safety

For read-only verification, keep the real UIKitPlus repository read-only.

If temporary source instrumentation is required:

- prefer a disposable `/tmp` copy or another explicitly disposable verification-only copy;
- build/run the instrumented copy, not the tracked working tree;
- do not stage/commit diagnostic colors, borders, labels, overlays, logging, or debug helpers;
- record exactly what was changed for instrumentation;
- discard the copy after evidence is captured.

If the current implementation task explicitly allows source mutation and temporary instrumentation must occur in the working copy, all diagnostic changes must be fully removed before final diff/audit. A clean final tracked diff is mandatory.

Never convert a diagnostic marker into a workaround simply because it made the bug visible.

## UIKit Geometry Correlation

When UIKit is involved, inspect only values relevant to the hypothesis, for example:

- `UIView.frame` and `bounds`;
- `convert(_:to:)` / `convert(_:from:)` for common-coordinate comparison;
- `window` attachment;
- `safeAreaInsets`;
- `intrinsicContentSize` / fitting size when sizing is disputed;
- `UIScrollView.contentOffset`, `contentSize`, `bounds`, and `adjustedContentInset`;
- presentation/model-layer geometry only when animation state is relevant.

Do not compare frames from unrelated coordinate spaces without conversion.

## AppKit Geometry Correlation

When AppKit is involved, inspect only values relevant to the hypothesis, for example:

- `NSView.frame` and `bounds`;
- `convert(_:to:)` / `convert(_:from:)`;
- `visibleRect`;
- `window` attachment;
- `intrinsicContentSize` / `fittingSize` when sizing is disputed;
- `NSScrollView.contentView` and `NSClipView.bounds` for viewport/scroll position;
- table/row/cell frames and native reuse state when `NSTableView` is involved.

For scrolling defects, distinguish document/content extent from clip-view viewport and current clip bounds.

## Runtime / LLDB Evidence

When LLDB or an equivalent runtime inspector is available, capture the smallest values that test the hypothesis.

Useful evidence may include:

- class/type identity of the actual native view/controller;
- view/window hierarchy ownership;
- hidden/alpha/layer state;
- frame/bounds/visible rectangle;
- scroll offset/content extent/insets;
- active constraints relevant to one disputed axis;
- lifecycle/reuse state;
- UIKitPlus state/listener value only when the visual question depends on it.

Do not dump huge hierarchies or logs without a specific question. Prefer a small set of values paired with the rendered marker.

## Screenshot / Recording Discipline

Keep reproduction conditions explicit:

- platform/OS and target;
- window/device size and scale when relevant;
- orientation when relevant;
- scroll position/selection/state needed to reproduce;
- resize phase or interaction sequence when the defect is transient.

Save screenshots/recordings under the active verification artifact directory when possible.

When comparing multiple captures:

- include timestamps or an explicit sequence in filenames/report;
- sort by the timestamp/sequence, not upload/tool-return order;
- keep baseline and instrumented captures clearly identified;
- do not claim a pixel/point measurement that was not actually established.

A maintainer-provided screenshot/recording is valid rendered evidence when automatic capture is unavailable, but geometry/runtime conclusions still need their own evidence.

## Framework vs Consuming-App Ownership

UIKitPlus must not absorb an application-local workaround merely because a defect appears through UIKitPlus UI.

Before proposing framework mutation, classify the failing owner:

- consuming application composition/content;
- UIKitPlus wrapper/modifier/state/layout behavior;
- native UIKit/AppKit behavior;
- interaction between those layers.

For application-specific symptoms, instrument the smallest application/native boundary first. Modify generic UIKitPlus only after evidence shows the reusable framework contract is actually wrong or missing and normal architecture approval allows the change.

For `UList`/`NSTableView`, follow `MACOS_ULIST_NSTABLEVIEW.md` and the dedicated `macos_ulist_skill.md` during implementation; this visual skill is used in the separate rendered-diagnostic/verification step.

## High-Value Diagnostic Patterns

### Boundary proof

Mark the exact edge the viewport is expected to reach. If the marker is visible, the viewport reached that rendered boundary; if not, correlate with clip/scroll geometry before guessing why.

### Parent vs child isolation

Give parent and child different markers. This distinguishes parent clipping/placement from child sizing/content defects without adding layout elements.

### Hierarchy binary search

When ownership is unclear, move a single marker outward/inward through existing native containers across separate runs. Stop when the first layer whose rendered boundary diverges from expected geometry is identified.

### Resize / transient defect

Use recording plus geometry samples at defined resize/interaction points. A static screenshot cannot prove continuous behavior by itself.

## Verification Report Contract

A visual diagnostic report should contain:

```text
objective question
reproduction environment
architecture owner / suspected layer
instrumentation location
marker legend
rendered observation
native/runtime geometry observation
correlation / conclusion
framework-vs-app ownership classification
remaining uncertainty
cleanup proof
real-repository Git state
```

Clearly distinguish:

- directly observed rendered evidence;
- directly inspected source/Git evidence;
- runtime/LLDB evidence;
- inference derived from those facts.

Do not state stronger conclusions than the evidence supports.

## Stop Conditions

Stop and report instead of widening scope when:

- the defect cannot be reproduced under the stated conditions;
- instrumentation changes the geometry/behavior being measured;
- the required runtime/UI tool is unavailable and no verifier with that capability is available;
- evidence localizes the issue outside UIKitPlus and the task does not authorize that external scope;
- fixing it would require a new public API/architecture contract not already approved;
- final cleanup cannot prove all diagnostic instrumentation is absent from the tracked diff.

A successful diagnosis ends with objective evidence and a clean production source state, not with the continued presence of debug UI.
