#if !os(macOS)
import UIKit

class UListSection {
    var item: BodyBuilderItem
    let axis: NSLayoutConstraint.Axis
    
    init (_ item: BodyBuilderItem, axis: NSLayoutConstraint.Axis? = nil) {
        self.item = item
        self.axis = axis ?? .vertical
    }
}

public class UList: UView, UITableViewDataSource {
    @State var reversed = false
    
    var scrollPosition: State<CGPoint>?
    
    var items: [UListSection] = []
    
    @MainActor
    public override init (@BodyBuilder block: BodyBuilder.SingleView) {
        super.init(frame: .zero)
        process(block())
        $reversed.listen { [weak self] old, new in
            self?.tableView.transform = CGAffineTransform(rotationAngle: new ? -(CGFloat)(Double.pi) : 0)
            if let tableView = self?.tableView {
                tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.size.width - 8)
            }
            if old != new {
                self?.tableView.reloadData()
            }
        }
        .holdIfOwned(by: self)
        setup()
    }
    
    @MainActor
    public init (@BodyBuilder block: (UList) -> BodyBuilder.Result) {
        super.init(frame: .zero)
        process(block(self))
        $reversed.listen { [weak self] old, new in
            self?.tableView.transform = CGAffineTransform(rotationAngle: new ? -(CGFloat)(Double.pi) : 0)
            if let tableView = self?.tableView {
                tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.size.width - 8)
            }
            if old != new {
                self?.tableView.reloadData()
            }
        }
        .holdIfOwned(by: self)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func process(_ item: BodyBuilderItemable, sectionIndex: Int = 0) {
        let item = item.bodyBuilderItem
        switch item {
        case .single(let view):
            items.append(.init(item))
        case .multiple(let views):
            items.append(.init(item))
        case .forEach(let fr):
            let direction = fr.axis ?? .vertical
            let listSection = UListSection(item, axis: direction)
            items.append(listSection)
            fr.subscribeToChanges({ [weak self] in
                self?.tableView.beginUpdates()
            }, { [weak self] deletions, insertions, modifications in
                self?.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: sectionIndex)}, with: .fade)
                self?.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: sectionIndex) }, with: .fade)
                self?.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: sectionIndex) }, with: .fade)
            }) { [weak self] in
                self?.tableView.endUpdates()
            }
        case .nested(let items):
            for (i, v) in items.enumerated() {
                process(v, sectionIndex: sectionIndex + i)
            }
        case .none:
            break
        }
    }
    
    /// Applies some defaults to the list
    public func setup() {
        #if !os(tvOS)
        tableView.separatorStyle(.none)
        #endif
    }
    
    public lazy var tableView = UTableView()
        .register(UListDynamicCell.self)
        .automaticDimension()
        .edgesToSuperview()
        .dataSource(self)
        .delegate(self)
        .background(backgroundColor ?? .clear)
    
    override public func buildView() {
        super.buildView()
        body {
            tableView
        }
    }
    
    // MARK: Keyboard Dismiss Mode
    
    @discardableResult
    public func keyboardDismissMode(_ mode: UIScrollView.KeyboardDismissMode) -> Self {
        tableView.keyboardDismissMode = mode
        return self
    }
    
    // MARK: ScrollView methods
    
    open func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        tableView.setContentOffset(contentOffset, animated: animated)
    }

    open func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        tableView.scrollRectToVisible(rect, animated: animated)
    }
    
    // MARK: TableView methods
    
    open func reloadData() {
        tableView.reloadData()
    }
    
    open func reloadSection(_ i: Int) {
        tableView.reloadSections(IndexSet(integer: i), with: UITableView.RowAnimation.fade)
    }
    
    open func beginUpdates() {
        tableView.beginUpdates()
    }
    
    open func endUpdates() {
        tableView.endUpdates()
    }
    
    // MARK: - Refresh Control
    #if !os(tvOS)
    @discardableResult
    public func refreshControl(_ refreshControl: UIRefreshControl) -> Self {
        tableView.refreshControl(refreshControl)
        return self
    }
    #endif
    
    // MARK: - UITableViewDataSource
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        items.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch items[section].item {
        case .single(let view):
            return view.isHidden ? 0 : 1
        case .multiple(let views):
            return views.filter { !$0.isHidden }.count
        case .forEach(let fr):
            return fr.count
        case .nested, .none:
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: UListDynamicCell.self, for: indexPath)
        let section = items[indexPath.section]
        switch section.item {
        case .single(let view):
            cell.setRootView(UStackView(view).axis(section.axis))
        case .multiple(let views):
            cell.setRootView(UStackView(views.filter { !$0.isHidden }[indexPath.row]).axis(section.axis))
        case .forEach(let fr):
            let item = fr.items(at: indexPath.row).bodyBuilderItem
            switch item {
            case .single(let view):
                cell.setRootView(UStackView(view).axis(section.axis))
            case .multiple(let views):
                cell.setRootView(UStackView(views).axis(section.axis))
            case .forEach(let fr):
                cell.setRootView(UStackView(BodyBuilderItems(items: fr.allItems())).axis(section.axis))
            case .nested(let items):
                cell.setRootView(UStackView(BodyBuilderItems(items: items)).axis(section.axis))
            case .none:
                cell.setRootView(.init())
            }
        case .nested, .none:
            cell.setRootView(.init())
        }
        cell.transform = CGAffineTransform(rotationAngle: reversed ? CGFloat(Double.pi) : 0)
        return cell
    }
    
    // MARK: - Separator
    #if !os(tvOS)
    @discardableResult
    public func separatorColor(_ value: UIColor) -> Self {
        tableView.separatorColor(value)
        return self
    }

    @discardableResult
    public func separatorStyle(_ value: UITableViewCell.SeparatorStyle) -> Self {
        tableView.separatorStyle(value)
        return self
    }
    #endif
    @discardableResult
    public func separatorInset(_ value: UIEdgeInsets) -> Self {
        tableView.separatorInset(value)
        return self
    }
    
    @discardableResult
    public func separatorInset(top: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0, bottom: CGFloat = 0) -> Self {
        tableView.separatorInset(top: top, left: left, right: right, bottom: bottom)
        return self
    }
    
    @discardableResult
    public func reversed(_ value: Bool = true) -> Self {
        reversed = value
        return self
    }
    
    @discardableResult
    public func update() -> Self {
        tableView.beginUpdates()
        tableView.endUpdates()
        return self
    }
}

