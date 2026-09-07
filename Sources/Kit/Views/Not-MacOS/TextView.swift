#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit
import UIKitPlusCore

@available(*, deprecated, renamed: "UTextView")
public typealias TextView = UTextView

/// aka `UITextView`
open class UTextView: UITextView, AnyDeclarativeProtocol, DeclarativeProtocolInternal {
    public var declarativeView: UTextView { self }
    public lazy var properties = Properties<UTextView>()
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
    
    public init (_ string: AnyString..., textContainer: NSTextContainer? = nil) {
        super.init(frame: .zero, textContainer: textContainer)
        _setup()
        text(string)
    }
    
    public init (_ strings: [AnyString], textContainer: NSTextContainer? = nil) {
        super.init(frame: .zero, textContainer: textContainer)
        _setup()
        text(strings)
    }
    
    public init (_ localized: LocalizedString...) {
        super.init(frame: .zero, textContainer: nil)
        _setup()
        text(localized)
    }
    
    public init (_ localized: LocalizedString..., textContainer: NSTextContainer) {
        super.init(frame: .zero, textContainer: textContainer)
        _setup()
        text(localized)
    }
    
    public init (_ localized: [LocalizedString], textContainer: NSTextContainer? = nil) {
        super.init(frame: .zero, textContainer: textContainer)
        _setup()
        text(localized)
    }
    
    public init<A: AnyString>(_ state: State<A>, textContainer: NSTextContainer? = nil) {
        super.init(frame: .zero, textContainer: textContainer)
        _setup()
        text(state)
    }
    
    public init (textContainer: NSTextContainer? = nil, @AnyStringBuilder stateString: @escaping AnyStringBuilder.Handler) {
        super.init(frame: .zero, textContainer: textContainer)
        _setup()
        text(stateString: stateString)
    }
    
    public override init(frame: CGRect, textContainer: NSTextContainer? = nil) {
        super.init(frame: frame, textContainer: textContainer)
        _setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var _delegate = TextViewDelegate(self)
    
    private func _setup() {
        clipsToBounds = true
        textContainer.lineFragmentPadding = 0
        translatesAutoresizingMaskIntoConstraints = false
        delegate = _delegate
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
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        onLayoutSubviews()
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        movedToSuperview()
    }
    
    @discardableResult
    public func delegate(_ delegate: UITextViewDelegate?) -> Self {
        self.delegate = delegate
        return self
    }
    
    @discardableResult
    public func content(_ content: TextFieldContentType) -> Self {
        if #available(iOS 10.0, *) {
            if let type = content.type {
                textContentType = type
            }
        }
        return self
    }
        
    @discardableResult
    public func textInsets(_ insets: UIEdgeInsets) -> Self {
        textContainerInset = insets
        return self
    }
    
    @discardableResult
    public func textInsets(_ all: CGFloat) -> Self {
        textInsets(.init(top: all, left: all, bottom: all, right: all))
    }

    @discardableResult
    public func textInsets(top: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0, bottom: CGFloat = 0) -> Self {
        textInsets(.init(top: top, left: left, bottom: bottom, right: right))
    }
    
    // MARK: - Delegate Replication
    
    public typealias SimpleHandler = () -> Void
    public typealias SimpleHandlerText = (TextView) -> Void
    public typealias BoolHandler = () -> Bool
    public typealias BoolHandlerText = (TextView) -> Bool
    public typealias BoolHandlerTextRangeString = (TextView, NSRange, String) -> Bool
    public typealias BoolHandlerRangeString = (NSRange, String) -> Bool
    public typealias BoolHandlerTextURLRange = (TextView, URL, NSRange) -> Bool
    public typealias BoolHandlerTextURLRangeInteraction = (TextView, URL, NSRange, TextItemInteraction) -> Bool
    public typealias BoolHandlerTextTextAttachmentRange = (TextView, NSTextAttachment, NSRange) -> Bool
    public typealias BoolHandlerTextTextAttachmentRangeInteraction = (TextView, NSTextAttachment, NSRange, TextItemInteraction) -> Bool
    
