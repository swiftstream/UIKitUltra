#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension BaseViewController {
    @discardableResult
    public func body(@BodyBuilder block: BodyBuilder.SingleView) -> Self {
        view.body { block() }
        return self
    }
}
