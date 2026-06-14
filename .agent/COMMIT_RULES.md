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
