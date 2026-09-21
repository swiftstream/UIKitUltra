# UIKitUltra Application State Ownership Architecture

## Metadata

- **Short name:** Application State Ownership (`ASO`)
- **Architecture ID namespace:** `AO*`
- **Scope:** applications built with UIKitUltra
- **Layer:** application architecture / cross-layer guidance
- **Depends on:** `STATE_SYSTEM.md`, `VIEW_COMPOSITION.md`, `RUNTIME_MODEL.md`, `MUTATION_MODEL.md`, `PLATFORM_ABSTRACTION.md`
- **Primary artifacts:** `UView`, `ViewController`, `App`, `UState`/`State`, focused callbacks, immutable data values, dedicated runtime/domain owners

## 1. Definition

Application State Ownership is the default architecture for UIKitUltra applications.

Its central rule is:

> Mutable state lives with the nearest object that naturally owns its lifetime, authority, and invariants. UIKitUltra views bind directly to that state. Shared dependencies are passed explicitly as exact `UState` references, immutable values, or focused callbacks. A separate ViewModel/PresentationModel layer is not introduced by default.

ASO is an ownership architecture rather than a mandatory layer acronym. It defines:

- where state belongs;
- who may mutate it;
- how state is exposed to child components;
- how user actions return to the owner;
- when an application-wide or domain/runtime owner is justified;
- how UIKitUltra reference-semantic state participates in composition and lifecycle;
- how to avoid presentation containers, service locators, duplicate stores, and hidden dependency graphs.

ASO is compatible with UIKit/AppKit view controllers, UIKitUltra declarative composition, ordinary data models, services, repositories, sessions, documents, provider runtimes, and persistence layers. It does not forbid models. It forbids creating an intermediate presentation object merely because a screen contains mutable UI state.

## 2. Why this architecture exists

UIKitUltra is not SwiftUI and does not build disposable value-view trees. Its views and controllers are real reference-semantic UIKit/AppKit objects. `State<Value>`/`UState<Value>` is also reference-semantic. A UIKitUltra component can therefore own mutable state for exactly as long as that component exists and can pass the same state object to children without copying it.

A default ViewModel layer often adds no useful boundary in this environment when it:

- mirrors fields already owned by a view or controller;
- exposes all screen state to every child;
- contains UIKit/AppKit/UIKitUltra types;
- forwards user actions without domain invariants;
- becomes a presentation-state bag;
- obscures the real lifetime owner;
- encourages a later God object containing networking, persistence, session, and tool behavior.

ASO uses UIKitUltra's native strengths instead:

- real object identity;
- explicit composition;
- reference-semantic `UState` sharing;
- declarative `.map` derivations;
- focused child initializer contracts;
- native UIKit/AppKit lifecycle ownership;
- dedicated runtime owners only when authority and lifetime require them.

## 3. Goals

ASO aims to provide:

1. **Obvious ownership:** a reader can locate the owner of mutable state from the source hierarchy.
2. **Minimal dependency surfaces:** child components receive only what they use.
3. **Direct reactive composition:** UIKitUltra views bind to owner states without mirrored presentation stores.
4. **Correct lifetimes:** state normally dies with its natural owner unless a longer-lived owner is explicitly chosen.
5. **Replaceable presentation fixtures:** UI prototypes cannot accidentally become domain architecture.
6. **Incremental complexity:** domain/runtime layers appear only when real behavior justifies them.
7. **Native platform alignment:** UIKit/AppKit objects retain their normal lifecycle and authority.
8. **Testable boundaries:** exact state references, immutable values, and callbacks can be supplied to previews and focused tests.
9. **No hidden global graph:** dependencies remain visible in initializers, properties, or typed global owners.
10. **Framework-consistent code:** application architecture follows UIKitUltra reference and mutation semantics.

## 4. Non-goals

ASO does not require:

