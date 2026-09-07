#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
private final class _WindowTabNotificationToken: @unchecked Sendable {
    let value: NSObjectProtocol

    init(value: NSObjectProtocol) {
        self.value = value
    }
}

@MainActor
private protocol _WindowTabReconciliationSink: AnyObject {
    func scheduleNativeReconciliation()
}

@MainActor
private final class _WindowTabReconciliationRelay: @unchecked Sendable {
    weak var owner: (any _WindowTabReconciliationSink)?

    init(owner: any _WindowTabReconciliationSink) {
        self.owner = owner
    }

    func schedule() {
        owner?.scheduleNativeReconciliation()
    }
}

/// The application-level disposition for a native last-tab close request.
@MainActor
public enum WindowTabCloseDecision {
    /// Continue with AppKit's normal tab/window close operation.
    case allow
    /// Reject the request and let UIKitPlus provide the standard close beep.
    case deny
    /// The application handled the request itself; suppress native closing
    /// without producing a beep.
    case handled
}

/// A native AppKit group with declarative topology and lazy tab content.
@MainActor
public final class WindowTabGroup<ID: Hashable>: AppBuilderContent, AnyWindowTabGroup, WindowTabGroupRuntime {
    /// The app-builder item that activates this native tab group.
    public var appBuilderContent: AppBuilderItem { .windowTabGroups([self]) }
    /// Two-way logical topology state for ordering, groups, and selection.
    public let topologyState: UState<WindowTabTopology<ID>>

    private let stateBindingHolder = TempStatesHolder()
    private var collections: [AnyWindowTabCollection] = []
    private var tabs: [AnyHashable: AnyWindowTab] = [:]
    private var tabRegistrationOrder: [AnyHashable] = []
    private var groupObservers: [NSKeyValueObservation] = []
    private var windowObservers: [_WindowTabNotificationToken] = []
    private var windowConfigurations: [(Window) -> Window] = []
    private var windowProxies: [ObjectIdentifier: WindowProxy] = [:]
    private var delegateProxies: [ObjectIdentifier: _WindowTabDelegateProxy] = [:]
    private struct PendingClosedTab {
        let tab: AnyWindowTab
        let windowProxy: WindowProxy?
        let delegateProxy: _WindowTabDelegateProxy?
    }
    private var pendingClosedTabs: [AnyHashable: PendingClosedTab] = [:]
    private lazy var reconciliationRelay = _WindowTabReconciliationRelay(owner: self)
    private var isApplyingTopology = false
    private var activationCompleted = false
    private var pendingNativeReconciliation = false
    private var onNewTabHandler: ((UUID?) -> Void)?
    private var onLastTabCloseHandler:
        ((ID, UUID, NSWindow) -> WindowTabCloseDecision)?
    private var requestedTabOverviewVisibility: Bool?

    deinit {
        groupObservers.forEach { $0.invalidate() }
        windowObservers.forEach { NotificationCenter.default.removeObserver($0.value) }
    }

    /// Creates a group with an internally retained topology state.
    public init(
        _ topology: WindowTabTopology<ID>,
        @WindowTabBuilder content: @escaping WindowTabBuilder.Block
    ) {
        topologyState = UState(wrappedValue: topology)
        process(content().windowTabBuilderItem)
        installTopologyListener()
    }

    /// Creates a group bound to the supplied two-way topology state.
    public init(
        _ topology: UState<WindowTabTopology<ID>>,
        @WindowTabBuilder content: @escaping WindowTabBuilder.Block
    ) {
        topologyState = topology
        process(content().windowTabBuilderItem)
        installTopologyListener()
    }

    /// Installs the group into UIKitPlus `AppBuilder` and materializes its native windows.
    public func activate() {
        guard !activationCompleted else { return }
        activationCompleted = true
        normalizeTopologyToRegisteredTabs()
        applyTopologyToNative(topologyState.wrappedValue, presentSelection: true)
        observeNativeGroups()
    }

    /// Configures each registered window and retains its proxy for live state bindings.
    ///
    /// The closure is applied immediately to existing windows and to every
    /// subsequently registered window. State-backed modifiers remain live for
    /// the lifetime of the tab group, including after a tab changes groups.
    @discardableResult
    public func configureEachWindow(_ configure: @escaping (Window) -> Window) -> Self {
        windowConfigurations.append(configure)
        tabs.values.forEach { applyWindowConfiguration(to: $0) }
        return self
    }

