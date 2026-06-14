# Navigation Flow Skill

## Purpose

Use this skill for navigation wrappers, push/pop behavior, transition helpers, and swipe-back configuration.

## Minimum Context

1. `.agent/architecture/LAYER_MODEL.md`
2. `.agent/architecture/NAVIGATION_SYSTEM.md`
3. `.agent/architecture/RUNTIME_MODEL.md`
4. `.agent/architecture/PLATFORM_ABSTRACTION.md`
5. `.agent/architecture/FLUENT_CHAIN_CONTRACT.md`

## Plan Checklist

- Identify platform scope (iOS/tvOS vs macOS navigation variants).
- Identify lifecycle and transition behavior affected.
- Validate chain API compatibility for configuration methods.
- Validate gesture/delegate interactions for swipe-back behavior.

## Implementation Rules

- Preserve platform-specific navigation separation.
- Keep transition behavior explicit (no hidden global navigation effects).
- Keep chain-return semantics intact for nav configuration methods.
- Document any lifecycle assumptions in runtime contracts.

## Audit Checklist

1. iOS/macOS behavior divergence remains intentional and documented.
2. Swipe-back gating and delegate behavior remain correct.
3. Transition helpers remain explicit opt-in APIs.
4. No platform leakage into shared navigation contracts.
