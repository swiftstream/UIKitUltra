//
//  KeyEquivalentMaskable.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 13.08.2020.
//

#if os(macOS)
import Cocoa

public protocol KeyMaskable: AnyObject {
    @discardableResult
    func keyMask(_ mask: NSEvent.ModifierFlags) -> Self
    
    @discardableResult
    func keyMask(_ state: State<NSEvent.ModifierFlags>) -> Self
}

protocol _KeyMaskable: KeyMaskable {
    func _setKeyMask(_ v: NSEvent.ModifierFlags)
}

extension KeyMaskable {
    @discardableResult
    public func keyMask(_ mask: NSEvent.ModifierFlags) -> Self {
        guard let s = self as? _KeyMaskable else { return self }
        s._setKeyMask(mask)
        return self
    }

    @discardableResult
    public func keyMask(_ state: State<NSEvent.ModifierFlags>) -> Self {
        keyMask(state.wrappedValue)
        state.listen { [weak self] in
            self?.keyMask($0)
        }
        .holdIfOwned(by: self)
        return self
    }
}
#endif