- all state to live in a `UView`;
- all logic to live in a view controller;
- one global singleton containing the whole application;
- strict unidirectional reducers;
- protocol abstractions for every dependency;
- repository/service layers for trivial local operations;
- removal of data models or domain objects;
- rejection of MVC, coordinators, documents, repositories, actors, or services where useful;
- direct UI access to credentials, persistence engines, network clients, or unsafe process APIs;
- hiding platform differences behind artificial shared types.

ASO does not ban a dedicated object named `Model`, `Store`, `Session`, `Document`, `Runtime`, or `Controller`. Such an object is valid when it owns real authority, invariants, I/O, persistence, concurrency, recovery, or a lifetime independent of one view.

## 5. Vocabulary

### State owner

The object whose lifetime and authority define the mutable state. It creates or retains the authoritative `State`/`UState` instance and is responsible for its invariants and listener lifecycle.

### Consumer

A view, controller, service, or child component that reads or writes an owner's state through an explicitly supplied reference or operation.

### Composition owner

The nearest ancestor view/controller that creates multiple sibling components and owns state shared among them.

### App environment

Application-wide preferences or presentation conditions that intentionally apply across screens/windows, such as theme, locale, UI scale, accessibility overrides, or global navigation scene state.

### Runtime/domain owner

A dedicated long-lived object that owns authoritative application behavior: session, project, document, conversation, provider run, repository, permission ledger, persistence store, credential broker, or similar.

### Fixture

Deterministic immutable sample data used for previews, visual implementation, or presentation-only prototypes. A fixture is not authoritative runtime state.

### Focused callback

A closure that grants one intentional action rather than broad access to the owner's state or object.

## 6. Ownership scopes

ASO uses four mutable ownership scopes plus immutable data.

### 6.1 Component-local UI ownership

Use the `UView` or `ViewController` itself when state:

- exists only to render or operate that component;
- does not need to outlive the component;
- is not authoritative outside the component;
- is not shared by unrelated siblings.

Examples:

- selected local tab;
- text-field contents for a local form;
- palette visibility;
- loading spinner visibility for a local request;
- measured preferred height;
- animation revision;
- temporary validation message;
- locally loaded list values belonging to one screen.

Preferred form:

```swift
final class SearchViewController: ViewController {
    @UState private var query = ""
    @UState private var results: [SearchResult] = []
    @UState private var isLoading = false
}
```

The controller may perform a focused API request and update its own states when no independent domain lifetime or invariant justifies another owner.

### 6.2 Nearest-common composition ownership

Use the nearest ancestor that composes all consumers when state is shared by sibling components.

Examples:

- root workspace owns selected project used by tab bar and content;
- form controller owns a value edited by a custom input view;
- main controller owns current tab used by content and bottom bar;
- chat workspace owns messages used by transcript and composer during a presentation-fixture phase.

Preferred form:

```swift
final class MainViewController: ViewController {
    @UState private var currentTab: Tab = .home
    @UState private var badgeCount = 0

    private lazy var tabBar = BottomTabBar(
        selection: $currentTab,
        badgeCount: $badgeCount
    )
}
```

A child receives only the state it needs:

```swift
final class BottomTabBar: UView {
    private let selection: UState<Tab>
    private let badgeCount: UState<Int>

    init(selection: UState<Tab>, badgeCount: UState<Int>) {
        self.selection = selection
        self.badgeCount = badgeCount
        super.init(frame: .zero)
    }
}
```

Do not pass the entire parent controller or a generic screen model when two state references are sufficient.

### 6.3 Application-wide environment ownership

Use `App` or another explicitly designated application environment owner when state intentionally applies across the application or all relevant windows.

Examples:

- selected theme;
- UI scale;
- locale;
- global accessibility preference;
- active application scene;
- app-wide routing state;
- global presentation policy.

Preferred form:

```swift
final class App: BaseApp {
    @UState var theme: Theme = .system
    @UState var uiScale: CGFloat = 1
}
```

Consumers may access a typed application owner or receive exact app-owned states where explicit injection improves lifecycle or test setup.