    /// Handles the native tab-bar plus button and `newWindowForTab(_:)` responder action.
    @discardableResult
    public func onNewTab(_ handler: @escaping (_ groupID: UUID?) -> Void) -> Self {
        onNewTabHandler = handler
        return self
    }

    /// Intercepts a user close request when this is the only tab in its
    /// logical native group.
    ///
    /// Return `.allow` to continue with AppKit's normal close, `.deny` to
    /// reject the close and beep, or `.handled` when the application has
    /// replaced the tab itself and the native close must be suppressed. The
    /// callback runs for the native close button, Command-W, and
    /// `requestCloseTab(_:)`; source-array removals remain force-close
    /// operations and do not invoke it.
    @discardableResult
    public func onLastTabClose(
        _ handler: @escaping (
            _ tabID: ID,
            _ groupID: UUID,
            _ window: NSWindow
        ) -> WindowTabCloseDecision
    ) -> Self {
        onLastTabCloseHandler = handler
        return self
    }

    /// Selects a registered tab and updates the bound topology.
    @discardableResult
    public func selectTab(_ id: ID) -> Self {
        topologyState.wrappedValue = topologyState.wrappedValue.selecting(id)
        return self
    }

    /// Requests a tab close through its current close policy.
    @discardableResult
    public func requestCloseTab(_ id: ID) -> Self {
        let anyID = AnyHashable(id)
        guard let tab = tabs[anyID] else { return self }
        switch closeDecision(window: tab.window) {
        case .handled:
            return self
        case .deny:
            NSSound.beep()
            return self
        case .allow:
            tab.window.performClose(nil)
            return self
        }
    }

    /// Moves a tab to a target logical group and index.
    @discardableResult
    public func moveTab(_ id: ID, to groupID: UUID, at index: Int) -> Self {
        topologyState.wrappedValue = topologyState.wrappedValue.moving(id, to: groupID, at: index)
        return self
    }

    /// Toggles the native tab bar for the active window.
    @discardableResult
    public func toggleTabBar() -> Self {
        activeWindow?.toggleTabBar(nil)
        return self
    }

    /// Shows AppKit's native tab bar for the active window when it is hidden.
    ///
    /// AppKit hides the native bar automatically when a group contains one
    /// window. This idempotent counterpart to `toggleTabBar()` keeps the
    /// discoverable tab affordance (including the plus button) available for
    /// singleton groups and detached project windows.
    @discardableResult
    public func showTabBar() -> Self {
        if let window = activeWindow {
            ensureTabBarVisible(for: window)
        }
        return self
    }

    /// Toggles AppKit's native tab overview for the active window.
    @discardableResult
    public func toggleTabOverview() -> Self {
        activeWindow?.toggleTabOverview(nil)
        return self
    }

    /// Sets whether the active native group's tab overview is visible.
    ///
    /// The requested value is retained until native activation makes the
    /// active group available. Later calls replace the requested value.
    @discardableResult
    public func tabOverviewVisible(_ value: Bool) -> Self {
        requestedTabOverviewVisibility = value
        applyRequestedTabOverviewVisibility()
        return self
    }

    /// Binds the active native group's tab-overview visibility one way to a
    /// Boolean state. The current value is applied immediately; repeated calls
    /// add bindings held by the group until teardown.
    @discardableResult
    public func tabOverviewVisible(_ state: UState<Bool>) -> Self {
        _ = tabOverviewVisible(state.wrappedValue)
        state.listen { [weak self] in _ = self?.tabOverviewVisible($0) }
            .hold(in: stateBindingHolder)
        return self
    }

    /// The native window currently selected in the active logical group.
    public var activeWindow: NSWindow? {
        guard let activeID = topologyState.wrappedValue.activeGroupID,
              let group = topologyState.wrappedValue.groups.first(where: { $0.id == activeID }) else {
            return nil
        }
        return tabs[AnyHashable(group.selectedTabID)]?.window
    }

    /// The active AppKit tab group, when the logical active group is native.
    ///
    /// This is a read-only escape hatch for AppKit APIs that UIKitPlus does
    /// not reinterpret. Use the topology modifiers for membership, ordering,
    /// and selection changes so the caller-owned state remains authoritative.
    public var activeNativeGroup: NSWindowTabGroup? {
        activeWindow?.tabGroup
    }

