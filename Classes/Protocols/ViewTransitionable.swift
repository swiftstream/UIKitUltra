#if !os(macOS)
import UIKit

@MainActor
protocol _ViewTransitionable {
    var _transitionableView: UIView { get }
    
    func _transition(_ duration: TimeInterval, _ options: UIView.AnimationOptions, animations: @escaping () -> Void)
    func _transition(_ duration: TimeInterval, _ options: UIView.AnimationOptions, animations: @escaping () -> Void, completion: (@escaping (Bool) -> Void))
}

extension _ViewTransitionable {
    func _transition(_ duration: TimeInterval, _ options: UIView.AnimationOptions, animations: @escaping () -> Void, completion: (@escaping (Bool) -> Void)) {
        UIView.transition(with: _transitionableView, duration: duration, options: options, animations: animations, completion: completion)
    }
    
    func _transition(_ duration: TimeInterval, _ options: UIView.AnimationOptions, animations: @escaping () -> Void) {
        _transition(duration, options, animations: animations) { _ in }
    }
}
#endif
