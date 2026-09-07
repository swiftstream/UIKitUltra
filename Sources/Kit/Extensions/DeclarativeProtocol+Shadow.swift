#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension DeclarativeProtocol {
    @discardableResult
    public func shadow(_ colorNumber: Int, opacity: Float = 1, x: CGFloat = 0, y: CGFloat = 0, radius: CGFloat = 10) -> Self {
        shadow(colorNumber.color, opacity: opacity, x: x, y: y, radius: radius)
    }
    
    @discardableResult
    public func shadow(_ color: UColor = .black, opacity: Float = 1, x: CGFloat = 0, y: CGFloat = 0, radius: CGFloat = 10) -> Self {
        _setShadow(x: x, y: y)
        _setShadow(opacity: opacity)
        _setShadow(radius: radius)
        _applyShadowColor(color)
        return self
    }

    @discardableResult
    public func shadow(_ state: State<UColor>, opacity: Float = 1, x: CGFloat = 0, y: CGFloat = 0, radius: CGFloat = 10) -> Self {
        _setShadow(x: x, y: y)
        _setShadow(opacity: opacity)
        _setShadow(radius: radius)
        _setShadow(color: state)
        return self
    }

    private func _applyShadowColor(_ color: UColor) {
        #if os(macOS)
        properties.shadowColor.changeHandler = nil
        properties.shadowColor = color
        declarativeView.layer?.shadowColor = color.current.cgColor
        properties.shadowColor.onChange { [weak self] new in
            self?.declarativeView.layer?.shadowColor = new.cgColor
        }
        #else
        properties.shadowColor = color
        declarativeView.layer.shadowColor = color.cgColor
        properties.traitCollectionDidChangeHandlers[.shadowColor] = { [weak self] _ in
            self?.declarativeView.layer.shadowColor = color.cgColor
        }
        #endif
    }

    private func _setShadow(color: State<UColor>) {
        _applyShadowColor(color.wrappedValue)
        color.listen { [weak self] _, newColor in
            self?._applyShadowColor(newColor)
        }
        .hold(in: _declarativeView._properties.stateBindingHolder)
    }
    
    private func _setShadow(opacity: Float) {
        #if os(macOS)
        declarativeView.layer?.shadowOpacity = opacity
        #else
        declarativeView.layer.shadowOpacity = opacity
        #endif
    }
    
    private func _setShadow(x: CGFloat, y: CGFloat) {
        #if os(macOS)
        declarativeView.wantsLayer = true
        declarativeView.shadow = NSShadow()
        declarativeView.layer?.shadowOffset = CGSize(width: x, height: y)
        #else
        declarativeView.layer.shadowOffset = CGSize(width: x, height: y)
        #endif
    }
    
    private func _setShadow(radius: CGFloat) {
        #if os(macOS)
        declarativeView.layer?.shadowRadius = radius
        #else
        declarativeView.layer.shadowRadius = radius
        #endif
    }
}
#endif
