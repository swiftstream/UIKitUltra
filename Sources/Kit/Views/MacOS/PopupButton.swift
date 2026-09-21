#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
import UltraCore

fileprivate final class _UPopUpButtonInsetCell: NSPopUpButtonCell, _MacOSInsettableCell {
    private var insets = _MacOSControlInsets.zero

    var _macOSControlInsets: _MacOSControlInsets { insets }

    override init(textCell string: String, pullsDown: Bool) {
        super.init(textCell: string, pullsDown: pullsDown)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    func _setMacOSControlInsets(_ insets: _MacOSControlInsets) {
        self.insets = insets
    }

    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        guard !insets.isZero else {
            super.drawInterior(withFrame: cellFrame, in: controlView)
            return
        }
        super.drawInterior(withFrame: insets.contentFrame(for: cellFrame), in: controlView)
    }

    override func cellSize(forBounds rect: NSRect) -> NSSize {
        guard !insets.isZero else {
            return super.cellSize(forBounds: rect)
        }
        return insets.expandedSize(super.cellSize(forBounds: insets.contentFrame(for: rect)))
    }
}

open class UPopUpButton: NSPopUpButton, AnyDeclarativeProtocol, DeclarativeProtocolInternal {
    public var declarativeView: UPopUpButton { self }
    public lazy var properties = Properties<UPopUpButton>()
    lazy var _properties = PropertiesInternal()

    override open class var cellClass: AnyClass? {
        get { _UPopUpButtonInsetCell.self }
        set {}
    }

    open override var intrinsicContentSize: NSSize {
        guard let insets = _macOSControlInsetsValue, !insets.isZero else {
            return super.intrinsicContentSize
        }
        return insets.expandedSize(super.intrinsicContentSize)
    }
    
    @Ultra.State public var height: CGFloat = 0
    @Ultra.State public var width: CGFloat = 0
    @Ultra.State public var top: CGFloat = 0
    @Ultra.State public var leading: CGFloat = 0
    @Ultra.State public var left: CGFloat = 0
    @Ultra.State public var trailing: CGFloat = 0
    @Ultra.State public var right: CGFloat = 0
    @Ultra.State public var bottom: CGFloat = 0
    @Ultra.State public var centerX: CGFloat = 0
    @Ultra.State public var centerY: CGFloat = 0
    
    var __height: Ultra.State<CGFloat> { $height }
    var __width: Ultra.State<CGFloat> { $width }
    var __top: Ultra.State<CGFloat> { $top }
    var __leading: Ultra.State<CGFloat> { $leading }
    var __left: Ultra.State<CGFloat> { $left }
    var __trailing: Ultra.State<CGFloat> { $trailing }
    var __right: Ultra.State<CGFloat> { $right }
    var __bottom: Ultra.State<CGFloat> { $bottom }
    var __centerX: Ultra.State<CGFloat> { $centerX }
    var __centerY: Ultra.State<CGFloat> { $centerY }
    
    lazy var _bezelStyleState: State<NSButton.BezelStyle> = .init(wrappedValue: bezelStyle)
//    lazy var _buttonTypeState: State<NSButton.ButtonType> = .init(wrappedValue: .momentaryPushIn)
    lazy var _ignoreMultiClickState: State<Bool> = .init(wrappedValue: ignoresMultiClick)
    lazy var _continuousState: State<Bool> = .init(wrappedValue: isContinuous)
    lazy var _refuseFirstResponderState: State<Bool> = .init(wrappedValue: refusesFirstResponder)
    lazy var _borderedState: State<Bool> = .init(wrappedValue: isBordered)
    
    @discardableResult
    public init(_ v: Menu) {
        super.init(frame: .zero, pullsDown: false)
        _setup()
        menu(v)
    }
    
    @discardableResult
    public init(@MenuBuilder content: @escaping MenuBuilder.Block) {
        super.init(frame: .zero, pullsDown: false)
        _setup()
        menu(content: content)
    }
    
