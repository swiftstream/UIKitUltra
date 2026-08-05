# Project Memory

This file stores stable governance memory for UIKitPlus agent work.

## Repository Identity

- UIKitPlus is a declarative UIKit/AppKit DSL framework.
- Core contract root is `DeclarativeProtocol` with reference semantics.
- Public API growth is extension-driven.

## Current State

- The source baseline underlying the macOS UList/NSTableView governance contract
  is `56b726fbbf9ec6218677a106ff33599a5b1187c3`; framework source was unchanged.
- Local `master` tracks `origin/master`; no push is authorized.
- Push is locked.
- Governance docs are being finalized before Swift 6 strict concurrency migration.
- `.artifacts` is transient and ignored.
- State vNext is deferred until after Swift 6 migration.

## Baselines

- macOS swift test baseline: 390 tests, 5 skipped
- iOS simulator baseline: 218

- macOS `UTextView` is an AppKit scroll/text wrapper with declarative state, editing, command support, auto-growing height, and maximum-height scrolling.

## macOS Window and Controller Facts

- `Window.toolbar(_:)` preserves native optional semantics: passing `nil` clears
  the toolbar, while `Window.toolbar()` creates a native `NSToolbar`. [PA1][FC1][FC6]
- macOS `ViewController` window notifications are additive by notification name;
  delivery checks `notification.object === view.window`, so configuration may
  happen before attachment and remains correct if the view moves between
  windows. Selector observers are removed during controller teardown.
  [PA1][PA3][FC5][MU3]

## macOS Text Facts

macOS UText synchronizes native line-mode flags immediately and preserves the
native `preferredMaxLayoutWidth` default. Multiline layout is resolved by the
caller's constraint graph and native AppKit intrinsic sizing. When a multiline
text field must wrap within a constrained horizontal space, the caller can use
UIKitPlus's existing public compression-resistance modifier to allow horizontal
compression instead of changing measurement properties during layout. UIKitPlus
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
- Chronological append plus explicit `scrollToBottom()` is supported.
- ForEach listeners release with the list, and no AppKit diffable-data-source
  layer was added. [RT8][ST6][PA4]

## macOS Menu Ownership Facts

- UIKitPlus-created macOS menus use private `_NSMenu: NSMenu` storage that
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
- UIKitPlus has no synthetic UIKit Glass view or wrapper effect.
- Native `UIVisualEffectView` installation may copy supplied effects. UIKitPlus validates the installed native type and public configuration rather than supplied-object identity.
- `UIKitPlus-iPhone-26-2` (iPhone 17 Pro-equivalent) and `UIKitPlus-iPad-26-2` (iPad Pro 11-inch-equivalent) iOS 26.2 runtime probes passed; native diagnostics observed copied effect identities while configured public values survived installation.
- The focused tvOS 26.2 Glass runtime probe passed. The complete tvOS package build remains blocked by unrelated pre-existing unavailable UIKit APIs and is not claimed tvOS-clean.
- Catalyst follows the iOS source branch, but current macabi validation was not performed successfully because the compiler failed before loading UIKit.
- visionOS and watchOS are excluded from the Glass feature.

## Frozen Architectural Decisions

1. Architecture is frozen by default.
2. Fluent APIs are `Self`-returning in-place mutations.
3. State engine is reference-based (`State`, `InnerState`) with synchronous listener dispatch.
4. Constraint system uses deferred pre-constraint queues plus activation on superview availability.
5. Platform abstraction is explicit and conditional (`#if os(macOS)` / non-macOS variants).

## Workflow Memory

- Mandatory phase order: `PLAN -> IMPLEMENT -> AUDIT -> LOCAL COMMIT`.
- No push until independent audit is accepted and user authorizes.
- Patch review must validate fluent, state, extension, runtime, and mutation contracts.
- Task closure requires `.agent` synchronization.

## Documentation Memory

- `ARCH_INDEX.md` is the routing entrypoint.
- Max active architecture docs defaults to `3`.
- Skills/templates are secondary context after architecture loading.

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
