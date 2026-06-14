# Tasks

Active governance-tracked work items.

## Current

### GOV-001 — Finalize UIKitPlus agent governance docs

- Status: IN PROGRESS until this docs commit is audited and committed
- Scope: `AGENTS.md`, `.agent/**`, `.gitignore`
- Non-scope: `Classes/**`, `Tests/**`, Swift 6 migration, State vNext implementation, push

## Blocked

### AUDIT-001 — Independent audit of 52 local commits before push

- Status: BLOCKED on GOV-001 completion
- Depends on: governance docs committed locally
- Scope: all 52 local commits on `master` ahead of `origin/master`

### MIGRATION-001 — Swift 6 strict concurrency migration

- Status: BLOCKED on AUDIT-001
- Depends on: governance commit + 52-commit audit accepted
- Scope: `Classes/**` Swift 6 strict concurrency annotations
- Reference: `.agent/STATE_VNEXT_PLAN.md` §5

### STATE-001 — State vNext after Swift 6 baseline

- Status: BLOCKED on MIGRATION-001
- Depends on: Swift 6 migration complete and accepted
- Scope: State vNext implementation
- Reference: `.agent/STATE_VNEXT_PLAN.md`

## Current Known Baseline

- HEAD: `379d5cb0b4af45cf4758645b0485931cf5195d09`
- Branch: `master...origin/master [ahead 52]`
- Push: LOCKED
- macOS swift test baseline: 228
- iOS simulator baseline: 218

## Ongoing Maintenance

1. Keep architecture contracts synchronized with runtime changes.
2. Keep skill routing aligned with architecture evolution.
3. Re-audit context budget/load rules after major module additions.
