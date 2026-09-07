#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension Int: ConstraintValue {
    public var constraintValue: ConstraintValueType {
        .init(.equal, CGFloat(self))
    }
}

extension Double: ConstraintValue {
    public var constraintValue: ConstraintValueType {
        .init(.equal, CGFloat(self))
    }
}

extension CGFloat: ConstraintValue {
    public var constraintValue: ConstraintValueType {
        .init(.equal, self)
    }
}
#endif
