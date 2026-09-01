# Validation Rules

UIKitPlus-specific validation rules for agent work.

## 1. General Hygiene

Every task must inspect repository status before and after mutation and review the complete task diff.

Preferred shell checks when available:

```bash
git status --short --untracked-files=all
git diff --check
```

Rules:
- preserve unrelated staged/unstaged/untracked user work;
- do not claim a validation command passed unless it actually ran;
- docs-only tasks do not edit Swift production/tests/package/project files unless explicitly approved;
- `.artifacts/**` may contain transient planning/evidence/handoff files but must remain ignored and must never be staged/committed.

## 2. Governance / Documentation Validation

When closing a governance workflow change, verify at minimum:

```bash
test -f AGENTS.md
test -f .agent/ARCH_INDEX.md
test -f .agent/WORKFLOW.md
test -f .agent/DEVELOPMENT_ORCHESTRATION.md
test -f .agent/ARTIFACTS_WORKFLOW.md
test -f .agent/COMMIT_RULES.md
test -f .agent/CONTEXT_LOADING_RULES.md
test -f .agent/PUBLIC_CONTENT_IDEAS.md
test -f .agent/SOURCE_MAP.md
test -f .agent/TASKS.md
test -f .agent/VALIDATION_RULES.md
grep -n "^\.artifacts/$" .gitignore
```

Also audit:
- no Swift source/test/package/project diff unless explicitly in scope;
- `.artifacts/**` is not staged/tracked;
- no stale references to removed/obsolete orchestration owners;
- no model/vendor-specific implementation-orchestration wording in stable workflow owners;
- root `AGENTS.md` remains routing-focused rather than duplicating focused owners;
- operational workflow docs do not inflate the architecture context budget;
- public-content shards remain lazy and are not normal development context;
- stable architecture IDs/owners and project-specific rules were not accidentally rewritten.

## 3. Source-Task Validation

For tasks that edit Swift source, begin with the smallest focused check that can prove/reject the change, then expand according to scope/risk.

Current common package checks when applicable:

```bash
swift test
swift test --filter <focused-test>
```

Platform-specific rules:
- use `xcodebuild` only when relevant and available;
- do not claim iOS/tvOS/macOS rendered/native validation unless actually run/observed;
- when rendered presence, clipping, viewport reach, native ownership, resize behavior, or actual visual boundaries are ambiguous on any UI surface, use `.agent/skills/uikitplus-visual-ui-diagnostics/SKILL.md` to obtain objective screenshot/recording plus native/runtime geometry evidence rather than extending log-only inference;
- changed public fluent APIs must be audited against the relevant `FC*`/`ST*`/other architecture IDs selected by `ARCH_INDEX.md`;
- macOS native window-tab patches require the focused window-tab contract validation and full package validation appropriate to current source;
- macOS `UList`/`NSTableView` changes must satisfy the rendered recycling/live-resize gate owned by `MACOS_ULIST_NSTABLEVIEW.md` when that contract requires it.

Green tests/builds are evidence, not architecture proof. Independent source/diff/owner review remains mandatory.

## 4. Missing Tool / Runtime Capability

If the coordinator/reviewer cannot directly run a required command or rendered/native check, use the focused read-only verification delegation defined by `DEVELOPMENT_ORCHESTRATION.md` and `ARTIFACTS_WORKFLOW.md`.

For delegated rendered-UI diagnosis, use `.agent/skills/uikitplus-visual-ui-diagnostics/SKILL.md` as the operational skill for that verification step and keep temporary instrumentation out of the real tracked repository whenever the task is read-only.

Do not silently downgrade required evidence because the current tool surface lacks the capability.

## 5. Milestone Gate

For substantial roadmap milestones, strict validation and rendered/native/live acceptance are followed by the independent whole-milestone conformance review defined by `DEVELOPMENT_ORCHESTRATION.md` before stable milestone state is marked complete.

This extra gate does not apply to trivial docs/format-only tasks or isolated low-risk fixes.

## 6. Commit / Push Gate

Validation success does not authorize staging, commit, or push.

- staging/commit require explicit maintainer authorization and follow `COMMIT_RULES.md`;
- `.artifacts/**` never enters the staged snapshot;
- UIKitPlus push remains locked until its current project-specific audit/migration prerequisites are satisfied and the maintainer explicitly authorizes push.