extension UList: UIScrollViewDelegate {
    @discardableResult
    public func contentOffset(_ position: CGPoint, animated: Bool = true) -> Self {
        tableView.setContentOffset(position, animated: animated)
        return self
    }
    
    @discardableResult
    public func scrollPosition(_ binding: UIKitPlus.State<CGPoint>) -> Self {
        scrollPosition = binding
        return self
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollPosition?.wrappedValue = scrollView.contentOffset
    }
}

extension UList: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool { false }
}

extension UList {
    // MARK: Indicators
    
    @discardableResult
    public func hideIndicator(_ indicators: NSLayoutConstraint.Axis...) -> Self {
        if indicators.contains(.horizontal) {
            tableView.showsHorizontalScrollIndicator = false
        }
        if indicators.contains(.vertical) {
            tableView.showsVerticalScrollIndicator = false
        }
        return self
    }
    
    // MARK: Indicators
    
    @discardableResult
    public func hideAllIndicators() -> Self {
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        return self
    }
    
    // MARK: Content Inset
    
    @discardableResult
    public func contentInset(_ insets: UIEdgeInsets) -> Self {
        tableView.contentInset = insets
        return self
    }
    
    @discardableResult
    public func contentInset(top: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0, bottom: CGFloat = 0) -> Self {
        contentInset(.init(top: top, left: left, bottom: bottom, right: right))
    }
    
    // MARK: Scroll Indicator Inset
    
    @discardableResult
    public func scrollIndicatorInsets(_ insets: UIEdgeInsets) -> Self {
        tableView.scrollIndicatorInsets = insets
        return self
    }
    
    @discardableResult
    public func scrollIndicatorInsets(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> Self {
        scrollIndicatorInsets(.init(top: top, left: left, bottom: bottom, right: right))
    }
}
#endif
