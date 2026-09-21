#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit

final public class ClickGestureRecognizer: NSClickGestureRecognizer, _GestureTrackable, _GestureDelegatorable {
    var _tracker = _GestureTracker()
    var _delegator = _GestureDelegator()
    
    public init(clicks: Int = 1, touches: Int = 1, buttonMask: Int = 0x1) {
        super.init(target: _tracker, action: #selector(_tracker.handle))
        self.numberOfClicksRequired = clicks
        self.numberOfTouchesRequired = touches
        self.buttonMask = buttonMask
        delegate = _delegator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func numberOfClicksRequired(_ v: Int) -> Self {
        numberOfClicksRequired = v
        return self
    }
    
    @discardableResult
    public func numberOfClicksRequired(_ state: Ultra.State<Int>) -> Self {
        state.listen { [weak self] in
            self?.numberOfClicksRequired = $0
        }
        .hold(in: _tracker)
        return self
    }
    
    @discardableResult
    public func numberOfTouchesRequired(_ v: Int) -> Self {
        numberOfTouchesRequired = v
        return self
    }
    
    @discardableResult
    public func numberOfTouchesRequired(_ state: Ultra.State<Int>) -> Self {
        state.listen { [weak self] in
            self?.numberOfTouchesRequired = $0
        }
        .hold(in: _tracker)
        return self
    }
    
    @discardableResult
    public func buttonMask(_ v: Int) -> Self {
        buttonMask = v
        return self
    }
    
    @discardableResult
    public func buttonMask(_ state: Ultra.State<Int>) -> Self {
        state.listen { [weak self] in
            self?.buttonMask = $0
        }
        .hold(in: _tracker)
        return self
    }
    
    var _tag: Int = 0
    public override var tag: Int {
        get { _tag }
        set { _tag = newValue }
    }
}
#endif
#endif