    /// The active AppKit group's windows in native leading-to-trailing order.
    public var activeNativeWindows: [NSWindow] {
        activeNativeGroup?.windows ?? activeWindow.map { [$0] } ?? []
    }

    /// Whether AppKit currently displays the active group's tab bar.
    public var isTabBarVisible: Bool {
        activeNativeGroup?.isTabBarVisible ?? false
    }

    /// Whether AppKit currently displays the active group's tab overview.
    public var isTabOverviewVisible: Bool {
        activeNativeGroup?.isOverviewVisible ?? false
    }

    /// Returns the native AppKit group containing a registered window.
    public func nativeGroup(for window: NSWindow? = nil) -> NSWindowTabGroup? {
        (window ?? activeWindow)?.tabGroup
    }

    /// Returns the logical native-group identity containing the supplied
    /// AppKit window. The lookup uses the current native group membership, so
    /// it remains correct immediately after a tab is detached or reattached,
    /// before the deferred KVO reconciliation pass runs.
    public func nativeGroupID(for window: NSWindow?) -> UUID? {
        guard let window else { return topologyState.wrappedValue.activeGroupID }
        let nativeWindows = window.tabGroup?.windows ?? [window]
        let nativeIDs = Set(nativeWindows.compactMap { nativeTabID(for: $0) })
        guard !nativeIDs.isEmpty else { return topologyState.wrappedValue.activeGroupID }

        return topologyState.wrappedValue.groups.first { group in
            Set(group.tabIDs.map { AnyHashable($0) }) == nativeIDs
        }?.id
    }

    /// Reconciles declarative topology with AppKit immediately.
    ///
    /// Native tab actions are delivered before the next queued KVO pass. Call
    /// this at command-routing boundaries (for example, Cmd+T) when the
    /// command must target the window that is currently key right now. Pass
    /// the action's source window when AppKit has just detached a tab; this
    /// preserves the detached group's identity even before key-window KVO is
    /// delivered.
    @discardableResult
    public func synchronizeNativeTopology(preferredWindow: NSWindow? = nil) -> Self {
        guard activationCompleted else { return self }
        pendingNativeReconciliation = false
        reconcileFromNative(preferredWindow: preferredWindow)
        return self
    }

    // MARK: WindowTabGroupRuntime

    /// Registers one concrete tab and installs its close/plus delegate proxy.
    public func register(tab: AnyWindowTab) {
        let id = tab.anyID
        precondition(tabs[id] == nil, "WindowTabGroup received a duplicate tab ID")
        tabs[id] = tab
        tabRegistrationOrder.append(id)
        let proxy = _WindowTabDelegateProxy(
            group: self,
            sourceWindow: tab.window,
            forward: tab.window.delegate
        )
        delegateProxies[ObjectIdentifier(tab.window)] = proxy
        tab.window.delegate = proxy
        applyWindowConfiguration(to: tab)
    }

    /// Attaches a dynamic collection and registers its current tabs.
    public func attach(collection: AnyWindowTabCollection) {
        guard !collections.contains(where: { $0 === collection }) else { return }
        collections.append(collection)
        collection.currentTabs.forEach { register(tab: $0.1) }
    }

    /// Applies a source identity change to the native group.
    public func collectionDidChange(
        _ collection: AnyWindowTabCollection,
        oldIDs: [AnyHashable],
        newIDs: [AnyHashable]
    ) {
        collectionDidChange(collection, oldIDs: oldIDs, newIDs: newIDs, moves: [])
    }

    /// Applies a source identity change and its explicit move diff.
    public func collectionDidChange(
        _ collection: AnyWindowTabCollection,
        oldIDs: [AnyHashable],
        newIDs: [AnyHashable],
        moves: [WindowTabMove]
    ) {
        // The move diff is computed by WindowTabForEach before this callback;
        // the complete new identity order is also required to reconcile adds
        // and removals in one pass.
        _ = moves
        let oldSet = Set(oldIDs)
        let newSet = Set(newIDs)
        oldSet.subtracting(newSet).forEach { closeTab($0, force: true) }
        collection.currentTabs.forEach { pair in
            if tabs[pair.0] == nil { register(tab: pair.1) }
        }
        normalizeTopologyToRegisteredTabs()
        // Normalize first so source additions receive stable logical slots;
        // then fill every existing collection slot with the exact new order.
        reorderTopology(for: newIDs)
        normalizeTopologyToRegisteredTabs()
        if activationCompleted {
            applyTopologyToNative(topologyState.wrappedValue, presentSelection: false)
        }
    }

