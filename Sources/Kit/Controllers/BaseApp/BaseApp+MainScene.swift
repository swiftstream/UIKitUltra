#if os(macOS) || os(iOS) || os(tvOS)
//
//  BaseApp+MainScene.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 11.09.2020.
//

#if !os(macOS)
import UIKit
import UIKitPlusCore

extension UIViewController {
    public func attach(to window: UIWindow?) {
        window?.rootViewController = self
        window?.makeKeyAndVisible()
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    public func attach(to scene: UIScene) -> UIWindow? {
        guard let windowScene = scene as? UIWindowScene else { return nil }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = self
        window.makeKeyAndVisible()
        return window
    }
}

extension BaseApp {
    /// Returns safe insets of the mainScene's window
    public static var safeInsets: UIEdgeInsets { mainScene.safeInsets }
    
    /// Returns safe insets of the mainScene's window
    public var safeInsets: UIEdgeInsets { mainScene.safeInsets }
    
    public typealias RootSimpleCompletion = () -> Void
    public typealias RootBeforeTransition = (UIViewController) -> Void
    
    public class MainScene: _AnyScene, AppBuilderContent {
        public var appBuilderContent: AppBuilderItem { .mainScene(self) }
        
        public var persistentIdentifier: String = UUID().uuidString
        public var stateRestorationActivity: NSUserActivity?
        public var userInfo: [String : Any]?
        
        /// Link closure to the wndow
        var _windowRetriever: () -> UIWindow = { UIWindow() }
        
        /// Returns the window
        public var window: UIWindow { _windowRetriever() }
        
        /// Link closure to safe insets of the wndow
        var _safeInsetsRetriever: () -> UIEdgeInsets = { .zero }
        
        /// Returns safe insets of the window
        public var safeInsets: UIEdgeInsets { _safeInsetsRetriever() }
        
        var _onConnect: ((UIWindow?) -> Void)?
        var _onDisconnect: ((UIWindow?) -> Void)?
        var _onDestroy: ((UIWindow?) -> Void)?
        var _onBecomeActive: ((UIWindow?) -> Void)?
        var _onWillResignActive: ((UIWindow?) -> Void)?
        var _onWillEnterForeground: ((UIWindow?) -> Void)?
        var _onDidEnterBackground: ((UIWindow?) -> Void)?
        
        class MainSceneViewController: ViewController {
            #if !os(tvOS)
            open override var preferredStatusBarStyle: UIStatusBarStyle { currentHandler().preferredStatusBarStyle }
            #endif
            
            let currentHandler: () -> UIViewController
            
            init (_ handler: @escaping () -> UIViewController) {
                currentHandler = handler
                super.init()
            }
            
            public required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
        
        public lazy var viewController: ViewController = MainSceneViewController { self.current }
        
        @UState public internal(set) var currentScreen: SceneScreenType = .splash
        public internal(set) lazy var current: UIViewController = NotImplementedViewController("nothing")
        
        var _showOnboardingBeforeMainScreen = false
        
        var screens: [SceneScreenType: () -> UIViewController] = [:] // NotImplementedViewController("splashScreen")
        
        /// By default shows `splashScreen`
        public init (_ initialScreen: SceneScreenType = .splash) {
            currentScreen = initialScreen
        }
        
        public init (_ handler: () -> SceneScreenType) {
            currentScreen = handler()
        }
        
        public init (_ viewController: UIViewController) {
            let type: SceneScreenType = "custom"
            currentScreen = type
            screens[type] = { viewController }
        }
        
        public init (_ handler: @escaping () -> UIViewController) {
            let type: SceneScreenType = "custom"
            currentScreen = type
            screens[type] = handler
        }
        
        /// should be called from BaseApp on didFinishLaunching
        func initialize() {
            current = screens[currentScreen]?() ?? NotImplementedViewController(currentScreen.description)
            viewController.addChild(current)
            current.view.frame = viewController.view.bounds
            viewController.view.body { current.view }
            current.didMove(toParent: viewController)
        }
        
        public func splashScreen(_ handler: @escaping () -> UIViewController) -> Self {
            screens[.splash] = handler
            return self
        }
        
        public func loginScreen(_ handler: @escaping () -> UIViewController) -> Self {
            screens[.login] = handler
            return self
        }
        
        public func logoutScreen(_ handler: @escaping () -> UIViewController) -> Self {
            screens[.logout] = handler
            return self
        }
        
        public func mainScreen(_ handler: @escaping () -> UIViewController) -> Self {
            screens[.main] = handler
            return self
        }
        
