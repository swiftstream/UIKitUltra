# UIKitUltra Product Identity

Stable authority for product, package, module, target, trait, and backend naming.

## Canonical Identity

- Repository/package/framework brand: `UIKitUltra`.
- Canonical public Swift library/module imported by application code: `Ultra`.
- The public `U*` API prefix means **Ultra**.
- Do not create or document a public Swift module named `UIKitUltra`.
- Framework prose may say `UIKitUltra`; Swift import/module examples must use `Ultra` / `Ultra*`.

Golden developer-experience rule:

> If you know UIKit then you already know everything in UIKitUltra.

## Repository and Workspace Identity

Canonical GitHub organization:

`https://github.com/swiftstream`

Canonical UIKitUltra repository:

`https://github.com/swiftstream/UIKitUltra`

Canonical local workspace root:

`/Users/imike/Development/SwiftStream`

Canonical local UIKitUltra path:

`/Users/imike/Development/SwiftStream/UIKitUltra`

SwiftStream-owned `Ultra*` sibling repositories live beside UIKitUltra under this workspace when checked out locally. Current local UIKitUltra-family siblings include:

```text
/Users/imike/Development/SwiftStream/UIKitUltra
/Users/imike/Development/SwiftStream/UltraGTK
/Users/imike/Development/SwiftStream/UltraDemoApp
```

Canonical GitHub backend repository identities currently include:

| Repository | Public Swift backend/module identity |
|---|---|
| `swiftstream/UltraGTK` | `UltraGTK` |
| `swiftstream/UltraQt` | `UltraQt` |
| `swiftstream/UltraWinUI` | `UltraWin` |
| `swiftstream/UltraAndroid` | `UltraAndroid` |
| `swiftstream/UltraTUI` | `UltraTUI` |

Repository identity and public Swift module identity are not required to be textually identical. In particular, `UltraWinUI` is the intentional repository name, while UIKitUltra's public backend/module naming remains `UltraWin`. The Android repository identity is `UltraAndroid`.

Do not introduce new active references to the retired workspace root `/Users/imike/Development/UIKitUltra`. Historical/frozen evidence keeps historical paths verbatim.

## SwiftPM Naming

Current common/runtime identity direction:

```text
Ultra
UltraCore
UltraQtRuntime
UltraWinRuntime
```

Accepted GTK production foundation identity is external and singular:

```text
repository/package/product/module/import = UltraGTK
```

Explicit backend public/direct modules:

```text
UltraGTK
UltraQt
UltraWin
UltraAndroid
UltraTUI
```

The pre-H3 `UltraGTKRuntime` / `UltraGTKCore` names are historical
source/evidence identities only. H3 Wave C removed their selected production
closure; active GTK production identity is the external singular `UltraGTK`.

Linux selection traits:

```text
UltraGTK
UltraQt
```

Compile-time defines owned by the package use the `ULTRA_` prefix, for example:

```text
ULTRA_GTK_BACKEND
ULTRA_QT_BACKEND
ULTRA_GTK_TESTS
```

GTK native boundary identities:

```text
CUltraGTK
UltraGTKBridge
ultra_gtk_*
UltraGTK*
ULTRA_GTK_*
```

## Backend Naming

Direct backend wrapper prefixes remain top-level and backend-specific:

```text
GTK*
Qt*
Win*
Android*
TUI*
```

Rare direct backend escapes use:

```text
.gtk
.qt
.win
.android
.tui
```

Windows public UIKitUltra naming uses `Win`, not `WinUI`. The underlying native Windows toolkit remains Microsoft WinUI 3 / Windows App SDK and should be named accurately in implementation documentation and evidence.

## Compatibility and Historical Evidence

- Legacy `UIKitPlus*` and intermediate `UIKitUltra*` Swift module spellings are migration history, not final module identity.
- Historical/frozen evidence, accepted reports, commit messages, hashes, and provenance snapshots must not be mechanically rewritten.
- Stable compatibility identifiers such as persisted string keys remain unchanged unless a dedicated compatibility migration explicitly authorizes changing them.
- Real historical/external URLs remain unchanged until their destination actually changes.

## Ownership Boundary

This file owns naming identity only. Backend architecture, support claims, inheritance/native authority, dependency isolation, and explicit-overlay behavior remain owned by `architecture/NATIVE_BACKENDS.md`.
