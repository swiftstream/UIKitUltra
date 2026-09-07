#if os(macOS) || os(iOS) || os(tvOS)
//
//  View+Menuable.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 22.08.2020.
//

#if os(macOS)
import AppKit

extension BaseView: _Menuable {
    func _setMenu(_ v: Menu) {
        menu = v.menu
    }
}
#endif
#endif
