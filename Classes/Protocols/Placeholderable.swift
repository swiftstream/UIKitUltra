#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
public protocol Placeholderable: AnyObject {
    #if !os(macOS)
    @discardableResult
    func placeholderChangeTransition(_ value: UIView.AnimationOptions) -> Self
    #endif
    
    @discardableResult
    func placeholder(_ value: LocalizedString...) -> Self
    
    @discardableResult
    func placeholder(_ value: [LocalizedString]) -> Self
    
    @discardableResult
    func placeholder(_ value: AnyString...) -> Self
    
    @discardableResult
    func placeholder(_ value: [AnyString]) -> Self
    
    @discardableResult
    func placeholder<A: AnyString>(_ state: State<A>) -> Self
    
    @discardableResult
    func placeholder(@AnyStringBuilder stateString: @escaping AnyStringBuilder.Handler) -> Self
}

@MainActor
protocol _Placeholderable: Placeholderable {
    var _statedPlaceholder: AnyStringBuilder.Handler? { get set }
    #if !os(macOS)
    var _placeholderChangeTransition: UIView.AnimationOptions? { get set }
    #endif
    
    func _setPlaceholder(_ v: NSAttributedString?)
}

@MainActor
extension _Placeholderable {
    func _changePlaceholder(to newValue: NSAttributedString) {
        #if os(macOS)
        _setPlaceholder(newValue)
        #else
        guard let transition = _placeholderChangeTransition else {
            _setPlaceholder(newValue)
            return
        }
        if let view = self as? _ViewTransitionable {
            view._transition(0.25, transition) {
                self._setPlaceholder(newValue)
            }
        } else {
            _setPlaceholder(newValue)
        }
        #endif
    }
}

extension Placeholderable {
    @discardableResult
    public func placeholder(_ value: LocalizedString...) -> Self {
        placeholder(String(value))
    }
    
    @discardableResult
    public func placeholder(_ value: [LocalizedString]) -> Self {
        placeholder(String(value))
    }
    
    @discardableResult
    public func placeholder(_ value: AnyString...) -> Self {
        placeholder(value)
    }

    @discardableResult
    public func placeholder<A: AnyString>(_ state: State<A>) -> Self {
        placeholder(state.wrappedValue)
        state.listen { [weak self] in
            self?.placeholder($0)
        }
        .holdIfOwned(by: self)
        return self
    }
}

@available(iOS 13.0, *)
@MainActor
extension Placeholderable {
    #if !os(macOS)
    @discardableResult
    public func placeholderChangeTransition(_ value: UIView.AnimationOptions) -> Self {
        guard let s = self as? _Placeholderable else { return self }
        s._placeholderChangeTransition = value
        return self
    }
    #endif
    
    @discardableResult
    public func placeholder(_ value: [AnyString]) -> Self {
        guard let s = self as? _Placeholderable else { return self }
        value.onUpdate { [weak s] in
            s?._changePlaceholder(to: $0)
        }
        s._changePlaceholder(to: value.attributedString)
        return self
    }
    
    @discardableResult
    public func placeholder(@AnyStringBuilder stateString: @escaping AnyStringBuilder.Handler) -> Self {
        (self as? _Placeholderable)?._statedPlaceholder = stateString
        return placeholder(stateString())
    }
}

// for iOS lower than 13
@MainActor
extension _Placeholderable {
    #if !os(macOS)
    @discardableResult
    public func placeholderChangeTransition(_ value: UIView.AnimationOptions) -> Self {
        _placeholderChangeTransition = value
        return self
    }
    #endif
    
    @discardableResult
    public func placeholder(_ value: [AnyString]) -> Self {
        value.onUpdate { [weak self] in
            self?._changePlaceholder(to: $0)
        }
        _changePlaceholder(to: value.attributedString)
        return self
    }
    
    @discardableResult
    public func placeholder(@AnyStringBuilder stateString: @escaping AnyStringBuilder.Handler) -> Self {
        _statedPlaceholder = stateString
        return placeholder(stateString())
    }
}
