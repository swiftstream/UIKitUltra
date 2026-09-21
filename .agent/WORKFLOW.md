# Workflow

Mandatory development workflow for UIKitUltra. Active source uses the final `UIKitUltra` brand with `Ultra` / `Ultra*` Swift identities; historical/frozen evidence may retain legacy `UIKitPlus` spellings where historically accurate.

## PLAN -> IMPLEMENT -> AUDIT

Every non-trivial task follows:

1. **PLAN** - research current facts, define exact scope, relevant architecture owners/IDs, expected mutations, and completion evidence. Externalize substantial research/plan state under `.artifacts/planning/<slug>/` according to `ARTIFACTS_WORKFLOW.md`.
2. **IMPLEMENT** - execute the reviewed plan without unrelated expansion. Large or multi-behavior work is decomposed into numbered surgical task files before an implementation executor receives it.
3. **AUDIT** - verify behavior, source, architecture IDs, docs, validation, and Git state with concrete evidence; use focused correction task files when needed; synchronize durable knowledge that actually changed.

Small typo/format-only work may skip a formal artifact plan but still requires scope/result verification.

UIKitUltra-specific PLAN/IMPLEMENT/AUDIT mechanics are in `DEVELOPMENT_PHASES.md`. Model-independent coordinator/executor roles and review gates are in `DEVELOPMENT_ORCHESTRATION.md`. Detailed transient task/report mechanics are in `ARTIFACTS_WORKFLOW.md`. Load `PARALLEL_DEVELOPMENT.md` only when linked-worktree/parallel-lane work is actually in scope. The one-time UIKitPlus -> UIKitUltra rename is migration history, not permanent workflow authority.

Git cadence is governed by `COMMIT_RULES.md`: prefer small completed validated logical units, but staging/commit/tag/push still require the explicit authorization that covers each exact Git operation/scope. Tag + push are eligible only at an accepted release-block boundary. Do not duplicate the detailed cadence here.

## UIKitUltra Development Shape

For new native/backend-backed functionality, preserve the established two-stage rule:

```text
inspect analogous current UIKitUltra implementation; use legacy UIKitPlus history only when relevant
-> Stage 1: thin truthful native/backend wrapper preserving authoritative backend semantics
-> Stage 2: UIKitUltra conveniences/common DSL using established mechanisms
-> focused validation
-> independent architecture/source audit
```

Apple Stage 1 remains direct UIKit/AppKit. GTK/Qt/Win/Android/TUI backend work follows the focused rules in `NATIVE_BACKENDS.md`.

Do not introduce a replacement lifecycle/layout/state/coordination model merely because it seems cleaner in isolation. New engineering approaches require the explicit review/approval owned by `SYSTEM_RULES.md` and relevant architecture owners.

## Iterative LLM-Assisted Work

For non-trivial iterative work, load `DEVELOPMENT_ORCHESTRATION.md` and `ARTIFACTS_WORKFLOW.md`.

- Detailed mechanics, allowlists, architecture IDs, verification, and stop conditions live in numbered task files.
- The executor coordinator prompt stays short and drives autonomous task-by-task execution with append-only reporting.
- Executor reports are evidence inputs, never proof. Independent review inspects actual files, Git state/diff, direct callers, architecture owners, and relevant validation.
- Audit findings become a new focused numbered correction wave rather than one giant correction prompt.
- When the coordinator lacks a required execution/runtime/UI/native capability, use a focused read-only verification task rather than leaving a blind spot.
- Substantial roadmap milestones receive the independent whole-milestone conformance gate defined by `DEVELOPMENT_ORCHESTRATION.md` before they are marked complete.

## Documentation Synchronization

Update stable documentation only when a task changes a durable fact, architecture rule, task/debt state, source/navigation ownership, or workflow rule.

Do not touch unrelated docs merely because a generic checklist exists. Link to the authoritative owner instead of duplicating full contracts.

After meaningful research/design/implementation/correction/audit, perform the lazy public-content capture check owned by `PUBLIC_CONTENT_IDEAS.md`. If no genuinely valuable README/docs/website/release/migration/publication material appeared, do not open the bank. If the check is positive, append only to the relevant shard while the context is fresh.

## Git Safety

Follow `COMMIT_RULES.md`. Preserve unrelated user work. PLAN/IMPLEMENT/AUDIT completion does not waive scope, validation, protected-index, local-development, release-block, or remote-safety gates.
