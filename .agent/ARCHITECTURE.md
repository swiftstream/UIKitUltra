# UIKitPlus Architecture Specification

This file is a compact compatibility index for the architecture chunk set.

## Architecture Documents

- `.agent/architecture/LAYER_MODEL.md`
- `.agent/architecture/DSL_ARCHITECTURE.md`
- `.agent/architecture/DECLARATIVE_PROTOCOL.md`
- `.agent/architecture/VIEW_COMPOSITION.md`
- `.agent/architecture/STATE_SYSTEM.md`
- `.agent/architecture/LAYOUT_SYSTEM.md`
- `.agent/architecture/MACOS_ULIST_NSTABLEVIEW.md`
- `.agent/architecture/MACOS_ULIST_TEXTKIT2.md`
- `.agent/architecture/GESTURE_SYSTEM.md`
- `.agent/architecture/NAVIGATION_SYSTEM.md`
- `.agent/architecture/PLATFORM_ABSTRACTION.md`
- `.agent/architecture/FLUENT_CHAIN_CONTRACT.md`
- `.agent/architecture/EXTENSION_SYSTEM.md`
- `.agent/architecture/RUNTIME_MODEL.md`
- `.agent/architecture/MUTATION_MODEL.md`
- `.agent/architecture/APPLICATION_STATE_OWNERSHIP.md`

## Architectural Core

UIKitPlus is governed by these core facts:
- DSL surface is reference-semantic, not value-semantic.
- Fluent chains are in-place mutation APIs returning `Self`.
- State propagation is listener-driven and synchronous by default.
- Constraint application can be deferred until superview/context availability.
- Extension composition is the primary delivery mechanism for framework features.
- UIKit/AppKit abstraction is conditional and intentionally asymmetric where platform APIs differ.
- UIKitPlus application state follows Application State Ownership: local state belongs to its natural View/ViewController owner, sibling-shared state to the nearest common composition owner, app-wide environment to `App`, and authoritative runtime/domain state to a justified dedicated owner.
- A ViewModel/PresentationModel is not a default UIKitPlus layer; children receive exact state references, immutable values, and focused callbacks instead of broad state bags.

## Contract Priority

When contracts conflict, use this priority:
1. `LAYER_MODEL.md`
2. `FLUENT_CHAIN_CONTRACT.md`
3. `STATE_SYSTEM.md`
4. `EXTENSION_SYSTEM.md`
5. `RUNTIME_MODEL.md`
6. `MUTATION_MODEL.md`
7. Domain architecture docs
8. `APPLICATION_STATE_OWNERSHIP.md` for application-level ownership decisions, subject to the framework contracts above

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
- `AO*`: UIKitPlus application state ownership
- `UL*`: macOS UList / NSTableView runtime contract
- `UTK*`: macOS UList / TextKit 2 application-row integration
