import Foundation

public protocol StatesHolder: AnyObject {
    var statesValues: StatesHolderValuesBox { get }
}

public final class StatesHolderValuesBox {
    var heldListeners: [UUID: StateListener] = [:]
    var callbacks: [() -> Void] = []
    var isInvalidated = false

    public init() {}
}

final class WeakStatesHolderValuesBox {
    weak var value: StatesHolderValuesBox?

    init(_ value: StatesHolderValuesBox) {
        self.value = value
    }
}

public extension StatesHolder {
    func releaseStates() {
        let listeners = Array(statesValues.heldListeners.values)
        statesValues.heldListeners.removeAll()

        let callbacks = statesValues.callbacks
        statesValues.callbacks.removeAll()

        listeners.forEach { $0.cancel() }
        callbacks.forEach { $0() }
    }
}

public extension StatesHolder {
    func invalidateStates() {
        guard !statesValues.isInvalidated else { return }

        statesValues.isInvalidated = true

        let listeners = Array(statesValues.heldListeners.values)
        statesValues.heldListeners.removeAll()

        let callbacks = statesValues.callbacks
        statesValues.callbacks.removeAll()

        listeners.forEach { $0.cancel() }
        callbacks.forEach { $0() }
    }
}

public extension StatesHolder {
    func releaseState(_ state: AnyState) {
        let listeners = statesValues.heldListeners.values.filter {
            $0.sourceID == state.id
        }

        listeners.forEach { $0.cancel() }
    }
}

public extension StatesHolder {
    func awaitRelease(_ callback: @escaping () -> Void) {
        guard !statesValues.isInvalidated else {
            callback()
            return
        }

        statesValues.callbacks.append(callback)
    }
}

public final class TempStatesHolder: StatesHolder {
    public let statesValues = StatesHolderValuesBox()

    public init() {}

    deinit {
        invalidateStates()
    }
}

public extension Array where Element == StateListener {
    @discardableResult
    func hold(in holder: StatesHolder) -> Self {
        forEach { $0.hold(in: holder) }
        return self
    }
}