Application ownership must not become an excuse for a universal mutable singleton. Only genuinely app-wide environment belongs here.

### 6.4 Runtime/domain ownership

Use a dedicated runtime/domain owner when state:

- must outlive a screen;
- is authoritative for multiple unrelated features;
- coordinates I/O, persistence, concurrency, or recovery;
- enforces business/domain invariants;
- controls credentials, permissions, tools, or external resources;
- has a lifecycle such as session, document, project, conversation, run, or transaction;
- must be restored independently of UI construction.

Examples:

```swift
final class Session {
    @State private var profile = StatefulProfile()
    @State private var activeWorkout = StatefulWorkout()
}
```

```swift
actor ProviderRun {
    // Owns request lifecycle, cancellation, tool turns, and authoritative run state.
}
```

UIKitUltra views bind to exact exposed states or focused operations:

```swift
UText(Session.profile.$name)
    .hidden(Session.profile.$isDisabled)
```

A runtime owner is not a ViewModel. It owns real application behavior and remains meaningful without a particular view.

### 6.5 Immutable values and fixtures

Ordinary structs, enums, identifiers, configuration values, server DTOs, and fixture arrays do not need a mutable state owner until their value changes reactively.

Keep deterministic fixture data immutable and close to its consuming feature or in a pure fixture namespace.

A fixture namespace:

- contains no mutable singleton state;
- performs no I/O;
- has no app authority;
- can be removed or replaced without changing runtime architecture.

## 7. Architecture invariants

### AO1: One authoritative owner

Every mutable value has one authoritative state owner. Consumers share the same reference or use derived state; they do not create mirrored authoritative copies.

### AO2: Nearest natural lifetime

Choose the shortest-lived owner whose lifetime fully covers the required behavior. Do not promote local state to app/session scope without need.

### AO3: Nearest common owner for siblings

State shared by siblings belongs to their nearest common composition owner unless an independent runtime/domain owner already has authority.

### AO4: Exact dependency contracts

A child receives only the `UState` references, immutable values, and callbacks it actually requires. Initializer/property signatures must reveal those dependencies.

### AO5: No default presentation layer

Do not create a ViewModel/PresentationModel solely to move UI state out of a UIKitUltra view or controller.

### AO6: App scope is intentional

Only genuinely application-wide environment belongs to `App`. Local screen/workspace state must not be placed in a global singleton for convenience.

### AO7: Runtime owners require real authority

Dedicated long-lived owners are justified by domain authority, I/O, persistence, concurrency, consistency, security, recovery, or independent lifetime—not by naming convention.

### AO8: Derived state is not duplicated state

Use `.map`, combined states, computed properties, or explicit derivation instead of storing a second mutable value that can drift from its source.

### AO9: Focused writes

When a child needs one action, prefer a focused callback over granting write access to an entire state or owner.

### AO10: Explicit reference flow

State references flow from owners to consumers through construction/composition. Hidden service-location and ambient mutable context are forbidden by default.

### AO11: Fixtures are non-authoritative

Presentation fixtures remain deterministic, immutable, replaceable, and isolated from domain/session/persistence authority.

### AO12: Listener lifecycle follows ownership

The object that installs a listener owns its token/teardown strategy. Longer-lived states require weak captures when consumers have shorter lifetimes.

### AO13: Platform-native lifetime remains authoritative

UIKit/AppKit view/controller/window lifecycle remains the source of UI object lifetime. ASO does not invent a second UI lifecycle.

### AO14: Side effects stay at an explicit boundary

A view/controller may initiate focused side effects appropriate to its scope. Complex or authoritative side effects move to a runtime/domain owner. Side effects must not be hidden inside passive state mappings.

### AO15: State access does not imply object access

Passing `UState<Value>` does not justify passing the owner object. Consumers should not gain unrelated methods/properties.

### AO16: No replacement state bag

Removing a presentation model must not produce a renamed context/store/environment object containing the same unrelated state.

### AO17: Preview dependencies are minimal

