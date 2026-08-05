# Validation Rules

UIKitPlus-specific validation rules for agent work.

---

## 1. General Hygiene

Every task must run:

```bash
git status --short --untracked-files=all
git diff --check
```

Rules:
- No Swift source edits in docs-only tasks.
- No test edits in docs-only tasks.
- No Package.swift edits in docs-only tasks.

## 2. Docs Closure Validation

When closing a documentation/governance task, verify:

```bash
test -f AGENTS.md
test -f .agent/COMMIT_RULES.md
test -f .agent/SOURCE_MAP.md
test -f .agent/TECH_DEBT.md
test -f .agent/TASKS.md
test -f .agent/TASKS_ARCHIVE.md
test -f .agent/VALIDATION_RULES.md
test -f .agent/STATE_VNEXT_PLAN.md
grep -n "^\\.artifacts/$" .gitignore
```

Additional checks:
- `.artifacts/**` not staged;
- no `Classes/**` changes;
- no `Tests/**` changes;
- no `Package.swift` changes;
- no `Package.resolved` changes;
- no `.swiftpm/**` changes;
- no `.artifacts/**` changes.

## 3. Source-Task Validation (Future)

For tasks that edit Swift source:

```bash
swift test
swift test --filter <focused-test>   # when tests exist
```

Platform-specific validation:
- `xcodebuild` only when relevant and available;
- do not claim iOS/tvOS validation unless actually run.
- macOS `UList` / `NSTableView` source changes also require the rendered
  recycling and live-resize gate in `MACOS_ULIST_NSTABLEVIEW.md` (`UL10`).

## 4. Push Lock

Validation success does not allow push.

Push to origin is forbidden until:
1. governance docs are committed locally;
2. independent 52-commit audit is accepted;
3. critical regressions are fixed or deferred;
4. Swift 6 / State vNext risks are documented;
5. the user explicitly authorizes push.

## 5. Documentation-Only Task Checklist

- [ ] `git status --short --untracked-files=all` shows only docs files
- [ ] `git diff --check` passes
- [ ] No `Classes/**` in diff
- [ ] No `Tests/**` in diff
- [ ] No `Package.swift` in diff
- [ ] `.artifacts/**` not staged
- [ ] All required `.agent` docs exist
- [ ] `.gitignore` contains `.artifacts/`
