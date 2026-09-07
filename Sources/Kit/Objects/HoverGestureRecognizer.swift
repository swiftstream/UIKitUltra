#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

#if !os(tvOS)
@available(iOS 13.0, *)
final public class HoverGestureRecognizer: UIHoverGestureRecognizer, _GestureTrackable, _GestureDelegatorable {
    var _tracker = _GestureTracker()
    var _delegator = _GestureDelegator()
    
    public init() {
        super.init(target: _tracker, action: #selector(_tracker.handle))
        delegate = _delegator
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
