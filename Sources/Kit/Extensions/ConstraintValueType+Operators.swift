#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

prefix operator >=
public prefix func >=(rhs: CGFloat) -> ConstraintValueType {
    .init(.greaterThanOrEqual, rhs)
}

prefix operator >=-
public prefix func >=-(rhs: CGFloat) -> ConstraintValueType {
    .init(.greaterThanOrEqual, -1 * rhs)
}

prefix operator <=
public prefix func <=(rhs: CGFloat) -> ConstraintValueType {
    .init(.lessThanOrEqual, rhs)
}

prefix operator <=-
public prefix func <=-(rhs: CGFloat) -> ConstraintValueType {
    .init(.lessThanOrEqual, -1 * rhs)
}

/// Operator for constraint + multiplier
/// Example:
/// ```swift
///view.left(to: view2, 350 ~ 1.5)
///```
/// `350 ~ 1.5` above means: 350pt with 1.5 multiplier
infix operator ~ : AdditionPrecedence
public func ~(lhs: ConstraintValue, rhs: CGFloat) -> ConstraintValue {
    ConstraintValueType(lhs.constraintValue.relation, lhs.constraintValue.value, rhs, lhs.constraintValue.priority)
}


/// Operator for constraint + layout-priority
/// Example:
/// ```swift
///view.left(to: view2, 350 ! 999)
///```
/// `350 ! 999` above means: 350pt with 999 priority
infix operator ! : AdditionPrecedence
public func !(lhs: ConstraintValue, rhs: UILayoutPriority) -> ConstraintValue {
    ConstraintValueType(lhs.constraintValue.relation, lhs.constraintValue.value, lhs.constraintValue.multiplier, rhs)
}

public func !(lhs: ConstraintValue, rhs: Float) -> ConstraintValue {
    ConstraintValueType(lhs.constraintValue.relation, lhs.constraintValue.value, lhs.constraintValue.multiplier, .init(rhs))
}
#endif
