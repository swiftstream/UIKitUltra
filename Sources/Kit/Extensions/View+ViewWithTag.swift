#if os(macOS) || os(iOS) || os(tvOS)
//
//  UIView+ViewWithTag.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 18.04.2020.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension BaseView {
    public func viewWithTagInSuperview(_ tag: Int) -> BaseView? {
        if let view = viewWithTag(tag) {
            return view
        } else if let view = superview?.viewWithTag(tag) {
            return view
        } else if let view = superview?.superview?.viewWithTag(tag) {
            return view
        } else if let view = superview?.superview?.superview?.viewWithTag(tag) {
            return view
        } else if let view = superview?.superview?.superview?.superview?.viewWithTag(tag) {
            return view
        } else if let view = superview?.superview?.superview?.superview?.superview?.viewWithTag(tag) {
            return view
        } else if let view = superview?.superview?.superview?.superview?.superview?.superview?.viewWithTag(tag) {
            return view
        } else if let view = superview?.superview?.superview?.superview?.superview?.superview?.superview?.viewWithTag(tag) {
            return view
        } else if let view = superview?.superview?.superview?.superview?.superview?.superview?.superview?.superview?.viewWithTag(tag) {
            return view
        } else if let view = superview?.superview?.superview?.superview?.superview?.superview?.superview?.superview?.superview?.viewWithTag(tag) {
            return view
        } else if let view = superview?.superview?.superview?.superview?.superview?.superview?.superview?.superview?.superview?.superview?.viewWithTag(tag) {
            return view
        }
        return nil
    }
}
#endif
