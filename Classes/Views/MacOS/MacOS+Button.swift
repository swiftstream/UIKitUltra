#if os(macOS)
import AppKit

open class UButton: NSButton, AnyDeclarativeProtocol, DeclarativeProtocolInternal {
    public var declarativeView: UButton { self }
    public lazy var properties = Properties<UButton>()
    lazy var _properties = PropertiesInternal()
    
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
