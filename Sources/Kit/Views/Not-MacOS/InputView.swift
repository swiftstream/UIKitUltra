#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit
import UIKitPlusCore

@available(*, deprecated, renamed: "UInputView")
public typealias InputView = UInputView

open class UInputView: UIInputView, AnyDeclarativeProtocol, DeclarativeProtocolInternal {
    public static var defaultKeyboardHeight: CGFloat = 216
    
    public var declarativeView: UInputView { self }
    public lazy var properties = Properties<UInputView>()
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
    
    public override init(frame: CGRect, inputViewStyle: UIInputView.Style) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        _setup()
        buildView()
    }
    
    public init (_ inputViewStyle: UIInputView.Style = .default) {
        super.init(frame: .zero, inputViewStyle: inputViewStyle)
        _setup()
        buildView()
    }
    
    @MainActor
    public init (_ inputViewStyle: UIInputView.Style = .default, @BodyBuilder block: BodyBuilder.SingleView) {
        super.init(frame: .zero, inputViewStyle: inputViewStyle)
        _setup()
        body { block() }
        buildView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _setup() {
        translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { [weak self] (self: Self?, previousTraitCollection) in
                guard let self else { return }
                self.properties.traitCollectionDidChangeHandlers.values.forEach { $0(self.traitCollection) }
            }
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                properties.traitCollectionDidChangeHandlers.values.forEach { $0(traitCollection) }
            }
        }
    }
    
    open func buildView() {}
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        onLayoutSubviews()
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        movedToSuperview()
    }
    
    private var _intrinsicContentSize: CGSize = .init(width: UIView.noIntrinsicMetric, height: InputView.defaultKeyboardHeight) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        return _intrinsicContentSize
    }
    
    @discardableResult
    public func intrinsicContentSize(w: CGFloat = UIView.noIntrinsicMetric, h: CGFloat = UIView.noIntrinsicMetric) -> Self {
        _intrinsicContentSize = .init(width: w, height: h)
        return self
    }
    
    @discardableResult
    public func intrinsicContentSize(_ value: CGFloat) -> Self {
        intrinsicContentSize(w: value, h: value)
    }
    
    /// Width for `intrinsicContentSize`
    @discardableResult
    public func contentWidth(_ value: CGFloat) -> Self {
        intrinsicContentSize(w: value)
    }
    
    /// Height for `intrinsicContentSize`
    @discardableResult
    public func contentHeight(_ value: CGFloat) -> Self {
        intrinsicContentSize(h: value)
    }
    
    @discardableResult
    public func allowsSelfSizing(_ value: Bool) -> Self {
        allowsSelfSizing = value
        return self
    }
}

// MARK: Convenience Initializers

extension InputView {
    public convenience init (_ innerView: UIView) {
        self.init()
        body { innerView }
    }
    
    public convenience init <V>(_ innerView: () -> V) where V: DeclarativeProtocol {
        self.init()
        body { innerView().declarativeView }
    }
    
    @discardableResult
    @MainActor
    public func subviews(@BodyBuilder block: BodyBuilder.SingleView) -> Self {
        body { block() }
    }
    
    @MainActor
    public static func subviews(@BodyBuilder block: BodyBuilder.SingleView) -> InputView {
        InputView(block: block)
    }
}
#endif
#endif
