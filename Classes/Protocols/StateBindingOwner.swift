@MainActor
internal protocol _StateBindingOwner: AnyObject {
    var stateBindingHolder: TempStatesHolder { get }
}

internal extension StateListener {
    @discardableResult
    @MainActor
    func holdInStateBindingOwnerIfAvailable(
        _ candidate: AnyObject
    ) -> Self {
        guard let owner = candidate as? _StateBindingOwner else {
            return self
        }

        return hold(in: owner.stateBindingHolder)
    }
}
