#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
public protocol TextAttributesEditingAllowable: AnyObject {
    @discardableResult
    func allowEditingTextAttributes() -> Self
    
    @discardableResult
    func allowEditingTextAttributes(_ value: Bool) -> Self
    
    @discardableResult
    func allowEditingTextAttributes(_ binding: UIKitPlus.State<Bool>) -> Self
}

@MainActor
protocol _TextAttributesEditingAllowable: TextAttributesEditingAllowable {
    func _setAllowEditingTextAttributes(_ v: Bool)
}

extension TextAttributesEditingAllowable {
    @discardableResult
    public func allowEditingTextAttributes() -> Self {
        allowEditingTextAttributes(true)
    }
    
    @discardableResult
    public func allowEditingTextAttributes(_ binding: UIKitPlus.State<Bool>) -> Self {
        binding.listen { [weak self] in
            self?.allowEditingTextAttributes($0)
        }
        .holdInStateBindingOwnerIfAvailable(self)
        return allowEditingTextAttributes(binding.wrappedValue)
    }
}

@available(iOS 13.0, macOS 10.15, *)
@MainActor
extension TextAttributesEditingAllowable {
    @discardableResult
    public func allowEditingTextAttributes(_ value: Bool) -> Self {
        guard let s = self as? _TextAttributesEditingAllowable else { return self }
        s._setAllowEditingTextAttributes(value)
        return self
    }
}

// for iOS lower than 13
@MainActor
extension _TextAttributesEditingAllowable {
    @discardableResult
    public func allowEditingTextAttributes(_ value: Bool) -> Self {
        _setAllowEditingTextAttributes(value)
        return self
    }
}
