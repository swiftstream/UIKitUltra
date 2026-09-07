#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension DeclarativeProtocol {
    #if os(macOS)
    @discardableResult
    public func contentCompressionResistancePriority(
        _ priority: NSLayoutConstraint.Priority,
        for orientation: NSLayoutConstraint.Orientation
    ) -> Self {
        declarativeView.setContentCompressionResistancePriority(priority, for: orientation)
        return self
    }
    #else
    @discardableResult
    public func contentCompressionResistancePriority(
        _ priority: UILayoutPriority,
        for axis: NSLayoutConstraint.Axis
    ) -> Self {
        declarativeView.setContentCompressionResistancePriority(priority, for: axis)
        return self
    }
    #endif

    @discardableResult
    public func compressionResistance(x value: UILayoutPriority) -> Self {
        #if !os(macOS)
        declarativeView.setContentCompressionResistancePriority(value, for: .horizontal)
        #endif
        return self
    }
    
    @discardableResult
    public func compressionResistance(y value: UILayoutPriority) -> Self {
        #if !os(macOS)
        declarativeView.setContentCompressionResistancePriority(value, for: .vertical)
        #endif
        return self
    }
    
    @discardableResult
    public func compressionResistance(x value: Float) -> Self {
        declarativeView.setContentCompressionResistancePriority(.init(value), for: .horizontal)
        return self
    }
    
    @discardableResult
    public func compressionResistance(y value: Float) -> Self {
        declarativeView.setContentCompressionResistancePriority(.init(value), for: .vertical)
        return self
    }
}
#endif