A preview constructs only the states, immutable values, and typed environment required by the component under preview.

### AO18: Architecture grows by demonstrated need

Start with local/composition ownership. Introduce runtime layers only when actual behavior, lifetime, consistency, or safety requirements demand them.

## 8. State-placement decision algorithm

For every mutable value, answer in order:

1. **Is it authoritative domain/runtime state?**
   - Does it represent a session, document, project, conversation, provider run, credential, permission, persistence record, or business invariant?
   - Does it need I/O, concurrency, recovery, or a lifetime independent of one screen?
   - If yes, place it in a dedicated runtime/domain owner.

2. **Is it intentionally application-wide?**
   - Must all relevant screens/windows observe the same value?
   - Is it a global preference/environment value?
   - If yes, place it in `App` or a typed app environment owner.

3. **Is it shared by sibling UI components?**
   - Identify their nearest common parent.
   - Place the state in that composition owner.

4. **Is it local to one component?**
   - Place it directly in that `UView`/`ViewController` using `@UState`.

5. **Is it actually derived?**
   - Do not store it. Map or compute it from the authoritative source.

6. **Is it immutable sample/configuration data?**
   - Keep it as a normal value or fixture, not state.

7. **What is the minimum child capability?**
   - read-only derived state;
   - exact writable `UState`;
   - one focused callback;
   - immutable value;
   - dedicated runtime operation.

If the answer is “pass the entire model/context because it is easier,” the placement decision is incomplete.

## 9. Dependency and event flow

ASO does not require a single global reducer, but flow must be explicit.

### Owner-to-consumer data flow

- owner creates/retains state;
- owner passes the same state reference or a mapped derivation to consumers;
- consumers bind UIKitUltra properties declaratively;
- native UIKit/AppKit objects render the resulting state.

```text
Owner UState
   ├── mapped label text
   ├── hidden/size/color binding
   └── exact child UState reference
```

### Consumer-to-owner event flow

Use one of:

1. direct write to an intentionally writable exact `UState`;
2. focused callback for a specific request;
3. method on a dedicated runtime/domain owner;
4. platform action routed to the composition owner.

Examples:

```swift
button.onAction {
    selectedTab.wrappedValue = .settings
}
```

```swift
ChildView(onDeleteRequested: { [weak self] id in
    self?.delete(id)
})
```

Do not expose an entire parent/model merely to call one operation.

### Sibling communication

Siblings do not directly discover each other. Their common owner:

- owns shared state; or
- wires a focused callback from one sibling to another's public operation.

This preserves explicit composition without creating a mediator class whose only job is forwarding UI events.

## 10. Role definitions

### UView

A `UView` may own:

- local reactive UI state;
- local controls/subviews;
- local measurements and animation state;
- local presentation actions;
- exact child state references;
- focused callbacks.

A `UView` should not own:

- credentials;
- persistent database authority;
- cross-feature session authority;
- unrestricted process/network/tool execution;
- a duplicate copy of runtime state.

### ViewController

A `ViewController` is a natural composition and lifecycle owner. It may:

- own screen state;
- compose child views/controllers;
- trigger focused API/service calls;
- update its own states from results;
- own navigation/presentation decisions;
- bridge platform lifecycle events.

Move behavior out only when it has an independent domain/runtime lifetime or complexity—not to satisfy a pattern quota.

### App

`App` owns:

- application lifecycle;
- app-wide scene/window composition;
- intentional app environment state;
- app-level routing or system integration;
- application services whose authority is truly global.

It must not become a generic dump for screen-local state.

### Runtime/domain owner

A runtime/domain owner:

- remains meaningful without one view;
- has explicit authority and invariants;
- exposes exact states and operations;
- isolates I/O/security/concurrency where needed;
- avoids UIKit/AppKit presentation responsibilities unless it is a native document/window owner by design.

### Service/repository/API client

A service executes a focused external operation. It need not own UI state. A screen/controller may call it and update local state, or a runtime owner may call it and update authoritative runtime state.

