//
//  Taggable.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 17.04.2020.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
public protocol Taggable: AnyObject {
    var tag: Int { get set }
    
    @discardableResult
    func tag(_ value: Int) -> Self
}

extension Taggable {
    @discardableResult
    public func tag(_ value: Int) -> Self {
        tag = value
        return self
    }
}

extension UGestureRecognizer: Taggable {
    @objc
    public var tag: Int {
        get { 0 }
        set {}
    }
}
