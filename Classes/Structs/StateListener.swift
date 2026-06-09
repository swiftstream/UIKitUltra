import Foundation

public final class StateListener {
    public let id: UUID
    let sourceID: UUID

    private weak var state: AnyState?
    private var holderBoxes: [WeakStatesHolderValuesBox] = []
    private var isCancelled = false

    init(id: UUID, state: AnyState) {
        self.id = id
        sourceID = state.id
        self.state = state
    }

    @discardableResult
    public func hold(in holder: StatesHolder) -> Self {
        guard !isCancelled else { return self }

        let values = holder.statesValues

        guard !values.isInvalidated else {
            cancel()
            return self
        }

        values.heldListeners[id] = self

        holderBoxes.removeAll { $0.value == nil }

        if !holderBoxes.contains(where: { $0.value === values }) {
            holderBoxes.append(.init(values))
        }

        return self
    }

    public func cancel() {
        guard !isCancelled else { return }

        state?.removeListener(id: id)
        sourceDidRemove()
    }

    func sourceDidRemove() {
        guard !isCancelled else { return }

        isCancelled = true
        state = nil

        let boxes = holderBoxes
        holderBoxes.removeAll()

        boxes.forEach {
            $0.value?.heldListeners.removeValue(forKey: id)
        }
    }
}
