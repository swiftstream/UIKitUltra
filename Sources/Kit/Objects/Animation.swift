#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

open class Animation {
    public init() {
//        UIViewPropertyAnimator()
    }
    
    @discardableResult
    public func delay(_ delay: Double) -> Self {
        
        return self
    }
    
    /// Returns an animation that has its speed multiplied by `speed`. For
    /// example, if you had `oneSecondAnimation.speed(0.25)`, it would be at
    /// 25% of its normal speed, so you would have an animation that would last
    /// 4 seconds.
    public func speed(_ speed: Double) -> Self {
           
       return self
   }
    
    public func repeatCount(_ repeatCount: Int, autoreverses: Bool = true) -> Self {
        
        return self
    }

    public func repeatForever(autoreverses: Bool = true) -> Self {
        
        return self
    }
}

extension Animation {
    public static var `default`: Animation { .init() }
    public static func easeInOut(duration: Double) -> Animation {
        return .init()
    }

    public static var easeInOut: Animation { .init() }

    public static func easeIn(duration: Double) -> Animation {
        return .init()
    }

    public static var easeIn: Animation { .init() }

    public static func easeOut(duration: Double) -> Animation {
        return .init()
    }

    public static var easeOut: Animation { .init() }

    public static func linear(duration: Double) -> Animation {
           return .init()
       }

    public static var linear: Animation { .init() }

    public static func timingCurve(_ c0x: Double, _ c0y: Double, _ c1x: Double, _ c1y: Double, duration: Double = 0.35) -> Animation {
        return .init()
    }
    
    /// An interpolating spring animation that uses a damped spring
    /// model to produce values in the range [0, 1] that are then used
    /// to interpolate within the [from, to] range of the animated
    /// property. Preserves velocity across overlapping animations by
    /// adding the effects of each animation.
    ///
    /// - Parameters:
    ///   - mass: The mass of the object attached to the spring.
    ///   - stiffness: The stiffness of the spring.
    ///   - damping: The spring damping value.
    ///   - initialVelocity: the initial velocity of the spring, as
    ///     a value in the range [0, 1] representing the magnitude of
    ///     the value being animated.
    /// - Returns: a spring animation.
    public static func interpolatingSpring(mass: Double = 1.0, stiffness: Double, damping: Double, initialVelocity: Double = 0.0) -> Animation {
        return .init()
    }
    
    /// A persistent spring animation. When mixed with other `spring()`
    /// or `interactiveSpring()` animations on the same property, each
    /// animation will be replaced by their successor, preserving
    /// velocity from one animation to the next. Optionally blends the
    /// response values between springs over a time period.
    ///
    /// - Parameters:
    ///   - response: The stiffness of the spring, defined as an
    ///     approximate duration in seconds. A value of zero requests
    ///     an infinitely-stiff spring, suitable for driving
    ///     interactive animations.
    ///   - dampingFraction: The amount of drag applied to the value
    ///     being animated, as a fraction of an estimate of amount
    ///     needed to produce critical damping.
    ///   - blendDuration: The duration in seconds over which to
    ///     interpolate changes to the response value of the spring.
    /// - Returns: a spring animation.
    public static func spring(response: Double = 0.55, dampingFraction: Double = 0.825, blendDuration: Double = 0) -> Animation {
        
        return .init()
    }

    /// A convenience for a `spring()` animation with a lower
    /// `response` value, intended for driving interactive animations.
    public static func interactiveSpring(response: Double = 0.15, dampingFraction: Double = 0.86, blendDuration: Double = 0.25) -> Animation {
        
        return .init()
    }
}
#endif
