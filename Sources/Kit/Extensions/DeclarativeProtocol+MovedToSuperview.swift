#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension DeclarativeProtocol {
    func movedToSuperview() {
        for constraint in _declarativeView._properties.notAppliedPreConstraintsSolo {
            declarativeView.activateSolo(constraint)
        }
        for constraint in _declarativeView._properties.notAppliedPreConstraintsSuper {
            declarativeView.activateSuper(constraint)
        }
        for constraint in _declarativeView._properties.notAppliedPreConstraintsRelative {
            declarativeView.activateRelative(constraint)
        }
        NotificationCenter.default.post(raw: AddedViewWithTag(tag))
    }
}
#endif
