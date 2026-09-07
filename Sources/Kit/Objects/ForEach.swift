#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public protocol AnyForEach {
    #if os(macOS)
    var orientation: NSUserInterfaceLayoutOrientation? { get }
    var alignment: NSLayoutConstraint.Attribute? { get }
    #else
    var axis: NSLayoutConstraint.Axis? { get }
    var alignment: UIStackView.Alignment? { get }
    #endif

    var distribution: _STV.Distribution? { get }
    var spacing: CGFloat? { get }

    var count: Int { get }

    func allItems() -> [BodyBuilder.Result]
    func items(at index: Int) -> BodyBuilder.Result

    func subscribeToChanges(
        _ begin: @escaping () -> Void,
        _ handler: @escaping ([Int], [Int], [Int]) -> Void,
        _ end: @escaping () -> Void
    )
}

public extension AnyForEach {
    #if os(macOS)
    var alignment: NSLayoutConstraint.Attribute? { nil }
    #else
    var alignment: UIStackView.Alignment? { nil }
    #endif

    var distribution: _STV.Distribution? { nil }
    var spacing: CGFloat? { nil }
}

public typealias UForEach = ForEach
public class ForEach<Item>: StatesHolder where Item: Hashable {
    public typealias BuildViewHandler = (Int, Item) -> BodyBuilder.Result
    public typealias BuildViewHandlerValue = (Item) -> BodyBuilder.Result
    public typealias BuildViewHandlerSimple = () -> BodyBuilder.Result

    public let statesValues = StatesHolderValuesBox()

    let items: State<[Item]>
    let block: BuildViewHandler
    
    #if os(macOS)
    public var orientation: NSUserInterfaceLayoutOrientation? { nil }
    public var alignment: NSLayoutConstraint.Attribute?
    #else
    public var axis: NSLayoutConstraint.Axis? { nil }
    public var alignment: UIStackView.Alignment?
    #endif
    public var distribution: _STV.Distribution?
    public var spacing: CGFloat?
    
    public init (_ items: [Item], @BodyBuilder block: @escaping BuildViewHandler) {
        self.items = State(wrappedValue: items)
        self.block = block
    }
    
    public init (_ items: [Item], @BodyBuilder block: @escaping BuildViewHandlerValue) {
        self.items = State(wrappedValue: items)
        self.block = { _, v in
            block(v)
        }
    }
    
    public init (_ items: [Item], @BodyBuilder block: @escaping BuildViewHandlerSimple) {
        self.items = State(wrappedValue: items)
        self.block = { _,_ in
            block()
        }
    }
    
    public init (_ items: State<[Item]>, @BodyBuilder block: @escaping BuildViewHandler) {
        self.items = items
        self.block = block
    }
    
    public init (_ items: State<[Item]>, @BodyBuilder block: @escaping BuildViewHandlerValue) {
        self.items = items
        self.block = { _, v in
            block(v)
        }
    }
    
    public init (_ items: State<[Item]>, @BodyBuilder block: @escaping BuildViewHandlerSimple) {
        self.items = items
        self.block = { _,_ in
            block()
        }
    }

    // Mask: Alignment

    #if os(macOS)
    @discardableResult
    public func alignment(_ alignment: NSLayoutConstraint.Attribute) -> Self {
        self.alignment = alignment
        return self
    }
    #else
    @discardableResult
    public func alignment(_ alignment: UIStackView.Alignment) -> Self {
        self.alignment = alignment
        return self
    }
    #endif

    // Mask: Distribution

    @discardableResult
    public func distribution(_ distribution: _STV.Distribution) -> Self {
        self.distribution = distribution
        return self
    }

    // Mask: Spacing

    @discardableResult
    public func spacing(_ spacing: CGFloat) -> Self {
        self.spacing = spacing
        return self
    }

    deinit {
        invalidateStates()
    }
}

extension ForEach: AnyForEach {
    public var count: Int { items.wrappedValue.count }
    
    public func allItems() -> [BodyBuilder.Result] {
        items.wrappedValue.enumerated().compactMap { [weak self] in
            self?.block($0.offset, $0.element)
        }
    }
    
    public func items(at index: Int) -> BodyBuilder.Result {
        guard index < items.wrappedValue.count else { return [] }
        return block(index, items.wrappedValue[index])
    }
    
    public func subscribeToChanges(_ begin: @escaping () -> Void, _ handler: @escaping ([Int], [Int], [Int]) -> Void, _ end: @escaping () -> Void) {
        items.beginTrigger(begin).hold(in: self)

        items.listen { old, new in
            let diff = old.difference(new)
            let deletions = diff.removed.compactMap { $0.index }
            let insertions = diff.inserted.compactMap { $0.index }
            let modifications = diff.modified.compactMap { $0.index }

            guard deletions.count > 0 ||
                  insertions.count > 0 ||
                  modifications.count > 0 else {
                return
            }

            handler(deletions, insertions, modifications)
        }.hold(in: self)

        items.endTrigger(end).hold(in: self)
    }
}

extension ForEach: BodyBuilderItemable {
    public var bodyBuilderItem: BodyBuilderItem {
        .forEach(self)
    }
}

extension ForEach where Item == Int {
    public convenience init (_ items: ClosedRange<Item>, @BodyBuilder block: @escaping BuildViewHandler) {
        self.init(items.map { $0 }, block: block)
    }
    
    public convenience init (_ items: ClosedRange<Item>, @BodyBuilder block: @escaping BuildViewHandlerValue) {
        self.init(items.map { $0 }, block: block)
    }
    
    public convenience init (_ items: ClosedRange<Item>, @BodyBuilder block: @escaping BuildViewHandlerSimple) {
        self.init(items.map { $0 }, block: block)
    }
}

public class VForEach<Item>: ForEach<Item> where Item: Hashable {
    #if os(macOS)
    public override var orientation: NSUserInterfaceLayoutOrientation? { .horizontal }
    #else
    public override var axis: NSLayoutConstraint.Axis? { .vertical }
    #endif
}

public class HForEach<Item>: ForEach<Item> where Item: Hashable {
    #if os(macOS)
    public override var orientation: NSUserInterfaceLayoutOrientation? { .horizontal }
    #else
    public override var axis: NSLayoutConstraint.Axis? { .horizontal }
    #endif
}
#endif
