#if os(macOS)
import AppKit
#else
import UIKit
#endif

@available(*, deprecated, renamed: "BodyBuilder")
public typealias ViewBuilder = BodyBuilder

@resultBuilder public struct BodyBuilder {
    public typealias Result = BodyBuilderItemable
    public typealias SingleView = @MainActor () -> Result
    
    /// Builds an empty view from an block containing no statements, `{ }`.
    public static func buildBlock() -> Result { [] }
    
    /// Passes a single view written as a child view (e..g, `{ Text("Hello") }`) through unmodified.
    public static func buildBlock(_ attrs: BodyBuilderItemable...) -> Result {
        buildBlock(attrs)
    }
    
    /// Passes a single view written as a child view (e..g, `{ Text("Hello") }`) through unmodified.
    public static func buildBlock(_ attrs: [BodyBuilderItemable]) -> Result {
        BodyBuilderItems(items: attrs)
    }
    
    /// Provides support for "if" statements in multi-statement closures, producing an `Optional` view
    /// that is visible only when the `if` condition evaluates `true`.
    public static func buildIf(_ content: BodyBuilderItemable?) -> Result {
        guard let content = content else { return EmptyBodyBuilderItem() }
        return content
    }
    
    /// Provides support for "if" statements in multi-statement closures, producing
    /// ConditionalContent for the "then" branch.
    public static func buildEither(first: BodyBuilderItemable) -> Result {
        first
    }

    /// Provides support for "if-else" statements in multi-statement closures, producing
    /// ConditionalContent for the "else" branch.
    public static func buildEither(second: BodyBuilderItemable) -> Result {
        second
    }
}

extension BaseViewController: BodyBuilderItemable {
    public var bodyBuilderItem: BodyBuilderItem {
        .single(UView(inline: view).edgesToSuperview())
    }
}
