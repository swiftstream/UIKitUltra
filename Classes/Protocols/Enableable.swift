#if os(macOS)
import AppKit
#else
import UIKit
#endif

public protocol Enableable: AnyObject {
    @discardableResult
    func enabled() -> Self
    
    @discardableResult
    func enabled(_ value: Bool) -> Self
    
    @discardableResult
    func enabled(_ binding: UIKitPlus.State<Bool>) -> Self
}

protocol _Enableable: Enableable {
    func _setEnabled(_ v: Bool)
}

extension Enableable {
    @discardableResult
    public func enabled() -> Self {
        enabled(true)
    }
    
    @discardableResult
    public func enabled(_ binding: UIKitPlus.State<Bool>) -> Self {
        binding.listen { [weak self] in
            self?.enabled($0)
        }
        .holdIfOwned(by: self)
        return enabled(binding.wrappedValue)
    }
}

@available(iOS 13.0, *)
extension Enableable {
    @discardableResult
    public func enabled(_ value: Bool) -> Self {
        guard let s = self as? _Enableable else { return self }
        s._setEnabled(value)
        return self
    }
}

// for iOS lower than 13
extension _Enableable {
    @discardableResult
    public func enabled(_ value: Bool) -> Self {
        _setEnabled(value)
        return self
    }
}
