# Native Backends

## Metadata
- Layer: Platform / Cross-Layer
- Depends On Layers: DSL, Runtime, Platform
- Current Implemented UI Families: UIKit (iOS/tvOS), AppKit (macOS)
- Accepted Future Native Families: GTK 4 + libadwaita, Qt 6 + selected KF6/Breeze integration, WinUI 3 + Windows App SDK
- Status: G2 architecture accepted; M1 structural multi-backend foundation implemented and audited; non-Apple production UI backends are not implemented/support-claimed yet

## Purpose

Define the durable architecture for expanding UIKitPlus from its current UIKit/AppKit implementation to additional **real native** desktop backends without turning UIKitPlus into a custom renderer or forcing third-party Swift UI wrapper frameworks into the runtime dependency chain.

This document is architecture authority, not a support claim. Until the corresponding production milestone passes implementation and independent audit, Linux/Windows backend APIs remain unimplemented/unreleased even though their architecture is accepted here.

## Invariants

### NB1: One Public UIKitPlus Module Identity

Normal consumers use:

```swift
import UIKitPlus
```

on every supported backend.

Internal targets/modules `UIKitPlusCore`, `UIKitPlusGTK`, `UIKitPlusQt`, and `UIKitPlusWinUI` are implementation details and must not become required normal consumer imports. The UIKitPlus prefix is deliberate collision-avoidance for external Swift package graphs.

### NB2: Real Native Objects Are Authoritative

Every implemented backend uses the real host toolkit's controls, layout/container objects, lifecycle, input/focus, windowing, accessibility, appearance, and model/view facilities.

UIKitPlus must not introduce:

- a custom cross-platform renderer;
- a UIKit emulator;
- a shadow visual tree that competes with the native hierarchy;
- a parallel layout solver;
- a parallel list virtualization/reuse engine.

Shared UIKitPlus semantics map to native toolkit primitives. Platform-specific APIs remain first-class when no honest shared semantic exists.

### NB3: UIKitPlus Owns Production Binding/Bridge Layers

No third-party Swift UI wrapper framework may sit between UIKitPlus and GTK/Qt/WinUI as a required production dependency.

UIKitPlus owns the generated/mechanical binding or bridge layer used by each backend.

Community projects and tools may be used for research, comparison, compiler/tooling reference, or validation, but production runtime/source ownership stays with UIKitPlus unless the maintainer explicitly revises this architecture.

### NB4: Hybrid Core + Backend Target Model

Accepted internal SwiftPM target/module identities are:

```text
UIKitPlusCore
UIKitPlusGTK
UIKitPlusQt
UIKitPlusWinUI
```

`UIKitPlusCore` contains only code proven toolkit-independent. Its physical source directory may remain the concise `Sources/Core/**`; directory names are not module identities. The public `UIKitPlus` target likewise uses the concise physical root `Sources/Kit/**`. Existing Apple implementation may remain in that public target while structural work evolves; an `AppleBackend` target is not required merely for symmetry.

The first pre-authorized portable nucleus is limited to the independently proven State/listener files. Additional source enters `UIKitPlusCore` only after file-level portability evidence and review.

### NB5: Generate Mechanical Breadth, Curate UIKitPlus Semantics

Native breadth should be generated from authoritative native metadata/headers using UIKitPlus-owned deterministic tooling:

```text
authoritative metadata / headers
-> UIKitPlus-owned deterministic importer
-> generator-only normalized Native IR
-> backend-private generated bindings / bridge source
-> curated UIKitPlus semantic adapters
```

The Native IR is a build-time generator schema, not a runtime UI abstraction.

Generated source should be source-controlled, reproducible, hash/provenance-manifested, and never manually patched. Hand-authored exceptions belong in explicit importer/override/curation inputs.

### NB6: Backend Dependency Closure Is Physically Isolated

Apple consumers must not resolve/build/link/require GTK/libadwaita, Qt/KF6, Windows App SDK/NuGet/MSBuild/XAML build tooling, or foreign backend generators.

Likewise:

- a GTK build must not pull Qt/KF6 or Windows tooling;
- a Qt build must not pull GTK/libadwaita or Windows tooling;
- a Windows build must not pull GTK/Qt dependencies.

Dependency isolation must be executable evidence, not just manifest intent.

### NB7: Linux Backend Selection Is Explicit and Implementation-Gated

Because `os(Linux)` does not identify GNOME vs KDE, the accepted package-selection traits are namespaced to avoid collisions:

```text
UIKitPlusGTK
UIKitPlusQt
```

Required semantics:

```text
GTK only -> GTK closure
Qt only  -> Qt closure
both     -> deliberate diagnostic failure
neither  -> deliberate diagnostic requiring explicit selection
```

SwiftPM traits are additive and must never be described as manifest-enforced mutually exclusive features.

If real consumer dependency graphs make trait union operationally unsuitable, explicit product/target/package selection is the accepted fallback. Do not silently default GTK on Linux.

### NB8: Native Markup Is Private Infrastructure, Not the Consumer UI Language

UIKitPlus's declarative Swift/body-builder/fluent API remains the application UI authoring layer.

The framework may own or generate private native infrastructure required by a toolkit/build system, including for example:

- WinUI `App.xaml`, generated `.g.*`, XBF/PRI/resource metadata;
- a narrowly justified GtkBuilder/template resource;
- Qt/KDE generated metadata/resources where native tooling requires it.

But the primary UIKitPlus body/control tree must not be serialized into XAML, GtkBuilder XML, QML, Qt Designer `.ui`, or another markup language merely because the toolkit supports one.

Consumer-authored control trees stay Swift-first unless a future explicit architecture revision says otherwise.

### NB9: Layout and Lists Stay Toolkit-Native

Apple `PreConstraint` / `NSLayoutConstraint` behavior remains Apple Auto Layout runtime and is not generalized into a cross-toolkit constraint solver.

Only honest shared layout intent may map to native GTK/Qt/WinUI layout/container primitives.

Likewise `ForEach` may share identity/diff intent, but each backend delegates virtualization/reuse/model-view ownership to its native list/model system. A stack of row views is not acceptable production list support.

### NB10: Accepted Backend Sequencing

The accepted implementation sequence is:

```text
M1 structural multi-backend foundation, Apple-preserving
-> M2 GTK owned generator + primitive native slice
-> M3 GTK/libadwaita desktop + native list/model foundation
-> M4 freeze/revalidate shared backend contract + Native IR from real implementation evidence
-> M5 WinUI production backend
-> M6 Qt/KDE production backend
```

GTK is intentionally first because GIR/GObject is the simplest binding-oriented metadata boundary. GTK implementation details must not be promoted into universal contracts before M4 revalidation.

### NB11: Windows Production Boundary Is Owned C++/WinRT + Narrow C ABI Unless Revised by Evidence

The accepted Windows production hypothesis is:

```text
UIKitPlus Swift semantic adapter
-> UIKitPlus-owned generated Swift/C ABI boundary
-> UIKitPlus-owned C++/WinRT bridge
-> WinUI 3 / Windows App SDK
```

Direct `swift-winrt` projection remains optional/reference tooling rather than a required production dependency.

The research corpus executably proved Windows ARM64 runtime feasibility, including real bidirectional native/Swift behavior and external UI Automation event provenance.

M1 Task07 executably selected the source-first Windows orchestration shape:

```text
package-owned Windows prepare/build workflow
-> NuGet restore in owned scratch
-> supported ARM64 VS/MSBuild C++/WinRT build
-> UIKitPlusWinUI C ABI loader
-> normal consumer import UIKitPlus
```

The proof reached a real WinUI projected metadata boundary and an exact native
runtime canary through `import UIKitPlus`. Raw PE bytes may differ because of
timestamp/debug metadata while code/interface/provenance remain deterministic.
The exact durable production command/product wiring still belongs to the future
WinUI production milestone; M1 does not add or ship a production native bridge.
Opaque prebuilt native binaries remain disallowed without a separate maintainer
architecture decision.

