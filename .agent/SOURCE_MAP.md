# Source Map

Living source ownership/navigation map for humans and LLM agents.

This document is source navigation guidance. It is not architecture authority, task log, or governance authority.

## Update Rule

MUST update this file when:
- a source file is added, deleted, moved, or renamed;
- ownership/responsibility of a source file changes;
- after future Swift 6 migration if source boundaries change.

Do not add transient commit logs here. Keep this map focused on stable source ownership and navigation.

## Entry Points

- `Package.swift` — SwiftPM package manifest.

## Source Layout

### Classes/Controllers/**

- `Menu.swift` — macOS `NSMenu` wrapper; UIKitPlus-created menus use private
  `_NSMenu` storage to retain declarative `MenuItem` action owners for the
  native AppKit menu lifetime. [RT7][PA1][PA3]
- `ViewController.swift` — cross-platform controller wrapper; macOS window
  notification callbacks register by native notification name, filter delivery
  against the controller's current `view.window`, preserve additive listener
  semantics, and remove selector observers during teardown. [PA1][PA3][FC5][MU3]
- `Window.swift` — macOS `NSWindow` fluent wrapper; `toolbar(_:)` preserves
  native optional semantics while `toolbar()` creates a native toolbar;
  `title`, `acceptsMouseMovedEvents`, and the opt-in best-effort
  `titlebarBackground(_:)` expose owner-scoped state bindings. The titlebar
  bridge follows dynamic `UColor` theme updates under `App`, safely falling
  back to the light value outside that host, and is not a stable AppKit
  hierarchy contract. [PA1][PA3][FC1][FC6][FC11][FC12][ST8]
- `MacOS+WindowTabTopology.swift` — validated logical group/tab topology and
  identity-preserving source move descriptions. Contract:
  `architecture/MACOS_WINDOW_TABS.md`. [PA1][FC1][FC11][WT-001][WT-003]
- `MacOS+WindowTabRuntime.swift` — type-erased tab runtime protocols and
  result-builder support. [PA1][FC1][FC2][WT-001][WT-004]
- `MacOS+WindowTab.swift` — lazy `WindowTab` native window wrapper and the
  complete `NSWindowTab` metadata surface with concrete state overloads.
  [PA1][FC1][FC11][FC12][ST8][WT-002][WT-006]
- `MacOS+WindowTabForEach.swift` — identity-preserving source-array
  reconciliation, explicit move reporting, and configure/update lifecycle.
  [PA1][FC1][FC5][FC11][FC12][ST8][RT5][MU2][WT-004]
- `MacOS+WindowTabGroup.swift` — native group activation, detach/reattach,
  close/plus delegate proxy, topology reconciliation, native group access, and
  overview controls. [PA1][FC1][FC2][FC5][FC11][FC12][ST8][WT-001][WT-005][WT-006]
- `MacOS+OpenPanel.swift` — declarative `NSOpenPanel` wrapper with concrete
  and state-bound configuration plus modal URL results. [PA1][FC11][FC12][ST8][WT-007]
- `MacOS+Alert.swift` — declarative `NSAlert` wrapper with concrete and
  state-bound message configuration plus modal responses. [PA1][FC11][FC12][ST8][WT-007]
- `StatusItem.swift` — macOS status item controller with state binding support.
- `MenuItem.swift` — macOS menu item with state bindings, closure actions, and
  cycle-free helper ownership. [RT7][PA1][PA3]

### Classes/Views/Universal/**

Cross-platform views shared between UIKit and AppKit:

- `StackView.swift` — `UStackView` universal stack.
- `HScrollStack.swift` — horizontal scroll stack.
- `VScrollStack.swift` — vertical scroll stack.
- `ActivityIndicator.swift` — `UActivityView` (UIKit/tvOS) and `UActivityIndicator` (macOS).
- `BarButtonItemView.swift` — `UBarButtonItem` with owner scaffolding.

### Classes/Views/Not-MacOS/**

UIKit-only views (guarded by `#if !os(macOS)`):

- `Button.swift` — `UButton` UIKit scalar state bindings.
- `ImageView.swift` — `UImage` state bindings and URL loader.
- `DatePickerView.swift` — `UDatePicker` scalar state bindings.
- `SliderView.swift` — `USlider` scalar state bindings.
- `Toggle.swift` — `UToggle` scalar state bindings.
- `PickerView.swift` — `UPickerView` textColor binding.
- `SegmentedControl.swift` — `USegmentedControl` select binding.
- `RefreshControl.swift` — `URefreshControl` tint binding with owner scaffolding.
- `TextField.swift` — `UTextField` typing-state listener.
- `TextView.swift` — `UTextView` typing-state listener.
- `Collection.swift` — `UCollection` reversed-state binding.
- `List.swift` — `UList` reversed-state binding.

