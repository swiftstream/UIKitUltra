# Architecture Index

Authoritative routing and architecture-ID ownership index for UIKitUltra. Keep context minimal and layer-aware. This is a router: load only the owner needed for the current task.

Operational development authorities are routed separately from technical architecture:

- canonical repository/package/module/backend naming: `PRODUCT_IDENTITY.md`;
- workflow: `WORKFLOW.md`;
- coordinator/executor roles and independent review gates: `DEVELOPMENT_ORCHESTRATION.md`;
- linked-worktree/parallel-lane hierarchy and integration ownership: `PARALLEL_DEVELOPMENT.md`;
- transient research/plan/task/report/handoff mechanics: `ARTIFACTS_WORKFLOW.md`;
- Git/staging/commit safety: `COMMIT_RULES.md`;
- progressive loading: `CONTEXT_LOADING_RULES.md`;
- source navigation: `SOURCE_MAP.md`;
- lazy durable README/docs/website/publication idea capture: `PUBLIC_CONTENT_IDEAS.md` plus focused `.agent/public-content-ideas/**` shards. Do not load during ordinary development unless the capture check is positive or the task is explicitly public-content work.

Operational workflow/artifact/public-content owners do not consume architecture-doc slots.

## Loading Protocol

1. Identify the task type and select **one primary architecture owner** below.
2. Load that owner.
3. Add up to two supporting architecture docs only if the task actually crosses their boundaries; `LAYER_MODEL.md` is normally a support doc for cross-layer work, not an automatic read.
4. Stop at decision-complete context.

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
  - `.agent/architecture/NATIVE_BACKENDS.md` for UIKitUltra GTK/Qt/Win/Android/TUI backend topology, explicit module/import boundaries, owned bridge/runtime architecture, dependency isolation, semantic promotion, and support-gating rules

- UIKitUltra application architecture:
  - `.agent/architecture/APPLICATION_STATE_OWNERSHIP.md`

- macOS native window tabs, lazy content, native detach/reattach, topology
  state, source-array moves, and concrete state-binding overloads:
  - `.agent/architecture/MACOS_WINDOW_TABS.md` (implementation is split across
    `MacOS+WindowTabTopology.swift`, `MacOS+WindowTabRuntime.swift`,
    `MacOS+WindowTab.swift`, `MacOS+WindowTabForEach.swift`, and
    `MacOS+WindowTabGroup.swift`)

## Domain Routing

- Product/package/module/trait/backend naming:
  - Primary: `.agent/PRODUCT_IDENTITY.md`.
  - Add `NATIVE_BACKENDS.md` only when backend architecture/support/inheritance is also in scope.

- Declarative protocol / chain API:
  - Primary: `DECLARATIVE_PROTOCOL.md` or `FLUENT_CHAIN_CONTRACT.md`, depending on which contract changes.
  - Support only when needed: `EXTENSION_SYSTEM.md` or the other contract.

- Body / `ForEach` / view composition:
  - Primary: `VIEW_COMPOSITION.md`.
  - Support only when needed: `RUNTIME_MODEL.md` for lifecycle/diffs or `MUTATION_MODEL.md` for callback/re-entrancy behavior.

- State / binding / listener changes:
  - Primary: `STATE_SYSTEM.md`.
  - Support only when needed: `FLUENT_CHAIN_CONTRACT.md` for public setter shape, `MUTATION_MODEL.md` for bidirectional/re-entrant flows, or `RUNTIME_MODEL.md` for lifecycle/deferred behavior.

- Application state placement / View/ViewController ownership / child dependency contracts / app-wide environment:
  - Primary: `APPLICATION_STATE_OWNERSHIP.md`.
  - Support only when needed: `STATE_SYSTEM.md` or `VIEW_COMPOSITION.md`.

- Constraint/layout changes:
  - Primary: `LAYOUT_SYSTEM.md`.
  - Support only when needed: `RUNTIME_MODEL.md` or `MUTATION_MODEL.md`.

- macOS `UList` / `NSTableView` hosting, sizing, recycling, scrolling, live resize:
  - Primary: `MACOS_ULIST_NSTABLEVIEW.md`.
  - Support only when needed: `RUNTIME_MODEL.md`, `LAYOUT_SYSTEM.md`, or `MUTATION_MODEL.md`.

- Persistent TextKit 2 `UList` rows:
  - Primary: `MACOS_ULIST_TEXTKIT2.md`.
  - Add `MACOS_ULIST_NSTABLEVIEW.md` when table-host integration matters; add another contract only through normal budget escalation.

- Gesture wrapper/delegation:
  - Primary: `GESTURE_SYSTEM.md`.
  - Support only when needed: `EXTENSION_SYSTEM.md`, `MUTATION_MODEL.md`, or `PLATFORM_ABSTRACTION.md`.

- Navigation behavior:
  - Primary: `NAVIGATION_SYSTEM.md`.
  - Support only when needed: `RUNTIME_MODEL.md` or `PLATFORM_ABSTRACTION.md`.

- UIKit/AppKit bridge behavior:
  - Primary: `PLATFORM_ABSTRACTION.md`.
  - Add `LAYER_MODEL.md` or the impacted domain owner only when that boundary is actually in scope.

- Native backend topology/import boundaries/selection/owned bridges/dependency isolation, GTK/Qt/Win/Android/TUI architecture, or cross-backend semantic promotion:
  - Primary: `NATIVE_BACKENDS.md`; prefer section/ID reads for backend-specific work rather than full-file preload.
  - Common module/import/autocomplete: `NB1`, `NB4`, `NB15`.
  - Native authority/inheritance: `NB2`, `NB13`.
  - Layout/list lowering: `NB9` + `LAYOUT_SYSTEM.md` only when layout is actually in scope.
  - Win: `NB11`; Android: `NB17` (+ `NB19` only for shared-State questions); TUI: `NB18`.
  - Parallel-lane ownership: `NB10`, `NB20` + `PARALLEL_DEVELOPMENT.md` only when linked worktrees are actually in scope.
  - Add `PLATFORM_ABSTRACTION.md` or `LAYER_MODEL.md` only when that specific boundary is actually in scope.

## Governance and Debt Routing

- Development flow:
  - `.agent/WORKFLOW.md`
  - `.agent/DEVELOPMENT_PHASES.md`

- Model-independent LLM/coding-agent orchestration:
  - `.agent/DEVELOPMENT_ORCHESTRATION.md`
  - `.agent/PARALLEL_DEVELOPMENT.md` when linked worktrees/parallel lanes are in scope
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

- Shared State-package convergence/migration planning:
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
