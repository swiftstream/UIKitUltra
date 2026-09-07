#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

final public class TapGestureRecognizer: UITapGestureRecognizer, _GestureTrackable, _GestureDelegatorable {
    var _tracker = _GestureTracker()
    var _delegator = _GestureDelegator()
    
    public init(taps: Int = 1, touches: Int = 1) {
        super.init(target: _tracker, action: #selector(_tracker.handle))
        numberOfTapsRequired = taps
        #if !os(tvOS)
        numberOfTouchesRequired = touches
        #endif
        delegate = _delegator
    }
    
    @discardableResult
    public func numberOfTapsRequired(_ v: Int) -> Self {
        numberOfTapsRequired = v
        return self
    }
    
    @discardableResult
    public func numberOfTapsRequired(_ state: UIKitPlus.State<Int>) -> Self {
        state.listen { [weak self] in
            self?.numberOfTapsRequired = $0
        }
        .hold(in: _tracker)
        return self
    }
    #if !os(tvOS)
    @discardableResult
    public func numberOfTouchesRequired(_ v: Int) -> Self {
        numberOfTouchesRequired = v
        return self
    }
    
    @discardableResult
    public func numberOfTouchesRequired(_ state: UIKitPlus.State<Int>) -> Self {
        state.listen { [weak self] in
            self?.numberOfTouchesRequired = $0
        }
        .hold(in: _tracker)
        return self
    }
    #endif
    var _tag: Int = 0
    public override var tag: Int {
        get { _tag }
        set { _tag = newValue }
    }
}
#endif
#endif
