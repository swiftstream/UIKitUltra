#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
public protocol Messageable: AnyObject {
    #if !os(macOS)
    @discardableResult
    func messageChangeTransition(_ value: UIView.AnimationOptions) -> Self
    #endif
    
    @discardableResult
    func message(_ value: LocalizedString...) -> Self
    
    @discardableResult
    func message(_ value: [LocalizedString]) -> Self
    
    @discardableResult
    func message(_ value: AnyString...) -> Self
    
    @discardableResult
    func message(_ value: [AnyString]) -> Self
    
    @discardableResult
    func message<A: AnyString>(_ state: State<A>) -> Self
    
    @discardableResult
    func message(@AnyStringBuilder stateString: @escaping AnyStringBuilder.Handler) -> Self
}

protocol _Messageable: Messageable {
    var _statedMessage: AnyStringBuilder.Handler? { get set }
    #if !os(macOS)
    var _messageChangeTransition: UIView.AnimationOptions? { get set }
    #endif
    
    func _setMessage(_ v: NSAttributedString?)
}

extension _Messageable {
    func _changeMessage(to newValue: NSAttributedString) {
        #if os(macOS)
        _setMessage(newValue)
        #else
        guard let transition = _messageChangeTransition else {
            _setMessage(newValue)
            return
        }
        if let view = self as? _ViewTransitionable {
            view._transition(0.25, transition) {
                self._setMessage(newValue)
            }
        } else {
            _setMessage(newValue)
        }
        #endif
    }
}

extension Messageable {
    @discardableResult
    public func message(_ value: LocalizedString...) -> Self {
        message(String(value))
    }
    
    @discardableResult
    public func message(_ value: [LocalizedString]) -> Self {
        message(String(value))
    }
    
    @discardableResult
    public func message(_ value: AnyString...) -> Self {
        message(value)
    }

    @discardableResult
    public func message<A: AnyString>(_ state: State<A>) -> Self {
        message(state.wrappedValue)
        state.listen { [weak self] in
            self?.message($0)
        }
        .holdInStateBindingOwnerIfAvailable(self)
        return self
    }
}

@available(iOS 13.0, *)
extension Messageable {
    #if !os(macOS)
    @discardableResult
    public func textChangeTransition(_ value: UIView.AnimationOptions) -> Self {
        guard let s = self as? _Messageable else { return self }
        s._messageChangeTransition = value
        return self
    }
    #endif
    
    @discardableResult
    public func text(_ value: [AnyString]) -> Self {
        guard let s = self as? _Messageable else { return self }
        value.onUpdate { [weak s] in
            s?._changeMessage(to: $0)
        }
        s._changeMessage(to: value.attributedString)
        return self
    }
    
    @discardableResult
    public func text(@AnyStringBuilder stateString: @escaping AnyStringBuilder.Handler) -> Self {
        (self as? _Messageable)?._statedMessage = stateString
        return message(stateString())
    }
}

// for iOS lower than 13
extension _Messageable {
    #if !os(macOS)
    @discardableResult
    public func messageChangeTransition(_ value: UIView.AnimationOptions) -> Self {
        _messageChangeTransition = value
        return self
    }
    #endif
    
    @discardableResult
    public func message(_ value: [AnyString]) -> Self {
        value.onUpdate { [weak self] in
            self?._changeMessage(to: $0)
        }
        _changeMessage(to: value.attributedString)
        return self
    }
    
    @discardableResult
    public func message(@AnyStringBuilder stateString: @escaping AnyStringBuilder.Handler) -> Self {
        _statedMessage = stateString
        return message(stateString())
    }
}
