#if !os(macOS)
import UIKit
#if !os(tvOS)

@available(*, deprecated, renamed: "USlider")
public typealias USliderView = USlider
@available(*, deprecated, renamed: "USlider")
public typealias SliderView = USlider

open class USlider: UISlider, AnyDeclarativeProtocol, DeclarativeProtocolInternal {
    public var declarativeView: USlider { self }
    public lazy var properties = Properties<USlider>()
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
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
        buildView()
        addTarget(self, action: #selector(_valueChanged), for: .valueChanged)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func _setup() {
        translatesAutoresizingMaskIntoConstraints = false
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
    
    open func buildView() {}
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        onLayoutSubviews()
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        movedToSuperview()
    }
    
    @discardableResult
    public func value(_ value: Float) -> Self {
        self.value = value
        return self
    }
    
    var bindValue: UIKitPlus.State<Float>?
    
    @discardableResult
    public func value(_ binding: UIKitPlus.State<Float>) -> Self {
        bindValue = binding
        binding.listen { [weak self] in self?.value($0) }
            .hold(in: stateBindingHolder)

        return value(binding.wrappedValue)
    }
    
    @discardableResult
    public func minimumValue(_ value: Float) -> Self {
        minimumValue = value
        return self
    }
    
    @discardableResult
    public func minimumValue(_ binding: UIKitPlus.State<Float>) -> Self {
        binding.listen { [weak self] in self?.minimumValue($0) }
            .hold(in: stateBindingHolder)

        return minimumValue(binding.wrappedValue)
    }
    
    @discardableResult
    public func maximumValue(_ value: Float) -> Self {
        maximumValue = value
        return self
    }
    
    @discardableResult
    public func maximumValue(_ binding: UIKitPlus.State<Float>) -> Self {
        binding.listen { [weak self] in self?.maximumValue($0) }
            .hold(in: stateBindingHolder)

        return maximumValue(binding.wrappedValue)
    }
    
    @discardableResult
    public func minimumValueImage(_ value: UIImage?) -> Self {
        minimumValueImage = value
        return self
    }
    
    @discardableResult
    public func minimumValueImage(_ binding: UIKitPlus.State<UIImage?>) -> Self {
        binding.listen { [weak self] in self?.minimumValueImage($0) }
            .hold(in: stateBindingHolder)

        return minimumValueImage(binding.wrappedValue)
    }
    
    @discardableResult
    public func maximumValueImage(_ value: UIImage?) -> Self {
        maximumValueImage = value
        return self
    }
    
    @discardableResult
    public func maximumValueImage(_ binding: UIKitPlus.State<UIImage?>) -> Self {
        binding.listen { [weak self] in self?.maximumValueImage($0) }
            .hold(in: stateBindingHolder)

        return maximumValueImage(binding.wrappedValue)
    }
    
    @discardableResult
    public func isContinuous(_ value: Bool = true) -> Self {
        isContinuous = value
        return self
    }
    
    @discardableResult
    public func isContinuous(_ binding: UIKitPlus.State<Bool>) -> Self {
        binding.listen { [weak self] in self?.isContinuous($0) }
            .hold(in: stateBindingHolder)

        return isContinuous(binding.wrappedValue)
    }
    
    @discardableResult
    public func minimumTrackTintColor(_ value: UIColor?) -> Self {
        minimumTrackTintColor = value
        return self
    }
    
    @discardableResult
    public func minimumTrackTintColor(_ value: Int?) -> Self {
        minimumTrackTintColor = value?.color
        return self
    }
    
    @discardableResult
    public func minimumTrackTintColor(_ binding: UIKitPlus.State<UIColor>) -> Self {
        binding.listen { [weak self] in self?.minimumTrackTintColor($0) }
            .hold(in: stateBindingHolder)

        return minimumTrackTintColor(binding.wrappedValue)
    }
    
    @discardableResult
    public func minimumTrackTintColor(_ binding: UIKitPlus.State<Int>) -> Self {
        binding.listen { [weak self] in self?.minimumTrackTintColor($0) }
            .hold(in: stateBindingHolder)

        return minimumTrackTintColor(binding.wrappedValue)
    }
    
