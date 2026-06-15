#if os(macOS)
import AppKit
#else
import UIKit
#endif

public protocol GestureTrackable: AnyObject {
    @discardableResult
    func trackState(_ action: @escaping (UGestureRecognizer.State) -> Void) -> Self
    
    @discardableResult
    func trackState(_ action: @escaping (UGestureRecognizer.State, Self) -> Void) -> Self
    
    @discardableResult
    func trackState(_ state: State<UGestureRecognizer.State>) -> Self
    
    @discardableResult
    func onPossible(_ action: @escaping () -> Void) -> Self
    @discardableResult
    func onPossible(_ action: @escaping (Self) -> Void) -> Self
    
    @discardableResult
    func onBegan(_ action: @escaping () -> Void) -> Self
    @discardableResult
    func onBegan(_ action: @escaping (Self) -> Void) -> Self
    
    @discardableResult
    func onChanged(_ action: @escaping () -> Void) -> Self
    @discardableResult
    func onChanged(_ action: @escaping (Self) -> Void) -> Self
    
    @discardableResult
    func onEnded(_ action: @escaping () -> Void) -> Self
    @discardableResult
    func onEnded(_ action: @escaping (Self) -> Void) -> Self
    
    @discardableResult
    func onCancelled(_ action: @escaping () -> Void) -> Self
    @discardableResult
    func onCancelled(_ action: @escaping (Self) -> Void) -> Self
    
    @discardableResult
    func onFailed(_ action: @escaping () -> Void) -> Self
    @discardableResult
    func onFailed(_ action: @escaping (Self) -> Void) -> Self
}

@MainActor
protocol _GestureTrackable: GestureTrackable {
    var _tracker: _GestureTracker { get set }
}

extension GestureTrackable {
    @discardableResult
    public func onPossible(_ action: @escaping () -> Void) -> Self {
        onPossible { _ in action() }
    }
    
    @discardableResult
    public func onBegan(_ action: @escaping () -> Void) -> Self {
        onBegan { _ in action() }
    }
    
    @discardableResult
    public func onChanged(_ action: @escaping () -> Void) -> Self {
        onChanged { _ in action() }
    }
    
    @discardableResult
    public func onEnded(_ action: @escaping () -> Void) -> Self {
        onEnded { _ in action() }
    }
    
    @discardableResult
    public func onCancelled(_ action: @escaping () -> Void) -> Self {
        onCancelled { _ in action() }
    }
    
    @discardableResult
    public func onFailed(_ action: @escaping () -> Void) -> Self {
        onFailed { _ in action() }
    }
}

@available(iOS 13.0, *)
@MainActor
extension GestureTrackable {
    @discardableResult
    public func trackState(_ action: @escaping (UGestureRecognizer.State) -> Void) -> Self {
        guard let s = self as? _GestureTrackable else { return self }
        s._tracker.change = action
        return self
    }
    
    @discardableResult
    public func trackState(_ action: @escaping (UGestureRecognizer.State, Self) -> Void) -> Self {
        guard let s = self as? _GestureTrackable else { return self }
        s._tracker.change = { [weak self] in
            guard let self = self else { return }
            action($0, self)
        }
        return self
    }
    
    @discardableResult
    public func trackState(_ action: @escaping (Self, UGestureRecognizer.State) -> Void) -> Self {
        guard let s = self as? _GestureTrackable else { return self }
        s._tracker.change = { [weak self] in
            guard let self = self else { return }
            action(self, $0)
        }
        return self
    }
    
    @discardableResult
    public func trackState(_ state: State<UGestureRecognizer.State>) -> Self {
        guard let s = self as? _GestureTrackable else { return self }
        s._tracker.change = {
            state.wrappedValue = $0
        }
        return self
    }
    
    @discardableResult
    public func onPossible(_ action: @escaping (Self) -> Void) -> Self {
        guard let s = self as? _GestureTrackable else { return self }
        s._tracker.possible = { [weak self] in
            guard let self = self else { return }
            action(self)
        }
        return self
    }
    
