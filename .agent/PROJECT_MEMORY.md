# Project Memory

This file stores lazy durable current-state memory for UIKitUltra agent work. Do not load it at startup unless the current task needs these facts.

## Repository Identity

- Canonical local workspace root is `/Users/imike/Development/SwiftStream`; canonical local project path is `/Users/imike/Development/SwiftStream/UIKitUltra`.
- Canonical GitHub organization is `swiftstream`; UIKitUltra lives at `https://github.com/swiftstream/UIKitUltra`. New UIKitUltra-family `Ultra*` repositories belong in the same organization unless explicitly decided otherwise.
- UIKitUltra, `UltraGTK`, and `UltraDemoApp` are independent sibling repositories under the SwiftStream workspace, not subdirectories of one shared Git repository.
- `Package.swift` permanently carries `let isLocalDevelopment = false`; `true` is a local-only uncommitted override for relative sibling package paths and is forbidden in any commit/tag/release/push.
- Canonical project/framework identity is **UIKitUltra**; canonical public Swift module/product identity is **Ultra**; `U*` means **Ultra**. Active source uses the final identity scheme; one-time rename mechanics and historical evidence stay in `.artifacts/migrations/**`.
- Golden developer-experience rule: `If you know UIKit then you already know everything in UIKitUltra.`
- Apple remains directly UIKit/AppKit-native. Additional backend families and exact public backend/module naming are owned by `architecture/NATIVE_BACKENDS.md`.
- Core contract root remains `DeclarativeProtocol` with reference semantics. Public API growth is extension-driven.

## Current State

- The source baseline underlying the macOS UList/NSTableView governance contract
  is `56b726fbbf9ec6218677a106ff33599a5b1187c3`; framework source was unchanged.
- Local `master` tracks `origin/master`; no push is authorized.
- Push is locked.
- Stable development orchestration is model-independent and routed through `DEVELOPMENT_ORCHESTRATION.md` plus `ARTIFACTS_WORKFLOW.md` for non-trivial iterative work.
- `.artifacts/**` is transient, Git-ignored working memory and is reconstructable from stable docs + Git + actual source when missing.
- Parallel linked-worktree work is governed lazily by `.agent/PARALLEL_DEVELOPMENT.md`; concrete lane paths/base SHAs/status remain transient `.artifacts/**` state.
- The standalone maintainer-owned `State` repository (`https://github.com/MihaelIsaev/State`) is the accepted canonical destination for shared State used by UIKitUltra/SwifDroid/compatible frameworks; extraction/migration remains implementation-gated.
- `IDENTITY-ULTRA-001` is final-CLEAN after Correction 01. The original independent final rename audit found only `IRFA-001-STABLE-NB4-PUBLIC-MODULE-IDENTITY-STALE`; PRIMARY corrected the two stale NB4 module/product facts and the focused independent re-audit closed `IRFA-001` with `A11` and `A18` PASS. Identity migration is no longer a blocker for Unified Layout research or future lane planning; linked-worktree lanes still require an exact committed base.
- Current Git integration task is `INTEGRATION-001`. Correction 01 is PRIMARY-accepted after a CLEAN focused independent re-audit (18 PASS / 0 FAIL; GIPA-001/002/003 CLOSED). Index Transition 01 is complete and accepted: the historical 296-record staged checkpoint was retired through the independently verified 377-literal restore authority while the working tree remained byte-identical. PRIMARY froze the complete 315-leaf post-transition partition: 287 exact paths belong to coherent product+architecture release-base Commit R and 28 to later governance/orchestration Commit G. Commit R may be created only after its exact staged candidate passes the required independent audit and PRIMARY acceptance; Commit G remains separately reviewed and committed afterward. Tag/push stay blocked until the post-integration release-block audit. Stable `.agent/**` documentation remains PRIMARY-owned.
- M1 structural native-backend foundation is implemented/audited and the active package exposes public module/product `Ultra`. H3 Wave C production UltraGTK extraction/migration is PRIMARY FINAL CLOSED after corrected C05 acceptance, post-C05 durable agent-doc synchronization, and a CLEAN final independent Sol audit (60 PASS / 0 FAIL, no findings). GTK native-foundation ownership is external and singular: sibling repository/package/product/module/import `UltraGTK` sits below `Ultra`; the former root-owned `UltraGTKRuntime` / `UltraGTKCore` production split and old GTK ownership roots are absent. Linux selection remains explicit through `UltraGTK` / `UltraQt` traits; Qt/Win retain their current runtime identities until their own migration gates. Canonical UIKitUltra keeps `isLocalDevelopment = false`; Linux `UltraGTK` resolves exact `swiftstream/UltraGTK@3.0.0-alpha.5`, while uncommitted local development may use sibling `../UltraGTK`. UltraGTK publication is PRIMARY-accepted at root commit `894f4a545e21cc2f1363a231f4f00f69ba2fdb75`, tree `7eb36dc1f16b7f077469195a98414184825d80b4`, and annotated tag `3.0.0-alpha.5` (tag object `a23eacf57ca033f30d42e625de124e9c5846c89e`, peeled target equal to the root commit). Historical UIKitUltra-root SwiftPM planner overbuild remains recorded; C05 accepts backend isolation from the direct selected-target plus external-consumer actual compile/link/runtime oracle, not from root-product planning. No production source/package/stable-agent correction is required by Wave C final closure, and no broad non-Apple support claim follows from H3 acceptance. UIKitUltra Git integration remains a separate explicit gate.
- `UltraCore` currently contains exactly `ExpressableState.swift`,
  `OrderedRegistrations.swift`, `State.swift`, `StateListener.swift`, and
  `StatesHolder.swift`, with Foundation-only direct imports.
