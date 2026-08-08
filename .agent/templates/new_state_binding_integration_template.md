# Template: New State Binding Integration

Use this template for APIs that bind runtime or DSL behavior to `State` or `InnerState`.

## Pre-Checks

1. `LAYER_MODEL.md`
2. `STATE_SYSTEM.md`
3. `FLUENT_CHAIN_CONTRACT.md`

Load `MUTATION_MODEL.md` for bidirectional/re-entrant mutation,
`RUNTIME_MODEL.md` for lifecycle/deferred behavior, or another domain doc only
through documented context-budget escalation.

## Binding Stub

- Binding target:
- Fluent setter(s) in patch scope:
- ST8 classification: bindable / non-bindable
- Scalar/object overload signature:
- `State`/`UState` overload signature:
- If non-bindable, reviewed semantic rationale:
- Source state type:
- Direction: one-way / two-way
- Initial value application path:
- Listener attachment location:
- Owner capture strategy:
- Listener holder:
- Recursion guard strategy:
- Repeat-call semantics: additive / deduplicated / guarded
- Teardown path:
- Assignment policy: every assignment (`listen`) / distinct only
- Autocomplete surface: explicit overload pair / FC11 generic exception
- FC11 overload-resolution and autocomplete evidence, if applicable:
- Per-overload FC12 DocC summary:

## Safety Requirements

- Implement the recorded ST8 classification without changing ST2/ST6
  semantics.
- Enforce FC11 discoverability and FC12 per-overload DocC.
- Keep derivation, one-way binding, and two-way synchronization explicit.

## Audit Notes

- ST8 surface, initial application, ownership, repeat behavior, and teardown
  validated.
- FC11/FC12 validated.
- Any escalated mutation/runtime contract validated and recorded.
