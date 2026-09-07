#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension DeclarativeProtocol {
    public func focusToNextResponderOrResign() {
        if let nextResponder = declarativeView.viewWithTagInSuperview(tag + 1) {
            nextResponder.becomeFirstResponder()
        } else {
            declarativeView.resignFirstResponder()
        }
    }
}
#endif
