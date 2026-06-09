#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension DeclarativeProtocol {
    public var opacity: State<Float> { properties.$opacity }
    
    @discardableResult
    public func opacity(_ opacity: Float) -> Self {
        #if os(macOS)
        declarativeView.layer?.opacity = opacity
        #else
        declarativeView.layer.opacity = opacity
        #endif
        return self
    }
    
    @discardableResult
    public func opacity(_ state: State<Float>) -> Self {
        #if os(macOS)
        declarativeView.layer?.opacity = state.wrappedValue
        #else
        declarativeView.layer.opacity = state.wrappedValue
        #endif
        properties.opacity = state.wrappedValue
        state.listen { [weak self] new in
            #if os(macOS)
            self?.declarativeView.layer?.opacity = new
            #else
            self?.declarativeView.layer.opacity = new
            #endif
            self?.properties.opacity = new
        }
        .hold(in: _declarativeView._properties.stateBindingHolder)
        return self
    }
}
