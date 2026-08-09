#if os(macOS)
import AppKit
import UniformTypeIdentifiers
import XCTest
@testable import UIKitPlus

@MainActor
final class MacOSWindowTabsDeclarativeTests: XCTestCase {
    private struct Item: Identable {
        static var idKey: KeyPath<Item, Int> { \Item.id }
        let id: Int
        let title: String

        init(id: Int, title: String = "") {
            self.id = id
            self.title = title
        }
    }

    private final class ForwardingDelegate: NSObject, NSWindowDelegate {
        var resizeCount = 0

        func windowDidResize(_ notification: Notification) {
            resizeCount += 1
        }
    }

    private final class Runtime: WindowTabGroupRuntime {
        var attachedCollection: AnyWindowTabCollection?
        var registered: [AnyHashable: AnyWindowTab] = [:]
        var moves: [WindowTabMove] = []

        func register(tab: AnyWindowTab) {
            registered[tab.anyID] = tab
        }

        func attach(collection: AnyWindowTabCollection) {
            attachedCollection = collection
            collection.currentTabs.forEach { register(tab: $0.1) }
        }

        func collectionDidChange(
            _ collection: AnyWindowTabCollection,
            oldIDs: [AnyHashable],
            newIDs: [AnyHashable]
        ) {}

        func collectionDidChange(
            _ collection: AnyWindowTabCollection,
            oldIDs: [AnyHashable],
            newIDs: [AnyHashable],
            moves: [WindowTabMove]
        ) {
            self.moves = moves
        }
    }

    func testTopologyMoveDetachAndMergePreserveLogicalOrder() {
        let firstGroupID = UUID()
        let secondGroupID = UUID()
        let topology = WindowTabTopology(
            groups: [
                .init(id: firstGroupID, tabIDs: [1, 2, 3], selectedTabID: 1),
                .init(id: secondGroupID, tabIDs: [4], selectedTabID: 4)
            ],
            activeGroupID: firstGroupID
        )

        XCTAssertEqual(topology.moving(1, to: firstGroupID, at: 2).groups[0].tabIDs, [2, 3, 1])
        XCTAssertEqual(topology.moving(4, to: firstGroupID, at: 1).groups[0].tabIDs, [1, 4, 2, 3])
        XCTAssertEqual(
            topology.moving(4, to: secondGroupID, at: 0).groups[1].tabIDs,
            [4]
        )

        let detachedID = UUID()
        let detached = topology.detaching(2, newGroupID: detachedID)
        XCTAssertEqual(detached.groups.map(\.id), [firstGroupID, detachedID, secondGroupID])
        XCTAssertEqual(detached.groups[1].tabIDs, [2])

        let merged = topology.merging(group: secondGroupID, into: firstGroupID)
        XCTAssertEqual(merged.groups.map(\.id), [firstGroupID])
        XCTAssertEqual(merged.groups[0].tabIDs, [1, 2, 3, 4])
    }

    func testWindowTabMaterializesOnceAndStateBindingsRemainLive() {
        var materializationCount = 0
        let tab = WindowTab(id: 7) {
            materializationCount += 1
            return NSViewController()
        }
        let title = State<String>(wrappedValue: "Initial")
        let tooltip = State<String?>(wrappedValue: "Tip")
        let closeAllowed = State<Bool>(wrappedValue: true)

        _ = tab
            .tabTitle(title)
            .tabToolTip(tooltip)
            .canClose(closeAllowed)

        XCTAssertFalse(tab.isMaterialized)
        XCTAssertFalse(tab.window.isReleasedWhenClosed)
        XCTAssertEqual(tab.window.tab.title, "Initial")
        XCTAssertEqual(tab.window.tab.toolTip, "Tip")
        XCTAssertTrue(tab.closeAllowed)

        title.wrappedValue = "Updated"
        tooltip.wrappedValue = "Updated tip"
        closeAllowed.wrappedValue = false
        XCTAssertEqual(tab.window.tab.title, "Updated")
        XCTAssertEqual(tab.window.tab.toolTip, "Updated tip")
        XCTAssertFalse(tab.closeAllowed)

        tab.materialize()
        tab.materialize()
        XCTAssertEqual(materializationCount, 1)
        XCTAssertTrue(tab.isMaterialized)
    }