        public func onboardingScreen(_ handler: @escaping () -> UIViewController) -> Self {
            screens[.onboarding] = handler
            return self
        }
        
        public func custom(_ type: SceneScreenType, _ handler: @escaping () -> UIViewController) -> Self {
            screens[type] = handler
            return self
        }
        
        public func showOnboardingBeforeMainScreen() -> Self {
            _showOnboardingBeforeMainScreen = true
            return self
        }
        
        open func `switch`(to type: SceneScreenType, animation: RootTransitionAnimation, beforeTransition: RootBeforeTransition? = nil, completion: RootSimpleCompletion? = nil) {
            if currentScreen == type {
                print("⚠️ Don't show \(type) twice")
                return
            }
            guard let vc = nextViewController(for: type) else { return }
            if _showOnboardingBeforeMainScreen, screens[.onboarding] != nil {
                `switch`(to: .onboarding, animation: animation, beforeTransition: beforeTransition, completion: completion)
                return
            }
            currentScreen = type
            beforeTransition?(vc)
            switch animation {
            case .none:
                replaceWithoutAnimation(screens[.login]?() ?? NotImplementedViewController(SceneScreenType.login.description))
//                proceedDeeplink()
                completion?()
            case .dismiss:
                animateDismissTransition(to: vc) { [weak self] in
                    if type == .logout {
                        self?.currentScreen = .login
                    }
//                    self?.proceedDeeplink()
                    completion?()
                }
            case .fade:
                animateFadeTransition(to: vc) { [weak self] in
                    if type == .logout {
                        self?.currentScreen = .login
                    }
//                    self?.proceedDeeplink()
                    completion?()
                }
            }
        }
        
        public func `switch`(to: UIViewController, as: SceneScreenType, animation: RootTransitionAnimation, beforeTransition: RootBeforeTransition? = nil, completion: RootSimpleCompletion? = nil) {
            currentScreen = `as`
            switch animation {
            case .none:
                beforeTransition?(to)
                replaceWithoutAnimation(to)
//                proceedDeeplink()
                completion?()
            case .dismiss:
                beforeTransition?(to)
                animateDismissTransition(to: to) {
//                    self.proceedDeeplink()
                    completion?()
                }
            case .fade:
                beforeTransition?(to)
                animateFadeTransition(to: to) {
//                    self.proceedDeeplink()
                    completion?()
                }
            }
        }
        
        private func replaceWithoutAnimation(_ new: UIViewController) {
            viewController.addChild(new)
            new.view.frame = viewController.view.bounds
            viewController.view.addSubview(new.view)
            new.didMove(toParent: viewController)

            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()

            current = new
            #if !os(tvOS)
            viewController.setNeedsStatusBarAppearanceUpdate()
            #endif
        }
        
        private func animateFadeTransition(to new: UIViewController, completion: RootSimpleCompletion? = nil) {
            current.willMove(toParent: nil)
            new.view.frame = viewController.view.bounds
            viewController.addChild(new)
            new.willMove(toParent: viewController)
            viewController.transition(from: current, to: new, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseOut], animations: {}) { completed in
                self.current.removeFromParent()
                new.didMove(toParent: self.viewController)
                self.current = new
                completion?()
                #if !os(tvOS)
                self.viewController.setNeedsStatusBarAppearanceUpdate()
                #endif
            }
        }
        
        private func animateDismissTransition(to new: UIViewController, completion: RootSimpleCompletion? = nil) {
            let initialFrame = CGRect(x: -viewController.view.bounds.width, y: 0, width: viewController.view.bounds.width, height: viewController.view.bounds.height)
            current.willMove(toParent: nil)
            viewController.addChild(new)
            new.view.frame = initialFrame
            viewController.transition(from: current, to: new, duration: 0.3, options: [], animations: {
                new.view.frame = self.viewController.view.bounds
            }) { completed in
                self.current.removeFromParent()
                new.didMove(toParent: self.viewController)
                self.current = new
                completion?()
                #if !os(tvOS)
                self.viewController.setNeedsStatusBarAppearanceUpdate()
                #endif
            }
        }
        
        func nextViewController(for type: SceneScreenType) -> UIViewController? {
            switch type {
            case .splash: return screens[type]?()
            case .login: return screens[type]?()
            case .logout:
                guard let handler = screens[type] else {
                    return screens[.login]?()
                }
                return handler()
            case .main: return screens[type]?()
            case .onboarding: return screens[type]?() ?? screens[.main]?()
            default: return screens[type]?()
            }
        }
    }
}
#endif
#endif
