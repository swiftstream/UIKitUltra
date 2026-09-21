# Commit Rules

Git, staging, commit-message, and preservation rules for UIKitUltra.

## Pre-Work Check

Before mutation, inspect the complete repository baseline, including staged, unstaged, and untracked files.

Preferred command when a shell is available:

```bash
git status --short --untracked-files=all
```

Record/understand the baseline so unrelated user work can be preserved exactly.

## Post-Work Check

After work, inspect status again and review the complete task diff.

When a shell is available, also run:

```bash
git diff --check
```

Confirm only approved task-scope files changed and no unrelated work was disturbed.

## Preservation Rules

- Preserve unrelated staged, unstaged, and untracked files.
- Never stage unrelated changes.
- Never amend, squash, rebase, merge, reset, checkout/restore user work, clean, stash, or rewrite history unless the maintainer explicitly authorizes that exact operation and scope.
- If an approved task file overlaps unexpected user edits, stop and report the conflict rather than overwriting or hiding the work.
- Do not perform broad cosmetic cleanup merely to make a task diff look cleaner.

## Staging Gate

Staging requires explicit maintainer authorization covering the exact intended operation and scope. The maintainer may grant that authorization for one operation or for a bounded multi-step sequence in advance; once a specific operation is already covered by that explicit authorization, do not ask for a redundant confirmation unless a task-specific frozen contract requires one.

For any new, widened, or otherwise unapproved scope or Git operation, obtain explicit maintainer authorization before staging.

When staging:

- stage only the approved logical-unit paths;
- never use broad `git add .`, `git add -A`, or equivalent repository-wide staging for normal task commits;
- do not use `git commit -a`;
- re-check status after staging;
- inspect the **complete staged snapshot/diff** before committing;
- if staged content contains anything outside approved scope, do not commit until the scope is corrected by an explicitly safe operation.

`.artifacts/**` is disposable working memory and must never be staged or committed.

## Local Development Manifest Gate

`Package.swift` contains the committed switch:

```swift
let isLocalDevelopment = false
```

This is a hard repository rule:

- `isLocalDevelopment = true` is allowed only in an **uncommitted local working tree** for sibling-package development;
- **never stage or commit** `Package.swift` while the switch is `true`;
- **never tag, release, publish, or push** a commit whose manifest sets the switch to `true`;
- every commit/release gate that includes `Package.swift` must verify the exact committed literal remains `let isLocalDevelopment = false`;
- local sibling dependencies use relative paths such as `../UltraGTK`, never maintainer-specific absolute paths;
- default/non-local mode uses the canonical SwiftStream GitHub repository for the child package;
- historical `.artifacts/**` evidence may retain old absolute paths and must not be mechanically rewritten.

If the switch is found as `true` during a staging/commit audit, the commit is BLOCKED until it is restored to `false` without disturbing unrelated work.

The primary local checkout installs a defensive Git hook at `.git/hooks/pre-commit`. The hook checks both the working-tree `Package.swift` and the staged `Package.swift` snapshot and rejects `isLocalDevelopment = true`. This hook is local Git metadata and is intentionally not committed. New clones must install an equivalent local hook. `git commit --no-verify` does **not** waive this repository rule; the stable governance above remains authoritative even if hooks are bypassed or unavailable.

## Current Commit / Release Cadence

This is the maintainer's current stable cadence policy and may be revised later.

### Commit often

When explicit maintainer authorization covers the commit operation for an implementation/correction/governance scope:

- commit after **every logically complete and validated unit**, including small features, fixes, focused refactors, tests, or governance changes;
- do not wait for a large milestone merely to reduce commit count;
- keep each commit coherent and independently understandable;
- a bounded explicit authorization may cover several predefined commits in one reviewed sequence; otherwise each commit remains a separate explicit Git gate;
- a failed required validation/audit blocks that logical unit's commit;
- the commit phase must not mutate source/docs merely to repair a bad staged snapshot; return to implementation/correction instead;
- after every commit, verify subject, changed paths, commit identity, and remaining working-tree/index state.

This standing cadence does **not** authorize new scope, unrelated staging, history rewriting, or bypassing task-specific gates.

### Tag and push by completed release block

Do **not** push after every commit.

When a logically complete release block has passed its required review/audit/acceptance and is ready for downstream/nightly consumers, it becomes **eligible** for the release step; passing those gates does not itself authorize tag creation or push.

After explicit maintainer authorization covers the exact tag and remote refs:

1. ensure the production branch is release-safe and all intended commits for that block are present;
2. create the next sequential alpha tag on the active release line;
3. push the production branch and that exact tag in the same release step;
4. verify remote branch and tag identities after push.

For the current UIKitUltra release line:

```text
3.0.0-alpha.*
```

use the next sequential `alpha.N` tag, preserving the repository's established annotated-tag convention unless stable release policy is explicitly changed.

