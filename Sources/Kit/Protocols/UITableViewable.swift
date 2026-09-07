#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

public protocol UITableViewable: UIScrollViewable {
    var _tableView: UITableView { get }
}

extension UITableViewable {
    public var _scrollView: UIView { _tableView }
}
#endif
#endif