### Classes/Views/MacOS/**

macOS-only views (guarded by `#if os(macOS)`):

- `MacOS+Button.swift` — `UButton` macOS type state binding, hover bridge, setup listener.
- `MacOS+ImageView.swift` — `UImage` macOS `NSImage` and URL state bindings.
- `MacOS+TextField.swift` — `UTextField` macOS typing-state and attributed-string listener.
- `MacOS+Text.swift` — `UText` macOS `NSTextField` label; line configuration
  synchronizes `maximumNumberOfLines`, `usesSingleLineMode`,
  `NSTextFieldCell.wraps`, and `NSTextFieldCell.isScrollable`. Multiline sizing
  remains native and constraint-driven; callers can use the existing public
  compression-resistance modifier when text should wrap inside constrained
  horizontal space. Text-style mutations invalidate intrinsic sizing.
  [PA1][PA3][RT1][FC5]
- `MacOS+TextView.swift` — macOS `UTextView` owned `NSTextView` inside `NSScrollView` with declarative text/state/editing/command API, auto-growing height, and maximum-height scrolling.
- `MacOS+List.swift` — macOS `UList` backed by `UScrollView` and one-column
  view-based `NSTableView`; owns ordered sections, maps scoped `ForEach` diffs
  to targeted native row operations, and delegates width propagation, cell
  reuse, automatic heights, scrolling, and live resize to AppKit. Full contract:
  `architecture/MACOS_ULIST_NSTABLEVIEW.md`. [PA4][PA5][VC5][RT8][UL1]
- `MacOS+GlassEffectView.swift` — macOS 26+ native `UGlassEffectView: NSGlassEffectView` declarative Glass host.
- `MacOS+VisualEffectView.swift` — macOS native `UVisualEffectView: NSVisualEffectView` legacy effect host.

### Classes/Extensions/**

Extension-driven feature composition (the `DeclarativeProtocol+Feature.swift` pattern):

- `DeclarativeProtocol+*.swift` — declarative view-owned state bindings (Tint, Corners, Hidden, Alpha, Opacity, UserInteraction, Borders, Shadow).
- `DeclarativeProtocol+HuggingPriority.swift` — owns the canonical native content-hugging fluent modifier for UIKit/AppKit, preserving native priority and axis/orientation semantics. [FC1][FC2][FC3][FC6][EX1][EX4][EX5][PA1][PA3][PA5]
- `DeclarativeProtocol+CompressionResistance.swift` — owns the canonical native content-compression-resistance fluent modifier for UIKit/AppKit, preserving native priority and axis/orientation semantics. [FC1][FC2][FC3][FC6][EX1][EX4][EX5][PA1][PA3][PA5]
- `UIGlassEffect+Declarative.swift` — iOS/iPadOS/tvOS 26+ fluent modifiers for the native `UIGlassEffect` object.
- `UIGlassContainerEffect+Declarative.swift` — iOS/iPadOS/tvOS 26+ fluent spacing modifier for the native `UIGlassContainerEffect` object.
- `DeclarativeProtocol+CornerConfiguration.swift` — generic iOS/tvOS 26+ declarative `UIView.cornerConfiguration` modifier.
- `UIColor+Dynamic.swift` — macOS dynamic-color theme listener; safely skips
  theme wiring and returns the light variant when `NSApplication` is not a
  UIKitPlus `App`.
- `AttrStr+Joined.swift` — attributed string joined composition.
- `Array+Diff.swift` — collision-safe identity and duplicate matching diff helpers.

### Classes/Protocols/**

Protocol-oriented abstractions:

- `StateBindingOwner.swift` — `_StateBindingOwner` protocol and `holdInStateBindingOwnerIfAvailable(_:)` internal bridge for protocol-extension listener ownership.
- `DeclarativeProtocol.swift` — core protocol for fluent chain API.
- `Colorable.swift`, `Tintable.swift`, `BackgroundColorable.swift` — color protocol state routing.
- `Textable.swift`, `Titleable.swift`, `Messageable.swift`, `Placeholderable.swift` — text protocol state routing.
- `Hiddenable.swift`, `BulletsEchoable.swift` — strong-capture capability bindings.
- `ControlStateable.swift`, `BezelStyleable.swift` — stored capability bindings.
- `Hiddenable.swift` — hidden state listener.