Avoid wrapping every service call in a ViewModel that only forwards parameters and results.

## 11. `UState` usage rules

### UI code

Prefer `@UState` for mutable UI/application state in UIKitUltra application code. `UState` is the application-facing alias of the reference-semantic `State` engine.

```swift
@UState private var selected = false
```

Pass the projected/reference state expected by the active UIKitUltra API and repository conventions.

### Domain/runtime code

`@State` or `@UState` may be used according to semantic clarity and module conventions. The underlying ownership rules are identical.

### Mapping

Use `.map` for derived presentation values:

```swift
UText(progress.map { "\(Int($0 * 100))%" })
```

Do not keep both `progress` and a mutable `progressLabelText` state.

### Write capability

Passing `UState<Value>` grants mutation. When the child should only request one operation, pass a callback or mapped/read-only expression instead.

### Collections

A stateful collection used by `UForEach` has one owner. Children render values or receive focused operations keyed by identity. Do not create separate collection states per view and synchronize them manually.

## 12. Lifecycle and memory rules

ASO inherits UIKitUltra `State` listener semantics: registration is additive and not automatically idempotent.

Required:

- install listeners once in the intended lifecycle path;
- retain `StateListener` tokens where current API requires it;
- use weak captures when state may outlive the consumer;
- explicitly remove listeners or rely on verified holder teardown according to the concrete API;
- avoid listener installation during repeatedly evaluated builder/configuration paths;
- avoid parent/child cycles through callbacks;
- use identity checks when long-lived owners retain child callbacks/controllers;
- keep delayed/asynchronous fixture actions cancellation/lifetime-safe.

Ownership migration is incomplete if state moves but listener ownership becomes ambiguous.

## 13. Concurrency and side effects

UIKitUltra UI state is normally main-thread/main-actor owned.

Rules:

- UI mutations occur on the appropriate main actor/thread;
- off-main work returns results to the owner before state mutation;
- actors/tasks/services own concurrent operations when required;
- UI state must not be used as an implicit cross-actor synchronization primitive;
- cancellation belongs to the operation/runtime owner;
- security-sensitive operations must not be performed directly by passive views;
- mappings remain pure presentation derivations and must not perform I/O;
- delayed UI fixture actions capture owners weakly and verify current state/revision before mutation.

## 14. Persistence and restoration

Persistence does not automatically change state ownership.

Examples:

- a local form state may be saved by its controller;
- an app-wide theme may persist through app settings;
- a session/project/document owner restores authoritative state;
- a repository stores data but does not become a presentation model.

Persisted values should be restored into the same authoritative owner. Do not create a second persistent “view state store” mirroring owner state unless a separately defined restoration requirement justifies it.

## 15. Cross-platform rules

- Keep shared ownership concepts consistent across UIKit and AppKit.
- Platform-specific owner implementations may differ when lifecycle and native APIs differ.
- Do not invent shared wrapper types that erase important UIKit/AppKit semantics.
- `App`, scene, window, and controller access patterns may be platform-specific but must remain typed and explicit.
- App-wide state must compile coherently in every supported source branch or be intentionally platform-scoped.
- A macOS-only UI feature may have macOS-only local state without polluting mobile owners.

## 16. Previews and tests

### Previews

Construct the smallest valid dependency set:

```swift
Preview {
    BottomTabBar(
        selection: .init(wrappedValue: .home),
        badgeCount: .init(wrappedValue: 0)
    )
}
```

Do not create an entire application state graph to preview one component.

### Focused tests

Test:

- owner state mutation;
- child binding to exact state;
- callback effects;
- derived mappings;
- listener lifecycle;
- absence of duplicated state;
- runtime-owner invariants where applicable.

Do not test private implementation solely to preserve a ViewModel abstraction.

### Integration/UI tests

Use where behavior crosses real navigation, native layout, persistence, runtime, or platform boundaries. ASO does not require speculative test layers for simple reactive bindings.

