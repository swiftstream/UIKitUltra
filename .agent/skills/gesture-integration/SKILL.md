---
name: gesture-integration
description: Change or review UIKitUltra gesture recognizer wrappers and gesture DSL internals inside the UIKitUltra source repository. Use for recognizer attachment, delegate fallback, State-driven callbacks, extension overloads, and platform-specific gesture behavior; not for ordinary downstream gesture usage.
---

# Maintain UIKitUltra Gesture Integration

Use this LOCAL contributor skill for built-in gesture-wrapper and gesture-DSL source work.

## Load the smallest decision-complete context

1. Assume root/architecture/skill routing already selected this skill and `GESTURE_SYSTEM.md`; do not re-read `AGENTS.md`/`SKILL_INDEX.md` unless that context is genuinely missing or stale.
2. Use [`GESTURE_SYSTEM.md`](../../architecture/GESTURE_SYSTEM.md) as the primary owner.
3. Add only what the change needs:
   - [`MUTATION_MODEL.md`](../../architecture/MUTATION_MODEL.md) for callback mutation/re-entrancy;
   - [`EXTENSION_SYSTEM.md`](../../architecture/EXTENSION_SYSTEM.md) for extension surfaces/collisions;
   - [`PLATFORM_ABSTRACTION.md`](../../architecture/PLATFORM_ABSTRACTION.md) for UIKit/AppKit exposure;
   - [`FLUENT_CHAIN_CONTRACT.md`](../../architecture/FLUENT_CHAIN_CONTRACT.md) for changed public chain APIs.
4. Use [`SOURCE_MAP.md`](../../SOURCE_MAP.md) only if the affected source location/ownership is not already known.

## Plan checklist

- Identify the recognizer/gesture domain and exact platform availability.
- Determine delegate ownership and `_GestureDelegator`/outer-delegate fallback implications.
- Identify callbacks that mutate State or runtime properties.
- Check repeat attachment/listener behavior and extension overload collision risk.

## Implementation rules

- Keep recognizer attachment explicit and fluent APIs chainable.
- Preserve the current delegate fallback/precedence contract.
- Keep repeated setup behavior truthful; do not claim idempotency without deduplication.
- Keep State mutation and callback ownership explicit.
- Isolate platform-specific APIs with the established conditional-compilation boundary.
- Do not introduce hidden global gesture behavior or a second delegation mechanism.

## Audit

Verify:

- no new extension ambiguity;
- delegate fallback remains functional;
- callback-driven State/runtime mutation follows selected owners;
- platform exposure is intentional and correct;
- changed public APIs preserve fluent/reference semantics;
- unrelated source/governance remains untouched.

Stop and re-plan if the work needs a new delegation/lifecycle model rather than an extension of the current gesture architecture.