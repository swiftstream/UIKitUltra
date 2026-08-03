#if os(macOS)
import AppKit

/// aka `NSLabel`
open class UText: NSTextField, AnyDeclarativeProtocol, DeclarativeProtocolInternal {
    public var declarativeView: UText { self }
    public lazy var properties = Properties<UText>()
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
    
    public init<A: AnyString>(_ state: State<A>) {
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
    
    func _setup() {
        translatesAutoresizingMaskIntoConstraints = false
//        clipsToBounds = true
        isBezeled = false
        isEditable = false
        backgroundColor = .clear
    }
    
    open override func layout() {
        super.layout()
        onLayoutSubviews()
    }

    private func invalidateTextLayout() {
        invalidateIntrinsicContentSize()
        needsLayout = true
    }
    
    open override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        movedToSuperview()
    }
}

extension UText: Refreshable {
    /// Refreshes using `RefreshHandler`
    public func refresh() {
        if let statedText = _properties.statedText {
            text(statedText())
        }
    }
}

extension UText: _Fontable {
    func _setFont(_ v: UFont?) {
        font = v
        invalidateTextLayout()
    }
}

extension UText: _Textable {
    var _currentText: String { self.stringValue }

    var _statedText: AnyStringBuilder.Handler? {
        get { _properties.statedText }
        set { _properties.statedText = newValue }
    }
    
    func _setText(_ v: NSAttributedString?) {
        attributedStringValue = .init() // hack to update attributed string with changed paragraph style
        attributedStringValue = v ?? .init()
        invalidateTextLayout()
    }
}

extension UText: _Colorable {
    var _colorState: State<UColor> { properties.textColorState }

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

extension UText: _TextAligmentable {
    func _setTextAlignment(v: NSTextAlignment) {
        let p = NSMutableParagraphStyle()
        p.alignment = v
        let str = NSMutableAttributedString(attributedString: attributedStringValue)
        str.addAttribute(.paragraphStyle, value: p, range: NSRange(location: 0, length: str.length))
        attributedStringValue = str
        alignment = v
        invalidateTextLayout()
    }
}

extension UText: _TextLineable {
    func _setNumbelOfLines(_ v: Int) {
        maximumNumberOfLines = v

        let isMultiline = v != 1
        usesSingleLineMode = !isMultiline

        if let textFieldCell = cell as? NSTextFieldCell {
            textFieldCell.wraps = isMultiline
            textFieldCell.isScrollable = !isMultiline
        }

        invalidateTextLayout()
    }
}

extension UText: _TextLineBreakModeable {
    func _setLineBreakMode(_ v: NSLineBreakMode) {
        lineBreakMode = v
        invalidateTextLayout()
    }
}

//extension Text: _TextAdjustsFontSizeable {
//    func _setAdjustsFontSizeToFitWidth(_ v: Bool) {
//        adjustsFontSizeToFitWidth = v
//    }
//}
//
//extension Text: _TextScaleable {
//    func _setMinimumScaleFactor(_ v: CGFloat) {
//        minimumScaleFactor = v
//    }
//}
#endif
