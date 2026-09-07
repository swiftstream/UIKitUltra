#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit
import UIKitPlusCore

public typealias ULabel = UText

/// aka `UILabel`
open class UText: UILabel, AnyDeclarativeProtocol, DeclarativeProtocolInternal {
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
        clipsToBounds = true
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
    func _setFont(_ v: UIFont?) {
        font = v
    }
}

extension UText: _Textable {
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

extension UText: _ViewTransitionable {
    var _transitionableView: UIView { self }
}

extension UText: _Colorable {
    var _colorState: State<UIColor> { properties.textColorState }
    
    func _setColor(_ v: UIColor?) {
        textColor = v
        properties.textColor = v ?? .clear
    }
}

extension UText: _TextAligmentable {
    func _setTextAlignment(v: NSTextAlignment) {
        let p = NSMutableParagraphStyle()
        p.alignment = v
        let str = NSMutableAttributedString(attributedString: attributedText ?? .init())
        str.addAttribute(.paragraphStyle, value: p, range: NSRange(location: 0, length: str.length))
        attributedText = str
        textAlignment = v
    }
}

extension UText: _TextLineable {
    func _setNumbelOfLines(_ v: Int) {
        numberOfLines = v
    }
}

extension UText: _TextLineBreakModeable {
    func _setLineBreakMode(_ v: NSLineBreakMode) {
        lineBreakMode = v
    }
}

extension UText: _TextAdjustsFontSizeable {
    func _setAdjustsFontSizeToFitWidth(_ v: Bool) {
        adjustsFontSizeToFitWidth = v
    }
}

extension UText: _TextScaleable {
    func _setMinimumScaleFactor(_ v: CGFloat) {
        minimumScaleFactor = v
    }
}
#endif
#endif