## 17. Valid patterns

### Local screen state

```swift
final class ContestsViewController: ViewController {
    @UState private var joined: [Contest] = []
    @UState private var available: [Contest] = []
    @UState private var finished: [Contest] = []

    func loadData() {
        API.contests.load().onSuccess { [weak self] response in
            self?.joined = response.joined
            self?.available = response.available
            self?.finished = response.finished
        }
    }
}
```

No `ContestsViewModel` is required unless contest state becomes authoritative outside this screen or gains independent runtime invariants.

### Shared parent state

```swift
final class WorkspaceView: UView {
    @UState private var selectedSessionId = UUID()
    @UState private var statusText = "Ready"

    private lazy var sidebar = SessionSidebarView(
        selectedSessionId: $selectedSessionId,
        onStatus: { [weak self] text in self?.statusText = text }
    )
}
```

### Child-local plus external state

```swift
final class DateInputView: UInputView {
    @UState private var selectedDate = Date()
    private let value: UState<Date?>

    init(value: UState<Date?>) {
        self.value = value
        super.init(.default)
    }
}
```

### Global runtime owner

```swift
final class Session {
    @State private var profile = StatefulProfile()

    static var profile: StatefulProfile {
        shared.profile
    }
}
```

Views bind to exact profile states; they do not receive a `ProfilePresentationModel`.

## 18. Anti-patterns

### Universal presentation model

```swift
final class ScreenPresentationModel {
    let theme: UState<Theme>
    let selectedTab: UState<Tab>
    let formText: UState<String>
    let messages: UState<[Message]>
    let providers: UState<[Provider]>
    // every child receives this object
}
```

Why it fails:

- unrelated ownership scopes are mixed;
- dependency contracts are hidden;
- children gain excessive authority;
- lifetime becomes broader than necessary;
- the object tends to absorb runtime behavior.

### Renamed state bag

Replacing `PresentationModel` with `Context`, `Store`, `Environment`, `Coordinator`, or `Dependencies` while retaining the same unrelated mutable fields does not satisfy ASO.

### Global convenience singleton

Putting screen-local selection, form values, and animation state in `App`/`Session` merely to avoid initializer parameters is forbidden.

### Mirrored state

```swift
@UState var selectedId: UUID
@UState var selectedItem: Item
```

when `selectedItem` can be derived from `selectedId` and items. This creates drift unless a documented invariant requires both.

### Parent-object injection

Passing a parent view/controller to a child solely so the child can mutate a few fields hides dependencies and increases coupling. Pass exact states/callbacks instead.

### Callback service locator

A struct containing dozens of unrelated closures is an all-access context in another form. Use focused callbacks per component contract.

### Passive mapping with side effects

Do not trigger network, persistence, process, or tool operations from `.map` closures intended to derive presentation values.

### Premature runtime extraction

Do not create a repository/store/interactor for local UI state with no independent lifetime, invariant, or I/O boundary.

## 19. Relationship to other architectures

ASO is not presented as universally superior. It is the default architecture that matches UIKitUltra semantics and the maintainer's application style.

| Architecture | Primary organizing idea | ASO relationship |
|---|---|---|
| MVC | Model, View, Controller roles | UIKit/AppKit controllers remain natural composition/lifecycle owners. ASO adds precise reactive state ownership and avoids forcing all presentation state into a separate model. |
| MVVM | View binds to a ViewModel that exposes presentation state/actions | ASO usually binds views directly to their natural owner states. A dedicated object is used only when it has real runtime/domain authority, not as a mandatory screen mirror. |
| MVP | Presenter mediates passive view interactions | ASO allows views/controllers to own local state and focused actions directly. A mediator is added only when coordination complexity justifies an independent owner. |
| VIPER/Clean Architecture | Strict role/module separation | ASO begins with fewer layers and introduces boundaries for real domain, I/O, security, persistence, or independent lifetime. It can coexist with clean domain boundaries without creating presentation boilerplate. |
| Redux/TCA | Central store, actions, reducers, unidirectional updates | ASO uses decentralized natural ownership and reference-semantic state. A reducer/store may still be a valid runtime owner for a domain that genuinely benefits from those invariants. |
| SwiftUI Environment/Observable | Ambient environment and observable object graphs | ASO keeps UIKitUltra dependencies explicit and reference-based. App-wide state may be typed global environment, but local state is not injected ambiently. |
| Coordinator pattern | Navigation flow ownership | Coordinators may be used for complex navigation lifetime. They must not become generic presentation-state bags. |

