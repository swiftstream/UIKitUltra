#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit

/// This object tracks pinch gestures on a track pad or other input device and stores the resulting magnification value for you to use in your code.
/// This gesture recognizer automatically sets the value of the delaysMagnificationEvents property to true.
final public class MagnificationGestureRecognizer: NSMagnificationGestureRecognizer, _GestureTrackable, _GestureDelegatorable {
    var _tracker = _GestureTracker()
    var _delegator = _GestureDelegator()
    
    public init(magnification: CGFloat? = nil) {
        super.init(target: _tracker, action: #selector(_tracker.handle))
        if let magnification = magnification {
            self.magnification = magnification
        }
        delegate = _delegator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func magnification(_ v: CGFloat) -> Self {
        magnification = v
        return self
    }
    
    @discardableResult
    public func magnification(_ state: UIKitPlus.State<CGFloat>) -> Self {
        state.listen { [weak self] in
            self?.magnification = $0
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
