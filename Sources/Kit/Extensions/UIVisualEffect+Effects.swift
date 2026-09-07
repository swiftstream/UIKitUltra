#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

extension UIVisualEffect {
    public static var darkBlur: UIVisualEffect { UIBlurEffect(style: .dark) }
    public static var lightBlur: UIVisualEffect { UIBlurEffect(style: .light) }
    public static var extraLightBlur: UIVisualEffect { UIBlurEffect(style: .extraLight) }
    @available(iOS 10.0, *)
    public static var prominentBlur: UIVisualEffect {UIBlurEffect(style: .prominent) }
    @available(iOS 10.0, *)
    public static var regularBlur: UIVisualEffect { UIBlurEffect(style: .regular) }
}
#endif
#endif
