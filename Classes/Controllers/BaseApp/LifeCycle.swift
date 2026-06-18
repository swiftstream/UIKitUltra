//
//  LifeCycle.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 12.09.2020.
//

#if !os(macOS)
import UIKit

@MainActor
public var Lifecycle: LifecycleBuilderProtocol { LifecycleBuilder() }

@MainActor
public protocol LifecycleBuilderProtocol: AnyObject, AppBuilderContent {
    func didFinishLaunching(_ handler: @escaping () -> Void) -> Self
    func willFinishLaunching(_ handler: @escaping (_ launchOptions: [UIApplication.LaunchOptionsKey: Any]) -> Bool) -> Self
    func didFinishLaunching(_ handler: @escaping (_ launchOptions: [UIApplication.LaunchOptionsKey: Any]) -> Bool) -> Self
    func didBecomeActive(_ handler: @escaping () -> Void) -> Self
    func willResignActive(_ handler: @escaping () -> Void) -> Self
    func didEnterBackground(_ handler: @escaping () -> Void) -> Self
    func willEnterForeground(_ handler: @escaping () -> Void) -> Self
    func openURL(_ handler: @escaping (_ url: URL) -> Bool) -> Self
    func openURL(_ handler: @escaping (_ url: URL, _ options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool) -> Self
    func openURL(_ handler: @escaping (_ url: URL, _ sourceApplication: String?, _ annotation: Any) -> Bool) -> Self
    func didReceiveMemoryWarning(_ handler: @escaping () -> Void) -> Self
    func willTerminate(_ handler: @escaping () -> Void) -> Self
    func significantTimeChange(_ handler: @escaping () -> Void) -> Self
    func willChangeStatusBarOrientation(_ handler: @escaping (_ newOrientation: UIInterfaceOrientation, _ duration: TimeInterval) -> Void) -> Self
    func didChangeStatusBarOrientation(_ handler: @escaping (_ oldOrientation: UIInterfaceOrientation) -> Void) -> Self
    func willChangeStatusBarFrame(_ handler: @escaping (_ newFrame: CGRect) -> Void) -> Self
    func didChangeStatusBarFrame(_ handler: @escaping (_ oldFrame: CGRect) -> Void) -> Self
    func didRegisterNotificationSettings(_ handler: @escaping (_ notificationSettings: UIUserNotificationSettings) -> Void) -> Self
    func didRegisterForRemoteNotificationsWithDeviceToken(_ handler: @escaping (_ deviceToken: Data) -> Void) -> Self
    func didFailToRegisterForRemoteNotifications(_ handler: @escaping (_ error: Error) -> Void) -> Self
    func didReceiveRemoteNotification(_ handler: @escaping (_ userInfo: [AnyHashable : Any]) -> Void) -> Self
    func didReceiveNotification(_ handler: @escaping (_ notification: UILocalNotification) -> Void) -> Self
    func handleLocalActionWithResponseInfo(_ handler: @escaping (_ identifier: String?, _ notification: UILocalNotification, _ responseInfo: [AnyHashable : Any], _ completionHandler: @escaping () -> Void) -> Void) -> Self
    func handleLocalAction(_ handler: @escaping (_ identifier: String?, _ notification: UILocalNotification, _ completionHandler: @escaping () -> Void) -> Void) -> Self
    func handleRemoteActionWithResponseInfo(_ handler: @escaping (_ identifier: String?, _ remoteNotification: [AnyHashable : Any], _ responseInfo: [AnyHashable : Any], _ completionHandler: @escaping () -> Void) -> Void) -> Self
    func handleRemoteAction(_ handler: @escaping (_ identifier: String?, _ remoteNotification: [AnyHashable : Any], _ completionHandler: @escaping () -> Void) -> Void) -> Self
    func didReceiveRemoteNotification(_ handler: @escaping (_ userInfo: [AnyHashable : Any], _ completionHandler: (UIBackgroundFetchResult) -> Void) -> Void) -> Self
    func performFetch(_ handler: @escaping (_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Void) -> Self
    func performActionForShortcutItem(_ handler: @escaping (_ shortcutItem: UIApplicationShortcutItem, _ completionHandler: @escaping (Bool) -> Void) -> Void) -> Self
    func handleEventsForBackgroundURLSession(_ handler: @escaping (_ identifier: String, _ completionHandler: @escaping () -> Void) -> Void) -> Self
    func handleWatchKitExtensionRequest(_ handler: @escaping (_ userInfo: [AnyHashable : Any], _ reply: @escaping ([AnyHashable : Any]?) -> Void) -> Void) -> Self
    func shouldRequestHealthAuthorization(_ handler: @escaping () -> Void) -> Self
    func protectedDataWillBecomeUnavailable(_ handler: @escaping () -> Void) -> Self
    func protectedDataDidBecomeAvailable(_ handler: @escaping () -> Void) -> Self
    func supportedInterfaceOrientations(_ handler: @escaping (_ window: UIWindow?) -> UIInterfaceOrientationMask) -> Self
    func shouldAllowExtensionPointIdentifier(_ handler: @escaping (_ extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool) -> Self
    func viewControllerWithRestorationIdentifierPath(_ handler: @escaping (_ identifierComponents: [String], _ coder: NSCoder) -> UIViewController?) -> Self
    func shouldSaveSecureApplicationState(_ handler: @escaping (_ coder: NSCoder) -> Bool) -> Self
    func shouldRestoreSecureApplicationState(_ handler: @escaping (_ coder: NSCoder) -> Bool) -> Self
    func willEncodeRestorableState(_ handler: @escaping (_ coder: NSCoder) -> Void) -> Self
    func didDecodeRestorableState(_ handler: @escaping (_ coder: NSCoder) -> Void) -> Self
    func willContinueUserActivity(_ handler: @escaping (_ userActivityType: String) -> Bool) -> Self
    func continueUserActivity(_ handler: @escaping (_ userActivity: NSUserActivity, _ restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool) -> Self
    func didFailToContinueUserActivityWithType(_ handler: @escaping (_ userActivityType: String, _ error: Error) -> Void) -> Self
    func didUpdateUserActivity(_ handler: @escaping (_ userActivity: NSUserActivity) -> Void) -> Self
}

extension LifecycleBuilderProtocol {
    public var appBuilderContent: AppBuilderItem { .lifecycle(self) }
}

protocol _LifecycleBuilderProtocol: LifecycleBuilderProtocol {
    var _didFinishLaunching: (() -> Void)? { get set }
    var _willFinishLaunchingWithOptions: (([UIApplication.LaunchOptionsKey: Any]) -> Bool)? { get set }
    var _didFinishLaunchingWithOptions: (([UIApplication.LaunchOptionsKey: Any]) -> Bool)? { get set }
    var _didBecomeActive: (() -> Void)? { get set }
    var _willResignActive: (() -> Void)? { get set }
    var _didEnterBackground: (() -> Void)? { get set }
    var _willEnterForeground: (() -> Void)? { get set }
    var _openURLWithOptions: ((URL, [UIApplication.OpenURLOptionsKey : Any]) -> Bool)? { get set }
    var _openURLSourceAppAnnotation: ((URL, String?, Any) -> Bool)? { get set }
    var _didReceiveMemoryWarning: (() -> Void)? { get set }
    var _willTerminate: (() -> Void)? { get set }
    var _significantTimeChange: (() -> Void)? { get set }
    var _willChangeStatusBarOrientation: ((UIInterfaceOrientation, TimeInterval) -> Void)? { get set }
    var _didChangeStatusBarOrientation: ((UIInterfaceOrientation) -> Void)? { get set }
    var _willChangeStatusBarFrame: ((CGRect) -> Void)? { get set }
    var _didChangeStatusBarFrame: ((CGRect) -> Void)? { get set }
    var _didRegisterNotificationSettings: ((UIUserNotificationSettings) -> Void)? { get set }
    var _didRegisterForRemoteNotificationsWithDeviceToken: ((Data) -> Void)? { get set }
    var _didFailToRegisterForRemoteNotifications: ((Error) -> Void)? { get set }
    var _didReceiveRemoteNotification: (([AnyHashable : Any]) -> Void)? { get set }
    var _didReceiveNotification: ((UILocalNotification) -> Void)? { get set }
    var _handleLocalActionWithResponseInfo: ((String?, UILocalNotification, [AnyHashable : Any], @escaping () -> Void) -> Void)? { get set }
    var _handleLocalAction: ((String?, UILocalNotification, @escaping () -> Void) -> Void)? { get set }
    var _handleRemoteActionWithResponseInfo: ((String?, [AnyHashable : Any], [AnyHashable : Any], @escaping () -> Void) -> Void)? { get set }
    var _handleRemoteAction: ((String?, [AnyHashable : Any], @escaping () -> Void) -> Void)? { get set }
    var _didReceiveRemoteNotificationWithCompletion: (([AnyHashable : Any], @escaping (UIBackgroundFetchResult) -> Void) -> Void)? { get set }
    var _performFetch: ((@escaping (UIBackgroundFetchResult) -> Void) -> Void)? { get set }
    var _performActionForShortcutItem: ((UIApplicationShortcutItem, @escaping (Bool) -> Void) -> Void)? { get set }
    var _handleEventsForBackgroundURLSession: ((String, @escaping () -> Void) -> Void)? { get set }
    var _handleWatchKitExtensionRequest: (([AnyHashable : Any], @escaping ([AnyHashable : Any]?) -> Void) -> Void)? { get set }
    var _shouldRequestHealthAuthorization: (() -> Void)? { get set }
    var _protectedDataWillBecomeUnavailable: (() -> Void)? { get set }
    var _protectedDataDidBecomeAvailable: (() -> Void)? { get set }
    var _supportedInterfaceOrientations: ((UIWindow?) -> UIInterfaceOrientationMask)? { get set }
    var _shouldAllowExtensionPointIdentifier: ((UIApplication.ExtensionPointIdentifier) -> Bool)? { get set }
    var _viewControllerWithRestorationIdentifierPath: (([String], NSCoder) -> UIViewController?)? { get set }
    var _shouldSaveSecureApplicationState: ((NSCoder) -> Bool)? { get set }
    var _shouldRestoreSecureApplicationState: ((NSCoder) -> Bool)? { get set }
    var _willEncodeRestorableState: ((NSCoder) -> Void)? { get set }
    var _didDecodeRestorableState: ((NSCoder) -> Void)? { get set }
    var _willContinueUserActivity: ((String) -> Bool)? { get set }
    var _continueUserActivity: ((NSUserActivity, @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool)? { get set }
    var _didFailToContinueUserActivityWithType: ((String, Error) -> Void)? { get set }
    var _didUpdateUserActivity: ((NSUserActivity) -> Void)? { get set }
}

class LifecycleBuilder: _LifecycleBuilderProtocol {
    init () {}
    
    var _didFinishLaunching: (() -> Void)?
    
    public func didFinishLaunching(_ handler: @escaping () -> Void) -> Self {
        _didFinishLaunching = handler
        return self
    }
    
    var _willFinishLaunchingWithOptions: (([UIApplication.LaunchOptionsKey: Any]) -> Bool)?
    
    public func willFinishLaunching(_ handler: @escaping (_ launchOptions: [UIApplication.LaunchOptionsKey: Any]) -> Bool) -> Self {
        _willFinishLaunchingWithOptions = handler
        return self
    }
    
    var _didFinishLaunchingWithOptions: (([UIApplication.LaunchOptionsKey: Any]) -> Bool)?
    
    public func didFinishLaunching(_ handler: @escaping (_ launchOptions: [UIApplication.LaunchOptionsKey: Any]) -> Bool) -> Self {
        _didFinishLaunchingWithOptions = handler
        return self
    }
    
    var _didBecomeActive: (() -> Void)?
        
    public func didBecomeActive(_ handler: @escaping () -> Void) -> Self {
        _didBecomeActive = handler
        return self
    }

    var _willResignActive: (() -> Void)?
        
    public func willResignActive(_ handler: @escaping () -> Void) -> Self {
        _willResignActive = handler
        return self
    }
    
    var _didEnterBackground: (() -> Void)?
        
    public func didEnterBackground(_ handler: @escaping () -> Void) -> Self {
        _didEnterBackground = handler
        return self
    }

    var _willEnterForeground: (() -> Void)?
        
    public func willEnterForeground(_ handler: @escaping () -> Void) -> Self {
        _willEnterForeground = handler
        return self
    }
    
    var _openURLWithOptions: ((URL, [UIApplication.OpenURLOptionsKey : Any]) -> Bool)?
        
    public func openURL(_ handler: @escaping (_ url: URL) -> Bool) -> Self {
        _openURLWithOptions = { url,_ in
            handler(url)
        }
        return self
    }
    
    public func openURL(_ handler: @escaping (_ url: URL, _ options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool) -> Self {
        _openURLWithOptions = handler
        return self
    }
    
    var _openURLSourceAppAnnotation: ((URL, String?, Any) -> Bool)?
    
    func openURL(_ handler: @escaping (_ url: URL, _ sourceApplication: String?, _ annotation: Any) -> Bool) -> Self {
        _openURLSourceAppAnnotation = handler
        return self
    }

    var _didReceiveMemoryWarning: (() -> Void)?
        
    public func didReceiveMemoryWarning(_ handler: @escaping () -> Void) -> Self {
        _didReceiveMemoryWarning = handler
        return self
    }

    var _willTerminate: (() -> Void)?
        
    public func willTerminate(_ handler: @escaping () -> Void) -> Self {
        _willTerminate = handler
        return self
    }

    var _significantTimeChange: (() -> Void)?
        
    public func significantTimeChange(_ handler: @escaping () -> Void) -> Self {
        _significantTimeChange = handler
        return self
    }
    
    var _willChangeStatusBarOrientation: ((UIInterfaceOrientation, TimeInterval) -> Void)?
        
    public func willChangeStatusBarOrientation(_ handler: @escaping (_ newOrientation: UIInterfaceOrientation, _ duration: TimeInterval) -> Void) -> Self {
        _willChangeStatusBarOrientation = handler
        return self
    }

    var _didChangeStatusBarOrientation: ((UIInterfaceOrientation) -> Void)?
        
    public func didChangeStatusBarOrientation(_ handler: @escaping (_ oldOrientation: UIInterfaceOrientation) -> Void) -> Self {
        _didChangeStatusBarOrientation = handler
        return self
    }

    var _willChangeStatusBarFrame: ((CGRect) -> Void)?
        
    public func willChangeStatusBarFrame(_ handler: @escaping (_ newFrame: CGRect) -> Void) -> Self {
        _willChangeStatusBarFrame = handler
        return self
    }

    var _didChangeStatusBarFrame: ((CGRect) -> Void)?
        
    public func didChangeStatusBarFrame(_ handler: @escaping (_ oldFrame: CGRect) -> Void) -> Self {
        _didChangeStatusBarFrame = handler
        return self
    }

    var _didRegisterNotificationSettings: ((UIUserNotificationSettings) -> Void)?
        
    public func didRegisterNotificationSettings(_ handler: @escaping (_ notificationSettings: UIUserNotificationSettings) -> Void) -> Self {
        _didRegisterNotificationSettings = handler
        return self
    }

    var _didRegisterForRemoteNotificationsWithDeviceToken: ((Data) -> Void)?
        
    public func didRegisterForRemoteNotificationsWithDeviceToken(_ handler: @escaping (_ deviceToken: Data) -> Void) -> Self {
        _didRegisterForRemoteNotificationsWithDeviceToken = handler
        return self
    }

    var _didFailToRegisterForRemoteNotifications: ((Error) -> Void)?
        
    public func didFailToRegisterForRemoteNotifications(_ handler: @escaping (_ error: Error) -> Void) -> Self {
        _didFailToRegisterForRemoteNotifications = handler
        return self
    }

    var _didReceiveRemoteNotification: (([AnyHashable : Any]) -> Void)?
        
    public func didReceiveRemoteNotification(_ handler: @escaping (_ userInfo: [AnyHashable : Any]) -> Void) -> Self {
        _didReceiveRemoteNotification = handler
        return self
    }

    var _didReceiveNotification: ((UILocalNotification) -> Void)?
        
    public func didReceiveNotification(_ handler: @escaping (_ notification: UILocalNotification) -> Void) -> Self {
        _didReceiveNotification = handler
        return self
    }
    
    var _handleLocalActionWithResponseInfo: ((String?, UILocalNotification, [AnyHashable : Any], @escaping () -> Void) -> Void)?
        
    public func handleLocalActionWithResponseInfo(_ handler: @escaping (_ identifier: String?, _ notification: UILocalNotification, _ responseInfo: [AnyHashable : Any], _ completionHandler: @escaping () -> Void) -> Void) -> Self {
        _handleLocalActionWithResponseInfo = handler
        return self
    }
    
    var _handleLocalAction: ((String?, UILocalNotification, @escaping () -> Void) -> Void)?
        
    public func handleLocalAction(_ handler: @escaping (_ identifier: String?, _ notification: UILocalNotification, _ completionHandler: @escaping () -> Void) -> Void) -> Self {
        _handleLocalAction = handler
        return self
    }

    var _handleRemoteActionWithResponseInfo: ((String?, [AnyHashable : Any], [AnyHashable : Any], @escaping () -> Void) -> Void)?
        
    public func handleRemoteActionWithResponseInfo(_ handler: @escaping (_ identifier: String?, _ remoteNotification: [AnyHashable : Any], _ responseInfo: [AnyHashable : Any], _ completionHandler: @escaping () -> Void) -> Void) -> Self {
        _handleRemoteActionWithResponseInfo = handler
        return self
    }

    var _handleRemoteAction: ((String?, [AnyHashable : Any], @escaping () -> Void) -> Void)?
        
    public func handleRemoteAction(_ handler: @escaping (_ identifier: String?, _ remoteNotification: [AnyHashable : Any], _ completionHandler: @escaping () -> Void) -> Void) -> Self {
        _handleRemoteAction = handler
        return self
    }
    
    var _didReceiveRemoteNotificationWithCompletion: (([AnyHashable : Any], @escaping (UIBackgroundFetchResult) -> Void) -> Void)?
        
    public func didReceiveRemoteNotification(_ handler: @escaping (_ userInfo: [AnyHashable : Any], _ completionHandler: (UIBackgroundFetchResult) -> Void) -> Void) -> Self {
        _didReceiveRemoteNotificationWithCompletion = handler
        return self
    }

    var _performFetch: ((@escaping (UIBackgroundFetchResult) -> Void) -> Void)?
        
    public func performFetch(_ handler: @escaping (_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Void) -> Self {
        _performFetch = handler
        return self
    }

    var _performActionForShortcutItem: ((UIApplicationShortcutItem, @escaping (Bool) -> Void) -> Void)?
        
    public func performActionForShortcutItem(_ handler: @escaping (_ shortcutItem: UIApplicationShortcutItem, _ completionHandler: @escaping (Bool) -> Void) -> Void) -> Self {
        _performActionForShortcutItem = handler
        return self
    }

    var _handleEventsForBackgroundURLSession: ((String, @escaping () -> Void) -> Void)?
        
    public func handleEventsForBackgroundURLSession(_ handler: @escaping (_ identifier: String, _ completionHandler: @escaping () -> Void) -> Void) -> Self {
        _handleEventsForBackgroundURLSession = handler
        return self
    }
    
    var _handleWatchKitExtensionRequest: (([AnyHashable : Any], @escaping ([AnyHashable : Any]?) -> Void) -> Void)?
        
    public func handleWatchKitExtensionRequest(_ handler: @escaping (_ userInfo: [AnyHashable : Any], _ reply: @escaping ([AnyHashable : Any]?) -> Void) -> Void) -> Self {
        _handleWatchKitExtensionRequest = handler
        return self
    }
    
    var _shouldRequestHealthAuthorization: (() -> Void)?
        
    public func shouldRequestHealthAuthorization(_ handler: @escaping () -> Void) -> Self {
        _shouldRequestHealthAuthorization = handler
        return self
    }
    
////    optional func application(_ application: UIApplication, handle intent: INIntent, completionHandler: @escaping (INIntentResponse) -> Void)
//    var _handleIntentWithCompletion: ((INIntent, @escaping (INIntentResponse) -> Void) -> Void)?
//
//    public func onHandleIntentWithCompletion(_ handler: @escaping (_ intent: INIntent, _ completionHandler: @escaping (INIntentResponse) -> Void) -> Void) -> Self {
//        _handleIntentWithCompletion = handler
//        return self
//    }
    
    var _protectedDataWillBecomeUnavailable: (() -> Void)?
        
    public func protectedDataWillBecomeUnavailable(_ handler: @escaping () -> Void) -> Self {
        _protectedDataWillBecomeUnavailable = handler
        return self
    }

    var _protectedDataDidBecomeAvailable: (() -> Void)?
        
    public func protectedDataDidBecomeAvailable(_ handler: @escaping () -> Void) -> Self {
        _protectedDataDidBecomeAvailable = handler
        return self
    }
    
    var _supportedInterfaceOrientations: ((UIWindow?) -> UIInterfaceOrientationMask)?
        
    public func supportedInterfaceOrientations(_ handler: @escaping (_ window: UIWindow?) -> UIInterfaceOrientationMask) -> Self {
        _supportedInterfaceOrientations = handler
        return self
    }

    var _shouldAllowExtensionPointIdentifier: ((UIApplication.ExtensionPointIdentifier) -> Bool)?
        
    public func shouldAllowExtensionPointIdentifier(_ handler: @escaping (_ extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool) -> Self {
        _shouldAllowExtensionPointIdentifier = handler
        return self
    }

    var _viewControllerWithRestorationIdentifierPath: (([String], NSCoder) -> UIViewController?)?
        
    public func viewControllerWithRestorationIdentifierPath(_ handler: @escaping (_ identifierComponents: [String], _ coder: NSCoder) -> UIViewController?) -> Self {
        _viewControllerWithRestorationIdentifierPath = handler
        return self
    }

    var _shouldSaveSecureApplicationState: ((NSCoder) -> Bool)?
        
    public func shouldSaveSecureApplicationState(_ handler: @escaping (_ coder: NSCoder) -> Bool) -> Self {
        _shouldSaveSecureApplicationState = handler
        return self
    }

    var _shouldRestoreSecureApplicationState: ((NSCoder) -> Bool)?
        
    public func shouldRestoreSecureApplicationState(_ handler: @escaping (_ coder: NSCoder) -> Bool) -> Self {
        _shouldRestoreSecureApplicationState = handler
        return self
    }

    var _willEncodeRestorableState: ((NSCoder) -> Void)?
        
    public func willEncodeRestorableState(_ handler: @escaping (_ coder: NSCoder) -> Void) -> Self {
        _willEncodeRestorableState = handler
        return self
    }

    var _didDecodeRestorableState: ((NSCoder) -> Void)?
        
    public func didDecodeRestorableState(_ handler: @escaping (_ coder: NSCoder) -> Void) -> Self {
        _didDecodeRestorableState = handler
        return self
    }

    var _willContinueUserActivity: ((String) -> Bool)?
        
    public func willContinueUserActivity(_ handler: @escaping (_ userActivityType: String) -> Bool) -> Self {
        _willContinueUserActivity = handler
        return self
    }
    
    var _continueUserActivity: ((NSUserActivity, @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool)?
        
    public func continueUserActivity(_ handler: @escaping (_ userActivity: NSUserActivity, _ restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool) -> Self {
        _continueUserActivity = handler
        return self
    }
    
    var _didFailToContinueUserActivityWithType: ((String, Error) -> Void)?
        
    public func didFailToContinueUserActivityWithType(_ handler: @escaping (_ userActivityType: String, _ error: Error) -> Void) -> Self {
        _didFailToContinueUserActivityWithType = handler
        return self
    }

    var _didUpdateUserActivity: ((NSUserActivity) -> Void)?
        
    public func didUpdateUserActivity(_ handler: @escaping (_ userActivity: NSUserActivity) -> Void) -> Self {
        _didUpdateUserActivity = handler
        return self
    }

////    optional func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShareMetadata)
//    var _userDidAcceptCloudKitShare: ((CKShareMetadata) -> Void)?
//
//    public func userDidAcceptCloudKitShare(_ handler: @escaping (_ cloudKitShareMetadata: CKShareMetadata) -> Void) -> Self {
//        _userDidAcceptCloudKitShare = handler
//        return self
//    }
}
#endif
