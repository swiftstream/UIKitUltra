#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit

extension DeclarativeProtocol {
    @discardableResult
    public func onMagnification(_ value: CGFloat? = nil, on state: NSGestureRecognizer.State, _ action: @escaping () -> Void) -> Self {
        onMagnification(value, on: state) { v, r in
            action()
        }
    }
    
    @discardableResult
    public func onMagnification(_ value: CGFloat? = nil, on state: NSGestureRecognizer.State, _ action: @escaping (Self) -> Void) -> Self {
        onMagnification(value, on: state) { v, r in
            action(self)
        }
    }
    
    @discardableResult
    public func onMagnification(_ value: CGFloat? = nil, on state: NSGestureRecognizer.State, _ action: @escaping (Self, MagnificationGestureRecognizer) -> Void) -> Self {
        onMagnification(value) { v, s, r in
            if s == state {
                action(v, r)
            }
        }
    }
    
    @discardableResult
    public func onMagnification(_ value: CGFloat? = nil, _ action: @escaping (Self) -> Void) -> Self {
        onMagnification(value) { v, s, r in
            action(v)
        }
    }
    
    @discardableResult
    public func onMagnification(_ value: CGFloat? = nil, _ action: @escaping (Self, NSGestureRecognizer.State) -> Void) -> Self {
        onMagnification(value) { v, s, r in
            action(v, s)
        }
    }
    
    @discardableResult
    public func onMagnification(_ value: CGFloat? = nil, _ action: @escaping (Self, NSGestureRecognizer.State, MagnificationGestureRecognizer) -> Void) -> Self {
        let recognizer = MagnificationGestureRecognizer(magnification: value)
        declarativeView.addGestureRecognizer(recognizer.trackState { [weak self, weak recognizer] in
            guard let self = self, let recognizer = recognizer else { return }
            action(self, $0, recognizer)
        })
        return self
    }
    
    @discardableResult
    public func onMagnification(_ value: CGFloat? = nil, _ state: State<NSGestureRecognizer.State>) -> Self {
        onMagnification(value) { v, s, r in
            state.wrappedValue = s
        }
    }
}
#endif
#endif
