#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

class _GestureDelegator: NSObject {
    weak var _outerDelegate: UGestureRecognizerDelegate?
    
    var _shouldBegin: (() -> Bool)?
    
    #if os(macOS)
    var _shouldAttemptToRecognizeWithEvent: ((NSEvent) -> Bool)?
    var _shouldReceiveTouch: ((NSTouch) -> Bool)?
    #else
    var _shouldReceivePress: ((UIPress) -> Bool)?
    var _shouldReceiveTouch: ((UITouch) -> Bool)?
    #endif
    
    var _shouldRequireFailureOfOtherGestureRecognizer: ((UGestureRecognizer) -> Bool)?
    var _shouldBeRequiredToFailByOtherGestureRecognizer: ((UGestureRecognizer) -> Bool)?
    var _shouldRecognizeSimultaneouslyWithOtherGestureRecognizer: ((UGestureRecognizer) -> Bool)?
}

extension _GestureDelegator: UGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UGestureRecognizer) -> Bool {
        _shouldBegin?() ?? _outerDelegate?.gestureRecognizerShouldBegin?(gestureRecognizer) ?? true
    }
    
    #if os(macOS)
    public func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
        _shouldAttemptToRecognizeWithEvent?(event)
            ?? _outerDelegate?.gestureRecognizer?(gestureRecognizer, shouldAttemptToRecognizeWith: event)
            ?? true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldReceive touch: NSTouch) -> Bool {
        _shouldReceiveTouch?(touch)
            ?? _outerDelegate?.gestureRecognizer?(gestureRecognizer, shouldReceive: touch)
            ?? true
    }
    #else
    public func gestureRecognizer(_ gestureRecognizer: UGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        _shouldReceivePress?(press)
            ?? _outerDelegate?.gestureRecognizer?(gestureRecognizer, shouldReceive: press)
            ?? true
    }

    public func gestureRecognizer(_ gestureRecognizer: UGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        _shouldReceiveTouch?(touch)
            ?? _outerDelegate?.gestureRecognizer?(gestureRecognizer, shouldReceive: touch)
            ?? true
    }
    #endif

    public func gestureRecognizer(_ gestureRecognizer: UGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UGestureRecognizer) -> Bool {
        _shouldRequireFailureOfOtherGestureRecognizer?(otherGestureRecognizer)
            ?? _outerDelegate?.gestureRecognizer?(gestureRecognizer, shouldRequireFailureOf: otherGestureRecognizer)
            ?? false
    }

    public func gestureRecognizer(_ gestureRecognizer: UGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UGestureRecognizer) -> Bool {
        _shouldBeRequiredToFailByOtherGestureRecognizer?(otherGestureRecognizer)
            ?? _outerDelegate?.gestureRecognizer?(gestureRecognizer, shouldBeRequiredToFailBy: otherGestureRecognizer)
            ?? false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UGestureRecognizer) -> Bool {
        _shouldRecognizeSimultaneouslyWithOtherGestureRecognizer?(otherGestureRecognizer)
            ?? _outerDelegate?.gestureRecognizer?(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer)
            ?? false
    }
}
#endif
