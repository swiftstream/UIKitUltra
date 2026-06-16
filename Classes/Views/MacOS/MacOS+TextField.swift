#if os(macOS)
import Foundation
import AppKit

@MainActor
open class UTextField: NSTextField, AnyDeclarativeProtocol, DeclarativeProtocolInternal {
    public var declarativeView: UTextField { self }
    public typealias P = Properties<UTextField>
    public lazy var properties = P()
    lazy var _properties = PropertiesInternal()
    fileprivate lazy var _formatter = _Formatter(self)
    
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
    
    fileprivate weak var outsideDelegate: TextFieldDelegate?
    
    public init (_ string: AnyString...) {
        super.init(frame: .zero)
        _setup()
        text(string)
    }
    
    public init (_ strings: [AnyString]) {
        super.init(frame: .zero)
        _setup()
        text(strings)
    }
    
    public init (_ localized: LocalizedString...) {
        super.init(frame: .zero)
        _setup()
        text(localized)
    }
    
    public init (_ localized: [LocalizedString]) {
        super.init(frame: .zero)
        _setup()
        text(localized)
    }
    
    public init<A: AnyString>(_ state: UIKitPlus.State<A>) {
        super.init(frame: .zero)
        _setup()
        text(state)
    }
    
    public init (@AnyStringBuilder stateString: @escaping AnyStringBuilder.Handler) {
        super.init(frame: .zero)
        _setup()
        text(stateString: stateString)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor
    open override func layout() {
        super.layout()
        onLayoutSubviews()
    }
    
    @MainActor
    open override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        movedToSuperview()
    }
    
    fileprivate lazy var _innerDelegate = _InnerDelegate(self)
    
    open override var stringValue: String {
        get { attributedStringValue.string }
        set { attributedStringValue = .init(string: newValue) }
    }
    
    func _setup() {
        translatesAutoresizingMaskIntoConstraints = false
        delegate = _innerDelegate
        formatter = _formatter
    }
    
    @discardableResult
    public func delegate(_ delegate: TextFieldDelegate?) -> Self {
        self.outsideDelegate = delegate
        return self
    }
    
    // MARK: Delegate Closures
    
    @discardableResult
    public func shouldBeginEditing(_ closure: @escaping P.BoolClosure) -> Self {
        properties._shouldBeginEditing = closure
        return self
    }
    
    @discardableResult
    public func didBeginEditing(_ closure: @escaping P.VoidClosure) -> Self {
        properties._didBeginEditing.append(closure)
        return self
    }
    
    @discardableResult
    public func shouldEndEditing(_ closure: @escaping P.BoolClosure) -> Self {
        properties._shouldEndEditing = closure
        return self
    }
    
    @discardableResult
    public func didEndEditing(_ closure: @escaping P.VoidClosure) -> Self {
        properties._didEndEditing.append(closure)
        return self
    }
    
    @State public var isFirstResponder = false
    
    open override func becomeFirstResponder() -> Bool {
        guard super.becomeFirstResponder() else { return false }
        isFirstResponder = true
        _onFocusHandler?(self)
        _updateCursorColor()
        return true
    }
    
    open override func textDidEndEditing(_ notification: Notification) { // best thing to catch loosing focus
        super.textDidEndEditing(notification)
        guard String(describing: notification.userInfo?["_NSFirstResponderReplacingFieldEditor"]).contains("NSWindow") == false else { return } // dirty hack
        guard currentEditor() == nil else { return }
        isFirstResponder = false
        _onUnFocusHandler?(self)
        properties._editingDidEnd.forEach { $0(self) }
    }
    
    // MARK: Focus
    
    @discardableResult
    public func dropFocus() -> Self {
        window?.makeFirstResponder(nil)
        return self
    }
    
    private var _onFocusHandler: P.VoidClosure?
    fileprivate var _onUnFocusHandler: P.VoidClosure?
    
    @discardableResult
    public func onFocus(_ closure: @escaping P.VoidClosure) -> Self {
        _onFocusHandler = closure
        return self
    }
    
    @discardableResult
    public func onUnFocus(_ closure: @escaping P.VoidClosure) -> Self {
        _onUnFocusHandler = closure
        return self
    }
    