## 20. When a dedicated state object is justified

Create a separate state-owning object only when at least one strong reason exists:

- state outlives a particular view/controller;
- multiple unrelated screens require the same authoritative state;
- object enforces domain invariants;
- object coordinates asynchronous/concurrent operations;
- persistence/restoration belongs to its lifecycle;
- external resources require ownership and cancellation;
- security/permission boundaries require isolation;
- the object is a document/session/project/conversation/run with independent identity;
- the object can be meaningfully tested and used without one concrete view.

Before creating it, document:

1. authority;
2. lifetime;
3. invariants;
4. I/O/concurrency boundary;
5. exposed exact states;
6. allowed operations;
7. teardown/cancellation;
8. why local/composition/app ownership is insufficient.

“Keeping the view clean” is not enough by itself.

## 21. Migration from presentation-model architecture

1. Inventory every mutable property, immutable fixture, computed value, and method.
2. Classify each as local UI, shared composition, app environment, runtime/domain, derived, or immutable fixture.
3. Move app-wide environment first.
4. Move shared sibling state to the nearest common owner.
5. Move component-local state into each component.
6. Replace model injection with exact state/value/callback contracts.
7. Move real runtime behavior to dedicated owners only when identified.
8. Narrow high-risk components without changing their algorithms.
9. Move fixtures to immutable feature-local namespaces.
10. Delete the empty presentation model.
11. Search for renamed replacement bags.
12. Validate lifecycle, builds, UI behavior, and performance after every step.

Never delete a central model first and then improvise dependencies. Migrate ownership incrementally while keeping the application buildable.

## 22. Review checklist

For every UIKitUltra application patch, reviewers should ask:

### Ownership

- Who owns each new mutable state?
- Does the owner have the shortest correct lifetime?
- Is there exactly one authoritative state?
- Is any state actually derived or immutable?

### Dependencies

- Does each child receive only what it uses?
- Would a callback grant less authority than a writable state?
- Is a parent/model/context being passed for convenience?
- Are dependencies visible in the initializer/property contract?

### Scope

- Is app-global state genuinely global?
- Is a runtime owner justified by real authority/lifetime?
- Are fixtures non-authoritative?
- Has a presentation model been recreated under another name?

### Lifecycle

- Who owns listener tokens?
- Can the state outlive the consumer?
- Are weak captures and teardown correct?
- Can setup register duplicate listeners?

### Side effects

- Is I/O initiated at an explicit boundary?
- Does cancellation belong to the correct owner?
- Are mappings pure?
- Are security-sensitive operations outside passive views?

### Validation

- Can the component be previewed with minimal dependencies?
- Are build/platform boundaries preserved?
- Did ownership changes alter native layout, visual behavior, or performance?
- Do stable docs match actual ownership?

## 23. Audit implications

Architecture audits must fail patches that:

- add a default screen ViewModel/PresentationModel without documented independent authority;
- pass a broad model/context to children that need only a few states/actions;
- duplicate authoritative state;
- move local state to `App`/global singletons for convenience;
- hide dependencies through service location;
- mix immutable fixtures with mutable runtime authority;
- install listeners without ownership/teardown clarity;
- introduce a runtime owner with no independent lifetime/invariant;
- change visual/native behavior as an incidental ownership refactor;
- claim ASO compliance while retaining an equivalent renamed state bag.

A compliant patch should make the owner graph easier to explain than before.
