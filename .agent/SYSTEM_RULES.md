# System Rules

Non-negotiable operational rules for UIKitPlus agent work.

1. Architecture is frozen by default.
2. Use `PLAN -> IMPLEMENT -> AUDIT` for all tasks.
3. Preserve fluent `Self` chain semantics.
4. Keep state/listener mutations explicit and auditable.
5. Keep extension behavior domain-scoped and composable.
6. Do not introduce hidden runtime lifecycle side effects.
7. Keep UIKit/AppKit boundaries explicit via conditional compilation.
8. Existing UIKitPlus engineering approaches, fluent API conventions, state/listener patterns, composition rules, and platform mappings are the primary authority for all new work. Agents must inspect and reuse analogous existing classes before designing anything new.
9. New functionality is implemented in at least two explicit stages: first, a simple declarative wrapper over the native UIKit/AppKit API; second, UIKitPlus-specific conveniences built according to the same patterns already used by comparable UIKitPlus classes.
10. A new engineering approach, internal coordination model, lifecycle mechanism, or abstraction pattern may be introduced only after a written proposal is reviewed and explicitly approved by the library author.
11. Hidden workarounds, compensating layout engines, and behavior-specific hacks are forbidden. Edge cases must be handled through clean, optional, composable public declarative APIs that let the caller customize native behavior explicitly without changing the default path.
12. Prefer native UIKit/AppKit layout, sizing, scrolling, animation, diffing, reuse, and lifecycle behavior as the implementation substrate; UIKitPlus conveniences must extend that substrate rather than replace it.
13. Sync documentation before closing a task.
14. Push is locked until governance docs committed, 52-commit audit accepted, and user authorizes.
15. Documentation-only tasks must not edit Swift source.
16. `.artifacts/**` is transient and must never be committed.
