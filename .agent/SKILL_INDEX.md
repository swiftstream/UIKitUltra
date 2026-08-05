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
  - Skill: `.agent/skills/view_composition_skill.md`

- Constraint and layout DSL updates:
  - Architecture: `LAYOUT_SYSTEM.md`, `RUNTIME_MODEL.md`, `MUTATION_MODEL.md`
  - Contract: `STATE_SYSTEM.md` when state-backed constants are involved
  - Skill: `.agent/skills/constraint_system_skill.md`

- State and binding updates:
  - Architecture: `STATE_SYSTEM.md`, `MUTATION_MODEL.md`, `RUNTIME_MODEL.md`
  - Contract: `FLUENT_CHAIN_CONTRACT.md`
  - Skill: `.agent/skills/state_binding_skill.md`

- Gesture wrapper/integration updates:
  - Architecture: `GESTURE_SYSTEM.md`, `MUTATION_MODEL.md`, `PLATFORM_ABSTRACTION.md`
  - Contract: `EXTENSION_SYSTEM.md` and `FLUENT_CHAIN_CONTRACT.md`
  - Skill: `.agent/skills/gesture_integration_skill.md`

- Navigation flow updates:
  - Architecture: `NAVIGATION_SYSTEM.md`, `RUNTIME_MODEL.md`, `PLATFORM_ABSTRACTION.md`
  - Contract: `FLUENT_CHAIN_CONTRACT.md`
  - Skill: `.agent/skills/navigation_flow_skill.md`

- macOS `UList` / `NSTableView`, row hosting, self-sizing, recycling,
  scrolling, automatic heights, or live resize:
  - Architecture: `MACOS_ULIST_NSTABLEVIEW.md`
  - Supporting contract: at most one of `RUNTIME_MODEL.md`,
    `LAYOUT_SYSTEM.md`, or `MUTATION_MODEL.md`, selected by the task
  - Skill: `.agent/skills/macos_ulist_skill.md`

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