    // MARK: Private runtime

    private func process(_ item: WindowTabBuilderItem) {
        switch item {
        case .none:
            break
        case .tab(let tab):
            register(tab: tab)
        case .collection(let collection):
            collection.install(into: self)
        case .items(let items):
            items.forEach(process)
        }
    }

    private func applyWindowConfiguration(to tab: AnyWindowTab) {
        guard !windowConfigurations.isEmpty else { return }
        let key = ObjectIdentifier(tab.window)
        let window = windowProxies[key] ?? WindowProxy(window: tab.window)
        windowProxies[key] = window
        windowConfigurations.forEach { _ = $0(window) }
    }

    private func installTopologyListener() {
        topologyState.listen { [weak self] _, new in
            guard let self, !self.isApplyingTopology else { return }
            self.normalizeTopologyToRegisteredTabs()
            guard self.activationCompleted else { return }
            self.applyTopologyToNative(new, presentSelection: true)
        }.hold(in: stateBindingHolder)
    }

    private func normalizeTopologyToRegisteredTabs() {
        let registered = tabRegistrationOrder.filter { tabs[$0] != nil }
        guard !registered.isEmpty else {
            if !topologyState.wrappedValue.groups.isEmpty {
                topologyState.wrappedValue = .empty
            }
            return
        }

        let current = topologyState.wrappedValue
        var groups: [WindowTabTopology<ID>.Group] = []
        var seen: Set<AnyHashable> = []

        for group in current.groups {
            let ids = group.tabIDs.compactMap { id -> ID? in
                let any = AnyHashable(id)
                guard registered.contains(any), !seen.contains(any) else { return nil }
                seen.insert(any)
                return id
            }
            guard !ids.isEmpty else { continue }
            let selected = ids.contains(group.selectedTabID) ? group.selectedTabID : ids[0]
            groups.append(.init(id: group.id, tabIDs: ids, selectedTabID: selected))
        }

        let missing = registered.filter { !seen.contains($0) }
        if groups.isEmpty {
            let typed = missing.compactMap { $0.base as? ID }
            groups = typed.isEmpty ? [] : [
                .init(id: UUID(), tabIDs: typed, selectedTabID: typed[0])
            ]
        } else if !missing.isEmpty {
            let typed = missing.compactMap { $0.base as? ID }
            if let first = groups.first, !typed.isEmpty {
                groups[0] = .init(
                    id: first.id,
                    tabIDs: first.tabIDs + typed,
                    selectedTabID: first.selectedTabID
                )
            }
        }

        let active = current.activeGroupID.flatMap { id in groups.contains { $0.id == id } ? id : nil }
            ?? groups.first?.id
        let normalized = WindowTabTopology<ID>(groups: groups, activeGroupID: active)
        if normalized != current {
            isApplyingTopology = true
            topologyState.wrappedValue = normalized
            isApplyingTopology = false
        }
    }

    private func reorderTopology(for collectionIDs: [AnyHashable]) {
        guard !collectionIDs.isEmpty else { return }
        let sourceOrder = Dictionary(
            uniqueKeysWithValues: collectionIDs.enumerated().map { ($0.element, $0.offset) }
        )
        let current = topologyState.wrappedValue
        let groups = current.groups.map { group -> WindowTabTopology<ID>.Group in
            // Source-array updates must not flatten native groups. Reorder
            // only the tabs that already belong to this group; group
            // membership is owned by WindowTabTopology and native detach/
            // reattach reconciliation, not by the collection's flat order.
            let ids = group.tabIDs.sorted {
                (sourceOrder[AnyHashable($0)] ?? Int.max)
                    < (sourceOrder[AnyHashable($1)] ?? Int.max)
            }
            return .init(id: group.id, tabIDs: ids, selectedTabID: ids.contains(group.selectedTabID) ? group.selectedTabID : ids[0])
        }
        guard groups != current.groups else { return }
        isApplyingTopology = true
        topologyState.wrappedValue = .init(groups: groups, activeGroupID: current.activeGroupID)
        isApplyingTopology = false
    }

