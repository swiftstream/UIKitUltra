#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

@available(*, deprecated, renamed: "UBarButtonItem")
public typealias BarButtonItem = UBarButtonItem

open class UBarButtonItem: UIBarButtonItem {
    private let _stateBindingHolder = TempStatesHolder()

    var stateBindingHolder: TempStatesHolder {
        _stateBindingHolder
    }

    public init(_ title: String?) {
        super.init()
        self.title = title
        setup()
    }
    
    public init(_ localized: LocalizedString...) {
        super.init()
        self.title = String(localized)
        setup()
    }
    
    public init(_ localized: [LocalizedString]) {
        super.init()
        self.title = String(localized)
        setup()
    }
    
    // TODO: figure out how to implement `barButtonSystemItem`
//    public init(_ barButtonSystemItem: UIBarButtonItem.SystemItem) {
//        super.init()
//        self.image
//        setup()
//    }
    
    
    public init(image: UIImage?) {
        super.init()
        self.image = image
        setup()
    }
    
    public init(_ image: State<UIImage>) {
        super.init()
        self.image = image.wrappedValue
        setup()
        image.listen { [weak self] in self?.image = $0 }
            .hold(in: stateBindingHolder)
    }
    
    public init(image imageName: String) {
        super.init()
        self.image = UIImage(named: imageName)
        setup()
    }
    
    public init(_ customView: UIView) {
        super.init()
        self.customView = customView
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        target = self
        action = #selector(tapEvenWithbuttont(_:))
    }
    
    // MARK: TouchUpInside
    
    public typealias TapAction = ()->Void
    public typealias TapActionWithButton = (UBarButtonItem)->Void
    
    private var tapCallback: TapAction?
    private var tapWithButtonCallback: TapActionWithButton?
    
    @discardableResult
    public func tapAction(_ callback: @escaping TapAction) -> Self {
        tapCallback = callback
        return self
    }
    
    @discardableResult
    public func tapAction(_ callback: @escaping TapActionWithButton) -> Self {
        tapWithButtonCallback = callback
        return self
    }
    
    @objc private func tapEvenWithbuttont(_ button: UBarButtonItem) {
        tapCallback?()
        tapWithButtonCallback?(button)
    }
    
    @discardableResult
    public func style(_ style: UIBarButtonItem.Style) -> Self {
        self.style = style
        return self
    }
    
    // MARK: tint
    
    @discardableResult
    public func tint(_ color: UIColor) -> Self {
        self.tintColor = color
        return self
    }
    
    @discardableResult
    public func tint(_ color: Int) -> Self {
        tint(color.color)
    }
    
    @discardableResult
    public func tint(_ binding: State<UIColor>) -> Self {
        binding.listen { [weak self] in self?.tint($0) }
            .hold(in: stateBindingHolder)
        return tint(binding.wrappedValue)
    }
    
    
    @discardableResult
    public func tint(_ binding: State<Int>) -> Self {
        binding.listen { [weak self] in self?.tint($0) }
            .hold(in: stateBindingHolder)
        return tint(binding.wrappedValue)
    }
}

extension UBarButtonItem: _StateBindingOwner {}

#endif
#endif
