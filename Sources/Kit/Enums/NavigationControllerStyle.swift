#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

public enum NavigationControllerStyle {
    case `default`, transparent
    case color(UColor)
}
#endif
#endif
