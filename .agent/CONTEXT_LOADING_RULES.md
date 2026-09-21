# Context Loading Rules

Mandatory progressive-loading discipline for UIKitUltra agent work. The goal is decision-complete context, not complete-document awareness.

## Default Budget

For normal work:

- load **1 primary architecture owner** plus at most **2 supporting architecture docs** only when genuinely needed;
- `LAYER_MODEL.md` is normally one of those docs when cross-layer boundaries matter, but do not load it mechanically for a narrowly self-contained owner task;
- load **at most 1 operational skill** by default;
- inspect the **smallest relevant source subset**;
- do not bulk-load `.agent/architecture/**`, `.agent/skills/**`, templates, artifacts, task/debt/history files, or external repositories.

## Loading Sequence

1. Read root `AGENTS.md`.
2. If work is non-trivial iterative LLM/coding-agent development, load `DEVELOPMENT_ORCHESTRATION.md` and `ARTIFACTS_WORKFLOW.md`; otherwise do not load them merely because they exist.
3. Load `PARALLEL_DEVELOPMENT.md` only when linked worktrees/parallel lanes are actually in scope.
4. Use `ARCH_INDEX.md` to identify the **primary** architecture owner.
5. Load that primary owner. For a long owner with known architecture IDs/section headings, prefer the smallest decision-complete section/range plus any explicitly referenced invariants; full-file read is not mandatory. Add up to two supporting architecture docs only when the task actually crosses their boundaries.
6. Load `STYLE_GUIDELINES.md`, `DSL_SAFETY_RULES.md`, and/or `EXTENSION_RULES.md` only when the edit type needs them; these policy docs do not replace architecture owners.
7. Use `SKILL_INDEX.md` only when a concrete operational procedure applies; load at most one skill by default. A dedicated verification step may switch skills rather than keeping both loaded.
8. Use `SOURCE_MAP.md` only when source ownership/location is not already obvious, then inspect only the exact source/test/project files required.
9. Load `PROJECT_MEMORY.md`, `TASKS.md`, `TECH_DEBT.md`, `TASKS_ARCHIVE.md`, `STATE_VNEXT_PLAN.md`, or similar durable-state files only when the current task actually needs their state/history; they are not startup context.
10. Treat `PUBLIC_CONTENT_IDEAS.md` and `.agent/public-content-ideas/**` as lazy communication context, not normal development context. Load only after a positive capture check or for explicit public-content work.
11. Load `.artifacts/**` only for the **active** planning/execution/audit/handoff lineage. Do not bulk-load old research, old task waves, or sibling lane artifacts.
12. Stop loading once ownership, contract, scope, and required evidence are clear. Do not re-read already loaded documents without a concrete reason.

## Recommended Architecture Slice

Typical source work uses one primary owner and only the supporting contracts needed to decide the task. `LAYER_MODEL.md` is useful for cross-layer changes but is not a ceremonial mandatory read for every narrowly scoped task.

Default architecture-doc budget remains `<= 3` total.

Application state-placement/refactor work routes through `APPLICATION_STATE_OWNERSHIP.md` and its `AO*` invariants.

## Source Navigation Rule

Use `SOURCE_MAP.md` before broad discovery when source ownership/location is unclear. Skip it when the exact target source is already known. Update it only when durable source topology/ownership changes.

## Escalation

Broader context is allowed for genuinely cross-cutting architecture/documentation migrations or audits. State why the normal budget is insufficient, load the smallest extra set, then return to focused routing afterward.

The budget is a discipline, not permission to ignore a clearly relevant owner merely to stay under a number.
