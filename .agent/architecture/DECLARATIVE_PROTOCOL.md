# DeclarativeProtocol

## Metadata
- Layer: DSL
- Depends On Layers: Runtime, Platform
- Primary Runtime Artifacts: `DeclarativeProtocol`, `declarativeView`, `properties`, layout-facing state properties, `tag`

## Purpose

Define the root declarative contract that anchors UIKitPlus fluent APIs to concrete view/controller objects.

## Invariants

### DP1: Core Contract Shape

`DeclarativeProtocol` requires:
- `associatedtype V: BaseView, DeclarativeProtocol = Self`
- `var declarativeView: V { get }`
- `var properties: Properties<V> { get set }`

### DP2: Layout-Facing Surface Exists on the Protocol

The protocol exposes scalar layout-facing properties (`height`, `width`, `top`, `leading`, `left`, `trailing`, `right`, `bottom`, `centerX`, `centerY`) and `tag`.

### DP3: Reference Identity Is Preserved

Fluent operations are applied to the same underlying instance through `declarativeView`.

### DP4: Internal Runtime Bridge

Conforming runtime types provide internal bridge access through `DeclarativeProtocolInternal` for constraint state links and lifecycle behavior.

## Forbidden Patterns

- Conforming with value-semantic copies for `declarativeView`.
- Breaking consistency between public protocol-facing properties and internal state links.
- Hiding `declarativeView` replacement inside fluent methods.

## Integration Rules

- New conforming types must provide stable `properties` storage.
- New conforming types that participate in constraints must support internal runtime contract fields (`__height`, etc.).
- Protocol extensions must not assume non-declared concrete storage unless constrained to internal protocols.

## Audit Implications

Changes to this contract require explicit review of:
- chain safety,
- constraint state linkage,
- extension compatibility.
