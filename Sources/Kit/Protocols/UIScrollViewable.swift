#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

public protocol UIScrollViewable: UIViewable {
    var _scrollView: UIScrollView { get }
}

extension UIScrollViewable {
    public var _view: UIView { _scrollView }
}
#endif
#endif
