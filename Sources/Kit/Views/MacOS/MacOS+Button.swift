#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
import UIKitPlusCore

struct _MacOSControlInsets: Equatable {
    var top: CGFloat
    var left: CGFloat
    var right: CGFloat
    var bottom: CGFloat

    static let zero = Self(top: 0, left: 0, right: 0, bottom: 0)

    init(top: CGFloat, left: CGFloat, right: CGFloat, bottom: CGFloat) {
        self.top = top
        self.left = left
        self.right = right
        self.bottom = bottom
    }

    init(_ insets: NSEdgeInsets) {
        self.init(top: insets.top, left: insets.left, right: insets.right, bottom: insets.bottom)
    }

    var isZero: Bool {
        self == .zero
    }

    var nsEdgeInsets: NSEdgeInsets {
        .init(top: top, left: left, bottom: bottom, right: right)
    }

    func contentFrame(for frame: NSRect) -> NSRect {
        .init(
            x: frame.minX + left,
            y: frame.minY + bottom,
            width: max(0, frame.width - left - right),
            height: max(0, frame.height - top - bottom)
        )
    }

    func expandedSize(_ size: NSSize) -> NSSize {
        .init(width: size.width + left + right, height: size.height + top + bottom)
    }
}

@MainActor
protocol _MacOSInsettableCell: AnyObject {
    var _macOSControlInsets: _MacOSControlInsets { get }
    func _setMacOSControlInsets(_ insets: _MacOSControlInsets)
}

extension _MacOSInsettableCell {
    func _macOSContentFrame(for frame: NSRect) -> NSRect {
        _macOSControlInsets.contentFrame(for: frame)
    }

    func _macOSExpandedSize(_ size: NSSize) -> NSSize {
        _macOSControlInsets.expandedSize(size)
    }
}

extension NSControl {
    var _macOSControlInsetsValue: _MacOSControlInsets? {
        (cell as? _MacOSInsettableCell)?._macOSControlInsets
    }

    @discardableResult
    func _setMacOSControlInsets(_ insets: _MacOSControlInsets) -> Bool {
        guard let insettableCell = cell as? _MacOSInsettableCell else {
            return false
        }
        guard insettableCell._macOSControlInsets != insets else {
            return true
        }

        insettableCell._setMacOSControlInsets(insets)
        invalidateIntrinsicContentSize(for: insettableCell as! NSCell)
        needsDisplay = true
        needsLayout = true
        return true
    }

    @discardableResult
    func _updateMacOSControlInsets(_ update: (inout _MacOSControlInsets) -> Void) -> Bool {
        guard var insets = _macOSControlInsetsValue else {
            return false
        }
        update(&insets)
        return _setMacOSControlInsets(insets)
    }
}

