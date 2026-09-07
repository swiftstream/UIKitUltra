#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit

extension AnyDeclarativeProtocol {
    @MainActor
    func onLayoutSubviews() {
        if _declarativeView._properties.circleCorners == true {
            if let minSide = [declarativeView.bounds.size.width, declarativeView.bounds.size.height].min() {
                declarativeView.layer?.cornerRadius = minSide / 2
            }
        }
    }
}
#else
import UIKit

extension AnyDeclarativeProtocol {
    @MainActor
    func onLayoutSubviews() {
        if _declarativeView._properties.circleCorners == true {
            if let minSide = [declarativeView.bounds.size.width, declarativeView.bounds.size.height].min() {
                declarativeView.layer.cornerRadius = minSide / 2
            }
        } else if let customCorners = _declarativeView._properties.customCorners {
            if _declarativeView._properties.customCorners?.backgroundColor == nil {
                _declarativeView._properties.customCorners?.backgroundColor = declarativeView.backgroundColor == .clear ? .white : declarativeView.backgroundColor
                background(.clear)
            }
            declarativeView.layer.cornerRadius = 0
            let path = UIBezierPath(roundedRect: declarativeView.bounds,
                                    byRoundingCorners: UIRectCorner(customCorners.corners),
                                    cornerRadii: CGSize(width: customCorners.radius, height: customCorners.radius))
            let maskLayer = CAShapeLayer()
            maskLayer.accessibilityLabel = "maskLayer.accessibilityLabel"
            maskLayer.path = path.cgPath
            maskLayer.fillColor = _declarativeView._properties.customCorners?.backgroundColor?.cgColor ?? UIColor.white.cgColor
            if declarativeView.layer.sublayers?.contains(where: { $0.accessibilityLabel == maskLayer.accessibilityLabel }) == true {
                declarativeView.layer.sublayers?.removeFirst()
            }
            declarativeView.layer.insertSublayer(maskLayer, at: 0)
        }
    }
}
#endif
#endif
