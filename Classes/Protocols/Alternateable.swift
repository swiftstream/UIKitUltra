#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
public protocol Alternateable: AnyObject {
    @discardableResult
    func alternate() -> Self
    
    @discardableResult
    func alternate(_ value: Bool) -> Self
    
    @discardableResult
    func alternate(_ binding: UIKitPlus.State<Bool>) -> Self
}

protocol _Alternateable: Alternateable {
    func _setAlternate(_ v: Bool)
}

extension Alternateable {
    @discardableResult
    public func alternate() -> Self {
        alternate(true)
    }
    
    @discardableResult
    public func alternate(_ binding: UIKitPlus.State<Bool>) -> Self {
        binding.listen { [weak self] in
            self?.alternate($0)
        }
        .holdIfOwned(by: self)
        return alternate(binding.wrappedValue)
    }
}

@available(iOS 13.0, *)
extension Alternateable {
    @discardableResult
    public func alternate(_ value: Bool) -> Self {
        guard let s = self as? _Alternateable else { return self }
        s._setAlternate(value)
        return self
    }
}

// for iOS lower than 13
extension _Alternateable {
    @discardableResult
    public func alternate(_ value: Bool) -> Self {
        _setAlternate(value)
        return self
    }
}
