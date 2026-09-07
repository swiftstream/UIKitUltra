#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import UIKitPlus

final class StateRemoveListenersTests: XCTestCase {

    func testRemoveListenersRemovesNormalListeners() {
        let state = State(wrappedValue: 0)

        var calls = 0

        state.listen { _ in
            calls += 1
        }

        state.wrappedValue = 1
        XCTAssertEqual(calls, 1)

        state.removeListeners()

        state.wrappedValue = 2
        XCTAssertEqual(calls, 1)
    }

    func testRemoveListenersRemovesBeginListenersAndEndTriggers() {
        let state = State(wrappedValue: 0)

        var beginCalls = 0
        var listenerCalls = 0
        var endCalls = 0

        state.beginTrigger {
            beginCalls += 1
        }

        state.listen { _ in
            listenerCalls += 1
        }

        state.endTrigger {
            endCalls += 1
        }

        state.wrappedValue = 1

        XCTAssertEqual(beginCalls, 1)
        XCTAssertEqual(listenerCalls, 1)
        XCTAssertEqual(endCalls, 1)

        state.removeListeners()

        state.wrappedValue = 2

        XCTAssertEqual(beginCalls, 1)
        XCTAssertEqual(listenerCalls, 1)
        XCTAssertEqual(endCalls, 1)
    }

    func testRemoveListenersInvalidatesHeldListenerTokenSafely() {
        let state = State(wrappedValue: 0)
        let holder = TempStatesHolder()

        var calls = 0

        let listener = state.listen { _ in
            calls += 1
        }
        .hold(in: holder)

        state.wrappedValue = 1
        XCTAssertEqual(calls, 1)

        state.removeListeners()

        state.wrappedValue = 2
        XCTAssertEqual(calls, 1)

        listener.cancel()

        state.wrappedValue = 3
        XCTAssertEqual(calls, 1)
    }

    func testRemoveListenersIsOnlyBulkRemovalAPI() {
        let state = State(wrappedValue: 0)

        var calls = 0

        state.listen { _ in
            calls += 1
        }

        state.wrappedValue = 1
        XCTAssertEqual(calls, 1)

        state.removeListeners()

        state.wrappedValue = 2
        XCTAssertEqual(calls, 1)
    }

    func testAnyStateRemoveListenersAliasWorks() {
        let state = State(wrappedValue: 0)
        let anyState: AnyState = state

        var calls = 0

        state.listen {
            calls += 1
        }

        state.wrappedValue = 1
        XCTAssertEqual(calls, 1)

        anyState.removeListeners()

        state.wrappedValue = 2
        XCTAssertEqual(calls, 1)
    }

    func testInnerStateRemoveListenersAliasWorks() {
        struct Parent {
            var name: String = "default"
        }

        let parentState = State(wrappedValue: Parent())
        let innerState = InnerState(parentState, \.name)

        var calls = 0

        innerState.listen { _ in
            calls += 1
        }

        parentState.wrappedValue = Parent(name: "updated")
        XCTAssertEqual(calls, 1)

        innerState.removeListeners()

        parentState.wrappedValue = Parent(name: "again")
        XCTAssertEqual(calls, 1)
    }

    func testCodableStateRemoveListenersAliasWorks() {
        let state = CodableState(wrappedValue: "initial")

        var calls = 0

        state.listen { _ in
            calls += 1
        }

        state.wrappedValue = "changed"
        XCTAssertEqual(calls, 1)

        state.removeListeners()

        state.wrappedValue = "again"
        XCTAssertEqual(calls, 1)
    }
}
#endif
