#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
public protocol Scrollable {
    @discardableResult
    func scrolling(_ enabled: Bool) -> Self
    
    @discardableResult
    func hideIndicator(_ indicators: NSLayoutConstraint.Axis...) -> Self
    
    @discardableResult
    func hideAllIndicators() -> Self
}

@MainActor
protocol _Scrollable: Scrollable {
    func _setScrollingEnabled(_ v: Bool)
    func _setVisibleVScrollIndicator(_ v: Bool)
    func _setVisibleHScrollIndicator(_ v: Bool)
}

@available(iOS 13.0, *)
extension Scrollable {
    // MARK: Scrolling
    
    @discardableResult
    public func scrolling(_ enabled: Bool) -> Self {
        guard let s = self as? _Scrollable else { return self }
        s._setScrollingEnabled(enabled)
        return self
    }
    
    // MARK: Indicators
    
    @discardableResult
    public func hideIndicator(_ indicators: NSLayoutConstraint.Axis...) -> Self {
        guard let s = self as? _Scrollable else { return self }
        if indicators.contains(.horizontal) {
            s._setVisibleHScrollIndicator(false)
        }
        if indicators.contains(.vertical) {
            s._setVisibleVScrollIndicator(false)
        }
        return self
    }
    
    // MARK: Indicators
    
    @discardableResult
    public func hideAllIndicators() -> Self {
        guard let s = self as? _Scrollable else { return self }
        s._setVisibleHScrollIndicator(false)
        s._setVisibleVScrollIndicator(false)
        return self
    }
}

// for iOS lower than 13
extension _Scrollable {
    // MARK: Scrolling
    
    @discardableResult
    public func scrolling(_ enabled: Bool) -> Self {
        _setScrollingEnabled(enabled)
        return self
    }
    
    // MARK: Indicators
    
    @discardableResult
    public func hideIndicator(_ indicators: NSLayoutConstraint.Axis...) -> Self {
        if indicators.contains(.horizontal) {
            _setVisibleHScrollIndicator(false)
        }
        if indicators.contains(.vertical) {
            _setVisibleVScrollIndicator(false)
        }
        return self
    }
    
    // MARK: Indicators
    
    @discardableResult
    public func hideAllIndicators() -> Self {
        _setVisibleHScrollIndicator(false)
        _setVisibleVScrollIndicator(false)
        return self
    }
}
