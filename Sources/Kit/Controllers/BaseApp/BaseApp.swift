#if os(macOS) || os(iOS) || os(tvOS)
//
//  BaseApp.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 09.09.2020.
//

#if !os(macOS)
import UIKit
import UltraCore

open class BaseApp: UIApplication, UIApplicationDelegate {
    public static override var shared: BaseApp { super.shared as! BaseApp }
    public static var mainScene: MainScene { shared.mainScene }
    
    @UState public var deviceOrientation = UIDevice.current.orientation
    @UState public var deviceBatteryLevel = UIDevice.current.batteryLevel
    @UState public var deviceBatteryState = UIDevice.current.batteryState
    @UState public var deviceProximityState = UIDevice.current.proximityState
    
    @UState public var pushAuthorizationStatus: PushNotificationsAuthorizationStatus = .notDetermined
    @UState public var pushNotificationToken: String?
    
    public internal(set) lazy var mainScene: MainScene = MainScene()
    
    public override init() {
        super.init()
        delegate = self
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var lifecycle: _LifecycleBuilderProtocol?
    
    var scenes: [_AnyScene] = []
    
    @AppBuilder open var body: AppBuilderContent { _AppContent(appBuilderContent: .none) }
    var shortcuts: [Shortcut] = []
    
    private func parseAppBuilderItem(_ item: AppBuilderItem) {
        switch item {
        case .lifecycle(let v): lifecycle = v as? _LifecycleBuilderProtocol
        case .mainScene(let scene):
            scenes.append(scene)
            mainScene = scene
        case .scene(let scene):
            scenes.append(scene)
        case .shortcuts(let v):
            shortcuts.append(contentsOf: v.shortcuts)
            _setShourtcuts()
        case .items(let items): items.forEach { parseAppBuilderItem($0) }
        case .none: break
        }
    }
    
    private func _setShourtcuts() {
        shortcutItems?.append(contentsOf: shortcuts.map { shortcut in
            shortcut._update = {
                guard let indexToRemove = self.shortcutItems?.firstIndex(where: { $0.type == shortcut.item.type }) else { return }
                self.shortcutItems?.remove(at: indexToRemove)
                if let indexArray = self.shortcuts.firstIndex(where: { $0 === shortcut }) {
                    self.shortcutItems?.insert(shortcut.item, at: indexArray)
                }
            }
            shortcut._disable = {
                self.shortcutItems?.removeAll(where: { $0.type == shortcut.item.type })
            }
            shortcut._enable = {
                self.shortcutItems?.removeAll(where: { $0.type == shortcut.item.type })
                guard let index = self.shortcuts.firstIndex(where: { $0 === shortcut }) else { return }
                self.shortcutItems?.insert(shortcut.item, at: index)
            }
            return shortcut.item
        })
    }
    
    // MARK: - UIApplicationDelegate
    
    public var window: UIWindow?
    
    public func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        shortcutItems = []
        parseAppBuilderItem(body.appBuilderContent)
        mainScene.initialize()
        if lifecycle?._willFinishLaunchingWithOptions?(launchOptions ?? [:]) == false {
            return false
        }
        return true
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.registerForRemoteNotifications()
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
            self.deviceOrientation = UIDevice.current.orientation
        }
        NotificationCenter.default.addObserver(forName: UIDevice.batteryLevelDidChangeNotification, object: nil, queue: .main) { _ in
            self.deviceBatteryLevel = UIDevice.current.batteryLevel
        }
        NotificationCenter.default.addObserver(forName: UIDevice.batteryStateDidChangeNotification, object: nil, queue: .main) { _ in
            self.deviceBatteryState = UIDevice.current.batteryState
        }
        NotificationCenter.default.addObserver(forName: UIDevice.proximityStateDidChangeNotification, object: nil, queue: .main) { _ in
            self.deviceProximityState = UIDevice.current.proximityState
        }
        if lifecycle?._didFinishLaunchingWithOptions?(launchOptions ?? [:]) == false {
            return false
        }
        lifecycle?._didFinishLaunching?()
        if #available(iOS 13.0, *) {} else {
            window = UIWindow(frame: UIScreen.main.bounds)
            mainScene.viewController.attach(to: window)
        }
        return true
    }
    
    public func applicationDidBecomeActive(_ application: UIApplication) {
        lifecycle?._didBecomeActive?()
        if #available(iOS 13.0, *) {} else {
            // TODO: handle shortcut
        }
    }
    
    public func applicationWillResignActive(_ application: UIApplication) {
        lifecycle?._willResignActive?()
    }
    
    public func applicationDidEnterBackground(_ application: UIApplication) {
        lifecycle?._didEnterBackground?()
    }
    
    public func applicationWillEnterForeground(_ application: UIApplication) {
        lifecycle?._willEnterForeground?()
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        lifecycle?._openURLWithOptions?(url, options) ?? true
    }
    
    public func application(_ app: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        lifecycle?._openURLSourceAppAnnotation?(url, sourceApplication, annotation) ?? true
    }
    
    public func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        lifecycle?._didReceiveMemoryWarning?()
    }
    
    public func applicationWillTerminate(_ application: UIApplication) {
        lifecycle?._willTerminate?()
    }
    
    public func applicationSignificantTimeChange(_ application: UIApplication) {
        lifecycle?._significantTimeChange?()
    }
    
    public func application(_ application: UIApplication, willChangeStatusBarOrientation newStatusBarOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        lifecycle?._willChangeStatusBarOrientation?(newStatusBarOrientation, duration)
    }
    
    public func application(_ application: UIApplication, didChangeStatusBarOrientation oldStatusBarOrientation: UIInterfaceOrientation) {
        lifecycle?._didChangeStatusBarOrientation?(oldStatusBarOrientation)
    }
    
    public func application(_ application: UIApplication, willChangeStatusBarFrame newStatusBarFrame: CGRect) {
        lifecycle?._willChangeStatusBarFrame?(newStatusBarFrame)
    }
    
    public func application(_ application: UIApplication, didChangeStatusBarFrame oldStatusBarFrame: CGRect) {
        lifecycle?._didChangeStatusBarFrame?(oldStatusBarFrame)
    }
    
    public func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        lifecycle?._didRegisterNotificationSettings?(notificationSettings)
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        pushNotificationToken = deviceToken.reduce("") { $0 + .init(format: "%02X", $1) }
        refreshPushStates()
        lifecycle?._didRegisterForRemoteNotificationsWithDeviceToken?(deviceToken)
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        refreshPushStates()
        lifecycle?._didFailToRegisterForRemoteNotifications?(error)
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        lifecycle?._didReceiveRemoteNotification?(userInfo)
    }
    
    public func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        lifecycle?._didReceiveNotification?(notification)
    }
    
    public func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        lifecycle?._handleLocalActionWithResponseInfo?(identifier, notification, responseInfo, completionHandler)
    }
    
    public func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        lifecycle?._handleLocalAction?(identifier, notification, completionHandler)
    }
    
    public func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        lifecycle?._handleRemoteActionWithResponseInfo?(identifier, userInfo, responseInfo, completionHandler)
    }
    
    public func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        lifecycle?._handleRemoteAction?(identifier, userInfo, completionHandler)
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        lifecycle?._didReceiveRemoteNotificationWithCompletion?(userInfo, completionHandler)
    }
    
