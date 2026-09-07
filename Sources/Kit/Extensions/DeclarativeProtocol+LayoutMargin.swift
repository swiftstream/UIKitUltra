#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

extension DeclarativeProtocol {
    @discardableResult
    public func layoutMargin(top: CGFloat? = nil, left: CGFloat? = nil, right: CGFloat? = nil, bottom: CGFloat? = nil) -> Self {
        if let top = top {
            declarativeView.layoutMargins.top = top
        }
        if let left = left {
            declarativeView.layoutMargins.left = left
        }
        if let right = right {
            declarativeView.layoutMargins.right = right
        }
        if let bottom = bottom {
            declarativeView.layoutMargins.bottom = bottom
        }
        return self
    }
    
    @discardableResult
    public func layoutMargin(x: CGFloat? = nil, y: CGFloat? = nil) -> Self {
        if let y = y {
            declarativeView.layoutMargins.top = y
            declarativeView.layoutMargins.bottom = y
        }
        if let x = x {
            declarativeView.layoutMargins.left = x
            declarativeView.layoutMargins.right = x
        }
        return self
    }
    
    @discardableResult
    public func layoutMargin(_ value: CGFloat) -> Self {
        declarativeView.layoutMargins.top = value
        declarativeView.layoutMargins.bottom = value
        declarativeView.layoutMargins.left = value
        declarativeView.layoutMargins.right = value
        return self
    }
}
#endif
#endif
