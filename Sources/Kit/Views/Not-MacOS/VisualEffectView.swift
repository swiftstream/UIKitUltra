#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit
import UIKitPlusCore

@available(*, deprecated, renamed: "UVisualEffectView")
public typealias VisualEffectView = UVisualEffectView

open class UVisualEffectView: UIVisualEffectView, AnyDeclarativeProtocol, DeclarativeProtocolInternal {
    public var declarativeView: UVisualEffectView { self }
    public lazy var properties = Properties<UVisualEffectView>()
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
    
    var _defaultEffect, _darkEffect: UIVisualEffect?
    
    public override init(effect: UIVisualEffect?) {
        self._defaultEffect = effect
        super.init(effect: effect)
        switchEffect()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    public init(_ effect: UIVisualEffect?, _ darkEffect: UIVisualEffect? = nil) {
        self._defaultEffect = effect
        self._darkEffect = darkEffect
        super.init(effect: effect)
        switchEffect()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    public init () {
        super.init(effect: nil)
        switchEffect()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    public func effect(_ effect: UIVisualEffect?) -> Self {
        self._defaultEffect = effect
        switchEffect()
        return self
    }
    
    @discardableResult
    public func darkEffect(_ effect: UIVisualEffect?) -> Self {
        self._darkEffect = effect
        switchEffect()
        return self
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        switchEffect()
    }
    
    var isDark: Bool {
        if #available(iOS 12.0, *) {
            return traitCollection.userInterfaceStyle == .dark
        }
        return false
    }
    
    private func switchEffect() {
        if isDark, let de = _darkEffect {
            effect = de
            return
        }
        effect = _defaultEffect
    }
}

// MARK: Convenience Initializers

extension UIVisualEffect {
    static func effect(_ effect: UIVisualEffect?) -> UVisualEffectView {
        UVisualEffectView(effect)
    }
}
#endif
#endif
