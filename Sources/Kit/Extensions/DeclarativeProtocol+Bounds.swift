#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension DeclarativeProtocol {
    #if !os(macOS)
    @discardableResult
    public func clipsToBounds(_ value: Bool = true) -> Self {
        declarativeView.clipsToBounds = value
        return self
    }
    #endif
    
    @discardableResult
    public func masksToBounds(_ value: Bool = true) -> Self {
        #if os(macOS)
        declarativeView.layer?.masksToBounds = value
        #else
        declarativeView.layer.masksToBounds = value
        #endif
        return self
    }
}
#endif
