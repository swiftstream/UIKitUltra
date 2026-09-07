#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit

extension DeclarativeProtocol {
    @discardableResult
    public func onPressGesture(touches: Int = 1, on state: NSGestureRecognizer.State = .began, _ action: @escaping () -> Void) -> Self {
        onPressGesture(touches: touches, on: state) { v, r in
            action()
        }
    }
    
    @discardableResult
    public func onPressGesture(touches: Int = 1, on state: NSGestureRecognizer.State, _ action: @escaping (Self) -> Void) -> Self {
        onPressGesture(touches: touches, on: state) { [weak self] v, r in
            guard let self = self else { return }
            action(self)
        }
    }
    
    @discardableResult
    public func onPressGesture(touches: Int = 1, on state: NSGestureRecognizer.State, _ action: @escaping (Self, PressGestureRecognizer) -> Void) -> Self {
        onPressGesture(touches: touches) { v, s, r in
            if s == state {
                action(v, r)
            }
        }
    }
    
    @discardableResult
    public func onPressGesture(touches: Int = 1, _ action: @escaping (Self) -> Void) -> Self {
        onPressGesture(touches: touches) { v, s, r in
            action(v)
        }
    }
    
    @discardableResult
    public func onPressGesture(touches: Int = 1, _ action: @escaping (Self, NSGestureRecognizer.State) -> Void) -> Self {
        onPressGesture(touches: touches) { v, s, r in
            action(v, s)
        }
    }
    
    @discardableResult
    public func onPressGesture(touches: Int = 1, _ action: @escaping (Self, NSGestureRecognizer.State, PressGestureRecognizer) -> Void) -> Self {
        let recognizer = PressGestureRecognizer(touches: touches)
        declarativeView.addGestureRecognizer(recognizer.trackState { [weak self, weak recognizer] in
            guard let self = self, let recognizer = recognizer else { return }
            action(self, $0, recognizer)
        })
        return self
    }
    
    @discardableResult
    public func onPressGesture(touches: Int = 1, _ state: State<NSGestureRecognizer.State>) -> Self {
        onPressGesture(touches: touches) { v, s, r in
            state.wrappedValue = s
        }
    }
}
#endif
#endif
