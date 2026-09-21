#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
import UltraCore

@available(*, deprecated, renamed: "UActivityIndicator")
public typealias ActivityIndicator = UActivityIndicator

open class UActivityIndicator: NSProgressIndicator, AnyDeclarativeProtocol, DeclarativeProtocolInternal {
    public var declarativeView: UActivityIndicator { self }
    public lazy var properties = Properties<UActivityIndicator>()
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
    
    private lazy var  _tag: Int = -1
    public override var tag: Int {
        get { _tag }
        set { _tag = newValue }
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.style = .spinning
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    public init(style: NSProgressIndicator.Style = .spinning) {
        super.init(frame: .zero)
        self.style = style
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layout() {
        super.layout()
        onLayoutSubviews()
    }
    
    open override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        movedToSuperview()
    }
    
//    // MARK: - color
//    
//    @discardableResult
//    public func color(_ color: UColor) -> Self {
////        declarativeView.wantsLayer = true
////        declarativeView.layer?.backgroundColor = color.current.cgColor
//        
////        self.color = color
//        return self
//    }
//
//    @discardableResult
//    public func color(_ number: Int) -> Self {
//        color(number.color)
//    }
//
//    @discardableResult
//    public func color(_ binding: State<UColor>) -> Self {
//        binding.listen { [weak self] in self?.color($0) }
//        return color(binding.wrappedValue)
//    }
//
//    @discardableResult
//    public func color(_ binding: State<Int>) -> Self {
//        binding.listen { [weak self] in self?.color($0) }
//        return color(binding.wrappedValue)
//    }
    
    @discardableResult
    public func started(_ value: Bool) -> Self {
        if value {
            startAnimation(nil)
        } else {
            stopAnimation(nil)
        }
        return self
    }
    
    @discardableResult
    public func started(_ binding: State<Bool>) -> Self {
        binding.listen { [weak self] in self?.started($0) }
            .hold(in: stateBindingHolder)
        return started(binding.wrappedValue)
    }
    
    @discardableResult
    public func hidesWhenStopped(_ value: Bool = true) -> Self {
        self.isDisplayedWhenStopped = !value
        return self
    }
    
    @discardableResult
    public func animate() -> Self {
        startAnimation(nil)
        return self
    }
}
#else
import UIKit
import UltraCore

public typealias UActivityIndicator = ActivityIndicator
open class ActivityIndicator: UIActivityIndicatorView, AnyDeclarativeProtocol, DeclarativeProtocolInternal {
    public var declarativeView: ActivityIndicator { self }
    public lazy var properties = Properties<ActivityIndicator>()
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
    
    public override init(style: UIActivityIndicatorView.Style) {
        super.init(style: style)
        _setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func _setup() {
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
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        onLayoutSubviews()
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        movedToSuperview()
    }
    
    // MARK: - color
    
    @discardableResult
    public func color(_ color: UIColor) -> Self {
        self.color = color
        return self
    }
    
    @discardableResult
    public func color(_ number: Int) -> Self {
        color(number.color)
    }
    
    @discardableResult
    public func color(_ binding: State<UIColor>) -> Self {
        binding.listen { [weak self] in self?.color($0) }
            .hold(in: stateBindingHolder)
        return color(binding.wrappedValue)
    }
    
    @discardableResult
    public func color(_ binding: State<Int>) -> Self {
        binding.listen { [weak self] in self?.color($0) }
            .hold(in: stateBindingHolder)
        return color(binding.wrappedValue)
    }
    
    @discardableResult
    public func started(_ value: Bool) -> Self {
        if value {
            startAnimating()
        } else {
            stopAnimating()
        }
        return self
    }
    
    @discardableResult
    public func started(_ binding: State<Bool>) -> Self {
        binding.listen { [weak self] in self?.started($0) }
            .hold(in: stateBindingHolder)
        return started(binding.wrappedValue)
    }
    
    @discardableResult
    public func hidesWhenStopped(_ value: Bool = true) -> Self {
        self.hidesWhenStopped = value
        return self
    }
    
    @discardableResult
    public func animate() -> Self {
        startAnimating()
        return self
    }
}
#endif
#endif
