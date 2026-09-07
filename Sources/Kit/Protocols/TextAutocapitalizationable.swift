#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

@MainActor
public protocol TextAutocapitalizationable {
    @discardableResult
    func autocapitalization(_ type: UITextAutocapitalizationType) -> Self
}

@MainActor
protocol _TextAutocapitalizationable: TextAutocapitalizationable {
    func _setTextAutocapitalizationType(_ v: UITextAutocapitalizationType)
}

@available(iOS 13.0, *)
extension TextAutocapitalizationable {
    @discardableResult
    public func autocapitalization(_ type: UITextAutocapitalizationType) -> Self {
        guard let s = self as? _TextAutocapitalizationable else { return self }
        s._setTextAutocapitalizationType(type)
        return self
    }
}

// for iOS lower than 13
extension _TextAutocapitalizationable {
    @discardableResult
    public func autocapitalization(_ type: UITextAutocapitalizationType) -> Self {
        _setTextAutocapitalizationType(type)
        return self
    }
}
#endif
#endif
