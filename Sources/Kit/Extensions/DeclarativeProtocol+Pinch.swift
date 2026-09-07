#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

#if !os(tvOS)
extension DeclarativeProtocol {
    @discardableResult
    public func onPinchGesture(scale: CGFloat? = nil, on state: UIGestureRecognizer.State, _ action: @escaping () -> Void) -> Self {
        onPinchGesture(scale: scale, on: state) { v, r in
            action()
        }
    }
    
    @discardableResult
    public func onPinchGesture(scale: CGFloat? = nil, on state: UIGestureRecognizer.State, _ action: @escaping (Self) -> Void) -> Self {
        onPinchGesture(scale: scale, on: state) { [weak self] v, r in
            guard let self = self else { return }
            action(self)
        }
    }
    
    @discardableResult
    public func onPinchGesture(scale: CGFloat? = nil, on state: UIGestureRecognizer.State, _ action: @escaping (Self, PinchGestureRecognizer) -> Void) -> Self {
        onPinchGesture(scale: scale) { v, s, r in
            if s == state {
                action(v, r)
            }
        }
    }
    
    @discardableResult
    public func onPinchGesture(scale: CGFloat? = nil, _ action: @escaping (Self) -> Void) -> Self {
        onPinchGesture(scale: scale) { v, s, r in
            action(v)
        }
    }
    
    @discardableResult
    public func onPinchGesture(scale: CGFloat? = nil, _ action: @escaping (Self, UIGestureRecognizer.State) -> Void) -> Self {
        onPinchGesture(scale: scale) { v, s, r in
            action(v, s)
        }
    }
    
    @discardableResult
    public func onPinchGesture(scale: CGFloat? = nil, _ action: @escaping (Self, UIGestureRecognizer.State, PinchGestureRecognizer) -> Void) -> Self {
        let recognizer = PinchGestureRecognizer(scale: scale)
        declarativeView.addGestureRecognizer(recognizer.trackState { [weak self, weak recognizer] in
            guard let self = self, let recognizer = recognizer else { return }
            action(self, $0, recognizer)
        })
        return self
    }
    
    @discardableResult
    public func onPinchGesture(scale: CGFloat? = nil, _ state: State<UIGestureRecognizer.State>) -> Self {
        onPinchGesture(scale: scale) { v, s, r in
            state.wrappedValue = s
        }
    }
}
#endif
#endif
#endif
