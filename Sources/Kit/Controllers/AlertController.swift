#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

extension UIAlertController: _Messageable, _UIAlertViewControllerable {
    /// See `_Messageable`
    
    var _statedMessage: AnyStringBuilder.Handler? {
        get { nil }
        set {}
    }
    
    var _messageChangeTransition: UIView.AnimationOptions? {
        get { nil }
        set {}
    }
    
    func _setMessage(_ v: NSAttributedString?) {
        message = v?.string
    }
    
    func _present(in vc: UIViewController, animated: Bool, completion: (() -> Void)?) -> Self {
        vc.present(self, animated: true, completion: completion)
        return self
    }
    
    public var controller: UIAlertController { self }
    
    @discardableResult
    public func textField(configurationHandler: @escaping ((UITextField) -> Void)) -> Self {
        addTextField(configurationHandler: configurationHandler)
        return self
    }
}

open class ActionSheet: UIAlertController {
    private let _stateBindingHolder = TempStatesHolder()

    var stateBindingHolder: TempStatesHolder {
        _stateBindingHolder
    }

    public convenience init() {
        self.init(title: nil, message: nil, preferredStyle: .actionSheet)
    }
}

open class AlertController: UIAlertController {
    private let _stateBindingHolder = TempStatesHolder()

    var stateBindingHolder: TempStatesHolder {
        _stateBindingHolder
    }

    public convenience init(_ style: UIAlertController.Style) {
        self.init(title: nil, message: nil, preferredStyle: style)
    }
    
    @discardableResult
    public func sourceView(_ view: UIView) -> Self {
        popoverPresentationController?.sourceView = view
        return self
    }
}

public typealias AlertAction = UIAlertAction

extension ActionSheet: _StateBindingOwner {}

extension AlertController: _StateBindingOwner {}

extension UIAlertAction: _Enableable {
    func _setEnabled(_ v: Bool) {
        isEnabled = v
    }
}

@MainActor
public protocol UIAlertViewControllerable {
    var controller: UIAlertController { get }
    
    @discardableResult
    func action(_ title: String?, _ style: UIAlertAction.Style, _ handler: @escaping ((AlertAction) -> Void)) -> Self
    
    @discardableResult
    func action(_ title: String?, _ style: UIAlertAction.Style, _ handler: @escaping ((AlertAction, UIAlertController) -> Void)) -> Self
    
    @discardableResult
    func action(_ title: String?, _ handler: @escaping ((AlertAction) -> Void)) -> Self
    
    @discardableResult
    func action(_ title: String?, _ handler: @escaping ((AlertAction, UIAlertController) -> Void)) -> Self
    
    @discardableResult
    func action(_ title: String?) -> Self
    
    @discardableResult
    func action(_ title: String?, _ style: UIAlertAction.Style, _ handler: @escaping (() -> Void)) -> Self
    
    @discardableResult
    func action(_ title: String?, _ handler: @escaping (() -> Void)) -> Self
    
    @discardableResult
    func destructive(_ title: String?, _ handler: @escaping ((AlertAction) -> Void)) -> Self
    
    @discardableResult
    func destructive(_ title: String?, _ handler: @escaping ((AlertAction, UIAlertController) -> Void)) -> Self
    
    @discardableResult
    func destructive(_ title: String?, _ handler: @escaping (() -> Void)) -> Self
    
    @discardableResult
    func destructive(_ title: String?) -> Self
    
    @discardableResult
    func cancel(_ title: String?, _ handler: @escaping ((AlertAction) -> Void)) -> Self
    
    @discardableResult
    func cancel(_ title: String?, _ handler: @escaping ((AlertAction, UIAlertController) -> Void)) -> Self
    
    @discardableResult
    func cancel(_ title: String?, _ handler: @escaping (() -> Void)) -> Self
    
    @discardableResult
    func cancel(_ title: String?) -> Self
    
    @discardableResult
    func present(in vc: UIViewController, animated: Bool, completion: @escaping (() -> Void)) -> Self
    
