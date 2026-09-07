#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public struct ConstraintValueType: ConstraintValue {
    public var constraintValue: ConstraintValueType { self }
    
    let relation: NSLayoutConstraint.Relation
    let value, multiplier: CGFloat
    let priority: UILayoutPriority
    
    init (_ mode: NSLayoutConstraint.Relation = .equal,
          _ value: CGFloat,
          _ multiplier: CGFloat = 1,
          _ priority: UILayoutPriority = .init(1000)) {
        self.relation = mode
        self.value = value
        self.multiplier = multiplier
        self.priority = priority
    }
}
#endif
