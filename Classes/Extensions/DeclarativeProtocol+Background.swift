#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension AnyDeclarativeProtocol {
    @MainActor
    public var background: State<UColor> { properties.$background }
    
    @MainActor
    var _backgroundColorState: State<UColor> { background }
    
    #if os(macOS)
    @MainActor
    func _setBackgroundColor(_ v: NSColor?) {
        declarativeView.wantsLayer = true
        declarativeView.layer?.backgroundColor = v?.cgColor
    }
    #else
    @MainActor
    func _setBackgroundColor(_ v: UColor?) {
        declarativeView.backgroundColor = v
    }
    #endif
    
//    @discardableResult
//    public func background(_ number: Int) -> Self {
//        background(number.color)
//    }
//
//    @discardableResult
//    public func background(_ color: UColor) -> Self {
//        _setBackground(.init(wrappedValue: color))
//        return self
//    }
//
//    @discardableResult
//    public func background(_ state: State<UColor>) -> Self {
//        _setBackground(state)
//        state.listen { [weak self] old, new in
//            self?.background(new)
//            self?.properties.background = new
//        }
//        return self
//    }
//
//    private func _setBackground(_ color: State<UColor>) {
//        #if os(macOS)
//        background.wrappedValue.changeHandler = nil
//        properties.background = color.wrappedValue
//        declarativeView.wantsLayer = true
//        declarativeView.layer?.backgroundColor = color.wrappedValue.current.cgColor
//        properties.background.onChange { [weak self] new in
//            self?.declarativeView.layer?.backgroundColor = new.cgColor
//        }
//        #else
//        properties.background = color.wrappedValue
//        declarativeView.backgroundColor = color
//        #endif
//    }
}
