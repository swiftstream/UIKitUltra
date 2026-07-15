import Foundation
import XCTest
@testable import UIKitPlus

#if os(macOS)
import AppKit

private struct ListProbeItem: Identable {
    static var idKey: KeyPath<Self, UUID> { \Self.id }

    let id: UUID
    let text: String
}

private final class RecordingTableView: NSTableView {
    var reloadDataCount = 0
    var insertedIndexes: [IndexSet] = []
    var removedIndexes: [IndexSet] = []
    var reloadedIndexes: [IndexSet] = []
    var scrolledRows: [Int] = []
    private var isRecordingScroll = false

    override func reloadData() {
        reloadDataCount += 1
        super.reloadData()
    }

    override func insertRows(
        at indexes: IndexSet,
        withAnimation animationOptions: NSTableView.AnimationOptions
    ) {
        insertedIndexes.append(indexes)
        super.insertRows(at: indexes, withAnimation: animationOptions)
    }

    override func removeRows(
        at indexes: IndexSet,
        withAnimation animationOptions: NSTableView.AnimationOptions
    ) {
        removedIndexes.append(indexes)
        super.removeRows(at: indexes, withAnimation: animationOptions)
    }

    override func reloadData(
        forRowIndexes rowIndexes: IndexSet,
        columnIndexes: IndexSet
    ) {
        reloadedIndexes.append(rowIndexes)
        super.reloadData(
            forRowIndexes: rowIndexes,
            columnIndexes: columnIndexes
        )
    }

    override func scrollRowToVisible(_ row: Int) {
        if !isRecordingScroll {
            scrolledRows.append(row)
            isRecordingScroll = true
        }
        defer { isRecordingScroll = false }
        super.scrollRowToVisible(row)
    }

    func resetRecordings() {
        reloadDataCount = 0
        insertedIndexes.removeAll()
        removedIndexes.removeAll()
        reloadedIndexes.removeAll()
        scrolledRows.removeAll()
    }
}

@MainActor
private func ensureUIKitPlusApplication() {
    _ = App.shared
}

@MainActor
final class MacOSListDeclarativeTests: XCTestCase {
    func testBothBuilderInitializersPreserveDeclarativeIdentity() {
        ensureUIKitPlusApplication()
        let declaredView = UText("declared")
        let declarativeView = UList { declaredView }

        XCTAssertTrue(declarativeView.declarativeView === declarativeView)

        var receivedList: UList?
        let selfAwareView = UText("self-aware")
        let selfAwareList = UList { list in
            receivedList = list
            return selfAwareView
        }

        XCTAssertTrue(receivedList === selfAwareList)
        let cell = selfAwareList.tableView.view(
            atColumn: 0,
            row: 0,
            makeIfNecessary: true
        ) as? NSTableCellView
        let root = cell?.subviews.first as? UStackView
        XCTAssertTrue(root?.arrangedSubviews.first === selfAwareView)
    }

    func testNativeStructureUsesOneHeaderlessAutomaticallySizedTable() {
        ensureUIKitPlusApplication()
        let list = UList { UText("row") }
        let table = list.tableView

        XCTAssertTrue(list.documentView === table)
        XCTAssertEqual(table.tableColumns.count, 1)
        XCTAssertNil(table.headerView)
        XCTAssertTrue(table.usesAutomaticRowHeights)
        XCTAssertEqual(table.gridStyleMask, [])
        XCTAssertFalse(table.usesAlternatingRowBackgroundColors)
        XCTAssertEqual(table.selectionHighlightStyle, .none)
        XCTAssertTrue(table.allowsEmptySelection)
        XCTAssertEqual(table.intercellSpacing, .zero)
        XCTAssertFalse(list.hasHorizontalScroller)
        XCTAssertTrue(list.hasVerticalScroller)
        XCTAssertTrue(list.autohidesScrollers)
        XCTAssertFalse(list.drawsBackground)
        XCTAssertEqual(list.backgroundColor, .clear)
        XCTAssertFalse(list.contentView.drawsBackground)
        XCTAssertEqual(list.contentView.backgroundColor, .clear)
        XCTAssertFalse(list.tableView(table, shouldSelectRow: 0))
    }

