# Architecture Index

Authoritative routing and architecture-ID ownership index for UIKitPlus. Keep context minimal and layer-aware.

Operational development authorities are routed separately from technical architecture:

- workflow: `WORKFLOW.md`;
- coordinator/executor roles and independent review gates: `DEVELOPMENT_ORCHESTRATION.md`;
- transient research/plan/task/report/handoff mechanics: `ARTIFACTS_WORKFLOW.md`;
- Git/staging/commit safety: `COMMIT_RULES.md`;
- progressive loading: `CONTEXT_LOADING_RULES.md`;
- source navigation: `SOURCE_MAP.md`;
- lazy durable README/docs/website/publication idea capture: `PUBLIC_CONTENT_IDEAS.md` plus focused `.agent/public-content-ideas/**` shards. Do not load during ordinary development unless the capture check is positive or the task is explicitly public-content work.

Operational workflow/artifact/public-content owners do not consume architecture-doc slots.

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
  - `.agent/architecture/MACOS_ULIST_TEXTKIT2.md`
  - `.agent/architecture/GESTURE_SYSTEM.md`
  - `.agent/architecture/NAVIGATION_SYSTEM.md`
  - `.agent/architecture/RUNTIME_MODEL.md`
  - `.agent/architecture/MUTATION_MODEL.md`
  - `.agent/architecture/EXTENSION_SYSTEM.md`

- Platform layer:
  - `.agent/architecture/PLATFORM_ABSTRACTION.md`
  - `.agent/architecture/NATIVE_BACKENDS.md` for implemented M1 backend target/selection boundaries plus accepted Linux/Windows native-backend topology, owned bindings/generator architecture, backend dependency isolation, markup posture, and support-gating rules

- UIKitPlus application architecture:
  - `.agent/architecture/APPLICATION_STATE_OWNERSHIP.md`

- macOS native window tabs, lazy content, native detach/reattach, topology
  state, source-array moves, and concrete state-binding overloads:
  - `.agent/architecture/MACOS_WINDOW_TABS.md` (implementation is split across
    `MacOS+WindowTabTopology.swift`, `MacOS+WindowTabRuntime.swift`,
    `MacOS+WindowTab.swift`, `MacOS+WindowTabForEach.swift`, and
    `MacOS+WindowTabGroup.swift`)

## Domain Routing

- Declarative protocol and chain API changes:
  - `DECLARATIVE_PROTOCOL.md`
  - `FLUENT_CHAIN_CONTRACT.md`
  - `EXTENSION_SYSTEM.md`

- Body/ForEach/view composition changes:
  - `VIEW_COMPOSITION.md`
  - `RUNTIME_MODEL.md`
  - `MUTATION_MODEL.md`

- State/binding/listener changes and State-companion assessment for new or
  materially changed fluent value setters:
  - `STATE_SYSTEM.md`
  - `FLUENT_CHAIN_CONTRACT.md`
  - add `MUTATION_MODEL.md` only through documented context-budget escalation
    when bidirectional, re-entrant, or multi-state mutation is in scope

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

- macOS `UList` rows backed by persistent TextKit 2 objects:
  - `MACOS_ULIST_NSTABLEVIEW.md`
  - `MACOS_ULIST_TEXTKIT2.md`
  - with mandatory `LAYER_MODEL.md`, this fills the default three-document
    budget; load another contract only through documented escalation

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

- Native Linux/Windows backend topology, implemented `UIKitPlusCore`/backend package boundaries, backend selection, owned binding/generator work, native-markup posture, or backend dependency isolation:
  - `NATIVE_BACKENDS.md`
  - `LAYER_MODEL.md`
  - add `PLATFORM_ABSTRACTION.md` or the impacted domain owner only when the task changes those contracts

## Governance and Debt Routing

- Development flow:
  - `.agent/WORKFLOW.md`
  - `.agent/DEVELOPMENT_PHASES.md`

- Model-independent LLM/coding-agent orchestration:
  - `.agent/DEVELOPMENT_ORCHESTRATION.md`
  - `.agent/ARTIFACTS_WORKFLOW.md`

- Source ownership and navigation:
  - `.agent/SOURCE_MAP.md`

- Technical debt and future refactor candidates:
  - `.agent/TECH_DEBT.md`

- Commit rules and message style:
  - `.agent/COMMIT_RULES.md`

- Validation rules:
  - `.agent/VALIDATION_RULES.md`

- Lazy durable public-content capture:
  - `.agent/PUBLIC_CONTENT_IDEAS.md`
  - `.agent/public-content-ideas/**` only after a positive capture check or for explicit public-content work

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
- `UTK*` -> `MACOS_ULIST_TEXTKIT2.md`
- `WT*` -> `MACOS_WINDOW_TABS.md`
- `NB*` -> `NATIVE_BACKENDS.md`
