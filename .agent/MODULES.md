# Modules

Framework-oriented module map for UIKitUltra.

## Controllers

- `ViewController`
- `NavigationController` (iOS + macOS variants)
- app/shell controllers (`BaseApp`, tabs, alerts, windows)

## Views

- Universal views (`UView`, `_StackView`, stacks, spacing)
- iOS/tvOS-specific views (`Not-MacOS/*`)
- macOS-specific views (`MacOS/*`)

## Protocols

- Root DSL contracts (`DeclarativeProtocol`, `DeclarativeProtocolInternal`)
- feature protocols (text, gestures, navigation, wrappers)

## Extensions

- `DeclarativeProtocol+Feature.swift` DSL surface
- view/controller/runtime helpers
- platform utility extensions

## Objects

- `Properties`, `PropertiesInternal`
- `PreConstraint`
- gesture wrappers/delegators/trackers
- `ForEach` and related runtime helpers

## Structs

- `State`, `InnerState`, expression/mapping helpers
- builders (`BodyBuilder`, gestures/app builders)
- constraint value abstractions

## Enums

- constraint side enums
- navigation/style enums
- platform behavior toggles

## Styles

- style structs and style-application helpers

## Supporting Assets

- `.agent/*` governance contracts
- `.agent/skills/*` operational skills
- `.agent/templates/*` implementation templates
