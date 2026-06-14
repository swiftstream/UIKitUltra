# Extension Rules

## Ownership and Placement

- Use feature-scoped files: `DeclarativeProtocol+Feature.swift`.
- Keep type-specific behavior close to owning protocol/type extension.
- Keep platform-specific variants behind `#if os(macOS)` / `#if !os(macOS)` boundaries.

## Compatibility Rules

- Avoid ambiguous overload sets.
- Prefer explicit labels for overload disambiguation.
- Keep protocol-extension defaults behavior-compatible with conforming concrete types.

## Side-Effect Boundaries

Allowed:
- explicit state/listener wiring,
- explicit notification wiring tied to documented flows.

Forbidden:
- hidden global observer side effects,
- cross-domain mutable singleton mutation,
- undocumented runtime lifecycle assumptions.

## Collision Audit

For each new extension method:
- check existing symbols and overloads,
- check platform-conditional symmetry,
- check contract-doc updates.

## Anti-Patterns (Forbidden)

- Introducing overloads that become ambiguous after platform-conditional compilation.
- Installing listeners/observers in extension methods without documented duplicate-call handling.
- Repeated observer wiring in lifecycle/rebuild paths without explicit ownership and teardown strategy.
- Cross-domain side effects (layout/state/navigation coupling) that are not declared in architecture contracts.
- Additive behavior that is real but undocumented, especially in repeated fluent configuration paths.
