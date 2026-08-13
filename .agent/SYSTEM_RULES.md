# System Rules

Non-negotiable operational and engineering rules for UIKitPlus agent work.

1. Architecture is frozen by default. Contract-changing architecture work requires explicit maintainer approval.
2. Use the `PLAN -> IMPLEMENT -> AUDIT` development cycle; commit and push are separate explicit Git gates.
3. Preserve fluent `Self` chain semantics.
4. Keep state/listener mutations explicit and auditable.
5. Keep extension behavior domain-scoped and composable.
6. Do not introduce hidden runtime lifecycle side effects.
7. Keep UIKit/AppKit boundaries explicit via conditional compilation.
8. Existing UIKitPlus engineering approaches, fluent API conventions, state/listener patterns, composition rules, and platform mappings are the primary implementation evidence for new work. Inspect and reuse analogous existing classes before designing anything new.
9. New native-backed functionality is implemented in at least two explicit stages when applicable: first, a simple declarative wrapper over the native UIKit/AppKit API; second, UIKitPlus-specific conveniences built according to patterns already used by comparable UIKitPlus classes.
10. A new engineering approach, internal coordination model, lifecycle mechanism, or abstraction pattern may be introduced only after a written proposal is reviewed and explicitly approved by the library author.
11. Hidden workarounds, compensating layout engines, and behavior-specific hacks are forbidden. Edge cases should be handled through clean, optional, composable public declarative APIs when caller customization is the correct boundary.
12. Prefer native UIKit/AppKit layout, sizing, scrolling, animation, diffing, reuse, and lifecycle behavior as the implementation substrate. UIKitPlus conveniences extend that substrate rather than replacing it.
13. Synchronize only affected durable documentation before closing a task; do not touch unrelated docs by checklist habit.
14. Preserve unrelated staged, unstaged, and untracked user work. Follow `COMMIT_RULES.md` for every Git mutation.
15. UIKitPlus push remains locked until the repository's current audit/migration prerequisites are satisfied and the maintainer explicitly authorizes push.
16. Documentation-only tasks must not edit Swift production/test/package/project source unless the maintainer explicitly expands scope.
17. `.artifacts/**` is disposable Git-ignored working memory. It may be created/updated during work but must not be staged or committed.
18. For non-trivial iterative LLM-assisted work, follow `DEVELOPMENT_ORCHESTRATION.md` and `ARTIFACTS_WORKFLOW.md`; large/cognitively dense implementation or correction work is decomposed into numbered surgical tasks rather than one giant executor prompt.
19. Executor reports, green tests, builds, and rendered checks are evidence, not architecture proof. Independently inspect actual source/diff/Git and relevant architecture owners before acceptance.
20. `PUBLIC_CONTENT_IDEAS.md` and its shards are lazy communication context, not normal development context. Open them only after a positive capture check or for explicit public-content work.
