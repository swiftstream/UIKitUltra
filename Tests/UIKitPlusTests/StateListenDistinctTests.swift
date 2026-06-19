import XCTest
@testable import UIKitPlus

final class StateListenDistinctTests: XCTestCase {

    func testListenDistinctNewValueSkipsEqualAssignments() {
        let state = State(wrappedValue: 0)

        var values: [Int] = []

        state.listenDistinct { newValue in
            values.append(newValue)
        }

        state.wrappedValue = 0
        state.wrappedValue = 1
        state.wrappedValue = 1
        state.wrappedValue = 2

        XCTAssertEqual(values, [1, 2])
    }

    func testListenDistinctOldNewReceivesOnlyDistinctPairs() {
        let state = State(wrappedValue: "a")

        var pairs: [(String, String)] = []

        state.listenDistinct { oldValue, newValue in
            pairs.append((oldValue, newValue))
        }

        state.wrappedValue = "a"
        state.wrappedValue = "b"
        state.wrappedValue = "b"
        state.wrappedValue = "c"

        XCTAssertEqual(pairs.map { $0.0 }, ["a", "b"])
        XCTAssertEqual(pairs.map { $0.1 }, ["b", "c"])
    }

    func testRegularListenStillFiresForEqualAssignments() {
        let state = State(wrappedValue: 0)

        var regularCalls = 0
        var distinctCalls = 0

        state.listen { _ in
            regularCalls += 1
        }

        state.listenDistinct { _ in
            distinctCalls += 1
        }

        state.wrappedValue = 0

        XCTAssertEqual(regularCalls, 1)
        XCTAssertEqual(distinctCalls, 0)
    }

    func testListenDistinctTokenCancelStopsFutureDistinctEvents() {
        let state = State(wrappedValue: 0)

        var calls = 0

        let listener = state.listenDistinct { _ in
            calls += 1
        }

        state.wrappedValue = 1
        XCTAssertEqual(calls, 1)

        listener.cancel()

        state.wrappedValue = 2
        XCTAssertEqual(calls, 1)
    }

    func testListenDistinctTokenCanBeHeldInStatesHolder() {
        let state = State(wrappedValue: 0)
        let holder = TempStatesHolder()

        var calls = 0

        state.listenDistinct { _ in
            calls += 1
        }
        .hold(in: holder)

        state.wrappedValue = 1
        XCTAssertEqual(calls, 1)

        holder.invalidateStates()

        state.wrappedValue = 2
        XCTAssertEqual(calls, 1)
    }

    func testRemoveListenersRemovesDistinctListeners() {
        let state = State(wrappedValue: 0)

        var calls = 0

        state.listenDistinct { _ in
            calls += 1
        }

        state.wrappedValue = 1
        XCTAssertEqual(calls, 1)

        state.removeListeners()

        state.wrappedValue = 2
        XCTAssertEqual(calls, 1)
    }

    func testCodableStateListenDistinctWorks() {
        let state = CodableState(wrappedValue: 0)

        var values: [Int] = []

        state.listenDistinct { newValue in
            values.append(newValue)
        }

        state.wrappedValue = 0
        state.wrappedValue = 1
        state.wrappedValue = 1
        state.wrappedValue = 2

        XCTAssertEqual(values, [1, 2])
    }

    func testInnerStateListenDistinctWorks() {
        let parent = State(wrappedValue: SampleStateValue(title: "a"))
        let inner = InnerState(parent, \.title)

        var values: [String] = []

        inner.listenDistinct { newValue in
            values.append(newValue)
        }

        inner.wrappedValue = "a"
        inner.wrappedValue = "b"
        inner.wrappedValue = "b"
        inner.wrappedValue = "c"

        XCTAssertEqual(values, ["b", "c"])
    }

    func testListenDistinctWorksWithOptionalValues() {
        let state = State<Int?>(wrappedValue: nil)

        var values: [Int?] = []

        state.listenDistinct { newValue in
            values.append(newValue)
        }

        state.wrappedValue = nil
        state.wrappedValue = 1
        state.wrappedValue = 1
        state.wrappedValue = nil

        XCTAssertEqual(values.count, 2)
        XCTAssertEqual(values[0], 1)
        XCTAssertNil(values[1])
    }
}

private struct SampleStateValue: Equatable {
    var title: String
}
