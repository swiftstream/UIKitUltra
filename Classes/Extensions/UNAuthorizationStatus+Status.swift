//
//  UNAuthorizationStatus+Status.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 10.09.2020.
//

#if !os(macOS)
import UIKit

@available(iOS 10.0, *)
extension UNAuthorizationStatus {
    var status: PushNotificationsAuthorizationStatus {
        switch self {
        case .authorized: return .authorized
        case .denied: return .denied
        case .notDetermined: return .notDetermined
        #if swift(>=5.3)
        case .ephemeral: return .notDetermined
        #endif
        case .provisional:
            if #available(iOS 12.0, *) {
                return .provisional
            } else {
                return .authorized
            }
        @unknown default: return .notDetermined
        }
    }
}
#endif
