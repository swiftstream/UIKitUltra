#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
public protocol Borderedable: AnyObject {
    @discardableResult
    func bordered() -> Self
    
    @discardableResult
    func bordered(_ value: Bool) -> Self
    
    @discardableResult
    func bordered(_ binding: Ultra.State<Bool>) -> Self
}

@MainActor
protocol _Borderedable: Borderedable {
    var _borderedState: State<Bool> { get }
    
    func _setBordered(_ v: Bool)
}

extension Borderedable {
    @discardableResult
    public func bordered() -> Self {
        bordered(true)
    }
    
    @discardableResult
    public func bordered(_ binding: Ultra.State<Bool>) -> Self {
        binding.listen { [weak self] in
            self?.bordered($0)
        }
        .holdInStateBindingOwnerIfAvailable(self)
        return bordered(binding.wrappedValue)
    }
}

@available(iOS 13.0, macOS 10.15, *)
@MainActor
extension Borderedable {
    @discardableResult
    public func bordered(_ value: Bool) -> Self {
        guard let s = self as? _Borderedable else { return self }
        s._setBordered(value)
        return self
    }
}

// for iOS lower than 13
@MainActor
extension _Borderedable {
    @discardableResult
    public func bordered(_ value: Bool) -> Self {
        _setBordered(value)
        return self
    }
}
#endif
