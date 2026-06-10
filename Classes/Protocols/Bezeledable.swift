#if os(macOS)
import AppKit
#else
import UIKit
#endif

public protocol Bezeledable: AnyObject {
    @discardableResult
    func bezeled() -> Self
    
    @discardableResult
    func bezeled(_ value: Bool) -> Self
    
    @discardableResult
    func bezeled(_ binding: UIKitPlus.State<Bool>) -> Self
}

protocol _Bezeledable: Bezeledable {
    func _setBezeled(_ v: Bool)
}

extension Bezeledable {
    @discardableResult
    public func bezeled() -> Self {
        bezeled(true)
    }
    
    @discardableResult
    public func bezeled(_ binding: UIKitPlus.State<Bool>) -> Self {
        binding.listen { [weak self] in
            self?.bezeled($0)
        }
        .holdIfOwned(by: self)
        return bezeled(binding.wrappedValue)
    }
}

@available(iOS 13.0, macOS 10.15, *)
extension Bezeledable {
    @discardableResult
    public func bezeled(_ value: Bool) -> Self {
        guard let s = self as? _Bezeledable else { return self }
        s._setBezeled(value)
        return self
    }
}

// for iOS lower than 13
extension _Bezeledable {
    @discardableResult
    public func bezeled(_ value: Bool) -> Self {
        _setBezeled(value)
        return self
    }
}
