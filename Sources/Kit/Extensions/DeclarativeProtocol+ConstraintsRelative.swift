#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension DeclarativeProtocol {
    private func _createRelative(value: State<CGFloat>,
                                              relation: NSLayoutConstraint.Relation,
                                              multiplier: CGFloat,
                                              priority: UILayoutPriority,
                                              attribute1: NSLayoutConstraint.Attribute,
                                              attribute2: NSLayoutConstraint.Attribute?,
                                              toSafe: Bool,
                                              destinationView: PreConstraintViewable?) -> Self {
        let pc = PreConstraint(value: value,
                                        relation: relation,
                                        multiplier: multiplier,
                                        priority: priority,
                                        attribute1: attribute1,
                                        attribute2: attribute2,
                                        toSafe: toSafe,
                                        fromView: declarativeView,
                                        destinationView: destinationView)
        if let _ = declarativeView.superview {
            declarativeView.activateRelative(pc)
        } else {
            _declarativeView._properties.notAppliedPreConstraintsRelative.append(pc)
        }
        return self
    }
    
    // MARK: - top
    
    @discardableResult
    public func top(to side: DeclarativeConstraintYSide,
                          of view: PreConstraintViewable,
                          _ state: State<CGFloat>,
                          relation: NSLayoutConstraint.Relation = .equal,
                          multiplier: CGFloat = 1,
                          priority: UILayoutPriority = .defaultHigh,
                          safeArea: Bool = false) -> Self {
        _createRelative(value: state,
                        relation: relation,
                        multiplier: multiplier,
                        priority: priority,
                        attribute1: .top,
                        attribute2: side.side,
                        toSafe: safeArea,
                        destinationView: view)
    }
    
    /// By default to `bottom` of destination view
    @discardableResult
    public func top(to view: PreConstraintViewable,
                          _ state: State<CGFloat>,
                          relation: NSLayoutConstraint.Relation = .equal,
                          multiplier: CGFloat = 1,
                          priority: UILayoutPriority = .defaultHigh,
                          safeArea: Bool = false) -> Self {
        top(to: .bottom, of: view, state, relation: relation, multiplier: multiplier, priority: priority, safeArea: safeArea)
    }
    
    @discardableResult
    public func top(to side: DeclarativeConstraintYSide, of view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0), safeArea: Bool = false) -> Self {
        top(to: side,
              of: view,
              .init(wrappedValue: value.constraintValue.value),
              relation: value.constraintValue.relation,
              multiplier: value.constraintValue.multiplier,
              priority: value.constraintValue.priority,
              safeArea: safeArea)
    }
    
    /// By default to `bottom` of destination view
    @discardableResult
    public func top(to view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0), safeArea: Bool = false) -> Self {
        top(to: .bottom, of: view, value, safeArea: safeArea)
    }
    
    // MARK: - leading
    
    @discardableResult
    public func leading(to side: DeclarativeConstraintXSide,
                                of view: PreConstraintViewable,
                                _ state: State<CGFloat>,
                                relation: NSLayoutConstraint.Relation = .equal,
                                multiplier: CGFloat = 1,
                                priority: UILayoutPriority = .defaultHigh,
                                safeArea: Bool = false) -> Self {
        _createRelative(value: state,
                                relation: relation,
                                multiplier: multiplier,
                                priority: priority,
                                attribute1: .leading,
                                attribute2: side.side,
                                toSafe: safeArea,
                                destinationView: view)
    }
    
    /// By default to `trailing` of destination view
    @discardableResult
    public func leading(to view: PreConstraintViewable,
                                _ state: State<CGFloat>,
                                relation: NSLayoutConstraint.Relation = .equal,
                                multiplier: CGFloat = 1,
                                priority: UILayoutPriority = .defaultHigh,
                                safeArea: Bool = false) -> Self {
        leading(to: .trailing, of: view, state, relation: relation, multiplier: multiplier, priority: priority, safeArea: safeArea)
    }
    
    @discardableResult
    public func leading(to side: DeclarativeConstraintXSide, of view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0), safeArea: Bool = false) -> Self {
        leading(to: side,
                   of: view,
                   .init(wrappedValue: value.constraintValue.value),
                   relation: value.constraintValue.relation,
                   multiplier: value.constraintValue.multiplier,
                   priority: value.constraintValue.priority,
                   safeArea: safeArea)
    }
    
    /// By default to `trailing` of destination view
    @discardableResult
    public func leading(to view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0), safeArea: Bool = false) -> Self {
        leading(to: .trailing, of: view, value, safeArea: safeArea)
    }
    
    // MARK: - left
    
    @discardableResult
    public func left(to side: DeclarativeConstraintXSide,
                          of view: PreConstraintViewable,
                          _ state: State<CGFloat>,
                          relation: NSLayoutConstraint.Relation = .equal,
                          multiplier: CGFloat = 1,
                          priority: UILayoutPriority = .defaultHigh,
                          safeArea: Bool = false) -> Self {
        _createRelative(value: state,
                                relation: relation,
                                multiplier: multiplier,
                                priority: priority,
                                attribute1: .left,
                                attribute2: side.side,
                                toSafe: safeArea,
                                destinationView: view)
    }
    
    /// By default to `right` of destination view
    @discardableResult
    public func left(to view: PreConstraintViewable,
                          _ state: State<CGFloat>,
                          relation: NSLayoutConstraint.Relation = .equal,
                          multiplier: CGFloat = 1,
                          priority: UILayoutPriority = .defaultHigh,
                          safeArea: Bool = false) -> Self {
        left(to: .right, of: view, state, relation: relation, multiplier: multiplier, priority: priority, safeArea: safeArea)
    }
    
    @discardableResult
    public func left(to side: DeclarativeConstraintXSide, of view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0), safeArea: Bool = false) -> Self {
        left(to: side,
              of: view,
              .init(wrappedValue: value.constraintValue.value),
              relation: value.constraintValue.relation,
              multiplier: value.constraintValue.multiplier,
              priority: value.constraintValue.priority,
              safeArea: safeArea)
    }
    
    /// By default to `right` of destination view
    @discardableResult
    public func left(to view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0), safeArea: Bool = false) -> Self {
        left(to: .right, of: view, value, safeArea: safeArea)
    }
    
    // MARK: - trailing
    
    @discardableResult
    public func trailing(to side: DeclarativeConstraintXSide,
                                of view: PreConstraintViewable,
                                _ state: State<CGFloat>,
                                relation: NSLayoutConstraint.Relation = .equal,
                                multiplier: CGFloat = 1,
                                priority: UILayoutPriority = .defaultHigh,
                                safeArea: Bool = false) -> Self {
        _createRelative(value: state,
                                relation: relation,
                                multiplier: multiplier,
                                priority: priority,
                                attribute1: .trailing,
                                attribute2: side.side,
                                toSafe: safeArea,
                                destinationView: view)
    }
    
    /// By default to `leading` of destination view
    @discardableResult
    public func trailing(to view: PreConstraintViewable,
                                _ state: State<CGFloat>,
                                relation: NSLayoutConstraint.Relation = .equal,
                                multiplier: CGFloat = 1,
                                priority: UILayoutPriority = .defaultHigh,
                                safeArea: Bool = false) -> Self {
        trailing(to: .leading, of: view, state, relation: relation, multiplier: multiplier, priority: priority, safeArea: safeArea)
    }
    
    @discardableResult
    public func trailing(to side: DeclarativeConstraintXSide, of view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0), safeArea: Bool = false) -> Self {
        trailing(to: side,
                   of: view,
                   .init(wrappedValue: value.constraintValue.value),
                   relation: value.constraintValue.relation,
                   multiplier: value.constraintValue.multiplier,
                   priority: value.constraintValue.priority,
                   safeArea: safeArea)
    }
    
    /// By default to `leading` of destination view
    @discardableResult
    public func trailing(to view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0), safeArea: Bool = false) -> Self {
        trailing(to: .leading, of: view, value, safeArea: safeArea)
    }
    
    // MARK: - right
    
    @discardableResult
    public func right(to side: DeclarativeConstraintXSide,
                            of view: PreConstraintViewable,
                            _ state: State<CGFloat>,
                            relation: NSLayoutConstraint.Relation = .equal,
                            multiplier: CGFloat = 1,
                            priority: UILayoutPriority = .defaultHigh,
                            safeArea: Bool = false) -> Self {
        _createRelative(value: state,
                                relation: relation,
                                multiplier: multiplier,
                                priority: priority,
                                attribute1: .right,
                                attribute2: side.side,
                                toSafe: safeArea,
                                destinationView: view)
    }
    
    /// By default to `left` of destination view
    @discardableResult
    public func right(to view: PreConstraintViewable,
                            _ state: State<CGFloat>,
                            relation: NSLayoutConstraint.Relation = .equal,
                            multiplier: CGFloat = 1,
                            priority: UILayoutPriority = .defaultHigh,
                            safeArea: Bool = false) -> Self {
        right(to: .left, of: view, state, relation: relation, multiplier: multiplier, priority: priority, safeArea: safeArea)
    }
    
    @discardableResult
    public func right(to side: DeclarativeConstraintXSide, of view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0), safeArea: Bool = false) -> Self {
        right(to: side,
                of: view,
                .init(wrappedValue: value.constraintValue.value),
                relation: value.constraintValue.relation,
                multiplier: value.constraintValue.multiplier,
                priority: value.constraintValue.priority,
                safeArea: safeArea)
    }
    
    /// By default to `left` of destination view
    @discardableResult
    public func right(to view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0), safeArea: Bool = false) -> Self {
        right(to: .left, of: view, value, safeArea: safeArea)
    }
    
    // MARK: - bottom
    
    @discardableResult
    public func bottom(to side: DeclarativeConstraintYSide,
                                of view: PreConstraintViewable,
                                _ state: State<CGFloat>,
                                relation: NSLayoutConstraint.Relation = .equal,
                                multiplier: CGFloat = 1,
                                priority: UILayoutPriority = .defaultHigh,
                                safeArea: Bool = false) -> Self {
        _createRelative(value: state,
                                relation: relation,
                                multiplier: multiplier,
                                priority: priority,
                                attribute1: .bottom,
                                attribute2: side.side,
                                toSafe: safeArea,
                                destinationView: view)
    }
    
    /// By default to `top` of destination view
    @discardableResult
    public func bottom(to view: PreConstraintViewable,
                                _ state: State<CGFloat>,
                                relation: NSLayoutConstraint.Relation = .equal,
                                multiplier: CGFloat = 1,
                                priority: UILayoutPriority = .defaultHigh,
                                safeArea: Bool = false) -> Self {
        bottom(to: .top, of: view, state, relation: relation, multiplier: multiplier, priority: priority, safeArea: safeArea)
    }
    
    @discardableResult
    public func bottom(to side: DeclarativeConstraintYSide, of view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0), safeArea: Bool = false) -> Self {
        bottom(to: side,
                   of: view,
                   .init(wrappedValue: value.constraintValue.value),
                   relation: value.constraintValue.relation,
                   multiplier: value.constraintValue.multiplier,
                   priority: value.constraintValue.priority,
                   safeArea: safeArea)
    }
    
    /// By default to `top` of destination view
    @discardableResult
    public func bottom(to view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0), safeArea: Bool = false) -> Self {
        bottom(to: .top, of: view, value, safeArea: safeArea)
    }
    
    // MARK: - center x
    
    @discardableResult
    public func centerX(to side: DeclarativeConstraintCXSide,
                                 of view: PreConstraintViewable,
                                 _ state: State<CGFloat>,
                                 relation: NSLayoutConstraint.Relation = .equal,
                                 multiplier: CGFloat = 1,
                                 priority: UILayoutPriority = .defaultHigh) -> Self {
        _createRelative(value: state,
                                relation: relation,
                                multiplier: multiplier,
                                priority: priority,
                                attribute1: .centerX,
                                attribute2: side.side,
                                toSafe: false,
                                destinationView: view)
    }
    
    /// By default to `centerX` of destination view
    @discardableResult
    public func centerX(to view: PreConstraintViewable,
                                _ state: State<CGFloat>,
                                relation: NSLayoutConstraint.Relation = .equal,
                                multiplier: CGFloat = 1,
                                priority: UILayoutPriority = .defaultHigh) -> Self {
        centerX(to: .x, of: view, state, relation: relation, multiplier: multiplier, priority: priority)
    }
    
    @discardableResult
    public func centerX(to side: DeclarativeConstraintCXSide, of view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0)) -> Self {
        centerX(to: side,
                    of: view,
                    .init(wrappedValue: value.constraintValue.value),
                    relation: value.constraintValue.relation,
                    multiplier: value.constraintValue.multiplier,
                    priority: value.constraintValue.priority)
    }
    
    /// By default to `centerX` of destination view
    @discardableResult
    public func centerX(to view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0)) -> Self {
        centerX(to: .x, of: view, value)
    }
    
    // MARK: - center y
    
    @discardableResult
    public func centerY(to side: DeclarativeConstraintCYSide,
                                 of view: PreConstraintViewable,
                                 _ state: State<CGFloat>,
                                 relation: NSLayoutConstraint.Relation = .equal,
                                 multiplier: CGFloat = 1,
                                 priority: UILayoutPriority = .defaultHigh) -> Self {
        _createRelative(value: state,
                                relation: relation,
                                multiplier: multiplier,
                                priority: priority,
                                attribute1: .centerY,
                                attribute2: side.side,
                                toSafe: false,
                                destinationView: view)
    }
    
    /// By default to `centerY` of destination view
    @discardableResult
    public func centerY(to view: PreConstraintViewable,
                                _ state: State<CGFloat>,
                                relation: NSLayoutConstraint.Relation = .equal,
                                multiplier: CGFloat = 1,
                                priority: UILayoutPriority = .defaultHigh) -> Self {
        centerY(to: .y, of: view, state, relation: relation, multiplier: multiplier, priority: priority)
    }
    
    @discardableResult
    public func centerY(to side: DeclarativeConstraintCYSide, of view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0)) -> Self {
        centerY(to: side,
                    of: view,
                    .init(wrappedValue: value.constraintValue.value),
                    relation: value.constraintValue.relation,
                    multiplier: value.constraintValue.multiplier,
                    priority: value.constraintValue.priority)
    }
    
    /// By default to `centerY` of destination view
    @discardableResult
    public func centerY(to view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0)) -> Self {
        centerY(to: .y, of: view, value)
    }
    
    // MARK: - center both
    
    @discardableResult
    public func center(to view: PreConstraintViewable,
                               _ value: State<CGFloat>,
                               relation: NSLayoutConstraint.Relation = .equal,
                               multiplier: CGFloat = 1,
                               priority: UILayoutPriority = .defaultHigh) -> Self {
        centerX(to: view, value, relation: relation, multiplier: multiplier, priority: priority)
        .centerY(to: view, value, relation: relation, multiplier: multiplier, priority: priority)
    }
    
    @discardableResult
    public func center(to view: PreConstraintViewable, _ value: ConstraintValue) -> Self {
        centerX(to: view, value).centerY(to: view, value)
    }
    
    @discardableResult
    public func center(to view: PreConstraintViewable,
                              x: State<CGFloat>,
                              y: State<CGFloat>,
                              relation: NSLayoutConstraint.Relation = .equal,
                              multiplier: CGFloat = 1,
                              priority: UILayoutPriority = .defaultHigh) -> Self {
        centerX(to: view, x, relation: relation, multiplier: multiplier, priority: priority)
        .centerY(to: view, y, relation: relation, multiplier: multiplier, priority: priority)
    }
    
    @discardableResult
    public func center(to view: PreConstraintViewable,
                               x: State<CGFloat>,
                               y: ConstraintValue,
                               relation: NSLayoutConstraint.Relation = .equal,
                               multiplier: CGFloat = 1,
                               priority: UILayoutPriority = .defaultHigh) -> Self {
        centerX(to: view, x, relation: relation, multiplier: multiplier, priority: priority)
        .centerY(to: view, y)
    }
    
    @discardableResult
    public func center(to view: PreConstraintViewable,
                              x: ConstraintValue,
                              y: State<CGFloat>,
                              relation: NSLayoutConstraint.Relation = .equal,
                              multiplier: CGFloat = 1,
                              priority: UILayoutPriority = .defaultHigh) -> Self {
        centerX(to: view, x)
        .centerY(to: view, y, relation: relation, multiplier: multiplier, priority: priority)
    }
    
    @discardableResult
    public func center(to view: PreConstraintViewable, x: ConstraintValue = CGFloat(0), y: ConstraintValue = CGFloat(0)) -> Self {
        centerX(to: view, x).centerY(to: view, y)
    }
    
    // MARK: - width
    
    @discardableResult
    public func width(to side: DeclarativeConstraintDSide,
                              of view: PreConstraintViewable,
                              _ state: State<CGFloat>,
                              relation: NSLayoutConstraint.Relation = .equal,
                              multiplier: CGFloat = 1,
                              priority: UILayoutPriority = .defaultHigh) -> Self {
        _createRelative(value: state,
                                relation: relation,
                                multiplier: multiplier,
                                priority: priority,
                                attribute1: .width,
                                attribute2: side.side,
                                toSafe: false,
                                destinationView: view)
    }
    
    /// By default to `width` of destination view
    @discardableResult
    public func width(to view: PreConstraintViewable,
                             _ state: State<CGFloat>,
                             relation: NSLayoutConstraint.Relation = .equal,
                             multiplier: CGFloat = 1,
                             priority: UILayoutPriority = .defaultHigh) -> Self {
        width(to: .width, of: view, state, relation: relation, multiplier: multiplier, priority: priority)
    }
    
    @discardableResult
    public func width(to side: DeclarativeConstraintDSide, of view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0)) -> Self {
        width(to: side,
                 of: view,
                 .init(wrappedValue: value.constraintValue.value),
                 relation: value.constraintValue.relation,
                 multiplier: value.constraintValue.multiplier,
                 priority: value.constraintValue.priority)
    }
    
    /// By default to `width` of destination view
    @discardableResult
    public func width(to view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0)) -> Self {
        width(to: .width, of: view, value)
    }
    
    // MARK: - height
    
    @discardableResult
    public func height(to side: DeclarativeConstraintDSide,
                              of view: PreConstraintViewable,
                              _ state: State<CGFloat>,
                              relation: NSLayoutConstraint.Relation = .equal,
                              multiplier: CGFloat = 1,
                              priority: UILayoutPriority = .defaultHigh) -> Self {
        _createRelative(value: state,
                                relation: relation,
                                multiplier: multiplier,
                                priority: priority,
                                attribute1: .height,
                                attribute2: side.side,
                                toSafe: false,
                                destinationView: view)
    }
    
    /// By default to `height` of destination view
    @discardableResult
    public func height(to view: PreConstraintViewable,
                               _ state: State<CGFloat>,
                               relation: NSLayoutConstraint.Relation = .equal,
                               multiplier: CGFloat = 1,
                               priority: UILayoutPriority = .defaultHigh) -> Self {
        height(to: .height, of: view, state, relation: relation, multiplier: multiplier, priority: priority)
    }
    
    @discardableResult
    public func height(to side: DeclarativeConstraintDSide, of view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0)) -> Self {
        height(to: side,
                  of: view,
                  .init(wrappedValue: value.constraintValue.value),
                  relation: value.constraintValue.relation,
                  multiplier: value.constraintValue.multiplier,
                  priority: value.constraintValue.priority)
    }
    
    /// By default to `height` of destination view
    @discardableResult
    public func height(to view: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0)) -> Self {
        height(to: .height, of: view, value)
    }
    
    // MARK: - equal
    
    @discardableResult
    public func equalSize(to: PreConstraintViewable, _ value: ConstraintValue = CGFloat(0)) -> Self {
        width(to: to, value)
        .height(to: to, value)
    }
    
    @discardableResult
    public func equalSize(to: PreConstraintViewable,
                                   _ state: State<CGFloat>,
                                   relation: NSLayoutConstraint.Relation = .equal,
                                   multiplier: CGFloat = 1,
                                   priority: UILayoutPriority = .defaultHigh) -> Self {
        width(to: to, state, relation: relation, multiplier: multiplier, priority: priority)
        .height(to: to, state, relation: relation, multiplier: multiplier, priority: priority)
    }
    
    // MARK: - Activation
    
    func activateRelative(_ pc: PreConstraint) {
        guard let superview = declarativeView.superview else { return }
        guard let preConstraintView = pc.destinationView?.preConstraintView else { return }
        guard let _self = self as? DeclarativeProtocolInternal else { return }
        guard let destinationView = preConstraintView.unwrapWithSuperview(superview) else {
            guard let tag = preConstraintView.tag else { return }
            NotificationCenter.default.addObserver(for: AddedViewWithTag(tag)) {
                self.activateRelative(pc)
            }
            return
        }
        guard let _destinationView = destinationView as? DeclarativeProtocolInternal else { return }
        // Deactivate duplicate constraints and remove them from array
        _self._properties.appliedPreConstraintsRelative.removeAll {
            $0 != pc
                && $0.attribute1 == pc.attribute1
                &&  $0.attribute2 == pc.attribute2
                && $0.relation == pc.relation
                && $0.fromView === pc.fromView
                &&  $0.destinationView?.preConstraintView?.unwrapWithSuperview(superview) === destinationView
        }
        _destinationView._properties.appliedPreConstraintsRelative.removeAll {
            $0 != pc
                && $0.attribute1 == pc.attribute2
                &&  $0.attribute2 == pc.attribute1
                && $0.relation == pc.relation
                && $0.fromView === destinationView
                &&  $0.destinationView?.preConstraintView?.unwrapWithSuperview(superview) === pc.fromView
        }
        if let index = _self._properties.appliedPreConstraintsRelative.firstIndex(where: {
            $0.attribute1 == pc.attribute1
                &&  $0.attribute2 == pc.attribute2
                && $0.relation == pc.relation
                && $0.fromView === pc.fromView
                &&  $0.destinationView?.preConstraintView?.unwrapWithSuperview(superview) === destinationView
        }) {
            _self._properties.appliedPreConstraintsRelative[index].constraint?.isActive = false
            _self._properties.appliedPreConstraintsRelative[index].constraint?.shouldBeArchived = true
            _self._properties.appliedPreConstraintsRelative.remove(at: index)
        }
        guard let _ = destinationView.superview else {
            _self._properties.notAppliedPreConstraintsRelative.removeAll(where: { $0 === pc })
            if let inverted = pc.inverted() {
                _destinationView._properties.notAppliedPreConstraintsRelative.append(inverted)
            }
            return
        }
        // Move pre constraint from not applied to applied
        _self._properties.notAppliedPreConstraintsRelative.removeAll(where: { $0 === pc })
        _self._properties.appliedPreConstraintsRelative.append(pc)
        // Create constraint
        var constraint: NSLayoutConstraint?
        // If constraint for safeArea then create it through anchor
        if pc.toSafe {
            switch pc.attribute1 {
            // MARK: top
            case .top:
                switch pc.relation {
                case .equal:
                    switch pc.attribute2 {
                    case .top: constraint = declarativeView.topAnchor.constraint(equalTo: destinationView.safeArea.topAnchor, constant: pc.value.wrappedValue)
                    case .bottom: constraint = declarativeView.topAnchor.constraint(equalTo: destinationView.safeArea.bottomAnchor, constant: pc.value.wrappedValue)
                    default: break
                    }
                case .greaterThanOrEqual:
                    switch pc.attribute2 {
                    case .top: constraint = declarativeView.topAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.topAnchor, constant: pc.value.wrappedValue)
                    case .bottom: constraint = declarativeView.topAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.bottomAnchor, constant: pc.value.wrappedValue)
                    default: break
                    }
                case .lessThanOrEqual:
                    switch pc.attribute2 {
                    case .top: constraint = declarativeView.topAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.topAnchor, constant: pc.value.wrappedValue)
                    case .bottom: constraint = declarativeView.topAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.bottomAnchor, constant: pc.value.wrappedValue)
                    default: break
                    }
                @unknown default: break
                }
            // MARK: leading
            case .leading:
                switch pc.relation {
                case .equal:
                    switch pc.attribute2 {
                    case .leading: constraint = declarativeView.leadingAnchor.constraint(equalTo: destinationView.safeArea.leadingAnchor, constant: pc.value.wrappedValue)
                    case .left: constraint = declarativeView.leadingAnchor.constraint(equalTo: destinationView.safeArea.leftAnchor, constant: pc.value.wrappedValue)
                    case .trailing: constraint = declarativeView.leadingAnchor.constraint(equalTo: destinationView.safeArea.trailingAnchor, constant: pc.value.wrappedValue)
                    case .right: constraint = declarativeView.leadingAnchor.constraint(equalTo: destinationView.safeArea.rightAnchor, constant: pc.value.wrappedValue)
                    case .centerX: constraint = declarativeView.leadingAnchor.constraint(equalTo: destinationView.safeArea.centerXAnchor, constant: pc.value.wrappedValue)
                    default: break
                    }
                case .greaterThanOrEqual:
                    switch pc.attribute2 {
                    case .leading: constraint = declarativeView.leadingAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.leadingAnchor, constant: pc.value.wrappedValue)
                    case .left: constraint = declarativeView.leadingAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.leftAnchor, constant: pc.value.wrappedValue)
                    case .trailing: constraint = declarativeView.leadingAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.trailingAnchor, constant: pc.value.wrappedValue)
                    case .right: constraint = declarativeView.leadingAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.rightAnchor, constant: pc.value.wrappedValue)
                    case .centerX: constraint = declarativeView.leadingAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.centerXAnchor, constant: pc.value.wrappedValue)
                    default: break
                    }
                case .lessThanOrEqual:
                    switch pc.attribute2 {
                    case .leading: constraint = declarativeView.leadingAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.leadingAnchor, constant: pc.value.wrappedValue)
                    case .left: constraint = declarativeView.leadingAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.leftAnchor, constant: pc.value.wrappedValue)
                    case .trailing: constraint = declarativeView.leadingAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.trailingAnchor, constant: pc.value.wrappedValue)
                    case .right: constraint = declarativeView.leadingAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.rightAnchor, constant: pc.value.wrappedValue)
                    case .centerX: constraint = declarativeView.leadingAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.centerXAnchor, constant: pc.value.wrappedValue)
                    default: break
                    }
                @unknown default: break
                }
            // MARK: left
            case .left:
                switch pc.relation {
                case .equal:
                    switch pc.attribute2 {
                    case .leading: constraint = declarativeView.leftAnchor.constraint(equalTo: destinationView.safeArea.leadingAnchor, constant: pc.value.wrappedValue)
                    case .left: constraint = declarativeView.leftAnchor.constraint(equalTo: destinationView.safeArea.leftAnchor, constant: pc.value.wrappedValue)
                    case .trailing: constraint = declarativeView.leftAnchor.constraint(equalTo: destinationView.safeArea.trailingAnchor, constant: pc.value.wrappedValue)
                    case .right: constraint = declarativeView.leftAnchor.constraint(equalTo: destinationView.safeArea.rightAnchor, constant: pc.value.wrappedValue)
                    case .centerX: constraint = declarativeView.leftAnchor.constraint(equalTo: destinationView.safeArea.centerXAnchor, constant: pc.value.wrappedValue)
                    default: break
                    }
                case .greaterThanOrEqual:
                    switch pc.attribute2 {
                    case .leading: constraint = declarativeView.leftAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.leadingAnchor, constant: pc.value.wrappedValue)
                    case .left: constraint = declarativeView.leftAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.leftAnchor, constant: pc.value.wrappedValue)
                    case .trailing: constraint = declarativeView.leftAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.trailingAnchor, constant: pc.value.wrappedValue)
                    case .right: constraint = declarativeView.leftAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.rightAnchor, constant: pc.value.wrappedValue)
                    case .centerX: constraint = declarativeView.leftAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.centerXAnchor, constant: pc.value.wrappedValue)
                    default: break
                    }
                case .lessThanOrEqual:
                    switch pc.attribute2 {
                    case .leading: constraint = declarativeView.leftAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.leadingAnchor, constant: pc.value.wrappedValue)
                    case .left: constraint = declarativeView.leftAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.leftAnchor, constant: pc.value.wrappedValue)
                    case .trailing: constraint = declarativeView.leftAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.trailingAnchor, constant: pc.value.wrappedValue)
                    case .right: constraint = declarativeView.leftAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.rightAnchor, constant: pc.value.wrappedValue)
                    case .centerX: constraint = declarativeView.leftAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.centerXAnchor, constant: pc.value.wrappedValue)
                    default: break
                    }
                @unknown default: break
                }
            // MARK: trailing
            case .trailing:
                switch pc.relation {
                case .equal:
                    switch pc.attribute2 {
                    case .leading: constraint = declarativeView.trailingAnchor.constraint(equalTo: destinationView.safeArea.leadingAnchor, constant: pc.value.wrappedValue)
                    case .left: constraint = declarativeView.trailingAnchor.constraint(equalTo: destinationView.safeArea.leftAnchor, constant: pc.value.wrappedValue)
                    case .trailing: constraint = declarativeView.trailingAnchor.constraint(equalTo: destinationView.safeArea.trailingAnchor, constant: pc.value.wrappedValue)
                    case .right: constraint = declarativeView.trailingAnchor.constraint(equalTo: destinationView.safeArea.rightAnchor, constant: pc.value.wrappedValue)
                    case .centerX: constraint = declarativeView.trailingAnchor.constraint(equalTo: destinationView.safeArea.centerXAnchor, constant: pc.value.wrappedValue)
                    default: break
                    }
                case .greaterThanOrEqual:
                    switch pc.attribute2 {
                    case .leading: constraint = declarativeView.trailingAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.leadingAnchor, constant: pc.value.wrappedValue)
                    case .left: constraint = declarativeView.trailingAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.leftAnchor, constant: pc.value.wrappedValue)
                    case .trailing: constraint = declarativeView.trailingAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.trailingAnchor, constant: pc.value.wrappedValue)
                    case .right: constraint = declarativeView.trailingAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.rightAnchor, constant: pc.value.wrappedValue)
                    case .centerX: constraint = declarativeView.trailingAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.centerXAnchor, constant: pc.value.wrappedValue)
                    default: break
                    }
                case .lessThanOrEqual:
                    switch pc.attribute2 {
                    case .leading: constraint = declarativeView.trailingAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.leadingAnchor, constant: pc.value.wrappedValue)
                    case .left: constraint = declarativeView.trailingAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.leftAnchor, constant: pc.value.wrappedValue)
                    case .trailing: constraint = declarativeView.trailingAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.trailingAnchor, constant: pc.value.wrappedValue)
                    case .right: constraint = declarativeView.trailingAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.rightAnchor, constant: pc.value.wrappedValue)
                    case .centerX: constraint = declarativeView.trailingAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.centerXAnchor, constant: pc.value.wrappedValue)
                    default: break
                    }
                @unknown default: break
                }
            // MARK: right
            case .right:
                switch pc.relation {
                case .equal:
                    switch pc.attribute2 {
                    case .leading: constraint = declarativeView.rightAnchor.constraint(equalTo: destinationView.safeArea.leadingAnchor, constant: pc.value.wrappedValue)
                    case .left: constraint = declarativeView.rightAnchor.constraint(equalTo: destinationView.safeArea.leftAnchor, constant: pc.value.wrappedValue)
                    case .trailing: constraint = declarativeView.rightAnchor.constraint(equalTo: destinationView.safeArea.trailingAnchor, constant: pc.value.wrappedValue)
                    case .right: constraint = declarativeView.rightAnchor.constraint(equalTo: destinationView.safeArea.rightAnchor, constant: pc.value.wrappedValue)
                    case .centerX: constraint = declarativeView.rightAnchor.constraint(equalTo: destinationView.safeArea.centerXAnchor, constant: pc.value.wrappedValue)
                    default: break
                    }
                case .greaterThanOrEqual:
                    switch pc.attribute2 {
                    case .leading: constraint = declarativeView.rightAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.leadingAnchor, constant: pc.value.wrappedValue)
                    case .left: constraint = declarativeView.rightAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.leftAnchor, constant: pc.value.wrappedValue)
                    case .trailing: constraint = declarativeView.rightAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.trailingAnchor, constant: pc.value.wrappedValue)
                    case .right: constraint = declarativeView.rightAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.rightAnchor, constant: pc.value.wrappedValue)
                    case .centerX: constraint = declarativeView.rightAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.centerXAnchor, constant: pc.value.wrappedValue)
                    default: break
                    }
                case .lessThanOrEqual:
                    switch pc.attribute2 {
                    case .leading: constraint = declarativeView.rightAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.leadingAnchor, constant: pc.value.wrappedValue)
                    case .left: constraint = declarativeView.rightAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.leftAnchor, constant: pc.value.wrappedValue)
                    case .trailing: constraint = declarativeView.rightAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.trailingAnchor, constant: pc.value.wrappedValue)
                    case .right: constraint = declarativeView.rightAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.rightAnchor, constant: pc.value.wrappedValue)
                    case .centerX: constraint = declarativeView.rightAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.centerXAnchor, constant: pc.value.wrappedValue)
                    default: break
                    }
                @unknown default: break
                }
            // MARK: bottom
            case .bottom:
                switch pc.relation {
                case .equal:
                    switch pc.attribute2 {
                    case .top: constraint = declarativeView.bottomAnchor.constraint(equalTo: destinationView.safeArea.topAnchor, constant: pc.value.wrappedValue)
                    case .bottom: constraint = declarativeView.bottomAnchor.constraint(equalTo: destinationView.safeArea.bottomAnchor, constant: pc.value.wrappedValue)
                    default: break
                    }
                case .greaterThanOrEqual:
                    switch pc.attribute2 {
                    case .top: constraint = declarativeView.bottomAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.topAnchor, constant: pc.value.wrappedValue)
                    case .bottom: constraint = declarativeView.bottomAnchor.constraint(greaterThanOrEqualTo: destinationView.safeArea.bottomAnchor, constant: pc.value.wrappedValue)
                    default: break
                    }
                case .lessThanOrEqual:
                    switch pc.attribute2 {
                    case .top: constraint = declarativeView.bottomAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.topAnchor, constant: pc.value.wrappedValue)
                    case .bottom: constraint = declarativeView.bottomAnchor.constraint(lessThanOrEqualTo: destinationView.safeArea.bottomAnchor, constant: pc.value.wrappedValue)
                    default: break
                    }
                @unknown default: break
                }
            default: break
            }
        }
        // If constraint was not for safeArea then create it as usual
        if constraint == nil {
            constraint = NSLayoutConstraint(item: self,
                                                            attribute: pc.attribute1,
                                                            relatedBy: pc.relation,
                                                            toItem: destinationView,
                                                            attribute: pc.attribute2 ?? .notAnAttribute,
                                                            multiplier: pc.multiplier,
                                                            constant: pc.value.wrappedValue)
        }
        // Store constraint into pre constraint
        pc.constraint = constraint
        // Activate constraint
        constraint?.isActive = true
        // Redraw itself
        #if os(macOS)
        superview.layoutSubtreeIfNeeded() // TODO: check layoutSubtreeIfNeeded!
        #else
        superview.layoutIfNeeded()
        #endif
    }
}
#endif
