#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
public protocol Titleable: AnyObject {
    #if !os(macOS)
    @discardableResult
    func titleChangeTransition(_ value: UIView.AnimationOptions) -> Self
    #endif
    
    @discardableResult
    func title(_ value: LocalizedString...) -> Self
    
    @discardableResult
    func title(_ value: [LocalizedString]) -> Self
    
    @discardableResult
    func title(_ value: AnyString...) -> Self
    
    @discardableResult
    func title(_ value: [AnyString]) -> Self
    
    @discardableResult
    func title<A: AnyString>(_ state: State<A>) -> Self
    
    @discardableResult
    func title(@AnyStringBuilder stateString: @escaping AnyStringBuilder.Handler) -> Self
}

@MainActor
protocol _Titleable: Titleable {
    var _statedTitle: AnyStringBuilder.Handler? { get set }
    #if !os(macOS)
    var _titleChangeTransition: UIView.AnimationOptions? { get set }
    #endif
    
    func _setTitle(_ v: NSAttributedString?)
}

@MainActor
extension _Titleable {
    func _changeTitle(to newValue: NSAttributedString) {
        #if os(macOS)
        _setTitle(newValue)
        #else
        guard let transition = _titleChangeTransition else {
            _setTitle(newValue)
            return
        }
        if let view = self as? _ViewTransitionable {
            view._transition(0.25, transition) {
                self._setTitle(newValue)
            }
        } else {
            _setTitle(newValue)
        }
        #endif
    }
}

extension Titleable {
    @discardableResult
    public func title(_ value: LocalizedString...) -> Self {
        title(String(value))
    }
    
    @discardableResult
    public func title(_ value: [LocalizedString]) -> Self {
        title(String(value))
    }
    
    @discardableResult
    public func title(_ value: AnyString...) -> Self {
        title(value)
    }
    
    @discardableResult
    public func title<A: AnyString>(_ state: State<A>) -> Self {
        title(state.wrappedValue)
        state.listen { [weak self] in
            self?.title($0)
        }
        .holdIfOwned(by: self)
        return self
    }
}

@available(iOS 13.0, *)
@MainActor
extension Titleable {
    #if !os(macOS)
    @discardableResult
    public func titleChangeTransition(_ value: UIView.AnimationOptions) -> Self {
        (self as? _Titleable)?._titleChangeTransition = value
        return self
    }
    #endif
    
    @discardableResult
    public func title(_ value: [AnyString]) -> Self {
        guard let s = self as? _Titleable else { return self }
        value.onUpdate { [weak s] in
            s?._changeTitle(to: $0)
        }
        s._changeTitle(to: value.attributedString)
        return self
    }

    @discardableResult
    public func title(@AnyStringBuilder stateString: @escaping AnyStringBuilder.Handler) -> Self {
        (self as? _Titleable)?._statedTitle = stateString
        return title(stateString())
    }
}

// for iOS lower than 13
@MainActor
extension _Titleable {
    #if !os(macOS)
    @discardableResult
    public func titleChangeTransition(_ value: UIView.AnimationOptions) -> Self {
        _titleChangeTransition = value
        return self
    }
    #endif
    
    @discardableResult
    public func title(_ value: [AnyString]) -> Self {
        value.onUpdate { [weak self] in
            self?._changeTitle(to: $0)
        }
        _changeTitle(to: value.attributedString)
        return self
    }
    
    @discardableResult
    public func title(@AnyStringBuilder stateString: @escaping AnyStringBuilder.Handler) -> Self {
        _statedTitle = stateString
        return title(stateString())
    }
}
