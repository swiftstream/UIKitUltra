# View Composition

## Metadata
- Layer: DSL
- Depends On Layers: Runtime, Platform
- Primary Runtime Artifacts: `BodyBuilder`, `BodyBuilderItem`, `BaseView.addItem`, `ForEach`, `View+Body`

## Purpose

Specify how UIKitPlus composes views declaratively while preserving object identity and runtime update wiring.

## Invariants

### VC1: Builder Output Is Itemized

`BodyBuilder` resolves into `BodyBuilderItem` cases (`single`, `multiple`, `nested`, `forEach`, `none`) consumed by runtime insertion logic.

### VC2: Composition Preserves UIKit/AppKit Identity

Built items insert real `BaseView` instances; composition does not create value-view snapshots.

### VC3: ForEach Is Subscription-Driven

`ForEach` over stateful collections subscribes to state changes and applies deletions/insertions based on diff results.

### VC4: Insertion Order Is Explicit

`addItem` and `add(views:at:)` define deterministic insertion order within current hierarchy operations.

### VC5: Native List Composition

Platform `UList` implementations consume `BodyBuilderItem` sections and map
`ForEach` diffs to native row operations. Stateful insertions, removals, and
modifications update only affected native rows rather than rebuilding the
complete list composition tree.

Native row ownership remains platform-owned. Row roots are real UIKitPlus
views. On macOS, every top-level declarative row view is pinned to the native
row wrapper's leading and trailing edges, and the wrapper is pinned to the
native cell edges. This forms one native constraint graph from the AppKit-owned
column and cell width down to the declarative row content. UIKitPlus does not
maintain a second resize, animation, or row-height engine. The macOS 11+
`.plain` style and macOS 10.15 legacy plain-compatible default supply no
implicit outer padding, so a row's visual insets are explicit constraints owned
by the calling composition. No second snapshot/diff engine is introduced.
[VC5][RT5][RT8][PA4][PA5]

## Forbidden Patterns

- Treating composition as immutable tree diffing engine.
- Replacing entire subtrees on every update without domain justification.
- Ignoring `ForEach` diff semantics and manually mutating arranged/subview sets unsafely.

## Integration Rules

- New builder items must define runtime insertion and update semantics.
- `ForEach` integrations must document state ownership and listener lifecycle.
- Composition extensions must not bypass declared insertion helpers without clear reason.

## Audit Implications

Composition patches must verify:
- correct item translation,
- safe ForEach update propagation,
- no hidden lifecycle regressions in insertion/removal.
