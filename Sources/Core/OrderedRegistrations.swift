import Foundation

struct OrderedRegistration<Handler> {
    let id: UUID
    let handler: Handler
}

struct OrderedRegistrations<Handler> {
    private var values: [OrderedRegistration<Handler>] = []

    mutating func append(id: UUID, handler: Handler) {
        values.append(.init(id: id, handler: handler))
    }

    mutating func remove(id: UUID) {
        values.removeAll { $0.id == id }
    }

    mutating func removeAll() {
        values.removeAll()
    }

    var snapshot: [Handler] {
        values.map { $0.handler }
    }
}