    // MARK: textViewShouldBeginEditing
    
    var shouldBeginEditingHandler: BoolHandler?
    var shouldBeginEditingHandlerText: BoolHandlerText?
    
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
    
    // MARK: textViewShouldEndEditing
    
    var shouldEndEditingHandler: BoolHandler?
    var shouldEndEditingHandlerText: BoolHandlerText?
    
    @discardableResult
    public func onShouldEndEditing(_ handler: @escaping BoolHandler) -> Self {
        shouldEndEditingHandler = handler
        shouldEndEditingHandlerText = nil
        return self
    }
    
    @discardableResult
    public func onShouldEndEditing(_ handler: @escaping BoolHandlerText) -> Self {
        shouldEndEditingHandler = nil
        shouldEndEditingHandlerText = handler
        return self
    }
    
    // MARK: textViewDidBeginEditing
    
    var didBeginEditingHandler: SimpleHandler?
    var didBeginEditingHandlerText: SimpleHandlerText?
    
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
    
    // MARK: textViewDidEndEditing
    
    var didEndEditingHandler: SimpleHandler?
    var didEndEditingHandlerText: SimpleHandlerText?
    
    @discardableResult
    public func onDidEndEditing(_ handler: @escaping SimpleHandler) -> Self {
        didBeginEditingHandler = handler
        return self
    }
    
    @discardableResult
    public func onDidEndEditing(_ handler: @escaping SimpleHandlerText) -> Self {
        didBeginEditingHandlerText = handler
        return self
    }
    
    // MARK: shouldChangeTextInRange
    
    var shouldChangeTextHandler: BoolHandler?
    var shouldChangeTextHandlerText: BoolHandlerText?
    var shouldChangeTextHandlerTextRangeString: BoolHandlerTextRangeString?
    var shouldChangeTextHandlerRangeString: BoolHandlerRangeString?
    
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
    public func onShouldChangeText(_ handler: @escaping BoolHandlerTextRangeString) -> Self {
        shouldChangeTextHandler = nil
        shouldChangeTextHandlerText = nil
        shouldChangeTextHandlerTextRangeString = handler
        shouldChangeTextHandlerRangeString = nil
        return self
    }
    
    @discardableResult
    public func onShouldChangeText(_ handler: @escaping BoolHandlerRangeString) -> Self {
        shouldChangeTextHandler = nil
        shouldChangeTextHandlerText = nil
        shouldChangeTextHandlerTextRangeString = nil
        shouldChangeTextHandlerRangeString = handler
        return self
    }
    
    // MARK: textViewDidChange
    
    var didChangeTextHandler: SimpleHandler?
    var didChangeTextHandlerText: SimpleHandlerText?
    
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
    
    // MARK: textViewDidChangeSelection
    
    var didChangeSelectionHandler: SimpleHandler?
    var didChangeSelectionHandlerText: SimpleHandlerText?
    
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
    
    // MARK: shouldInteractWithURLInteraction
    
    var shouldInteractWithURLHandler: BoolHandler?
    var shouldInteractWithURLHandlerText: BoolHandlerText?
    var shouldInteractWithURLHandlerURLRange: BoolHandlerTextURLRange?
    var shouldInteractWithURLHandlerURLRangeInteraction: BoolHandlerTextURLRangeInteraction?
    
    @discardableResult
    public func shouldInteractWithURL(_ handler: @escaping BoolHandler) -> Self {
        shouldInteractWithURLHandler = handler
        shouldInteractWithURLHandlerText = nil
        shouldInteractWithURLHandlerURLRange = nil
        shouldInteractWithURLHandlerURLRangeInteraction = nil
        return self
    }
    
