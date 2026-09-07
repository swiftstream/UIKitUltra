#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

@MainActor
public protocol TextScaleable {
    @discardableResult
    func minimumScaleFactor(_ value: CGFloat) -> Self
}

@MainActor
protocol _TextScaleable: TextScaleable {
    func _setMinimumScaleFactor(_ v: CGFloat)
}

@available(iOS 13.0, *)
extension TextScaleable {
    @discardableResult
    public func minimumScaleFactor(_ value: CGFloat) -> Self {
        guard let s = self as? _TextScaleable else { return self }
        s._setMinimumScaleFactor(value)
        return self
    }
}

// for iOS lower than 13
extension _TextScaleable {
    @discardableResult
    public func minimumScaleFactor(_ value: CGFloat) -> Self {
        _setMinimumScaleFactor(value)
        return self
    }
}
#endif
#endif
