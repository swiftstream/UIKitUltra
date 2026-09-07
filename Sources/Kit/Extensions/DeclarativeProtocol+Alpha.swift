#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension DeclarativeProtocol {
    public var alpha: State<CGFloat> { properties.$alpha }
    
    @discardableResult
    public func alpha(_ alpha: CGFloat) -> Self {
        #if os(macOS)
        declarativeView.alphaValue = alpha
        #else
        declarativeView.alpha = alpha
        #endif
        properties.alpha = alpha
        return self
    }
    
    @discardableResult
    public func alpha(_ state: State<CGFloat>) -> Self {
        alpha(state.wrappedValue)
        state.listen { [weak self] new in
            self?.alpha(new)
        }
        .hold(in: _declarativeView._properties.stateBindingHolder)
        return self
    }
}
#endif
