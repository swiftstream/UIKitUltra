---
name: navigation-flow
description: Change or review UIKitPlus navigation wrappers and navigation DSL internals inside the UIKitPlus source repository. Use for push/pop behavior, transition helpers, swipe-back configuration, lifecycle effects, and platform-specific navigation implementation; not for ordinary downstream navigation usage.
---

# Maintain UIKitPlus Navigation Flow

Use this LOCAL contributor skill for built-in UIKitPlus navigation source work.

## Load the smallest decision-complete context

1. Start from UIKitPlus `AGENTS.md` and [`SKILL_INDEX.md`](../../SKILL_INDEX.md).
2. Use [`NAVIGATION_SYSTEM.md`](../../architecture/NAVIGATION_SYSTEM.md) as the primary owner.
3. Add only what the change needs:
   - [`RUNTIME_MODEL.md`](../../architecture/RUNTIME_MODEL.md) for lifecycle/deferred transitions;
   - [`PLATFORM_ABSTRACTION.md`](../../architecture/PLATFORM_ABSTRACTION.md) for iOS/tvOS/macOS separation;
   - [`FLUENT_CHAIN_CONTRACT.md`](../../architecture/FLUENT_CHAIN_CONTRACT.md) for changed public configuration APIs.
4. Use [`SOURCE_MAP.md`](../../SOURCE_MAP.md) before broad source discovery.

## Plan checklist

- Identify exact platform scope and current native navigation substrate.
- Identify push/pop or transition lifecycle behavior affected.
- Check fluent API compatibility for configuration changes.
- Check recognizer/delegate interactions when swipe-back behavior is involved.
- Distinguish local convenience behavior from a new global navigation policy.

## Implementation rules

- Preserve platform-specific navigation separation.
- Keep transitions and navigation effects explicit; do not introduce hidden global behavior.
- Preserve fluent `Self` return semantics for public configuration methods.
- Keep lifecycle assumptions aligned with the current runtime owner.
- Preserve native navigation/delegate ownership unless architecture is explicitly re-opened.

## Audit

Verify:

- intentional platform divergence remains correct;
- swipe-back gating/delegate behavior is preserved when in scope;
- transition helpers remain explicit opt-in APIs;
- no platform leakage appears in shared contracts;
- fluent/reference semantics remain intact;
- unrelated source/governance remains untouched.

Stop and re-plan if the work requires a new navigation lifecycle/coordination model rather than an implementation inside the existing architecture.