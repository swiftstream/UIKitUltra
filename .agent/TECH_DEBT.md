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

### TD-001 — Independent audit of current local commit required before push

- Status: Open — ready for fresh independent audit
- Severity: Critical
- Area: Governance / Push Safety
- Files:
  - `AGENTS.md`
  - `.agent/TASKS.md`
  - `.agent/STATE_VNEXT_PLAN.md`
- Issue:
  - The historical `52 local commits` push-gate count is no longer the live repository state.
  - Current post-M1 Git is `master...origin/master [ahead 1]`; the local push delta is the single audited-candidate M1 commit `9ded8fabc8ba0d2181d4a630ebc295599c27a87b` with parent `69c3aaaa7b8e040bc206d0e9243dc90c1f23cb11`.
  - The M1 pre-commit candidate audit chain is CLEAN after B01 closure, but the resulting local commit still requires its own fresh independent commit-scope audit before push.
  - Push remains locked until that audit is accepted and the maintainer separately authorizes push.
- Risk:
  - Pushing the local commit without a post-commit identity/scope audit could miss commit-construction drift, accidental path inclusion, or a mismatch between the audited staged candidate and the resulting Git object.
- Suggested direction:
  - Perform a fresh independent audit of exact `origin/master..HEAD` / `69c3aaaa… -> 9ded8fab…` commit scope.
  - Verify commit SHA/subject/parent, complete changed-path/content scope, accepted M1 audit lineage, absence of `.artifacts/**`, and clean post-commit repository state.
  - Fix or explicitly defer any material regression before push.
- Non-goals for this reconciliation:
  - Not pushing.
  - Not rewriting/amending the M1 commit.

### TD-002 — Swift 6 strict concurrency monitoring

- Status: Partially Resolved (S6)
- Severity: High
- Area: Swift 6 / Concurrency
- Files:
  - `.agent/STATE_VNEXT_PLAN.md` (§5)
- Issue:
  - UIKitUltra strict-concurrency diagnostics are currently clean.
  - `swift build -Xswiftc -strict-concurrency=complete` passes.
  - `swift test -Xswiftc -strict-concurrency=complete` passes (286 tests, 0 failures).
  - Zero State-related diagnostics found.
  - No immediate `@MainActor State`, `Value: Sendable`, or `@unchecked Sendable` implementation is required.
- Risk:
  - Low for now. Diagnostics are clean.
  - Revisit only if future Swift versions or API policy require deeper State changes.
- Suggested direction:
  - S6 accepted Option C first: keep `State<Value>` unconstrained.
  - The standalone maintainer-owned `State` repository is now the accepted shared-package destination; S7 should be a conformance/extraction audit + implementation plan, not another destination-choice ADR.
- Non-goals for this docs-closure chat:
  - Not implementing State concurrency changes.
  - Not editing Swift source.

### TD-003 — State vNext deferred/global architecture debt

- Status: Partially Resolved
- Severity: High
- Area: State Architecture
- Files:
  - `.agent/STATE_VNEXT_PLAN.md`
- Issue:
  - UIKitUltra `@State` previously diverged from desired DX and lifecycle conventions.
  - `listenDistinct`, `removeListeners()`, `StateValuable` minimal API, `CombinedState3...7`, `holdIfOwned(by:)` cleanup, and S6 concurrency envelope ADR/probe are resolved (S1-S6).
  - Remaining: audited extraction/conformance of the canonical implementation into `https://github.com/MihaelIsaev/State` (S7) and migration of consuming frameworks.
- Risk:
  - The destination package is decided, but source convergence/migration remains pending and current framework implementations have diverged.
  - Future Swift versions or API policy may still require revisiting the State concurrency envelope, but current S6 diagnostics are clean.
- Suggested direction:
  - Run S7 shared State conformance/extraction audit and implementation plan against the accepted standalone package destination.
  - Optionally run a release/readiness audit for S1-S6 before starting the migration wave.
  - Do not implement `@MainActor State`, `Value: Sendable`, or `@unchecked Sendable` unless a future diagnostic or accepted API policy requires it.
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
  - `Sources/Kit/Views/Not-MacOS/List.swift`
  - `Sources/Kit/Views/Not-MacOS/Collection.swift`
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
  - `Sources/Kit/Controllers/MenuItem.swift`
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
  - `Sources/Kit/Extensions/AttrStr+Joined.swift`
- Issue:
  - `AttrStr.Joined` child-only recomposition was identified as needing targeted tests before any repair.
  - Current behavior is documented but not tested.
- Risk:
  - Low for current state. Only relevant if AttributedString composition API changes.
- Suggested direction:
  - Add targeted tests for `AttrStr.Joined` recomposition before modifying behavior.
- Non-goals for this docs-closure chat:
  - Not adding tests or modifying AttributedString source.

### TD-008 — Cross-backend layout reparent semantics require executable Apple baseline before universal freeze

- Status: Open / Research Required
- Severity: Medium
- Area: Layout / Cross-Backend Architecture
- Files:
  - `Sources/Kit/Objects/PreConstraint.swift`
  - `.agent/architecture/LAYOUT_SYSTEM.md`
  - `.agent/architecture/NATIVE_BACKENDS.md`
- Issue:
  - Current Apple declaration-before-parent behavior is proven and durable.
  - Automatic detach/reparent persistence is unproven and is NOT frozen.
  - `deapplyAllConstraints()` exists, but automatic removal-time invocation is not established.
  - Before Unified Layout architecture is frozen, execute the Apple `configure -> parent A -> detach -> parent B` executable compatibility probe and record whether constraints survive/reactivate automatically versus require explicit deapply/reapply.
- Risk:
  - Freezing universal cross-backend reparent semantics without an Apple baseline could silently improve/change Apple compatibility semantics or invent unsupported automatic persistence behavior.
- Suggested direction:
  - Execute the Apple parent A -> detach -> parent B probe before Unified Layout contract freeze.
  - Do not silently improve or change Apple semantics while defining cross-backend parity.
- Scope note:
  - This does not block narrow E1.1 `centerInSuperview()` or D01 live acceptance.
  - It blocks broad universal constraint/reparent semantics from being frozen without evidence.
- Non-goals for this docs-closure chat:
  - Not executing the Apple probe now.
  - Not freezing Universal Layout implementation.
  - Not claiming automatic reparent persistence.
