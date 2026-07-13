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

- `StatusItem.swift` — macOS status item controller with state binding support.
- `MenuItem.swift` — macOS menu item with state bindings and listener lifecycle.

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
- `MacOS+TextView.swift` — macOS `UTextView` owned `NSTextView` inside `NSScrollView` with declarative text/state/editing/command API, auto-growing height, and maximum-height scrolling.

### Classes/Extensions/**

Extension-driven feature composition (the `DeclarativeProtocol+Feature.swift` pattern):

- `DeclarativeProtocol+*.swift` — declarative view-owned state bindings (Tint, Corners, Hidden, Alpha, Opacity, UserInteraction, Borders, Shadow).
- `UIColor+Dynamic.swift` — macOS dynamic-color theme listener.
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

Test suite: 362 tests (macOS baseline), 218 tests (iOS simulator baseline).

## Key Ownership Notes

- `State.swift`, `StateListener.swift`, `StatesHolder.swift`, `StateBindingOwner.swift` — core state engine.
- `PreConstraint.swift` — self-owned `StateListener` pattern (completed in milestone 6).
- `Identable.swift` — identity conformance for diff.
- `Array+Diff.swift` — collision-safe identity and duplicate matching (completed in milestone 7).
- `MenuItem.swift` — lifecycle fix with retain-cycle repair (completed in milestone 5M).
- `List.swift` — reversed-state binding.
- `ForEach.swift` — scoped subscriptions.