    // MARK: Tint
    
    var _tintColor: NSColor?
    
    func _updateCursorColor() {
        guard let editor = currentEditor() as? NSTextView, let color = _tintColor else { return }
        editor.insertionPointColor = color
    }
    
    /// An alternative to `shouldChangeCharacters`
    /// It will disable `shouldChangeCharacters`
    ///
    /// Use this handler with formatters like `AnyFormatKit`
    ///
    /// ```swift
    /// import AnyFormatKit
    ///
    /// fileprivate let phoneFormatter = DefaultTextInputFormatter(textPattern: "(###) ###-####")
    ///
    /// extension TextField {
    ///     static var phone: TextField {
    ///         return TextField()
    ///             .content(.telephoneNumber)
    ///             .autocapitalization(.none)
    ///             .autocorrection(.no)
    ///             .keyboard(.phonePad)
    ///             .font(.articoRegular, 15)
    ///             .placeholder("(555) 123-4567".foreground(.darkGrey).font(.helveticaNeueRegular, 15))
    ///             .color(.blackHole)
    ///             .height(18)
    ///             .formatCharacters { textField, range, text in
    ///                 let result = phoneFormatter.formatInput(currentText: textField.stringValue, range: range, replacementString: text)
    ///                 textField.stringValue = result.formattedText
    ///                 textField.currentEditor()?.selectedRange = NSRange(location: result.caretBeginOffset, length: 0)
    ///             }
    ///     }
    /// }
    /// ```
    @discardableResult
    public func formatCharacters(_ closure: @escaping P.FormatCharactersClosure) -> Self {
        properties._shouldFormatCharacters = closure
        return self
    }
    
    @discardableResult
    public func shouldChangeCharacters(_ closure: @escaping P.ChangeCharactersClosure) -> Self {
        properties._shouldChangeCharacters = closure
        return self
    }
    
    @discardableResult
    public func shouldClear(_ closure: @escaping P.BoolClosure) -> Self {
        properties._shouldClear = closure
        return self
    }
    
//    @discardableResult
//    public func shouldReturn(_ closure: @escaping () -> Void) -> Self {
//        properties._shouldReturnVoid = closure
//        return self
//    }
//
//    @discardableResult
//    public func shouldReturn(_ closure: @escaping P.BoolClosure) -> Self {
//        properties._shouldReturn = closure
//        return self
//    }
    
//    @discardableResult
//    public func shouldReturnToNextResponder() -> Self {
//        properties._shouldReturnVoid = {
//            self.focusToNextResponderOrResign()
//        }
//        return self
//    }

    @discardableResult
    public func formater(_ v: Formatter) -> Self {
        formatter = v
        return self
    }
    
    @discardableResult
    public func editingDidBegin(_ closure: @escaping P.VoidClosure) -> Self {
        properties._editingDidBegin.append(closure)
        return self
    }
    
    @discardableResult
    public func editingChanged(_ closure: @escaping P.VoidClosure) -> Self {
        properties._editingChanged.append(closure)
        return self
    }
    
    @discardableResult
    public func editingDidEnd(_ closure: @escaping P.VoidClosure) -> Self {
        properties._editingDidEnd.append(closure)
        return self
    }
    
    @discardableResult
    public func onAction(_ closure: @escaping P.EmptyVoidClosure) -> Self {
        properties._textFieldEmptyAction.append(closure)
        return self
    }
    
    @discardableResult
    public func onAction(_ closure: @escaping P.VoidClosure) -> Self {
        properties._textFieldAction.append(closure)
        return self
    }
    
    // MARK: NewLine Action
    
    @discardableResult
    public func onNewLineAction(pass: Bool = false, _ closure: @escaping P.EmptyVoidClosure) -> Self {
        onNewLineAction { _ -> Bool in
            closure()
            return pass
        }
    }
    
    @discardableResult
    public func onNewLineAction(pass: Bool = false, _ closure: @escaping P.VoidClosure) -> Self {
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
        _innerDelegate.newLineHandler = { !closure(self) }
        return self
    }
    
    // MARK: Cmd+Enter Action
    
