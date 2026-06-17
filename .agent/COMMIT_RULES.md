# Commit Rules

## Commit Message Style

All commits must follow strict prefixes:

- 📖 ... for documentation/governance
- 🧪 ... for tests
- 🛠 ... for source fixes
- 🪚 ... for scoped implementation/migration
- 🧹 ... for cleanup/removal

## Rules

- Imperative mood, not past tense.
- One logical change per commit.
- No mixed Swift source + governance unless explicitly approved.
- Docs closure commit may include only `AGENTS.md`, `.agent/**`, and `.gitignore`.
- `.artifacts/**` must never be committed.
- No push — local commits are allowed only after ChatGPT audit acceptance.
- Migration commits must not mix diagnostic/behavior changes with cosmetic cleanup.
- Style cleanup requires its own explicitly approved cleanup commit.
- Migration commits must not contain whitespace-only source diffs or extra blank lines unrelated to the approved change.
- Do not remove existing source comments unless they are obsolete or misleading after the code change.
- Single-use helper extraction is not allowed in migration commits unless explicitly approved and justified by diagnostic reduction, behavior safety, lifecycle isolation, or test seam necessity.
