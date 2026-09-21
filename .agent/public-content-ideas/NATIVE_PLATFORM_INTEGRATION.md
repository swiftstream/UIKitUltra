# Native Platform Integration Public Content Ideas

Focused idea bank for README/docs/publication material about UIKitUltra extending native UIKit/AppKit behavior instead of replacing it with parallel hidden engines.

Do not load this shard during ordinary development. Read/update it only after a positive public-content capture check or when preparing public documentation/content.

## Native first, declarative on top

Status: architecture-approved
Good for: README | website docs | article | short post

### Why users should care

A useful UIKitUltra story is that declarative convenience does not require abandoning UIKit/AppKit's native semantics. The framework's preferred pattern is to expose the real native capability through a thin declarative wrapper first, then add UIKitUltra-specific fluent/state conveniences using mechanisms already established by the library.

That gives users a declarative API while keeping native lifecycle, layout, sizing, reuse, windowing, and platform behavior recognizable and debuggable.

### Candidate visual

```text
UIKitUltra fluent/declarative API
          │
          ▼
small explicit wrapper / binding layer
          │
          ▼
native UIKit / AppKit capability
          │
          ▼
native lifecycle + layout + reuse + platform behavior
```

The design rejects the opposite shape when the native substrate already owns the behavior:

```text
declarative API
    └─ hidden replacement layout/lifecycle/state engine
       └─ compensates for native behavior with private heuristics
```

### Evidence / provenance

Stable owners/rules:
- `.agent/SYSTEM_RULES.md` native-first two-stage implementation rules;
- `.agent/architecture/PLATFORM_ABSTRACTION.md`;
- `.agent/architecture/RUNTIME_MODEL.md`;
- focused native owners such as `MACOS_ULIST_NSTABLEVIEW.md` and `MACOS_WINDOW_TABS.md`.

Concrete repository examples include native `NSTableView`-backed `UList`, native AppKit window tabs, native menu ownership, and native Liquid Glass platform mappings.

### Publication caveat

This is a stable architecture/development philosophy, not a claim that every UIKitUltra feature has identical native coverage on every Apple platform. Public examples must state the actual platform/validation status of the concrete feature being shown.

## Declarative macOS window tabs without replacing AppKit topology

Status: implemented
Good for: README | website docs | article | release notes | short post

### Why users should care

UIKitUltra can expose native macOS project/window tab behavior declaratively while still letting AppKit own the native tab-group mechanics. The implementation keeps declarative metadata/topology synchronized with native reorder, detach, and reattach behavior, materializes tab content lazily, and preserves native delegate behavior instead of introducing a parallel fake tab system.

This is a strong example of the framework's native-first rule applied to a lifecycle-heavy feature.

### Candidate example / visual

A public-content piece could show the fluent tab declaration next to a topology diagram:

```text
caller source state
      │
      ▼
WindowTabGroup / WindowTab
      │
      ▼
WindowTabTopology reconciliation
      │
      ▼
NSWindowTabGroup + native windows
```

Useful story points to preserve:
- metadata/windows register eagerly;
- content controllers materialize on first selection;
- native reorder/detach/reattach is reconciled with caller source/topology state;
- the delegate proxy forwards selectors UIKitUltra does not own;
- `WindowTabGroup.onLastTabClose` exposes a typed decision hook without bypassing native close policy.

### Evidence / provenance

Stable contract:
- `.agent/architecture/MACOS_WINDOW_TABS.md` (`WT-001`-`WT-007`).

Relevant implementation/history checkpoints:
- `5f9a38a4d77ae2d769aa2ea00e98d39fb905db45` - 🪚 Harden `WindowTab` runtime and native topology;
- `2573c3670f87411fdad843213b0fb6ee78ad2084` - 🧪 Cover macOS window-tab and state contracts;
- `29f594216cf846fe543f7350e09269fe7d5d0def` - 📖 Synchronize macOS window-tab architecture docs;
- `d0eb7e83e612cd11255fbe4d2e90f09f74d40337` - 🪚 Add typed `WindowTabGroup.onLastTabClose` hook;
- `17424622da28de092a88014560b34b27720a1ce8` - 📖 Document `WindowTabGroup.onLastTabClose` contract.

### Publication caveat

Source and focused test/architecture synchronization are present, but this governance task did not verify release/shipped status or perform new rendered-app acceptance. Do not label the feature `shipped` from this entry alone.

## Native Liquid Glass instead of a synthetic visual clone

Status: validated
Good for: README | website docs | release notes | article | short post

### Why users should care

UIKitUltra maps modern Glass effects to the platform's native objects instead of building a synthetic look-alike view/effect layer. That keeps behavior aligned with Apple's platform implementation and illustrates how UIKitUltra adds declarative configuration without taking ownership away from the native rendering system.

A particularly useful engineering detail is that validation follows the installed native effect/configuration rather than assuming object identity survives `UIVisualEffectView` installation.

### Candidate visual

```text
UIKitUltra Glass configuration
        │
        ├─ macOS 26+ -> NSGlassEffectView
        │
        └─ iOS/iPadOS/tvOS 26+ -> native UIKit effects
                                  hosted by UVisualEffectView
```

Potential article angle: **"Declarative does not mean simulated: wrapping new Apple UI capabilities natively."**

### Evidence / provenance

Stable facts are recorded in `.agent/PROJECT_MEMORY.md` and platform architecture owners.

Relevant commits:
- `77c1e531f7790bcbefb44651ecf3d6856397d185` - `🪚 Add native Liquid Glass support`;
- `3cabe69ba76080f005fab269a7025bc0fbb76061` - `🧪 Cover native Liquid Glass support`;
- `61fb188b0cb3960d0357ecbd657771b521b8dc0b` - `📖 Document Liquid Glass platform mapping`.

Stable memory records successful focused runtime probes on iOS/iPadOS/tvOS 26.2, while also recording platform-specific caveats such as Catalyst validation limitations and unrelated tvOS package-build blockers.

### Publication caveat

`validated` here refers to the focused native/runtime evidence already recorded by UIKitUltra stable project memory. This governance task did not verify release/shipped status. Public content must preserve the platform caveats and must not imply universal Apple-platform validation.
