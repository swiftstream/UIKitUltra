#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

public protocol StateValuable {
    associatedtype Value

    var simpleValue: Value { get }
    var stateValue: State<Value>? { get }
}

extension State: StateValuable {
    public var simpleValue: Value {
        wrappedValue
    }

    public var stateValue: State<Value>? {
        self
    }
}

extension CodableState: StateValuable {
    public var simpleValue: Value {
        wrappedValue
    }

    public var stateValue: State<Value>? {
        projectedValue
    }
}

extension InnerState: StateValuable {
    public var simpleValue: InnerValue {
        wrappedValue
    }

    public var stateValue: State<InnerValue>? {
        projectedValue
    }
}

extension String: StateValuable {
    public var simpleValue: String { self }
    public var stateValue: State<String>? { nil }
}

extension Bool: StateValuable {
    public var simpleValue: Bool { self }
    public var stateValue: State<Bool>? { nil }
}

extension Int: StateValuable {
    public var simpleValue: Int { self }
    public var stateValue: State<Int>? { nil }
}

extension Double: StateValuable {
    public var simpleValue: Double { self }
    public var stateValue: State<Double>? { nil }
}
#endif
