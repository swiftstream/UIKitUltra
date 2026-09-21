#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit
import UltraCore
#if !os(tvOS)

open class UStepper: UIStepper, AnyDeclarativeProtocol, DeclarativeProtocolInternal {
    public var declarativeView: UStepper { self }
    public lazy var properties = Properties<UStepper>()
    lazy var _properties = PropertiesInternal()
    
    @Ultra.State public var height: CGFloat = 0
    @Ultra.State public var width: CGFloat = 0
    @Ultra.State public var top: CGFloat = 0
    @Ultra.State public var leading: CGFloat = 0
    @Ultra.State public var left: CGFloat = 0
    @Ultra.State public var trailing: CGFloat = 0
    @Ultra.State public var right: CGFloat = 0
    @Ultra.State public var bottom: CGFloat = 0
    @Ultra.State public var centerX: CGFloat = 0
    @Ultra.State public var centerY: CGFloat = 0
    
    var __height: Ultra.State<CGFloat> { $height }
    var __width: Ultra.State<CGFloat> { $width }
    var __top: Ultra.State<CGFloat> { $top }
    var __leading: Ultra.State<CGFloat> { $leading }
    var __left: Ultra.State<CGFloat> { $left }
    var __trailing: Ultra.State<CGFloat> { $trailing }
    var __right: Ultra.State<CGFloat> { $right }
    var __bottom: Ultra.State<CGFloat> { $bottom }
    var __centerX: Ultra.State<CGFloat> { $centerX }
    var __centerY: Ultra.State<CGFloat> { $centerY }
    
    public init(_ value: Double) {
        super.init(frame: .zero)
        self.value = value
        setup()
    }
    
    public init(_ state: Ultra.State<Double>) {
        super.init(frame: .zero)
        valueBinding = state
        self.value = state.wrappedValue
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        addTarget(self, action: #selector(valueChanged), for: .valueChanged)
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
    
    private var isContinuousBinding: Ultra.State<Bool>?
    private var autorepeatBinding: Ultra.State<Bool>?
    private var wrapsBinding: Ultra.State<Bool>?
    private var valueBinding: Ultra.State<Double>?
    private var minValueBinding: Ultra.State<Double>?
    private var maxValueBinding: Ultra.State<Double>?
    private var stepValueBinding: Ultra.State<Double>?
    
    public typealias ChangedClosure = (Double) -> Void
    private var _valueChanged: ChangedClosure?
    
    @objc
    private func valueChanged() {
        _valueChanged?(value)
        valueBinding?.wrappedValue = value
    }
    
    @discardableResult
    public func changed(_ callback: @escaping ChangedClosure) -> Self {
        _valueChanged = callback
        return self
    }
    
    // if YES, value change events are sent any time the value changes during interaction. default = YES
    @discardableResult
    public func isContinuous(_ value: Bool = true) -> Self {
        isContinuousBinding?.wrappedValue = value
        isContinuous = value
        return self
    }
    
    @discardableResult
    public func isContinuous(_ state: Ultra.State<Bool>) -> Self {
        isContinuousBinding = state
        isContinuous = state.wrappedValue
        return self
    }
    
    // if YES, press & hold repeatedly alters value. default = YES
    @discardableResult
    public func autorepeat(_ value: Bool = true) -> Self {
        autorepeatBinding?.wrappedValue = value
        autorepeat = value
        return self
    }
    
    @discardableResult
    public func autorepeat(_ state: Ultra.State<Bool>) -> Self {
        autorepeatBinding = state
        autorepeat = state.wrappedValue
        return self
    }
    
    // if YES, value wraps from min <-> max. default = NO
    @discardableResult
    public func wraps(_ value: Bool = true) -> Self {
        wrapsBinding?.wrappedValue = value
        wraps = value
        return self
    }
    
    @discardableResult
    public func wraps(_ state: Ultra.State<Bool>) -> Self {
        wrapsBinding = state
        wraps = state.wrappedValue
        return self
    }
    
    // default is 0. sends UIControlEventValueChanged. clamped to min/max
    @discardableResult
    public func value(_ value: Double) -> Self {
        valueBinding?.wrappedValue = value
        self.value = value
        return self
    }
    
    @discardableResult
    public func value(_ state: Ultra.State<Double>) -> Self {
        valueBinding = state
        value = state.wrappedValue
        return self
    }
    
    // default 0. must be less than maximumValue
    @discardableResult
    public func minimumValue(_ value: Double) -> Self {
        minValueBinding?.wrappedValue = value
        minimumValue = value
        return self
    }
    
    @discardableResult
    public func minimumValue(_ state: Ultra.State<Double>) -> Self {
        minValueBinding = state
        minimumValue = state.wrappedValue
        return self
    }
    
    // default 100. must be greater than minimumValue
    @discardableResult
    public func maximumValue(_ value: Double) -> Self {
        maxValueBinding?.wrappedValue = value
        maximumValue = value
        return self
    }
    
    @discardableResult
    public func maximumValue(_ state: Ultra.State<Double>) -> Self {
        maxValueBinding = state
        maximumValue = state.wrappedValue
        return self
    }
    
    // default 1. must be greater than 0
    @discardableResult
    public func stepValue(_ value: Double) -> Self {
        stepValueBinding?.wrappedValue = value
        stepValue = value
        return self
    }
    
    @discardableResult
    public func stepValue(_ state: Ultra.State<Double>) -> Self {
        stepValueBinding = state
        stepValue = state.wrappedValue
        return self
    }
}
#endif
#endif
#endif