- Physical UIKitUltra backend source directories stay concise: `Sources/Core`,
  `Sources/QtRuntime`, `Sources/Qt`, `Sources/WinRuntime`, and `Sources/Win`.
  GTK native-foundation source/bridge/generator ownership lives in sibling
  `UltraGTK`; UIKitUltra retains its public Linux façade under `Sources/Kit/**`.
  Legacy UIKitUltra-owned `Sources/WinUI/**` and old GTK ownership roots are
  absent from the active tree; SwiftPM module identity is `Ultra*`.
- The public `Ultra` target lives under `Sources/Kit/**`. `Kit` is intentionally only a concise physical directory name; package/repository identity remains `UIKitUltra`, while consumer Swift code imports `Ultra`.
- CocoaPods distribution is no longer supported by UIKitUltra. The repository's
  legacy `UIKit-Plus.podspec` was removed and public installation guidance now
  uses Swift Package Manager only. The release that first ships this removal
  must include an explicit migration note: CocoaPods installation is no longer
  supported and users should migrate to Swift Package Manager. The rationale
  should accurately describe CocoaPods as being in maintenance mode with
  CocoaPods Trunk moving to permanent read-only for new Podspec publication,
  rather than claiming the entire CocoaPods infrastructure had already gone
  offline before that actually occurs.
- M1 Task07 selected and executable-proved a package-owned source-first Windows
  ARM64 NuGet/MSBuild/C++/WinRT bridge workflow consumed through only
  `import Ultra`. Production WinUI controls and durable native bridge
  source remain future implementation work.

## Baselines

- macOS swift test baseline: 407 tests, 5 skipped
- iOS simulator baseline: 218

- macOS `UTextView` is an AppKit scroll/text wrapper with declarative state, editing, command support, auto-growing height, and maximum-height scrolling.

## macOS Window and Controller Facts

- `Window.toolbar(_:)` preserves native optional semantics: passing `nil` clears
  the toolbar, while `Window.toolbar()` creates a native `NSToolbar`. [PA1][FC1][FC6]
- `Window.titlebarBackground(_:)` is an explicit best-effort bridge for native
  title/tab chrome; it follows dynamic `UColor` theme updates under `App`,
  safely falls back to the light value outside that host, and is not a stable
  AppKit hierarchy contract. [PA1][PA3][FC12][ST8]
- macOS `ViewController` window notifications are additive by notification name;
  delivery checks `notification.object === view.window`, so configuration may
  happen before attachment and remains correct if the view moves between
  windows. Selector observers are removed during controller teardown.
  [PA1][PA3][FC5][MU3]
