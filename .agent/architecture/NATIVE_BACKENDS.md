# Native Backends

Focused architecture owner for UIKitUltra cross-backend UI rules.

**Lazy-load rule:** do not read this file for ordinary Apple-only/state/navigation/layout work unless backend architecture is actually involved. Load it for GTK/Qt/Win/Android/TUI work, backend module/import boundaries, cross-backend semantic promotion, or support claims.

## Metadata

- Layer: Platform / Cross-Layer
- Canonical product: `UIKitUltra`; `U*` means **Ultra**
- Apple: UIKit/AppKit remain direct native implementations
- Additional families: GTK 4/libadwaita, Qt 6/KF6, Win over WinUI 3/Windows App SDK, Android Views/Material, UIKitUltra-owned TUI
- Current implementation/status belongs in `PROJECT_MEMORY.md` / `TASKS.md`; execution evidence belongs in `.artifacts/**`

## Invariants

### NB1: One Clean Common Module

Normal portable code uses:

```swift
import Ultra
```

The common module exposes the universal `U*` DSL only. Backend-direct API is opt-in and must not pollute ordinary autocomplete through transitive superclass imports.

Active source uses the final `UIKitUltra` brand and `Ultra` / `Ultra*` Swift identities. Historical/frozen evidence may retain `UIKitPlus` spellings where historically accurate; those spellings are not current API identity.

### NB2: One Authoritative Backend Object Model

For GUI backends, the real host-native object/hierarchy is authoritative. Do not introduce a competing renderer, shadow widget tree, UIKit emulator, cross-toolkit layout solver, or fake list virtualization when the host owns those facilities.

TUI is different because terminals have no native widget hierarchy: UIKitUltra's retained `TUI*` tree/render/focus/input runtime is the authoritative TUI backend, not a shadow of another toolkit. [NB18]

### NB3: UIKitUltra Owns Production Bridges

No third-party Swift UI wrapper may sit between UIKitUltra and GTK/Qt/Win as a required production substrate. No third-party complete TUI framework may own the UIKitUltra TUI runtime.

UIKitUltra owns its generated/mechanical bridge layers. Android retains the maintainer-owned JNIKit + shared Droid runtime direction. [NB17]

External projects/tools may be research/reference/validation inputs without becoming runtime dependencies.

### NB4: Backend Native Foundation Below the Common Module

The accepted dependency direction is:

```text
native toolkit
    ↑
backend native foundation
    ↑
Ultra common module
    ↑
application
```

The selected backend foundation owns the minimum native superclass/object/runtime machinery used by `U*`. `Ultra` owns shared UIKitUltra semantics, builders, State/fluent conveniences, and cross-platform application semantics above that foundation.

For GTK, the accepted production identity is one external source-control package/product/module:

```text
GTK / GObject
    ↑
UltraGTK
    ↑
Ultra
    ↑
application
```

There is no production `UltraGTKRuntime` / `UltraGTKCore` split in the accepted H3 target architecture. Those names are transitional pre-cutover source/history identities.

Ordinary portable source still imports only `Ultra`. Explicit native/backend work may additionally `import UltraGTK`. Do not place implementation-only runtime/signal helpers on inherited GTK wrapper classes merely to make them reachable from `Ultra`; default Swift member visibility would leak them through `U*`. Prefer curated top-level backend types for such cross-package support. Do not rely on every client enabling Swift `MemberImportVisibility`.

Current other backend identities remain independently governed until their own architecture/migration gates:

```text
UltraQt
UltraWin
UltraAndroid
UltraTUI
```

SwiftStream local-development topology is sibling-based:

```text
/Users/imike/Development/SwiftStream/
├── UIKitUltra/
├── UltraGTK/
└── UltraDemoApp/
```

UIKitUltra's manifest carries `let isLocalDevelopment = false` as a committed safety switch. When a child backend package dependency is wired:

- `false` is the only commit/release-safe value and resolves the dependency from its canonical `https://github.com/swiftstream/<Repo>.git` source-control repository;
- `true` is local-working-tree-only and selects a relative sibling path such as `../UltraGTK`;
- the local override must not use `/Users/...`, `/media/psf/...`, or any other machine-specific absolute path;
- backend selection/isolation rules still apply: local-development mode must not become an excuse to resolve unrelated backend packages;
- every staging/commit/release gate must reject `isLocalDevelopment = true`.

The historical Wave B disposable patch used an absolute evidence path for UltraGTK. That path remains historical evidence only and is not canonical manifest policy after the SwiftStream workspace relocation.

### NB5: Generate Breadth, Curate Semantics

Where native API breadth is generated:

```text
authoritative metadata/headers
→ UIKitUltra-owned deterministic importer
→ generator-only normalized IR
→ backend-private generated bindings/bridge source
→ curated UIKitUltra semantic layer
```

