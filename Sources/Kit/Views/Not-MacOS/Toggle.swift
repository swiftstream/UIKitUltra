#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit
import UIKitPlusCore
#if !os(tvOS)

open class UToggle: UISwitch, AnyDeclarativeProtocol, DeclarativeProtocolInternal {
    public var declarativeView: UToggle { self }
    public lazy var properties = Properties<UToggle>()
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
    
    var binding: UIKitPlus.State<Bool>?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public init(_ state: UIKitPlus.State<Bool>) {
        binding = state
        super.init(frame: .zero)
        setup()
        isOn = state.wrappedValue
        state.listen { [weak self] new in
            self?.setOn(new, animated: true)
        }
        .hold(in: stateBindingHolder)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        addTarget(self, action: #selector(changed), for: .valueChanged)
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
    
    // MARK: Handler
    
    private var _changed: (Bool) -> Void = { _ in }
    
    @objc
    private func changed() {
        binding?.wrappedValue = isOn
        _changed(isOn)
    }
    
    @discardableResult
    public func onChange(_ closure: @escaping (Bool) -> Void) -> Self {
        _changed = closure
        return self
    }
    
    @discardableResult
    public func onTint(_ color: UIColor) -> Self {
        onTintColor = color
        return self
    }
    
    @discardableResult
    public func onTint(_ color: Int) -> Self {
        onTintColor = color.color
        return self
    }
    
    @discardableResult
    public func onTint(_ binding: UIKitPlus.State<UIColor>) -> Self {
        binding.listen { [weak self] in self?.onTint($0) }
            .hold(in: stateBindingHolder)

        return onTint(binding.wrappedValue)
    }
    
    @discardableResult
    public func onTint(_ binding: UIKitPlus.State<Int>) -> Self {
        binding.listen { [weak self] in self?.onTint($0) }
            .hold(in: stateBindingHolder)

        return onTint(binding.wrappedValue)
    }
    
    @discardableResult
    public func thumbTint(_ color: UIColor) -> Self {
        thumbTintColor = color
        return self
    }
    
    @discardableResult
    public func thumbTint(_ color: Int) -> Self {
        thumbTintColor = color.color
        return self
    }
    
    @discardableResult
    public func thumbTint(_ binding: UIKitPlus.State<UIColor>) -> Self {
        binding.listen { [weak self] in self?.thumbTint($0) }
            .hold(in: stateBindingHolder)

        return thumbTint(binding.wrappedValue)
    }
    
    @discardableResult
    public func thumbTint(_ binding: UIKitPlus.State<Int>) -> Self {
        binding.listen { [weak self] in self?.thumbTint($0) }
            .hold(in: stateBindingHolder)

        return thumbTint(binding.wrappedValue)
    }
    
    @discardableResult
    public func onImage(_ image: UIImage?) -> Self {
        onImage = image
        return self
    }
    
    @discardableResult
    public func onImage(_ binding: UIKitPlus.State<UIImage?>) -> Self {
        binding.listen { [weak self] in self?.onImage($0) }
            .hold(in: stateBindingHolder)

        return onImage(binding.wrappedValue)
    }
    
    @discardableResult
    public func offImage(_ image: UIImage?) -> Self {
        offImage = image
        return self
    }
    
    @discardableResult
    public func offImage(_ binding: UIKitPlus.State<UIImage?>) -> Self {
        binding.listen { [weak self] in self?.offImage($0) }
            .hold(in: stateBindingHolder)

        return offImage(binding.wrappedValue)
    }
}

extension UToggle: _Enableable {
    func _setEnabled(_ v: Bool) {
        isEnabled = v
    }
}
#endif
#endif
#endif
