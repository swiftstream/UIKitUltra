# Context Loading Rules

Mandatory progressive-loading discipline for UIKitPlus agent work.

## Default Budget

For normal work:

- load `LAYER_MODEL.md` plus the smallest decision-complete domain/contract set;
- keep **at most 3 active architecture docs** by default;
- load **at most 1 operational skill** by default;
- inspect the **smallest relevant source subset**;
- do not bulk-load `.agent/architecture/**`, `.agent/skills/**`, templates, artifacts, or external repositories.

## Loading Sequence

1. Read root `AGENTS.md`.
2. If work is non-trivial iterative LLM/coding-agent development, load `DEVELOPMENT_ORCHESTRATION.md` and `ARTIFACTS_WORKFLOW.md`. These are operational docs and do not consume architecture-doc slots.
3. Use `ARCH_INDEX.md` to identify the relevant layer/domain/contract owners.
4. Load `architecture/LAYER_MODEL.md`.
5. Load only the domain/contract architecture docs needed to reach a decision, keeping the default total at 3.
6. Load `STYLE_GUIDELINES.md`, `DSL_SAFETY_RULES.md`, and/or `EXTENSION_RULES.md` only when the edit type needs them; these policy docs do not replace architecture owners.
7. Use `SKILL_INDEX.md` only when a concrete operational procedure applies; load at most one skill by default. A dedicated verification step may switch from the implementation skill to `.agent/skills/uikitplus-visual-ui-diagnostics/SKILL.md`; do not keep both loaded merely because the parent task used an implementation skill.
8. Use `SOURCE_MAP.md` before broad source discovery, then inspect only the exact source/test/project files required.
9. Treat `PUBLIC_CONTENT_IDEAS.md` and `.agent/public-content-ideas/**` as lazy communication context, not normal development context. First perform the capture check from current work. Only if positive, or if the task explicitly concerns README/public docs/website docs/release notes/migration guides/articles/posts, load the router and exactly the relevant shard(s). These files do not consume architecture-doc slots.
10. Load `.artifacts/**` only for the active planning/execution/audit/handoff step. Do not bulk-load all task files; an executor reads the next numbered task immediately before execution.
11. Stop loading when ownership, design contract, scope, and required evidence are sufficient.

## Recommended Architecture Slice

Typical source work uses:

- `LAYER_MODEL.md`;
- one domain owner such as `STATE_SYSTEM.md`, `LAYOUT_SYSTEM.md`, `VIEW_COMPOSITION.md`, `MACOS_ULIST_NSTABLEVIEW.md`, or `MACOS_WINDOW_TABS.md`;
- one supporting contract such as `FLUENT_CHAIN_CONTRACT.md`, `EXTENSION_SYSTEM.md`, `RUNTIME_MODEL.md`, `MUTATION_MODEL.md`, or `PLATFORM_ABSTRACTION.md`.

Do not force this shape when the task genuinely needs a different focused combination.

Application state-placement/refactor work routes through `APPLICATION_STATE_OWNERSHIP.md` and its `AO*` invariants.

## Source Navigation Rule

For source tasks, read `SOURCE_MAP.md` after architecture routing. Use it to identify likely owners before broad grep or broad file reads. Update it only when durable source topology/ownership changes.

## Escalation

Broader context is allowed for genuinely cross-cutting architecture/documentation migrations or audits. State why the normal budget is insufficient, load the smallest extra set, then return to focused routing afterward.

The budget is a discipline, not permission to ignore a clearly relevant owner merely to stay under a number.
