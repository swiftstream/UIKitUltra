#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import UIKitPlusCore

open class UView: BaseView, UIViewable, AnyDeclarativeProtocol, DeclarativeProtocolInternal {
    public var declarativeView: UView { self }
    public lazy var properties = Properties<UView>()
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
    
    @MainActor
    public init (@BodyBuilder block: BodyBuilder.SingleView) {
        super.init(frame: .zero)
        _setup()
        body { block() }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    
    public convenience init () {
        self.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _setup() {
        translatesAutoresizingMaskIntoConstraints = false
        #if os(macOS)
        #else
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { [weak self] (self: Self?, previousTraitCollection) in
                guard let self else { return }
                self.properties.traitCollectionDidChangeHandlers.values.forEach { $0(self.traitCollection) }
            }
        }
        #endif
        body { body }
        buildView()
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
    
    @MainActor @BodyBuilder open var body: BodyBuilder.Result { EmptyBodyBuilderItem() }

    #if os(macOS)
    open override func layout() {
        super.layout()
        onLayoutSubviews()
    }
    
    open override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        movedToSuperview()
    }
    
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        window?.makeFirstResponder(nil)
        return super.resignFirstResponder()
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
    
    open func buildView() {}
    
    #if os(macOS)
    open override var isFlipped: Bool {
        properties.isFlipped
    }
    
    @discardableResult
    public func flipped(_ value: Bool) -> Self {
        properties.isFlipped = value
        return self
    }
    #endif
    
    // MARK: Touches
    #if os(macOS)
    typealias TouchClosure = (NSEvent) -> Void
    #else
    typealias TouchClosure = (Set<UITouch>, UIEvent?) -> Void
    #endif
    
    var _touchesBegan: TouchClosure?
    var _touchesMoved: TouchClosure?
    var _touchesEnded: TouchClosure?
    var _touchesCancelled: TouchClosure?
    
    #if os(macOS)
    open override func touchesBegan(with event: NSEvent) {
        super.touchesBegan(with: event)
        gestureRecognizers.forEach {
            ($0 as? USwipeGestureRecognizer)?.touchesBegan(with: event)
        }
        _touchesBegan?(event)
    }
    
    open override func touchesMoved(with event: NSEvent) {
        super.touchesMoved(with: event)
        gestureRecognizers.forEach {
            ($0 as? USwipeGestureRecognizer)?.touchesMoved(with: event)
        }
        _touchesMoved?(event)
    }
    
    open override func touchesEnded(with event: NSEvent) {
        super.touchesEnded(with: event)
        gestureRecognizers.forEach {
            ($0 as? USwipeGestureRecognizer)?.touchesEnded(with: event)
        }
        _touchesEnded?(event)
    }
    
    open override func touchesCancelled(with event: NSEvent) {
        super.touchesCancelled(with: event)
        gestureRecognizers.forEach {
            ($0 as? USwipeGestureRecognizer)?.touchesCancelled(with: event)
        }
        _touchesCancelled?(event)
    }
    
    public enum TouchPanState: CustomStringConvertible {
        case began, changed, ended, cancelled, swiped
        
        public var description: String {
            switch self {
            case .began: return "began"
            case .changed: return "changed"
            case .ended: return "ended"
            case .cancelled: return "cancelled"
            case .swiped: return "swiped"
            }
        }
    }
    
    public typealias TouchPanHandler = (TouchPanState, CGPoint, CGPoint) -> Void
    
    var _touchPanHandler: TouchPanHandler?
    var scrollBeganPoint: CGPoint?
    var scrollLastDeltaPoint: CGPoint = .zero
    
    open override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        switch event.phase {
        case .began:
            scrollBeganPoint = .init(x: event.scrollingDeltaX, y: event.scrollingDeltaY)
            scrollLastDeltaPoint = scrollBeganPoint ?? .zero
            _touchPanHandler?(.began, .zero, .zero)
        case .changed:
            if let scrollBeganPoint = scrollBeganPoint {
                scrollLastDeltaPoint.x += event.scrollingDeltaX
                scrollLastDeltaPoint.y += event.scrollingDeltaY
                _touchPanHandler?(.changed, scrollLastDeltaPoint, .init(x: event.deltaX, y: event.deltaY))
            }
        case .ended:
            if let scrollBeganPoint = scrollBeganPoint {
                scrollLastDeltaPoint.x += event.scrollingDeltaX
                scrollLastDeltaPoint.y += event.scrollingDeltaY
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                    guard let self = self else { return }
                    if let _ = self.scrollBeganPoint {
                        self._touchPanHandler?(.ended, self.scrollLastDeltaPoint, .init(x: event.deltaX, y: event.deltaY))
                    }
                }
            }
        case .cancelled:
            if let scrollBeganPoint = scrollBeganPoint {
                _touchPanHandler?(.cancelled, .zero, .zero)
                self.scrollBeganPoint = nil
            }
        case .mayBegin:
            break
        case .stationary:
            break
        default:
            if let scrollBeganPoint = scrollBeganPoint {
                print(event)
                scrollLastDeltaPoint.x += event.scrollingDeltaX
                scrollLastDeltaPoint.y += event.scrollingDeltaY
                _touchPanHandler?(.swiped, scrollLastDeltaPoint, .init(x: event.deltaX, y: event.deltaY))
                self.scrollBeganPoint = nil
            }
        }
    }
    
    /// Touch pan gesture handler
    /// to handle touch pan on magic mouse with one finger
    /// and on magic trackpad with two fingers
    ///
    /// Parameters:
    /// - state
    /// - scrollDelta: scroll position
    /// - delta: to understand the way of moving (especially for swipe state)
    @discardableResult
    public func onTouchPanGesture(_ action: @escaping TouchPanHandler) -> Self {
        _touchPanHandler = action
        return self
    }
    #else
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        _touchesBegan?(touches, event)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        _touchesMoved?(touches, event)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        _touchesEnded?(touches, event)
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        _touchesCancelled?(touches, event)
    }
    #endif
}

