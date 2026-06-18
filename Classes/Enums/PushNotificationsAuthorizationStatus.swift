//
//  PushNotificationsAuthorizationStatus.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 10.09.2020.
//

public enum PushNotificationsAuthorizationStatus: Sendable {
    // The user has not yet made a choice regarding whether the application may post user notifications.
    case notDetermined

    // The application is not authorized to post user notifications.
    case denied
    
    // The application is authorized to post user notifications.
    case authorized
    
    // The application is authorized to post non-interruptive user notifications.
    case provisional
}