    @discardableResult
    public func onCmdEnterAction(pass: Bool = false, _ closure: @escaping P.EmptyVoidClosure) -> Self {
        onCmdEnterAction { _ -> Bool in
            closure()
            return pass
        }
    }
    
    @discardableResult
    public func onCmdEnterAction(pass: Bool = false, _ closure: @escaping P.VoidClosure) -> Self {
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
        _innerDelegate.cmdEnterHandler = { !closure(self) }
        return self
    }
    
    // MARK: Option+Enter Action
    
    @discardableResult
    public func onOptionEnterAction(pass: Bool = false, _ closure: @escaping P.EmptyVoidClosure) -> Self {
        onOptionEnterAction { _ -> Bool in
            closure()
            return pass
        }
    }
    
    @discardableResult
    public func onOptionEnterAction(pass: Bool = false, _ closure: @escaping P.VoidClosure) -> Self {
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
        _innerDelegate.optionEnterHandler = { !closure(self) }
        return self
    }
    
    // MARK: Shift+Enter Action
    
    @discardableResult
    public func onShiftEnterAction(pass: Bool = false, _ closure: @escaping P.EmptyVoidClosure) -> Self {
        onShiftEnterAction { _ -> Bool in
            closure()
            return pass
        }
    }
    
    @discardableResult
    public func onShiftEnterAction(pass: Bool = false, _ closure: @escaping P.VoidClosure) -> Self {
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
        _innerDelegate.shiftEnterHandler = { !closure(self) }
        return self
    }
    
    // MARK: DeleteForward Action
    
    @discardableResult
    public func onDeleteForwardAction(pass: Bool = false, _ closure: @escaping P.EmptyVoidClosure) -> Self {
        onDeleteForwardAction { _ -> Bool in
            closure()
            return pass
        }
    }
    
    @discardableResult
    public func onDeleteForwardAction(pass: Bool = false, _ closure: @escaping P.VoidClosure) -> Self {
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
        _innerDelegate.deleteForwardHandler = { !closure(self) }
        return self
    }
    
    // MARK: DeleteBackward Action
    
    @discardableResult
    public func onDeleteBackwardAction(pass: Bool = false, _ closure: @escaping P.EmptyVoidClosure) -> Self {
        onDeleteBackwardAction { _ -> Bool in
            closure()
            return pass
        }
    }
    
    @discardableResult
    public func onDeleteBackwardAction(pass: Bool = false, _ closure: @escaping P.VoidClosure) -> Self {
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
        _innerDelegate.deleteBackwardHandler = { !closure(self) }
        return self
    }
    
    // MARK: InsertTab Action
    
    @discardableResult
    public func onInsertTabAction(pass: Bool = false, _ closure: @escaping P.EmptyVoidClosure) -> Self {
        onInsertTabAction { _ -> Bool in
            closure()
            return pass
        }
    }
    
    @discardableResult
    public func onInsertTabAction(pass: Bool = false, _ closure: @escaping P.VoidClosure) -> Self {
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
        _innerDelegate.insertTabHandler = { !closure(self) }
        return self
    }
    
    // MARK: Cancel Action
    
    @discardableResult
    public func onCancelAction(pass: Bool = false, _ closure: @escaping P.EmptyVoidClosure) -> Self {
        onCancelAction { _ -> Bool in
            closure()
            return pass
        }
    }
    
    @discardableResult
    public func onCancelAction(pass: Bool = false, _ closure: @escaping P.VoidClosure) -> Self {
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
        _innerDelegate.cancelOperationHandler = { !closure(self) }
        return self
    }
    
    // MARK:
    
    func _setBackgroundColor(_ v: NSColor?) {
        guard v != .clear else {
            (cell as? NSTextFieldCell)?.drawsBackground = false
            return
        }
        guard let v = v else {
            (cell as? NSTextFieldCell)?.drawsBackground = false
            return
        }
        (cell as? NSTextFieldCell)?.drawsBackground = true
        (cell as? NSTextFieldCell)?.backgroundColor = v
    }
    
    public func `return`() {
        _innerDelegate.action()
        _innerDelegate.newLineHandler?()
    }
}

