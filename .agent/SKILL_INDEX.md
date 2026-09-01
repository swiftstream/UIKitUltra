# Skill Index

Use this index to route implementation tasks to the minimum required architecture context.

## Load Policy

1. Load `AGENTS.md`.
2. Load `.agent/ARCH_INDEX.md`.
3. Load `.agent/architecture/LAYER_MODEL.md`.
4. Load one domain doc and one contract doc.
5. Load one skill doc.

Default maximum active architecture docs: `3`.

## Task Routing

- View composition and builder integration:
  - Architecture: `VIEW_COMPOSITION.md`, `RUNTIME_MODEL.md`, `MUTATION_MODEL.md`
  - Contract: `FLUENT_CHAIN_CONTRACT.md`
  - Skill: `.agent/skills/view-composition/SKILL.md`

- Constraint and layout DSL updates:
  - Architecture: `LAYOUT_SYSTEM.md`, `RUNTIME_MODEL.md`, `MUTATION_MODEL.md`
  - Contract: `STATE_SYSTEM.md` when state-backed constants are involved
  - Skill: `.agent/skills/constraint-system/SKILL.md`

- State and binding updates, including State-surface classification for every
  new or materially changed fluent value setter:
  - Architecture: `STATE_SYSTEM.md`
  - Contract: `FLUENT_CHAIN_CONTRACT.md`
  - Escalate selectively to `MUTATION_MODEL.md` for bidirectional/re-entrant
    mutation or `RUNTIME_MODEL.md` for lifecycle/deferred behavior
  - Skill: `.agent/skills/state-binding/SKILL.md`

- Gesture wrapper/integration updates:
  - Architecture: `GESTURE_SYSTEM.md`, `MUTATION_MODEL.md`, `PLATFORM_ABSTRACTION.md`
  - Contract: `EXTENSION_SYSTEM.md` and `FLUENT_CHAIN_CONTRACT.md`
  - Skill: `.agent/skills/gesture-integration/SKILL.md`

- Navigation flow updates:
  - Architecture: `NAVIGATION_SYSTEM.md`, `RUNTIME_MODEL.md`, `PLATFORM_ABSTRACTION.md`
  - Contract: `FLUENT_CHAIN_CONTRACT.md`
  - Skill: `.agent/skills/navigation-flow/SKILL.md`

- macOS `UList` / `NSTableView`, row hosting, self-sizing, recycling,
  scrolling, automatic heights, or live resize:
  - Architecture: `MACOS_ULIST_NSTABLEVIEW.md`
  - TextKit 2 rows: load `MACOS_ULIST_TEXTKIT2.md`; do not also load a
    supporting contract without documented context-budget escalation
  - Other rows: supporting contract is at most one of `RUNTIME_MODEL.md`,
    `LAYOUT_SYSTEM.md`, or `MUTATION_MODEL.md`, selected by the task
  - Skill: `.agent/skills/macos-ulist/SKILL.md`

- General rendered UIKit/AppKit/UIKitPlus diagnosis when visibility, clipping,
  native ownership, viewport reach, resize behavior, or actual rendered
  boundaries are ambiguous from source/logs/geometry alone:
  - Architecture: keep the primary owner already selected for the defect;
    add at most one supporting contract only when needed to interpret evidence
  - Skill: `.agent/skills/uikitplus-visual-ui-diagnostics/SKILL.md`
  - Use this as a dedicated diagnostic/verification-step skill. It replaces the
    implementation skill for that step rather than being loaded as a second
    operational skill.

## Governance Routing

- Source ownership:
  - `.agent/SOURCE_MAP.md`

- Technical debt:
  - `.agent/TECH_DEBT.md`

- Commit rules:
  - `.agent/COMMIT_RULES.md`

- Validation rules:
  - `.agent/VALIDATION_RULES.md`

## State/Layout-Sensitive Minimum Contracts

For any task that changes state propagation, layout activation, or binding flows, always include:
- `STATE_SYSTEM.md`
- `FLUENT_CHAIN_CONTRACT.md`
- `RUNTIME_MODEL.md`
- `MUTATION_MODEL.md`
