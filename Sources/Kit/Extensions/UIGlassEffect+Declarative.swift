#if os(macOS) || os(iOS) || os(tvOS)
#if os(iOS) || os(tvOS)
import UIKit

@available(iOS 26.0, tvOS 26.0, *)
extension UIGlassEffect {
    @discardableResult
    public func tintColor(_ value: UIColor?) -> Self {
        tintColor = value
        return self
    }

    @discardableResult
    public func interactive(_ value: Bool = true) -> Self {
        isInteractive = value
        return self
    }
}
#endif
#endif
