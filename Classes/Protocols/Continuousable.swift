#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
public protocol Continuousable: AnyObject {
    @discardableResult
    func continuous() -> Self
    
    @discardableResult
    func continuous(_ value: Bool) -> Self
    
    @discardableResult
    func continuous(_ binding: UIKitPlus.State<Bool>) -> Self
}

@MainActor
protocol _Continuousable: Continuousable {
    var _continuousState: State<Bool> { get }
    
    func _setContinuous(_ v: Bool)
}

extension Continuousable {
    @discardableResult
    public func continuous() -> Self {
        continuous(true)
    }
    
    @discardableResult
    public func continuous(_ binding: UIKitPlus.State<Bool>) -> Self {
        binding.listen { [weak self] in
            self?.continuous($0)
        }
        .holdInStateBindingOwnerIfAvailable(self)
        return continuous(binding.wrappedValue)
    }
}

@available(iOS 13.0, macOS 10.15, *)
@MainActor
extension Continuousable {
    @discardableResult
    public func continuous(_ value: Bool) -> Self {
        guard let s = self as? _Continuousable else { return self }
        s._setContinuous(value)
        return self
    }
}

// for iOS lower than 13
@MainActor
extension _Continuousable {
    @discardableResult
    public func continuous(_ value: Bool) -> Self {
        _setContinuous(value)
        return self
    }
}
