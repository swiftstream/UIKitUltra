#if os(macOS)
import AppKit
#else
import UIKit
#endif

public protocol FirstResponderRefusable: AnyObject {
    @discardableResult
    func refuseFirstResponder() -> Self
    
    @discardableResult
    func refuseFirstResponder(_ value: Bool) -> Self
    
    @discardableResult
    func refuseFirstResponder(_ binding: UIKitPlus.State<Bool>) -> Self
}

protocol _FirstResponderRefusable: FirstResponderRefusable {
    var _refuseFirstResponderState: State<Bool> { get }
    
    func _setRefuseFirstResponder(_ v: Bool)
}

extension FirstResponderRefusable {
    @discardableResult
    public func refuseFirstResponder() -> Self {
        refuseFirstResponder(true)
    }
    
    @discardableResult
    public func refuseFirstResponder(_ binding: UIKitPlus.State<Bool>) -> Self {
        binding.listen { [weak self] in
            self?.refuseFirstResponder($0)
        }
        .holdIfOwned(by: self)
        return refuseFirstResponder(binding.wrappedValue)
    }
}

@available(iOS 13.0, macOS 10.15, *)
extension FirstResponderRefusable {
    @discardableResult
    public func refuseFirstResponder(_ value: Bool) -> Self {
        guard let s = self as? _FirstResponderRefusable else { return self }
        s._setRefuseFirstResponder(value)
        return self
    }
}

// for iOS lower than 13
extension _FirstResponderRefusable {
    @discardableResult
    public func refuseFirstResponder(_ value: Bool) -> Self {
        _setRefuseFirstResponder(value)
        return self
    }
}