- macOS native project tabs are implemented by the split
  `MacOS+WindowTabTopology.swift`, `MacOS+WindowTabRuntime.swift`,
  `MacOS+WindowTab.swift`, `MacOS+WindowTabForEach.swift`, and
  `MacOS+WindowTabGroup.swift` sources. Metadata/windows are registered
  eagerly, content controllers materialize on first selection, and a
  reference-backed `WindowTabTopology` reconciles AppKit
  reorder/detach/reattach with the caller's source and topology `UState`
  values. Stable-ID replacement uses an explicit repeatable update handler;
  the delegate proxy forwards all non-owned AppKit selectors, and the group
  exposes the typed `onLastTabClose` decision hook without bypassing native
  close policy. The focused contract is `MACOS_WINDOW_TABS.md`
  (`WT-001`–`WT-007`).

## macOS Text Facts

macOS UText synchronizes native line-mode flags immediately and preserves the
native `preferredMaxLayoutWidth` default. Multiline layout is resolved by the
caller's constraint graph and native AppKit intrinsic sizing. When a multiline
text field must wrap within a constrained horizontal space, the caller can use
UIKitUltra's existing public compression-resistance modifier to allow horizontal
compression instead of changing measurement properties during layout. UIKitUltra
does not infer a width from a superview, persist provisional geometry, or run a
parallel measurement lifecycle. Text, font, alignment, line-break, and
line-count mutations invalidate intrinsic size, while `.lines(1)` restores
native single-line flags. [PA1][PA3][RT1][FC5]

## macOS List Facts

- High-level macOS `UList` exists with `UScrollView` plus one-column
  `NSTableView` native backing. [PA4][VC5]
- `UForEach` diffs map to targeted native insert, remove, and reload operations;
  rows use automatic sizing. [VC5][RT8]
- Every top-level declarative row view is pinned to the native row wrapper's
  leading and trailing edges, while the wrapper itself is pinned to the native
  `NSTableCellView` edges. The table document view uses native width autoresizing;
  `NSTableView.columnAutoresizingStyle` and the column autoresizing mask own
  column width changes. `UList` has no live-resize layout override, manual frame
  synchronization, or row-height engine. AppKit owns cell frames, live resize,
  and automatic row-height calculation. [VC5][RT8][PA4][PA5]
- macOS `UList` keeps AppKit-owned width propagation, reuse, automatic heights,
  scrolling, and live resize. Application rows own complete initial content and
  content-specific self-sizing; recycling is never a resize trigger. The full
  contract is `MACOS_ULIST_NSTABLEVIEW.md`. [RT8][UL1][UL4][UL5][UL6]
- Rich TextKit 2 rows keep one persistent text-system graph, complete initial
  layout, width-only reflow, targeted native height invalidation, and a narrow
  partially-clipped viewport refresh. The focused contract is
  `MACOS_ULIST_TEXTKIT2.md`. [UL7][UL8][UTK1][UTK7]
- Chronological append plus explicit `scrollToBottom()` is supported.
- ForEach listeners release with the list, and no AppKit diffable-data-source
  layer was added. [RT8][ST6][PA4]

## macOS Menu Ownership Facts

- UIKitUltra-created macOS menus use private `_NSMenu: NSMenu` storage that
  retains declarative `MenuItem` wrappers for the lifetime of the native menu. [RT7][PA1][PA3]
- This keeps closure-based actions and key equivalents functional when AppKit
  retains only `NSMenu`. [RT7][PA1][PA3]
- The ownership graph contains no Objective-C associated objects, global
  registry, `_MenuItem.root`, or `MenuItemHelper.root`. [RT7][PA1][PA3]
- `Menu.init(_ menu: NSMenu)` preserves the exact external native-menu identity. [RT7][PA1][PA3]

## Glass Effect Facts

