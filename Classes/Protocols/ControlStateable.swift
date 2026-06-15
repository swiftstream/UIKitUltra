#if os(macOS)
import Cocoa

public protocol ControlStateable: AnyObject {
    @discardableResult
    func state(_ value: NSControl.StateValue) -> Self
    
    @discardableResult
    func state(_ binding: UIKitPlus.State<NSControl.StateValue>) -> Self
}

@MainActor
protocol _ControlStateable: ControlStateable {
    var _stateState: State<NSControl.StateValue> { get set }
    
    func _setState(_ v: NSControl.StateValue)
}

@available(iOS 13.0, *)
@MainActor
extension ControlStateable {
    @discardableResult
    public func state(_ binding: UIKitPlus.State<NSControl.StateValue>) -> Self {
        guard let s = self as? _ControlStateable else { return self }
        s._stateState = binding
        s._setState(binding.wrappedValue)
        binding.listen { [weak s] in
            s?._setState($0)
        }
        .holdIfOwned(by: self)
        return self
    }
    
    @discardableResult
    public func state(_ value: NSControl.StateValue) -> Self {
        guard let s = self as? _ControlStateable else { return self }
        s._stateState.wrappedValue = value
        s._setState(value)
        return self
    }
}

// for iOS lower than 13
@MainActor
extension _ControlStateable {
    @discardableResult
    public func state(_ binding: UIKitPlus.State<NSControl.StateValue>) -> Self {
        _stateState = binding
        _setState(binding.wrappedValue)
        binding.listen { [weak self] in
            self?._setState($0)
        }
        .holdIfOwned(by: self)
        return self
    }
    
    @discardableResult
    public func state(_ value: NSControl.StateValue) -> Self {
        _stateState.wrappedValue = value
        _setState(value)
        return self
    }
}
#endif
