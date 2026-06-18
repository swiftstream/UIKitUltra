#if !os(macOS)
import UIKit

@MainActor
public protocol Keyboardable {
    @discardableResult
    func keyboard(_ keyboard: UIKeyboardType) -> Self
    
    @discardableResult
    func returnKeyType(_ type: UIReturnKeyType) -> Self
    
    @discardableResult
    func keyboardAppearance(_ appearance: UIKeyboardAppearance) -> Self
    
    @discardableResult
    func inputView(_ view: UIView) -> Self
    
    @discardableResult
    func inputAccessoryView(_ view: UIView) -> Self
}

@MainActor
protocol _Keyboardable: Keyboardable {
    func _setKeyboardType(_ v: UIKeyboardType)
    func _setReturnKeyType(_ v: UIReturnKeyType)
    func _setKeyboardAppearance(_ v: UIKeyboardAppearance)
    func _setInputView(_ v: UIView?)
    func _setInputAccessoryView(_ v: UIView?)
}

extension Keyboardable {
    @discardableResult
    public func inputView(_ view: (Self) -> UIView) -> Self {
        inputView(view(self))
    }
    
    @discardableResult
    public func inputAccessoryView(_ view: (Self) -> UIView) -> Self {
        inputAccessoryView(view(self))
    }
}

@available(iOS 13.0, *)
extension Keyboardable {
    @discardableResult
    public func keyboard(_ keyboard: UIKeyboardType) -> Self {
        guard let s = self as? _Keyboardable else { return self }
        s._setKeyboardType(keyboard)
        return self
    }
    
    @discardableResult
    public func returnKeyType(_ type: UIReturnKeyType) -> Self {
        guard let s = self as? _Keyboardable else { return self }
        s._setReturnKeyType(type)
        return self
    }
    
    @discardableResult
    public func keyboardAppearance(_ appearance: UIKeyboardAppearance) -> Self {
        guard let s = self as? _Keyboardable else { return self }
        s._setKeyboardAppearance(appearance)
        return self
    }
    
    @discardableResult
    public func inputView(_ view: UIView) -> Self {
        guard let s = self as? _Keyboardable else { return self }
        s._setInputView(view)
        return self
    }
    
    @discardableResult
    public func inputAccessoryView(_ view: UIView) -> Self {
        guard let s = self as? _Keyboardable else { return self }
        s._setInputAccessoryView(view)
        return self
    }
}

// for iOS lower than 13
extension _Keyboardable {
    @discardableResult
    public func keyboard(_ keyboard: UIKeyboardType) -> Self {
        _setKeyboardType(keyboard)
        return self
    }
    
    @discardableResult
    public func returnKeyType(_ type: UIReturnKeyType) -> Self {
        _setReturnKeyType(type)
        return self
    }
    
    @discardableResult
    public func keyboardAppearance(_ appearance: UIKeyboardAppearance) -> Self {
        _setKeyboardAppearance(appearance)
        return self
    }
    
    @discardableResult
    public func inputView(_ view: UIView) -> Self {
        _setInputView(view)
        return self
    }
    
    @discardableResult
    public func inputAccessoryView(_ view: UIView) -> Self {
        _setInputAccessoryView(view)
        return self
    }
}
#endif
