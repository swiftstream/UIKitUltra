# Technical Debt Register

Stable register of known technical debt and future refactoring candidates.

This file is important project context for humans and LLM agents. Read it when planning refactors, architecture cleanup, or source-ownership work.

This file is not a transient bug log, test-failure log, or changelog. Only record stable debt that is likely to matter beyond the current task.

---

## Update Rule

Update this file when:
- a large file becomes a future refactoring candidate;
- a file mixes multiple stable responsibilities;
- a refactor intentionally leaves a known follow-up;
- ownership boundaries are documented but not compiler-enforced;
- a temporary architecture compromise is accepted for later cleanup.

Do not update this file for:
- transient build/test failures;
- temporary debugging notes;
- one-off implementation mistakes fixed in the same task;
- speculative ideas without clear source ownership impact.

---

## Severity Guide

- `Critical` — blocks safe continuation of the current path or can mislead future agents badly.
- `High` — important source ownership, navigation, validation, or maintainability debt.
- `Medium` — should be addressed when touching the area or during a nearby refactor.
- `Low` — tracked for awareness; not urgent.

---

## Current Debt

### TD-001 — Independent audit of 52 local commits required before push

- Status: Open
- Severity: Critical
- Area: Governance / Push Safety
- Files:
  - `AGENTS.md`
  - `.agent/TASKS.md`
- Issue:
  - 52 commits have accumulated locally on `master` ahead of `origin/master`.
  - No independent audit has been performed on these commits.
  - Push is locked until audit is accepted.
- Risk:
  - Pushing unaudited commits may introduce regressions, broken tests, or architecture drift.
- Suggested direction:
  - Perform independent commit-scope audit of all 52 local commits.
  - Classify each commit: safe, risky, or regression.
  - Fix or explicitly defer any critical regressions before push.
- Non-goals for this docs-closure chat:
  - Not auditing commits now.
  - Not pushing.

### TD-002 — Swift 6 strict concurrency migration pending

- Status: Deferred
- Severity: High
- Area: Swift 6 / Concurrency
- Files:
  - `.agent/STATE_VNEXT_PLAN.md` (§5)
- Issue:
  - UIKitPlus is not yet Swift 6 strict-concurrency compatible.
  - `@State` needs `@MainActor` isolation, `Value: Sendable`, and closure Sendability annotations.
  - Open question: `open class State` vs `final class State`.
- Risk:
  - Delayed migration accumulates more source debt.
  - Swift 6 language mode may produce new warnings or errors.
- Suggested direction:
  - Complete governance docs commit first.
  - Complete 52-commit audit.
  - Then begin Swift 6 strict concurrency migration following `STATE_VNEXT_PLAN.md` §5.
- Non-goals for this docs-closure chat:
  - Not starting Swift 6 migration.
  - Not editing Swift source.

### TD-003 — State vNext deferred/global architecture debt

- Status: Deferred
- Severity: High
- Area: State Architecture
- Files:
  - `.agent/STATE_VNEXT_PLAN.md`
- Issue:
  - UIKitPlus `@State` diverges from desired DX (missing `listenDistinct`, `StateValuable`, `removeListeners()`, multi-state `.and(...)` chain).
  - `.holdIfOwned(by:)` appears in implementation; public API should use only `.hold(in:)`.
  - This is global cross-framework debt shared with SwifDroid and SwifWeb.
- Risk:
  - Continued DX divergence across frameworks.
  - Internal routing helpers leak into public mental model.
- Suggested direction:
  - After Swift 6 migration, write State ADR.
  - Implement State vNext in standalone State package.
  - Migrate UIKitPlus to shared State package.
- Non-goals for this docs-closure chat:
  - Not implementing State vNext.
  - Not editing Swift state source.

### TD-004 — .artifacts planning facts must be promoted before artifacts are discarded

- Status: Open
- Severity: Medium
- Area: Documentation / Artifacts
- Files:
  - `.artifacts/planning/PLAN-UI.md`
  - `.agent/TECH_DEBT.md`
- Issue:
  - `.artifacts/planning/PLAN-UI.md` contains exhaustive listener audit inventory (78 call sites).
  - This is transient planning data but the audit inventory is durable project knowledge.
  - `.artifacts/**` is transient and must never be committed.
- Risk:
  - If `.artifacts/` is deleted before promotion, durable audit facts are lost.
- Suggested direction:
  - Promote durable audit findings to `.agent/TECH_DEBT.md` or architecture docs before discarding `.artifacts/`.
  - Do not commit `.artifacts/**`.
- Non-goals for this docs-closure chat:
  - Not promoting artifacts now (separate task).

### TD-005 — 5L2 dynamic hidden-row behavior deferred

- Status: Deferred
- Severity: Low
- Area: List / Collection
- Files:
  - `Classes/Views/Not-MacOS/List.swift`
  - `Classes/Views/Not-MacOS/Collection.swift`
- Issue:
  - Dynamic hidden-row behavior was identified as deferred in the listener audit.
  - Currently not runtime-reachable with existing concrete conformers.
- Risk:
  - Low. Dead code path with no current impact.
- Suggested direction:
  - Design dynamic hidden-row behavior separately if it becomes needed. Do not resurrect the removed dead legacy `handleHiddency` path.
- Non-goals for this docs-closure chat:
  - Not editing List/Collection source.

### TD-006 — RISK-32 future MenuItem StateListener routing re-evaluation if tokens are added

- Status: Deferred
- Severity: Low
- Area: MenuItem / Controller
- Files:
  - `Classes/Controllers/MenuItem.swift`
- Issue:
  - MenuItem lifecycle baseline was completed (milestone 5M).
  - If MenuItem gains additional StateListener tokens in the future, routing must be re-evaluated.
- Risk:
  - Low for current state. Only relevant if MenuItem API surface expands.
- Suggested direction:
  - Monitor MenuItem for new listener registrations.
  - Route any new tokens through `stateBindingHolder`.
- Non-goals for this docs-closure chat:
  - Not modifying MenuItem source.

### TD-007 — RISK-24 AttrStr.Joined child-only recomposition needs targeted tests before repair

- Status: Deferred
- Severity: Low
- Area: AttributedString / Composition
- Files:
  - `Classes/Extensions/AttrStr+Joined.swift`
- Issue:
  - `AttrStr.Joined` child-only recomposition was identified as needing targeted tests before any repair.
  - Current behavior is documented but not tested.
- Risk:
  - Low for current state. Only relevant if AttributedString composition API changes.
- Suggested direction:
  - Add targeted tests for `AttrStr.Joined` recomposition before modifying behavior.
- Non-goals for this docs-closure chat:
  - Not adding tests or modifying AttributedString source.
