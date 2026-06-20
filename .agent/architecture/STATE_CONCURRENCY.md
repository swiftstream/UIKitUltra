# State Concurrency Decision

## Status

Deferred.

## Decision

Do not apply SwifDroid-style `@MainActor`, `Value: Sendable`, `Sendable`, or `@unchecked Sendable` changes to UIKitPlus State in the immediate corrective path.

## Rationale

A4 showed that UIKitPlus already builds and tests cleanly under Swift 6 strict concurrency because the package uses `swift-tools-version:6.2`.

The experimental probes showed:

- baseline: 332 tests pass;
- `@MainActor` on `State`: build fails with large actor-isolation cascade;
- `Value: Sendable`: build fails with 10,253 errors, especially UIKit bridging/value types;
- support type `@unchecked Sendable`: tests pass but provides low value without `Value: Sendable`;
- combined SwifDroid-like envelope: build fails with 205 errors.

## Current position

SwifDroid's concurrency envelope is a known difference from UIKitPlus.

UIKitPlus will preserve its current unconstrained `State<Value>` model for now.

This decision can be revisited only after UIKitPlus parity work is complete and with a dedicated migration plan.

## Non-goals

- No `SharedState`.
- No SwiftUI-collision-driven rename.
- No package extraction.
- No `/State` dependency.
