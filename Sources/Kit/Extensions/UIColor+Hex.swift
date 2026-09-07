#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
public typealias UColor = Color
#else
public typealias UColor = UIColor
extension UColor {
    public var current: UIColor { self }
}
#endif

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension UColor {
    public convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        #if os(macOS)
        self.init(NSColor.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0))
        #else
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
        #endif
    }
    
    public convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

extension Int {
    public var color: UColor {
        UColor(netHex: self)
    }
}
#endif
