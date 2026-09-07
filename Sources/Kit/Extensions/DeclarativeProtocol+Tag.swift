#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension DeclarativeProtocol {
    @discardableResult
    public func tag(_ value: Int) -> Self {
        tag = value
        return self
    }
}
#endif
