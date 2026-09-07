#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension DeclarativeProtocol {
    @discardableResult
    public func gesture(_ recognizer: UGestureRecognizer) -> Self {
        gestures(recognizer)
    }
    
    @discardableResult
    public func gestures(_ recognizers: UGestureRecognizer...) -> Self {
        gestures(recognizers)
    }
    
    @discardableResult
    public func gestures(_ recognizers: [UGestureRecognizer]) -> Self {
        recognizers.forEach { declarativeView.addGestureRecognizer($0) }
        return self
    }
    
    @discardableResult
    public func gestures(@GesturesBuilder block: GesturesBuilder.Block) -> Self {
        gestures(block().gestureRecognizers)
    }
    
    @discardableResult
    public func gestures(@GesturesBuilder block: (Self) -> GesturesBuilderItem) -> Self {
        gestures(block(self).gestureRecognizers)
    }
}
#endif
