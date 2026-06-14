# Gesture Integration Skill

## Purpose

Use this skill for gesture recognizer wrappers, state-tracking callbacks, gesture delegation behavior, and gesture DSL extension additions.

## Minimum Context

1. `.agent/architecture/LAYER_MODEL.md`
2. `.agent/architecture/GESTURE_SYSTEM.md`
3. `.agent/architecture/EXTENSION_SYSTEM.md`
4. `.agent/architecture/MUTATION_MODEL.md`
5. `.agent/architecture/FLUENT_CHAIN_CONTRACT.md`
6. `.agent/architecture/PLATFORM_ABSTRACTION.md`

## Plan Checklist

- Identify target gesture domains and platform availability.
- Validate delegate precedence and outer-delegate fallback behavior.
- Validate whether callbacks mutate `State` or runtime properties.
- Check extension overload collision risk.

## Implementation Rules

- Keep gesture APIs chainable and explicit about recognizer attachment.
- Preserve `_GestureDelegator` fallback semantics.
- Document repeat-call behavior when attaching recognizers/listeners.
- Keep platform-specific gesture surfaces conditionally isolated.

## Audit Checklist

1. No extension overload ambiguity introduced.
2. Delegate fallback path remains functional.
3. State mutation from callbacks is explicit and contract-aligned.
4. Platform-specific API exposure remains correct.