    @discardableResult
    public func onBegan(_ action: @escaping (Self) -> Void) -> Self {
        guard let s = self as? _GestureTrackable else { return self }
        s._tracker.began = { [weak self] in
            guard let self = self else { return }
            action(self)
        }
        return self
    }
    
    @discardableResult
    public func onChanged(_ action: @escaping (Self) -> Void) -> Self {
        guard let s = self as? _GestureTrackable else { return self }
        s._tracker.changed = { [weak self] in
            guard let self = self else { return }
            action(self)
        }
        return self
    }
    
    @discardableResult
    public func onEnded(_ action: @escaping (Self) -> Void) -> Self {
        guard let s = self as? _GestureTrackable else { return self }
        s._tracker.ended = { [weak self] in
            guard let self = self else { return }
            action(self)
        }
        return self
    }
    
    @discardableResult
    public func onCancelled(_ action: @escaping (Self) -> Void) -> Self {
        guard let s = self as? _GestureTrackable else { return self }
        s._tracker.cancelled = { [weak self] in
            guard let self = self else { return }
            action(self)
        }
        return self
    }
    
    @discardableResult
    public func onFailed(_ action: @escaping (Self) -> Void) -> Self {
        guard let s = self as? _GestureTrackable else { return self }
        s._tracker.failed = { [weak self] in
            guard let self = self else { return }
            action(self)
        }
        return self
    }
    
    @discardableResult
    public func delegate(_ object: UGestureRecognizerDelegate) -> Self {
        guard let s = self as? _GestureTrackable else { return self }
        s._tracker.outerDelegate = object
        return self
    }
}

// for iOS lower than 13
@MainActor
extension _GestureTrackable {
    @discardableResult
    public func trackState(_ action: @escaping (UGestureRecognizer.State) -> Void) -> Self {
        _tracker.change = action
        return self
    }
    
    @discardableResult
    public func trackState(_ action: @escaping (UGestureRecognizer.State, Self) -> Void) -> Self {
        _tracker.change = { [weak self] in
            guard let self = self else { return }
            action($0, self)
        }
        return self
    }
    
    @discardableResult
    public func trackState(_ action: @escaping (Self, UGestureRecognizer.State) -> Void) -> Self {
        _tracker.change = { [weak self] in
            guard let self = self else { return }
            action(self, $0)
        }
        return self
    }
    
    @discardableResult
    public func trackState(_ state: State<UGestureRecognizer.State>) -> Self {
        _tracker.change = {
            state.wrappedValue = $0
        }
        return self
    }
    
    @discardableResult
    public func onPossible(_ action: @escaping (Self) -> Void) -> Self {
        _tracker.possible = { [weak self] in
            guard let self = self else { return }
            action(self)
        }
        return self
    }
    
    @discardableResult
    public func onBegan(_ action: @escaping (Self) -> Void) -> Self {
        _tracker.began = { [weak self] in
            guard let self = self else { return }
            action(self)
        }
        return self
    }
    
    @discardableResult
    public func onChanged(_ action: @escaping (Self) -> Void) -> Self {
        _tracker.changed = { [weak self] in
            guard let self = self else { return }
            action(self)
        }
        return self
    }
    
    @discardableResult
    public func onEnded(_ action: @escaping (Self) -> Void) -> Self {
        _tracker.ended = { [weak self] in
            guard let self = self else { return }
            action(self)
        }
        return self
    }
    
    @discardableResult
    public func onCancelled(_ action: @escaping (Self) -> Void) -> Self {
        _tracker.cancelled = { [weak self] in
            guard let self = self else { return }
            action(self)
        }
        return self
    }
    
    @discardableResult
    public func onFailed(_ action: @escaping (Self) -> Void) -> Self {
        _tracker.failed = { [weak self] in
            guard let self = self else { return }
            action(self)
        }
        return self
    }
    
    @discardableResult
    public func delegate(_ object: UGestureRecognizerDelegate) -> Self {
        _tracker.outerDelegate = object
        return self
    }
}
