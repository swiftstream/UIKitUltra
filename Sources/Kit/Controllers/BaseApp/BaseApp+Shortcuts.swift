#if os(macOS) || os(iOS) || os(tvOS)
//
//  BaseApp+Shortcuts.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 11.09.2020.
//

#if !os(macOS)
import UIKit

extension BaseApp {
    public class Shortcuts: AppBuilderContent {
        public var appBuilderContent: AppBuilderItem { .shortcuts(self) }
        
        var shortcuts: [Shortcut] = []
        
        public init (@ShortcutBuilder block: ShortcutBuilder.Block) {
            parseShortcutBuilderItem(block().shortcutBuilderContent)
        }
        
        private func parseShortcutBuilderItem(_ item: ShortcutBuilderItem) {
            switch item {
            case .shortcut(let v): shortcuts.append(v)
            case .items(let items): items.forEach { parseShortcutBuilderItem($0) }
            case .none: break
            }
        }
        
        func onChange() -> Self {

            return self
        }
    }
}
#endif
#endif
