//
//  UIInterfaceOrientation+Description.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 09.09.2020.
//

#if !os(macOS)
import UIKit

extension UIInterfaceOrientation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .landscapeLeft: return "landscapeLeft"
        case .landscapeRight: return "landscapeRight"
        case .portrait: return "portrait"
        case .portraitUpsideDown: return "portraitUpsideDown"
        case .unknown: return "unknown"
        @unknown default: return "unknown"
        }
    }
}
#endif
