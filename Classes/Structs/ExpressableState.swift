import Foundation

extension State {
    public func map<Result>(_ expression: @escaping () -> Result) -> State<Result> {
        .init(self, expression)
    }

    public func map<Result>(_ expression: @escaping (Value) -> Result) -> State<Result> {
        .init(self, expression)
    }
}

// MARK: Any States to Expressable

public protocol AnyState: AnyObject {
    var id: UUID { get }

    @discardableResult
    func listen(_ listener: @escaping () -> Void) -> StateListener

    func removeListener(id: UUID)
    func removeAllListeners()
}

extension Array where Element == AnyState {
    public func map<Result>(_ expression: @escaping () -> Result) -> State<Result> {
        let state = State<Result>.init(wrappedValue: expression())

        for source in self {
            source.listen { [weak state] in
                state?.wrappedValue = expression()
            }.hold(in: state)
        }

        return state
    }
}