Generated source is reproducible/provenanced and not manually patched. The IR is build-time tooling, not a runtime universal widget model.

### NB6: Backend Dependency Closure Is Isolated

A consumer/build must not resolve unrelated backend toolchains or dependencies.

Examples:

- Apple must not pull GTK/Qt/Win/Android/TUI dependencies;
- GTK must not pull Qt/Win/Android/TUI;
- Qt must not pull GTK/Win/Android/TUI;
- Win must not pull GTK/Qt/Android/TUI;
- Android must not pull GTK/Qt/Win/TUI;
- TUI must not pull GUI backends unless an explicit integration product requires them.

Prove isolation executablely; manifest intent alone is insufficient.

### NB7: Backend Selection Is Explicit Where OS Is Ambiguous

Linux does not identify GTK vs Qt. Selection must be explicit; both/neither cases require deliberate behavior rather than silent GTK defaulting.

Active SwiftPM traits are `UltraGTK` / `UltraQt`; historical M1 evidence may still show `UIKitPlusGTK` / `UIKitPlusQt`. The explicit-selection contract is unchanged by the identity migration.

### NB8: Consumer UI Remains Swift-First

Native markup/resources may exist as private build/runtime infrastructure, including XAML, GtkBuilder resources, Qt metadata, Android resources/Manifest/Gradle metadata, etc.

Do not serialize the primary consumer-authored `U*` control tree into XAML/GtkBuilder/QML/Qt `.ui`/Android XML/Compose as the normal authoring model.

### NB9: Layout and Lists Use Honest Backend Mechanisms

Apple Auto Layout remains Apple runtime, not a hidden universal solver.

Shared layout expresses semantic intent and lowers to each backend's honest mechanism: GTK/Qt/Win native layout, Android parent-owned `LayoutParams`/ViewGroup mechanisms, and UIKitUltra-owned cell layout for TUI.

Android and TUI are mandatory inputs to Unified Layout research.

GUI list/collection virtualization uses the host's native model/view/reuse facility when one exists. TUI may own virtualization because the terminal provides none.

### NB10: Backend Production May Proceed in Parallel Lanes

After shared architecture gates are accepted, substantial GTK/Qt/Win/Android/TUI implementation may run in isolated linked worktrees under `PARALLEL_DEVELOPMENT.md`.

Exact committed bases are mandatory. Shared/common contracts remain primary-owned. Use `PRIMARY_SYNC_REQUIRED` / `CROSS_LANE_INTEGRATION_REQUIRED` rather than silent copying/merging. [NB20]

### NB11: Win Means UIKitUltra Win; Native Toolkit Remains WinUI

UIKitUltra-owned names use `Win`:

```text
UltraWin
WinView
WinButton
...
```

Microsoft's toolkit remains correctly named **WinUI 3 / Windows App SDK**.

Accepted production boundary remains UIKitUltra-owned Swift/C ABI + C++/WinRT bridge over native WinUI unless new evidence explicitly revises it. Direct `swift-winrt` is optional/reference tooling, not a required production substrate.

Historical evidence using `UIKitPlusWinUI` keeps its historical spelling.

### NB12: Support Claims Require Implemented + Audited Evidence

Architecture/research acceptance is not a support claim.

Each backend requires the appropriate build/runtime, lifecycle, interaction, appearance/accessibility, dependency/license, complex-fixture, and independent audit evidence before public support claims.

Evidence on one architecture/host does not automatically certify another.

### NB13: `U*` Inheritance Preserves Native Identity

Apple compatibility anchors remain native:

```text
iOS/tvOS UView   → UIView
macOS    UView   → NSView
iOS/tvOS UButton → UIButton
macOS    UButton → NSButton
```

Foreign GUI backends use UIKitUltra-owned Swift wrappers around exactly one authoritative native object:

```text
UButton → GTKButton     → GtkButton*
UButton → QtButton      → Qt native control
UButton → WinButton     → WinUI control
UButton → AndroidButton → Android/Material control
```

The Swift wrapper need not literally subclass the underlying C/C++/WinRT/Java class.

TUI analogously uses `UButton → TUIButton`, with `TUIButton` itself authoritative under NB2.

`BaseView` keeps the same semantic role but must map to an honest generic child-containing view/container. Android plain `View` is therefore insufficient for `UView`; exact container ownership belongs to Unified Layout research.

### NB14: Universal DSL Is a Semantic Superset

Do not reduce UIKitUltra to the lowest common denominator.

Promote valuable UIKit/AppKit/GTK/Qt/WinUI/Android/TUI capabilities into common `U*` API when an honest semantic exists. If one backend lacks a stock widget, a high-quality custom native/backend control is allowed.

Do not universalize OS/backend plumbing that lacks an honest common semantic; keep it backend-direct instead.

