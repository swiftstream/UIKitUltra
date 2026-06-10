internal protocol _StateBindingOwner: AnyObject {
    var stateBindingHolder: TempStatesHolder { get }
}

internal extension StateListener {
    @discardableResult
    func holdIfOwned(by candidate: AnyObject) -> Self {
        guard let owner = candidate as? _StateBindingOwner else {
            return self
        }

        return hold(in: owner.stateBindingHolder)
    }
}