@MainActor
fileprivate class _InnerDelegate: NSObject, NSTextFieldDelegate, NSTextDelegate {
    let parent: UTextField
    
    init (_ textField: UTextField) {
        parent = textField
        super.init()
        parent.target = self
        parent.action = #selector(action)
    }
    
    var newLineHandler: (() -> Bool)?
    var cmdEnterHandler: (() -> Bool)?
    var optionEnterHandler: (() -> Bool)?
    var shiftEnterHandler: (() -> Bool)?
    var deleteForwardHandler: (() -> Bool)?
    var deleteBackwardHandler: (() -> Bool)?
    var insertTabHandler: (() -> Bool)?
    var cancelOperationHandler: (() -> Bool)?
    
    @MainActor
    @objc func action() {
        parent.properties._textFieldAction.forEach { $0(self.parent) }
        parent.properties._textFieldEmptyAction.forEach { $0() }
    }
    
    @MainActor
    @objc func editingDidBegin() {
        parent.properties._editingDidBegin.forEach { $0(self.parent) }
    }
    
    @MainActor
    @objc private func invalidateTimer() {
        parent._properties.isTyping = false
    }
    
    @MainActor
    @objc func editingChanged() {
        parent._properties.typingTimer?.invalidate()
        parent._properties.typingTimer = Timer.scheduledTimer(timeInterval: parent._properties.typingInterval, target: self, selector: #selector(invalidateTimer), userInfo: nil, repeats: false)
        parent._properties.isTyping = true
        parent.properties._editingChanged.forEach { $0(self.parent) }
        parent._properties.textChangeListeners.forEach {
            $0(parent.attributedStringValue)
        }
    }
    
    @objc func editingDidEnd() {
        // almost useless...
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case "noop:": // any unsupported combination
            guard let event = NSApp.currentEvent else {
                return false
            }
            if event.key == .enter, event.modifierFlags.contains(.command), let result = cmdEnterHandler?(), result {
                return true
            }
            return false
        case #selector(NSResponder.insertNewlineIgnoringFieldEditor(_:)):
            guard let event = NSApp.currentEvent else {
                return false
            }
            if event.key == .enter, event.modifierFlags.contains(.option), let result = optionEnterHandler?(), result {
                return true
            }
            return false
        case #selector(NSResponder.insertNewline(_:)):
            // Do something against ENTER key
            guard let event = NSApp.currentEvent else {
                return newLineHandler?() ?? false
            }
            if event.modifierFlags.contains(.shift), let result = shiftEnterHandler?(), result {
                return true
            }
            return newLineHandler?() ?? false
        case #selector(NSResponder.deleteForward(_:)):
            // Do something against DELETE key
            return deleteForwardHandler?() ?? false
        case #selector(NSResponder.deleteBackward(_:)):
            // Do something against BACKSPACE key
            return deleteBackwardHandler?() ?? false
        case #selector(NSResponder.insertTab(_:)):
            // Do something against TAB key
            return insertTabHandler?() ?? false
        case #selector(NSResponder.cancelOperation(_:)):
            // Do something against ESCAPE key
            return cancelOperationHandler?() ?? false
        default: // TODO: add more cases
            // return true if the action was handled; otherwise false
            return false
        }
    }
    
    // MARK: NSTextFieldDelegate
    
//    public func textField(_ textField: NSTextField, textView: NSTextView, candidatesForSelectedRange selectedRange: NSRange) -> [Any]? {
//
//    }
//
//    public func textField(_ textField: NSTextField, textView: NSTextView, candidates: [NSTextCheckingResult], forSelectedRange selectedRange: NSRange) -> [NSTextCheckingResult] {
//
//    }
//
//    public func textField(_ textField: NSTextField, textView: NSTextView, shouldSelectCandidateAt index: Int) -> Bool {
//
//    }
    
    // MARK: NSControlTextEditingDelegate
    
    @MainActor
    public func controlTextDidBeginEditing(_ obj: Notification) {
        editingDidBegin()
        parent.outsideDelegate?.textFieldDidBeginEditing?(parent)
        parent.properties._didBeginEditing.forEach { $0(self.parent) }
    }

    @MainActor
    public func controlTextDidEndEditing(_ obj: Notification) {
        if parent.currentEditor() == nil {
            print("YAAAAY3")
        }
        editingDidEnd()
        parent.outsideDelegate?.textFieldDidEndEditing?(parent)
        parent.properties._didEndEditing.forEach { $0(self.parent) }
    }

    @MainActor
    public func controlTextDidChange(_ obj: Notification) {
        editingChanged()
    }
    
    @MainActor
    public func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        parent.outsideDelegate?.textFieldShouldBeginEditing?(parent) ?? parent.properties._shouldBeginEditing(parent)
    }

    @MainActor
    public func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        parent.outsideDelegate?.textFieldShouldEndEditing?(parent) ?? parent.properties._shouldEndEditing(parent)
    }
}

