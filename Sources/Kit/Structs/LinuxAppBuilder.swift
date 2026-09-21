#if os(Linux) && ULTRA_GTK_BACKEND

@MainActor
public protocol AppBuilderContent {
    var appBuilderContent: AppBuilderItem { get }
}

@MainActor
public enum AppBuilderItem {
    case none
    case windows([Window])
    case items([AppBuilderItem])

    package func _windows() -> [Window] {
        switch self {
        case .none:
            return []
        case .windows(let windows):
            return windows
        case .items(let items):
            return items.flatMap { $0._windows() }
        }
    }
}

@MainActor
struct _AppContent: AppBuilderContent {
    let appBuilderContent: AppBuilderItem
}

@resultBuilder
public struct AppBuilder {
    public typealias Block = @MainActor () -> AppBuilderContent

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
        guard let content else { return _AppContent(appBuilderContent: .none) }
        return _AppContent(appBuilderContent: .items([content.appBuilderContent]))
    }

    @MainActor
    public static func buildEither(first content: AppBuilderContent) -> AppBuilderContent {
        _AppContent(appBuilderContent: .items([content.appBuilderContent]))
    }

    @MainActor
    public static func buildEither(second content: AppBuilderContent) -> AppBuilderContent {
        _AppContent(appBuilderContent: .items([content.appBuilderContent]))
    }
}

#endif