    func testStaticSingleAndMultipleItemsPreserveOrderedVisibleRowCount() {
        ensureUIKitPlusApplication()
        let visibleSingle = UText("single")
        let hiddenSingle = UText("hidden-single")
        hiddenSingle.isHidden = true
        let visibleMultipleFirst = UText("multiple-first")
        let hiddenMultiple = UText("hidden-multiple")
        hiddenMultiple.isHidden = true
        let visibleMultipleLast = UText("multiple-last")

        let list = UList {
            visibleSingle
            hiddenSingle
            [visibleMultipleFirst, hiddenMultiple, visibleMultipleLast]
        }

        XCTAssertEqual(list.tableView.numberOfRows, 3)
        let values = (0..<list.tableView.numberOfRows).compactMap { row -> String? in
            let cell = list.tableView.view(
                atColumn: 0,
                row: row,
                makeIfNecessary: true
            ) as? NSTableCellView
            let root = cell?.subviews.first as? UStackView
            return (root?.arrangedSubviews.first as? UText)?.stringValue
        }
        XCTAssertEqual(values, ["single", "multiple-first", "multiple-last"])
    }

    func testInitialForEachValuesMapToChronologicalNativeRows() {
        ensureUIKitPlusApplication()
        let items = [
            ListProbeItem(id: UUID(), text: "oldest"),
            ListProbeItem(id: UUID(), text: "middle"),
            ListProbeItem(id: UUID(), text: "newest")
        ]
        let state = State<[ListProbeItem]>(wrappedValue: items)
        let list = UList {
            UForEach(state) { item in
                UText(item.text)
            }
        }

        let firstCell = list.tableView.view(
            atColumn: 0,
            row: 0,
            makeIfNecessary: true
        ) as? NSTableCellView
        let lastCell = list.tableView.view(
            atColumn: 0,
            row: 2,
            makeIfNecessary: true
        ) as? NSTableCellView
        let firstRoot = firstCell?.subviews.first as? UStackView
        let lastRoot = lastCell?.subviews.first as? UStackView

        XCTAssertEqual((firstRoot?.arrangedSubviews.first as? UText)?.stringValue, "oldest")
        XCTAssertEqual((lastRoot?.arrangedSubviews.first as? UText)?.stringValue, "newest")
    }

    func testAppendingItemPerformsOneNativeInsertionAndPreservesOrder() {
        ensureUIKitPlusApplication()
        let initialItems = [
            ListProbeItem(id: UUID(), text: "first"),
            ListProbeItem(id: UUID(), text: "second")
        ]
        let state = State<[ListProbeItem]>(wrappedValue: initialItems)
        let table = RecordingTableView(frame: .zero)
        let list = UList(tableView: table) {
            UForEach(state) { item in UText(item.text) }
        }
        table.resetRecordings()

        state.wrappedValue.append(
            ListProbeItem(id: UUID(), text: "third")
        )

        XCTAssertEqual(table.insertedIndexes, [IndexSet(integer: 2)])
        XCTAssertTrue(table.removedIndexes.isEmpty)
        XCTAssertTrue(table.reloadedIndexes.isEmpty)
        XCTAssertEqual(table.reloadDataCount, 0)
        XCTAssertEqual(table.numberOfRows, 3)
        XCTAssertEqual(listTextValues(in: list), ["first", "second", "third"])
    }

    func testRemovingItemPerformsOneNativeDeletionAndPreservesOrder() {
        ensureUIKitPlusApplication()
        let initialItems = [
            ListProbeItem(id: UUID(), text: "first"),
            ListProbeItem(id: UUID(), text: "removed"),
            ListProbeItem(id: UUID(), text: "last")
        ]
        let state = State<[ListProbeItem]>(wrappedValue: initialItems)
        let table = RecordingTableView(frame: .zero)
        let list = UList(tableView: table) {
            UForEach(state) { item in UText(item.text) }
        }
        table.resetRecordings()

        state.wrappedValue.remove(at: 1)

        XCTAssertEqual(table.removedIndexes, [IndexSet(integer: 1)])
        XCTAssertTrue(table.insertedIndexes.isEmpty)
        XCTAssertTrue(table.reloadedIndexes.isEmpty)
        XCTAssertEqual(table.reloadDataCount, 0)
        XCTAssertEqual(table.numberOfRows, 2)
        XCTAssertEqual(listTextValues(in: list), ["first", "last"])
    }

    func testSameIdentableIDWithChangedContentReloadsOnlyTheRow() {
        ensureUIKitPlusApplication()
        let id = UUID()
        let state = State<[ListProbeItem]>(wrappedValue: [
            ListProbeItem(id: id, text: "before")
        ])
        let table = RecordingTableView(frame: .zero)
        let list = UList(tableView: table) {
            UForEach(state) { item in UText(item.text) }
        }
        table.resetRecordings()

        state.wrappedValue = [ListProbeItem(id: id, text: "after")]

        XCTAssertTrue(table.insertedIndexes.isEmpty)
        XCTAssertTrue(table.removedIndexes.isEmpty)
        XCTAssertEqual(table.reloadedIndexes, [IndexSet(integer: 0)])
        XCTAssertEqual(table.reloadDataCount, 0)
        XCTAssertEqual(table.numberOfRows, 1)
        XCTAssertEqual(listTextValues(in: list), ["after"])
    }

