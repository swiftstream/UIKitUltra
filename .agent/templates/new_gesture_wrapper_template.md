# Template: New Gesture Wrapper

Use this template for new gesture recognizer wrappers and fluent gesture APIs.

## Pre-Checks

1. `GESTURE_SYSTEM.md`
2. `FLUENT_CHAIN_CONTRACT.md`
3. `EXTENSION_SYSTEM.md`
4. `MUTATION_MODEL.md`
5. `PLATFORM_ABSTRACTION.md`

## Wrapper Stub

- Gesture type:
- Wrapper type name:
- Callback surface (state/action/delegate):
- Delegate fallback behavior:
- Platform availability:

## Safety Requirements

- Recognizer attachment is explicit.
- Delegate behavior preserves outer fallback when local handler is absent.
- State mutation path (if any) is explicit and documented.
- Repeat-call behavior is declared (additive vs dedup).

## Audit Notes

- Chain API integrity validated.
- Delegate path validated.
- Platform conditional correctness validated.
