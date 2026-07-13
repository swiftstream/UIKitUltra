#if os(macOS)
import AppKit

@available(*, deprecated, renamed: "UTextView")
public typealias TextView = UTextView

@MainActor
open class UTextView: NSScrollView,
                      AnyDeclarativeProtocol,
                      DeclarativeProtocolInternal,
                      NSTextViewDelegate {
    public var declarativeView: UTextView { self }
    public typealias P = Properties<UTextView>
    public lazy var properties = P()
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

    private lazy var _tag: Int = -1
    public override var tag: Int {
        get { _tag }
        set { _tag = newValue }
    }

    // MARK: - Owned Text View

    public let textView: NSTextView

    // MARK: - Auto-Growing

    private var _minHeight: CGFloat = 0
    private var _maxHeight: CGFloat = .greatestFiniteMagnitude

    // MARK: - Editing Callbacks

    public typealias SimpleHandler = () -> Void
    public typealias SimpleHandlerText = (TextView) -> Void
    public typealias BoolHandler = () -> Bool
    public typealias BoolHandlerText = (TextView) -> Bool
    public typealias BoolHandlerTextRangeString =
        (TextView, NSRange, String) -> Bool
    public typealias BoolHandlerRangeString =
        (NSRange, String) -> Bool

    private var shouldBeginEditingHandler: BoolHandler?
    private var shouldBeginEditingHandlerText: BoolHandlerText?
    private var shouldEndEditingHandler: BoolHandler?
    private var shouldEndEditingHandlerText: BoolHandlerText?
    private var didBeginEditingHandler: SimpleHandler?
    private var didBeginEditingHandlerText: SimpleHandlerText?
    private var didEndEditingHandler: SimpleHandler?
    private var didEndEditingHandlerText: SimpleHandlerText?
    private var shouldChangeTextHandler: BoolHandler?
    private var shouldChangeTextHandlerText: BoolHandlerText?
    private var shouldChangeTextHandlerTextRangeString: BoolHandlerTextRangeString?
    private var shouldChangeTextHandlerRangeString: BoolHandlerRangeString?
    private var didChangeTextHandler: SimpleHandler?
    private var didChangeTextHandlerText: SimpleHandlerText?
    private var didChangeSelectionHandler: SimpleHandler?
    private var didChangeSelectionHandlerText: SimpleHandlerText?
    private var onFocusHandler: P.VoidClosure?
    private var onUnFocusHandler: P.VoidClosure?

    // MARK: - Command Handlers

    private var newLineHandler: (() -> Bool)?
    private var cmdEnterHandler: (() -> Bool)?
    private var optionEnterHandler: (() -> Bool)?
    private var shiftEnterHandler: (() -> Bool)?
    private var deleteForwardHandler: (() -> Bool)?
    private var deleteBackwardHandler: (() -> Bool)?
    private var insertTabHandler: (() -> Bool)?
    private var cancelOperationHandler: (() -> Bool)?

    // MARK: - Focus

    @UIKitPlus.State public var isFirstResponder = false
    private var _tintColor: NSColor?

    // MARK: - Layout State

    private var _isUpdatingHeight = false
    private var _currentIntrinsicHeight: CGFloat = 0

    // MARK: - Initializers

    public init(_ string: AnyString...) {
        let textView = NSTextView(frame: .zero)
        self.textView = textView
        super.init(frame: .zero)
        _setup()
        text(string)
    }

    public init(_ strings: [AnyString]) {
        let textView = NSTextView(frame: .zero)
        self.textView = textView
        super.init(frame: .zero)
        _setup()
        text(strings)
    }

    public init(_ localized: LocalizedString...) {
        let textView = NSTextView(frame: .zero)
        self.textView = textView
        super.init(frame: .zero)
        _setup()
        text(localized)
    }

    public init(_ localized: [LocalizedString]) {
        let textView = NSTextView(frame: .zero)
        self.textView = textView
        super.init(frame: .zero)
        _setup()
        text(localized)
    }

    public init<A: AnyString>(_ state: UIKitPlus.State<A>) {
        let textView = NSTextView(frame: .zero)
        self.textView = textView
        super.init(frame: .zero)
        _setup()
        text(state)
    }

    public init(
        @AnyStringBuilder stateString: @escaping AnyStringBuilder.Handler
    ) {
        let textView = NSTextView(frame: .zero)
        self.textView = textView
        super.init(frame: .zero)
        _setup()
        text(stateString: stateString)
    }

    public override init(frame: CGRect) {
        let textView = NSTextView(frame: .zero)
        self.textView = textView
        super.init(frame: frame)
        _setup()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func _setup() {
        translatesAutoresizingMaskIntoConstraints = false

        borderType = .noBorder
        drawsBackground = false
        backgroundColor = .clear
        contentView.drawsBackground = false
        contentView.backgroundColor = .clear
        hasHorizontalScroller = false
        hasVerticalScroller = false
        autohidesScrollers = true
        scrollerStyle = .overlay

        textView.drawsBackground = false
        textView.backgroundColor = .clear
        textView.isRichText = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.heightTracksTextView = false
        textView.textContainer?.lineFragmentPadding = 0
        textView.textContainer?.size.height = CGFloat.greatestFiniteMagnitude

        textView.delegate = self
        documentView = textView
    }

    // MARK: - Layout

    open override func layout() {
        super.layout()
        _updateTextViewWidth()
        _updateIntrinsicContentSize()
        onLayoutSubviews()
    }

    open override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        movedToSuperview()
    }

    open override var intrinsicContentSize: NSSize {
        NSSize(
            width: NSView.noIntrinsicMetric,
            height: _currentIntrinsicHeight
        )
    }

    // MARK: - Background

    func _setBackgroundColor(_ value: NSColor?) {
        let resolvedColor: NSColor

        if let value, value != .clear {
            resolvedColor = value
        } else {
            resolvedColor = .clear
        }

        drawsBackground = false
        backgroundColor = .clear

        contentView.backgroundColor = resolvedColor
        contentView.drawsBackground = resolvedColor != .clear

        textView.backgroundColor = .clear
        textView.drawsBackground = false

        contentView.needsDisplay = true
        textView.needsDisplay = true
        needsDisplay = true
    }

    // MARK: - Text

    @discardableResult
    public func text(_ value: String) -> Self {
        _applyAttributedText(NSAttributedString(string: value))
        return self
    }

    public var stringValue: String {
        get { textView.string }
        set { _applyAttributedText(NSAttributedString(string: newValue)) }
    }

    private func _applyAttributedText(_ value: NSAttributedString?) {
        let oldSelection = textView.selectedRange()
        guard let textStorage = textView.textStorage else {
            _updateTextViewWidth()
            _updateIntrinsicContentSize()
            return
        }
        textStorage.setAttributedString(value ?? NSAttributedString())

        let length = textStorage.length
        guard oldSelection.location != NSNotFound else {
            _updateTextViewWidth()
            _updateIntrinsicContentSize()
            _scrollSelectionToVisible()
            return
        }

        let location = Swift.min(Swift.max(oldSelection.location, 0), length)
        let availableLength = Swift.max(length - location, 0)
        let selection = NSRange(
            location: location,
            length: Swift.min(Swift.max(oldSelection.length, 0), availableLength)
        )
        textView.setSelectedRange(selection)
        _updateTextViewWidth()
        _updateIntrinsicContentSize()
        _scrollSelectionToVisible()
    }

    // MARK: - Text Insets and Auto-Growing

    @discardableResult
    public func textInsets(horizontal: CGFloat, vertical: CGFloat) -> Self {
        textInsets(NSSize(width: horizontal, height: vertical))
    }

    @discardableResult
    public func textInsets(_ value: CGFloat) -> Self {
        textInsets(NSSize(width: value, height: value))
    }

    @discardableResult
    public func textInsets(_ value: NSSize) -> Self {
        textView.textContainerInset = value
        _updateTextViewWidth()
        _updateIntrinsicContentSize()
        return self
    }

    @discardableResult
    public func autoGrowing(minHeight: CGFloat, maxHeight: CGFloat) -> Self {
        _minHeight = Swift.max(minHeight, 0)
        _maxHeight = Swift.max(maxHeight, _minHeight)
        _updateIntrinsicContentSize()
        return self
    }

    // MARK: - Editing Lifecycle

    @discardableResult
    public func onShouldBeginEditing(_ handler: @escaping BoolHandler) -> Self {
        shouldBeginEditingHandlerText = nil
        shouldBeginEditingHandler = handler
        return self
    }

    @discardableResult
    public func onShouldBeginEditing(_ handler: @escaping BoolHandlerText) -> Self {
        shouldBeginEditingHandler = nil
        shouldBeginEditingHandlerText = handler
        return self
    }

    @discardableResult
    public func onShouldEndEditing(_ handler: @escaping BoolHandler) -> Self {
        shouldEndEditingHandlerText = nil
        shouldEndEditingHandler = handler
        return self
    }

    @discardableResult
    public func onShouldEndEditing(_ handler: @escaping BoolHandlerText) -> Self {
        shouldEndEditingHandler = nil
        shouldEndEditingHandlerText = handler
        return self
    }

    @discardableResult
    public func onDidBeginEditing(_ handler: @escaping SimpleHandler) -> Self {
        didBeginEditingHandler = handler
        return self
    }

    @discardableResult
    public func onDidBeginEditing(_ handler: @escaping SimpleHandlerText) -> Self {
        didBeginEditingHandlerText = handler
        return self
    }

    @discardableResult
    public func onDidEndEditing(_ handler: @escaping SimpleHandler) -> Self {
        didEndEditingHandler = handler
        return self
    }

    @discardableResult
    public func onDidEndEditing(_ handler: @escaping SimpleHandlerText) -> Self {
        didEndEditingHandlerText = handler
        return self
    }

    @discardableResult
    public func onShouldChangeText(_ handler: @escaping BoolHandler) -> Self {
        shouldChangeTextHandler = handler
        shouldChangeTextHandlerText = nil
        shouldChangeTextHandlerTextRangeString = nil
        shouldChangeTextHandlerRangeString = nil
        return self
    }

    @discardableResult
    public func onShouldChangeText(_ handler: @escaping BoolHandlerText) -> Self {
        shouldChangeTextHandler = nil
        shouldChangeTextHandlerText = handler
        shouldChangeTextHandlerTextRangeString = nil
        shouldChangeTextHandlerRangeString = nil
        return self
    }

    @discardableResult
    public func onShouldChangeText(
        _ handler: @escaping BoolHandlerTextRangeString
    ) -> Self {
        shouldChangeTextHandler = nil
        shouldChangeTextHandlerText = nil
        shouldChangeTextHandlerTextRangeString = handler
        shouldChangeTextHandlerRangeString = nil
        return self
    }

    @discardableResult
    public func onShouldChangeText(
        _ handler: @escaping BoolHandlerRangeString
    ) -> Self {
        shouldChangeTextHandler = nil
        shouldChangeTextHandlerText = nil
        shouldChangeTextHandlerTextRangeString = nil
        shouldChangeTextHandlerRangeString = handler
        return self
    }

    @discardableResult
    public func onTextDidChange(_ handler: @escaping SimpleHandler) -> Self {
        didChangeTextHandler = handler
        return self
    }

    @discardableResult
    public func onTextDidChange(_ handler: @escaping SimpleHandlerText) -> Self {
        didChangeTextHandlerText = handler
        return self
    }

    @discardableResult
    public func onTextChanged(
        _ closure: @escaping (UTextView) -> Void
    ) -> Self {
        onTextDidChange(closure)
    }

    @discardableResult
    public func onDidChangeSelection(_ handler: @escaping SimpleHandler) -> Self {
        didChangeSelectionHandler = handler
        return self
    }

    @discardableResult
    public func onDidChangeSelection(_ handler: @escaping SimpleHandlerText) -> Self {
        didChangeSelectionHandlerText = handler
        return self
    }

    // MARK: - Focus

    @discardableResult
    public func dropFocus() -> Self {
        window?.makeFirstResponder(nil)
        return self
    }

    @discardableResult
    public func onFocus(_ closure: @escaping P.VoidClosure) -> Self {
        onFocusHandler = closure
        return self
    }

    @discardableResult
    public func onUnFocus(_ closure: @escaping P.VoidClosure) -> Self {
        onUnFocusHandler = closure
        return self
    }

    // MARK: - Command Actions

    @discardableResult
    public func onNewLineAction(
        pass: Bool = false,
        _ closure: @escaping P.EmptyVoidClosure
    ) -> Self {
        onNewLineAction { _ -> Bool in
            closure()
            return pass
        }
    }

    @discardableResult
    public func onNewLineAction(
        pass: Bool = false,
        _ closure: @escaping P.VoidClosure
    ) -> Self {
        onNewLineAction { _ -> Bool in
            closure(self)
            return pass
        }
    }

    @discardableResult
    public func onNewLineAction(_ closure: @escaping P.EmptyBoolClosure) -> Self {
        onNewLineAction { _ in closure() }
    }

    @discardableResult
    public func onNewLineAction(_ closure: @escaping P.BoolClosure) -> Self {
        newLineHandler = { !closure(self) }
        return self
    }

    @discardableResult
    public func onCmdEnterAction(
        pass: Bool = false,
        _ closure: @escaping P.EmptyVoidClosure
    ) -> Self {
        onCmdEnterAction { _ -> Bool in
            closure()
            return pass
        }
    }

    @discardableResult
    public func onCmdEnterAction(
        pass: Bool = false,
        _ closure: @escaping P.VoidClosure
    ) -> Self {
        onCmdEnterAction { _ -> Bool in
            closure(self)
            return pass
        }
    }

    @discardableResult
    public func onCmdEnterAction(_ closure: @escaping P.EmptyBoolClosure) -> Self {
        onCmdEnterAction { _ in closure() }
    }

    @discardableResult
    public func onCmdEnterAction(_ closure: @escaping P.BoolClosure) -> Self {
        cmdEnterHandler = { !closure(self) }
        return self
    }

    @discardableResult
    public func onOptionEnterAction(
        pass: Bool = false,
        _ closure: @escaping P.EmptyVoidClosure
    ) -> Self {
        onOptionEnterAction { _ -> Bool in
            closure()
            return pass
        }
    }

    @discardableResult
    public func onOptionEnterAction(
        pass: Bool = false,
        _ closure: @escaping P.VoidClosure
    ) -> Self {
        onOptionEnterAction { _ -> Bool in
            closure(self)
            return pass
        }
    }

    @discardableResult
    public func onOptionEnterAction(_ closure: @escaping P.EmptyBoolClosure) -> Self {
        onOptionEnterAction { _ in closure() }
    }

    @discardableResult
    public func onOptionEnterAction(_ closure: @escaping P.BoolClosure) -> Self {
        optionEnterHandler = { !closure(self) }
        return self
    }

    @discardableResult
    public func onShiftEnterAction(
        pass: Bool = false,
        _ closure: @escaping P.EmptyVoidClosure
    ) -> Self {
        onShiftEnterAction { _ -> Bool in
            closure()
            return pass
        }
    }

    @discardableResult
    public func onShiftEnterAction(
        pass: Bool = false,
        _ closure: @escaping P.VoidClosure
    ) -> Self {
        onShiftEnterAction { _ -> Bool in
            closure(self)
            return pass
        }
    }

    @discardableResult
    public func onShiftEnterAction(_ closure: @escaping P.EmptyBoolClosure) -> Self {
        onShiftEnterAction { _ in closure() }
    }

    @discardableResult
    public func onShiftEnterAction(_ closure: @escaping P.BoolClosure) -> Self {
        shiftEnterHandler = { !closure(self) }
        return self
    }

    @discardableResult
    public func onDeleteForwardAction(
        pass: Bool = false,
        _ closure: @escaping P.EmptyVoidClosure
    ) -> Self {
        onDeleteForwardAction { _ -> Bool in
            closure()
            return pass
        }
    }

    @discardableResult
    public func onDeleteForwardAction(
        pass: Bool = false,
        _ closure: @escaping P.VoidClosure
    ) -> Self {
        onDeleteForwardAction { _ -> Bool in
            closure(self)
            return pass
        }
    }

    @discardableResult
    public func onDeleteForwardAction(_ closure: @escaping P.EmptyBoolClosure) -> Self {
        onDeleteForwardAction { _ in closure() }
    }

    @discardableResult
    public func onDeleteForwardAction(_ closure: @escaping P.BoolClosure) -> Self {
        deleteForwardHandler = { !closure(self) }
        return self
    }

    @discardableResult
    public func onDeleteBackwardAction(
        pass: Bool = false,
        _ closure: @escaping P.EmptyVoidClosure
    ) -> Self {
        onDeleteBackwardAction { _ -> Bool in
            closure()
            return pass
        }
    }

    @discardableResult
    public func onDeleteBackwardAction(
        pass: Bool = false,
        _ closure: @escaping P.VoidClosure
    ) -> Self {
        onDeleteBackwardAction { _ -> Bool in
            closure(self)
            return pass
        }
    }

    @discardableResult
    public func onDeleteBackwardAction(_ closure: @escaping P.EmptyBoolClosure) -> Self {
        onDeleteBackwardAction { _ in closure() }
    }

    @discardableResult
    public func onDeleteBackwardAction(_ closure: @escaping P.BoolClosure) -> Self {
        deleteBackwardHandler = { !closure(self) }
        return self
    }

    @discardableResult
    public func onInsertTabAction(
        pass: Bool = false,
        _ closure: @escaping P.EmptyVoidClosure
    ) -> Self {
        onInsertTabAction { _ -> Bool in
            closure()
            return pass
        }
    }

    @discardableResult
    public func onInsertTabAction(
        pass: Bool = false,
        _ closure: @escaping P.VoidClosure
    ) -> Self {
        onInsertTabAction { _ -> Bool in
            closure(self)
            return pass
        }
    }

    @discardableResult
    public func onInsertTabAction(_ closure: @escaping P.EmptyBoolClosure) -> Self {
        onInsertTabAction { _ in closure() }
    }

    @discardableResult
    public func onInsertTabAction(_ closure: @escaping P.BoolClosure) -> Self {
        insertTabHandler = { !closure(self) }
        return self
    }

    @discardableResult
    public func onCancelAction(
        pass: Bool = false,
        _ closure: @escaping P.EmptyVoidClosure
    ) -> Self {
        onCancelAction { _ -> Bool in
            closure()
            return pass
        }
    }

    @discardableResult
    public func onCancelAction(
        pass: Bool = false,
        _ closure: @escaping P.VoidClosure
    ) -> Self {
        onCancelAction { _ -> Bool in
            closure(self)
            return pass
        }
    }

    @discardableResult
    public func onCancelAction(_ closure: @escaping P.EmptyBoolClosure) -> Self {
        onCancelAction { _ in closure() }
    }

    @discardableResult
    public func onCancelAction(_ closure: @escaping P.BoolClosure) -> Self {
        cancelOperationHandler = { !closure(self) }
        return self
    }

    // MARK: - NSTextViewDelegate

    public func textShouldBeginEditing(_ textObject: NSText) -> Bool {
        if let handler = shouldBeginEditingHandler {
            return handler()
        }
        if let handler = shouldBeginEditingHandlerText {
            return handler(self)
        }
        return true
    }

    public func textDidBeginEditing(_ notification: Notification) {
        isFirstResponder = true
        onFocusHandler?(self)
        didBeginEditingHandler?()
        didBeginEditingHandlerText?(self)
        _updateCursorColor()
    }

    public func textShouldEndEditing(_ textObject: NSText) -> Bool {
        if let handler = shouldEndEditingHandler {
            return handler()
        }
        if let handler = shouldEndEditingHandlerText {
            return handler(self)
        }
        return true
    }

    public func textDidEndEditing(_ notification: Notification) {
        isFirstResponder = false
        onUnFocusHandler?(self)
        didEndEditingHandler?()
        didEndEditingHandlerText?(self)
    }

    public func textView(
        _ textView: NSTextView,
        shouldChangeTextIn affectedCharRange: NSRange,
        replacementString: String?
    ) -> Bool {
        let replacement = replacementString ?? ""
        if let handler = shouldChangeTextHandler {
            return handler()
        }
        if let handler = shouldChangeTextHandlerText {
            return handler(self)
        }
        if let handler = shouldChangeTextHandlerTextRangeString {
            return handler(self, affectedCharRange, replacement)
        }
        if let handler = shouldChangeTextHandlerRangeString {
            return handler(affectedCharRange, replacement)
        }
        return true
    }

    public func textDidChange(_ notification: Notification) {
        _didChangeTextPipeline()
    }

    public func textViewDidChangeSelection(_ notification: Notification) {
        didChangeSelectionHandler?()
        didChangeSelectionHandlerText?(self)
    }

    public func textView(
        _ textView: NSTextView,
        doCommandBy commandSelector: Selector
    ) -> Bool {
        let modifierFlags = NSApp.currentEvent?.modifierFlags
            .intersection(.deviceIndependentFlagsMask) ?? []
        return _handleCommand(commandSelector, modifierFlags: modifierFlags)
    }

    func _handleCommand(
        _ commandSelector: Selector,
        modifierFlags: NSEvent.ModifierFlags
    ) -> Bool {
        let normalizedFlags = modifierFlags.intersection(.deviceIndependentFlagsMask)

        if commandSelector == #selector(NSResponder.insertNewline(_:))
            || commandSelector == #selector(NSResponder.insertNewlineIgnoringFieldEditor(_:)) {
            switch normalizedFlags {
            case []:
                return newLineHandler?() ?? false
            case [.command]:
                return cmdEnterHandler?() ?? false
            case [.option]:
                return optionEnterHandler?() ?? false
            case [.shift]:
                return shiftEnterHandler?() ?? false
            default:
                return false
            }
        }

        switch commandSelector {
        case #selector(NSResponder.deleteForward(_:)):
            return deleteForwardHandler?() ?? false
        case #selector(NSResponder.deleteBackward(_:)):
            return deleteBackwardHandler?() ?? false
        case #selector(NSResponder.insertTab(_:)):
            return insertTabHandler?() ?? false
        case #selector(NSResponder.cancelOperation(_:)):
            return cancelOperationHandler?() ?? false
        default:
            return false
        }
    }

    // MARK: - Focus and Text Mutation Internals

    private func _updateCursorColor() {
        guard let color = _tintColor else { return }
        textView.insertionPointColor = color
    }

    private func _didChangeTextPipeline() {
        _updateTextViewWidth()
        _updateIntrinsicContentSize()

        _properties.typingTimer?.invalidate()
        _properties.typingTimer = Timer.scheduledTimer(
            timeInterval: _properties.typingInterval,
            target: self,
            selector: #selector(_invalidateTypingTimer),
            userInfo: nil,
            repeats: false
        )
        _properties.isTyping = true

        didChangeTextHandler?()
        didChangeTextHandlerText?(self)
        _properties.textChangeListeners.forEach {
            $0(textView.textStorage ?? NSAttributedString())
        }
        _scrollSelectionToVisible()
    }

    @objc private func _invalidateTypingTimer() {
        _properties.isTyping = false
    }

    // MARK: - Geometry

    private func _measureContentHeight() -> CGFloat {
        let availableWidth = contentView.bounds.width
        guard availableWidth > 0 else { return _minHeight }

        guard
            let textContainer = textView.textContainer,
            let layoutManager = textView.layoutManager
        else {
            return _minHeight
        }

        let insetWidth = availableWidth - textView.textContainerInset.width * 2
        textContainer.size.width = Swift.max(insetWidth, 1)
        textContainer.size.height = CGFloat.greatestFiniteMagnitude

        layoutManager.ensureLayout(for: textContainer)
        let usedRect = layoutManager.usedRect(for: textContainer)
        let height = usedRect.height + textView.textContainerInset.height * 2
        return height.rounded(.up)
    }

    private func _clampHeight(_ contentHeight: CGFloat) -> CGFloat {
        guard _maxHeight < .greatestFiniteMagnitude else {
            return Swift.max(contentHeight, _minHeight)
        }
        return Swift.min(
            Swift.max(contentHeight, _minHeight),
            _maxHeight
        )
    }

    private func _updateTextViewWidth() {
        let availableWidth = contentView.bounds.width
        guard availableWidth > 0 else { return }
        textView.frame.size.width = availableWidth
        guard let textContainer = textView.textContainer else { return }
        let insetWidth = availableWidth - textView.textContainerInset.width * 2
        textContainer.size.width = Swift.max(insetWidth, 1)
        textContainer.size.height = CGFloat.greatestFiniteMagnitude
    }

    private func _updateIntrinsicContentSize() {
        guard !_isUpdatingHeight else { return }
        _isUpdatingHeight = true
        defer { _isUpdatingHeight = false }

        let contentHeight = _measureContentHeight()
        let clampedHeight = _clampHeight(contentHeight)
        let documentHeight = Swift.max(contentHeight, clampedHeight)
        textView.frame.size.height = documentHeight

        let tolerance: CGFloat = 0.5
        hasVerticalScroller =
            _maxHeight < .greatestFiniteMagnitude
            && contentHeight > clampedHeight + tolerance

        if abs(clampedHeight - _currentIntrinsicHeight) > tolerance {
            _currentIntrinsicHeight = clampedHeight
            invalidateIntrinsicContentSize()
            superview?.needsLayout = true
            needsLayout = true
        }
    }

    private func _scrollSelectionToVisible() {
        let range = textView.selectedRange()
        guard range.location != NSNotFound else { return }
        textView.scrollRangeToVisible(range)
    }
}