    @discardableResult
    func present(in vc: UIViewController, animated: Bool) -> Self
    
    @discardableResult
    func present(in vc: UIViewController, completion: @escaping (() -> Void)) -> Self
    
    @discardableResult
    func present(in vc: UIViewController) -> Self
    
    func addAction(_ action: UIAlertAction)
    
    @discardableResult
    func textField(configurationHandler: @escaping ((UITextField) -> Void)) -> Self
}

@MainActor
protocol _UIAlertViewControllerable: UIAlertViewControllerable {
    func _present(in vc: UIViewController, animated: Bool, completion: (() -> Void)?) -> Self
}

extension UIAlertViewControllerable {
    @discardableResult
    public func action(_ title: String?, _ style: UIAlertAction.Style, _ handler: @escaping ((AlertAction) -> Void)) -> Self {
        action(title, style) { action, controller in
            handler(action)
        }
    }
    
    public func action(_ title: String?, _ style: UIAlertAction.Style, _ handler: @escaping ((AlertAction, UIAlertController) -> Void)) -> Self {
        addAction(AlertAction(title: title, style: style) {
            handler($0, self.controller)
        })
        return self
    }
    
    @discardableResult
    public func action(_ title: String?, _ handler: @escaping ((AlertAction) -> Void)) -> Self {
        action(title, .default, handler)
    }
    
    @discardableResult
    public func action(_ title: String?, _ handler: @escaping ((AlertAction, UIAlertController) -> Void)) -> Self {
        action(title, .default, handler)
    }
    
    @discardableResult
    public func action(_ title: String?) -> Self {
        action(title, .default) {}
    }
    
    @discardableResult
    public func action(_ title: String?, _ style: UIAlertAction.Style, _ handler: @escaping (() -> Void)) -> Self {
        action(title, style) { _ in handler() }
    }
    
    @discardableResult
    public func action(_ title: String?, _ handler: @escaping (() -> Void)) -> Self {
        action(title, .default, handler)
    }
    
    @discardableResult
    public func destructive(_ title: String?, _ handler: @escaping ((AlertAction) -> Void)) -> Self {
        action(title, .destructive, handler)
    }
    
    @discardableResult
    public func destructive(_ title: String?, _ handler: @escaping ((AlertAction, UIAlertController) -> Void)) -> Self {
        action(title, .destructive, handler)
    }
    
    @discardableResult
    public func destructive(_ title: String?, _ handler: @escaping (() -> Void)) -> Self {
        action(title, .destructive, handler)
    }
    
    @discardableResult
    public func destructive(_ title: String?) -> Self {
        destructive(title) { _ in }
    }
    
    @discardableResult
    public func cancel(_ title: String?, _ handler: @escaping ((AlertAction) -> Void)) -> Self {
        action(title, .cancel, handler)
    }
    
    @discardableResult
    public func cancel(_ title: String?, _ handler: @escaping ((AlertAction, UIAlertController) -> Void)) -> Self {
        action(title, .cancel, handler)
    }
    
    @discardableResult
    public func cancel(_ title: String?, _ handler: @escaping (() -> Void)) -> Self {
        action(title, handler)
    }
    
    @discardableResult
    public func cancel(_ title: String?) -> Self {
        action(title, .cancel) {}
    }
    
    @discardableResult
    public func present(in vc: UIViewController, animated: Bool, completion: @escaping (() -> Void)) -> Self {
        guard let s = self as? _UIAlertViewControllerable else { return self }
        return s._present(in: vc, animated: animated, completion: completion) as! Self
    }
    
    @discardableResult
    public func present(in vc: UIViewController, animated: Bool) -> Self {
        present(in: vc, animated: animated) {}
    }
    
    @discardableResult
    public func present(in vc: UIViewController, completion: @escaping (() -> Void)) -> Self {
        present(in: vc, animated: true, completion: completion)
    }
    
    @discardableResult
    public func present(in vc: UIViewController) -> Self {
        present(in: vc) {}
    }
}
#endif
#endif
