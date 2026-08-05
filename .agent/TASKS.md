# Tasks

Active governance-tracked work items.

## Current

### GOV-001 — Finalize UIKitPlus agent governance docs

- Status: COMPLETE — governance docs audited and committed locally
- Scope: `AGENTS.md`, `.agent/**`, `.gitignore`
- Non-scope: `Classes/**`, `Tests/**`, Swift 6 migration, State vNext implementation, push

### ULIST-DOC-001 — Define macOS UList/NSTableView golden runtime contract

- Status: COMPLETE — documentation and ChatGPT audit accepted; framework source unchanged
- Scope: `MACOS_ULIST_NSTABLEVIEW.md`, routing, runtime facts, validation, patch review, source map, memory, and operational skill
- Non-scope: `Classes/**`, `Tests/**`, public API, source behavior, push
- Guardrails: preserve the current native AppKit width/reuse/automatic-height graph; no speculative dual-root, forced-layout, responsive-scrolling, cache, or row-height-engine changes

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

- Source baseline before this documentation commit: `56b726fbbf9ec6218677a106ff33599a5b1187c3`
- Expected post-commit branch: `master...origin/master [ahead 1]`
- Push: LOCKED
- macOS swift test baseline: 390 tests, 5 skipped
- iOS simulator baseline: 218

## Ongoing Maintenance

1. Keep architecture contracts synchronized with runtime changes.
2. Keep skill routing aligned with architecture evolution.
3. Re-audit context budget/load rules after major module additions.
