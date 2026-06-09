#if os(macOS)
import AppKit

final public class RotationGestureRecognizer: NSRotationGestureRecognizer, _GestureTrackable, _GestureDelegatorable {
    var _tracker = _GestureTracker()
    var _delegator = _GestureDelegator()
    
    public init(rotation: CGFloat? = nil) {
        super.init(target: _tracker, action: #selector(_tracker.handle))
        if let rotation = rotation {
            self.rotation = rotation
        }
        delegate = _delegator
    }
    
    public init(rotationInDegrees: CGFloat) {
        super.init(target: _tracker, action: #selector(_tracker.handle))
        self.rotationInDegrees = rotationInDegrees
        delegate = _delegator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func rotation(_ v: CGFloat) -> Self {
        rotation = v
        return self
    }
    
    @discardableResult
    public func rotation(_ state: UIKitPlus.State<CGFloat>) -> Self {
        state.listen { [weak self] in
            self?.rotation = $0
        }
        .hold(in: _tracker)
        return self
    }
    
    @discardableResult
    public func rotationInDegrees(_ v: CGFloat) -> Self {
        rotationInDegrees = v
        return self
    }
    
    @discardableResult
    public func rotationInDegrees(_ state: UIKitPlus.State<CGFloat>) -> Self {
        state.listen { [weak self] in
            self?.rotationInDegrees = $0
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
#else
import UIKit

#if !os(tvOS)
final public class RotationGestureRecognizer: UIRotationGestureRecognizer, _GestureTrackable, _GestureDelegatorable {
    var _tracker = _GestureTracker()
    var _delegator = _GestureDelegator()
    
    public init(rotation: CGFloat? = nil) {
        super.init(target: _tracker, action: #selector(_tracker.handle))
        if let rotation = rotation {
            self.rotation = rotation
        }
        delegate = _delegator
    }
    
    @discardableResult
    public func rotation(_ v: CGFloat) -> Self {
        rotation = v
        return self
    }
    
    @discardableResult
    public func rotation(_ state: UIKitPlus.State<CGFloat>) -> Self {
        state.listen { [weak self] in
            self?.rotation = $0
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
