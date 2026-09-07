#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit

final public class PanGestureRecognizer: NSPanGestureRecognizer, _GestureTrackable, _GestureDelegatorable {
    var _tracker = _GestureTracker()
    var _delegator = _GestureDelegator()
    
    public init(touches: Int? = nil, buttonMask: Int? = nil) {
        super.init(target: _tracker, action: #selector(_tracker.handle))
        if let touches = touches {
            numberOfTouchesRequired = touches
        }
        if let buttonMask = buttonMask {
            self.buttonMask = buttonMask
        }
        delegate = _delegator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func numberOfTouches(_ v: Int) -> Self {
        numberOfTouchesRequired = v
        return self
    }
    
    @discardableResult
    public func numberOfTouches(_ state: UIKitPlus.State<Int>) -> Self {
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
    public func buttonMask(_ state: UIKitPlus.State<Int>) -> Self {
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
#else
import UIKit

final public class PanGestureRecognizer: UIPanGestureRecognizer, _GestureTrackable, _GestureDelegatorable {
    var _tracker = _GestureTracker()
    var _delegator = _GestureDelegator()
    
    public init(minTouches: Int? = nil, maxTouches: Int? = nil) {
        super.init(target: nil, action: nil)
        #if !os(tvOS)
        if let minTouches = minTouches {
            minimumNumberOfTouches = minTouches
        }
        if let maxTouches = maxTouches {
            maximumNumberOfTouches = maxTouches
        }
        #endif
        addTarget(_tracker, action: #selector(_tracker.handle))
        delegate = _delegator
    }
    #if !os(tvOS)
    @discardableResult
    public func minimumNumberOfTouches(_ v: Int) -> Self {
        minimumNumberOfTouches = v
        return self
    }
    
    @discardableResult
    public func minimumNumberOfTouches(_ state: UIKitPlus.State<Int>) -> Self {
        state.listen { [weak self] in
            self?.minimumNumberOfTouches = $0
        }
        .hold(in: _tracker)
        return self
    }
    
    @discardableResult
    public func maximumNumberOfTouches(_ v: Int) -> Self {
        maximumNumberOfTouches = v
        return self
    }
    
    @discardableResult
    public func maximumNumberOfTouches(_ state: UIKitPlus.State<Int>) -> Self {
        state.listen { [weak self] in
            self?.maximumNumberOfTouches = $0
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
