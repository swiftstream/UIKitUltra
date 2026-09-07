#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit

extension DeclarativeProtocol {
    @discardableResult
    public func onSwipeGesture(direction: USwipeGestureRecognizer.Direction, touches: Int = 2, on state: GestureRecognizer.State, _ action: @escaping () -> Void) -> Self {
        onSwipeGesture(direction: direction, touches: touches, on: state) { _ in action() }
    }
    
    @discardableResult
    public func onSwipeGesture(direction: USwipeGestureRecognizer.Direction, touches: Int = 2, on state: GestureRecognizer.State, _ action: @escaping (Self) -> Void) -> Self {
        onSwipeGesture(direction: direction, touches: touches) { v, s, r in
            if s == state {
                action(v)
            }
        }
    }
    
    @discardableResult
    public func onSwipeGesture(direction: USwipeGestureRecognizer.Direction, touches: Int = 2, _ action: @escaping () -> Void) -> Self {
        onSwipeGesture(direction: direction, touches: touches) { v, s, r in
            action()
        }
    }
    
    @discardableResult
    public func onSwipeGesture(direction: USwipeGestureRecognizer.Direction, touches: Int = 2, _ action: @escaping (Self) -> Void) -> Self {
        onSwipeGesture(direction: direction, touches: touches) { v, s, r in
            action(v)
        }
    }
    
    @discardableResult
    public func onSwipeGesture(direction: USwipeGestureRecognizer.Direction, touches: Int = 2, _ action: @escaping (Self, GestureRecognizer.State) -> Void) -> Self {
        onSwipeGesture(direction: direction, touches: touches) { v, s, r in
            action(v, s)
        }
    }
}
#else
import UIKit

extension DeclarativeProtocol {
    @discardableResult
    public func onSwipeGesture(direction: USwipeGestureRecognizer.Direction, touches: Int = 1, on state: GestureRecognizer.State, _ action: @escaping () -> Void) -> Self {
        onSwipeGesture(direction: direction, touches: touches, on: state) { _ in action() }
    }
    
    @discardableResult
    public func onSwipeGesture(direction: USwipeGestureRecognizer.Direction, touches: Int = 1, on state: GestureRecognizer.State, _ action: @escaping (Self) -> Void) -> Self {
        onSwipeGesture(direction: direction, touches: touches) { v, s, r in
            if s == state {
                action(v)
            }
        }
    }
    
    @discardableResult
    public func onSwipeGesture(direction: USwipeGestureRecognizer.Direction, touches: Int = 1, _ action: @escaping () -> Void) -> Self {
        onSwipeGesture(direction: direction, touches: touches) { v, s, r in
            action()
        }
    }
    
    @discardableResult
    public func onSwipeGesture(direction: USwipeGestureRecognizer.Direction, touches: Int = 1, _ action: @escaping (Self) -> Void) -> Self {
        onSwipeGesture(direction: direction, touches: touches) { v, s, r in
            action(v)
        }
    }
    
    @discardableResult
    public func onSwipeGesture(direction: USwipeGestureRecognizer.Direction, touches: Int = 1, _ action: @escaping (Self, GestureRecognizer.State) -> Void) -> Self {
        onSwipeGesture(direction: direction, touches: touches) { v, s, r in
            action(v, s)
        }
    }
}
#endif
extension DeclarativeProtocol {
    @discardableResult
    public func onSwipeGesture(direction: USwipeGestureRecognizer.Direction, touches: Int? = nil, _ action: @escaping (Self, GestureRecognizer.State, SwipeGestureRecognizer) -> Void) -> Self {
        #if os(macOS)
        declarativeView.allowedTouchTypes = .init(arrayLiteral: .direct, .indirect)
        declarativeView.wantsRestingTouches = true
        #endif
        let recognizer = SwipeGestureRecognizer(direction: direction, touches: touches)
        declarativeView.addGestureRecognizer(recognizer.trackState { [weak self, weak recognizer] in
            guard let self = self, let recognizer = recognizer else { return }
            action(self, $0, recognizer)
        })
        return self
    }
    
    @discardableResult
    public func onSwipeGesture(direction: USwipeGestureRecognizer.Direction, touches: Int? = nil, _ state: State<GestureRecognizer.State>) -> Self {
        onSwipeGesture(direction: direction, touches: touches) { v, s, r in
            state.wrappedValue = s
        }
        return self
    }
}
#endif