extension UTextField: _Editableable {
    func _setEditable(_ v: Bool) {
        isEditable = v
    }
}

extension UTextField: _TextAttributesEditingAllowable {
    func _setAllowEditingTextAttributes(_ v: Bool) {
        allowsEditingTextAttributes = v
    }
}

extension UTextField: _Bezeledable {
    func _setBezeled(_ v: Bool) {
        isBezeled = v
    }
}

extension UTextField: _FocusRingTypeable {
    func _setFocusRingType(_ v: NSFocusRingType) {
        focusRingType = v
    }
}

extension UTextField: Refreshable {
    /// Refreshes using `RefreshHandler`
    public func refresh() {
        if let statedText = _properties.statedText {
            text(statedText())
        }
    }
}

extension UTextField: _Enableable {
    func _setEnabled(_ v: Bool) {
        isEnabled = v
    }
}

extension UTextField: _Fontable {
    func _setFont(_ v: UFont?) {
        font = v
    }
}

extension UTextField: _Cleanupable {
    func _cleanup() {
        attributedStringValue = .init()
        _innerDelegate.controlTextDidChange(.init(name: Notification.Name.init("")))
    }
}

extension UTextField: _Colorable {
    var _colorState: UState<UColor> { properties.textColorState }

    func _setColor(_ v: NSColor?) {
        let str = NSMutableAttributedString(attributedString: attributedStringValue)
        if let v = v {
            str.addAttribute(.foregroundColor, value: v, range: NSRange(location: 0, length: str.length))
        } else {
            str.removeAttribute(.foregroundColor, range: NSRange(location: 0, length: str.length))
        }
        attributedStringValue = str
    }
}

extension UTextField: _TextAligmentable {
    func _setTextAlignment(v: NSTextAlignment) {
        let p = NSMutableParagraphStyle()
        p.alignment = v
        let str = NSMutableAttributedString(attributedString: attributedStringValue)
        str.addAttribute(.paragraphStyle, value: p, range: NSRange(location: 0, length: str.length))
        attributedStringValue = str
        alignment = v
    }
}

extension UTextField: _TextBindable {
    func _setTextBind<A: AnyString>(_ binding: UIKitPlus.State<A>?) {
        _properties.textChangeListeners.append({ new in
            binding?.wrappedValue = A.make(new)
        })
    }
}

extension UTextField: _Textable {
    var _currentText: String { self.stringValue }

    var _statedText: AnyStringBuilder.Handler? {
        get { _properties.statedText }
        set { _properties.statedText = newValue }
    }
    
    func _setText(_ v: NSAttributedString?) {
        let selection = currentEditor()?.selectedRange
        let wasEmpty = attributedStringValue.string.count == 0
        attributedStringValue = .init() // hack to update attributed string with changed paragraph style
        attributedStringValue = v ?? .init()
        if wasEmpty {
            currentEditor()?.selectedRange = .init(location: attributedStringValue.string.count, length: attributedStringValue.string.count)
        } else if let selection = selection {
            currentEditor()?.selectedRange = selection
        }
    }
}

extension UTextField: _Typeable {
    func _setTypingInterval(_ v: TimeInterval) {
        _properties.typingInterval = v
    }
    
    func _observeTypingState(_ v: UIKitPlus.State<Bool>) {
        _properties.isTypingState.listen { [weak v] in
            guard let v = v else { return }
            guard v.wrappedValue != $0 else { return }
            v.wrappedValue = $0
        }
        .holdIfOwned(by: self)
        if v.wrappedValue != _properties.isTyping {
            v.wrappedValue = _properties.isTyping
        }
    }
}

