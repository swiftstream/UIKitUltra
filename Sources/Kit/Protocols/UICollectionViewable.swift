#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

public protocol UICollectionViewable: UIScrollViewable {
    var _collectionView: UICollectionView { get }
}

extension UICollectionViewable {
    public var _scrollView: UIView { _collectionView }
}
#endif
#endif
