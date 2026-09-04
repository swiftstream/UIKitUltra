//
//  _SceneDelegate.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 11.09.2020.
//

#if !os(macOS)
import UIKit

@available(iOS 13.0, *)
class _SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        window = BaseApp.shared.mainScene.viewController.attach(to: scene)
        BaseApp.shared.mainScene._safeInsetsRetriever = { [weak self] in
            self?.window?.safeInsets ?? .zero
        }
        BaseApp.shared.mainScene._windowRetriever = { [weak self] in
            self?.window ?? UIWindow()
        }
        if let shortcutItem = connectionOptions.shortcutItem {
            BaseApp.shared.shortcuts
                .first { $0.item.type == shortcutItem.type }?
                .action? { _ in }
        }
        BaseApp.shared.mainScene._onConnect?(window)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        BaseApp.shared.mainScene._onDisconnect?(window)
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        let _ = BaseApp.shared.lifecycle?._openURLSourceAppAnnotation?(
            url,
            nil,
            [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        BaseApp.shared.shortcuts
            .first { $0.item.type == shortcutItem.type }?
            .action?(completionHandler)
    }
}
#endif