// MARK: Convenience Initializers

extension UView {
    public static func inline(_ v: () -> BaseView) -> UView {
        .init(inline: v())
    }
    
    public convenience init (_ innerView: BaseView) {
        self.init()
        body { innerView }
    }
    
    public convenience init (inline inlineView: BaseView) {
        self.init()
        inlineView.translatesAutoresizingMaskIntoConstraints = false
        body { inlineView }
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: inlineView.leadingAnchor),
            trailingAnchor.constraint(equalTo: inlineView.trailingAnchor),
            topAnchor.constraint(equalTo: inlineView.topAnchor),
            bottomAnchor.constraint(equalTo: inlineView.bottomAnchor)
        ])
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
    public static func subviews(@BodyBuilder block: BodyBuilder.SingleView) -> UView {
        UView(block: block)
    }
}

// MARK: Touches
#if os(macOS)
extension UView {
    /// Began
    @discardableResult
    public func touchesBegan(_ closure: @escaping () -> Void) -> Self {
        _touchesBegan = { _ in closure() }
        return self
    }
    
    @discardableResult
    public func touchesBegan(_ closure: @escaping (Self) -> Void) -> Self {
        _touchesBegan = { [weak self] _ in
            guard let self = self else { return }
            closure(self)
        }
        return self
    }
    
    @discardableResult
    public func touchesBegan(_ closure: @escaping (Self, NSEvent) -> Void) -> Self {
        _touchesBegan = { [weak self] in
            guard let self = self else { return }
            closure(self, $0)
        }
        return self
    }
    
    /// Moved
    @discardableResult
    public func touchesMoved(_ closure: @escaping () -> Void) -> Self {
        _touchesMoved = { _ in closure() }
        return self
    }
    
    @discardableResult
    public func touchesMoved(_ closure: @escaping (Self) -> Void) -> Self {
        _touchesMoved = { [weak self] _ in
            guard let self = self else { return }
            closure(self)
        }
        return self
    }
    
    @discardableResult
    public func touchesMoved(_ closure: @escaping (Self, NSEvent) -> Void) -> Self {
        _touchesMoved = { [weak self] in
            guard let self = self else { return }
            closure(self, $0)
        }
        return self
    }
    
    /// Ended
    @discardableResult
    public func touchesEnded(_ closure: @escaping () -> Void) -> Self {
        _touchesEnded = { _ in closure() }
        return self
    }
    
    @discardableResult
    public func touchesEnded(_ closure: @escaping (Self) -> Void) -> Self {
        _touchesEnded = { [weak self] _ in
            guard let self = self else { return }
            closure(self)
        }
        return self
    }
    
    @discardableResult
    public func touchesEnded(_ closure: @escaping (Self, NSEvent) -> Void) -> Self {
        _touchesEnded = { [weak self] in
            guard let self = self else { return }
            closure(self, $0)
        }
        return self
    }
    
    /// Cancelled
    @discardableResult
    public func touchesCancelled(_ closure: @escaping () -> Void) -> Self {
        _touchesCancelled = { _ in closure() }
        return self
    }
    
