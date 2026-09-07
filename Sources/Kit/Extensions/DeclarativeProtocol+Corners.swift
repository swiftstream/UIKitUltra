#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit

extension DeclarativeProtocol {
    @discardableResult
    public func circle() -> Self {
        _declarativeView._properties.circleCorners = true
        return self
    }
    
    @discardableResult
    public func corners(_ radius: CGFloat) -> Self {
        _declarativeView._properties.circleCorners = false
        declarativeView.wantsLayer = true
        declarativeView.layer?.cornerRadius = radius
        return self
    }
    
    @discardableResult
    public func corners(_ state: State<CGFloat>) -> Self {
        corners(state.wrappedValue)
        state.listen { [weak self] new in
            self?.corners(new)
        }
        .hold(in: _declarativeView._properties.stateBindingHolder)
        return self
    }
}
#else
import UIKit

extension DeclarativeProtocol {
    @discardableResult
    public func circle() -> Self {
        _declarativeView._properties.circleCorners = true
        _declarativeView._properties.customCorners = nil
        return self
    }
    
    @discardableResult
    public func corners(_ radius: CGFloat, _ corners: [UIRectCorner]) -> Self {
        _declarativeView._properties.circleCorners = false
        _declarativeView._properties.customCorners = nil
        guard corners.count > 0 else {
            declarativeView.layer.cornerRadius = radius
            declarativeView.layoutIfNeeded()
            return self
        }
        _declarativeView._properties.customCorners = CustomCorners(radius: radius, corners: corners)
        return self
    }
    
    @discardableResult
    public func corners(_ radius: CGFloat, _ corners: UIRectCorner...) -> Self {
        self.corners(radius, corners)
    }
    
    @discardableResult
    public func corners(_ state: State<CGFloat>) -> Self {
        corners(state.wrappedValue)
        state.listen { [weak self] new in
            self?.corners(new)
        }
        .hold(in: _declarativeView._properties.stateBindingHolder)
        return self
    }
}
#endif
#endif