    private func applyTopologyToNative(
        _ topology: WindowTabTopology<ID>,
        presentSelection: Bool
    ) {
        guard !tabs.isEmpty else { return }
        isApplyingTopology = true
        defer { isApplyingTopology = false }

        // Materialize selected content before AppKit changes the visible
        // native selection. The selected tab can otherwise draw its empty
        // pre-materialization window while the controller is being built.
        materializeSelections(in: topology)

        // Keep already-detached native groups intact. Removing every window
        // from every group first looks deterministic, but AppKit may reuse a
        // just-emptied NSWindowTabGroup when the next window is inserted; a
        // detached singleton then gets merged back into the source group.
        // Instead, each desired logical group claims one existing native group
        // and only windows that actually move are removed.
        let desiredGroups: [(model: WindowTabTopology<ID>.Group, windows: [NSWindow])] =
            topology.groups.compactMap { model in
                let windows = model.tabIDs.compactMap { tabs[AnyHashable($0)]?.window }
                guard !windows.isEmpty else { return nil }
                return (model, windows)
            }
        var claimedNativeGroups: Set<ObjectIdentifier> = []
        var nativeTargets: [UUID: NSWindowTabGroup] = [:]

        for desired in desiredGroups {
            let candidate = desired.windows.lazy.compactMap(\.tabGroup).first { nativeGroup in
                claimedNativeGroups.insert(ObjectIdentifier(nativeGroup)).inserted
            }
            if let candidate {
                nativeTargets[desired.model.id] = candidate
            }
        }
        for desired in desiredGroups {
            let windows = desired.windows
            guard let first = windows.first else { continue }
            first.tabbingMode = .preferred
            let group = nativeTargets[desired.model.id]
            let groupFrame = first.frame

            if let group {
                let desiredSet = Set(windows.map(ObjectIdentifier.init))
                group.windows
                    .filter { !desiredSet.contains(ObjectIdentifier($0)) }
                    .forEach { group.removeWindow($0) }

                for (index, window) in windows.enumerated() {
                    if window.tabGroup !== group {
                        window.tabGroup?.removeWindow(window)
                        window.setFrame(groupFrame, display: false)
                        group.insertWindow(window, at: min(index, group.windows.count))
                    } else if group.windows.firstIndex(of: window) != index {
                        group.removeWindow(window)
                        group.insertWindow(window, at: min(index, group.windows.count))
                    }
                }
            } else {
                // No existing group can be reused (the logical topology split
                // one old group into multiple groups). Explicitly ungroup the
                // desired windows, then let AppKit create a fresh group from
                // the first window.
                windows.forEach { $0.tabGroup?.removeWindow($0) }
                for (index, window) in windows.dropFirst().enumerated() {
                    window.setFrame(groupFrame, display: false)
                    first.addTabbedWindow(window, ordered: .above)
                    if let nativeGroup = first.tabGroup {
                        nativeGroup.insertWindow(window, at: index + 1)
                    }
                }
            }

            if let selected = tabs[AnyHashable(desired.model.selectedTabID)]?.window,
               let nativeGroup = first.tabGroup {
                nativeGroup.selectedWindow = selected
            }

            if desired.model.tabIDs.count == 1 {
                ensureTabBarVisible(for: first)
                first.orderFront(nil)
            }
        }

        if presentSelection,
           let activeID = topology.activeGroupID,
           let activeGroup = topology.groups.first(where: { $0.id == activeID }),
           let selected = tabs[AnyHashable(activeGroup.selectedTabID)]?.window {
            selected.makeKeyAndOrderFront(nil)
        }

        applyRequestedTabOverviewVisibility()

        // A source-array insertion can create the first native group after
        // activation; refresh KVO coverage after every native topology write.
        observeNativeGroups()
    }

