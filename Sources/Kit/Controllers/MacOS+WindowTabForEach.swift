#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
/// A dynamic, identity-preserving collection of native tabs.
@MainActor
public final class WindowTabForEach<Item: Identable>: AnyWindowTabCollection, WindowTabBuilderContent {
    /// The closure used once to configure each stable tab instance.
    ///
    /// Use the tab's explicit `UState` overloads for metadata that can change
    /// while the item keeps the same identity; this avoids duplicate listeners
    /// during source-array reorder and replacement updates.
    public typealias ConfigureHandler = (Item, WindowTab<Item.ID>) -> WindowTab<Item.ID>

    /// Applies repeatable direct metadata updates to an existing tab.
    ///
    /// Ultra calls this after initial configuration and after each source
    /// state assignment. Keep this closure to scalar setters; state bindings
    /// belong in `ConfigureHandler`, which runs once per stable identity.
    public typealias UpdateHandler = (Item, WindowTab<Item.ID>) -> Void

    private let items: UState<[Item]>
    private let configure: ConfigureHandler
    private let update: UpdateHandler?
    private let stateHolder = TempStatesHolder()
    private var tabs: [AnyHashable: WindowTab<Item.ID>] = [:]
    private var configuredIDs: Set<AnyHashable> = []
    private var suppressSourceCallback = false

    /// Creates a static tab collection.
    public convenience init(
        _ items: [Item],
        configure: @escaping ConfigureHandler,
        update: UpdateHandler? = nil
    ) {
        self.init(UState(wrappedValue: items), configure: configure, update: update)
    }

    /// Creates a state-backed tab collection with targeted two-way updates.
    public init(
        _ items: UState<[Item]>,
        configure: @escaping ConfigureHandler,
        update: UpdateHandler? = nil
    ) {
        self.items = items
        self.configure = configure
        self.update = update
    }

    /// Current tabs in the same order as the bound source state.
    public var currentTabs: [(AnyHashable, AnyWindowTab)] {
        validateUniqueIDs(in: items.wrappedValue)
        return items.wrappedValue.map { item in
            let tab = makeOrConfigureTab(for: item)
            return (AnyHashable(item[keyPath: Item.idKey]), tab)
        }
    }

    /// Attaches the collection and starts two-way source/topology updates.
    public func install(into runtime: any WindowTabGroupRuntime) {
        runtime.attach(collection: self)
        items.wrappedValue.forEach { item in
            update?(item, makeOrConfigureTab(for: item))
        }
        items.listen { [weak self] old, new in
            guard let self, !self.suppressSourceCallback else { return }
            self.validateUniqueIDs(in: old)
            self.validateUniqueIDs(in: new)
            let oldIDs = old.map { AnyHashable($0[keyPath: Item.idKey]) }
            let newIDs = new.map { AnyHashable($0[keyPath: Item.idKey]) }
            new.forEach { item in
                let tab = self.makeOrConfigureTab(for: item)
                self.update?(item, tab)
            }
            let oldIndexes = Dictionary(uniqueKeysWithValues: oldIDs.enumerated().map { ($0.element, $0.offset) })
            let newIndexes = Dictionary(uniqueKeysWithValues: newIDs.enumerated().map { ($0.element, $0.offset) })
            let moves = newIDs.compactMap { id -> WindowTabMove? in
                guard let fromIndex = oldIndexes[id], let toIndex = newIndexes[id], fromIndex != toIndex else {
                    return nil
                }
                return WindowTabMove(id: id, fromIndex: fromIndex, toIndex: toIndex)
            }
            runtime.collectionDidChange(self, oldIDs: oldIDs, newIDs: newIDs, moves: moves)
            let newSet = Set(newIDs)
            self.tabs = self.tabs.filter { newSet.contains($0.key) }
            self.configuredIDs = self.configuredIDs.filter { newSet.contains($0) }
        }.hold(in: stateHolder)
    }

    /// Applies native reorder to the source array using stable item IDs.
    public func reorderSource(to ids: [AnyHashable]) {
        let oldItems = items.wrappedValue
        validateUniqueIDs(in: oldItems)
        let byID = Dictionary(uniqueKeysWithValues: oldItems.map {
            (AnyHashable($0[keyPath: Item.idKey]), $0)
        })
        guard ids.count == oldItems.count,
              Set(ids) == Set(byID.keys),
              let reordered = Optional(ids.compactMap { byID[$0] }) else { return }
        suppressSourceCallback = true
        items.wrappedValue = reordered
        suppressSourceCallback = false
    }

    /// Removes an item from the source array after a native close.
    public func removeSourceItem(with id: AnyHashable) {
        guard let index = items.wrappedValue.firstIndex(where: {
            AnyHashable($0[keyPath: Item.idKey]) == id
        }) else { return }
        var next = items.wrappedValue
        next.remove(at: index)
        suppressSourceCallback = true
        items.wrappedValue = next
        suppressSourceCallback = false
        tabs.removeValue(forKey: id)
        configuredIDs.remove(id)
    }

    /// Erases this dynamic collection into a builder item.
    public var windowTabBuilderItem: WindowTabBuilderItem { .collection(self) }

    private func makeOrConfigureTab(for item: Item) -> WindowTab<Item.ID> {
        let id = item[keyPath: Item.idKey]
        let tab = tabs[AnyHashable(id)] ?? WindowTab(id: id)
        let anyID = AnyHashable(id)
        if configuredIDs.insert(anyID).inserted {
            let configured = configure(item, tab)
            precondition(configured === tab, "WindowTabForEach configuration must preserve tab identity")
        }
        tabs[id] = tab
        return tab
    }

    private func validateUniqueIDs(in items: [Item]) {
        let ids = items.map { AnyHashable($0[keyPath: Item.idKey]) }
        precondition(
            Set(ids).count == ids.count,
            "WindowTabForEach source items must have unique Identable IDs"
        )
    }
}
#endif
#endif
