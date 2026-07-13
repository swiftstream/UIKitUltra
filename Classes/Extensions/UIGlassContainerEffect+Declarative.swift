#if os(iOS) || os(tvOS)
import UIKit

@available(iOS 26.0, tvOS 26.0, *)
extension UIGlassContainerEffect {
    @discardableResult
    public func spacing(_ value: CGFloat) -> Self {
        spacing = value
        return self
    }
}
#endif
