#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

public protocol UIButtonable: UIViewable {
    var _button: UIButton { get }
}

extension UIButtonable {
    public var _view: UIView { _button }
}
#endif
#endif