### NB15: Backend-Direct API Is Clean and Opt-In

Backend wrappers use natural method names without redundant prefixes:

```text
GTKButton.hasFrame(...)
```

not `gtkHasFrame`.

Explicit backend modules expose top-level backend wrapper types and rare direct escapes on the same authoritative object path:

```swift
.gtk { ... }
.qt { ... }
.win { ... }
.android { ... }
.tui { ... }
```

No proxy/copy control is created for an escape.

### NB16: UIKit Mental Model Is the Common UX Reference

Product rule:

> If you know UIKit then you already know everything in UIKitUltra.

Existing Apple/UIKitUltra DSL is the primary compatibility/naming reference. A major release may improve awkward APIs when justified, but avoid gratuitous breakage.

UIKit-like semantics such as control states/title/image/background should receive real behavior on other backends when feasible.

**Magic is acceptable in lowering, never in semantics.** Do not expose silent fake/no-op parity APIs.

### NB17: Android = JNIKit + Shared Droid Runtime + Modern Material Views

Android goes directly to the intended production architecture:

- JNIKit remains the canonical Java/JNI foundation;
- extract/formalize shared low-level Droid runtime used directly by SwifDroid and UIKitUltra;
- do not make official/third-party Java interop a migration target;
- use Android Views, not Jetpack Compose, as the UIKitUltra object model;
- prefer the current appropriate Material control for each common semantic;
- alternate classic/AppCompat/widget families remain SwifDroid territory;
- explicit direct module is `UltraAndroid`;
- Android participates in Unified Layout before broad parity implementation.

### NB18: TUI = Owned Runtime + Narrow Terminal Driver

Accepted class:

`HYBRID_OWN_RUNTIME_EXTERNAL_TERMINAL_LAYER`

UIKitUltra owns retained `TUI*` objects, State binding, layout, focus/responder routing, normalized input, semantics, cell raster/diff renderer, frame scheduling, image policy, and headless test representation. A narrow replaceable terminal/OS protocol driver sits below it.

Production TUI must support native-feeling pointer interaction where capabilities permit: hover, click/focus, drag/selection, wheel/trackpad scrolling, correct hit testing, high-frequency scroll coalescing/acceleration, and granular mouse capture/fallthrough. Keyboard operation remains complete without pointer capability.

True multi-touch is not a portable common TUI guarantee.

### NB19: State Has One Shared Package Authority

The maintainer-owned standalone `State` repository is the accepted long-term State authority for UIKitUltra, SwifDroid/Droid, and compatible frameworks:

`https://github.com/MihaelIsaev/State`

Backends bind that shared State to native/runtime objects rather than creating permanent parallel reactive systems. Extraction/convergence requires its own reviewed/audited implementation wave.

### NB20: Shared Contracts Remain Primary-Owned

Backend lanes own backend implementation/evidence. Primary owns Apple behavior, universal `U*` semantics, common values, shared State integration, Unified Layout, package-wide contracts, governance, and final integration.

A backend lane may propose/prove shared changes but does not make them canonical unilaterally.

## Implementation-State Routing

Do not turn this architecture owner into a milestone diary.

Use:

- `PROJECT_MEMORY.md` for concise durable current implementation facts;
- `TASKS.md` for current active gates;
- `TASKS_ARCHIVE.md` only for compact completed-task history worth retaining;
- `.artifacts/**` for research reports, exact hashes/counts, runtime evidence, audit reports, migration handoffs, and lane status.

## Forbidden Patterns

- backend import required for ordinary common DSL;
- backend-only members leaking into ordinary common autocomplete by design;
- third-party GUI/TUI runtime substrate replacing owned backend architecture;
- external Java interop replacing JNIKit without explicit architecture revision;
- Compose as the common Android runtime;
- fake cross-toolkit renderer/layout/list engine for GUI backends;
- silent no-op APIs sold as parity;
- redundant backend prefixes on backend-wrapper methods;
- unrelated backend dependencies leaking into a build;
- backend lane unilaterally changing shared contracts;
- public support claim without matching implementation/audit evidence.

## Audit Checklist

For a backend change, answer only the relevant questions:

- Does ordinary portable code remain `import Ultra` only after migration?
- Is backend-direct surface available only through the explicit backend module?
- Is the correct authoritative native/TUI object model preserved?
- Did a foreign runtime/wrapper dependency become required?
- Are backend dependencies isolated?
- Does layout/list behavior use the honest backend mechanism?
- Does a promoted common API have real semantics everywhere claimed?
- Does Android preserve JNIKit/Droid/Views/Material policy when relevant?
- Does TUI preserve the owned-runtime/terminal-driver boundary when relevant?
- Did a parallel lane bypass primary ownership for shared behavior?
- Is the claimed support level backed by appropriate runtime/audit evidence?
