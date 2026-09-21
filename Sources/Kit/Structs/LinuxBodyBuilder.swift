#if os(Linux) && ULTRA_GTK_BACKEND

import UltraGTK

@MainActor
public enum BodyBuilderItem {
    case none
    case single(BodyBuilderItemable)
    case multiple([BodyBuilderItemable])
    case nested([BodyBuilderItemable])

    package func _flatten() -> [BodyBuilderItemable] {
        switch self {
        case .none:
            return []
        case .single(let item):
            return [item]
        case .multiple(let items), .nested(let items):
            return items.flatMap { $0.bodyBuilderItem._flatten() }
        }
    }
}

@MainActor
public protocol BodyBuilderItemable: AnyObject {
    var bodyBuilderItem: BodyBuilderItem { get }
}

extension GTKView: BodyBuilderItemable {
    public var bodyBuilderItem: BodyBuilderItem { .single(self) }
}

@MainActor
public final class EmptyBodyBuilderItem: BodyBuilderItemable {
    public init() {}

    public var bodyBuilderItem: BodyBuilderItem { .none }
}

@MainActor
final class _BodyBuilderContent: BodyBuilderItemable {
    let bodyBuilderItem: BodyBuilderItem

    init(_ bodyBuilderItem: BodyBuilderItem) {
        self.bodyBuilderItem = bodyBuilderItem
    }
}

@resultBuilder
public struct BodyBuilder {
    public typealias Result = BodyBuilderItemable
    public typealias SingleView = @MainActor () -> Result

    @MainActor
    public static func buildBlock() -> Result {
        EmptyBodyBuilderItem()
    }

    @MainActor
    public static func buildBlock(_ attrs: BodyBuilderItemable...) -> Result {
        buildBlock(attrs)
    }

    @MainActor
    public static func buildBlock(_ attrs: [BodyBuilderItemable]) -> Result {
        _BodyBuilderContent(.nested(attrs))
    }

    @MainActor
    public static func buildIf(_ content: BodyBuilderItemable?) -> Result {
        guard let content else { return EmptyBodyBuilderItem() }
        return content
    }

    @MainActor
    public static func buildEither(first content: BodyBuilderItemable) -> Result {
        content
    }

    @MainActor
    public static func buildEither(second content: BodyBuilderItemable) -> Result {
        content
    }
}

#endif
