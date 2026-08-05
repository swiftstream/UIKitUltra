# Architecture Index

Load this file first. Keep context minimal and layer-aware.

## Loading Protocol

1. Identify task type and impacted layer(s).
2. Load `.agent/architecture/LAYER_MODEL.md`.
3. Load one domain architecture doc.
4. Load one contract doc (`FLUENT_CHAIN_CONTRACT`, `STATE_SYSTEM`, `EXTENSION_SYSTEM`, `RUNTIME_MODEL`, or `MUTATION_MODEL`).
5. Stop at decision-complete context.

Default max active architecture docs: `3`.

## Layer-First Routing

- Layer model and cross-layer boundaries:
  - `.agent/architecture/LAYER_MODEL.md`

- DSL layer:
  - `.agent/architecture/DSL_ARCHITECTURE.md`
  - `.agent/architecture/DECLARATIVE_PROTOCOL.md`
  - `.agent/architecture/VIEW_COMPOSITION.md`
  - `.agent/architecture/FLUENT_CHAIN_CONTRACT.md`

- Runtime layer:
  - `.agent/architecture/STATE_SYSTEM.md`
  - `.agent/architecture/LAYOUT_SYSTEM.md`
  - `.agent/architecture/MACOS_ULIST_NSTABLEVIEW.md`
  - `.agent/architecture/GESTURE_SYSTEM.md`
  - `.agent/architecture/NAVIGATION_SYSTEM.md`
  - `.agent/architecture/RUNTIME_MODEL.md`
  - `.agent/architecture/MUTATION_MODEL.md`
  - `.agent/architecture/EXTENSION_SYSTEM.md`

- Platform layer:
  - `.agent/architecture/PLATFORM_ABSTRACTION.md`

- UIKitPlus application architecture:
  - `.agent/architecture/APPLICATION_STATE_OWNERSHIP.md`

## Domain Routing

- Declarative protocol and chain API changes:
  - `DECLARATIVE_PROTOCOL.md`
  - `FLUENT_CHAIN_CONTRACT.md`
  - `EXTENSION_SYSTEM.md`

- Body/ForEach/view composition changes:
  - `VIEW_COMPOSITION.md`
  - `RUNTIME_MODEL.md`
  - `MUTATION_MODEL.md`

- State/binding/listener changes:
  - `STATE_SYSTEM.md`
  - `MUTATION_MODEL.md`
  - `FLUENT_CHAIN_CONTRACT.md`

- UIKitPlus application state placement, View/ViewController ownership, child dependency contracts, app-wide environment, runtime/domain owner decisions, ViewModel/PresentationModel evaluation, and fixture ownership:
  - `APPLICATION_STATE_OWNERSHIP.md`
  - `STATE_SYSTEM.md`
  - `VIEW_COMPOSITION.md`

- Constraint/layout changes:
  - `LAYOUT_SYSTEM.md`
  - `RUNTIME_MODEL.md`
  - `MUTATION_MODEL.md`

- macOS `UList` / `NSTableView`, visible-cell hosting, self-sizing rows,
  recycling, scrolling, automatic row heights, or live resize:
  - `MACOS_ULIST_NSTABLEVIEW.md`
  - add only one supporting contract when required:
    `RUNTIME_MODEL.md` for lifecycle/diffs, `LAYOUT_SYSTEM.md` for constraints,
    or `MUTATION_MODEL.md` for callbacks

- Gesture wrapper/delegation changes:
  - `GESTURE_SYSTEM.md`
  - `EXTENSION_SYSTEM.md`
  - `MUTATION_MODEL.md`

- Navigation behavior changes:
  - `NAVIGATION_SYSTEM.md`
  - `RUNTIME_MODEL.md`
  - `PLATFORM_ABSTRACTION.md`

- UIKit/AppKit bridge changes:
  - `PLATFORM_ABSTRACTION.md`
  - `LAYER_MODEL.md`
  - impacted domain doc(s)

## Governance and Debt Routing

- Source ownership and navigation:
  - `.agent/SOURCE_MAP.md`

- Technical debt and future refactor candidates:
  - `.agent/TECH_DEBT.md`

- Commit rules and message style:
  - `.agent/COMMIT_RULES.md`

- Validation rules:
  - `.agent/VALIDATION_RULES.md`

- Task archive (completed milestones):
  - `.agent/TASKS_ARCHIVE.md`

- State vNext planning (deferred):
  - `.agent/STATE_VNEXT_PLAN.md`

## ID Namespace Map

- `DA*` -> `DSL_ARCHITECTURE.md`
- `DP*` -> `DECLARATIVE_PROTOCOL.md`
- `VC*` -> `VIEW_COMPOSITION.md`
- `ST*` -> `STATE_SYSTEM.md`
- `LY*` -> `LAYOUT_SYSTEM.md`
- `GS*` -> `GESTURE_SYSTEM.md`
- `NV*` -> `NAVIGATION_SYSTEM.md`
- `PA*` -> `PLATFORM_ABSTRACTION.md`
- `LC*` -> `LAYER_MODEL.md`
- `FC*` -> `FLUENT_CHAIN_CONTRACT.md`
- `EX*` -> `EXTENSION_SYSTEM.md`
- `RT*` -> `RUNTIME_MODEL.md`
- `MU*` -> `MUTATION_MODEL.md`
- `AO*` -> `APPLICATION_STATE_OWNERSHIP.md`
- `UL*` -> `MACOS_ULIST_NSTABLEVIEW.md`