    private func observeNativeGroups() {
        groupObservers.forEach { $0.invalidate() }
        groupObservers.removeAll()
        windowObservers.forEach { NotificationCenter.default.removeObserver($0.value) }
        windowObservers.removeAll()
        var observed: Set<ObjectIdentifier> = []
        for tab in tabs.values {
            windowObservers.append(
                _WindowTabNotificationToken(value: NotificationCenter.default.addObserver(
                    forName: NSWindow.didBecomeKeyNotification,
                    object: tab.window,
                    queue: .main
                ) { [relay = reconciliationRelay] _ in
                    Task { @MainActor in relay.schedule() }
                })
            )
            guard let group = tab.window.tabGroup else { continue }
            let identifier = ObjectIdentifier(group)
            guard observed.insert(identifier).inserted else { continue }
            groupObservers.append(group.observe(\.windows, options: [.new]) { [relay = reconciliationRelay] _, _ in
                Task { @MainActor in relay.schedule() }
            })
            groupObservers.append(group.observe(\.selectedWindow, options: [.new]) { [relay = reconciliationRelay] _, _ in
                Task { @MainActor in relay.schedule() }
            })
        }
    }

    fileprivate func scheduleNativeReconciliation() {
        guard activationCompleted, !isApplyingTopology, !pendingNativeReconciliation else { return }
        pendingNativeReconciliation = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.pendingNativeReconciliation = false
            self.reconcileFromNative()
        }
    }

    private func reconcileFromNative(preferredWindow: NSWindow? = nil) {
        guard !isApplyingTopology else { return }
        let previous = topologyState.wrappedValue
        var nativeGroups: [(windows: [NSWindow], selected: NSWindow?)] = []
        var seenGroups: Set<ObjectIdentifier> = []

        for tabID in previous.tabIDs {
            guard let window = tabs[AnyHashable(tabID)]?.window else { continue }
            if let group = window.tabGroup {
                let identifier = ObjectIdentifier(group)
                guard seenGroups.insert(identifier).inserted else { continue }
                nativeGroups.append((group.windows, group.selectedWindow))
            } else {
                nativeGroups.append(([window], window))
            }
        }

        // AppKit has already switched its selected window by the time KVO is
        // delivered. Build that controller before the next display pass so a
        // first visit cannot expose a transparent/empty native window.
        nativeGroups.forEach { native in
            guard let selected = native.selected,
                  let tab = tabs.first(where: { $0.value.window === selected })?.value else {
                return
            }
            tab.materialize()
        }

        var usedPrevious: Set<UUID> = []
        var groups: [WindowTabTopology<ID>.Group] = []
        for native in nativeGroups {
            let ids = native.windows.compactMap { window in
                tabs.first { $0.value.window === window }?.key.base as? ID
            }
            guard !ids.isEmpty else { continue }
            let previousGroup = previous.groups
                .filter { !usedPrevious.contains($0.id) }
                .max { lhs, rhs in
                    lhs.tabIDs.filter(ids.contains).count < rhs.tabIDs.filter(ids.contains).count
                }
            let groupID = previousGroup?.id ?? UUID()
            if let previousGroup { usedPrevious.insert(previousGroup.id) }
            let selected = native.selected.flatMap { selectedWindow in
                tabs.first { $0.value.window === selectedWindow }?.key.base as? ID
            } ?? ids[0]
            groups.append(.init(id: groupID, tabIDs: ids, selectedTabID: selected))
        }

        guard !groups.isEmpty else { return }
        let preferredGroupID = preferredWindow.flatMap { window in
            nativeGroups.firstIndex { native in native.windows.contains { $0 === window } }
        }.flatMap { index in groups.indices.contains(index) ? groups[index].id : nil }
        let activeGroupID = preferredGroupID
            ?? groups.first { group in
                group.tabIDs.contains { id in tabs[AnyHashable(id)]?.window.isKeyWindow == true }
            }?.id
            ?? previous.activeGroupID.flatMap { id in groups.contains { $0.id == id } ? id : nil }
            ?? groups[0].id
        let next = WindowTabTopology(groups: groups, activeGroupID: activeGroupID)
        isApplyingTopology = true
        topologyState.wrappedValue = next
        isApplyingTopology = false
        updateCollectionOrders(from: next)
        materializeSelections(in: next)
        ensureTabBarsVisible(in: next)
        observeNativeGroups()
    }

    private func updateCollectionOrders(from topology: WindowTabTopology<ID>) {
        for collection in collections {
            let collectionIDs = Set(collection.currentTabs.map(\.0))
            let ordered = topology.tabIDs.compactMap { id -> AnyHashable? in
                let any = AnyHashable(id)
                return collectionIDs.contains(any) ? any : nil
            }
            collection.reorderSource(to: ordered)
        }
    }

    private func closeTab(_ anyID: AnyHashable, force: Bool) {
        guard let tab = tabs.removeValue(forKey: anyID) else { return }
        tabRegistrationOrder.removeAll { $0 == anyID }
        // Clear the proxy before closing the native window. Otherwise AppKit
        // can send its close notifications to a proxy that was already
        // released from `delegateProxies`, leaving a dangling delegate.
        let ownership = detachWindowOwnership(from: tab.window)
        retainPendingClose(anyID, tab: tab, ownership: ownership)
        let nextTopology: WindowTabTopology<ID>
        if let id = anyID.base as? ID {
            nextTopology = topologyState.wrappedValue.removing(id)
        } else {
            nextTopology = topologyState.wrappedValue
        }
        isApplyingTopology = true
        topologyState.wrappedValue = nextTopology
        isApplyingTopology = false
        collections.forEach { $0.removeSourceItem(with: anyID) }
        if force {
            tab.window.close()
        } else {
            tab.window.performClose(nil)
        }
    }

    fileprivate func closeDecision(window: NSWindow) -> WindowTabCloseDecision {
        guard let tab = tabs.first(where: { $0.value.window === window })?.value else {
            return .allow
        }
        guard tab.closeAllowed else { return .deny }

        guard let onLastTabCloseHandler,
              let tabID = tabs.first(where: { $0.value.window === window })?.key.base as? ID,
              let group = topologyState.wrappedValue.groups.first(where: {
                  $0.tabIDs.count == 1 && $0.tabIDs.contains(tabID)
              }) else {
            return .allow
        }

        return onLastTabCloseHandler(tabID, group.id, window)
    }

    fileprivate func didClose(window: NSWindow) {
        guard let anyID = tabs.first(where: { $0.value.window === window })?.key else { return }
        guard tabs[anyID]?.closeAllowed != false else { return }
        guard let id = anyID.base as? ID else { return }
        guard let tab = tabs.removeValue(forKey: anyID) else { return }
        tabRegistrationOrder.removeAll { $0 == anyID }
        // `windowWillClose` is currently executing on the delegate proxy, so
        // detach the native delegate first and keep the proxy alive through
        // the callback's `withExtendedLifetime` scope below.
        let ownership = detachWindowOwnership(from: window)
        retainPendingClose(anyID, tab: tab, ownership: ownership)
        isApplyingTopology = true
        topologyState.wrappedValue = topologyState.wrappedValue.removing(id)
        isApplyingTopology = false
        collections.forEach { $0.removeSourceItem(with: anyID) }
        normalizeTopologyToRegisteredTabs()
        if activationCompleted {
            applyTopologyToNative(topologyState.wrappedValue, presentSelection: true)
        } else {
            observeNativeGroups()
        }
    }

    fileprivate func newWindowForTab(from sourceWindow: NSWindow?) {
        synchronizeNativeTopology(preferredWindow: sourceWindow)
        // Reconciliation derives activeGroupID from the native key window;
        // use that authoritative selection after the synchronous pass rather
        // than a potentially stale identity lookup during AppKit's action.
        onNewTabHandler?(topologyState.wrappedValue.activeGroupID)
    }

    private func materializeSelections(in topology: WindowTabTopology<ID>) {
        topology.groups.forEach { group in
            tabs[AnyHashable(group.selectedTabID)]?.materialize()
        }
    }

    private func ensureTabBarsVisible(in topology: WindowTabTopology<ID>) {
        topology.groups
            .filter { $0.tabIDs.count == 1 }
            .compactMap { tabs[AnyHashable($0.tabIDs[0])]?.window }
            .forEach(ensureTabBarVisible(for:))
    }

    private func ensureTabBarVisible(for window: NSWindow) {
        guard window.tabGroup?.isTabBarVisible != true else { return }
        window.toggleTabBar(nil)
    }

    private func applyRequestedTabOverviewVisibility() {
        guard let requestedTabOverviewVisibility,
              let tabGroup = activeWindow?.tabGroup else { return }
        tabGroup.isOverviewVisible = requestedTabOverviewVisibility
    }

    private func nativeTabID(for window: NSWindow) -> AnyHashable? {
        tabs.first { $0.value.window === window }?.key
    }

    private func detachWindowOwnership(
        from window: NSWindow
    ) -> (windowProxy: WindowProxy?, delegateProxy: _WindowTabDelegateProxy?) {
        let windowID = ObjectIdentifier(window)
        let delegateProxy = delegateProxies.removeValue(forKey: windowID)
        if let delegateProxy {
            delegateProxy.restoreDelegate(on: window)
        }
        return (
            windowProxy: windowProxies.removeValue(forKey: windowID),
            delegateProxy: delegateProxy
        )
    }

    private func retainPendingClose(
        _ id: AnyHashable,
        tab: AnyWindowTab,
        ownership: (windowProxy: WindowProxy?, delegateProxy: _WindowTabDelegateProxy?)
    ) {
        pendingClosedTabs[id] = .init(
            tab: tab,
            windowProxy: ownership.windowProxy,
            delegateProxy: ownership.delegateProxy
        )
        DispatchQueue.main.async { [weak self] in
            self?.pendingClosedTabs.removeValue(forKey: id)
        }
    }

}

