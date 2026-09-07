#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension DeclarativeProtocol {
    #if os(macOS)
    @discardableResult
    public func contentHuggingPriority(
        _ priority: NSLayoutConstraint.Priority,
        for orientation: NSLayoutConstraint.Orientation
    ) -> Self {
        declarativeView.setContentHuggingPriority(priority, for: orientation)
        return self
    }
    #else
    @discardableResult
    public func contentHuggingPriority(
        _ priority: UILayoutPriority,
        for axis: NSLayoutConstraint.Axis
    ) -> Self {
        declarativeView.setContentHuggingPriority(priority, for: axis)
        return self
    }

    @discardableResult
    public func huggingPriority(x value: UILayoutPriority) -> Self {
        declarativeView.setContentHuggingPriority(value, for: .horizontal)
        return self
    }
    
    @discardableResult
    public func huggingPriority(y value: UILayoutPriority) -> Self {
        declarativeView.setContentHuggingPriority(value, for: .vertical)
        return self
    }
    
    @discardableResult
    public func huggingPriority(x value: Float) -> Self {
        declarativeView.setContentHuggingPriority(.init(value), for: .horizontal)
        return self
    }
    
    @discardableResult
    public func huggingPriority(y value: Float) -> Self {
        declarativeView.setContentHuggingPriority(.init(value), for: .vertical)
        return self
    }
    #endif
}
#endif
