//
//  MacOS+NavigationController.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 28.08.2020.
//

#if os(macOS)
import AppKit

@MainActor
public class NavigationController: ViewController {
    public private (set) var viewControllers: [ViewController] = []
    
    public let rootViewController: ViewController
    
    var transitionInProgress = false
    var touchPanHandler: TouchPanHandler?
    
    @MainActor
    public init(rootViewController: ViewController) {
        self.rootViewController = rootViewController
        super.init(nibName: nil, bundle: nil)
        view.body {
            (rootViewController.view as! UView).edgesToSuperview()
        }
        rootViewController.navigationController = self
        (view as? UView)?.onTouchPanGesture { s, p, d in
            switch s {
            case .began:
                if self.viewControllers.count > 0 {
                    guard self.transitionInProgress == false else { return }
                    self.transitionInProgress = true
                    self.touchPanHandler = .init(p, nav: self)
                }
            case .changed:
                self.touchPanHandler?.changed(to: p)
            case .ended:
                self.touchPanHandler?.ended(at: p)
                self.touchPanHandler = nil
            case .swiped:
                self.touchPanHandler?.swiped(to: p, delta: d)
                self.touchPanHandler = nil
            case .cancelled:
                self.touchPanHandler?.cancelled()
                self.touchPanHandler = nil
            }
        }
   }

    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Touch Pan
    
    @MainActor
    class TouchPanHandler {
        let beganPoint: CGPoint
        let nav: NavigationController
        let currentVC, previousVC: ViewController
        let width: CGFloat
        let endFrame: CGRect
        
        @MainActor
        init (_ beganPoint: CGPoint, nav: NavigationController) {
            self.beganPoint = beganPoint
            self.nav = nav
            currentVC = nav.viewControllers.popLast()!
            previousVC = nav.viewControllers.last ?? nav.rootViewController
            width = currentVC.view.frame.width
            endFrame = currentVC.view.frame.offsetBy(dx: width, dy: 0)
            (previousVC.view as! UView).edgesToSuperview()
            nav.view.addSubview(previousVC.view, positioned: .below, relativeTo: currentVC.view)
        }
        
        var destinationHasBeenReached = false
        
        func changed(to point: CGPoint) {
            guard point.x >= 0 else {
                destinationHasBeenReached = false
                return
            }
            guard point.x <= endFrame.width else {
                destinationHasBeenReached = true
                return
            }
            destinationHasBeenReached = point.x == endFrame.width
            previousVC.view.bounds.origin.x = width * 0.2 - (point.x  * 0.2)
            currentVC.view.bounds.origin.x = -point.x
        }
        
        func ended(at point: CGPoint) {
            guard !destinationHasBeenReached else {
                nav.unembedChildViewController(currentVC)
                
                return
            }
            // check if point far enough to proceed or rollback
            _end(with: point)
        }
        
        func swiped(to point: CGPoint, delta: CGPoint) {
            guard !destinationHasBeenReached else {
                nav.unembedChildViewController(currentVC)
                nav.transitionInProgress = false
                return
            }
            // check which way we're swiping and animate proceed or rollback this way
            if delta.x >= 0 {
                _end(with: point)
            } else {
                // if in the last moment swipe was backward then we should rollback
                _rollback()
            }
        }
        
        func cancelled() {
            _rollback()
        }
        
        func _end(with point: CGPoint) {
            let xDiff = point.x - beganPoint.x
            if xDiff < width * 0.3 {
                // rollback
                _rollback()
            } else {
                // proceed
                _proceed()
            }
        }
        
        func _rollback() {
            nav.viewControllers.append(currentVC)
            NSAnimationContext.runAnimationGroup({ context in
               context.duration = 0.3
               context.allowsImplicitAnimation = true
               context.timingFunction = .init(name: CAMediaTimingFunctionName.easeOut)
               previousVC.view.animator().bounds.origin.x = width * 0.2
               currentVC.view.animator().bounds.origin.x = 0
            }) {
                DispatchQueue.main.async {
                    self.nav.transitionInProgress = false
                    self.previousVC.view.removeFromSuperview()
                }
            }
        }
        
        func _proceed() {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                context.timingFunction = .init(name: .easeIn)
                currentVC.view.animator().bounds.origin.x = -endFrame.width
                previousVC.view.animator().bounds.origin.x = 0
            }) {
                DispatchQueue.main.async {
                    self.nav.transitionInProgress = false
                    self.nav.unembedChildViewController(self.currentVC)
                }
            }
        }
    }
}

// MARK: - Push

extension NavigationController {
    @MainActor
    public func pushViewController(_ viewController: ViewController) {
      pushViewController(viewController, animated: true)
   }

    @MainActor
    public func pushViewController(_ viewController: ViewController, animated: Bool) {
        viewController.navigationController = self
        viewController.view.wantsLayer = true
        let oldVC = viewControllers.last ?? rootViewController
        addChild(viewController)
        view.addSubview((viewController.view as! UView).edgesToSuperview(), positioned: .above, relativeTo: oldVC.view)
        viewControllers.append(viewController)
        guard animated else { return }
        let endFrame = oldVC.view.frame
        let startFrame = endFrame.offsetBy(dx: endFrame.width, dy: 0)
        viewController.view.frame = startFrame
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            context.timingFunction = .init(name: CAMediaTimingFunctionName.easeOut)
            oldVC.view.animator().bounds.origin.x = endFrame.width * 0.5
            viewController.view.animator().frame = endFrame
         }) {
            DispatchQueue.main.async {
                oldVC.view.removeFromSuperview()
            }
         }
    }
}

// MARK: - Pop

extension NavigationController {
    @discardableResult
    public func popViewController() {
        popViewController(animated: true)
    }

    @discardableResult
    @MainActor
    public func popViewController(animated: Bool) {
        guard let currentVC = viewControllers.popLast() else {
            return
        }
        let previousVC = viewControllers.last ?? rootViewController
        guard animated else {
            (previousVC.view as! UView).edgesToSuperview()
            view.addSubview(previousVC.view, positioned: .below, relativeTo: currentVC.view)
            previousVC.view.bounds.origin.x = 0
            unembedChildViewController(currentVC)
            return
        }
        let endFrame = currentVC.view.frame.offsetBy(dx: currentVC.view.frame.width, dy: 0)
        (previousVC.view as! UView).edgesToSuperview()
        view.addSubview(previousVC.view, positioned: .below, relativeTo: currentVC.view)
        previousVC.view.bounds.origin.x = currentVC.view.frame.width * 0.2
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            context.timingFunction = .init(name: .easeIn)
            currentVC.view.animator().bounds.origin.x = -endFrame.width
            previousVC.view.animator().bounds.origin.x = 0
        }) {
            DispatchQueue.main.async {
                self.unembedChildViewController(currentVC)
                self.transitionInProgress = false
            }
        }
        return
    }
}

extension NSViewController {
    @MainActor
    func embedChildViewController(_ vc: ViewController) {
        addChild(vc)
        view.addSubview((vc.view as! UView).edgesToSuperview(), positioned: .below, relativeTo: nil)
    }
    
    func unembedChildViewController(_ vc: NSViewController) {
        vc.view.removeFromSuperview()
        vc.removeFromParent()
    }
}
#endif
