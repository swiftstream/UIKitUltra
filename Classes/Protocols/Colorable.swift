#if os(macOS)
import AppKit
#else
import UIKit
#endif

public protocol Colorable: AnyObject {
    @discardableResult
    func color(_ color: UColor) -> Self
    
    @discardableResult
    func color(_ number: Int) -> Self
    
    @discardableResult
    func color(_ color: State<UColor>) -> Self
}

protocol _Colorable: Colorable {
    var _colorState: State<UColor> { get }
    
    #if os(macOS)
    func _setColor(_ v: NSColor?)
    #else
    func _setColor(_ v: UColor?)
    #endif
}

extension Colorable {
    @discardableResult
    public func color(_ number: Int) -> Self {
        color(number.color)
    }
    
    @discardableResult
    public func color(_ state: State<UColor>) -> Self {
        state.listen { [weak self] in
            self?.color($0)
        }
        .holdIfOwned(by: self)
        return color(state.wrappedValue)
    }
}

@available(iOS 13.0, *)
extension Colorable {
    @discardableResult
    public func color(_ color: UColor) -> Self {
        guard let s = self as? _Colorable else { return self }
        _color(color, on: s)
        return self
    }
}

// for iOS lower than 13
extension _Colorable {
    @discardableResult
    public func color(_ color: UColor) -> Self {
        _color(color, on: self)
        return self
    }
}

private func  _color(_ color: UColor, on s: _Colorable) {
    #if os(macOS)
    s._colorState.wrappedValue.changeHandler = nil
    #endif
    s._colorState.wrappedValue = color
    s._setColor(color.current)
    #if os(macOS)
    s._colorState.wrappedValue.onChange { [weak s] new in
        s?._setColor(new)
    }
    #endif
}
