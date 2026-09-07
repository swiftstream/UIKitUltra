#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit

public typealias UGestureRecognizer = NSGestureRecognizer
public typealias UGestureRecognizerDelegate = NSGestureRecognizerDelegate
#else
import UIKit

public typealias UGestureRecognizer = UIGestureRecognizer
public typealias UGestureRecognizerDelegate = UIGestureRecognizerDelegate
#endif

extension UGestureRecognizer: _GestureRecognizerable {
    func _setDelegate(_ v: UGestureRecognizerDelegate) {
        delegate = v
    }
    
    func _setEnabled(_ v: Bool) {
        isEnabled = v
    }
    
    #if !os(macOS)
    func _setCancelsTouchesInView(_ v: Bool) {
        cancelsTouchesInView = v
    }
    
    func _setDelaysTouchesBegan(_ v: Bool) {
        delaysTouchesBegan = v
    }
    
    func _setDelaysTouchesEnded(_ v: Bool) {
        delaysTouchesEnded = v
    }
    
    func _setName(_ v: String) {
        if #available(iOS 11.0, *) {
            name = v
        }
    }
    
    func _setRequiresExclusiveTouchType(_ v: Bool) {
        if #available(iOS 9.2, *) {
            requiresExclusiveTouchType = v
        }
    }
    
    func _setAllowedTouchTypes(_ v: [NSNumber]) {
        allowedTouchTypes = v
    }
    
    func _setAllowedPressTypes(_ v: [NSNumber]) {
        allowedPressTypes = v
    }
    #endif
    
    func _setRequireToFailOtherGestureRecognizer(_ v: UGestureRecognizer) {
        require(toFail: v)
    }
}
#endif
