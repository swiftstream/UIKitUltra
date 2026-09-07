#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

public enum StatusBarStyle {
    /// Automatic color. Depends on current iOS theme.
    case `default`
    /// Automatic color. Depends on current iOS theme but inverted.
    case defaultInverted
    /// White color
    case light
    /// Black color
    case dark
    #if !os(tvOS)
    public var rawValue: UIStatusBarStyle {
        switch self {
        case .default:
            return .default
        case .defaultInverted:
            if #available(iOS 13.0, *) {
                if UITraitCollection.current.userInterfaceStyle == .dark {
                    return .darkContent
                }
                else {
                    return .lightContent
                }
            }
            return .default
        case .light:
            return .lightContent
        case .dark:
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                return .default
            }
        }
    }
    
    public static func from(_ style: UIStatusBarStyle) -> StatusBarStyle {
        switch style {
        case .default: return .default
        case .lightContent: return .light
        case .darkContent: return .dark
        @unknown default: return .default
        }
    }
    #endif
}
#endif
#endif