Release pushes must remain narrow:

- no force push;
- no broad `--tags`;
- no unrelated refs;
- no tag reuse/rewrite;
- no push while `isLocalDevelopment = true`;
- if the next tag, remote state, or release-safe commit identity is ambiguous/conflicting, stop and resolve that exact release gate before mutation.

A release block may contain several fine-grained local commits since the previous push. The normal cadence is therefore:

```text
small logical unit -> commit
small logical unit -> commit
...
completed accepted release block -> next alpha tag + branch push + exact tag push
```

## UIKitUltra Commit Message Style

Use:

```text
<semantic emoji> <concise English action>
```

Rules:

- Write the subject in English.
- Use exactly one leading semantic emoji.
- Keep the subject short, action-oriented, and normally imperative in spirit (`Add`, `Fix`, `Correct`, `Document`, `Remove`, `Harden`, `Synchronize`, etc.).
- An optional semantic scope may use `:`, for example `Window: ...` or `State: ...`, when it improves clarity.
- Wrap Swift/API/type/symbol names in backticks, for example `UList`, `NSTableView`, `Window`, or `State`.
- Do not prefix subjects with `UIKitUltra:` merely to repeat the repository name.
- Do not use generic Conventional Commit prefixes such as `feat:`, `fix:`, or `chore:` by default.
- Do not append contributor-integration suffixes such as `(#54 by ...)` to ordinary maintainer-local commits. Such historical forms, if present, belong to contributor integration context rather than normal local work.
- Never add coding-agent, model, or tool attribution to source headers or commit messages merely because assisted tooling participated in the work.

### Established semantic emoji vocabulary

Recent UIKitPlus history establishes these meanings:

- `📖` - documentation, architecture, governance, or durable contract synchronization.
- `🪚` - scoped implementation/additive API work, especially focused native/declarative capability additions.
- `🛠` - source correction, hardening, behavioral fix, or compatibility repair.
- `🧪` - test-only/focused verification coverage; this is the preferred modern test emoji.
- `🧹` - cleanup/removal with no broader feature meaning.

Historical UIKitPlus commits also use:

- `✨` - additive feature work in older history;
- `✅` - tests in older history.

Do not rewrite history, but prefer the current `🪚`/`🛠`/`🧪` vocabulary when it truthfully matches new work. Other semantic emoji are allowed only when they communicate the change more accurately and remain consistent with the repository's one-emoji style; do not import another repository's emoji vocabulary mechanically.

## Commit Scope Rules

- Prefer one coherent logical change per commit.
- Do not mix Swift source and governance/docs unless the task genuinely requires both and the maintainer approves that combined scope.
- Stable `.agent/**` documentation is committed according to the meaning and ownership of the durable facts being recorded, not merely because several stable files are dirty at the same time.
- Governance/orchestration changes must use separate documentation/governance commits from product/backend/source implementation.
- Stable documentation synchronization may be committed partially or split across several commits when different owner files become semantically complete at different points in the workflow; do not hold a finished stable owner merely to create one large documentation commit, and do not commit a still-premature owner just to clear the working tree.
- Changes whose purpose is development orchestration/governance mechanics include orchestration/delegation workflow, artifact workflow, commit/process gates, and similar coding-agent development-process rules; keep them in the logically matching governance commit unit.
- Routine stable documentation that merely records an accepted implementation fact may follow the implementation's reviewed commit boundary when explicitly appropriate, but it still belongs in a separate commit when combining it with source would obscure the logical history.
- Migration/correction commits must not mix behavior changes with unrelated cosmetic cleanup.
- Do not include whitespace-only source churn or unrelated blank-line cleanup.
- Do not remove existing source comments unless they become obsolete/misleading because of the approved change.
- Single-use helper extraction is not a default cleanup technique; it must be justified by the approved architecture/behavior task.

## Parallel Worktree Commit Rule

When work is performed in a linked parallel lane under `PARALLEL_DEVELOPMENT.md`:

- staging/commit authorization applies only to that lane's reviewed branch/worktree scope;
- checkpoint commits belong only to the lane branch;
- a subordinate lane must never stage/commit the primary checkout on its own;
- a locally clean lane commit is not canonical integration;
- merge/cherry-pick/rebase/reimplementation/reconciliation into the primary line remains a separate primary/maintainer-owned decision;
- canonical `.artifacts/parallel/**` content remains ignored working memory and is never included in lane commits.

## Push Rule

Push behavior is owned by the current release cadence above, but push remains a separate explicit Git gate.

A release block that passes its required project-specific review/audit/acceptance gates is eligible for branch + next exact alpha tag publication; it is not thereby authorized to push. The maintainer must explicitly authorize the exact remote branch/tag push scope, either at that gate or through a prior bounded authorization that unambiguously covers those refs.

Outside that explicitly authorized release step, pushing remains unauthorized.