    @discardableResult
    public func shouldInteractWithURL(_ handler: @escaping BoolHandlerText) -> Self {
        shouldInteractWithURLHandler = nil
        shouldInteractWithURLHandlerText = handler
        shouldInteractWithURLHandlerURLRange = nil
        shouldInteractWithURLHandlerURLRangeInteraction = nil
        return self
    }
    
    @discardableResult
    public func shouldInteractWithURL(_ handler: @escaping BoolHandlerTextURLRange) -> Self {
        shouldInteractWithURLHandler = nil
        shouldInteractWithURLHandlerText = nil
        shouldInteractWithURLHandlerURLRange = handler
        shouldInteractWithURLHandlerURLRangeInteraction = nil
        return self
    }
    
    @discardableResult
    public func shouldInteractWithURL(_ handler: @escaping BoolHandlerTextURLRangeInteraction) -> Self {
        shouldInteractWithURLHandler = nil
        shouldInteractWithURLHandlerText = nil
        shouldInteractWithURLHandlerURLRange = nil
        shouldInteractWithURLHandlerURLRangeInteraction = handler
        return self
    }
    
    // MARK: shouldInteractWithTextAttachmentInteraction
    
    var shouldInteractWithTextAttachmentHandler: BoolHandler?
    var shouldInteractWithTextAttachmentHandlerText: BoolHandlerText?
    var shouldInteractWithTextAttachmentHandlerRange: BoolHandlerTextTextAttachmentRange?
    var shouldInteractWithTextAttachmentHandlerRangeInteraction: BoolHandlerTextTextAttachmentRangeInteraction?
    
    @discardableResult
    public func shouldInteractWithTextAttachment(_ handler: @escaping BoolHandler) -> Self {
        shouldInteractWithTextAttachmentHandler = handler
        shouldInteractWithTextAttachmentHandlerText = nil
        shouldInteractWithTextAttachmentHandlerRange = nil
        shouldInteractWithTextAttachmentHandlerRangeInteraction = nil
        return self
    }
    
    @discardableResult
    public func shouldInteractWithTextAttachment(_ handler: @escaping BoolHandlerText) -> Self {
        shouldInteractWithTextAttachmentHandler = nil
        shouldInteractWithTextAttachmentHandlerText = handler
        shouldInteractWithTextAttachmentHandlerRange = nil
        shouldInteractWithTextAttachmentHandlerRangeInteraction = nil
        return self
    }
    
    @discardableResult
    public func shouldInteractWithTextAttachment(_ handler: @escaping BoolHandlerTextTextAttachmentRange) -> Self {
        shouldInteractWithTextAttachmentHandler = nil
        shouldInteractWithTextAttachmentHandlerText = nil
        shouldInteractWithTextAttachmentHandlerRange = handler
        shouldInteractWithTextAttachmentHandlerRangeInteraction = nil
        return self
    }
    
    @discardableResult
    public func shouldInteractWithTextAttachment(_ handler: @escaping BoolHandlerTextTextAttachmentRangeInteraction) -> Self {
        shouldInteractWithTextAttachmentHandler = nil
        shouldInteractWithTextAttachmentHandlerText = nil
        shouldInteractWithTextAttachmentHandlerRange = nil
        shouldInteractWithTextAttachmentHandlerRangeInteraction = handler
        return self
    }
}

extension UTextView: Refreshable {
    /// Refreshes using `RefreshHandler`
    public func refresh() {
        if let statedText = _properties.statedText {
            text(statedText())
        }
    }
}

extension UTextView: _Fontable {
    func _setFont(_ v: UIFont?) {
        font = v
    }
}

extension UTextView: _TextBindable {
    func _setTextBind<A: AnyString>(_ binding: State<A>?) {
        _properties.textChangeListeners.append({ new in
            binding?.wrappedValue = A.make(new)
        })
    }
}

extension UTextView: _Textable {
    var _currentText: String { self.text ?? "" }

