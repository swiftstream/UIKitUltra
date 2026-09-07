#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public enum DeclarativeConstraintYSide: Int {
    case top, topMargin, bottom, bottomMargin
    var side: NSLayoutConstraint.Attribute {
        switch self {
        case .top: return .top
        case .topMargin:
            #if os(macOS)
            return .top
            #else
            return .topMargin
            #endif
        case .bottom: return .bottom
        case .bottomMargin:
            #if os(macOS)
            return .bottom
            #else
            return .bottomMargin
            #endif
        }
    }
}
#endif
