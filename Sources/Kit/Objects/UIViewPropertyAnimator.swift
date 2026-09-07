#if os(macOS) || os(iOS) || os(tvOS)
////
////  UIViewPropertyAnimator.swift
////  UIKit-Plus
////
////  Created by Mihael Isaev on 03.03.2020.
////
//
//import UIKit
//
//@available(iOS 10.0, *)
//extension UIViewPropertyAnimator {
//    public func delay(_ value: TimeInterval) -> Self {
//        delay = value
//        return self
//    }
//
//    
//    /// Defaults to 0. This property is set when calling -[UIView startAnimationAfterDelay:].
//    open var delay: TimeInterval { get }
//
//    
//    /// Defaults to YES. Raises if set on an active animator.
//    open var isUserInteractionEnabled: Bool
//
//    
//    /// Defaults to NO. Set if you need to manage the the hittesting of animating view hierarchies
//    open var isManualHitTestingEnabled: Bool
//
//    
//    /// Defaults to YES. Raises if set on an active animator.
//    open var isInterruptible: Bool
//
//    
//    /// Defaults to YES. Provides the ability for an animator to pause and scrub either linearly or using the animator’s current timing.
//    @available(iOS 11.0, *)
//    open var scrubsLinearly: Bool
//
//    
//    /// Defaults to NO. Provides the ability for an animator to pause on completion instead of transitioning to the .inactive state.
//    @available(iOS 11.0, *)
//    open var pausesOnCompletion: Bool
//}
#endif
