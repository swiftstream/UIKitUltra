#if os(macOS) || os(iOS) || os(tvOS)
//
//  PushNotificationOption.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 10.09.2020.
//

#if !os(macOS)
import UIKit

public enum PushNotificationOption {
    case badge, sound, alert, carPlay
    // iOS12+
    case criticalAlert, providesAppNotificationSettings, provisional
    // iOS13+
    case announcement
    
    @available(iOS 10.0, *)
    var unOption: UNAuthorizationOptions? {
        switch self {
        case .badge: return .badge
        case .sound: return .sound
        case .alert: return .alert
        case .carPlay: return .carPlay
        case .criticalAlert:
            if #available(iOS 12.0, *) {
                return .criticalAlert
            }
            return nil
        case .providesAppNotificationSettings:
            if #available(iOS 12.0, *) {
                return .providesAppNotificationSettings
            }
            return nil
        case .provisional:
            if #available(iOS 12.0, *) {
                return .provisional
            }
            return nil
        case .announcement:
            if #available(iOS 13.0, *) {
                return .announcement
            }
            return nil
        }
    }
    
    var oldType: UIUserNotificationType? {
        switch self {
        case .badge: return .badge
        case .sound: return .sound
        case .alert: return .alert
        case .carPlay: return nil
        case .criticalAlert: return nil
        case .providesAppNotificationSettings: return nil
        case .provisional: return nil
        case .announcement: return nil
        }
    }
}

extension Array where Element == PushNotificationOption {
    @available(iOS 10.0, *)
    var unOption: UNAuthorizationOptions {
        .init(compactMap { $0.unOption })
    }
    
    var oldSettings: UIUserNotificationSettings {
        .init(types: .init(compactMap { $0.oldType }), categories: nil)
    }
}
#endif
#endif
