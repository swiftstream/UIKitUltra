#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public enum DeclarativeConstraintXSide: Int {
    case leading, leadingMargin, left, leftMargin, trailing, trailingMargin, right, rightMargin, centerX, centerXMargin
    var side: NSLayoutConstraint.Attribute {
        switch self {
        case .leading: return .leading
        case .leadingMargin:
            #if os(macOS)
            return .leading
            #else
            return .leadingMargin
            #endif
        case .left: return .left
        case .leftMargin:
            #if os(macOS)
            return .left
            #else
            return .leftMargin
            #endif
        case .trailing: return .trailing
        case .trailingMargin:
            #if os(macOS)
            return .trailing
            #else
            return .trailingMargin
            #endif
        case .right: return .right
        case .rightMargin:
            #if os(macOS)
            return .right
            #else
            return .rightMargin
            #endif
        case .centerX: return .centerX
        case .centerXMargin:
            #if os(macOS)
            return .centerX
            #else
            return .centerXWithinMargins
            #endif
        }
    }
}
#endif
