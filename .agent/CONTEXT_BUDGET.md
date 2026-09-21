# Context Budget

Token discipline is mandatory for stable agent behavior.

## Target Budget

- Typical task context: `3000-7000` tokens when the task can safely fit there.

## Loading Priority

1. Root routing (`AGENTS.md`).
2. Operational orchestration/artifact owners only for non-trivial iterative work.
3. `ARCH_INDEX.md` to select one primary architecture owner.
4. That primary owner, plus up to two supporting architecture docs only when needed.
5. Targeted source reads; use `SOURCE_MAP.md` only when source location/ownership is unclear.
6. One relevant skill/template only when useful.
7. Parallel-worktree, task/history/debt, public-content, and artifact context only when the current task explicitly routes there.

## Budget Rules

- Authority hierarchy is conflict resolution, not a preload list.
- Keep active architecture docs <= 3 by default: 1 primary owner + at most 2 supporting docs.
- `DEVELOPMENT_ORCHESTRATION.md` and `ARTIFACTS_WORKFLOW.md` are operational workflow docs and do not consume architecture-doc slots, but load them only for non-trivial iterative work.
- `PARALLEL_DEVELOPMENT.md` is cold context unless linked worktrees/parallel lanes are actually in scope.
- `PROJECT_MEMORY.md`, task/debt/history docs, public-content docs, and `.artifacts/**` are lazy; load only the exact current-state/history/artifact slice required by the task.
- Prefer section/range reads of long architecture owners when `ARCH_INDEX`/architecture IDs already identify the relevant contract; full-owner reads are for genuinely cross-cutting work.
- Avoid full-file source reads when symbol/section-level reads are enough.
- Do not preload all skills/templates or re-read already loaded docs without a concrete reason.
- Prefer incremental context growth and stop at decision-complete context.

## Safety Override

If the budget must be exceeded for a cross-cutting architecture/governance audit or safety-critical task, load the smallest additional context required and record why in the relevant plan/audit artifact.