- macOS 26+ uses the native AppKit `UGlassEffectView: NSGlassEffectView` view.
- iOS/iPadOS/tvOS 26+ use native UIKit effect objects, with Glass effects hosted by the existing `UVisualEffectView`.
- The generic corner-configuration modifier assigns native `UIView.cornerConfiguration` and preserves declarative view identity.
- UIKitUltra has no synthetic UIKit Glass view or wrapper effect.
- Native `UIVisualEffectView` installation may copy supplied effects. UIKitUltra validates the installed native type and public configuration rather than supplied-object identity.
- `UIKitPlus-iPhone-26-2` (iPhone 17 Pro-equivalent) and `UIKitPlus-iPad-26-2` (iPad Pro 11-inch-equivalent) iOS 26.2 runtime probes passed; native diagnostics observed copied effect identities while configured public values survived installation.
- The focused tvOS 26.2 Glass runtime probe passed. The complete tvOS package build remains blocked by unrelated pre-existing unavailable UIKit APIs and is not claimed tvOS-clean.
- Catalyst follows the iOS source branch, but current macabi validation was not performed successfully because the compiler failed before loading UIKit.
- visionOS and watchOS are excluded from the Glass feature.

## Frozen Architectural Decisions

1. Architecture is frozen by default.
2. Fluent APIs are `Self`-returning in-place mutations.
3. State engine is reference-based (`State`, `InnerState`) with synchronous listener dispatch.
4. Constraint system uses deferred pre-constraint queues plus activation on superview availability.
5. Platform abstraction is explicit and compile-time scoped. GUI backends use real native toolkit objects; TUI owns its retained terminal object/render runtime because no native terminal widget hierarchy exists. GTK/Qt/Win/Android/TUI topology, owned bridge/runtime policy, dependency isolation, native-markup posture, universal-superset semantics, backend escape modules, and support gates are owned by `architecture/NATIVE_BACKENDS.md`.
6. Android production uses owned JNIKit + shared low-level Droid runtime + Android Views with modern Material-first controls; Compose and external Java interop are not UIKitUltra runtime dependencies.
7. Backend-specific direct APIs are opt-in through explicit modules and `.gtk/.qt/.win/.android/.tui` escapes; ordinary `import Ultra` remains the clean universal DSL.
8. Substantial backend implementation may proceed in isolated linked worktrees after the shared architecture gate; shared/common contract authority stays with the primary line.

## Workflow Memory

- Mandatory development cycle: `PLAN -> IMPLEMENT -> AUDIT`; commit and push are separate explicit Git gates.
- Non-trivial iterative work externalizes research/plans/tasks/reports/corrections under disposable `.artifacts/**`; large work uses numbered surgical task files plus a short coordinator prompt.
- Executor reports are evidence, not proof; independent source/diff/Git/architecture review is mandatory.
- When required verification cannot be executed directly, delegate a focused read-only verification task rather than leaving a blind spot.
- Substantial roadmap milestones require a final independent whole-milestone conformance review before milestone completion/commit gate.
- No push until current project-specific prerequisites are accepted and the user explicitly authorizes push.
- Patch review must validate fluent, state, extension, runtime, mutation, and relevant platform contracts.
- Task closure synchronizes only affected durable `.agent` owners.

## Documentation Memory

- `ARCH_INDEX.md` is the technical architecture routing entrypoint.
- Max active architecture docs defaults to `3`; operational orchestration/artifact owners do not consume these slots.
- Skills/templates are secondary context after architecture loading.
- `PUBLIC_CONTENT_IDEAS.md` and its shards are durable but lazy candidate communication material, loaded only after a positive capture check or for explicit public-content work.

## State vNext Memory

- Swift 6 strict concurrency first, State vNext later.
- Global cross-framework debt shared with SwifDroid and SwifWeb.
- External `@State` DX stays simple.
- `.hold(in:)` public lifecycle API.
- S5 removed obsolete `holdIfOwned(by:)`; `Classes`/`Tests` should stay free of it.
- Protocol extensions use internal `holdInStateBindingOwnerIfAvailable(_:)`; concrete owners use `.hold(in: stateBindingHolder)`.
- `removeListeners()` preferred naming.
- S6 accepted Option C first: keep `State<Value>` unconstrained for now and isolate UI binding surfaces only if future diagnostics require it.
- Strict build/test currently pass with zero State-related diagnostics; no immediate `@MainActor State` / `Value: Sendable` implementation is required.