/// A type-erased app-builder item retained by `UIKitPlus.App`.
@MainActor
public protocol AnyWindowTabGroup: AnyObject {
    /// Activates the group's native windows and observers.
    func activate()
}

@MainActor
private final class _WindowTabDelegateProxy: NSObject, NSWindowDelegate {
    weak var group: (any WindowTabGroupRuntime)?
    weak var sourceWindow: NSWindow?
    // NSObject's Objective-C forwarding hooks are nonisolated. AppKit calls
    // them synchronously on the main thread, so this weak bridge avoids
    // crossing the actor boundary while preserving the delegate's lifetime.
    // [PA1][RT5]
    nonisolated(unsafe) weak var forward: NSWindowDelegate?

    init(
        group: any WindowTabGroupRuntime,
        sourceWindow: NSWindow,
        forward: NSWindowDelegate?
    ) {
        self.group = group
        self.sourceWindow = sourceWindow
        self.forward = forward
        super.init()
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        let decision = (group as? _WindowTabCloseRuntime)?.closeDecision(window: sender) ?? .allow
        switch decision {
        case .handled:
            return false
        case .deny:
            NSSound.beep()
            return false
        case .allow:
            break
        }
        return forward?.windowShouldClose?(sender) ?? true
    }

    func windowWillClose(_ notification: Notification) {
        withExtendedLifetime(self) {
            if let window = notification.object as? NSWindow {
                (group as? _WindowTabCloseRuntime)?.didClose(window: window)
            }
            forward?.windowWillClose?(notification)
        }
    }

