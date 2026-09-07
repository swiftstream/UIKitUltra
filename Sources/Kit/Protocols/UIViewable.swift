#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
public protocol UIViewable: DeclarativeProtocol {
    var _view: BaseView { get }
}

extension UIViewable {
    @MainActor
    public var _view: BaseView { declarativeView }
}
#endif
