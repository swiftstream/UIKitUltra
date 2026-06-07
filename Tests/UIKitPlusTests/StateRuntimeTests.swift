import XCTest
@testable import UIKitPlus

final class StateRuntimeTests: XCTestCase {

    // MARK: - Test 1: Wrapped-value lifecycle phase order [ST2][MU2]

    func testWrappedValueLifecycleOrder() {
        let state = State(wrappedValue: 0)
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

        state.wrappedValue = 1

        XCTAssertEqual(log, [
            "begin",
            "listener:0->1",
            "end",
        ])
    }

    // MARK: - Test 2: Registration order inside phases [ST2]

    func testWrappedValueCallbackRegistrationOrder() {
        let state = State(wrappedValue: 0)
        var log: [String] = []

        state.beginTrigger { log.append("begin:1") }
        state.beginTrigger { log.append("begin:2") }
        state.listen { _, _ in log.append("listener:1") }
        state.listen { _, _ in log.append("listener:2") }
        state.endTrigger { log.append("end:1") }
        state.endTrigger { log.append("end:2") }

        state.wrappedValue = 1

        XCTAssertEqual(log, [
            "begin:1",
            "begin:2",
            "listener:1",
            "listener:2",
            "end:1",
            "end:2",
        ])
    }

    // MARK: - Test 3: Reset lifecycle [ST2]

    func testResetLifecycleOrder() {
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

    // MARK: - Test 4: Global listener removal [ST6]

    func testRemoveAllListenersRemovesAllCallbacks() {
        let state = State(wrappedValue: 0)
        var log: [String] = []

        state.beginTrigger { log.append("begin") }
        state.listen { _, _ in log.append("listener") }
        state.endTrigger { log.append("end") }

        state.removeAllListeners()

        state.wrappedValue = 1

        XCTAssertTrue(log.isEmpty)
    }

    // MARK: - Test 5: Merge initial synchronization [ST4]

    func testMergeInitialSynchronization() {
        let internalState = State(wrappedValue: 1)
        let externalState = State(wrappedValue: 2)

        internalState.merge(with: externalState)

        XCTAssertEqual(internalState.wrappedValue, 2)
        XCTAssertEqual(externalState.wrappedValue, 2)
    }

    // MARK: - Test 6: Merge external -> internal [ST4]

    func testMergeExternalToInternal() {
        let internalState = State(wrappedValue: 1)
        let externalState = State(wrappedValue: 2)

        internalState.merge(with: externalState)

        externalState.wrappedValue = 10

        XCTAssertEqual(internalState.wrappedValue, 10)
    }

    // MARK: - Test 7: Merge internal -> external [ST4]

    func testMergeInternalToExternal() {
        let internalState = State(wrappedValue: 1)
        let externalState = State(wrappedValue: 2)

        internalState.merge(with: externalState)

        internalState.wrappedValue = 20

        XCTAssertEqual(externalState.wrappedValue, 20)
    }

    // MARK: - Test 8: Merge avoids ping-pong [ST4][MU3]

    func testMergeDoesNotPingPong() {
        let internalState = State(wrappedValue: 1)
        let externalState = State(wrappedValue: 2)

        internalState.merge(with: externalState)

        var internalCount = 0
        var externalCount = 0

        internalState.listen { _, _ in internalCount += 1 }
        externalState.listen { _, _ in externalCount += 1 }

        externalState.wrappedValue = 10

        XCTAssertEqual(internalCount, 1)
        XCTAssertEqual(externalCount, 1)

        internalCount = 0
        externalCount = 0

        internalState.wrappedValue = 20

        XCTAssertEqual(internalCount, 1)
        XCTAssertEqual(externalCount, 1)
    }

    // MARK: - Test 9: Single-source map initial derivation [ST3]

    func testSingleSourceMapInitialDerivation() {
        let source = State(wrappedValue: 2)
        let mapped = source.map { $0 * 3 }

        XCTAssertEqual(mapped.wrappedValue, 6)
    }

    // MARK: - Test 10: Single-source map future propagation [ST3]

    func testSingleSourceMapPropagation() {
        let source = State(wrappedValue: 2)
        let mapped = source.map { $0 * 3 }

        source.wrappedValue = 4

        XCTAssertEqual(mapped.wrappedValue, 12)
    }

    // MARK: - Test 11: Two-source map initial derivation [ST5]

    func testCombinedTwoSourceMapInitialDerivation() {
        let left = State(wrappedValue: 2)
        let right = State(wrappedValue: 3)
        let mapped = left.and(right).map { l, r in l + r }

        XCTAssertEqual(mapped.wrappedValue, 5)
    }

    // MARK: - Test 12: Two-source map future propagation [ST5]

    func testCombinedTwoSourceMapPropagationFromEitherSource() {
        let left = State(wrappedValue: 2)
        let right = State(wrappedValue: 3)
        let mapped = left.and(right).map { l, r in l + r }

        left.wrappedValue = 4
        XCTAssertEqual(mapped.wrappedValue, 7)

        right.wrappedValue = 5
        XCTAssertEqual(mapped.wrappedValue, 9)
    }

    // MARK: - Test 13: Characterize broken [AnyState].map propagation [ST3]

    func testAnyStateArrayMapCharacterizesMissingPropagation() {
        let left = State(wrappedValue: 1)
        let right = State(wrappedValue: 2)

        let mapped = ([left, right] as [AnyState]).map {
            left.wrappedValue + right.wrappedValue
        }

        XCTAssertEqual(mapped.wrappedValue, 3)

        left.wrappedValue = 10
        right.wrappedValue = 20

        // Characterizes the current bug: the temporary `AnyStates` owner is not retained,
        // so source mutations do not propagate after the initial value is computed.
        XCTAssertEqual(mapped.wrappedValue, 3)
    }

    // MARK: - Test 14: Characterize current derived-state retention cycle [ST3]

    func testDerivedMapCharacterizesCurrentRetentionCycle() {
        let source = State(wrappedValue: 1)
        weak var weakMapped: State<Int>?

        do {
            let mapped = source.map { $0 * 2 }
            weakMapped = mapped
            XCTAssertNotNil(weakMapped)
        }

        // Characterizes the current bug: the source listener strongly retains the mapped state.
        XCTAssertNotNil(weakMapped)

        source.removeAllListeners()
        XCTAssertNil(weakMapped)
    }

    // MARK: - Test 15: Characterize ForEach subscriptions outliving owner [RT5]

    func testForEachCharacterizesSubscriptionsOutlivingOwner() {
        let items = State(wrappedValue: [1])
        var log: [String] = []

        var owner: ForEach<Int>? = ForEach(items) { _, _ in
        }

        weak var weakOwner = owner

        owner?.subscribeToChanges(
            {
                log.append("begin")
            },
            { _, _, _ in
                log.append("change")
            },
            {
                log.append("end")
            }
        )

        owner = nil
        XCTAssertNil(weakOwner)

        items.wrappedValue = [1, 2]

        // Characterizes the current bug: the source state retains subscriptions
        // after the `ForEach` owner has been released.
        XCTAssertEqual(
            log,
            [
                "begin",
                "change",
                "end",
            ]
        )

        items.removeAllListeners()
    }
}
