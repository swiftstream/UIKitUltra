#if os(macOS)
import AppKit
#else
import UIKit
#endif

public protocol TextFieldContentTypeable {
    func content(_ content: TextFieldContentType) -> Self
}

@MainActor
protocol _TextFieldContentTypeable: TextFieldContentTypeable {
    func _setTextFieldContentType(v: TextFieldContentType)
}

@available(iOS 13.0, macOS 10.15, *)
@MainActor
extension TextFieldContentTypeable {
    @discardableResult
    public func content(_ content: TextFieldContentType) -> Self {
        guard let s = self as? _TextFieldContentTypeable else { return self }
        s._setTextFieldContentType(v: content)
        return self
    }
}

// for iOS lower than 13
@MainActor
extension _TextFieldContentTypeable {
    @discardableResult
    public func content(_ content: TextFieldContentType) -> Self {
        _setTextFieldContentType(v: content)
        return self
    }
}
