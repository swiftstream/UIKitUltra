# Skill Index

Use this index to route implementation tasks to the minimum required architecture context.

## Load Policy

1. Start from `AGENTS.md` and `.agent/ARCH_INDEX.md` routing.
2. Keep the already selected primary architecture owner.
3. Add supporting architecture docs only when the task actually needs them; default maximum remains `3` total.
4. Load **one** skill only when a concrete operational procedure applies.

This index is a router, not a preload checklist. Do not load every architecture file mentioned under a task family.

## Task Routing

- View composition and builder integration:
  - Primary: `VIEW_COMPOSITION.md`
  - Support only when needed: `RUNTIME_MODEL.md` for lifecycle/diff behavior, `MUTATION_MODEL.md` for callback/re-entrancy, `FLUENT_CHAIN_CONTRACT.md` for public chain surface
  - Skill: `.agent/skills/view-composition/SKILL.md`

- Constraint and layout DSL updates:
  - Primary: `LAYOUT_SYSTEM.md`
  - Support only when needed: `RUNTIME_MODEL.md`, `MUTATION_MODEL.md`, or `STATE_SYSTEM.md` for state-backed constants
  - Skill: `.agent/skills/constraint-system/SKILL.md`

- State and binding updates, including State-surface classification for new/materially changed fluent value setters:
  - Primary: `STATE_SYSTEM.md`
  - Support only when needed: `FLUENT_CHAIN_CONTRACT.md`, `MUTATION_MODEL.md` for bidirectional/re-entrant mutation, or `RUNTIME_MODEL.md` for lifecycle/deferred behavior
  - Skill: `.agent/skills/state-binding/SKILL.md`

- Gesture wrapper/integration updates:
  - Primary: `GESTURE_SYSTEM.md`
  - Support only when needed: `MUTATION_MODEL.md`, `PLATFORM_ABSTRACTION.md`, `EXTENSION_SYSTEM.md`, or `FLUENT_CHAIN_CONTRACT.md`
  - Skill: `.agent/skills/gesture-integration/SKILL.md`

- Navigation flow updates:
  - Primary: `NAVIGATION_SYSTEM.md`
  - Support only when needed: `RUNTIME_MODEL.md`, `PLATFORM_ABSTRACTION.md`, or `FLUENT_CHAIN_CONTRACT.md`
  - Skill: `.agent/skills/navigation-flow/SKILL.md`

- macOS `UList` / `NSTableView`, row hosting, self-sizing, recycling,
  scrolling, automatic heights, or live resize:
  - Architecture: `MACOS_ULIST_NSTABLEVIEW.md`
  - TextKit 2 rows: load `MACOS_ULIST_TEXTKIT2.md`; do not also load a
    supporting contract without documented context-budget escalation
  - Other rows: supporting contract is at most one of `RUNTIME_MODEL.md`,
    `LAYOUT_SYSTEM.md`, or `MUTATION_MODEL.md`, selected by the task
  - Skill: `.agent/skills/macos-ulist/SKILL.md`

- General rendered UIKit/AppKit/UIKitUltra diagnosis when visibility, clipping,
  native ownership, viewport reach, resize behavior, or actual rendered
  boundaries are ambiguous from source/logs/geometry alone:
  - Architecture: keep the primary owner already selected for the defect;
    add at most one supporting contract only when needed to interpret evidence
  - Skill: `.agent/skills/uikitultra-visual-ui-diagnostics/SKILL.md`
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

## State/Layout-Sensitive Routing

Do not load a fixed four-document bundle.

- State semantics -> `STATE_SYSTEM.md` primary.
- Layout semantics -> `LAYOUT_SYSTEM.md` primary.
- Add `FLUENT_CHAIN_CONTRACT.md` only when public fluent shape changes.
- Add `RUNTIME_MODEL.md` only for lifecycle/deferred execution questions.
- Add `MUTATION_MODEL.md` only for bidirectional/re-entrant/multi-state mutation.

Stay within the default three-architecture-doc budget unless a documented escalation is genuinely required.