    @discardableResult
    public func maximumTrackTintColor(_ value: UIColor?) -> Self {
        maximumTrackTintColor = value
        return self
    }
    
    @discardableResult
    public func maximumTrackTintColor(_ value: Int?) -> Self {
        maximumTrackTintColor = value?.color
        return self
    }
    
    @discardableResult
    public func maximumTrackTintColor(_ binding: UIKitPlus.State<UIColor>) -> Self {
        binding.listen { [weak self] in self?.maximumTrackTintColor($0) }
            .hold(in: stateBindingHolder)

        return maximumTrackTintColor(binding.wrappedValue)
    }
    
    @discardableResult
    public func maximumTrackTintColor(_ binding: UIKitPlus.State<Int>) -> Self {
        binding.listen { [weak self] in self?.maximumTrackTintColor($0) }
            .hold(in: stateBindingHolder)

        return maximumTrackTintColor(binding.wrappedValue)
    }
    
    @discardableResult
    public func thumbTintColor(_ value: UIColor?) -> Self {
        thumbTintColor = value
        return self
    }
    
    @discardableResult
    public func thumbTintColor(_ value: Int?) -> Self {
        thumbTintColor = value?.color
        return self
    }
    
    @discardableResult
    public func thumbTintColor(_ binding: UIKitPlus.State<UIColor>) -> Self {
        binding.listen { [weak self] in self?.thumbTintColor($0) }
            .hold(in: stateBindingHolder)

        return thumbTintColor(binding.wrappedValue)
    }
    
    @discardableResult
    public func thumbTintColor(_ binding: UIKitPlus.State<Int>) -> Self {
        binding.listen { [weak self] in self?.thumbTintColor($0) }
            .hold(in: stateBindingHolder)

        return thumbTintColor(binding.wrappedValue)
    }
    
    @discardableResult
    public func tintColor(_ value: UIColor?) -> Self {
        tintColor = value
        return self
    }
    
    @discardableResult
    public func tintColor(_ value: Int?) -> Self {
        tintColor = value?.color
        return self
    }
    
    @discardableResult
    public func tintColor(_ binding: UIKitPlus.State<UIColor>) -> Self {
        binding.listen { [weak self] in self?.tintColor($0) }
            .hold(in: stateBindingHolder)

        return tintColor(binding.wrappedValue)
    }
    
    @discardableResult
    public func tintColor(_ binding: UIKitPlus.State<Int>) -> Self {
        binding.listen { [weak self] in self?.tintColor($0) }
            .hold(in: stateBindingHolder)

        return tintColor(binding.wrappedValue)
    }
    
    @discardableResult
    public func thumbImage(_ value: UIImage?, for state: UIControl.State = .normal) -> Self {
        setThumbImage(value, for: state)
        return self
    }
    
    @discardableResult
    public func thumbImage(_ binding: UIKitPlus.State<UIImage?>) -> Self {
        binding.listen { [weak self] in self?.thumbImage($0) }
            .hold(in: stateBindingHolder)

        return thumbImage(binding.wrappedValue)
    }
    
    var step: Float?
    
    @discardableResult
    public func step(_ value: Float) -> Self {
        step = value
        return self
    }
    
    // MARK: Value changed
    
    var _previousSteppedValue: Float?
    
    @objc
    private func _valueChanged() {
        if let step = step {
            let roundedValue = round(value / step) * step
            value = roundedValue
            if value != _previousSteppedValue {
                _onChange?(value)
                bindValue?.wrappedValue = value
            }
            _previousSteppedValue = value
        } else {
            _onChange?(value)
            bindValue?.wrappedValue = value
        }
    }
    
    public typealias OnChange = (Float) -> Void
    
    private var _onChange: OnChange?
    
    @discardableResult
    public func onChange(_ value: @escaping OnChange) -> Self {
        _onChange = value
        return self
    }
}
#endif
#endif