    /// Receives AppKit's native tab-bar plus action.
    @objc func newWindowForTab(_ sender: Any?) {
        (group as? _WindowTabNewTabRuntime)?.newWindowForTab(from: sourceWindow)
    }

    override func responds(to selector: Selector!) -> Bool {
        if selector == #selector(windowShouldClose(_:))
            || selector == #selector(windowWillClose(_:))
            || #selector(newWindowForTab(_:)) == selector {
            return true
        }
        return forward?.responds(to: selector) == true || super.responds(to: selector)
    }

    override func forwardingTarget(for selector: Selector!) -> Any? {
        if selector == #selector(windowShouldClose(_:))
            || selector == #selector(windowWillClose(_:))
            || #selector(newWindowForTab(_:)) == selector {
            return nil
        }
        if forward?.responds(to: selector) == true {
            return forward
        }
        return super.forwardingTarget(for: selector)
    }

    fileprivate func restoreDelegate(on window: NSWindow) {
        window.delegate = forward
    }
}

@MainActor
private protocol _WindowTabCloseRuntime: AnyObject {
    func closeDecision(window: NSWindow) -> WindowTabCloseDecision
    func didClose(window: NSWindow)
}

@MainActor
private protocol _WindowTabNewTabRuntime: AnyObject {
    func newWindowForTab(from sourceWindow: NSWindow?)
}

/// A lightweight proxy used by group-level window configuration closures.
@MainActor
private final class WindowProxy: Window {
    init(window: NSWindow) {
        super.init(existing: window)
    }
}

extension WindowTabGroup: _WindowTabCloseRuntime {}
extension WindowTabGroup: _WindowTabNewTabRuntime {}
extension WindowTabGroup: _WindowTabReconciliationSink {}

extension WindowTabGroup: WindowTabBuilderContent {
    /// Groups are app-builder roots rather than nested tab expressions.
    public var windowTabBuilderItem: WindowTabBuilderItem { .none }
}
#endif
#endif
