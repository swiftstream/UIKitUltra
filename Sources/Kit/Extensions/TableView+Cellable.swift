#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)

#else
import UIKit

extension UITableView {
    @discardableResult
    public func register(_ cellClass: Cellable.Type...) -> Self {
        cellClass.forEach { register($0, forCellReuseIdentifier: $0.reuseIdentifier) }
        return self
    }
    
    public func dequeueReusableCell<T: Cellable>(with class: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withIdentifier: `class`.reuseIdentifier, for: indexPath) as! T
    }
}
#endif
#endif
