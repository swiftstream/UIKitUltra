#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension NSLayoutConstraint.Attribute {
    #if os(macOS)
    static let all: [NSLayoutConstraint.Attribute] = [.width,
                                                                          .height,
                                                                          .top,
                                                                          .leading,
                                                                          .trailing,
                                                                          .bottom,
                                                                          .centerX,
                                                                          .centerY,
                                                                          .right,
                                                                          .left,
                                                                          .firstBaseline,
                                                                          .lastBaseline,
                                                                          .notAnAttribute]
    #else
    static let all: [NSLayoutConstraint.Attribute] = [.width,
                                                                          .height,
                                                                          .top,
                                                                          .topMargin,
                                                                          .leading,
                                                                          .leadingMargin,
                                                                          .trailing,
                                                                          .trailingMargin,
                                                                          .bottom,
                                                                          .bottomMargin,
                                                                          .centerX,
                                                                          .centerXWithinMargins,
                                                                          .centerY,
                                                                          .centerYWithinMargins,
                                                                          .right,
                                                                          .rightMargin,
                                                                          .left,
                                                                          .leftMargin,
                                                                          .firstBaseline,
                                                                          .lastBaseline,
                                                                          .notAnAttribute]
    #endif
}
