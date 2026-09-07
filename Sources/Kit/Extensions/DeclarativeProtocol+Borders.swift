#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension DeclarativeProtocol {
    private func _setBorderWidth(_ width: CGFloat) {
        #if os(macOS)
        declarativeView.wantsLayer = true
        #endif
        _declarativeView._properties.borders.views.forEach { $0.value.removeFromSuperview() }
        _declarativeView._properties.borders.views.removeAll()
        #if os(macOS)
        declarativeView.layer?.borderWidth = width
        #else
        declarativeView.layer.borderWidth = width
        #endif
    }
    
    private func _applyBorderColor(_ color: UColor) {
        #if os(macOS)
        properties.borderColor.changeHandler = nil
        properties.borderColor = color
        declarativeView.layer?.borderColor = color.current.cgColor
        properties.borderColor.onChange { [weak self] new in
            self?.declarativeView.layer?.borderColor = new.cgColor
        }
        #else
        properties.borderColor = color
        declarativeView.layer.borderColor = color.cgColor
        properties.traitCollectionDidChangeHandlers[.borderColor] = { [weak self] _ in
            self?.declarativeView.layer.borderColor = color.cgColor
        }
        #endif
    }

    private func _setBorderColor(_ color: State<UColor>) {
        _applyBorderColor(color.wrappedValue)
        color.listen { [weak self] _, newColor in
            self?._applyBorderColor(newColor)
        }
        .hold(in: _declarativeView._properties.stateBindingHolder)
    }

    @discardableResult
    public func border(_ width: CGFloat, _ colorNumber: Int) -> Self {
        border(width, colorNumber.color)
    }

    @discardableResult
    public func border(_ width: CGFloat, _ color: UColor) -> Self {
        _setBorderWidth(width)
        _applyBorderColor(color)
        return self
    }

    @discardableResult
    public func border(_ width: CGFloat, _ state: State<UColor>) -> Self {
        _setBorderWidth(width)
        _setBorderColor(state)
        return self
    }
    
    @discardableResult
    public func border(_ side: Borders.Side, _ width: CGFloat, _ color: UColor) -> Self {
        let border = UView().background(color)
        declarativeView.body { border }
        switch side {
        case .top:
            NSLayoutConstraint.activate([
                border.leadingAnchor.constraint(equalTo: declarativeView.leadingAnchor),
                border.trailingAnchor.constraint(equalTo: declarativeView.trailingAnchor),
                border.topAnchor.constraint(equalTo: declarativeView.topAnchor),
                border.heightAnchor.constraint(equalToConstant: width)
                ])
        case .left:
            NSLayoutConstraint.activate([
                border.leadingAnchor.constraint(equalTo: declarativeView.leadingAnchor),
                border.topAnchor.constraint(equalTo: declarativeView.topAnchor),
                border.bottomAnchor.constraint(equalTo: declarativeView.bottomAnchor),
                border.widthAnchor.constraint(equalToConstant: width)
                ])
        case .right:
            NSLayoutConstraint.activate([
                border.trailingAnchor.constraint(equalTo: declarativeView.trailingAnchor),
                border.topAnchor.constraint(equalTo: declarativeView.topAnchor),
                border.bottomAnchor.constraint(equalTo: declarativeView.bottomAnchor),
                border.widthAnchor.constraint(equalToConstant: width)
                ])
        case .bottom:
            NSLayoutConstraint.activate([
                border.leadingAnchor.constraint(equalTo: declarativeView.leadingAnchor),
                border.trailingAnchor.constraint(equalTo: declarativeView.trailingAnchor),
                border.bottomAnchor.constraint(equalTo: declarativeView.bottomAnchor),
                border.heightAnchor.constraint(equalToConstant: width)
                ])
        }
        _declarativeView._properties.borders.views[side]?.removeFromSuperview()
        _declarativeView._properties.borders.views.removeValue(forKey: side)
        return self
    }
    
    @discardableResult
    public func border(_ side: Borders.Side, _ width: CGFloat, _ colorNumber: Int) -> Self {
        border(side, width, colorNumber.color)
    }
    
    @discardableResult
    public func removeBorder(_ side: Borders.Side) -> Self {
        _declarativeView._properties.borders.views[side]?.removeFromSuperview()
        _declarativeView._properties.borders.views.removeValue(forKey: side)
        return self
    }
}
#endif
