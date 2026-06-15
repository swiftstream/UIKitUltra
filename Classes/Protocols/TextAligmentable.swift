#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
public protocol TextAligmentable {
    func alignment(_ alignment: NSTextAlignment) -> Self
}

@MainActor
protocol _TextAligmentable: TextAligmentable {
    func _setTextAlignment(v: NSTextAlignment)
}

@available(iOS 13.0, *)
@MainActor
extension TextAligmentable {
    @discardableResult
    public func alignment(_ alignment: NSTextAlignment) -> Self {
        guard let s = self as? _TextAligmentable else { return self }
        s._setTextAlignment(v: alignment)
        return self
    }
}

// for iOS lower than 13
@MainActor
extension _TextAligmentable {
    @discardableResult
    public func alignment(_ alignment: NSTextAlignment) -> Self {
        _setTextAlignment(v: alignment)
        return self
    }
}
