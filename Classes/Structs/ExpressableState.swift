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

public class AnyStates {
    private var _expression: (() -> Void)?
    
    @discardableResult
    init (_ states: [AnyState], expression: @escaping () -> Void) {
        _expression = expression
        for state in states {
            state.listen { [weak self] in
                self?._expression?()
            }
        }
    }
}

extension Array where Element == AnyState {
    public func map<Result>(_ expression: @escaping () -> Result) -> State<Result> {
        let state = State<Result>.init(wrappedValue: expression())
        AnyStates(self) { [weak state] in
            state?.wrappedValue = expression()
        }
        return state
    }
}
