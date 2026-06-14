# UIKitPlus Architecture Specification

This file is a compact compatibility index for the architecture chunk set.

## Architecture Documents

- `.agent/architecture/LAYER_MODEL.md`
- `.agent/architecture/DSL_ARCHITECTURE.md`
- `.agent/architecture/DECLARATIVE_PROTOCOL.md`
- `.agent/architecture/VIEW_COMPOSITION.md`
- `.agent/architecture/STATE_SYSTEM.md`
- `.agent/architecture/LAYOUT_SYSTEM.md`
- `.agent/architecture/GESTURE_SYSTEM.md`
- `.agent/architecture/NAVIGATION_SYSTEM.md`
- `.agent/architecture/PLATFORM_ABSTRACTION.md`
- `.agent/architecture/FLUENT_CHAIN_CONTRACT.md`
- `.agent/architecture/EXTENSION_SYSTEM.md`
- `.agent/architecture/RUNTIME_MODEL.md`
- `.agent/architecture/MUTATION_MODEL.md`

## Architectural Core

UIKitPlus is governed by these core facts:
- DSL surface is reference-semantic, not value-semantic.
- Fluent chains are in-place mutation APIs returning `Self`.
- State propagation is listener-driven and synchronous by default.
- Constraint application can be deferred until superview/context availability.
- Extension composition is the primary delivery mechanism for framework features.
- UIKit/AppKit abstraction is conditional and intentionally asymmetric where platform APIs differ.

## Contract Priority

When contracts conflict, use this priority:
1. `LAYER_MODEL.md`
2. `FLUENT_CHAIN_CONTRACT.md`
3. `STATE_SYSTEM.md`
4. `EXTENSION_SYSTEM.md`
5. `RUNTIME_MODEL.md`
6. `MUTATION_MODEL.md`
7. Domain architecture docs

## Related Governance Docs

- `.agent/SOURCE_MAP.md` — source ownership and navigation
- `.agent/TECH_DEBT.md` — technical debt register
- `.agent/COMMIT_RULES.md` — commit message rules
- `.agent/VALIDATION_RULES.md` — validation rules
- `.agent/TASKS_ARCHIVE.md` — completed milestones
- `.agent/STATE_VNEXT_PLAN.md` — State vNext planning (deferred)

## ID Summary

- `DA*`: DSL architecture
- `DP*`: DeclarativeProtocol
- `VC*`: view composition
- `ST*`: state system
- `LY*`: layout system
- `GS*`: gesture system
- `NV*`: navigation system
- `PA*`: platform abstraction
- `LC*`: layer model
- `FC*`: fluent chain contract
- `EX*`: extension system
- `RT*`: runtime model
- `MU*`: mutation model
