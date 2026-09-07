#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit

private enum _UListSection {
    case single(BaseView)
    case multiple([BaseView])
    case forEach(AnyForEach)
}

private final class _UListCell: NSTableCellView {
    private var currentRoot: UStackView?
    private var rootConstraints: [NSLayoutConstraint] = []

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ newRoot: UStackView) {
        NSLayoutConstraint.deactivate(rootConstraints)
        rootConstraints.removeAll()
        currentRoot?.removeFromSuperview()
        currentRoot = nil

        newRoot.translatesAutoresizingMaskIntoConstraints = false
        addSubview(newRoot)

        rootConstraints = [
            newRoot.leadingAnchor.constraint(equalTo: leadingAnchor),
            newRoot.trailingAnchor.constraint(equalTo: trailingAnchor),
            newRoot.topAnchor.constraint(equalTo: topAnchor),
            newRoot.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(rootConstraints)
        currentRoot = newRoot
    }
}

@MainActor
open class UList: UScrollView,
                  NSTableViewDataSource,
                  NSTableViewDelegate {
    public let tableView: NSTableView

    private let tableColumn: NSTableColumn
    private var sections: [_UListSection] = []

    private static let columnIdentifier = NSUserInterfaceItemIdentifier(
        "UIKitPlus.UList.Column"
    )
    private static let cellIdentifier = NSUserInterfaceItemIdentifier(
        "UIKitPlus.UList.Cell"
    )

    public init(
        @BodyBuilder block: BodyBuilder.SingleView
    ) {
        tableView = NSTableView(frame: .zero)
        tableColumn = NSTableColumn(identifier: Self.columnIdentifier)
        super.init()
        setupNativeTable()
        process(block())
        tableView.reloadData()
    }

    public init(
        @BodyBuilder block: (UList) -> BodyBuilder.Result
    ) {
        tableView = NSTableView(frame: .zero)
        tableColumn = NSTableColumn(identifier: Self.columnIdentifier)
        super.init()
        setupNativeTable()
        process(block(self))
        tableView.reloadData()
    }

    init(
        tableView: NSTableView,
        @BodyBuilder block: BodyBuilder.SingleView
    ) {
        self.tableView = tableView
        tableColumn = NSTableColumn(identifier: Self.columnIdentifier)
        super.init()
        setupNativeTable()
        process(block())
        tableView.reloadData()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupNativeTable() {
        borderType = .noBorder
        drawsBackground = false
        backgroundColor = .clear
        contentView.drawsBackground = false
        contentView.backgroundColor = .clear
        hasHorizontalScroller = false
        hasVerticalScroller = true
        autohidesScrollers = true
        scrollerStyle = .overlay

        tableView.headerView = nil
        tableView.autoresizingMask = [.width]
        if #available(macOS 11.0, *) {
            tableView.style = .plain
        }
        tableView.backgroundColor = .clear
        tableView.gridStyleMask = []
        tableView.usesAlternatingRowBackgroundColors = false
        tableView.selectionHighlightStyle = .none
        tableView.allowsEmptySelection = true
        tableView.intercellSpacing = .zero
        tableView.usesAutomaticRowHeights = true
        tableView.rowHeight = 44
        tableView.columnAutoresizingStyle = .lastColumnOnlyAutoresizingStyle
        tableView.dataSource = self
        tableView.delegate = self

        tableColumn.title = ""
        tableColumn.resizingMask.insert(.autoresizingMask)
        tableColumn.minWidth = 0

        tableView.addTableColumn(tableColumn)
        documentView = tableView
    }

    private func process(_ bodyBuilderItem: BodyBuilderItemable) {
        switch bodyBuilderItem.bodyBuilderItem {
        case .single(let view):
            sections.append(.single(view))
        case .multiple(let views):
            sections.append(.multiple(views))
        case .forEach(let forEach):
            let sectionIndex = sections.count
            sections.append(.forEach(forEach))
            forEach.subscribeToChanges(
                { [weak self] in
                    self?.tableView.beginUpdates()
                },
                { [weak self] deletions, insertions, modifications in
                    guard let self else { return }

                    let offset = rowOffset(forSectionAt: sectionIndex)
                    var deletionIndexes = IndexSet()
                    for localIndex in deletions {
                        deletionIndexes.insert(offset + localIndex)
                    }

                    var insertionIndexes = IndexSet()
                    for localIndex in insertions {
                        insertionIndexes.insert(offset + localIndex)
                    }

                    var modificationIndexes = IndexSet()
                    for localIndex in modifications {
                        modificationIndexes.insert(offset + localIndex)
                    }

                    if !deletionIndexes.isEmpty {
                        tableView.removeRows(
                            at: deletionIndexes,
                            withAnimation: .effectFade
                        )
                    }
                    if !insertionIndexes.isEmpty {
                        tableView.insertRows(
                            at: insertionIndexes,
                            withAnimation: .effectFade
                        )
                    }
                    if !modificationIndexes.isEmpty {
                        tableView.reloadData(
                            forRowIndexes: modificationIndexes,
                            columnIndexes: IndexSet(integer: 0)
                        )
                    }
                },
                { [weak self] in
                    self?.tableView.endUpdates()
                }
            )
        case .nested(let items):
            items.forEach { process($0) }
        case .none:
            break
        }
    }

    private func rowCount(for section: _UListSection) -> Int {
        switch section {
        case .single(let view):
            return view.isHidden ? 0 : 1
        case .multiple(let views):
            return views.filter { !$0.isHidden }.count
        case .forEach(let forEach):
            return forEach.count
        }
    }

    private func rowOffset(forSectionAt sectionIndex: Int) -> Int {
        sections.prefix(sectionIndex).reduce(into: 0) { result, section in
            result += rowCount(for: section)
        }
    }

    private func location(forNativeRow row: Int) -> (section: Int, localRow: Int)? {
        guard row >= 0 else { return nil }

        var remaining = row
        for (sectionIndex, section) in sections.enumerated() {
            let count = rowCount(for: section)
            if remaining < count {
                return (sectionIndex, remaining)
            }
            remaining -= count
        }
        return nil
    }

    private func rowRoot(for section: _UListSection, localRow: Int) -> UStackView {
        let root = UStackView()
            .orientation(.vertical)
            .alignment(.width)
            .distribution(.fill)
            .spacing(0)

        switch section {
        case .single(let view):
            root.add(item: view)
        case .multiple(let views):
            let visibleViews = views.filter { !$0.isHidden }
            root.add(item: visibleViews[localRow])
        case .forEach(let forEach):
            root.add(item: forEach.items(at: localRow))
        }
        return root
    }

    public func numberOfRows(in tableView: NSTableView) -> Int {
        sections.reduce(into: 0) { result, section in
            result += rowCount(for: section)
        }
    }

    public func tableView(
        _ tableView: NSTableView,
        viewFor tableColumn: NSTableColumn?,
        row: Int
    ) -> NSView? {
        guard let location = location(forNativeRow: row) else { return nil }
        let root = rowRoot(for: sections[location.section], localRow: location.localRow)

        let cell: _UListCell
        if let reusableCell = tableView.makeView(
            withIdentifier: Self.cellIdentifier,
            owner: self
        ) as? _UListCell {
            cell = reusableCell
        } else {
            cell = _UListCell(frame: .zero)
            cell.identifier = Self.cellIdentifier
        }
        cell.configure(root)
        return cell
    }

    public func tableView(
        _ tableView: NSTableView,
        shouldSelectRow row: Int
    ) -> Bool {
        false
    }

    @discardableResult
    public func reloadData() -> Self {
        tableView.reloadData()
        return self
    }

    @discardableResult
    public func scrollToRow(_ row: Int) -> Self {
        guard row >= 0 else { return self }
        guard row < tableView.numberOfRows else { return self }

        needsLayout = true
        tableView.needsLayout = true
        layoutSubtreeIfNeeded()
        tableView.layoutSubtreeIfNeeded()
        tableView.scrollRowToVisible(row)
        return self
    }

    @discardableResult
    public func scrollToBottom() -> Self {
        let count = tableView.numberOfRows
        guard count > 0 else { return self }
        scrollToRow(count - 1)
        return self
    }
}
#endif
#endif
