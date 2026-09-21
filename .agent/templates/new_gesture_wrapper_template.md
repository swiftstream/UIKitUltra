# Template: New Gesture Wrapper

Use this template for new gesture recognizer wrappers and fluent gesture APIs.

## Pre-Checks

Use `GESTURE_SYSTEM.md` as the primary owner.

Add only what the wrapper needs:

- `FLUENT_CHAIN_CONTRACT.md` for public chain API;
- `EXTENSION_SYSTEM.md` for extension placement/collisions;
- `MUTATION_MODEL.md` for callback/re-entrant mutation;
- `PLATFORM_ABSTRACTION.md` for platform exposure.

Do not load all supporting owners by default; stay within the normal architecture budget unless documented escalation is required.

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
