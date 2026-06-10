#if os(macOS)
import AppKit
#else
import UIKit
#endif

public protocol MixedStateAllowable: AnyObject {
    @discardableResult
    func allowMixedState() -> Self
    
    @discardableResult
    func allowMixedState(_ value: Bool) -> Self
    
    @discardableResult
    func allowMixedState(_ binding: UIKitPlus.State<Bool>) -> Self
}

protocol _MixedStateAllowable: MixedStateAllowable {
    var _allowMixedStateState: State<Bool> { get }
    
    func _setAllowMixedState(_ v: Bool)
}

extension MixedStateAllowable {
    @discardableResult
    public func allowMixedState() -> Self {
        allowMixedState(true)
    }
    
    @discardableResult
    public func allowMixedState(_ binding: UIKitPlus.State<Bool>) -> Self {
        binding.listen { [weak self] in
            self?.allowMixedState($0)
        }
        .holdIfOwned(by: self)
        return allowMixedState(binding.wrappedValue)
    }
}

@available(iOS 13.0, macOS 10.15, *)
extension MixedStateAllowable {
    @discardableResult
    public func allowMixedState(_ value: Bool) -> Self {
        guard let s = self as? _MixedStateAllowable else { return self }
        s._setAllowMixedState(value)
        return self
    }
}

// for iOS lower than 13
extension _MixedStateAllowable {
    @discardableResult
    public func allowMixedState(_ value: Bool) -> Self {
        _setAllowMixedState(value)
        return self
    }
}
