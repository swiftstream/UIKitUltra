# DSL Safety Rules

## Core Safety Requirements

1. Do not break `Self`-return fluent chains.
2. Do not introduce value-semantic builder assumptions.
3. Do not hide mutation behind non-obvious APIs.
4. Do not attach listeners implicitly without documenting lifecycle and repeat-call behavior.
5. Do not couple DSL methods to platform-specific behavior unless explicitly gated.

## Fluent API Safety Checks

Before merging DSL changes:
- verify chain continuity,
- verify in-place mutation expectations,
- verify idempotent behavior for value setters where possible,
- verify repeated binding/listener methods are explicitly handled.

## Composition Safety Checks

- body/result-builder integration must preserve view insertion semantics.
- ForEach integration must preserve diff-driven update logic.
- extension APIs must remain independently composable.

## Anti-Patterns (Forbidden)

- Hiding listener/binding installation inside methods that appear to be pure value setters.
- Repeated fluent chains that install additional listeners/observers without guard, dedup, or explicit ownership.
- Undocumented additive side effects triggered by repeated invocation.
- Rebuilding composition paths that re-register bindings on each pass without teardown strategy.
- Platform-specific behavior leaking through shared DSL surface without explicit conditional gating.
