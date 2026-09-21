#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
public protocol GestureRecognizerable: AnyObject {
    @discardableResult
    func delegate(_ v: UGestureRecognizerDelegate) -> Self
}

@MainActor
protocol _GestureRecognizerable: GestureRecognizerable {
    func _setDelegate(_ v: UGestureRecognizerDelegate)
    func _setEnabled(_ v: Bool)
    #if !os(macOS)
    func _setCancelsTouchesInView(_ v: Bool)
    func _setDelaysTouchesBegan(_ v: Bool)
    func _setDelaysTouchesEnded(_ v: Bool)
    func _setName(_ v: String)
    func _setRequiresExclusiveTouchType(_ v: Bool)
    func _setAllowedTouchTypes(_ v: [NSNumber])
    func _setAllowedPressTypes(_ v: [NSNumber])
    #endif
    func _setRequireToFailOtherGestureRecognizer(_ v: UGestureRecognizer)
}

@MainActor
private extension GestureRecognizerable {
    func _holdGestureBindingListenerIfPossible(_ listener: StateListener) {
        guard let tracker = (self as? _GestureTrackable)?._tracker else {
            return
        }

        listener.hold(in: tracker)
    }
}

@available(iOS 13.0, *)
@MainActor
extension GestureRecognizerable {
    @discardableResult
    public func delegate(_ v: UGestureRecognizerDelegate) -> Self {
        guard let s = self as? _GestureRecognizerable else { return self }
        s._setDelegate(v)
        return self
    }
    
    // MARK: enabled
    
    @discardableResult
    public func enabled(_ value: Bool) -> Self {
        guard let s = self as? _GestureRecognizerable else { return self }
        s._setEnabled(value)
        return self
    }
    
    @discardableResult
    public func enabled() -> Self {
        enabled(true)
    }
    
    @discardableResult
    public func enabled(_ binding: Ultra.State<Bool>) -> Self {
        let listener = binding.listen { [weak self] in
            self?.enabled($0)
        }
        _holdGestureBindingListenerIfPossible(listener)
        return enabled(binding.wrappedValue)
    }
    
    #if !os(macOS)
    // MARK: cancelsTouchesInView
    
    @discardableResult
    public func cancelsTouchesInView(_ value: Bool) -> Self {
        guard let s = self as? _GestureRecognizerable else { return self }
        s._setCancelsTouchesInView(value)
        return self
    }
    
    @discardableResult
    public func cancelsTouchesInView() -> Self {
        cancelsTouchesInView(true)
    }
    
    @discardableResult
    public func cancelsTouchesInView(_ binding: Ultra.State<Bool>) -> Self {
        let listener = binding.listen { [weak self] in
            self?.cancelsTouchesInView($0)
        }
        _holdGestureBindingListenerIfPossible(listener)
        return cancelsTouchesInView(binding.wrappedValue)
    }
    
    // MARK: delaysTouchesBegan
    
    @discardableResult
    public func delaysTouchesBegan(_ value: Bool) -> Self {
        guard let s = self as? _GestureRecognizerable else { return self }
        s._setDelaysTouchesBegan(value)
        return self
    }
    
    @discardableResult
    public func delaysTouchesBegan() -> Self {
        delaysTouchesBegan(true)
    }
    
    @discardableResult
    public func delaysTouchesBegan(_ binding: Ultra.State<Bool>) -> Self {
        let listener = binding.listen { [weak self] in
            self?.delaysTouchesBegan($0)
        }
        _holdGestureBindingListenerIfPossible(listener)
        return delaysTouchesBegan(binding.wrappedValue)
    }
    
    // MARK: delaysTouchesEnded
    
    @discardableResult
    public func delaysTouchesEnded(_ value: Bool) -> Self {
        guard let s = self as? _GestureRecognizerable else { return self }
        s._setDelaysTouchesEnded(value)
        return self
    }
    
    @discardableResult
    public func delaysTouchesEnded() -> Self {
        delaysTouchesEnded(true)
    }
    
    @discardableResult
    public func delaysTouchesEnded(_ binding: Ultra.State<Bool>) -> Self {
        let listener = binding.listen { [weak self] in
            self?.delaysTouchesEnded($0)
        }
        _holdGestureBindingListenerIfPossible(listener)
        return delaysTouchesEnded(binding.wrappedValue)
    }
    
    // MARK: requiresExclusiveTouchType
    
    @discardableResult
    public func requiresExclusiveTouchType(_ value: Bool) -> Self {
        guard let s = self as? _GestureRecognizerable else { return self }
        s._setRequiresExclusiveTouchType(value)
        return self
    }
    
    @discardableResult
    public func requiresExclusiveTouchType() -> Self {
        requiresExclusiveTouchType(true)
    }
    
    @discardableResult
    public func requiresExclusiveTouchType(_ binding: Ultra.State<Bool>) -> Self {
        let listener = binding.listen { [weak self] in
            self?.requiresExclusiveTouchType($0)
        }
        _holdGestureBindingListenerIfPossible(listener)
        return requiresExclusiveTouchType(binding.wrappedValue)
    }
    
    // MARK: allowedTouchTypes
    
    @discardableResult
    public func allowedTouchTypes(_ values: [NSNumber]) -> Self {
        guard let s = self as? _GestureRecognizerable else { return self }
        s._setAllowedTouchTypes(values)
        return self
    }
    
    @discardableResult
    public func allowedTouchTypes(_ values: NSNumber...) -> Self {
        allowedTouchTypes(values)
    }

