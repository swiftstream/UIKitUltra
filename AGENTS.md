# UIKitUltra - Agent Governance

## Repository Identity

UIKitUltra is the canonical repository/package/framework brand; the canonical public Swift library/module is `Ultra`. The repository migrated from the legacy `UIKitPlus` name; that rename is historical migration context rather than an active identity transition. The existing public `U*` prefix is retained and means **Ultra**. Naming authority: `.agent/PRODUCT_IDENTITY.md`.

UIKitUltra is a declarative, protocol-oriented UI framework whose Apple implementation remains built directly on UIKit/AppKit and whose accepted expansion architecture targets additional real-native backends plus an owned TUI runtime. Backend naming/architecture is routed through `ARCH_INDEX.md`; one-time rename mechanics stay in `.artifacts/**`.

Core characteristics:
- fluent `Self`-returning API composition;
- extension-driven feature growth;
- reference-semantic reactive state (`State`, `InnerState`, mapped/bound states);
- deferred/state-backed layout constraints;
- explicit UIKit/AppKit platform bridges;
- native-platform behavior as the preferred implementation substrate.

Architecture is frozen by default. Contract-changing architecture work requires explicit maintainer approval.

## Authority Hierarchy

When stable documents conflict, higher authority wins. **This hierarchy is for conflict resolution, not a preload list; do not read every owner by default.**

1. `.agent/SYSTEM_RULES.md` - global operational/engineering invariants.
2. `.agent/WORKFLOW.md`, `.agent/DEVELOPMENT_ORCHESTRATION.md`, `.agent/PARALLEL_DEVELOPMENT.md` when linked worktrees are actually in scope, `.agent/ARTIFACTS_WORKFLOW.md`, and `.agent/COMMIT_RULES.md` - development/orchestration/worktree/artifact/Git workflow.
3. `.agent/PRODUCT_IDENTITY.md` for canonical brand/module naming, then `.agent/ARCH_INDEX.md` and the owning `.agent/architecture/*.md` files for technical architecture and architecture-ID authority.
4. `.agent/STYLE_GUIDELINES.md`, `.agent/DSL_SAFETY_RULES.md`, `.agent/EXTENSION_RULES.md`, and applicable focused policy/skill docs - implementation conventions inside architecture boundaries.
5. `.agent/PROJECT_MEMORY.md` and `.agent/SOURCE_MAP.md` - durable current-state/navigation facts.
6. `.agent/TASKS.md`, `.agent/TODO.md`, `.agent/TECH_DEBT.md`, `.agent/TASKS_ARCHIVE.md`, and `.agent/STATE_VNEXT_PLAN.md` - active work, future work, debt, history, and State planning.
7. `.agent/CONTEXT_LOADING_RULES.md`, `.agent/CONTEXT_BUDGET.md`, `.agent/PUBLIC_CONTENT_IDEAS.md`, `.agent/SKILL_INDEX.md`, `.agent/skills/*`, `.agent/TEMPLATE_INDEX.md`, and `.agent/templates/*` - progressive routing and focused operational guidance.

`.artifacts/**` is disposable Git-ignored working memory and never stable authority.

Architecture owners win on UIKitUltra semantics. Link to owners instead of duplicating full contracts in routing/workflow docs.

## Mandatory Development Workflow

**PLAN -> IMPLEMENT -> AUDIT**

- Non-trivial work requires current-repository research and a reviewed plan before production mutation.
- Use `.agent/DEVELOPMENT_PHASES.md` for UIKitUltra-specific phase mechanics.
- For non-trivial iterative LLM-assisted work, load `.agent/DEVELOPMENT_ORCHESTRATION.md` and `.agent/ARTIFACTS_WORKFLOW.md`.
- Large/cognitively dense implementation or correction work is decomposed into numbered surgical task files; detailed mechanics stay in those files and the executor receives one short coordinator prompt.
- Executor reports are evidence, never proof. Independently inspect actual source/diff/Git and relevant architecture owners.
- If a materially reviewed assumption fails during implementation, stop that path and re-plan rather than silently widening scope.
- Commit and push are separate explicit gates; passing AUDIT does not authorize either.

## UIKitUltra Engineering Routing

For source/API work:

1. Use `.agent/ARCH_INDEX.md` to select **one primary architecture owner**.
2. Add at most two supporting architecture docs only when the task actually crosses those boundaries; `LAYER_MODEL.md` is not a ceremonial mandatory read.
3. Inspect analogous existing UIKitUltra source before designing a new approach; consult legacy UIKitPlus history only when it is actually relevant.
4. Preserve the native-first two-stage pattern where applicable: thin native/backend wrapper first, UIKitUltra convenience layer second.
5. Preserve fluent/reference/state/extension/platform invariants owned by the selected architecture docs.

Application state-placement work additionally routes through `.agent/architecture/APPLICATION_STATE_OWNERSHIP.md` and its `AO*` invariants.

## Mandatory Context Budget

Normal work:
- starts here;
- uses `ARCH_INDEX.md` to select one primary architecture owner;
- keeps at most 3 active architecture docs by default: that primary owner plus at most 2 supporting docs only when genuinely needed;
- loads at most one operational skill by default;
- uses `SOURCE_MAP.md` only when source ownership/location is not already obvious;
- treats `PROJECT_MEMORY.md`, task/debt/history files, parallel-worktree rules, public-content docs, and `.artifacts/**` as lazy context;
- inspects the smallest relevant source subset and stops loading at decision-complete context.

Operational orchestration/artifact docs do not consume architecture-doc slots, but they are not automatic startup reads. Public-content shards are lazy and must not be loaded "just in case".

Cross-cutting governance/architecture audits may deliberately exceed the default budget. Full rules: `.agent/CONTEXT_LOADING_RULES.md` and `.agent/CONTEXT_BUDGET.md`.

## Documentation Self-Maintenance

- Stable docs must match current implementation and reviewed architecture.
- Architecture IDs have one authoritative owner; cite instead of restating alternate full rules.
- Update only docs whose owned durable fact actually changed.
- Keep transient execution history, local tool IDs, temporary logs, and task-specific evidence in `.artifacts/**`, not stable governance.
- If `.artifacts/**` disappears, reconstruct current working context from stable docs + Git + actual source; never invent lost evidence.

After meaningful research/design/implementation/correction/audit, perform the lazy capture check owned by `.agent/PUBLIC_CONTENT_IDEAS.md`. Open the bank only when genuinely valuable README/docs/website/release/migration/publication material was discovered, then load only the relevant shard.

## Git Safety

Follow `.agent/COMMIT_RULES.md`.

Preserve unrelated staged, unstaged, and untracked user work. Never stage, commit, amend, reset, restore, clean, stash, rebase/merge, or push unless the maintainer's instruction explicitly authorizes that exact operation/scope.

`.artifacts/**` must never be staged or committed. The project-specific push lock remains in force until its stable prerequisites are satisfied and the maintainer explicitly authorizes push.

## Task / Durable State

- `TASKS.md` owns active governance-tracked work.
- `TASKS_ARCHIVE.md` owns compact completed-task history when worth retaining.
- `PROJECT_MEMORY.md` owns durable current facts useful beyond immediate source/Git inspection.
- `TODO.md` owns low-priority future ideas.
- `TECH_DEBT.md` owns verified debt.
- `STATE_VNEXT_PLAN.md` owns shared State-package convergence/migration planning.

Do not use `.artifacts/NEW_CHAT.md` as permanent project memory. It is only transient continuation context for the next coordinator/reviewer conversation.
