#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import Foundation
import UIKit

extension UICollectionView {
    @discardableResult
    public func register(_ cellClass: Cellable.Type...) -> Self {
        cellClass.forEach { register($0, forCellWithReuseIdentifier: $0.reuseIdentifier) }
        return self
    }
    
    public func dequeueReusableCell<T: Cellable>(with class: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: `class`.reuseIdentifier, for: indexPath) as! T
    }
}
#endif
#endif
