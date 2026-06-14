# Extension System

## Metadata
- Layer: Cross-Layer
- Depends On Layers: DSL, Runtime, Platform
- Primary Runtime Artifacts: `DeclarativeProtocol+Feature.swift` extensions, protocol default implementations, constrained extensions

## Purpose

Define extension ownership, precedence, collision control, and composability guarantees.

## Invariants

### EX1: Domain Ownership

Extensions are owned by feature domain and should remain scoped (layout, gesture, text, navigation, etc.).

### EX2: Naming Pattern Consistency

Primary extension file pattern is `DeclarativeProtocol+Feature.swift` (or equivalent type/protocol ownership pattern).

### EX3: Precedence Awareness

Resolution follows Swift dispatch/overload rules; architecture must account for:
- concrete type methods,
- constrained extensions,
- unconstrained protocol extensions.

Practical precedence expectation for review:
1. concrete type member wins,
2. constrained extension candidate wins over unconstrained when applicable,
3. protocol extension default is fallback.

### EX4: Platform Conditional Exclusivity

Platform-specific extension variants must be mutually exclusive and explicit.

### EX5: Composability Guarantee

Independent extensions must remain chain-composable without undocumented behavior coupling.

## Forbidden Patterns

- Domain mixing that creates hidden coupling between unrelated extension sets.
- Overload sets that introduce ambiguous call sites.
- Global side effects from extension methods not declared in contracts.
- Silent precedence changes that alter existing call resolution behavior.

## Integration Rules

- New extension APIs must include collision scan with existing methods.
- Overload introductions must include call-site disambiguation strategy.
- Cross-cutting side effects (e.g., notification-based activation helpers) require explicit contract documentation.

## Audit Implications

Extension patches must verify:
- no overload ambiguity,
- platform-conditional symmetry,
- no hidden side-effect coupling,
- chain contract compatibility.