    func testWindowTabForEachReportsIdentityPreservingMoves() {
        let source = State<[Item]>(wrappedValue: [Item(id: 1), Item(id: 2), Item(id: 3)])
        var configurationCount = 0
        let collection = WindowTabForEach(source) { item, tab in
            configurationCount += 1
            return tab.tabTitle("Item \(item.id)")
        }
        let runtime = Runtime()
        collection.install(into: runtime)
        _ = collection.currentTabs

        source.wrappedValue = [Item(id: 3), Item(id: 1), Item(id: 2)]

        XCTAssertEqual(configurationCount, 3)
        XCTAssertEqual(runtime.moves.map(\.id), [AnyHashable(3), AnyHashable(1), AnyHashable(2)])
        XCTAssertEqual(runtime.moves.map(\.fromIndex), [2, 0, 1])
        XCTAssertEqual(runtime.moves.map(\.toIndex), [0, 1, 2])
        XCTAssertEqual(collection.currentTabs.map(\.0), [AnyHashable(3), AnyHashable(1), AnyHashable(2)])
    }

    func testWindowTabForEachUpdateRefreshesReplacementWithoutReconfiguring() {
        let source = State<[Item]>(wrappedValue: [
            Item(id: 1, title: "One"),
            Item(id: 2, title: "Two")
        ])
        var configurationCount = 0
        var updateCount = 0
        let collection = WindowTabForEach(
            source,
            configure: { item, tab in
                configurationCount += 1
                return tab.tabTitle("Configured \(item.id)")
            },
            update: { item, tab in
                updateCount += 1
                _ = tab.tabToolTip(item.title)
            }
        )
        let runtime = Runtime()
        collection.install(into: runtime)

        XCTAssertEqual(configurationCount, 2)
        XCTAssertEqual(updateCount, 2)
        let originalTab = runtime.registered[AnyHashable(1)]

        source.wrappedValue = [
            Item(id: 1, title: "One revised"),
            Item(id: 2, title: "Two revised")
        ]

        XCTAssertEqual(configurationCount, 2)
        XCTAssertEqual(updateCount, 4)
        XCTAssertIdentical(runtime.registered[AnyHashable(1)], originalTab)
        XCTAssertEqual((runtime.registered[AnyHashable(1)] as? WindowTab<Int>)?.window.tab.toolTip, "One revised")
    }

    func testWindowTabGroupCreatesEmptyTopologyInSourceRegistrationOrder() {
        let source = State<[Item]>(wrappedValue: [Item(id: 2), Item(id: 1), Item(id: 3)])
        let collection = WindowTabForEach(source) { item, tab in
            tab.tabTitle("Item \(item.id)")
        }
        let group = WindowTabGroup(WindowTabTopology<Int>.empty) {
            collection
        }

        group.activate()

        XCTAssertEqual(group.topologyState.wrappedValue.tabIDs, [2, 1, 3])
    }

    func testWindowTabGroupRetainsWindowStateBindings() {
        let tabID = UUID()
        let topology = State<WindowTabTopology<UUID>>(
            wrappedValue: .singleGroup([tabID], selectedTabID: tabID)
        )
        let acceptsMouseMovedEvents = State<Bool>(wrappedValue: true)
        let group = WindowTabGroup(topology) {
            WindowTab(id: tabID)
        }
        group.configureEachWindow { window in
            window.acceptsMouseMovedEvents(acceptsMouseMovedEvents)
        }

        group.activate()
        let window = group.activeWindow
        XCTAssertTrue(window?.acceptsMouseMovedEvents == true)
        acceptsMouseMovedEvents.wrappedValue = false
        XCTAssertTrue(window?.acceptsMouseMovedEvents == false)
    }

