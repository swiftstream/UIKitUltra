#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

extension UColor {
    public func alpha(_ value: CGFloat) -> UColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return UColor(red: red, green: green, blue: blue, alpha: value)
    }
}
#endif
#endif