    @discardableResult
    public func touchesCancelled(_ closure: @escaping (Self) -> Void) -> Self {
        _touchesCancelled = { [weak self] _ in
            guard let self = self else { return }
            closure(self)
        }
        return self
    }
    
    @discardableResult
    public func touchesCancelled(_ closure: @escaping (Self, NSEvent) -> Void) -> Self {
        _touchesCancelled = { [weak self] in
            guard let self = self else { return }
            closure(self, $0)
        }
        return self
    }
}
#else
extension UView {
    /// Began
    @discardableResult
    public func touchesBegan(_ closure: @escaping () -> Void) -> Self {
        _touchesBegan = { _,_ in closure() }
        return self
    }
    
    @discardableResult
    public func touchesBegan(_ closure: @escaping (Self) -> Void) -> Self {
        _touchesBegan = { [weak self] _,_ in
            guard let self = self else { return }
            closure(self)
        }
        return self
    }
    
    @discardableResult
    public func touchesBegan(_ closure: @escaping (Self, Set<UITouch>) -> Void) -> Self {
        _touchesBegan = { [weak self] set, _ in
            guard let self = self else { return }
            closure(self, set)
        }
        return self
    }
    
    @discardableResult
    public func touchesBegan(_ closure: @escaping (Self, Set<UITouch>, UIEvent?) -> Void) -> Self {
        _touchesBegan = { [weak self] set, event in
            guard let self = self else { return }
            closure(self, set, event)
        }
        return self
    }
    
    /// Moved
    @discardableResult
    public func touchesMoved(_ closure: @escaping () -> Void) -> Self {
        _touchesMoved = { _,_ in closure() }
        return self
    }
    
    @discardableResult
    public func touchesMoved(_ closure: @escaping (Self) -> Void) -> Self {
        _touchesMoved = { [weak self] _,_ in
            guard let self = self else { return }
            closure(self)
        }
        return self
    }
    
    @discardableResult
    public func touchesMoved(_ closure: @escaping (Self, Set<UITouch>) -> Void) -> Self {
        _touchesMoved = { [weak self] set, _ in
            guard let self = self else { return }
            closure(self, set)
        }
        return self
    }
    
    @discardableResult
    public func touchesMoved(_ closure: @escaping (Self, Set<UITouch>, UIEvent?) -> Void) -> Self {
        _touchesMoved = { [weak self] set, event in
            guard let self = self else { return }
            closure(self, set, event)
        }
        return self
    }
    
    /// Ended
    @discardableResult
    public func touchesEnded(_ closure: @escaping () -> Void) -> Self {
        _touchesEnded = { _,_ in closure() }
        return self
    }
    
    @discardableResult
    public func touchesEnded(_ closure: @escaping (Self) -> Void) -> Self {
        _touchesEnded = { [weak self] _,_ in
            guard let self = self else { return }
            closure(self)
        }
        return self
    }
    
    @discardableResult
    public func touchesEnded(_ closure: @escaping (Self, Set<UITouch>) -> Void) -> Self {
        _touchesEnded = { [weak self] set, _ in
            guard let self = self else { return }
            closure(self, set)
        }
        return self
    }
    
    @discardableResult
    public func touchesEnded(_ closure: @escaping (Self, Set<UITouch>, UIEvent?) -> Void) -> Self {
        _touchesEnded = { [weak self] set, event in
            guard let self = self else { return }
            closure(self, set, event)
        }
        return self
    }
    
    /// Cancelled
    @discardableResult
    public func touchesCancelled(_ closure: @escaping () -> Void) -> Self {
        _touchesCancelled = { _,_ in closure() }
        return self
    }
    
    @discardableResult
    public func touchesCancelled(_ closure: @escaping (Self) -> Void) -> Self {
        _touchesCancelled = { [weak self] _,_ in
            guard let self = self else { return }
            closure(self)
        }
        return self
    }
    
    @discardableResult
    public func touchesCancelled(_ closure: @escaping (Self, Set<UITouch>) -> Void) -> Self {
        _touchesCancelled = { [weak self] set, _ in
            guard let self = self else { return }
            closure(self, set)
        }
        return self
    }
    
    @discardableResult
    public func touchesCancelled(_ closure: @escaping (Self, Set<UITouch>, UIEvent?) -> Void) -> Self {
        _touchesCancelled = { [weak self] set, event in
            guard let self = self else { return }
            closure(self, set, event)
        }
        return self
    }
}
#endif
#endif
