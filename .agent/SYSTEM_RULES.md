# System Rules

Non-negotiable operational rules for UIKitPlus agent work.

1. Architecture is frozen by default.
2. Use `PLAN -> IMPLEMENT -> AUDIT` for all tasks.
3. Preserve fluent `Self` chain semantics.
4. Keep state/listener mutations explicit and auditable.
5. Keep extension behavior domain-scoped and composable.
6. Do not introduce hidden runtime lifecycle side effects.
7. Keep UIKit/AppKit boundaries explicit via conditional compilation.
8. Sync documentation before closing a task.
9. Push is locked until governance docs committed, 52-commit audit accepted, and user authorizes.
10. Documentation-only tasks must not edit Swift source.
11. `.artifacts/**` is transient and must never be committed.