    var _statedText: AnyStringBuilder.Handler? {
        get { _properties.statedText }
        set { _properties.statedText = newValue }
    }
    
    var _textChangeTransition: UIView.AnimationOptions? {
        get { _properties.textChangeTransition }
        set { _properties.textChangeTransition = newValue }
    }
    
    func _setText(_ v: NSAttributedString?) {
        attributedText = nil // hack to update attributed string with changed paragraph style
        attributedText = v
    }
}

extension UTextView: _Typeable {
    func _setTypingInterval(_ v: TimeInterval) {
        _properties.typingInterval = v
    }
    
    func _observeTypingState(_ v: UIKitPlus.State<Bool>) {
        _properties.isTypingState.listen { [weak v] in
            guard let v = v else { return }
            guard v.wrappedValue != $0 else { return }
            v.wrappedValue = $0
        }
        .hold(in: stateBindingHolder)
        if v.wrappedValue != _properties.isTyping {
            v.wrappedValue = _properties.isTyping
        }
    }
}

extension UTextView: _Colorable {
    var _colorState: UIKitPlus.State<UIColor> { properties.textColorState }
    
    func _setColor(_ v: UIColor?) {
        textColor = v
        properties.textColor = v ?? .clear
    }
}

extension UTextView: _TextAligmentable {
    func _setTextAlignment(v: NSTextAlignment) {
        textAlignment = v
    }
}

extension UTextView: _Placeholderable {
    var _statedPlaceholder: AnyStringBuilder.Handler? {
        get { _properties.statedPlaceholder }
        set { _properties.statedPlaceholder = newValue }
    }
    
    var _placeholderChangeTransition: UIView.AnimationOptions? {
        get { _properties.placeholderChangeTransition }
        set { _properties.placeholderChangeTransition = newValue }
    }
    
    func _setPlaceholder(_ v: NSAttributedString?) {
        attributedText = nil // hack to update attributed string with changed paragraph style
        attributedText = v
        _properties.placeholderAttrText = v
    }
}


extension UTextView: _Keyboardable {
    func _setKeyboardType(_ v: UIKeyboardType) {
        keyboardType = v
    }
    
    func _setReturnKeyType(_ v: UIReturnKeyType) {
        returnKeyType = v
    }
    
    func _setKeyboardAppearance(_ v: UIKeyboardAppearance) {
        keyboardAppearance = v
    }
    
    func _setInputView(_ v: UIView?) {
        inputView = v
    }
    
    func _setInputAccessoryView(_ v: UIView?) {
        inputAccessoryView = v
    }
    
    @discardableResult
    public func inputView(_ view: (TextView) -> UIView) -> Self {
        inputView(view(self))
    }
    
    @discardableResult
    public func inputAccessoryView(_ view: (TextView) -> UIView) -> Self {
        inputAccessoryView(view(self))
    }
}

extension UTextView: _TextAutocapitalizationable {
    func _setTextAutocapitalizationType(_ v: UITextAutocapitalizationType) {
        autocapitalizationType = v
    }
}

extension UTextView: _TextAutocorrectionable {
    func _setTextAutocorrectionType(_ v: UITextAutocorrectionType) {
        autocorrectionType = v
    }
}

extension UTextView: _Cleanupable {
    func _cleanup() {
        text = ""
        didChangeTextHandler?()
        didChangeTextHandlerText?(self)
    }
}

extension UTextView: _Scrollable {
    func _setScrollingEnabled(_ v: Bool) {
        isScrollEnabled = v
    }
    
    func _setVisibleHScrollIndicator(_ v: Bool) {
        showsHorizontalScrollIndicator = v
    }
    
    func _setVisibleVScrollIndicator(_ v: Bool) {
        showsVerticalScrollIndicator = v
    }
}

extension UTextView: _Enableable {
    func _setEnabled(_ v: Bool) {
        self.isEditable = v
    }
}
#endif
#endif