//        @available(iOS, introduced: 7.0, deprecated: 13.0, message: "Use a BGAppRefreshTask in the BackgroundTasks framework instead")
    public func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        lifecycle?._performFetch?(completionHandler)
    }
    
    public func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        lifecycle?._performActionForShortcutItem?(shortcutItem, completionHandler)
        guard let shortcut = shortcuts.first(where: { $0.item.type == shortcutItem.type }) else { return }
        shortcut.action?(completionHandler)
    }
    
    public func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        lifecycle?._handleEventsForBackgroundURLSession?(identifier, completionHandler)
    }
    
    public func application(_ application: UIApplication, handleWatchKitExtensionRequest userInfo: [AnyHashable : Any]?, reply: @escaping ([AnyHashable : Any]?) -> Void) {
        lifecycle?._handleWatchKitExtensionRequest?(userInfo ?? [:], reply)
    }
    
    public func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
        lifecycle?._shouldRequestHealthAuthorization?()
    }
    
    public func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication) {
        lifecycle?._protectedDataWillBecomeUnavailable?()
    }
    
    public func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
        lifecycle?._protectedDataDidBecomeAvailable?()
    }
    
    public func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        lifecycle?._supportedInterfaceOrientations?(window) ?? .allButUpsideDown
    }
    
    public func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        lifecycle?._shouldAllowExtensionPointIdentifier?(extensionPointIdentifier) ?? true
    }
    
    public func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
        lifecycle?._viewControllerWithRestorationIdentifierPath?(identifierComponents, coder) ?? nil
    }
    
    public func application(_ application: UIApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
        lifecycle?._shouldSaveSecureApplicationState?(coder) ?? true
    }

    public func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        lifecycle?._shouldSaveSecureApplicationState?(coder) ?? true
    }
    
    public func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
        lifecycle?._shouldRestoreSecureApplicationState?(coder) ?? true
    }

    public func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        lifecycle?._shouldRestoreSecureApplicationState?(coder) ?? true
    }
    
    public func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder) {
        lifecycle?._willEncodeRestorableState?(coder)
    }
    
    public func application(_ application: UIApplication, didDecodeRestorableStateWith coder: NSCoder) {
        lifecycle?._didDecodeRestorableState?(coder)
    }
    
    public func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        lifecycle?._willContinueUserActivity?(userActivityType) ?? true
    }
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        lifecycle?._continueUserActivity?(userActivity, restorationHandler) ?? true
    }
    
    public func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        lifecycle?._didFailToContinueUserActivityWithType?(userActivityType, error)
    }
    
    public func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        lifecycle?._didUpdateUserActivity?(userActivity)
    }
    
    private func refreshPushStates() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                let status = settings.authorizationStatus.status
                DispatchQueue.main.async {
                    self.pushAuthorizationStatus = status
                }
            }
        } else {
            self.pushAuthorizationStatus = UIApplication.shared.currentUserNotificationSettings?.types.isEmpty == false ? .authorized : .notDetermined
        }
    }
    
    // MARK: - Scene
    
    @available(iOS 13.0, *)
    func makeWindowForScene(_ scene: UIScene) -> UIWindow? {
        mainScene.viewController.attach(to: scene)
    }
    
    @available(iOS 13.0, *)
    public func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        NSLog("options.urlContexts: \(options.urlContexts)")
        NSLog("options.sourceApplication: \(options.sourceApplication)")
        NSLog("options.handoffUserActivityType: \(options.handoffUserActivityType)")
        NSLog("options.userActivities: \(options.userActivities)")
        NSLog("options.notificationResponse: \(options.notificationResponse)")
        NSLog("options.shortcutItem: \(options.shortcutItem)")
        let config = UISceneConfiguration(name: nil, sessionRole: UISceneSession.Role.windowApplication)
        config.delegateClass = Ultra._SceneDelegate.self
        config.sceneClass = Ultra._Scene.self
        return config
    }
    
    @available(iOS 13.0, *)
    public func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        let pids = sceneSessions.map { session -> (String, UIWindow?) in
            (session.persistentIdentifier, (session.scene as? UIWindowScene)?.windows.first)
        }
        scenes.compactMap { scene -> (_AnyScene, UIWindow?)? in
            guard let pid = pids.first(where: { $0.0 == scene.persistentIdentifier }) else { return nil }
            return (scene, pid.1)
        }.forEach {
            $0.0._onDestroy?($0.1)
        }
    }
    
    // MARK: - Push Notifications
    
    public static func requestPushNotificationsAuthorization(_ options: PushNotificationOption...) {
        requestPushNotificationsAuthorization(options)
    }
    
    public static func requestPushNotificationsAuthorization(_ options: [PushNotificationOption]) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: options.unOption) { granted,_ in
                guard granted else {
                    BaseApp.shared.refreshPushStates()
                    return
                }
                DispatchQueue.main.async(execute: UIApplication.shared.registerForRemoteNotifications)
            }
        } else {
            UIApplication.shared.registerUserNotificationSettings(options.oldSettings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    // MARK: Convenience shortcut to Settings
    
    public static func openSettings() {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return }
        guard let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) else { return }
        guard UIApplication.shared.canOpenURL(appSettings) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(appSettings)
        } else {
            UIApplication.shared.openURL(appSettings)
        }
    }
}
#endif
#endif
