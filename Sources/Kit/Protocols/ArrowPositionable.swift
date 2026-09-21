#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit

@MainActor
public protocol ArrowPositionable: AnyObject {
    @discardableResult
    func arrowPosition(_ value: NSPopUpButton.ArrowPosition) -> Self
    
    @discardableResult
    func arrowPosition(_ binding: Ultra.State<NSPopUpButton.ArrowPosition>) -> Self
}

@MainActor
protocol _ArrowPositionable: ArrowPositionable {
    func _setArrowPosition(_ v: NSPopUpButton.ArrowPosition)
}

extension ArrowPositionable {
    @discardableResult
    public func arrowPosition(_ binding: Ultra.State<NSPopUpButton.ArrowPosition>) -> Self {
        binding.listen { [weak self] in
            self?.arrowPosition($0)
        }
        .holdInStateBindingOwnerIfAvailable(self)
        return arrowPosition(binding.wrappedValue)
    }
}

@available(iOS 13.0, macOS 10.15, *)
@MainActor
extension ArrowPositionable {
    @discardableResult
    public func arrowPosition(_ value: NSPopUpButton.ArrowPosition) -> Self {
        guard let s = self as? _ArrowPositionable else { return self }
        s._setArrowPosition(value)
        return self
    }
}

// for iOS lower than 13
@MainActor
extension _ArrowPositionable {
    @discardableResult
    public func arrowPosition(_ value: NSPopUpButton.ArrowPosition) -> Self {
        _setArrowPosition(value)
        return self
    }
}
#endif
#endif
