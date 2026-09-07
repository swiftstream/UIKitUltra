#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

@propertyWrapper
public class InnerState<Value, InnerValue>: AnyState, StatesHolder {
    private let _keyPath: WritableKeyPath<Value, InnerValue>
    private let _wrappedValue: State<Value>

    public var wrappedValue: InnerValue {
        get {
            _wrappedValue.wrappedValue[keyPath: _keyPath]
        }
        set {
            var parentValue = _wrappedValue.wrappedValue
            parentValue[keyPath: _keyPath] = newValue
            _wrappedValue.wrappedValue = parentValue
        }
    }

    @State
    private var innerState: InnerValue

    public var projectedValue: State<InnerValue> {
        $innerState
    }

    public var id: UUID {
        projectedValue.id
    }

    public let statesValues = StatesHolderValuesBox()

    public typealias Listener = (_ old: InnerValue, _ new: InnerValue) -> Void
    public typealias SimpleListener = (_ value: InnerValue) -> Void

    public init(
        _ value: State<Value>,
        _ keyPath: WritableKeyPath<Value, InnerValue>
    ) {
        _wrappedValue = value
        _keyPath = keyPath
        innerState = value.wrappedValue[keyPath: keyPath]

        value.listen { [weak self] newValue in
            guard let self = self else { return }

            self.innerState = newValue[keyPath: self._keyPath]
        }.hold(in: self)
    }

    deinit {
        invalidateStates()
    }

    @discardableResult
    public func listen(_ listener: @escaping Listener) -> StateListener {
        projectedValue.listen(listener)
    }

    @discardableResult
    public func listen(_ listener: @escaping SimpleListener) -> StateListener {
        projectedValue.listen(listener)
    }

    @discardableResult
    public func listen(_ listener: @escaping () -> Void) -> StateListener {
        projectedValue.listen(listener)
    }

    public func removeListener(id: UUID) {
        projectedValue.removeListener(id: id)
    }

    public func removeListeners() {
        projectedValue.removeListeners()
    }
}

public extension InnerState where InnerValue: Equatable {
    @discardableResult
    func listenDistinct(
        _ listener: @escaping (_ old: InnerValue, _ new: InnerValue) -> Void
    ) -> StateListener {
        projectedValue.listenDistinct(listener)
    }

    @discardableResult
    func listenDistinct(
        _ listener: @escaping (_ value: InnerValue) -> Void
    ) -> StateListener {
        projectedValue.listenDistinct(listener)
    }
}
#endif
