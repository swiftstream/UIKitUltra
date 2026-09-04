public protocol AnyIdentable {
    func identHash() -> Int
    func identValue() -> AnyHashable
}

public extension AnyIdentable {
    func identValue() -> AnyHashable {
        AnyHashable(identHash())
    }
}

public protocol Identable: Hashable, AnyIdentable {
    associatedtype ID: Hashable
    
    typealias IDKey = KeyPath<Self, ID>
    
    static var idKey: IDKey { get }
}

extension Identable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self[keyPath: Self.idKey])
    }
    
    public func identHash() -> Int {
        self[keyPath: Self.idKey].hashValue
    }

    public func identValue() -> AnyHashable {
        AnyHashable(self[keyPath: Self.idKey])
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.identHash() == rhs.identHash()
    }
}