    @discardableResult
    public init(@MenuBuilder content: @escaping (Menu) -> MenuBuilderContent) {
        super.init(frame: .zero, pullsDown: false)
        _setup()
        menu(content: content)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func _setup() {
        translatesAutoresizingMaskIntoConstraints = false
        target = self
        action = #selector(pushHandler)
    }

    /// Sets the four native content edges directly. Repeated equal calls are idempotent and listener-free while native popup selection, arrow, menu, and tracking behavior remain owned by AppKit. If the active AppKit cell has been replaced with a non-inset-capable cell, Ultra preserves that cell and this call is a no-op.
    @discardableResult
    public func contentInsets(_ insets: NSEdgeInsets) -> Self {
        _setMacOSControlInsets(.init(insets))
        return self
    }

    /// Sets equal horizontal and vertical native content edges. The arguments are intentionally unlabeled; repeated equal calls are idempotent and listener-free. If the active AppKit cell has been replaced with a non-inset-capable cell, Ultra preserves that cell and this call is a no-op.
    @discardableResult
    public func contentInsets(_ horizontal: CGFloat, _ vertical: CGFloat) -> Self {
        contentInsets(top: vertical, left: horizontal, right: horizontal, bottom: vertical)
    }

    /// Sets the same native content edge on all sides. Repeated equal calls are idempotent and listener-free. If the active AppKit cell has been replaced with a non-inset-capable cell, Ultra preserves that cell and this call is a no-op.
    @discardableResult
    public func contentInsets(_ value: CGFloat) -> Self {
        contentInsets(value, value)
    }

    /// Sets each native content edge explicitly. Repeated equal calls are idempotent and listener-free. If the active AppKit cell has been replaced with a non-inset-capable cell, Ultra preserves that cell and this call is a no-op.
    @discardableResult
    public func contentInsets(top: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0, bottom: CGFloat = 0) -> Self {
        _setMacOSControlInsets(.init(top: top, left: left, right: right, bottom: bottom))
        return self
    }

    /// Applies the current edge State immediately and follows future values one-way. Repeated State calls add holder-owned bindings until the popup is released. If the active AppKit cell has been replaced with a non-inset-capable cell, Ultra preserves that cell, makes no inset change, and does not register a State listener.
    @discardableResult
    public func contentInsets(_ state: State<NSEdgeInsets>) -> Self {
        guard _macOSControlInsetsValue != nil else {
            return self
        }
        contentInsets(state.wrappedValue)
        state.listen { [weak self] value in
            self?.contentInsets(value)
        }
        .hold(in: stateBindingHolder)
        return self
    }

    /// Applies the current horizontal and vertical States immediately and follows each future value one-way on its own axis. Repeated bindings are additive and holder-owned until the popup is released. If the active AppKit cell has been replaced with a non-inset-capable cell, Ultra preserves that cell, makes no inset change, and does not register State listeners.
    @discardableResult
    public func contentInsets(_ horizontal: State<CGFloat>, _ vertical: State<CGFloat>) -> Self {
        guard _macOSControlInsetsValue != nil else {
            return self
        }
        contentInsets(horizontal.wrappedValue, vertical.wrappedValue)
        horizontal.listen { [weak self] value in
            self?._updateMacOSControlInsets {
                $0.left = value
                $0.right = value
            }
        }
        .hold(in: stateBindingHolder)
        vertical.listen { [weak self] value in
            self?._updateMacOSControlInsets {
                $0.top = value
                $0.bottom = value
            }
        }
        .hold(in: stateBindingHolder)
        return self
    }

    /// Applies the current uniform State immediately and follows future values one-way on all four edges. Repeated bindings are additive and holder-owned until the popup is released. If the active AppKit cell has been replaced with a non-inset-capable cell, Ultra preserves that cell, makes no inset change, and does not register a State listener.
    @discardableResult
    public func contentInsets(_ state: State<CGFloat>) -> Self {
        guard _macOSControlInsetsValue != nil else {
            return self
        }
        contentInsets(state.wrappedValue)
        state.listen { [weak self] value in
            self?.contentInsets(value)
        }
        .hold(in: stateBindingHolder)
        return self
    }

    /// Applies the current four edge States immediately and follows each future value one-way on its own edge. Repeated bindings are additive and holder-owned until the popup is released. If the active AppKit cell has been replaced with a non-inset-capable cell, Ultra preserves that cell, makes no inset change, and does not register State listeners.
    @discardableResult
    public func contentInsets(top: State<CGFloat>, left: State<CGFloat>, right: State<CGFloat>, bottom: State<CGFloat>) -> Self {
        guard _macOSControlInsetsValue != nil else {
            return self
        }
        contentInsets(top: top.wrappedValue, left: left.wrappedValue, right: right.wrappedValue, bottom: bottom.wrappedValue)
        top.listen { [weak self] value in
            self?._updateMacOSControlInsets { $0.top = value }
        }
        .hold(in: stateBindingHolder)
        left.listen { [weak self] value in
            self?._updateMacOSControlInsets { $0.left = value }
        }
        .hold(in: stateBindingHolder)
        right.listen { [weak self] value in
            self?._updateMacOSControlInsets { $0.right = value }
        }
        .hold(in: stateBindingHolder)
        bottom.listen { [weak self] value in
            self?._updateMacOSControlInsets { $0.bottom = value }
        }
        .hold(in: stateBindingHolder)
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
    
    // MARK: Action
    
    private var actionHandler: (() -> Void)?
    private var actionSelfHandler: ((UPopUpButton) -> Void)?
    
    @objc func pushHandler() {
        actionHandler?()
        actionSelfHandler?(self)
    }
    
    @discardableResult
    public func onAction(_ handler: @escaping () -> Void) -> Self {
        actionHandler = handler
        return self
    }
    
    @discardableResult
    public func onAction(_ handler: @escaping (UPopUpButton) -> Void) -> Self {
        actionSelfHandler = handler
        return self
    }
    
    @discardableResult
    public func lineBreakMode(_ mode: NSLineBreakMode) -> Self {
        lineBreakMode = mode
        return self
    }
    
    @discardableResult
    public func alignment(_ v: NSTextAlignment) -> Self {
        alignment = v
        return self
    }
    
    @discardableResult
    public func baseWritingDirection(_ v: NSWritingDirection) -> Self {
        baseWritingDirection = v
        return self
    }
    
    @discardableResult
    public func usesSingleLineMode(_ v: Bool) -> Self {
        usesSingleLineMode = v
        return self
    }
    
    @discardableResult
    public func allowsExpansionToolTips(_ v: Bool) -> Self {
        allowsExpansionToolTips = v
        return self
    }
    
    @discardableResult
    public func preferredEdge(_ v: NSRectEdge) -> Self {
        preferredEdge = v
        return self
    }
}

extension UPopUpButton: _Titleable {
    var _statedTitle: AnyStringBuilder.Handler? {
        get { nil }
        set {}
    }
    
    func _setTitle(_ v: NSAttributedString?) {
        attributedTitle = .init() // hack to update attributed string with changed paragraph style
        attributedTitle = v ?? .init()
    }
}

extension UPopUpButton: _Enableable {
    func _setEnabled(_ v: Bool) {
        isEnabled = v
    }
}

extension UPopUpButton: _PullsDownable {
    func _setPullsDown(_ v: Bool) {
        pullsDown = v
    }
}

extension UPopUpButton: _ArrowPositionable {
    func _setArrowPosition(_ v: NSPopUpButton.ArrowPosition) {
        (cell as? NSPopUpButtonCell)?.arrowPosition = v
    }
}

extension UPopUpButton: _BezelStyleable {
    func _setBezelStyle(_ v: NSButton.BezelStyle) {
        bezelStyle = v
    }
}

extension UPopUpButton: _MultiClickIgnorable {
    func _setIgnoreMultiClick(_ v: Bool) {
        ignoresMultiClick = v
    }
}

extension UPopUpButton: _Continuousable {
    func _setContinuous(_ v: Bool) {
        isContinuous = v
    }
}

extension UPopUpButton: _FirstResponderRefusable {
    func _setRefuseFirstResponder(_ v: Bool) {
        refusesFirstResponder = v
    }
}

extension UPopUpButton: _Borderedable {
    func _setBordered(_ v: Bool) {
        isBordered = v
    }
}

extension UPopUpButton: _Soundable {
    func _setSound(_ v: NSSound?) {
        sound = v
    }
}

extension UPopUpButton: _Keyable {
    func _setKey(_ v: String) {
        keyEquivalent = v
    }
}

extension UPopUpButton: _KeyMaskable {
    func _setKeyMask(_ v: NSEvent.ModifierFlags) {
        keyEquivalentModifierMask = v
    }
}
#endif
#endif
