import XCTest
@testable import UIKitPlus

final class StateOptionalMergeTests: XCTestCase {

    func testOptionalStateValueOptionalConformanceReturnsWrappedValue() {
        let value: Int? = 42
        XCTAssertEqual(value.optional, 42)
    }

    func testOptionalStateValueUnwrapBuildsOptionalValue() {
        let value = Optional<Int>.unwrap(42)
        XCTAssertEqual(value, 42)
    }

    func testMergeWithNonOptionalCopiesNonOptionalToOptionalInitially() {
        let optional = State<Int?>(wrappedValue: nil)
        let value = State<Int>(wrappedValue: 42)

        optional.mergeWithNonOptional(with: value)

        XCTAssertEqual(optional.wrappedValue, 42)
        XCTAssertEqual(value.wrappedValue, 42)
    }

    func testMergeWithNonOptionalPropagatesNonOptionalToOptional() {
        let optional = State<Int?>(wrappedValue: nil)
        let value = State<Int>(wrappedValue: 42)

        optional.mergeWithNonOptional(with: value)

        value.wrappedValue = 100
        XCTAssertEqual(optional.wrappedValue, 100)
    }

    func testMergeWithNonOptionalPropagatesOptionalToNonOptional() {
        let optional = State<Int?>(wrappedValue: nil)
        let value = State<Int>(wrappedValue: 42)

        optional.mergeWithNonOptional(with: value)

        optional.wrappedValue = 200
        XCTAssertEqual(value.wrappedValue, 200)
    }

    func testMergeWithNonOptionalIgnoresNilOptionalAssignments() {
        let optional = State<Int?>(wrappedValue: nil)
        let value = State<Int>(wrappedValue: 42)

        optional.mergeWithNonOptional(with: value)

        value.wrappedValue = 300
        optional.wrappedValue = nil

        XCTAssertEqual(value.wrappedValue, 300)
        XCTAssertNil(optional.wrappedValue)
    }

    func testMergeWithNonOptionalCancelStopsExternalToOptionalDirection() {
        let optional = State<Int?>(wrappedValue: nil)
        let value = State<Int>(wrappedValue: 42)

        let listeners = optional.mergeWithNonOptional(with: value)
        XCTAssertEqual(listeners.count, 2)

        listeners[0].cancel()

        value.wrappedValue = 10
        XCTAssertNotEqual(optional.wrappedValue, 10)
    }

    func testMergeWithNonOptionalCancelStopsOptionalToExternalDirection() {
        let optional = State<Int?>(wrappedValue: nil)
        let value = State<Int>(wrappedValue: 42)

        let listeners = optional.mergeWithNonOptional(with: value)
        XCTAssertEqual(listeners.count, 2)

        listeners[1].cancel()

        optional.wrappedValue = 10
        XCTAssertNotEqual(value.wrappedValue, 10)
    }

    func testMergeWithNonOptionalDoesNotRecurseInfinitely() {
        let optional = State<Int?>(wrappedValue: nil)
        let value = State<Int>(wrappedValue: 1)

        optional.mergeWithNonOptional(with: value)

        var optionalChanges = 0
        var valueChanges = 0

        optional.listen { _ in optionalChanges += 1 }
        value.listen { _ in valueChanges += 1 }

        value.wrappedValue = 2

        XCTAssertEqual(optional.wrappedValue, 2)
        XCTAssertLessThanOrEqual(optionalChanges, 2)
        XCTAssertLessThanOrEqual(valueChanges, 1)
    }
}
