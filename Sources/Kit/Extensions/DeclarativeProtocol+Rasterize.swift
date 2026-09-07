#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

extension DeclarativeProtocol {
    @discardableResult
    public func rasterize(_ value: Bool = true) -> Self {
        declarativeView.layer.shouldRasterize = true
        declarativeView.layer.rasterizationScale = UIScreen.main.scale
        return self
    }
}
#endif
#endif
