#if os(macOS) || os(iOS) || os(tvOS)
//
//  NSView+BringToFront.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 26.08.2020.
//

#if os(macOS)
import AppKit

extension NSView {
    func bringSubviewToFront(_ view: NSView) {
            var theView = view
            self.sortSubviews({ viewA, viewB, rawPointer in
                let view = rawPointer?.load(as: NSView.self)
                switch view {
                case viewA:
                    return .orderedDescending
                case viewB:
                    return .orderedAscending
                default:
                    return .orderedSame
                }
            }, context: &theView)
    }
}
#endif
#endif
