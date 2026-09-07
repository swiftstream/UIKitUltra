#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension DeclarativeProtocol {
    @discardableResult
    public func removeAllConstraints() -> Self {
        // Solo
        _declarativeView._properties.appliedPreConstraintsSolo.forEach { $0.constraint?.isActive = false }
        _declarativeView._properties.notAppliedPreConstraintsSolo.removeAll()
        _declarativeView._properties.appliedPreConstraintsSolo.removeAll()
        // Super
        _declarativeView._properties.appliedPreConstraintsSuper.forEach { $0.constraint?.isActive = false }
        _declarativeView._properties.notAppliedPreConstraintsSuper.removeAll()
        _declarativeView._properties.appliedPreConstraintsSuper.removeAll()
        // Relative
        _declarativeView._properties.appliedPreConstraintsRelative.forEach { $0.constraint?.isActive = false }
        _declarativeView._properties.notAppliedPreConstraintsRelative.removeAll()
        _declarativeView._properties.appliedPreConstraintsRelative.removeAll()
        return self
    }
    
    @discardableResult
    public func deapplyAllConstraints() -> Self {
        // Solo
        _declarativeView._properties.appliedPreConstraintsSolo.forEach { $0.constraint?.isActive = false }
        _declarativeView._properties.notAppliedPreConstraintsSolo.append(contentsOf: _declarativeView._properties.appliedPreConstraintsSolo)
        _declarativeView._properties.appliedPreConstraintsSolo.removeAll()
        // Super
        _declarativeView._properties.appliedPreConstraintsSuper.forEach { $0.constraint?.isActive = false }
        _declarativeView._properties.notAppliedPreConstraintsSuper.append(contentsOf: _declarativeView._properties.appliedPreConstraintsSuper)
        _declarativeView._properties.appliedPreConstraintsSuper.removeAll()
        // Relative
        _declarativeView._properties.appliedPreConstraintsRelative.forEach { $0.constraint?.isActive = false }
        _declarativeView._properties.notAppliedPreConstraintsRelative.append(contentsOf: _declarativeView._properties.appliedPreConstraintsRelative)
        _declarativeView._properties.appliedPreConstraintsRelative.removeAll()
        return self
    }
}
#endif
