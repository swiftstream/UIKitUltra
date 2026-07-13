#if os(iOS) || os(tvOS)
import UIKit

@available(iOS 26.0, tvOS 26.0, *)
extension DeclarativeProtocol {
    @discardableResult
    public func cornerConfiguration(_ value: UICornerConfiguration) -> Self {
        declarativeView.cornerConfiguration = value
        return self
    }
}
#endif
