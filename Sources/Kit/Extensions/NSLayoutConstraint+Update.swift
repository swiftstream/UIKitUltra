#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension NSLayoutConstraint {
    @discardableResult
    func update(_ value: ConstraintValue) -> NSLayoutConstraint {
        constant = value.constraintValue.value
        #if !os(macOS)
        priority = value.constraintValue.priority
        #endif
        return self
    }
}
#endif
