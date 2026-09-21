#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

#if !os(tvOS)
final public class PinchGestureRecognizer: UIPinchGestureRecognizer, _GestureTrackable, _GestureDelegatorable {
    var _tracker = _GestureTracker()
    var _delegator = _GestureDelegator()
    
    public init(scale: CGFloat? = nil) {
        super.init(target: _tracker, action: #selector(_tracker.handle))
        if let scale = scale {
            self.scale = scale
        }
        delegate = _delegator
    }
    
    @discardableResult
    public func scale(_ v: CGFloat) -> Self {
        scale = v
        return self
    }
    
    @discardableResult
    public func scale(_ state: Ultra.State<CGFloat>) -> Self {
        state.listen { [weak self] in
            self?.scale = $0
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
#endif