### NB12: Support Claims Follow Implemented + Audited Milestones

Architecture acceptance does not itself mean a backend is supported.

Before public support claims, each backend must pass its roadmap's native build/runtime, lifecycle, interaction, appearance/accessibility as claimed, dependency/license, complex-fixture, and independent audit gates.

Linux x86_64 and Windows x64 require their own implementation validation before public claims; ARM64 research evidence does not automatically certify them.

## Current M1 Structural Policy

M1 structural foundation is implemented and audited. Durable current facts are:

- the public product/module identity remains `UIKitPlus`;
- `UIKitPlusCore`, `UIKitPlusGTK`, `UIKitPlusQt`, and `UIKitPlusWinUI` exist as internal SwiftPM targets;
- `UIKitPlusCore` contains exactly the initial proven portable State nucleus:
  `ExpressableState.swift`, `OrderedRegistrations.swift`, `State.swift`,
  `StateListener.swift`, and `StatesHolder.swift`;
- the three non-Apple backend targets remain behavior-empty compile skeletons;
- Linux exposes additive SwiftPM traits `UIKitPlusGTK` and `UIKitPlusQt` and
  requires explicit selection: both and neither deliberately diagnose;
- Windows attaches `UIKitPlusWinUI` through a platform-conditional dependency;
- ordinary consumers remain `import UIKitPlus` only;
- legacy UIKit/AppKit implementation remains Apple-scoped; `BaseView` is
  explicitly compiled only for macOS/iOS/tvOS;
- Task07 selected and executable-proved the package-owned source-first
  Windows NuGet/MSBuild/C++/WinRT integration mechanism described in NB11;
- no GTK/Qt/WinUI production controls, generated bindings, or public support
  claim are implemented by M1.

M1 intentionally did not invent a universal native-view protocol, cross-toolkit
renderer, layout engine, or list virtualization layer.

## Forbidden Patterns

- Required consumer imports of backend modules for ordinary UIKitPlus use.
- Runtime backend guessing on Linux instead of explicit build selection.
- Third-party Swift UI wrapper as required production substrate.
- Custom cross-platform renderer or native-control emulation.
- Runtime Native IR / generic widget metadata tree.
- Cross-toolkit Auto Layout clone.
- Stack-based fake production list virtualization.
- Consumer control trees generated into XAML/GtkBuilder/QML/.ui by default.
- Manual edits to generated native binding source.
- Foreign backend tooling/dependencies leaking into Apple builds.
- Opaque binary bridge distribution introduced without explicit maintainer review.
- Public Linux/Windows support claims before corresponding implementation/audit gates.

## Integration Rules

For any native-backend task:

1. Load `LAYER_MODEL.md` plus this owner and only the relevant domain owner(s).
2. Preserve NB1–NB12 unless a written architecture revision is explicitly accepted by the maintainer.
3. Inspect analogous existing UIKitPlus native-wrapper behavior before adding semantic conveniences.
4. Keep generated native breadth backend-private and curated public UIKitPlus semantics separate.
5. Prove dependency closure on every affected host family.
6. Use real native runtime/interaction evidence before claiming GUI behavior.
7. Keep platform-only capabilities platform-scoped instead of forcing fake parity.
8. Any shared contract change influenced by one backend must be revalidated against the other accepted backend families before it becomes durable universal architecture.

## Audit Implications

Native-backend changes must explicitly answer:

- Does normal consumer import remain `UIKitPlus`?
- Are real native objects still authoritative?
- Did any third-party wrapper become a required production dependency?
- Is `UIKitPlusCore` limited to proven portable semantics?
- Are backend dependency closures isolated?
- Is generated source deterministic and backend-private?
- Did layout/list behavior remain native-owned?
- Did private markup stay infrastructure rather than consumer control-tree authoring?
- Are platform-specific APIs allowed where honest?
- Is the claimed support level backed by actual host/runtime evidence?
- Did current work accidentally promote an implementation-specific GTK/Qt/WinUI detail into a universal contract?
