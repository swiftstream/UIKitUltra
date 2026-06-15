import Foundation

@resultBuilder public struct AnyStringBuilder {
    public typealias Handler = () -> AnyString
    
    public static func buildBlock() -> AnyString { "" }
    
    @MainActor
    public static func buildBlock(_ string: AnyString...) -> AnyString {
        buildBlock(string)
    }
    
    @MainActor
    public static func buildBlock(_ string: [AnyString]) -> AnyString {
        AttrStr(anyStrings: string)
    }
    
    public static func buildIf(_ content: AnyString?) -> AnyString {
        guard let content = content else { return "" }
        return content
    }
    
    public static func buildEither(first: AnyString) -> AnyString {
        first
    }

    public static func buildEither(second: AnyString) -> AnyString {
        second
    }
}
