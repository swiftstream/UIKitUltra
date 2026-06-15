#if os(macOS)
import AppKit

open class UScrollView: NSScrollView, AnyDeclarativeProtocol, DeclarativeProtocolInternal {
    public var declarativeView: UScrollView { self }
    public lazy var properties = Properties<UScrollView>()
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
    
    var scrollPosition: State<CGPoint>?
    
    private lazy var  _tag: Int = -1
    public override var tag: Int {
        get { _tag }
        set { _tag = newValue }
    }
    
    public init () {
        super.init(frame: .zero)
        _setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    
    private func _setup() {
        translatesAutoresizingMaskIntoConstraints = false
//        delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layout() {
        super.layout()
        onLayoutSubviews()
    }
    
    open override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        movedToSuperview()
    }

    open override func viewWillMove(toWindow newWindow: NSWindow?) {
        super.viewWillMove(toWindow: newWindow)
    }
    
    // MARK: Document View
    
    @discardableResult
    public func documentView(_ view: BaseView) -> Self {
        documentView = view
        return self
    }
    
//    // MARK: - Refresh Control
//    #if !os(tvOS)
//    @discardableResult
//    public func refreshControl(_ refreshControl: UIRefreshControl) -> Self {
//        if #available(iOS 10.0, *) {
//            self.refreshControl = refreshControl
//        } else {
//            addSubview(refreshControl)
//        }
//        return self
//    }
//
//    // MARK: Paging
//
//    @discardableResult
//    public func paging(_ enabled: Bool) -> Self {
//        isPagingEnabled = enabled
//        return self
//    }
//    #endif
    // MARK: Scrolling
    
//    @discardableResult
//    public func scrolling(_ enabled: Bool) -> Self {
//        isScrollEnabled = enabled
//        return self
//    }
    
    // MARK: Border Type
    
    @discardableResult
    public func borderType(_ type: NSBorderType) -> Self {
        borderType = type
        return self
    }
    
    // MARK: Indicators
    
    @discardableResult
    public func hideIndicator(_ indicators: NSLayoutConstraint.Axis...) -> Self {
        if indicators.contains(.horizontal) {
            hasHorizontalScroller = false
        }
        if indicators.contains(.vertical) {
            hasVerticalScroller = false
        }
        return self
    }
    
    @discardableResult
    public func showIndicator(_ indicators: NSLayoutConstraint.Axis...) -> Self {
        if indicators.contains(.horizontal) {
            hasHorizontalScroller = true
        }
        if indicators.contains(.vertical) {
            hasVerticalScroller = true
        }
        return self
    }
    
    @discardableResult
    public func hideAllIndicators() -> Self {
        hasVerticalScroller = false
        hasHorizontalScroller = false
        return self
    }
    
    @discardableResult
    public func showAllIndicators() -> Self {
        hasVerticalScroller = true
        hasHorizontalScroller = true
        return self
    }
    
    // MARK: Rulers
    
    @discardableResult
    public func hideRuler(_ indicators: NSLayoutConstraint.Axis...) -> Self {
        if indicators.contains(.horizontal) {
            hasHorizontalRuler = false
        }
        if indicators.contains(.vertical) {
            hasVerticalRuler = false
        }
        return self
    }
    
    @discardableResult
    public func showRuler(_ indicators: NSLayoutConstraint.Axis...) -> Self {
        if indicators.contains(.horizontal) {
            hasHorizontalRuler = true
        }
        if indicators.contains(.vertical) {
            hasVerticalRuler = true
        }
        return self
    }
    
    @discardableResult
    public func hideAllRulers() -> Self {
        hasVerticalRuler = false
        hasHorizontalRuler = false
        return self
    }
    
    @discardableResult
    public func showAllRulers() -> Self {
        hasVerticalRuler = true
        hasHorizontalRuler = true
        return self
    }
    
    // MARK: Content Inset
    
//    @discardableResult
//    public func contentInset(_ insets: UIEdgeInsets) -> Self {
//        contentInset = insets
//        return self
//    }
//
//    @discardableResult
//    public func contentInset(top: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0, bottom: CGFloat = 0) -> Self {
//        contentInset(.init(top: top, left: left, bottom: bottom, right: right))
//    }
    
    // MARK: Scroll Indicator Inset
    
//    @discardableResult
//    public func scrollIndicatorInsets(_ insets: UIEdgeInsets) -> Self {
//        scrollIndicatorInsets = insets
//        return self
//    }
//
//    @discardableResult
//    public func scrollIndicatorInsets(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> Self {
//        scrollIndicatorInsets(.init(top: top, left: left, bottom: bottom, right: right))
//    }
    
    // MARK: Delegate
    
//    @discardableResult
//    public func delegate(_ delegate: NSScrollViewDelegate) -> Self {
//        self.delegate = delegate
//        return self
//    }
}

// MARK: Convenience Initializers

extension UScrollView {
    public convenience init (_ innerView: NSView) {
        self.init()
        documentView = innerView
    }
    
    public convenience init <V>(_ innerView: () -> V) where V: DeclarativeProtocol {
        self.init()
        documentView = innerView().declarativeView
    }
    
    @discardableResult
    @MainActor
    public func subviews(@BodyBuilder block: BodyBuilder.SingleView) -> Self {
        documentView?.body { block() }
        return self
    }
}

//extension UScrollView: UIScrollViewDelegate {
//    @discardableResult
//    public func contentOffset(_ position: CGPoint, animated: Bool = true) -> Self {
//        setContentOffset(position, animated: animated)
//        return self
//    }
//
//    @discardableResult
//    public func scrollPosition(_ binding: UIKitPlus.State<CGPoint>) -> Self {
//        scrollPosition = binding
//        return self
//    }
//
//    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        scrollPosition?.wrappedValue = scrollView.contentOffset
//    }
//}
#endif