    @discardableResult
    public func allowedPressTypes(_ values: NSNumber...) -> Self {
        allowedPressTypes(values)
    }
    
    // MARK: allowedPressTypes
    
    @discardableResult
    public func allowedPressTypes(_ values: [NSNumber]) -> Self {
        guard let s = self as? _GestureRecognizerable else { return self }
        s._setAllowedPressTypes(values)
        return self
    }
    
    // MARK: debugName

    @discardableResult
    public func debugName(_ value: String) -> Self {
        guard let s = self as? _GestureRecognizerable else { return self }
        s._setName(value)
        return self
    }
    #endif
    
    // MARK: require toFail
    
    @discardableResult
    public func require(toFail otherGestureRecognizer: UGestureRecognizer) -> Self {
        guard let s = self as? _GestureRecognizerable else { return self }
        s._setRequireToFailOtherGestureRecognizer(otherGestureRecognizer)
        return self
    }
}

// for iOS lower than 13
extension _GestureRecognizerable {
    @discardableResult
    public func delegate(_ v: UGestureRecognizerDelegate) -> Self {
        _setDelegate(v)
        return self
    }
    
    // MARK: enabled
    
    @discardableResult
    public func enabled(_ value: Bool) -> Self {
        _setEnabled(value)
        return self
    }
    
    @discardableResult
    public func enabled() -> Self {
        enabled(true)
    }
    
    @discardableResult
    public func enabled(_ binding: Ultra.State<Bool>) -> Self {
        let listener = binding.listen { [weak self] in
            self?.enabled($0)
        }
        _holdGestureBindingListenerIfPossible(listener)
        return enabled(binding.wrappedValue)
    }
    
    #if !os(macOS)
    // MARK: cancelsTouchesInView
    
    @discardableResult
    public func cancelsTouchesInView(_ value: Bool) -> Self {
        _setCancelsTouchesInView(value)
        return self
    }
    
    @discardableResult
    public func cancelsTouchesInView() -> Self {
        cancelsTouchesInView(true)
    }
    
    @discardableResult
    public func cancelsTouchesInView(_ binding: Ultra.State<Bool>) -> Self {
        let listener = binding.listen { [weak self] in
            self?.cancelsTouchesInView($0)
        }
        _holdGestureBindingListenerIfPossible(listener)
        return cancelsTouchesInView(binding.wrappedValue)
    }
    
    // MARK: delaysTouchesBegan
    
    @discardableResult
    public func delaysTouchesBegan(_ value: Bool) -> Self {
        _setDelaysTouchesBegan(value)
        return self
    }
    
    @discardableResult
    public func delaysTouchesBegan() -> Self {
        delaysTouchesBegan(true)
    }
    
    @discardableResult
    public func delaysTouchesBegan(_ binding: Ultra.State<Bool>) -> Self {
        let listener = binding.listen { [weak self] in
            self?.delaysTouchesBegan($0)
        }
        _holdGestureBindingListenerIfPossible(listener)
        return delaysTouchesBegan(binding.wrappedValue)
    }
    
    // MARK: delaysTouchesEnded
    
    @discardableResult
    public func delaysTouchesEnded(_ value: Bool) -> Self {
        _setDelaysTouchesEnded(value)
        return self
    }
    
    @discardableResult
    public func delaysTouchesEnded() -> Self {
        delaysTouchesEnded(true)
    }
    
    @discardableResult
    public func delaysTouchesEnded(_ binding: Ultra.State<Bool>) -> Self {
        let listener = binding.listen { [weak self] in
            self?.delaysTouchesEnded($0)
        }
        _holdGestureBindingListenerIfPossible(listener)
        return delaysTouchesEnded(binding.wrappedValue)
    }
    
    // MARK: requiresExclusiveTouchType
    
    @discardableResult
    public func requiresExclusiveTouchType(_ value: Bool) -> Self {
        _setRequiresExclusiveTouchType(value)
        return self
    }
    
    @discardableResult
    public func requiresExclusiveTouchType() -> Self {
        requiresExclusiveTouchType(true)
    }
    
    @discardableResult
    public func requiresExclusiveTouchType(_ binding: Ultra.State<Bool>) -> Self {
        let listener = binding.listen { [weak self] in
            self?.requiresExclusiveTouchType($0)
        }
        _holdGestureBindingListenerIfPossible(listener)
        return requiresExclusiveTouchType(binding.wrappedValue)
    }
    
    // MARK: allowedTouchTypes
    
    @discardableResult
    public func allowedTouchTypes(_ values: [NSNumber]) -> Self {
        _setAllowedTouchTypes(values)
        return self
    }
    
    @discardableResult
    public func allowedTouchTypes(_ values: NSNumber...) -> Self {
        allowedTouchTypes(values)
    }

    @discardableResult
    public func allowedPressTypes(_ values: NSNumber...) -> Self {
        allowedPressTypes(values)
    }
    
    // MARK: allowedPressTypes
    
    @discardableResult
    public func allowedPressTypes(_ values: [NSNumber]) -> Self {
        _setAllowedPressTypes(values)
        return self
    }
    
    // MARK: debugName

    @discardableResult
    public func debugName(_ value: String) -> Self {
        _setName(value)
        return self
    }
    #endif
    
    // MARK: require toFail
    
    @discardableResult
    public func require(toFail otherGestureRecognizer: UGestureRecognizer) -> Self {
        _setRequireToFailOtherGestureRecognizer(otherGestureRecognizer)
        return self
    }
}
#endif