### Classes/Structs/**

Core state engine and data structures:

- `State.swift` — `State<Value>` property wrapper, merge/map internals.
- `StateListener.swift` — `StateListener` token and lifecycle.
- `StatesHolder.swift` — `StatesHolder` / `TempStatesHolder` listener ownership.
- `InnerState.swift` — parent projection listener.
- `ExpressableState.swift` — source forwarding.
- `CodableState.swift` — projected value forwarding.
- `ParagraphStyle.swift` — 20 state-to-property merge listeners.

### Classes/Objects/**

- `AttributedString.swift` — attributed string with color state listener and `AnyString.onUpdate`.
- `PreConstraint.swift` — deferred layout constraint with self-owned `StateListener`.
- `ForEach.swift` — `ForEach` scoped subscriptions.

### Tests/UIKitPlusTests/**

Test suite: 407 tests, 5 skipped (macOS baseline); 218 tests (historical complete iOS XCTest baseline).

- `MenuItemLifecycleTests.swift` — verifies cycle-free menu item teardown,
  native-menu ownership of closure targets after wrapper release, submenu
  action lifetime, and external `NSMenu` identity preservation. [RT7][PA1][PA3]
- `MacOSListDeclarativeTests.swift` — verifies native macOS `UList` structure,
  chronological rows, targeted ForEach mutations, native row-root hosting,
  width propagation, automatic heights, scrolling, and scoped listener
  ownership. [VC5][RT8][PA4][UL1][UL2][UL9]
- `MacOSTextDeclarativeTests.swift` — verifies native single-line and multiline
  AppKit cell flags exposed by `UText.lines(_:)` and `UText.multiline()`.
  [PA1][PA3][RT1][FC1]
- `MacOSWindowDeclarativeTests.swift` — verifies toolbar creation, fluent
  identity, preservation of native `toolbar(nil)` clearing semantics, and
  owner-scoped titlebar background bindings. [PA1][PA3][FC1][FC6][FC11][FC12][ST8]
- `MacOSWindowTabsDeclarativeTests.swift` — verifies native-tab topology
  invariants, lazy materialization, live tab state bindings, identity-preserving
  source replacement/moves, delegate forwarding, native group/overview access,
  and open-panel/alert state routing. [WT-001][WT-006][ST8]
- `MacOSViewControllerWindowNotificationTests.swift` — verifies notification
  filtering by the attached window, pre-attachment registration, payload
  delivery, and additive callback registration. [PA1][PA3][FC5][MU3]

### Glass Effect Ownership and Validation

- `MacOSVisualEffectsDeclarativeTests.swift` — macOS native and legacy visual-effect coverage; macOS 26-only Glass tests skip on older macOS hosts.
- `UIKitGlassEffectsDeclarativeTests.swift` — shared seven-test iOS/tvOS Glass and corner-configuration contract suite.
- UIKit Glass effect extensions are shared by iOS/iPadOS/tvOS 26+; `UVisualEffectView` remains the UIKit native host. Installed effect identity is not guaranteed after native installation; installed type and public configuration are the supported assertions. [PA1][PA2][PA3][FC1][FC2][FC3][EX1][EX4]
- Focused iOS 26.2 runtime probes passed on `UIKitPlus-iPhone-26-2` (iPhone 17 Pro-equivalent) and `UIKitPlus-iPad-26-2` (iPad Pro 11-inch-equivalent) simulators.
- Focused tvOS 26.2 runtime probe passed on an available Apple TV simulator. The complete tvOS package build remains blocked by unrelated pre-existing unavailable UIKit APIs in `PushNotificationOption.swift` and other paths; it is not a tvOS-clean baseline.
- Catalyst follows the iOS source branch but was not validated because the current macabi compiler path failed before loading UIKit.

## Key Ownership Notes

- `State.swift`, `StateListener.swift`, `StatesHolder.swift`, `StateBindingOwner.swift` — core state engine.
- `PreConstraint.swift` — self-owned `StateListener` pattern (completed in milestone 6).
- `Identable.swift` — identity conformance for diff.
- `Array+Diff.swift` — collision-safe identity and duplicate matching (completed in milestone 7).
- `Menu.swift` owns native `_NSMenu` declarative-item storage; `MenuItem.swift` remains cycle-free; native AppKit ownership, not reverse wrapper cycles, keeps closure actions alive. [RT7][PA1][PA3]
- `List.swift` — reversed-state binding.
- `ForEach.swift` — scoped subscriptions.
