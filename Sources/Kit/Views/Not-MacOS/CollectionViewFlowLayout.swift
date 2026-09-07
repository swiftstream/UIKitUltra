#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

@available(*, deprecated, renamed: "UCollectionViewFlowLayout")
public typealias CollectionViewFlowLayout = UCollectionViewFlowLayout

open class UCollectionViewFlowLayout: UICollectionViewFlowLayout {
    public override init () {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func itemSize(_ size: CGSize) -> Self {
        itemSize = size
        return self
    }
    
    @discardableResult
    public func itemSize(_ width: CGFloat, _ height: CGFloat) -> Self {
        itemSize(.init(width: width, height: height))
    }
    
    @discardableResult
    public func itemSize(_ size: CGFloat) -> Self {
        itemSize(.init(width: size, height: size))
    }
    
    @discardableResult
    public func estimatedItemSize(_ size: CGSize) -> Self {
        estimatedItemSize = size
        return self
    }
    
    @discardableResult
    public func estimatedItemSize(_ width: CGFloat, _ height: CGFloat) -> Self {
        estimatedItemSize(.init(width: width, height: height))
    }
    
    @discardableResult
    public func estimatedItemSize(_ size: CGFloat) -> Self {
        estimatedItemSize(.init(width: size, height: size))
    }
    
    @discardableResult
    public func minimumInteritemSpacing(_ value: CGFloat) -> Self {
        minimumInteritemSpacing = value
        return self
    }
    
    @discardableResult
    public func minimumLineSpacing(_ value: CGFloat) -> Self {
        minimumLineSpacing = value
        return self
    }
    
    @discardableResult
    public func scrollDirection(_ direction: UICollectionView.ScrollDirection) -> Self {
        scrollDirection = direction
        return self
    }
    
    @discardableResult
    public func sectionInset(_ sectionInset: UIEdgeInsets) -> Self {
        self.sectionInset = sectionInset
        return self
    }
    
    @discardableResult
    public func sectionInset(top: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0, bottom: CGFloat = 0) -> Self {
        sectionInset(.init(top: top, left: left, bottom: bottom, right: right))
    }
    
    @discardableResult
    public func sectionInset(x: CGFloat, y: CGFloat) -> Self {
        sectionInset(.init(top: y, left: x, bottom: y, right: x))
    }
    
    @discardableResult
    public func sectionInset(_ value: CGFloat) -> Self {
        sectionInset(.init(top: value, left: value, bottom: value, right: value))
    }
}
#endif
#endif
