#if os(macOS)
import Cocoa

public protocol BezelStyleable: AnyObject {
    @discardableResult
    func style(_ value: NSButton.BezelStyle) -> Self
    
    @discardableResult
    func style(_ binding: UIKitPlus.State<NSButton.BezelStyle>) -> Self
}

@MainActor
protocol _BezelStyleable: BezelStyleable {
    var _bezelStyleState: State<NSButton.BezelStyle> { get set }
    
    func _setBezelStyle(_ v: NSButton.BezelStyle)
}

@available(iOS 13.0, *)
@MainActor
extension BezelStyleable {
    @discardableResult
    public func style(_ binding: UIKitPlus.State<NSButton.BezelStyle>) -> Self {
        guard let s = self as? _BezelStyleable else { return self }
        s._bezelStyleState = binding
        s._setBezelStyle(binding.wrappedValue)
        binding.listen { [weak s] in
            s?._setBezelStyle($0)
        }
        .holdIfOwned(by: self)
        return self
    }
    
    @discardableResult
    public func style(_ value: NSButton.BezelStyle) -> Self {
        guard let s = self as? _BezelStyleable else { return self }
        s._bezelStyleState.wrappedValue = value
        s._setBezelStyle(value)
        return self
    }
}

// for iOS lower than 13
@MainActor
extension _BezelStyleable {
    @discardableResult
    public func style(_ binding: UIKitPlus.State<NSButton.BezelStyle>) -> Self {
        _bezelStyleState = binding
        _setBezelStyle(binding.wrappedValue)
        binding.listen { [weak self] in
            self?._setBezelStyle($0)
        }
        .holdIfOwned(by: self)
        return self
    }
    
    @discardableResult
    public func style(_ value: NSButton.BezelStyle) -> Self {
        _bezelStyleState.wrappedValue = value
        _setBezelStyle(value)
        return self
    }
}
#endif
