#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

extension UINavigationController {
    public func pushViewControllerAnimated(_ viewController: UIViewController, animation: CATransitionType = .fade, duration: CFTimeInterval = 0.3) {
        let transition: CATransition = CATransition()
        transition.duration = duration
        transition.type = animation
        view.layer.add(transition, forKey: nil)
        pushViewController(viewController, animated: false)
    }
    
    public func popViewControllerAnimated(animation: CATransitionType = .fade, duration: CFTimeInterval = 0.3) {
        let transition: CATransition = CATransition()
        transition.duration = duration
        transition.type = animation
        view.layer.add(transition, forKey: nil)
        popViewController(animated: false)
    }
}
#endif
#endif
