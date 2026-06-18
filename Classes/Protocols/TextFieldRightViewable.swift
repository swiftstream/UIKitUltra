#if !os(macOS)
import UIKit

@MainActor
public protocol TextFieldRightViewable {
    func rightView(_ view: UIView) -> Self
    func rightView(_ view: UIView, mode: UITextField.ViewMode) -> Self
    func rightView(_ view: @escaping () -> UIView) -> Self
    func rightView(mode: UITextField.ViewMode, _ view: @escaping () -> UIView) -> Self
}

@MainActor
protocol _TextFieldRightViewable: TextFieldRightViewable {
    func _setRightView(v: UIView)
    func _setRightViewMode(v: UITextField.ViewMode)
}

extension TextFieldRightViewable {
    @discardableResult
    public func rightView(_ view: UIView) -> Self {
        rightView(view, mode: .always)
    }
    
    @discardableResult
    public func rightView(_ view: @escaping () -> UIView) -> Self {
        rightView(mode: .always, view)
    }
    
    @discardableResult
    public func rightView(mode: UITextField.ViewMode, _ view: @escaping () -> UIView) -> Self {
        rightView(view(), mode: mode)
    }
}

@available(iOS 13.0, *)
extension TextFieldRightViewable {
    @discardableResult
    public func rightView(_ view: UIView, mode: UITextField.ViewMode) -> Self {
        guard let s = self as? _TextFieldRightViewable else { return self }
        s._setRightView(v: view)
        s._setRightViewMode(v: mode)
        return self
    }
}

// for iOS lower than 13
extension _TextFieldRightViewable {
    @discardableResult
    public func rightView(_ view: UIView, mode: UITextField.ViewMode) -> Self {
        _setRightView(v: view)
        _setRightViewMode(v: mode)
        return self
    }
}
#endif
