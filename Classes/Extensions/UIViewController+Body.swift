#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension BaseViewController {
    @discardableResult
    @MainActor
    public func body(@BodyBuilder block: BodyBuilder.SingleView) -> Self {
        view.body { block() }
        return self
    }
}
