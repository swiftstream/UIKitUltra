#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

enum DeclarativeConstraintAnySide {
    case cx(DeclarativeConstraintCXSide)
    case cy(DeclarativeConstraintCYSide)
    case d(DeclarativeConstraintDSide)
    case x(DeclarativeConstraintXSide)
    case y(DeclarativeConstraintYSide)
    
    var attribute: NSLayoutConstraint.Attribute {
        switch self {
        case .cx(let side): return side.side
        case .cy(let side): return side.side
        case .d(let side): return side.side
        case .x(let side): return side.side
        case .y(let side): return side.side
        }
    }
}
#endif