fileprivate final class _UButtonInsetCell: NSButtonCell, _MacOSInsettableCell {
    private var insets = _MacOSControlInsets.zero

    var _macOSControlInsets: _MacOSControlInsets { insets }

    override init(textCell string: String) {
        super.init(textCell: string)
    }

    override init(imageCell image: NSImage?) {
        super.init(imageCell: image)
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

open class UButton: NSButton, AnyDeclarativeProtocol, DeclarativeProtocolInternal {
    public var declarativeView: UButton { self }
    public lazy var properties = Properties<UButton>()
    lazy var _properties = PropertiesInternal()

    override open class var cellClass: AnyClass? {
        get { _UButtonInsetCell.self }
        set {}
    }
    
    @UIKitPlus.State public var height: CGFloat = 0
    @UIKitPlus.State public var width: CGFloat = 0
    @UIKitPlus.State public var top: CGFloat = 0
    @UIKitPlus.State public var leading: CGFloat = 0
    @UIKitPlus.State public var left: CGFloat = 0
    @UIKitPlus.State public var trailing: CGFloat = 0
    @UIKitPlus.State public var right: CGFloat = 0
    @UIKitPlus.State public var bottom: CGFloat = 0
    @UIKitPlus.State public var centerX: CGFloat = 0
    @UIKitPlus.State public var centerY: CGFloat = 0
    
    var __height: UIKitPlus.State<CGFloat> { $height }
    var __width: UIKitPlus.State<CGFloat> { $width }
    var __top: UIKitPlus.State<CGFloat> { $top }
    var __leading: UIKitPlus.State<CGFloat> { $leading }
    var __left: UIKitPlus.State<CGFloat> { $left }
    var __trailing: UIKitPlus.State<CGFloat> { $trailing }
    var __right: UIKitPlus.State<CGFloat> { $right }
    var __bottom: UIKitPlus.State<CGFloat> { $bottom }
    var __centerX: UIKitPlus.State<CGFloat> { $centerX }
    var __centerY: UIKitPlus.State<CGFloat> { $centerY }
    
    lazy var _stateState: State<NSControl.StateValue> = .init(wrappedValue: state)
    lazy var _bezelStyleState: State<NSButton.BezelStyle> = .init(wrappedValue: bezelStyle)
    lazy var _buttonTypeState: State<NSButton.ButtonType> = .init(wrappedValue: .momentaryPushIn)
    lazy var _allowMixedStateState: State<Bool> = .init(wrappedValue: allowsMixedState)
    lazy var _ignoreMultiClickState: State<Bool> = .init(wrappedValue: ignoresMultiClick)
    lazy var _continuousState: State<Bool> = .init(wrappedValue: isContinuous)
    lazy var _refuseFirstResponderState: State<Bool> = .init(wrappedValue: refusesFirstResponder)
    lazy var _borderedState: State<Bool> = .init(wrappedValue: isBordered)
    
    // MARK: Initialization
    
    init (_ cell: NSCell?) {
        super.init(frame: .zero)
        self.cell = cell
        _setup()
    }
    
    public init (_ string: AnyString...) {
        super.init(frame: .zero)
        _setup()
        title(string)
    }
    
    public init (_ strings: [AnyString]) {
        super.init(frame: .zero)
        _setup()
        title(strings)
    }
    
    public init (_ localized: LocalizedString...) {
        super.init(frame: .zero)
        _setup()
        title(localized)
    }
    
    public init (_ localized: [LocalizedString]) {
        super.init(frame: .zero)
        _setup()
        title(localized)
    }
    
    public init<A: AnyString>(_ state: State<A>) {
        super.init(frame: .zero)
        _setup()
        title(state)
    }
    
    public init (@AnyStringBuilder stateString: @escaping AnyStringBuilder.Handler) {
        super.init(frame: .zero)
        _setup()
        title(stateString: stateString)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func _setup() {
        translatesAutoresizingMaskIntoConstraints = false
        target = self
        bezelStyle = .regularSquare
        isBordered = false
        action = #selector(pushHandler)

        if !_isHoverListenerRegistered {
            _isHoverListenerRegistered = true

            isHoveredByMouse.listen { [weak self] old, new in
                guard old != new else { return }
                guard let self = self else { return }

                if new {
                    self._mouseEnteredHandler(self)
                } else {
                    self._mouseExitedHandler(self)
                }
            }
            .hold(in: _properties.stateBindingHolder)
        }

        updateTrackingAreas()
    }

    /// Sets the four native content edges directly. Repeated equal calls are idempotent and listener-free; a supplied non-inset-capable native window-button cell is preserved and this call is a documented no-op.
    @discardableResult
    public func contentInsets(_ insets: NSEdgeInsets) -> Self {
        _setMacOSControlInsets(.init(insets))
        return self
    }

    /// Sets equal horizontal and vertical native content edges. The arguments are intentionally unlabeled; repeated equal calls are idempotent and listener-free, and supplied non-inset-capable native cells are preserved as a no-op.
    @discardableResult
    public func contentInsets(_ horizontal: CGFloat, _ vertical: CGFloat) -> Self {
        contentInsets(top: vertical, left: horizontal, right: horizontal, bottom: vertical)
    }

    /// Sets the same native content edge on all sides. Repeated equal calls are idempotent and listener-free; supplied non-inset-capable native cells are preserved as a no-op.
    @discardableResult
    public func contentInsets(_ value: CGFloat) -> Self {
        contentInsets(value, value)
    }

    /// Sets each native content edge explicitly. Repeated equal calls are idempotent and listener-free; supplied non-inset-capable native cells are preserved as a documented no-op.
    @discardableResult
    public func contentInsets(top: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0, bottom: CGFloat = 0) -> Self {
        _setMacOSControlInsets(.init(top: top, left: left, right: right, bottom: bottom))
        return self
    }

    /// Applies the current edge State immediately and follows future values one-way. Repeated State calls add holder-owned bindings; unsupported supplied native cells install no listener and remain unchanged.
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

    /// Applies the current horizontal and vertical States immediately and follows each future value one-way on its own axis. Repeated bindings are additive and holder-owned; unsupported supplied native cells install no listeners.
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

    /// Applies the current uniform State immediately and follows future values one-way on all four edges. Repeated bindings are additive and holder-owned; unsupported supplied native cells install no listener.
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

    /// Applies the current four edge States immediately and follows each future value one-way on its own edge. Repeated bindings are additive and holder-owned; unsupported supplied native cells install no listeners.
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
    
    // MARK: Highlight
    
    open override var isHighlighted: Bool {
        didSet {
            guard isWaitingForHighlight else {
                return
            }
            if isHighlighted {
                _setBackgroundColor(backgroundHighlighted)
            } else {
                _setBackgroundColor(background.wrappedValue.current)
            }
        }
    }
    
    // MARK: Background Highlighted
    
    var backgroundHighlighted: NSColor?
    var isWaitingForHighlight = false
    
    @discardableResult
    public func backgroundHighlighted(_ color: UColor) -> Self {
        isWaitingForHighlight = true
        backgroundHighlighted = color.current
        color.onChange { [weak self] color in
            self?.backgroundHighlighted = color
            if self?.isHighlighted == true {
                self?._setBackgroundColor(color)
            }
        }
        return self
    }
    
    @discardableResult
    public func backgroundHighlighted(_ number: Int) -> Self {
        backgroundHighlighted(number.color)
    }
    
    // MARK: Window Buttons
    
    public static var windowClose: UButton = UButton(NSWindow.standardWindowButton(.closeButton, for: .closable)?.cell).onAction {
        $0.superview?.window?.orderOut(nil)
    }.onMouseHover {
        $0.needsDisplay = true
        $0.isHighlighted = true
    }.onMouseUnhover {
        $0.needsDisplay = true
        $0.isHighlighted = false
    }
    
    public static var windowMinimize: UButton = UButton(NSWindow.standardWindowButton(.miniaturizeButton, for: .closable)?.cell).onAction {
        $0.superview?.window?.miniaturize(nil)
    }.onMouseHover {
        $0.needsDisplay = true
        $0.isHighlighted = true
    }.onMouseUnhover {
        $0.needsDisplay = true
        $0.isHighlighted = false
    }
    
    public static var windowZoom: UButton = UButton(NSWindow.standardWindowButton(.zoomButton, for: .closable)?.cell).onAction {
        $0.superview?.window?.zoom(nil)
    }.onMouseHover {
        $0.needsDisplay = true
        $0.isHighlighted = true
    }.onMouseUnhover {
        $0.needsDisplay = true
        $0.isHighlighted = false
    }
    
    // MARK: Mouse Hover
    
    private lazy var area = makeTrackingArea()
    
    private func makeTrackingArea() -> NSTrackingArea {
        .init(rect: bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow, .activeAlways], owner: self, userInfo: nil)
    }
    
    open override func updateTrackingAreas() {
        removeTrackingArea(area)
        area = makeTrackingArea()
        addTrackingArea(area)
    }
    
    private var _isHoverListenerRegistered = false
    lazy var isHoveredByMouse = UState<Bool>(wrappedValue: false)
    var _mouseEnteredHandler: (UButton) -> Void = { _ in }
    var _mouseExitedHandler: (UButton) -> Void = { _ in }
    
    public override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        isHoveredByMouse.wrappedValue = true
    }

    public override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        isHoveredByMouse.wrappedValue = false
    }
    
    open override func mouseDown(with event: NSEvent) {
        isHighlighted = true
        super.mouseDown(with: event)
        isHighlighted = false
    }
    
    /// Listens for mouse hover and pass it into state
    @discardableResult
    public func hoveredByMouse(_ state: State<Bool>) -> Self {
        isHoveredByMouse.listen { [weak state] in
            state?.wrappedValue = $0
        }
        .hold(in: _properties.stateBindingHolder)

        return self
    }
    
    @discardableResult
    public func onMouseHover(_ closure: @escaping () -> Void) -> Self {
        onMouseHover { _ in
            closure()
        }
    }
    
    @discardableResult
    public func onMouseHover(_ closure: @escaping (UButton) -> Void) -> Self {
        _mouseEnteredHandler = closure
        return self
    }
    
    @discardableResult
    public func onMouseUnhover(_ closure: @escaping () -> Void) -> Self {
        onMouseUnhover { _ in
            closure()
        }
    }
    
    @discardableResult
    public func onMouseUnhover(_ closure: @escaping (UButton) -> Void) -> Self {
        _mouseExitedHandler = closure
        return self
    }
    
    // MARK: - Button Type
    
    @discardableResult
    public func type(_ type: NSButton.ButtonType) -> Self {
        _buttonTypeState.wrappedValue = type
        setButtonType(type)
        return self
    }
    
    @discardableResult
    public func type(_ state: State<NSButton.ButtonType>) -> Self {
        _buttonTypeState = state
        setButtonType(state.wrappedValue)

        state.listen { [weak self] in
            self?.setButtonType($0)
        }
        .hold(in: stateBindingHolder)

        return self
    }
    
    // MARK: Action
    
    private var actionHandler: (() -> Void)?
    private var actionSelfHandler: ((UButton) -> Void)?
    
    @objc func pushHandler() {
        _stateState.wrappedValue = state
        actionHandler?()
        actionSelfHandler?(self)
    }
    
    @discardableResult
    public func onAction(_ handler: @escaping () -> Void) -> Self {
        actionHandler = handler
        return self
    }
    
    @discardableResult
    public func onAction(_ handler: @escaping (UButton) -> Void) -> Self {
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
}

extension UButton: _Titleable {
    var _statedTitle: AnyStringBuilder.Handler? {
        get { nil }
        set {}
    }
    
    func _setTitle(_ v: NSAttributedString?) {
        attributedTitle = .init() // hack to update attributed string with changed paragraph style
        attributedTitle = v ?? .init()
    }
}

extension UButton: _Enableable {
    func _setEnabled(_ v: Bool) {
        isEnabled = v
    }
}

extension UButton: _BezelStyleable {
    func _setBezelStyle(_ v: NSButton.BezelStyle) {
        bezelStyle = v
    }
}

extension UButton: _MixedStateAllowable {
    func _setAllowMixedState(_ v: Bool) {
        allowsMixedState = v
    }
}

extension UButton: _MultiClickIgnorable {
    func _setIgnoreMultiClick(_ v: Bool) {
        ignoresMultiClick = v
    }
}

extension UButton: _Continuousable {
    func _setContinuous(_ v: Bool) {
        isContinuous = v
    }
}

extension UButton: _FirstResponderRefusable {
    func _setRefuseFirstResponder(_ v: Bool) {
        refusesFirstResponder = v
    }
}

extension UButton: _Borderedable {
    func _setBordered(_ v: Bool) {
        isBordered = v
    }
}

extension UButton: _Soundable {
    func _setSound(_ v: NSSound?) {
        sound = v
    }
}

extension UButton: _Keyable {
    func _setKey(_ v: String) {
        keyEquivalent = v
    }
}

extension UButton: _KeyMaskable {
    func _setKeyMask(_ v: NSEvent.ModifierFlags) {
        keyEquivalentModifierMask = v
    }
}

extension UButton: _ControlStateable {
    func _setState(_ v: NSControl.StateValue) {
        state = v
    }
}
#endif
#endif
