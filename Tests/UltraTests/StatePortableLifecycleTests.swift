#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import Ultra

private final class TestStatesHolder: StatesHolder {
    let statesValues = StatesHolderValuesBox()
}

final class StatePortableLifecycleTests: XCTestCase {

    // MARK: - LCST-001

    func testLCST001TokenCancelIsIdempotent() {
        let state = State(wrappedValue: 0)
        var count = 0

        let token = state.listen { _, _ in count += 1 }

        state.wrappedValue = 1
        XCTAssertEqual(count, 1)

        token.cancel()
        token.cancel()
        token.cancel()

        state.wrappedValue = 2
        XCTAssertEqual(count, 1)
    }

    // MARK: - LCST-002

    func testLCST002TokenCancelRemovesSourceListener() {
        let state = State(wrappedValue: 0)
        var count = 0

        let token = state.listen { _, _ in count += 1 }

        state.wrappedValue = 1
        XCTAssertEqual(count, 1)

        token.cancel()

        state.wrappedValue = 2
        state.wrappedValue = 3

        XCTAssertEqual(count, 1)
    }

    // MARK: - LCST-003

    func testLCST003DirectSourceRemovalMakesTokenCancelSafe() {
        let state = State(wrappedValue: 0)
        var count = 0

        let token = state.listen { _, _ in count += 1 }

        state.removeListener(id: token.id)

        state.wrappedValue = 1
        XCTAssertEqual(count, 0)

        token.cancel()
        token.cancel()

        state.wrappedValue = 2
        XCTAssertEqual(count, 0)
    }

    // MARK: - LCST-004

    func testLCST004BulkRemovalCleansTokenAndHolderBookkeeping() {
        let state = State(wrappedValue: 0)
        let holder = TestStatesHolder()
        var count = 0

        let token = state.listen { _, _ in count += 1 }
        token.hold(in: holder)

        XCTAssertEqual(holder.statesValues.heldListeners.count, 1)

        state.removeListeners()

        state.wrappedValue = 1
        XCTAssertEqual(count, 0)
        XCTAssertEqual(holder.statesValues.heldListeners.count, 0)

        token.cancel()

        holder.releaseStates()
        XCTAssertEqual(holder.statesValues.heldListeners.count, 0)
    }

    // MARK: - LCST-005

    func testLCST005HolderReleaseCancelsHeldListeners() {
        let state = State(wrappedValue: 0)
        let holder = TestStatesHolder()
        var count = 0

        state.listen { _, _ in count += 1 }.hold(in: holder)

        state.wrappedValue = 1
        XCTAssertEqual(count, 1)

        holder.releaseStates()

        state.wrappedValue = 2
        XCTAssertEqual(count, 1)

        holder.releaseStates()
        holder.releaseStates()

        state.wrappedValue = 3
        XCTAssertEqual(count, 1)
    }

    // MARK: - LCST-006

    func testLCST006HolderInvalidationIsTerminal() {
        let state = State(wrappedValue: 0)
        let holder = TestStatesHolder()
        var count = 0

        state.listen { _, _ in count += 1 }.hold(in: holder)

        holder.invalidateStates()
        holder.invalidateStates()

        XCTAssertEqual(holder.statesValues.heldListeners.count, 0)

        state.wrappedValue = 1
        XCTAssertEqual(count, 0)
    }

    // MARK: - LCST-007

    func testLCST007HoldingIntoInvalidatedHolderCancelsIncomingToken() {
        let state = State(wrappedValue: 0)
        let holder = TestStatesHolder()
        var count = 0

        holder.invalidateStates()

        let token = state.listen { _, _ in count += 1 }
        token.hold(in: holder)

        state.wrappedValue = 1

        XCTAssertEqual(count, 0)
        XCTAssertEqual(holder.statesValues.heldListeners.count, 0)
    }

    // MARK: - LCST-008

    func testLCST008SourceDeinitInvalidatesTokenOrMakesCancelSafe() {
        let holder = TestStatesHolder()

        do {
            let state = State(wrappedValue: 0)
            state.listen { _, _ in }.hold(in: holder)
            XCTAssertEqual(holder.statesValues.heldListeners.count, 1)
        }

        XCTAssertEqual(holder.statesValues.heldListeners.count, 0)
    }

    // MARK: - LCST-009

    func testLCST009MappedStateDoesNotRetainSource() {
        var source: State<Int>? = State(wrappedValue: 2)

        weak var weakSource = source

        let mapped = source!.map { value in
            value * 3
        }

        XCTAssertEqual(mapped.wrappedValue, 6)
        XCTAssertEqual(mapped.statesValues.heldListeners.count, 1)

        source = nil

        XCTAssertNil(weakSource)
        XCTAssertEqual(mapped.wrappedValue, 6)
    }

