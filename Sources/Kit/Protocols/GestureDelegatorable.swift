#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public protocol GestureDelegatorable: AnyObject {}

@MainActor
protocol _GestureDelegatorable: GestureDelegatorable {
    var _delegator: _GestureDelegator { get set }
}

@MainActor
extension GestureDelegatorable {
    @discardableResult
    public func delegate(_ object: UGestureRecognizerDelegate) -> Self {
        guard let s = self as? _GestureDelegatorable else { return self }
        s._delegator._outerDelegate = object
        return self
    }
    
    // MARK: Should Begin
    
    @discardableResult
    public func shouldBegin(_ action: @escaping () -> Bool) -> Self {
        shouldBegin { _ in action() }
    }
    
    @discardableResult
    public func shouldBegin(_ action: @escaping (Self) -> Bool) -> Self {
        guard let s = self as? _GestureDelegatorable else { return self }
        s._delegator._shouldBegin = { [weak self] in
            guard let self = self else { return false }
            return action(self)
        }
        return self
    }
    
    #if os(macOS)
    // MARK: Should Attempt Recognize With Event
    
    @discardableResult
    public func shouldAttemptToRecognizeWithEvent(_ action: @escaping () -> Bool) -> Self {
        guard let s = self as? _GestureDelegatorable else { return self }
        s._delegator._shouldAttemptToRecognizeWithEvent = { _ in
            action()
        }
        return self
    }
    
    @discardableResult
    public func shouldAttemptToRecognizeWithEvent(_ action: @escaping (NSEvent) -> Bool) -> Self {
        guard let s = self as? _GestureDelegatorable else { return self }
        s._delegator._shouldAttemptToRecognizeWithEvent = { e in
            action(e)
        }
        return self
    }
    
    @discardableResult
    public func shouldAttemptToRecognizeWithEvent(_ action: @escaping (Self, NSEvent) -> Bool) -> Self {
        guard let s = self as? _GestureDelegatorable else { return self }
        s._delegator._shouldAttemptToRecognizeWithEvent = { [weak self] e in
            guard let self = self else { return false }
            return action(self, e)
        }
        return self
    }
    
    // MARK: Should Receive Touch
    
    @discardableResult
    public func shouldReceiveTouch(_ action: @escaping () -> Bool) -> Self {
        shouldReceiveTouch { _,_ in
            action()
        }
    }
    
    @discardableResult
    public func shouldReceiveTouch(_ action: @escaping (NSTouch) -> Bool) -> Self {
        shouldReceiveTouch { _, t in
            action(t)
        }
    }
    
    @discardableResult
    public func shouldReceiveTouch(_ action: @escaping (Self, NSTouch) -> Bool) -> Self {
        guard let s = self as? _GestureDelegatorable else { return self }
        s._delegator._shouldReceiveTouch = { [weak self] t in
            guard let self = self else { return false }
            return action(self, t)
        }
        return self
    }
    #else
    // MARK: Should Receive Press
    
    @discardableResult
    public func shouldReceivePress(_ action: @escaping () -> Bool) -> Self {
        shouldReceivePress { _,_ in
            action()
        }
    }
    
    @discardableResult
    public func shouldReceivePress(_ action: @escaping (UIPress) -> Bool) -> Self {
        shouldReceivePress { _, p in
            action(p)
        }
    }
    
    @discardableResult
    public func shouldReceivePress(_ action: @escaping (Self, UIPress) -> Bool) -> Self {
        guard let s = self as? _GestureDelegatorable else { return self }
        s._delegator._shouldReceivePress = { [weak self] p in
            guard let self = self else { return false }
            return action(self, p)
        }
        return self
    }
    
    // MARK: Should Receive Touch
    
    @discardableResult
    public func shouldReceiveTouch(_ action: @escaping () -> Bool) -> Self {
        shouldReceiveTouch { _,_ in
            action()
        }
    }
    
    @discardableResult
    public func shouldReceiveTouch(_ action: @escaping (UITouch) -> Bool) -> Self {
        shouldReceiveTouch { _, t in
            action(t)
        }
    }
    
    @discardableResult
    public func shouldReceiveTouch(_ action: @escaping (Self, UITouch) -> Bool) -> Self {
        guard let s = self as? _GestureDelegatorable else { return self }
        s._delegator._shouldReceiveTouch = { [weak self] t in
            guard let self = self else { return false }
            return action(self, t)
        }
        return self
    }
    #endif
    
    
    // MARK: Should Require Failure Of Other Gesture Recognizer
    
    @discardableResult
    public func shouldRequireFailureOfOtherGestureRecognizer(_ action: @escaping () -> Bool) -> Self {
        shouldRequireFailureOfOtherGestureRecognizer { _,_ in
            action()
        }
    }
    
    @discardableResult
    public func shouldRequireFailureOfOtherGestureRecognizer(_ action: @escaping (UGestureRecognizer) -> Bool) -> Self {
        shouldRequireFailureOfOtherGestureRecognizer { _, o in
            action(o)
        }
    }
    
    @discardableResult
    public func shouldRequireFailureOfOtherGestureRecognizer(_ action: @escaping (Self, UGestureRecognizer) -> Bool) -> Self {
        guard let s = self as? _GestureDelegatorable else { return self }
        s._delegator._shouldRequireFailureOfOtherGestureRecognizer = { [weak self] o in
            guard let self = self else { return false }
            return action(self, o)
        }
        return self
    }
    
    // MARK: Should Be Required To Fail By Other Gesture Recognizer
    
    @discardableResult
    public func shouldBeRequiredToFailByOtherGestureRecognizer(_ action: @escaping () -> Bool) -> Self {
        shouldBeRequiredToFailByOtherGestureRecognizer { _,_ in
            action()
        }
    }
    
    @discardableResult
    public func shouldBeRequiredToFailByOtherGestureRecognizer(_ action: @escaping (UGestureRecognizer) -> Bool) -> Self {
        shouldBeRequiredToFailByOtherGestureRecognizer { _, o in
            action(o)
        }
    }
    
    @discardableResult
    public func shouldBeRequiredToFailByOtherGestureRecognizer(_ action: @escaping (Self, UGestureRecognizer) -> Bool) -> Self {
        guard let s = self as? _GestureDelegatorable else { return self }
        s._delegator._shouldBeRequiredToFailByOtherGestureRecognizer = { [weak self] o in
            guard let self = self else { return false }
            return action(self, o)
        }
        return self
    }
    
    // MARK: Should Recognize Simultaneously With Other Gesture Recognizer
    
    @discardableResult
    public func shouldRecognizeSimultaneouslyWithOtherGestureRecognizer(_ action: @escaping () -> Bool) -> Self {
        shouldRecognizeSimultaneouslyWithOtherGestureRecognizer { _,_ in
            action()
        }
    }
    
    @discardableResult
    public func shouldRecognizeSimultaneouslyWithOtherGestureRecognizer(_ action: @escaping (UGestureRecognizer) -> Bool) -> Self {
        shouldRecognizeSimultaneouslyWithOtherGestureRecognizer { _, o in
            action(o)
        }
    }
    
    @discardableResult
    public func shouldRecognizeSimultaneouslyWithOtherGestureRecognizer(_ action: @escaping (Self, UGestureRecognizer) -> Bool) -> Self {
        guard let s = self as? _GestureDelegatorable else { return self }
        s._delegator._shouldRecognizeSimultaneouslyWithOtherGestureRecognizer = { [weak self] o in
            guard let self = self else { return false }
            return action(self, o)
        }
        return self
    }
}
#endif
