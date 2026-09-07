#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit

extension DeclarativeProtocol where V: BaseView {
    // MARK Single Click
    
    @discardableResult
    public func onClickGesture(clicks: Int = 1, touches: Int = 1, buttonMask: Int = 0x1, on state: NSGestureRecognizer.State = .ended, _ action: @escaping () -> Void) -> Self {
        onClickGesture(clicks: clicks, touches: touches, buttonMask: buttonMask, on: state) { v in
            action()
        }
    }
    
    @discardableResult
    public func onClickGesture(clicks: Int = 1, touches: Int = 1, buttonMask: Int = 0x1, on state: NSGestureRecognizer.State = .ended, _ action: @escaping (Self) -> Void) -> Self {
        onClickGesture(clicks: clicks, touches: touches, buttonMask: buttonMask) { v, s, r in
            if s == state {
                action(v)
            }
        }
    }
    
    @discardableResult
    public func onClickGesture(clicks: Int = 1, touches: Int = 1, buttonMask: Int = 0x1, _ action: @escaping (Self, NSGestureRecognizer.State) -> Void) -> Self {
        onClickGesture(clicks: clicks, touches: touches, buttonMask: buttonMask) { v, s, r in
            action(v, s)
        }
    }
    
    @discardableResult
    public func onClickGesture(clicks: Int = 1, touches: Int = 1, buttonMask: Int = 0x1, _ action: @escaping (Self, NSGestureRecognizer.State, ClickGestureRecognizer) -> Void) -> Self {
        let recognizer = ClickGestureRecognizer(clicks: clicks, touches: touches, buttonMask: buttonMask)
        declarativeView.addGestureRecognizer(recognizer.trackState { [weak self] in
            guard let self = self else { return }
            action(self, $0, recognizer)
        })
        return self
    }
    
    @discardableResult
    public func onClickGesture(clicks: Int = 1, touches: Int = 1, buttonMask: Int = 0x1, _ state: State<NSGestureRecognizer.State>) -> Self {
        onClickGesture(clicks: clicks, touches: touches, buttonMask: buttonMask) { v, s, r in
            state.wrappedValue = s
        }
    }
    
    // MARK: Double Click
    
    @discardableResult
    public func onDoubleClickGesture(touches: Int = 1, buttonMask: Int = 0x1, on state: NSGestureRecognizer.State = .ended, _ action: @escaping () -> Void) -> Self {
        onClickGesture(clicks: 2, touches: touches, buttonMask: buttonMask, on: state, action)
    }
    
    @discardableResult
    public func onDoubleClickGesture(touches: Int = 1, buttonMask: Int = 0x1, on state: NSGestureRecognizer.State = .ended, _ action: @escaping (Self) -> Void) -> Self {
        onClickGesture(clicks: 2, touches: touches, buttonMask: buttonMask, on: state, action)
    }
    
    @discardableResult
    public func onDoubleClickGesture(touches: Int = 1, buttonMask: Int = 0x1, _ action: @escaping (Self, NSGestureRecognizer.State) -> Void) -> Self {
        onClickGesture(clicks: 2, touches: touches, buttonMask: buttonMask, action)
    }
    
    @discardableResult
    public func onDoubleClickGesture(touches: Int = 1, buttonMask: Int = 0x1, _ action: @escaping (Self, NSGestureRecognizer.State, ClickGestureRecognizer) -> Void) -> Self {
        onClickGesture(clicks: 2, touches: touches, buttonMask: buttonMask, action)
    }
    
    @discardableResult
    public func onDoubleClickGesture(touches: Int = 1, buttonMask: Int = 0x1, _ state: State<NSGestureRecognizer.State>) -> Self {
        onClickGesture(clicks: 2, touches: touches, buttonMask: buttonMask, state)
    }
}
#endif
#endif
