#if os(macOS)
import AppKit
#else
import UIKit
#endif

private var spacingAssociationKey: UInt8 = 0

extension BaseView {
    @available(iOS 11.0, *)
    var spacing: State<CGFloat>? {
        get {
            return objc_getAssociatedObject(self, &spacingAssociationKey) as? State<CGFloat>
        }
        set(newValue) {
            objc_setAssociatedObject(self, &spacingAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    @available(iOS 11.0, *)
    @discardableResult
    public func customSpacing(_ spacing: CGFloat) -> Self {
        if self.spacing == nil {
            self.spacing = State.init(wrappedValue: spacing)
        }
        else {
            self.spacing?.wrappedValue = spacing
        }

        if let superView = self.superview as? _STV {
            superView.setCustomSpacing(spacing, after: self)
        }
        return self
    }

    @available(iOS 11.0, *)
    @discardableResult
    public func customSpacing(_ spacing: State<CGFloat>) -> Self {
        self.spacing = spacing
        spacing.listen { [weak self] new in
            guard let self = self else { return }
            if let superView = self.superview as? _STV {
                superView.setCustomSpacing(new, after: self)
            }
        }
        return self
    }
}