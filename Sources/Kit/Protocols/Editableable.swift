#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
public protocol Editableable: AnyObject {
    @discardableResult
    func editable() -> Self
    
    @discardableResult
    func editable(_ value: Bool) -> Self
    
    @discardableResult
    func editable(_ binding: UIKitPlus.State<Bool>) -> Self
}

@MainActor
protocol _Editableable: Editableable {
    func _setEditable(_ v: Bool)
}

extension Editableable {
    @discardableResult
    public func editable() -> Self {
        editable(true)
    }
    
    @discardableResult
    public func editable(_ binding: UIKitPlus.State<Bool>) -> Self {
        binding.listen { [weak self] in
            self?.editable($0)
        }
        .holdInStateBindingOwnerIfAvailable(self)
        return editable(binding.wrappedValue)
    }
}

@available(iOS 13.0, *)
@MainActor
extension Editableable {
    @discardableResult
    public func editable(_ value: Bool) -> Self {
        guard let s = self as? _Editableable else { return self }
        s._setEditable(value)
        return self
    }
}

// for iOS lower than 13
@MainActor
extension _Editableable {
    @discardableResult
    public func editable(_ value: Bool) -> Self {
        _setEditable(value)
        return self
    }
}
#endif
