#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
public protocol TextAdjustsFontSizeable: AnyObject {
    @discardableResult
    func adjustsFontSizeToFitWidth() -> Self
    
    @discardableResult
    func adjustsFontSizeToFitWidth(_ value: Bool) -> Self
    
    @discardableResult
    func adjustsFontSizeToFitWidth(_ binding: UIKitPlus.State<Bool>) -> Self
}

protocol _TextAdjustsFontSizeable: TextAdjustsFontSizeable {
    func _setAdjustsFontSizeToFitWidth(_ v: Bool)
}

extension TextAdjustsFontSizeable {
    @discardableResult
    public func adjustsFontSizeToFitWidth() -> Self {
        adjustsFontSizeToFitWidth(true)
    }
    
    @discardableResult
    public func adjustsFontSizeToFitWidth(_ binding: UIKitPlus.State<Bool>) -> Self {
        binding.listen { [weak self] in
            self?.adjustsFontSizeToFitWidth($0)
        }
        .holdInStateBindingOwnerIfAvailable(self)
        return adjustsFontSizeToFitWidth(binding.wrappedValue)
    }
}

@available(iOS 13.0, *)
extension TextAdjustsFontSizeable {
    @discardableResult
    public func adjustsFontSizeToFitWidth(_ value: Bool) -> Self {
        guard let s = self as? _TextAdjustsFontSizeable else { return self }
        s._setAdjustsFontSizeToFitWidth(value)
        return self
    }
}

// for iOS lower than 13s
extension _TextAdjustsFontSizeable {
    @discardableResult
    public func adjustsFontSizeToFitWidth(_ value: Bool) -> Self {
        _setAdjustsFontSizeToFitWidth(value)
        return self
    }
}
#endif