extension UTextField: _Placeholderable {
    var _statedPlaceholder: AnyStringBuilder.Handler? {
        get { _properties.statedPlaceholder }
        set { _properties.statedPlaceholder = newValue }
    }

    func _setPlaceholder(_ v: NSAttributedString?) {
        (cell as? NSTextFieldCell)?.placeholderAttributedString = nil // hack to update attributed string with changed paragraph style
        (cell as? NSTextFieldCell)?.placeholderAttributedString = v
        _properties.placeholderAttrText = v
    }
    
    public var placeholder: AttrStr {
        get {
            guard let str = (cell as? NSTextFieldCell)?.placeholderAttributedString else {
                return .init("")
            }
            let attrStr = AttrStr(str)
            attrStr.onUpdate { [weak self] newValue in
                (self?.cell as? NSTextFieldCell)?.placeholderAttributedString = newValue
                self?._properties.placeholderAttrText = newValue
            }
            return attrStr
        }
        set {
            (cell as? NSTextFieldCell)?.placeholderAttributedString = newValue.attributedString
            _properties.placeholderAttrText = newValue.attributedString
        }
    }
}

extension UTextField: _Tintable {
    var _tintState: State<UColor> { properties.tintState }
    
    func _setTint(_ v: NSColor?) {
        _tintColor = v
        _updateCursorColor()
    }
}

//extension TextField: _TextAutocapitalizationable {
//    func _setTextAutocapitalizationType(_ v: UITextAutocapitalizationType) {
//        autocapitalizationType = v
//    }
//}
//
//extension TextField: _TextAutocorrectionable {
//    func _setTextAutocorrectionType(_ v: UITextAutocorrectionType) {
//        autocorrectionType = v
//    }
//}

extension UTextField: _TextFieldContentTypeable {
    /// Works only since macOS 10.16 or 11 (Big Sur and higher)
    func _setTextFieldContentType(v: TextFieldContentType) {
        #if swift(>=5.3)
        if #available(macOS 10.16, *) {
            contentType = v.nsType
        }
        #endif
    }
}

fileprivate class _Formatter<TF>: NumberFormatter where TF: UTextField {
    let tf: TF
    
    init(_ tf: TF) {
        self.tf = tf
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        obj?.pointee = string as NSString
        return true
    }
    
    override func string(for obj: Any?) -> String? {
        obj as? String
    }
    
    override func attributedString(for obj: Any, withDefaultAttributes attrs: [NSAttributedString.Key : Any]? = nil) -> NSAttributedString? {
        obj as? NSAttributedString
    }
    
    @MainActor
    override func isPartialStringValid(_ partialStringPtr: AutoreleasingUnsafeMutablePointer<NSString>, proposedSelectedRange proposedSelRangePtr: NSRangePointer?, originalString origString: String, originalSelectedRange origSelRange: NSRange, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        var origString = origString
        guard let origReplaceRange = Range<String.Index>.init(NSRange(location: 0, length: origSelRange.location + origSelRange.length), in: origString) else {
            tf._innerDelegate.editingChanged()
            return true
        }
        origString.replaceSubrange(origReplaceRange, with: "")
        
        var replacementString = String(partialStringPtr.pointee)
        guard let range = Range<String.Index>.init(NSRange(location: 0, length: origSelRange.location), in: replacementString) else {
            tf._innerDelegate.editingChanged()
            return true
        }
        replacementString.replaceSubrange(range, with: "")
        if let replacementRange = replacementString.range(of: origString) {
            replacementString.replaceSubrange(replacementRange, with: "")
        }
        
        if let result = tf.outsideDelegate?.textField?(self.tf, shouldChangeCharactersIn: origSelRange, replacementString: replacementString) {
            return result
        }
        if let handler = tf.properties._shouldFormatCharacters {
            let origStr = self.tf.stringValue
            handler(self.tf, origSelRange, replacementString)
            if origStr != self.tf.stringValue {
                tf._innerDelegate.editingChanged()
            }
            return false
        }
        if let handler = tf.properties._shouldChangeCharacters {
            return handler(tf, origSelRange, replacementString)
        }
        return true
    }
}
#endif
