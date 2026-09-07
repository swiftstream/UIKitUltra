#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

public protocol UILabelable: UIViewable {
    var _label: UILabel { get }
}

extension UILabelable {
    public var _view: UIView { _label }
}
#endif
#endif