    // MARK: - LCST-010

    func testLCST010CombinedMappedStateReleaseDisconnectsAllSources() {
        let left = State(wrappedValue: 1)
        let right = State(wrappedValue: 2)
        var evaluationCount = 0

        weak var weakMapped: State<Int>?

        do {
            let mapped = State<Int>(left, right) { left, right in
                evaluationCount += 1
                return left + right
            }

            weakMapped = mapped

            XCTAssertEqual(mapped.statesValues.heldListeners.count, 2)
            XCTAssertEqual(mapped.wrappedValue, 3)
            XCTAssertEqual(evaluationCount, 1)

            left.wrappedValue = 10

            XCTAssertEqual(mapped.wrappedValue, 12)
            XCTAssertEqual(evaluationCount, 2)

            right.wrappedValue = 20

            XCTAssertEqual(mapped.wrappedValue, 30)
            XCTAssertEqual(evaluationCount, 3)
        }

        XCTAssertNil(weakMapped)

        left.wrappedValue = 100
        right.wrappedValue = 200

        XCTAssertEqual(evaluationCount, 3)
    }

    // MARK: - LCST-011

    func testLCST011ListenerDeliveryOrderIsDeterministic() {
        let state = State(wrappedValue: 0)
        var log: [String] = []

        state.beginTrigger {
            log.append("begin")
        }
        state.listen { _, _ in
            log.append("listener")
        }
        state.endTrigger {
            log.append("end")
        }

        state.wrappedValue = 1

        XCTAssertEqual(log, ["begin", "listener", "end"])
    }

    // MARK: - LCST-012

    func testLCST012ListenerAddedDuringDispatchStartsNextMutation() {
        let state = State(wrappedValue: 0)
        var log: [String] = []

        var addedOnce = false

        state.listen { _, _ in
            log.append("A")
            if !addedOnce {
                addedOnce = true
                state.listen { _, _ in
                    log.append("C")
                }
            }
        }

        state.wrappedValue = 1
        XCTAssertEqual(log, ["A"])

        log.removeAll()

        state.wrappedValue = 2
        XCTAssertEqual(log, ["A", "C"])
    }

    // MARK: - LCST-013

    func testLCST013ListenerRemovedDuringDispatchAffectsNextMutationOnly() {
        let state = State(wrappedValue: 0)
        var log: [String] = []

        state.listen { _, _ in
            log.append("A")
            state.removeListeners()
        }

        state.listen { _, _ in
            log.append("B")
        }

        state.wrappedValue = 1
        XCTAssertEqual(log, ["A", "B"])

        log.removeAll()

        state.wrappedValue = 2
        XCTAssertTrue(log.isEmpty)
    }

    // MARK: - LCST-014

    func testLCST014ListenerCancelledDuringDispatchDoesNotCorruptCurrentSnapshot() {
        let state = State(wrappedValue: 0)
        var log: [String] = []

        var tokenB: StateListener?

        state.listen { _, _ in
            log.append("A")
            tokenB?.cancel()
        }

        tokenB = state.listen { _, _ in
            log.append("B")
        }

        state.wrappedValue = 1
        XCTAssertEqual(log, ["A", "B"])

        log.removeAll()

        state.wrappedValue = 2
        XCTAssertEqual(log, ["A"])
    }

    // MARK: - LCST-015

    func testLCST015NestedMutationUsesSpecifiedOrder() {
        let state = State(wrappedValue: 0)
        var log: [String] = []

        state.listen { old, new in
            log.append("A:\(old)->\(new):start")

            if new == 1 {
                state.wrappedValue = 2
            }

            log.append("A:\(old)->\(new):end")
        }

        state.listen { old, new in
            log.append("B:\(old)->\(new)")
        }

        state.wrappedValue = 1

        XCTAssertEqual(log, [
            "A:0->1:start",
            "A:1->2:start",
            "A:1->2:end",
            "B:1->2",
            "A:0->1:end",
            "B:0->1",
        ])
    }

    // MARK: - LCST-016

    func testLCST016ResetUsesBeginListenerEndLifecycle() {
        let state = State(wrappedValue: 0)
        state.wrappedValue = 1

        var log: [String] = []

        state.beginTrigger {
            log.append("begin")
        }
        state.listen { old, new in
            log.append("listener:\(old)->\(new)")
        }
        state.endTrigger {
            log.append("end")
        }

        state.reset()

        XCTAssertEqual(state.wrappedValue, 0)
        XCTAssertEqual(log, [
            "begin",
            "listener:1->0",
            "end",
        ])
    }
}
#endif
