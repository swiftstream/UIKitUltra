# Project Memory

This file stores stable governance memory for UIKitPlus agent work.

## Repository Identity

- UIKitPlus is a declarative UIKit/AppKit DSL framework.
- Core contract root is `DeclarativeProtocol` with reference semantics.
- Public API growth is extension-driven.

## Current State

- UIKitPlus is currently local-only ahead of origin by 52 commits.
- Latest accepted local source commit: `379d5cb0b4af45cf4758645b0485931cf5195d09`.
- Push is locked.
- Governance docs are being finalized before Swift 6 strict concurrency migration.
- `.artifacts` is transient and ignored.
- State vNext is deferred until after Swift 6 migration.

## Baselines

- macOS swift test baseline: 362
- iOS simulator baseline: 218

- macOS `UTextView` is an AppKit scroll/text wrapper with declarative state, editing, command support, auto-growing height, and maximum-height scrolling.

## Frozen Architectural Decisions

1. Architecture is frozen by default.
2. Fluent APIs are `Self`-returning in-place mutations.
3. State engine is reference-based (`State`, `InnerState`) with synchronous listener dispatch.
4. Constraint system uses deferred pre-constraint queues plus activation on superview availability.
5. Platform abstraction is explicit and conditional (`#if os(macOS)` / non-macOS variants).

## Workflow Memory

- Mandatory phase order: `PLAN -> IMPLEMENT -> AUDIT -> LOCAL COMMIT`.
- No push until independent audit is accepted and user authorizes.
- Patch review must validate fluent, state, extension, runtime, and mutation contracts.
- Task closure requires `.agent` synchronization.

## Documentation Memory

- `ARCH_INDEX.md` is the routing entrypoint.
- Max active architecture docs defaults to `3`.
- Skills/templates are secondary context after architecture loading.

## State vNext Memory

- Swift 6 strict concurrency first, State vNext later.
- Global cross-framework debt shared with SwifDroid and SwifWeb.
- External `@State` DX stays simple.
- `.hold(in:)` public lifecycle API.
- S5 removed obsolete `holdIfOwned(by:)`; `Classes`/`Tests` should stay free of it.
- Protocol extensions use internal `holdInStateBindingOwnerIfAvailable(_:)`; concrete owners use `.hold(in: stateBindingHolder)`.
- `removeListeners()` preferred naming.
- S6 accepted Option C first: keep `State<Value>` unconstrained for now and isolate UI binding surfaces only if future diagnostics require it.
- Strict build/test currently pass with zero State-related diagnostics; no immediate `@MainActor State` / `Value: Sendable` implementation is required.
