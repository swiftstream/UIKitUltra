#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import UltraCore

@propertyWrapper
public class CodableState<Value>: Stateable, Codable, Equatable, Hashable where Value: Codable, Value: Hashable {
    public var wrappedValue: Value {
        get { projectedValue.wrappedValue }
        set { projectedValue.wrappedValue = newValue }
    }

    public var projectedValue: State<Value>

    public var id: UUID {
        projectedValue.id
    }

    public init(wrappedValue value: Value) {
        projectedValue = .init(wrappedValue: value)
    }

    required public init (from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Value.self)
        projectedValue = .init(wrappedValue: value)
    }

    public func encode(to encoder: Encoder) throws {
        var single = encoder.singleValueContainer()
        try single.encode(wrappedValue)
    }

    public func reset() {
        projectedValue.reset()
    }

    @discardableResult
    public func beginTrigger(_ trigger: @escaping State<Value>.Trigger) -> StateListener {
        projectedValue.beginTrigger(trigger)
    }

    @discardableResult
    public func endTrigger(_ trigger: @escaping State<Value>.Trigger) -> StateListener {
        projectedValue.endTrigger(trigger)
    }

    @discardableResult
    public func listen(_ listener: @escaping State<Value>.Listener) -> StateListener {
        projectedValue.listen(listener)
    }

    @discardableResult
    public func listen(_ listener: @escaping State<Value>.SimpleListener) -> StateListener {
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

    public static func == (lhs: CodableState<Value>, rhs: CodableState<Value>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}
#endif
