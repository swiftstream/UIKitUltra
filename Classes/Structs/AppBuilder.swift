//
//  AppBuilder.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 10.09.2020.
//

#if !os(macOS)
import UIKit

@MainActor
public protocol AppBuilderContent {
    var appBuilderContent: AppBuilderItem { get }
}

public enum AppBuilderItem {
    case none
    case lifecycle(LifecycleBuilderProtocol)
    case mainScene(BaseApp.MainScene)
    case scene(BaseApp.Scene)
    case shortcuts(BaseApp.Shortcuts)
    case items([AppBuilderItem])
}

struct _AppContent: AppBuilderContent {
    let appBuilderContent: AppBuilderItem
}

@resultBuilder public struct AppBuilder {
    public typealias Block = () -> AppBuilderContent

    @MainActor
    public static func buildBlock() -> AppBuilderContent {
        _AppContent(appBuilderContent: .none)
    }

    @MainActor
    public static func buildBlock(_ attrs: AppBuilderContent...) -> AppBuilderContent {
        buildBlock(attrs)
    }

    @MainActor
    public static func buildBlock(_ attrs: [AppBuilderContent]) -> AppBuilderContent {
        _AppContent(appBuilderContent: .items(attrs.map { $0.appBuilderContent }))
    }

    @MainActor
    public static func buildIf(_ content: AppBuilderContent?) -> AppBuilderContent {
        guard let content = content else { return _AppContent(appBuilderContent: .none) }
        return _AppContent(appBuilderContent: .items([content.appBuilderContent]))
    }

    @MainActor
    public static func buildEither(first: AppBuilderContent) -> AppBuilderContent {
        _AppContent(appBuilderContent: .items([first.appBuilderContent]))
    }

    @MainActor
    public static func buildEither(second: AppBuilderContent) -> AppBuilderContent {
        _AppContent(appBuilderContent: .items([second.appBuilderContent]))
    }
}
#endif
