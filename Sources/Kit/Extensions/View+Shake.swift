#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit

extension NSLayoutConstraint {
    public typealias Axis = Orientation
}
#else
import UIKit
#endif

extension BaseView {
    public func shake(values: [CGFloat] = [-20, 20, -20, 20, -10, 10, -5, 5, 0],
                      duration: CFTimeInterval = 0.6,
                      axis: NSLayoutConstraint.Axis = .horizontal,
                      timing: CAMediaTimingFunctionName = .linear) {
        let animation = CAKeyframeAnimation(keyPath: axis == .horizontal ? "transform.translation.x" : "transform.translation.y")
        animation.timingFunction = CAMediaTimingFunction(name: timing)
        animation.duration = duration
        animation.values = values
        #if os(macOS)
        wantsLayer = true
        layer?.add(animation, forKey: "shake")
        #else
        layer.add(animation, forKey: "shake")
        #endif
    }
    
    public func shake(_ values: CGFloat...,
                      duration: CFTimeInterval = 0.6,
                      axis: NSLayoutConstraint.Axis = .horizontal,
                      timing: CAMediaTimingFunctionName = .linear) {
        shake(values: values, duration: duration, axis: axis, timing: timing)
    }
}

#if os(macOS)
extension NSWindow {
    public func shake(numberOfShakes: Int = 4, intensity: CGFloat = 0.05, duration: Double = 0.6){
        let frame: CGRect = self.frame
        let shakeAnimation: CAKeyframeAnimation = CAKeyframeAnimation()

        let shakePath = CGMutablePath()
        shakePath.move(to: CGPoint(x: NSMinX(frame), y: NSMinY(frame)))

        (0...numberOfShakes - 1).forEach { _ in
            shakePath.addLine(to: CGPoint(x: NSMinX(frame) - frame.size.width * intensity, y: NSMinY(frame)))
            shakePath.addLine(to: CGPoint(x: NSMinX(frame) + frame.size.width * intensity, y: NSMinY(frame)))
        }

        shakePath.closeSubpath()
        shakeAnimation.path = shakePath
        shakeAnimation.duration = duration

        self.animations = ["frameOrigin":shakeAnimation]
        self.animator().setFrameOrigin(self.frame.origin)
    }
}
#endif
#endif