extension UTextView: Refreshable {
    public func refresh() {
        if let statedText = _properties.statedText {
            text(statedText())
        }
    }
}

extension UTextView: _Editableable {
    func _setEditable(_ v: Bool) {
        textView.isEditable = v
    }
}

extension UTextView: _Enableable {
    func _setEnabled(_ v: Bool) {
        textView.isEditable = v
    }
}

extension UTextView: _Fontable {
    func _setFont(_ v: NSFont?) {
        textView.font = v
    }
}

extension UTextView: _Cleanupable {
    func _cleanup() {
        _setText(NSAttributedString())
        _didChangeTextPipeline()
    }
}

extension UTextView: _Colorable {
    var _colorState: UIKitPlus.State<UColor> { properties.textColorState }

    func _setColor(_ v: NSColor?) {
        textView.textColor = v
        properties.textColor = v.map(Color.init) ?? .clear
    }
}

extension UTextView: _TextAligmentable {
    func _setTextAlignment(v: NSTextAlignment) {
        textView.alignment = v
    }
}

extension UTextView: _TextBindable {
    func _setTextBind<A: AnyString>(_ binding: UIKitPlus.State<A>?) {
        _properties.textChangeListeners.append { new in
            binding?.wrappedValue = A.make(new)
        }
    }
}

extension UTextView: _Textable {
    var _currentText: String { textView.string }

    var _statedText: AnyStringBuilder.Handler? {
        get { _properties.statedText }
        set { _properties.statedText = newValue }
    }

    func _setText(_ v: NSAttributedString?) {
        _applyAttributedText(v)
    }
}

extension UTextView: _Typeable {
    func _setTypingInterval(_ v: TimeInterval) {
        _properties.typingInterval = v
    }

    func _observeTypingState(_ v: UIKitPlus.State<Bool>) {
        _properties.isTypingState.listen { [weak v] in
            guard let v else { return }
            guard v.wrappedValue != $0 else { return }
            v.wrappedValue = $0
        }
        .hold(in: stateBindingHolder)
        if v.wrappedValue != _properties.isTyping {
            v.wrappedValue = _properties.isTyping
        }
    }
}

extension UTextView: _Tintable {
    var _tintState: UIKitPlus.State<UColor> { properties.tintState }

    func _setTint(_ v: NSColor?) {
        _tintColor = v
        _updateCursorColor()
    }
}

extension UTextView: _FocusRingTypeable {
    func _setFocusRingType(_ v: NSFocusRingType) {
        textView.focusRingType = v
    }
}
#endif
