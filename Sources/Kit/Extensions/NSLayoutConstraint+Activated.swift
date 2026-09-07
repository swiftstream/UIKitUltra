#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension NSLayoutConstraint {
    @discardableResult
    func activated() -> NSLayoutConstraint {
        isActive = true
        return self
    }
}
#endif