    func testGeneratedRowHostsRealUIKitPlusHierarchyWithEdgeConstraints() {
        ensureUIKitPlusApplication()
        let declaredChild = UText("child")
        let table = NSTableView(frame: .zero)
        let list = UList(tableView: table) { declaredChild }
        let cell = table.view(
            atColumn: 0,
            row: 0,
            makeIfNecessary: true
        ) as? NSTableCellView
        let root = cell?.subviews.first as? UStackView

        XCTAssertNotNil(cell)
        XCTAssertTrue(root?.arrangedSubviews.first === declaredChild)
        XCTAssertFalse(root?.translatesAutoresizingMaskIntoConstraints ?? true)

        let edgeConstraints = (cell?.constraints ?? []).filter { constraint in
            guard constraint.isActive else { return false }
            let first = constraint.firstItem as AnyObject?
            let second = constraint.secondItem as AnyObject?
            return (first === root && second === cell) ||
                (first === cell && second === root)
        }
        XCTAssertEqual(edgeConstraints.count, 4)
        _ = list
    }

    func testScrollToBottomIsSafeForEmptyList() {
        ensureUIKitPlusApplication()
        let table = RecordingTableView(frame: .zero)
        let list = UList(tableView: table) { }
        table.resetRecordings()

        let result = list.scrollToBottom()

        XCTAssertTrue(result === list)
        XCTAssertTrue(table.scrolledRows.isEmpty)
    }

    func testScrollToBottomTargetsLastRow() {
        ensureUIKitPlusApplication()
        let state = State<[ListProbeItem]>(wrappedValue: [
            ListProbeItem(id: UUID(), text: "first"),
            ListProbeItem(id: UUID(), text: "second"),
            ListProbeItem(id: UUID(), text: "last")
        ])
        let table = RecordingTableView(frame: .zero)
        let list = UList(tableView: table) {
            UForEach(state) { item in UText(item.text) }
        }
        table.resetRecordings()

        let result = list.scrollToBottom()

        XCTAssertTrue(result === list)
        XCTAssertEqual(table.scrolledRows, [table.numberOfRows - 1])
    }

    func testReleasingListReleasesForEachAndListenerOwnership() {
        ensureUIKitPlusApplication()
        let sourceState = State<[ListProbeItem]>(wrappedValue: [])
        weak var weakForEach: ForEach<ListProbeItem>?
        weak var weakListener: StateListener?
        var list: UList?

        autoreleasepool {
            let forEach = UForEach(sourceState) { item in UText(item.text) }
            weakForEach = forEach
            list = UList(tableView: NSTableView(frame: .zero)) { forEach }
            weakListener = forEach.statesValues.heldListeners.values.first
            XCTAssertEqual(forEach.statesValues.heldListeners.count, 3)
            XCTAssertNotNil(weakForEach)
            XCTAssertNotNil(weakListener)
        }

        XCTAssertNotNil(weakForEach)
        list = nil
        XCTAssertNil(weakForEach)
        XCTAssertNil(weakListener)
        XCTAssertTrue(sourceState.wrappedValue.isEmpty)
    }

    func testInitializationAndLayoutDoNotDuplicateForEachSubscription() {
        ensureUIKitPlusApplication()
        let state = State<[ListProbeItem]>(wrappedValue: [
            ListProbeItem(id: UUID(), text: "row")
        ])
        let forEach = UForEach(state) { item in UText(item.text) }
        let list = UList(tableView: NSTableView(frame: .zero)) { forEach }
        let initialListeners = Array(forEach.statesValues.heldListeners.values)
        let initialIDs = Set(initialListeners.map(\StateListener.id))

        XCTAssertEqual(initialListeners.count, 3)

        for _ in 0..<3 {
            list.layoutSubtreeIfNeeded()
            list.layout()
            _ = list.reloadData()
            _ = list.scrollToRow(0)
            _ = list.scrollToBottom()
        }

        let finalListeners = Array(forEach.statesValues.heldListeners.values)
        XCTAssertEqual(finalListeners.count, 3)
        XCTAssertEqual(Set(finalListeners.map(\StateListener.id)), initialIDs)
    }

    private func listTextValues(in list: UList) -> [String] {
        (0..<list.tableView.numberOfRows).compactMap { row in
            let cell = list.tableView.view(
                atColumn: 0,
                row: row,
                makeIfNecessary: true
            ) as? NSTableCellView
            let root = cell?.subviews.first as? UStackView
            return (root?.arrangedSubviews.first as? UText)?.stringValue
        }
    }
}
#endif