    func testWindowTabDelegateForwardsNonOwnedAppKitCallbacks() {
        let delegate = ForwardingDelegate()
        let tabID = UUID()
        let tab = WindowTab(id: tabID)
        tab.window.delegate = delegate
        let group = WindowTabGroup(.singleGroup([tabID])) { tab }

        group.activate()
        tab.window.delegate?.windowDidResize?(Notification(
            name: NSWindow.didResizeNotification,
            object: tab.window
        ))

        XCTAssertEqual(delegate.resizeCount, 1)
        XCTAssertTrue(tab.window.delegate !== delegate)
    }

    func testWindowTabGroupExposesNativeGroupAndOverviewState() {
        let firstID = UUID()
        let secondID = UUID()
        let overview = State<Bool>(wrappedValue: false)
        let groupID = UUID()
        let topology = State<WindowTabTopology<UUID>>(
            wrappedValue: .singleGroup([firstID, secondID], groupID: groupID)
        )
        let firstTab = WindowTab(id: firstID)
        let secondTab = WindowTab(id: secondID)
        let group = WindowTabGroup(topology) {
            firstTab
            secondTab
        }

        _ = group.tabOverviewVisible(overview)
        group.activate()

        XCTAssertNotNil(group.activeNativeGroup)
        XCTAssertEqual(group.activeNativeWindows.count, 2)
        overview.wrappedValue = true
        XCTAssertTrue(group.isTabOverviewVisible)

        topology.wrappedValue = .singleGroup(
            [secondID, firstID],
            selectedTabID: secondID,
            groupID: groupID
        )
        XCTAssertIdentical(group.activeNativeWindows.first, secondTab.window)
        XCTAssertIdentical(group.activeNativeWindows.last, firstTab.window)
        XCTAssertTrue(group.activeWindow === group.activeNativeWindows.first)
    }

    func testOpenPanelAndAlertExposeConcreteStateInvariants() {
        let openPanel = OpenPanel()
        let directories = State<Bool>(wrappedValue: false)
        let prompt = State<String?>(wrappedValue: "Choose")
        let hiddenFiles = State<Bool>(wrappedValue: false)
        _ = openPanel
            .canChooseDirectories(directories)
            .prompt(prompt)
            .showsHiddenFiles(hiddenFiles)
            .canCreateDirectories(true)
        XCTAssertFalse(openPanel.panel.canChooseDirectories)
        XCTAssertEqual(openPanel.panel.prompt, "Choose")
        directories.wrappedValue = true
        prompt.wrappedValue = nil
        hiddenFiles.wrappedValue = true
        XCTAssertTrue(openPanel.panel.canChooseDirectories)
        XCTAssertNil(openPanel.panel.prompt)
        XCTAssertTrue(openPanel.panel.showsHiddenFiles)
        XCTAssertTrue(openPanel.panel.canCreateDirectories)

        if #available(macOS 11.0, *) {
            let contentTypes = State<[UTType]>(wrappedValue: [.plainText])
            _ = openPanel.allowedContentTypes(contentTypes)
            XCTAssertEqual(openPanel.panel.allowedContentTypes, [.plainText])
        }

        let alert = Alert(messageText: "Initial")
        let message = State<String?>(wrappedValue: "Updated")
        let style = State<NSAlert.Style>(wrappedValue: .warning)
        _ = alert.messageText(message).style(style).showsHelp(true)
        XCTAssertEqual(alert.alert.messageText, "Updated")
        message.wrappedValue = "Live"
        XCTAssertEqual(alert.alert.messageText, "Live")
        XCTAssertEqual(alert.alert.alertStyle, .warning)
        XCTAssertTrue(alert.alert.showsHelp)
    }
}
#endif
