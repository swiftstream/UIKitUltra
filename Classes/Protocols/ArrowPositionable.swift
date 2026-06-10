#if os(macOS)
import AppKit

public protocol ArrowPositionable: AnyObject {
    @discardableResult
    func arrowPosition(_ value: NSPopUpButton.ArrowPosition) -> Self
    
    @discardableResult
    func arrowPosition(_ binding: UIKitPlus.State<NSPopUpButton.ArrowPosition>) -> Self
}

protocol _ArrowPositionable: ArrowPositionable {
    func _setArrowPosition(_ v: NSPopUpButton.ArrowPosition)
}

extension ArrowPositionable {
    @discardableResult
    public func arrowPosition(_ binding: UIKitPlus.State<NSPopUpButton.ArrowPosition>) -> Self {
        binding.listen { [weak self] in
            self?.arrowPosition($0)
        }
        .holdIfOwned(by: self)
        return arrowPosition(binding.wrappedValue)
    }
}

@available(iOS 13.0, macOS 10.15, *)
extension ArrowPositionable {
    @discardableResult
    public func arrowPosition(_ value: NSPopUpButton.ArrowPosition) -> Self {
        guard let s = self as? _ArrowPositionable else { return self }
        s._setArrowPosition(value)
        return self
    }
}

// for iOS lower than 13
extension _ArrowPositionable {
    @discardableResult
    public func arrowPosition(_ value: NSPopUpButton.ArrowPosition) -> Self {
        _setArrowPosition(value)
        return self
    }
}
#endif
