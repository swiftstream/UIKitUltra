#if os(macOS)
import AppKit
#else
import UIKit
#endif

@available(*, deprecated, renamed: "UStackView")
public typealias StackView = UStackView

@MainActor
open class UStackView: _StackView {
    public override init () {
        super.init()
    }
    
    public init (_ viewBuilderItem: BodyBuilderItemable) {
        super.init(frame: .zero)
        add(item: viewBuilderItem)
    }
    
    @MainActor
    public init (@BodyBuilder block: BodyBuilder.SingleView) {
        super.init(frame: .zero)
        add(item: block())
    }
    
    @MainActor
    public init (@BodyBuilder block: (UStackView) -> BodyBuilder.Result) {
        super.init(frame: .zero)
        add(item: block(self))
    }
    
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor
    public func subviews(@BodyBuilder block: BodyBuilder.SingleView) -> Self {
        add(item: block())
        return self
    }
    
    @MainActor
    public static func subviews(@BodyBuilder block: BodyBuilder.SingleView) -> UVStack {
        .init(block: block)
    }
    
    // Mask: Axis
    
    #if os(macOS)
    @discardableResult
    public func orientation(_ orientation: NSUserInterfaceLayoutOrientation) -> UStackView {
        self.orientation = orientation
        return self
    }
    #else
    @discardableResult
    public func axis(_ axis: NSLayoutConstraint.Axis) -> UStackView {
        self.axis = axis
        return self
    }
    #endif
}

#if os(macOS)
public typealias _STV = NSStackView
#else
public typealias _STV = UIStackView
#endif

@MainActor
open class _StackView: _STV, AnyDeclarativeProtocol, DeclarativeProtocolInternal, EditableStackView {
    public var declarativeView: _StackView { self }
    public lazy var properties = Properties<_StackView>()
    lazy var _properties = PropertiesInternal()
    
    @State public var height: CGFloat = 0
    @State public var width: CGFloat = 0
    @State public var top: CGFloat = 0
    @State public var leading: CGFloat = 0
    @State public var left: CGFloat = 0
    @State public var trailing: CGFloat = 0
    @State public var right: CGFloat = 0
    @State public var bottom: CGFloat = 0
    @State public var centerX: CGFloat = 0
    @State public var centerY: CGFloat = 0
    
    var __height: State<CGFloat> { _height }
    var __width: State<CGFloat> { _width }
    var __top: State<CGFloat> { _top }
    var __leading: State<CGFloat> { _leading }
    var __left: State<CGFloat> { _left }
    var __trailing: State<CGFloat> { _trailing }
    var __right: State<CGFloat> { _right }
    var __bottom: State<CGFloat> { _bottom }
    var __centerX: State<CGFloat> { _centerX }
    var __centerY: State<CGFloat> { _centerY }
    
    open override var tag: Int {
        get { properties.tag }
        set {
            #if !os(macOS)
            super.tag = newValue
            #endif
            properties.tag = newValue
        }
    }
    
    public init () {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        _setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        _setup()
    }
    
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func _setup() {
        spacing = 0
        #if os(macOS)
        #else
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { [weak self] (self: Self?, previousTraitCollection) in
                guard let self else { return }
                self.properties.traitCollectionDidChangeHandlers.values.forEach { $0(self.traitCollection) }
            }
        }
        #endif
    }
    
    #if os(macOS)
    #else
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                properties.traitCollectionDidChangeHandlers.values.forEach { $0(traitCollection) }
            }
        }
    }
    #endif
    
    #if os(macOS)
    open override func layout() {
        super.layout()
        onLayoutSubviews()
    }
    
    open override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        movedToSuperview()
    }
    #else
    open override func layoutSubviews() {
        super.layoutSubviews()
        onLayoutSubviews()
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        movedToSuperview()
    }
    #endif
    
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
    
    @discardableResult
    public func spacing(_ state: State<CGFloat>) -> Self {
        state.listen { [weak self] new in
            self?.spacing = new
        }
        .hold(in: stateBindingHolder)
        self.spacing = state.wrappedValue
        return self
    }
    
    func add(item: BodyBuilderItemable) {
        switch item.bodyBuilderItem {
            case .single(let view):
                addArrangedSubview(view)
            case .multiple(let views):
                views.forEach { addArrangedSubview($0) }
            case .forEach(let fr):
                #if os(macOS)
                let initialOrientation = fr.orientation ?? orientation
                let stack = UStackView().orientation(initialOrientation)
                #else
                let initialAxis = fr.axis ?? axis
                let stack = UStackView().axis(initialAxis)
                #endif

                stack
                    .distribution(fr.distribution ?? distribution)
                    .alignment(fr.alignment ?? alignment)
                    .spacing(fr.spacing ?? spacing)

                let binding = RenderedForEachBinding(fr)
                stack.retainRenderedForEachBinding(binding)

                fr.allItems().forEach {
                    #if os(macOS)
                    stack.addArrangedSubview([$0].flatten(initialOrientation))
                    #else
                    stack.addArrangedSubview([$0].flatten(initialAxis))
                    #endif
                }

                addArrangedSubview(stack)

                fr.subscribeToChanges({}, { [weak self, weak stack, weak binding] deletions, insertions, _ in
                    guard let stack = stack, let fr = binding?.forEach else { return }

                    stack.arrangedSubviews.removeFromSuperview(at: deletions)

                    insertions.forEach {
                        #if os(macOS)
                        let orientation = fr.orientation ?? self?.orientation ?? stack.orientation
                        stack.add(arrangedView: [fr.items(at: $0)].flatten(orientation), at: $0)
                        #else
                        let axis = fr.axis ?? self?.axis ?? stack.axis
                        stack.add(arrangedView: [fr.items(at: $0)].flatten(axis), at: $0)
                        #endif
                    }
                }) {}
            case .nested(let items):
                items.forEach { add(item: $0) }
            case .none:
                break
            }
    }
}

extension Array where Element == BodyBuilderItemable {
    #if os(macOS)
    @MainActor
    fileprivate func flatten(_ orientation: NSUserInterfaceLayoutOrientation) -> BaseView {
        let stackView = StackView().orientation(orientation)
        forEach { stackView.add(item: $0) }
        return stackView
    }
    #else
    @MainActor
    fileprivate func flatten(_ axis: NSLayoutConstraint.Axis) -> BaseView {
        let stackView = UStackView().axis(axis)
        forEach { stackView.add(item: $0) }
        return stackView
    }
    #endif
}
