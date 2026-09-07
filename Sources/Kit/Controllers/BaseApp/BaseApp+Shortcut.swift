#if os(macOS) || os(iOS) || os(tvOS)
//
//  BaseApp+Shortcut.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 11.09.2020.
//

#if !os(macOS)
import UIKit

extension BaseApp {
    public class Shortcut: _Titleable, _Enableable, ShortcutBuilderContent {
        public var shortcutBuilderContent: ShortcutBuilderItem { .shortcut(self) }
        
        let item: UIMutableApplicationShortcutItem
        
        var _update = {}
        var _disable = {}
        var _enable = {}
        
        public typealias CompletionHandler = (Bool) -> Void
        var action: ((CompletionHandler) -> Void)?
        
        public init (_ type: String) {
            assert(type.count > 0, "Shortcut type should be set, it should be any unique string")
            item = UIMutableApplicationShortcutItem(type: type, localizedTitle: " ")
        }
        
        // MARK: - _Titleable
        
        var _statedTitle: AnyStringBuilder.Handler?
        var _titleChangeTransition: UIView.AnimationOptions?
        
        func _setTitle(_ v: NSAttributedString?) {
            item.localizedTitle = v?.string ?? "NO_TITLE"
            _update()
        }
        
        // MARK: - _Enableable
        
        func _setEnabled(_ v: Bool) {
            if v {
                _enable()
            } else {
                _disable()
            }
        }
        
        // MARK: - Methods
        
        @discardableResult
        public func subTitle(_ v: String) -> Self {
            item.localizedSubtitle = v
            return self
        }
        
        @discardableResult
        public func icon(_ v: UIApplicationShortcutIcon?) -> Self {
            item.icon = v
            return self
        }
        
        @discardableResult
        public func icon(type: UIApplicationShortcutIcon.IconType) -> Self {
            item.icon = .init(type: type)
            return self
        }
        
        @discardableResult
        public func targetContentIdentifier(_ v: Any?) -> Self {
            item.targetContentIdentifier = v
            return self
        }
        
        @discardableResult
        public func targetContentIdentifier(_ v: [String : NSSecureCoding]?) -> Self {
            item.userInfo = v
            return self
        }
        
        @discardableResult
        public func action(_ v: @escaping (CompletionHandler) -> Void) -> Self {
            action = v
            return self
        }
    }
}
#endif
#endif
