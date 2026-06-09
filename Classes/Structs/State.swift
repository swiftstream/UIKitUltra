import Foundation

public protocol Stateable: AnyState {
    associatedtype Value

    var wrappedValue: Value { get set }

    @discardableResult
    func beginTrigger(_ trigger: @escaping () -> Void) -> StateListener

    @discardableResult
    func endTrigger(_ trigger: @escaping () -> Void) -> StateListener

    @discardableResult
    func listen(_ listener: @escaping (_ old: Value, _ new: Value) -> Void) -> StateListener

    @discardableResult
    func listen(_ listener: @escaping (_ value: Value) -> Void) -> StateListener

    @discardableResult
    func listen(_ listener: @escaping () -> Void) -> StateListener
}

public typealias UState = State

@propertyWrapper
open class State<Value>: Stateable, StatesHolder {
    public let id = UUID()
    public let statesValues = StatesHolderValuesBox()

    private var _originalValue: Value
    private var _wrappedValue: Value
    public var wrappedValue: Value {
        get { _wrappedValue }
        set {
            let oldValue = _wrappedValue
            _wrappedValue = newValue

            let beginSnapshot = beginTriggers.snapshot
            let listenerSnapshot = listeners.snapshot
            let endSnapshot = endTriggers.snapshot

            for trigger in beginSnapshot {
                trigger()
            }

            for listener in listenerSnapshot {
                listener(oldValue, newValue)
            }

            for trigger in endSnapshot {
                trigger()
            }
        }
    }

    public var projectedValue: State<Value> { self }

    public typealias Trigger = () -> Void
    public typealias Listener = (_ old: Value, _ new: Value) -> Void
    public typealias SimpleListener = (_ value: Value) -> Void

    private var beginTriggers = OrderedRegistrations<Trigger>()
    private var endTriggers = OrderedRegistrations<Trigger>()
    private var listeners = OrderedRegistrations<Listener>()
    private var listenerTokens: [UUID: StateListener] = [:]

    deinit {
        invalidateStates()
        removeAllListeners()
    }

    init (_ stateA: AnyState, _ stateB: AnyState, _ expression: @escaping () -> Value) {
        let value = expression()
        _originalValue = value
        _wrappedValue = value

        stateA.listen { [weak self] in
            self?.wrappedValue = expression()
        }.hold(in: self)

        stateB.listen { [weak self] in
            self?.wrappedValue = expression()
        }.hold(in: self)
    }

    init <A, B>(
        _ stateA: State<A>,
        _ stateB: State<B>,
        _ expression: @escaping (A, B) -> Value
    ) {
        let valueExpression: () -> Value? = { [weak stateA, weak stateB] in
            guard let stateA = stateA, let stateB = stateB else { return nil }

            return expression(
                stateA.wrappedValue,
                stateB.wrappedValue
            )
        }

        let value = valueExpression()!

        _originalValue = value
        _wrappedValue = value

        let listener: () -> Void = { [weak self] in
            guard let value = valueExpression() else { return }

            self?.wrappedValue = value
        }

        stateA.listen(listener).hold(in: self)
        stateB.listen(listener).hold(in: self)
    }

    init <A, B>(
        _ stateA: State<A>,
        _ stateB: State<B>,
        _ expression: @escaping (CombinedDeprecatedResult<A, B>) -> Value
    ) {
        let valueExpression: () -> Value? = { [weak stateA, weak stateB] in
            guard let stateA = stateA, let stateB = stateB else { return nil }

            return expression(
                .init(
                    left: stateA.wrappedValue,
                    right: stateB.wrappedValue
                )
            )
        }

        let value = valueExpression()!

        _originalValue = value
        _wrappedValue = value

        let listener: () -> Void = { [weak self] in
            guard let value = valueExpression() else { return }

            self?.wrappedValue = value
        }

        stateA.listen(listener).hold(in: self)
        stateB.listen(listener).hold(in: self)
    }

    public init(wrappedValue value: Value) {
        _originalValue = value
        _wrappedValue = value
    }

    public init (_ stateA: AnyState, _ expression: @escaping () -> Value) {
        let value = expression()
        _originalValue = value
        _wrappedValue = value

        stateA.listen { [weak self] in
            self?.wrappedValue = expression()
        }.hold(in: self)
    }

    public init <A>(
        _ stateA: State<A>,
        _ expression: @escaping (A) -> Value
    ) {
        let value = expression(stateA.wrappedValue)

        _originalValue = value
        _wrappedValue = value

        stateA.listen { [weak self, weak stateA] in
            guard let stateA = stateA else { return }

            self?.wrappedValue = expression(stateA.wrappedValue)
        }.hold(in: self)
    }

