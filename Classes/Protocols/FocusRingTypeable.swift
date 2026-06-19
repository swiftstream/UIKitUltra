#if os(macOS)
import AppKit

@MainActor
public protocol FocusRingTypeable: AnyObject {
    @discardableResult
    func focusRingType(_ value: NSFocusRingType) -> Self
    
    @discardableResult
    func focusRingType(_ binding: UIKitPlus.State<NSFocusRingType>) -> Self
}

@MainActor
protocol _FocusRingTypeable: FocusRingTypeable {
    func _setFocusRingType(_ v: NSFocusRingType)
}

extension FocusRingTypeable {
    @discardableResult
    public func focusRingType(_ binding: UIKitPlus.State<NSFocusRingType>) -> Self {
        binding.listen { [weak self] in
            self?.focusRingType($0)
        }
        .holdInStateBindingOwnerIfAvailable(self)
        return focusRingType(binding.wrappedValue)
    }
}

@available(iOS 13.0, macOS 10.15, *)
@MainActor
extension FocusRingTypeable {
    @discardableResult
    public func focusRingType(_ value: NSFocusRingType) -> Self {
        guard let s = self as? _FocusRingTypeable else { return self }
        s._setFocusRingType(value)
        return self
    }
}

// for iOS lower than 13
@MainActor
extension _FocusRingTypeable {
    @discardableResult
    public func focusRingType(_ value: NSFocusRingType) -> Self {
        _setFocusRingType(value)
        return self
    }
}
#endif
