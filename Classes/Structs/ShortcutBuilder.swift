//
//  ShortcutBuilder.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 11.09.2020.
//

#if !os(macOS)
import UIKit

@MainActor
public protocol ShortcutBuilderContent {
    var shortcutBuilderContent: ShortcutBuilderItem { get }
}

public enum ShortcutBuilderItem {
    case none
    case shortcut(BaseApp.Shortcut)
    case items([ShortcutBuilderItem])
}

struct _ShortcutContent: ShortcutBuilderContent {
    let shortcutBuilderContent: ShortcutBuilderItem
}

@MainActor
@resultBuilder public struct ShortcutBuilder {
    public typealias Block = () -> ShortcutBuilderContent

    public static func buildBlock() -> ShortcutBuilderContent {
        _ShortcutContent(shortcutBuilderContent: .none)
    }

    public static func buildBlock(_ attrs: ShortcutBuilderContent...) -> ShortcutBuilderContent {
        buildBlock(attrs)
    }

    public static func buildBlock(_ attrs: [ShortcutBuilderContent]) -> ShortcutBuilderContent {
        _ShortcutContent(shortcutBuilderContent: .items(attrs.map { $0.shortcutBuilderContent }))
    }

    public static func buildIf(_ content: ShortcutBuilderContent?) -> ShortcutBuilderContent {
        guard let content = content else { return _ShortcutContent(shortcutBuilderContent: .none) }
        return _ShortcutContent(shortcutBuilderContent: .items([content.shortcutBuilderContent]))
    }

    public static func buildEither(first: ShortcutBuilderContent) -> ShortcutBuilderContent {
        _ShortcutContent(shortcutBuilderContent: .items([first.shortcutBuilderContent]))
    }

    public static func buildEither(second: ShortcutBuilderContent) -> ShortcutBuilderContent {
        _ShortcutContent(shortcutBuilderContent: .items([second.shortcutBuilderContent]))
    }
}
#endif
