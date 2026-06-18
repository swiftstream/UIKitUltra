#if !os(macOS)
import UIKit

@MainActor
public protocol TextFieldLeftViewable {
    func leftView(_ view: UIView) -> Self
    func leftView(_ view: UIView, mode: UITextField.ViewMode) -> Self
    func leftView(_ view: @escaping () -> UIView) -> Self
    func leftView(mode: UITextField.ViewMode, _ view: @escaping () -> UIView) -> Self
}

@MainActor
protocol _TextFieldLeftViewable: TextFieldLeftViewable {
    func _setLeftView(v: UIView)
    func _setLeftViewMode(v: UITextField.ViewMode)
}

extension TextFieldLeftViewable {
    @discardableResult
    public func leftView(_ view: UIView) -> Self {
        leftView(view, mode: .always)
    }
    
    @discardableResult
    public func leftView(_ view: @escaping () -> UIView) -> Self {
        leftView(mode: .always, view)
    }
    
    @discardableResult
    public func leftView(mode: UITextField.ViewMode, _ view: @escaping () -> UIView) -> Self {
        leftView(view(), mode: mode)
    }
}

@available(iOS 13.0, *)
extension TextFieldLeftViewable {
    @discardableResult
    public func leftView(_ view: UIView, mode: UITextField.ViewMode) -> Self {
        guard let s = self as? _TextFieldLeftViewable else { return self }
        s._setLeftView(v: view)
        s._setLeftViewMode(v: mode)
        return self
    }
}

// for iOS lower than 13
extension _TextFieldLeftViewable {
    @discardableResult
    public func leftView(_ view: UIView, mode: UITextField.ViewMode) -> Self {
        _setLeftView(v: view)
        _setLeftViewMode(v: mode)
        return self
    }
}
#endif
