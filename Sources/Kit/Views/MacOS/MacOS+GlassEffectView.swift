#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
import UIKitPlusCore

@available(macOS 26.0, *)
open class UGlassEffectView: NSGlassEffectView, AnyDeclarativeProtocol, DeclarativeProtocolInternal {
    public var declarativeView: UGlassEffectView { self }
    public lazy var properties = Properties<UGlassEffectView>()
    lazy var _properties = PropertiesInternal()

    @UState public var height: CGFloat = 0
    @UState public var width: CGFloat = 0
    @UState public var top: CGFloat = 0
    @UState public var leading: CGFloat = 0
    @UState public var left: CGFloat = 0
    @UState public var trailing: CGFloat = 0
    @UState public var right: CGFloat = 0
    @UState public var bottom: CGFloat = 0
    @UState public var centerX: CGFloat = 0
    @UState public var centerY: CGFloat = 0

    var __height: UState<CGFloat> { _height }
    var __width: UState<CGFloat> { _width }
    var __top: UState<CGFloat> { _top }
    var __leading: UState<CGFloat> { _leading }
    var __left: UState<CGFloat> { _left }
    var __trailing: UState<CGFloat> { _trailing }
    var __right: UState<CGFloat> { _right }
    var __bottom: UState<CGFloat> { _bottom }
    var __centerX: UState<CGFloat> { _centerX }
    var __centerY: UState<CGFloat> { _centerY }

    private lazy var _tag: Int = -1
    public override var tag: Int {
        get { _tag }
        set { _tag = newValue }
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        _setup()
    }

    public convenience init() {
        self.init(frame: .zero)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func _setup() {
        translatesAutoresizingMaskIntoConstraints = false
    }

    @discardableResult
    public func style(_ value: NSGlassEffectView.Style) -> Self {
        style = value
        return self
    }

    @discardableResult
    public func tintColor(_ value: NSColor?) -> Self {
        tintColor = value
        return self
    }

    @discardableResult
    public func cornerRadius(_ value: CGFloat) -> Self {
        cornerRadius = value
        return self
    }

    @discardableResult
    public func contentView(_ value: NSView?) -> Self {
        contentView = value
        return self
    }

    open override func layout() {
        super.layout()
        onLayoutSubviews()
    }

    open override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        movedToSuperview()
    }
}
#endif
#endif
