#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

@available(*, deprecated, renamed: "UWrapperView")
public typealias WrapperView = UWrapperView

open class UWrapperView<V>: UView where V: BaseView {
    public override var declarativeView: UWrapperView { return self }
    
    public let innerView: V
    
    var topConstraint, leadingConstraint, trailingConstraint, bottomConstraint: NSLayoutConstraint!
    
    public init (_ innerView: V) {
        self.innerView = innerView
        super.init(frame: .zero)
        innerView.translatesAutoresizingMaskIntoConstraints = false
        body { innerView }
        #if os(macOS)
        wantsLayer = true
        layer?.backgroundColor = .clear
        #else
        backgroundColor = .clear
        #endif
        topConstraint = innerView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        leadingConstraint = innerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        trailingConstraint = innerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        bottomConstraint = innerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([topConstraint, leadingConstraint, trailingConstraint, bottomConstraint])
        _setup()
    }
    
    public convenience init (_ innerView: () -> V) {
        self.init(innerView())
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func _setup() {
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
    
    #if os(macOS)
    open override func layout() {
        super.layout()
        onLayoutSubviews()
    }
    
    open override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        movedToSuperview()
    }
    #else
    open override func layoutSubviews() {
        super.layoutSubviews()
        onLayoutSubviews()
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        movedToSuperview()
    }
    #endif
    
    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return innerView.becomeFirstResponder()
    }
    
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return innerView.resignFirstResponder()
    }
    
    @discardableResult
    public func padding(top: CGFloat? = nil, left: CGFloat? = nil, right: CGFloat? = nil, bottom: CGFloat? = nil) -> Self {
        guard top != nil || left != nil || right != nil || bottom != nil else {
            return padding(10)
        }
        if let top = top {
            topConstraint.constant = top
        }
        if let left = left {
            leadingConstraint.constant = left
        }
        if let right = right {
            trailingConstraint.constant = right * (-1)
        }
        if let bottom = bottom {
            bottomConstraint.constant = bottom * (-1)
        }
        return self
    }
    
    @discardableResult
    public func padding(x: CGFloat, y: CGFloat) -> Self {
        padding(x: x)
        padding(y: y)
        return self
    }
    
    @discardableResult
    public func padding(x: CGFloat) -> Self {
        leadingConstraint.constant = x
        trailingConstraint.constant = x * (-1)
        return self
    }
    
    @discardableResult
    public func padding(y: CGFloat) -> Self {
        topConstraint.constant = y
        bottomConstraint.constant = y * (-1)
        return self
    }
    
    @discardableResult
    public func padding(_ value: CGFloat) -> Self {
        topConstraint.constant = value
        leadingConstraint.constant = value
        trailingConstraint.constant = value * (-1)
        bottomConstraint.constant = value * (-1)
        return self
    }
}
#endif
