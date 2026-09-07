#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public enum DeclarativeConstraintCXSide: Int {
    case x, xMargin
    case leading, leadingMargin, left, leftMargin
    case trailing, trailingMargin, right, rightMargin
    var side: NSLayoutConstraint.Attribute {
        switch self {
        case .x: return .centerX
        case .xMargin:
            #if os(macOS)
            return .centerX
            #else
            return .centerXWithinMargins
            #endif
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
        }
    }
}

public enum DeclarativeConstraintCYSide: Int {
    case y, yMargin
    case top, topMargin, bottom, bottomMargin
    var side: NSLayoutConstraint.Attribute {
        switch self {
        case .y: return .centerY
        case .yMargin:
            #if os(macOS)
            return .centerY
            #else
            return .centerYWithinMargins
            #endif
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
