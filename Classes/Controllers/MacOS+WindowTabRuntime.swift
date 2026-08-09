#if os(macOS)
import AppKit

@MainActor
private struct _WindowTabContent: WindowTabBuilderContent {
    let item: WindowTabBuilderItem

    var windowTabBuilderItem: WindowTabBuilderItem { item }
}

/// A type-erased native window tab exposed to the tab builder runtime.
@MainActor
public protocol AnyWindowTab: AnyObject {
    /// Type-erased stable identity of the tab.
    var anyID: AnyHashable { get }
    /// The AppKit window represented by the tab.
    var window: NSWindow { get }
    /// Whether the tab's content controller has been created.
    var isMaterialized: Bool { get }
    /// Whether native close actions may close this tab.
    var closeAllowed: Bool { get }

    /// Creates the tab's content controller once, if it has a factory.
    func materialize()
}

/// Runtime hooks used by `WindowTabForEach` without erasing the public item ID.
@MainActor
public protocol WindowTabGroupRuntime: AnyObject {
    /// Registers a tab with the runtime.
    func register(tab: AnyWindowTab)
    /// Attaches a dynamic tab collection to the runtime.
    func attach(collection: AnyWindowTabCollection)
    /// Reports a source collection identity change to the runtime.
    func collectionDidChange(
        _ collection: AnyWindowTabCollection,
        oldIDs: [AnyHashable],
        newIDs: [AnyHashable]
    )

    /// Reports a source change together with explicit identity-preserving moves.
    func collectionDidChange(
        _ collection: AnyWindowTabCollection,
        oldIDs: [AnyHashable],
        newIDs: [AnyHashable],
        moves: [WindowTabMove]
    )
}

/// A type-erased dynamic tab collection used by `WindowTabGroup`.
@MainActor
public protocol AnyWindowTabCollection: AnyObject {
    /// Current identity/tab pairs in source order.
    var currentTabs: [(AnyHashable, AnyWindowTab)] { get }

    /// Installs this collection into a tab-group runtime.
    func install(into runtime: any WindowTabGroupRuntime)
    /// Reorders the source collection to match native tab order.
    func reorderSource(to ids: [AnyHashable])
    /// Removes one source item after a native close.
    func removeSourceItem(with id: AnyHashable)
}

public extension WindowTabGroupRuntime {
    /// Falls back to the identity-only callback for custom runtimes.
    func collectionDidChange(
        _ collection: AnyWindowTabCollection,
        oldIDs: [AnyHashable],
        newIDs: [AnyHashable],
        moves: [WindowTabMove]
    ) {
        collectionDidChange(collection, oldIDs: oldIDs, newIDs: newIDs)
    }
}

/// The content protocol used by `WindowTabBuilder`.
@MainActor
public protocol WindowTabBuilderContent {
    /// The erased builder item represented by this value.
    var windowTabBuilderItem: WindowTabBuilderItem { get }
}

/// The type-erased result of a native tab builder expression.
@MainActor
public enum WindowTabBuilderItem {
    /// No tabs in this builder branch.
    case none
    /// One concrete tab.
    case tab(AnyWindowTab)
    /// One dynamic tab collection.
    case collection(AnyWindowTabCollection)
    /// Nested builder items.
    case items([WindowTabBuilderItem])
}

/// A result builder for native windows and dynamic tab collections.
@resultBuilder
@MainActor
public struct WindowTabBuilder {
    /// The closure signature accepted by `WindowTabGroup`'s result builder.
    public typealias Block = () -> WindowTabBuilderContent

    /// Builds an empty tab branch.
    public static func buildBlock() -> WindowTabBuilderContent {
        _WindowTabContent(item: .none)
    }

    /// Builds a branch containing one or more tab expressions.
    public static func buildBlock(_ values: WindowTabBuilderContent...) -> WindowTabBuilderContent {
        _WindowTabContent(item: .items(values.map(\.windowTabBuilderItem)))
    }

    /// Builds an optional tab expression.
    public static func buildIf(_ value: WindowTabBuilderContent?) -> WindowTabBuilderContent {
        _WindowTabContent(item: value.map { .items([$0.windowTabBuilderItem]) } ?? .none)
    }

    /// Builds the first conditional branch.
    public static func buildEither(first value: WindowTabBuilderContent) -> WindowTabBuilderContent {
        _WindowTabContent(item: .items([value.windowTabBuilderItem]))
    }

    /// Builds the second conditional branch.
    public static func buildEither(second value: WindowTabBuilderContent) -> WindowTabBuilderContent {
        _WindowTabContent(item: .items([value.windowTabBuilderItem]))
    }
}
#endif
