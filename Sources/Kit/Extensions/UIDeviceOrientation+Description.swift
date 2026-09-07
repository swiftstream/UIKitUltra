#if os(macOS) || os(iOS) || os(tvOS)
//
//  UIDeviceOrientation+Description.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 09.09.2020.
//

#if !os(macOS)
import UIKit

extension UIDeviceOrientation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .landscapeLeft: return "landscapeLeft"
        case .landscapeRight: return "landscapeRight"
        case .portrait: return "portrait"
        case .portraitUpsideDown: return "portraitUpsideDown"
        case .faceDown: return "faceDown"
        case .faceUp: return "faceUp"
        case .unknown: return "unknown"
        @unknown default: return "unknown"
        }
    }
}
#endif
#endif
