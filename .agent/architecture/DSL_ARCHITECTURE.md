# DSL Architecture

## Metadata
- Layer: DSL
- Depends On Layers: Runtime, Platform
- Primary Runtime Artifacts: `DeclarativeProtocol`, protocol extensions, fluent `Self` modifiers, result builders

## Purpose

Define the architecture of UIKitUltra as a fluent declarative DSL built on protocol conformance and extension composition.

## Invariants

### DA1: Fluent Chain Surface Is Primary API

Core user-facing APIs are `Self`-returning chain methods over reference-semantic view/controller objects.

### DA2: Protocol-Oriented Composition

Capabilities are composed by protocols and protocol extensions instead of monolithic base classes.

### DA3: Extension-Driven Expansion

New DSL capability is expected to be introduced as focused extensions in domain-specific files.

### DA4: Declarative Entry Points

Builder-style composition uses result builders (`body`, `BodyBuilder`, `ForEach`) while preserving UIKit/AppKit object identity.

## Forbidden Patterns

- Replacing chain methods with copy-return immutable builders.
- Introducing hidden object replacement during fluent chaining.
- Expanding DSL surface with undocumented side effects.
- Mixing unrelated domains into single extension files.

## Extension Rules

- Follow domain ownership (`DeclarativeProtocol+Feature.swift`).
- Preserve method naming consistency with existing DSL.
- Preserve `Self` return behavior for chainable APIs.
- Document repeat-call behavior when attaching listeners or observers.

## Audit Implications

DSL changes must be audited against:
- `FLUENT_CHAIN_CONTRACT.md`
- `EXTENSION_SYSTEM.md`
- `STATE_SYSTEM.md` (if bindings/listeners are involved)
