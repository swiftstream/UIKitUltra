//
//  AttrStr+Joined.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 09.02.2020.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension Array: AnyString where Element == AnyString {
    public var attributedString: NSAttributedString {
        var res: NSMutableAttributedString = .init()
        for str in self {
            res.append(str.attributedString)
        }
        return res
    }
    
    public func onUpdate(_ handler: @escaping (NSAttributedString) -> Void) {
        for str in self {
            str.onUpdate {
                handler($0.attributedString)
            }
        }
    }
    
    public static func make(_ v: NSAttributedString) -> Self {
        .init([v])
    }
}

extension Array where Element: NSAttributedString {
    public func joined() -> NSAttributedString {
        let result = NSMutableAttributedString(string: "")
        for str in self {
            result.append(str)
        }
        return result
    }
}

@MainActor
extension Array where Element: AttributedString {
    public func joined() -> AttrStr {
        let result = AttributedString("")
        for str in self {
            result._attributedString.append(str._attributedString)
        }
        return result
    }
    
    public func joined() -> NSMutableAttributedString {
        let result = NSMutableAttributedString(string: "")
        for str in self {
            result.append(str._attributedString)
        }
        return result
    }
}
