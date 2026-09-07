#if os(macOS) || os(iOS) || os(tvOS)
//
//  MacOS+TextContentType.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 27.08.2020.
//

#if os(macOS)
import AppKit

public enum TextFieldContentType {
    case username, password, oneTimeCode
    
    #if swift(>=5.3)
    @available(OSX 10.16, *)
    var nsType: NSTextContentType {
        switch self {
        case .username: return .username
        case .password: return .password
        case .oneTimeCode: return .oneTimeCode
        }
    }
    #endif
}
#endif
#endif