    public init <A>(
        _ stateA: State<A>,
        _ expressionTo: @escaping (A) -> Value,
        _ expressionFrom: @escaping (Value) -> A
    ) {
        let value = expressionTo(stateA.wrappedValue)

        _originalValue = value
        _wrappedValue = value

        var updatingFromSource = false
        var updatingFromMapped = false

        stateA.listen { [weak self, weak stateA] in
            guard !updatingFromMapped else { return }
            guard let stateA = stateA else { return }

            updatingFromSource = true
            defer { updatingFromSource = false }

            self?.wrappedValue = expressionTo(stateA.wrappedValue)
        }.hold(in: self)

        listen { [weak stateA] newValue in
            guard !updatingFromSource else { return }
            guard let stateA = stateA else { return }

            updatingFromMapped = true
            defer { updatingFromMapped = false }

            stateA.wrappedValue = expressionFrom(newValue)
        }.hold(in: self)
    }

    public func reset() {
        let oldValue = _wrappedValue
        _wrappedValue = _originalValue

        let beginSnapshot = beginTriggers.snapshot
        let listenerSnapshot = listeners.snapshot
        let endSnapshot = endTriggers.snapshot

        for trigger in beginSnapshot {
            trigger()
        }

        for listener in listenerSnapshot {
            listener(oldValue, _wrappedValue)
        }

        for trigger in endSnapshot {
            trigger()
        }
    }

    public func removeListener(id: UUID) {
        beginTriggers.remove(id: id)
        listeners.remove(id: id)
        endTriggers.remove(id: id)

        let token = listenerTokens.removeValue(forKey: id)
        token?.sourceDidRemove()
    }

    public func removeAllListeners() {
        beginTriggers.removeAll()
        listeners.removeAll()
        endTriggers.removeAll()

        let tokens = Array(listenerTokens.values)
        listenerTokens.removeAll()

        tokens.forEach { $0.sourceDidRemove() }
    }

    @discardableResult
    public func beginTrigger(_ trigger: @escaping Trigger) -> StateListener {
        let id = UUID()
        beginTriggers.append(id: id, handler: trigger)

        let token = StateListener(id: id, state: self)
        listenerTokens[id] = token

        return token
    }

    @discardableResult
    public func endTrigger(_ trigger: @escaping Trigger) -> StateListener {
        let id = UUID()
        endTriggers.append(id: id, handler: trigger)

        let token = StateListener(id: id, state: self)
        listenerTokens[id] = token

        return token
    }

    @discardableResult
    public func listen(_ listener: @escaping Listener) -> StateListener {
        let id = UUID()
        listeners.append(id: id, handler: listener)

        let token = StateListener(id: id, state: self)
        listenerTokens[id] = token

        return token
    }

    @discardableResult
    public func listen(_ listener: @escaping SimpleListener) -> StateListener {
        listen { _, newValue in
            listener(newValue)
        }
    }

    @discardableResult
    public func listen(_ listener: @escaping () -> Void) -> StateListener {
        listen { _, _ in
            listener()
        }
    }

    @discardableResult
    public func merge(with state: State<Value>) -> [StateListener] {
        guard self !== state else { return [] }

        wrappedValue = state.wrappedValue

        var justSetExternal = false
        var justSetInternal = false

        let externalListener = state.listen { [weak self] newValue in
            guard !justSetInternal else { return }

            justSetExternal = true
            defer { justSetExternal = false }

            self?.wrappedValue = newValue
        }

        let internalListener = listen { [weak state] newValue in
            guard !justSetExternal else { return }

            justSetInternal = true
            defer { justSetInternal = false }

            state?.wrappedValue = newValue
        }

        return [
            externalListener,
            internalListener,
        ]
    }

    public func and<V>(_ state: State<V>) -> CombinedState<Value, V> {
        CombinedState(left: projectedValue, right: state)
    }
}

public class CombinedState<A, B> {
    let _left: State<A>
    let _right: State<B>
    public var left: A { _left.wrappedValue }
    public var right: B { _right.wrappedValue }

    init (left: State<A>, right: State<B>) {
        self._left = left
        self._right = right
    }

    public func map<Result>(_ expression: @escaping () -> Result) -> State<Result> {
        .init(_left, _right, expression)
    }

    public func map<Result>(_ expression: @escaping (A, B) -> Result) -> State<Result> {
        .init(_left, _right, expression)
    }

    @available(*, deprecated, message: "🧨 This method will be removed soon. Please switch to `.map { left, right in }`.")
    public func map<Result>(_ expression: @escaping (CombinedDeprecatedResult<A, B>) -> Result) -> State<Result> {
        .init(_left, _right, expression)
    }
}

public struct CombinedDeprecatedResult<A, B> {
    public let left: A
    public let right: B
}
