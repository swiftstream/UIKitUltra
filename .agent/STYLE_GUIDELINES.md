# Style Guidelines

## Documentation Style

- Use strict, architecture-oriented English.
- Prefer concrete framework artifacts over abstract language.
- Avoid simulation/game terminology.
- Avoid claiming guarantees the UIKit/AppKit event loop cannot provide.

## Contract Writing Style

- State invariants as testable statements.
- Separate invariant vs recommendation.
- Label forbidden patterns explicitly.
- Keep integration rules explicit when extension rules are not applicable.

## Repository Terminology

Use canonical UIKitUltra terms:
- `DeclarativeProtocol`
- `State` / `InnerState`
- `PreConstraint`
- `ForEach`
- `movedToSuperview`
- `AnyDeclarativeProtocol`

## Change Hygiene

- Keep docs additive and coherent.
- Update indexes when adding/removing docs.
- Keep skills and templates synchronized with architecture contracts.
