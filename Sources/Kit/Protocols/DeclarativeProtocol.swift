#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
public protocol DeclarativeProtocol: AnyObject {
    associatedtype V: BaseView, DeclarativeProtocol = Self
    
    var declarativeView: V { get }
    var properties: Properties<V> { get set }
    
    // MARK: Public Constraints
    
    var height: CGFloat { get set }
    var width: CGFloat { get set }
    var top: CGFloat { get set }
    var leading: CGFloat { get set }
    var left: CGFloat { get set }
    var trailing: CGFloat { get set }
    var right: CGFloat { get set }
    var bottom: CGFloat { get set }
    var centerX: CGFloat { get set }
    var centerY: CGFloat { get set }
    
    var tag: Int { get set }
}
protocol AnyDeclarativeProtocol: DeclarativeProtocol, _BackgroundColorable {}
#endif
