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

public extension Stateable where Value: Equatable {
    @discardableResult
    func listenDistinct(
        _ listener: @escaping (_ old: Value, _ new: Value) -> Void
    ) -> StateListener {
        listen { oldValue, newValue in
            guard oldValue != newValue else { return }

            listener(oldValue, newValue)
        }
    }

    @discardableResult
    func listenDistinct(
        _ listener: @escaping (_ value: Value) -> Void
    ) -> StateListener {
        listenDistinct { _, newValue in
            listener(newValue)
        }
    }
}

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
        removeListeners()
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

    init <A, B, C>(
        _ stateA: State<A>,
        _ stateB: State<B>,
        _ stateC: State<C>,
        _ expression: @escaping (A, B, C) -> Value
    ) {
        let valueExpression: () -> Value? = { [weak stateA, weak stateB, weak stateC] in
            guard let stateA = stateA, let stateB = stateB, let stateC = stateC else { return nil }
            return expression(stateA.wrappedValue, stateB.wrappedValue, stateC.wrappedValue)
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
        stateC.listen(listener).hold(in: self)
    }

    init <A, B, C, D>(
        _ stateA: State<A>,
        _ stateB: State<B>,
        _ stateC: State<C>,
        _ stateD: State<D>,
        _ expression: @escaping (A, B, C, D) -> Value
    ) {
        let valueExpression: () -> Value? = { [weak stateA, weak stateB, weak stateC, weak stateD] in
            guard let stateA = stateA, let stateB = stateB, let stateC = stateC, let stateD = stateD else { return nil }
            return expression(stateA.wrappedValue, stateB.wrappedValue, stateC.wrappedValue, stateD.wrappedValue)
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
        stateC.listen(listener).hold(in: self)
        stateD.listen(listener).hold(in: self)
    }

    init <A, B, C, D, E>(
        _ stateA: State<A>,
        _ stateB: State<B>,
        _ stateC: State<C>,
        _ stateD: State<D>,
        _ stateE: State<E>,
        _ expression: @escaping (A, B, C, D, E) -> Value
    ) {
        let valueExpression: () -> Value? = { [weak stateA, weak stateB, weak stateC, weak stateD, weak stateE] in
            guard let stateA = stateA, let stateB = stateB, let stateC = stateC, let stateD = stateD, let stateE = stateE else { return nil }
            return expression(stateA.wrappedValue, stateB.wrappedValue, stateC.wrappedValue, stateD.wrappedValue, stateE.wrappedValue)
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
        stateC.listen(listener).hold(in: self)
        stateD.listen(listener).hold(in: self)
        stateE.listen(listener).hold(in: self)
    }

    init <A, B, C, D, E, F>(
        _ stateA: State<A>,
        _ stateB: State<B>,
        _ stateC: State<C>,
        _ stateD: State<D>,
        _ stateE: State<E>,
        _ stateF: State<F>,
        _ expression: @escaping (A, B, C, D, E, F) -> Value
    ) {
        let valueExpression: () -> Value? = { [weak stateA, weak stateB, weak stateC, weak stateD, weak stateE, weak stateF] in
            guard let stateA = stateA, let stateB = stateB, let stateC = stateC, let stateD = stateD, let stateE = stateE, let stateF = stateF else { return nil }
            return expression(stateA.wrappedValue, stateB.wrappedValue, stateC.wrappedValue, stateD.wrappedValue, stateE.wrappedValue, stateF.wrappedValue)
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
        stateC.listen(listener).hold(in: self)
        stateD.listen(listener).hold(in: self)
        stateE.listen(listener).hold(in: self)
        stateF.listen(listener).hold(in: self)
    }

    init <A, B, C, D, E, F, G>(
        _ stateA: State<A>,
        _ stateB: State<B>,
        _ stateC: State<C>,
        _ stateD: State<D>,
        _ stateE: State<E>,
        _ stateF: State<F>,
        _ stateG: State<G>,
        _ expression: @escaping (A, B, C, D, E, F, G) -> Value
    ) {
        let valueExpression: () -> Value? = { [weak stateA, weak stateB, weak stateC, weak stateD, weak stateE, weak stateF, weak stateG] in
            guard let stateA = stateA, let stateB = stateB, let stateC = stateC, let stateD = stateD, let stateE = stateE, let stateF = stateF, let stateG = stateG else { return nil }
            return expression(stateA.wrappedValue, stateB.wrappedValue, stateC.wrappedValue, stateD.wrappedValue, stateE.wrappedValue, stateF.wrappedValue, stateG.wrappedValue)
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
        stateC.listen(listener).hold(in: self)
        stateD.listen(listener).hold(in: self)
        stateE.listen(listener).hold(in: self)
        stateF.listen(listener).hold(in: self)
        stateG.listen(listener).hold(in: self)
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

    public func removeListeners() {
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

    public func release(with holder: StatesHolder) {
        holder.awaitRelease { [weak self] in
            self?.releaseStates()
        }
    }
}

public protocol OptionalStateValue {
    associatedtype Wrapped

    var optional: Wrapped? { get }

    static func unwrap(_ wrapped: Wrapped) -> Self
}

extension Optional: OptionalStateValue {
    public var optional: Wrapped? { self }

    public static func unwrap(_ wrapped: Wrapped) -> Self {
        wrapped
    }
}

public extension State where Value: OptionalStateValue, Value: ExpressibleByNilLiteral {
    @discardableResult
    func mergeWithNonOptional(with state: State<Value.Wrapped>) -> [StateListener] {
        wrappedValue = .unwrap(state.wrappedValue)

        var justSetExternal = false
        var justSetInternal = false

        let externalListener = state.listen { [weak self] newValue in
            guard !justSetInternal else { return }

            justSetExternal = true
            defer { justSetExternal = false }

            self?.wrappedValue = .unwrap(newValue)
        }

        let optionalListener = listen { [weak state] newValue in
            guard !justSetExternal else { return }
            guard let unwrappedValue = newValue.optional else { return }

            justSetInternal = true
            defer { justSetInternal = false }

            state?.wrappedValue = unwrappedValue
        }

        return [externalListener, optionalListener]
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

extension CombinedState {
    public func and<C>(_ state: State<C>) -> CombinedState3<A, B, C> {
        CombinedState3(self, state)
    }
}

public class CombinedState3<A, B, C> {
    let _box: CombinedState<A, B>
    let _c: State<C>

    init(_ box: CombinedState<A, B>, _ c: State<C>) {
        self._box = box
        self._c = c
    }

    public func map<Result>(_ expression: @escaping (A, B, C) -> Result) -> State<Result> {
        .init(_box._left, _box._right, _c, expression)
    }

    public func and<D>(_ state: State<D>) -> CombinedState4<A, B, C, D> {
        CombinedState4(self, state)
    }
}

public class CombinedState4<A, B, C, D> {
    let _box: CombinedState3<A, B, C>
    let _d: State<D>

    init(_ box: CombinedState3<A, B, C>, _ d: State<D>) {
        self._box = box
        self._d = d
    }

    public func map<Result>(_ expression: @escaping (A, B, C, D) -> Result) -> State<Result> {
        .init(_box._box._left, _box._box._right, _box._c, _d, expression)
    }

    public func and<E>(_ state: State<E>) -> CombinedState5<A, B, C, D, E> {
        CombinedState5(self, state)
    }
}

public class CombinedState5<A, B, C, D, E> {
    let _box: CombinedState4<A, B, C, D>
    let _e: State<E>

    init(_ box: CombinedState4<A, B, C, D>, _ e: State<E>) {
        self._box = box
        self._e = e
    }

    public func map<Result>(_ expression: @escaping (A, B, C, D, E) -> Result) -> State<Result> {
        .init(_box._box._box._left, _box._box._box._right, _box._box._c, _box._d, _e, expression)
    }

    public func and<F>(_ state: State<F>) -> CombinedState6<A, B, C, D, E, F> {
        CombinedState6(self, state)
    }
}

public class CombinedState6<A, B, C, D, E, F> {
    let _box: CombinedState5<A, B, C, D, E>
    let _f: State<F>

    init(_ box: CombinedState5<A, B, C, D, E>, _ f: State<F>) {
        self._box = box
        self._f = f
    }

    public func map<Result>(_ expression: @escaping (A, B, C, D, E, F) -> Result) -> State<Result> {
        .init(_box._box._box._box._left, _box._box._box._box._right, _box._box._box._c, _box._box._d, _box._e, _f, expression)
    }

    public func and<G>(_ state: State<G>) -> CombinedState7<A, B, C, D, E, F, G> {
        CombinedState7(self, state)
    }
}

public class CombinedState7<A, B, C, D, E, F, G> {
    let _box: CombinedState6<A, B, C, D, E, F>
    let _g: State<G>

    init(_ box: CombinedState6<A, B, C, D, E, F>, _ g: State<G>) {
        self._box = box
        self._g = g
    }

    public func map<Result>(_ expression: @escaping (A, B, C, D, E, F, G) -> Result) -> State<Result> {
        .init(_box._box._box._box._box._left, _box._box._box._box._box._right, _box._box._box._box._c, _box._box._box._d, _box._box._e, _box._f, _g, expression)
    }
}
