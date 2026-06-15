#if os(macOS)
import AppKit
#else
import UIKit
#endif

public enum BodyBuilderItem {
    case none
    case single(BaseView)
    case multiple([BaseView])
    case nested([BodyBuilderItemable])
    case forEach(AnyForEach)
}
@MainActor
public protocol BodyBuilderItemable {
    var bodyBuilderItem: BodyBuilderItem { get }
}
public struct EmptyBodyBuilderItem: BodyBuilderItemable {
    public var bodyBuilderItem: BodyBuilderItem { .none }
}
extension BaseView: BodyBuilderItemable {
    public var bodyBuilderItem: BodyBuilderItem { .single(self) }
}
extension Array: BodyBuilderItemable where Element: BaseView {
    public var bodyBuilderItem: BodyBuilderItem { .multiple(self) }
}
extension Optional: BodyBuilderItemable where Wrapped: BaseView {
    public var bodyBuilderItem: BodyBuilderItem {
        switch self {
        case .none: return .none
        case .some(let value): return .single(value)
        }
    }
}
