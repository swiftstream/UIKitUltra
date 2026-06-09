import XCTest
import Foundation
@testable import UIKitPlus

private final class TestStatesHolder: StatesHolder {
    let statesValues = StatesHolderValuesBox()
}

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

    // MARK: - Test 13: [AnyState].map propagation from every source [ST3][ST5]

    func testAnyStateArrayMapPropagatesFromEverySource() {
        let left = State(wrappedValue: 1)
        let right = State(wrappedValue: 2)

        let mapped = ([left, right] as [AnyState]).map {
            left.wrappedValue + right.wrappedValue
        }

        XCTAssertEqual(mapped.wrappedValue, 3)
        XCTAssertEqual(mapped.statesValues.heldListeners.count, 2)

        left.wrappedValue = 10
        XCTAssertEqual(mapped.wrappedValue, 12)

        right.wrappedValue = 20
        XCTAssertEqual(mapped.wrappedValue, 30)
    }

    // MARK: - Test 14: Derived map releases mapped state when it leaves scope [ST3][ST6][FC7]

    func testDerivedMapReleasesMappedStateWhenMappedStateLeavesScope() {
        let source = State(wrappedValue: 1)
        var evaluationCount = 0

        weak var weakMapped: State<Int>?

        do {
            let mapped = source.map { value in
                evaluationCount += 1
                return value * 2
            }

            weakMapped = mapped

            XCTAssertNotNil(weakMapped)
            XCTAssertEqual(mapped.statesValues.heldListeners.count, 1)
            XCTAssertEqual(mapped.wrappedValue, 2)
            XCTAssertEqual(evaluationCount, 1)

            source.wrappedValue = 2

            XCTAssertEqual(mapped.wrappedValue, 4)
            XCTAssertEqual(evaluationCount, 2)
        }

        XCTAssertNil(weakMapped)

        source.wrappedValue = 3

        XCTAssertEqual(evaluationCount, 2)
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

    // MARK: - SLICE 2A — Derived-state ownership repair

    // MARK: Test 16: Single-source no-argument lifecycle [ST3][ST6][FC7]

    func testSingleSourceNoArgumentMapReleasesMappedStateAndStopsUpdates() {
        let source = State(wrappedValue: 1)
        var evaluationCount = 0

        weak var weakMapped: State<Int>?

        do {
            let mapped = State<Int>(source as AnyState) {
                evaluationCount += 1
                return source.wrappedValue * 3
            }

            weakMapped = mapped

            XCTAssertEqual(mapped.statesValues.heldListeners.count, 1)
            XCTAssertEqual(mapped.wrappedValue, 3)
            XCTAssertEqual(evaluationCount, 1)

            source.wrappedValue = 2

            XCTAssertEqual(mapped.wrappedValue, 6)
            XCTAssertEqual(evaluationCount, 2)
        }

        XCTAssertNil(weakMapped)

        source.wrappedValue = 3

        XCTAssertEqual(evaluationCount, 2)
    }

    // MARK: Test 17: Typed two-source lifecycle [ST3][ST5][ST6][FC7]

    func testCombinedTypedMapReleasesMappedStateAndStopsUpdatesFromBothSources() {
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

    // MARK: Test 18: Two-source no-argument lifecycle [ST3][ST5][ST6][FC7]

    func testCombinedNoArgumentMapReleasesMappedStateAndStopsUpdatesFromBothSources() {
        let left = State(wrappedValue: 1)
        let right = State(wrappedValue: 2)
        var evaluationCount = 0

        weak var weakMapped: State<Int>?

        do {
            let mapped = State<Int>(left as AnyState, right as AnyState) {
                evaluationCount += 1
                return left.wrappedValue + right.wrappedValue
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

    // MARK: Test 19: Deprecated combined-result lifecycle [ST3][ST5][ST6][FC7]

    func testDeprecatedCombinedMapReleasesMappedStateAndStopsUpdatesFromBothSources() {
        let left = State(wrappedValue: 1)
        let right = State(wrappedValue: 2)
        var evaluationCount = 0

        weak var weakMapped: State<Int>?

        do {
            let mapped = State<Int>(left, right) {
                (values: CombinedDeprecatedResult<Int, Int>) in

                evaluationCount += 1
                return values.left + values.right
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

    // MARK: Test 20: [AnyState].map teardown [ST3][ST5][ST6][FC7]

    func testAnyStateArrayMapReleasesMappedStateAndStopsUpdatesFromAllSources() {
        let left = State(wrappedValue: 1)
        let right = State(wrappedValue: 2)
        var evaluationCount = 0

        weak var weakMapped: State<Int>?

        do {
            let mapped = ([left, right] as [AnyState]).map {
                evaluationCount += 1
                return left.wrappedValue + right.wrappedValue
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

    // MARK: Test 21: Typed one-source upstream retention [ST3][ST6][FC7]

    func testSingleSourceTypedMapDoesNotRetainUpstreamState() {
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

    // MARK: Test 22: Typed two-source upstream retention [ST3][ST5][ST6][FC7]

    func testCombinedTypedMapDoesNotRetainUpstreamStates() {
        var left: State<Int>? = State(wrappedValue: 1)
        var right: State<Int>? = State(wrappedValue: 2)

        weak var weakLeft = left
        weak var weakRight = right

        let mapped = left!.and(right!).map { left, right in
            left + right
        }

        XCTAssertEqual(mapped.wrappedValue, 3)
        XCTAssertEqual(mapped.statesValues.heldListeners.count, 2)

        left = nil
        right = nil

        XCTAssertNil(weakLeft)
        XCTAssertNil(weakRight)
        XCTAssertEqual(mapped.wrappedValue, 3)
    }

    // MARK: - GROUP A — Targeted cancellation

    func testListenerCancellationStopsFutureCallbacks() {
        let state = State(wrappedValue: 0)
        var count = 0

        let token = state.listen { _, _ in count += 1 }

        state.wrappedValue = 1
        XCTAssertEqual(count, 1)

        token.cancel()

        state.wrappedValue = 2
        XCTAssertEqual(count, 1)
    }

    func testListenerCancellationIsIdempotent() {
        let state = State(wrappedValue: 0)
        var count = 0

        let token = state.listen { _, _ in count += 1 }

        state.wrappedValue = 1
        XCTAssertEqual(count, 1)

        token.cancel()
        token.cancel()

        state.wrappedValue = 2
        XCTAssertEqual(count, 1)
    }

    func testRemoveListenerOnlyRemovesSelectedRegistration() {
        let state = State(wrappedValue: 0)
        var log: [String] = []

        let tokenA = state.listen { _, _ in log.append("A") }
        state.listen { _, _ in log.append("B") }

        state.removeListener(id: tokenA.id)

        state.wrappedValue = 1

        XCTAssertEqual(log, ["B"])
    }

    func testRemoveAllListenersCleansAllHolderBookkeeping() {
        let state = State(wrappedValue: 0)
        let holder = TestStatesHolder()

        let tokenA = state.listen { _, _ in }
        let tokenB = state.listen { _, _ in }

        tokenA.hold(in: holder)
        tokenB.hold(in: holder)

        XCTAssertEqual(holder.statesValues.heldListeners.count, 2)

        state.removeAllListeners()

        XCTAssertEqual(holder.statesValues.heldListeners.count, 0)

        state.wrappedValue = 1
    }

    func testDirectRemoveListenerCleansAllHolderBookkeeping() {
        let state = State(wrappedValue: 0)
        let holder = TestStatesHolder()

        let token = state.listen { _, _ in }
        token.hold(in: holder)

        XCTAssertEqual(holder.statesValues.heldListeners.count, 1)

        state.removeListener(id: token.id)

        XCTAssertEqual(holder.statesValues.heldListeners.count, 0)
    }

    func testIgnoredTokenRemainsActiveUntilExplicitSourceCleanup() {
        let state = State(wrappedValue: 0)
        var count = 0

        state.listen { _, _ in count += 1 }

        state.wrappedValue = 1
        XCTAssertEqual(count, 1)

        state.removeAllListeners()

        state.wrappedValue = 2
        XCTAssertEqual(count, 1)
    }

    // MARK: - GROUP B — Holder bookkeeping

    func testManualCancellationCleansHolderBookkeeping() {
        let state = State(wrappedValue: 0)
        let holder = TestStatesHolder()

        let token = state.listen { _, _ in }
        token.hold(in: holder)

        XCTAssertEqual(holder.statesValues.heldListeners.count, 1)

        token.cancel()

        XCTAssertEqual(holder.statesValues.heldListeners.count, 0)
    }

    func testRepeatedHoldInSameHolderDoesNotDuplicateBookkeeping() {
        let state = State(wrappedValue: 0)
        let holder = TestStatesHolder()

        let token = state.listen { _, _ in }
        token.hold(in: holder)
        token.hold(in: holder)

        XCTAssertEqual(holder.statesValues.heldListeners.count, 1)
    }

    func testMultipleHolderPolicy() {
        let state = State(wrappedValue: 0)
        let holderA = TestStatesHolder()
        let holderB = TestStatesHolder()
        var count = 0

        let token = state.listen { _, _ in count += 1 }
        token.hold(in: holderA)
        token.hold(in: holderB)

        XCTAssertEqual(holderA.statesValues.heldListeners.count, 1)
        XCTAssertEqual(holderB.statesValues.heldListeners.count, 1)

        token.cancel()

        XCTAssertEqual(holderA.statesValues.heldListeners.count, 0)
        XCTAssertEqual(holderB.statesValues.heldListeners.count, 0)

        state.wrappedValue = 1
        XCTAssertEqual(count, 0)
    }

    func testHolderReleaseIsIdempotent() {
        let state = State(wrappedValue: 0)
        let holder = TestStatesHolder()
        var count = 0

        state.listen { _, _ in count += 1 }.hold(in: holder)

        XCTAssertEqual(holder.statesValues.heldListeners.count, 1)

        holder.releaseStates()
        holder.releaseStates()

        XCTAssertEqual(holder.statesValues.heldListeners.count, 0)

        state.wrappedValue = 1
        XCTAssertEqual(count, 0)
    }

    func testReleaseStateOnlyCancelsMatchingSourceRegistrations() {
        let stateA = State(wrappedValue: 0)
        let stateB = State(wrappedValue: 0)
        let holder = TestStatesHolder()
        var log: [String] = []

        stateA.listen { _, _ in log.append("A") }.hold(in: holder)
        stateB.listen { _, _ in log.append("B") }.hold(in: holder)

        XCTAssertEqual(holder.statesValues.heldListeners.count, 2)

        holder.releaseState(stateA)

        XCTAssertEqual(holder.statesValues.heldListeners.count, 1)

        stateA.wrappedValue = 1
        stateB.wrappedValue = 1

        XCTAssertEqual(log, ["B"])
    }

    func testTempStatesHolderDeinitCancelsHeldToken() {
        let state = State(wrappedValue: 0)
        var count = 0

        do {
            let holder = TempStatesHolder()
            state.listen { _, _ in count += 1 }.hold(in: holder)
        }

        state.wrappedValue = 1
        XCTAssertEqual(count, 0)
    }

    // MARK: - GROUP C — Terminal invalidation

    func testInvalidateStatesIsIdempotent() {
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

    func testHoldIntoInvalidatedHolderCancelsIncomingToken() {
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

    func testReleaseStatesRemainsReusable() {
        let state = State(wrappedValue: 0)
        let holder = TestStatesHolder()
        var count = 0

        let tokenA = state.listen { _, _ in count += 1 }
        tokenA.hold(in: holder)

        holder.releaseStates()
        XCTAssertEqual(holder.statesValues.heldListeners.count, 0)

        state.wrappedValue = 1
        XCTAssertEqual(count, 0)

        let tokenB = state.listen { _, _ in count += 1 }
        tokenB.hold(in: holder)
        XCTAssertEqual(holder.statesValues.heldListeners.count, 1)

        state.wrappedValue = 2
        XCTAssertEqual(count, 1)

        holder.releaseStates()
        XCTAssertEqual(holder.statesValues.heldListeners.count, 0)

        state.wrappedValue = 3
        XCTAssertEqual(count, 1)
    }

    func testReleaseCallbackCanRegisterTokenForNextReusableRelease() {
        let state = State(wrappedValue: 0)
        let holder = TestStatesHolder()
        var count = 0

        holder.awaitRelease {
            state.listen { _, _ in count += 1 }.hold(in: holder)
        }

        holder.releaseStates()

        XCTAssertEqual(holder.statesValues.heldListeners.count, 1)

        state.wrappedValue = 1
        XCTAssertEqual(count, 1)

        holder.releaseStates()
        XCTAssertEqual(holder.statesValues.heldListeners.count, 0)

        state.wrappedValue = 2
        XCTAssertEqual(count, 1)
    }

    func testInvalidationCallbackCannotLeaveNewHeldTokenAlive() {
        let state = State(wrappedValue: 0)
        let holder = TestStatesHolder()
        var count = 0

        holder.awaitRelease {
            state.listen { _, _ in count += 1 }.hold(in: holder)
        }

        holder.invalidateStates()

        XCTAssertEqual(holder.statesValues.heldListeners.count, 0)

        state.wrappedValue = 1
        XCTAssertEqual(count, 0)
    }

    func testAwaitReleaseAfterInvalidationInvokesImmediately() {
        let holder = TestStatesHolder()
        var called = false

        holder.invalidateStates()

        holder.awaitRelease {
            called = true
        }

        XCTAssertTrue(called)
    }

    // MARK: - GROUP D — Source deinit

    func testSourceStateDeinitInvalidatesHeldToken() {
        let holder = TestStatesHolder()

        do {
            let state = State(wrappedValue: 0)
            state.listen { _, _ in }.hold(in: holder)
            XCTAssertEqual(holder.statesValues.heldListeners.count, 1)
        }

        XCTAssertEqual(holder.statesValues.heldListeners.count, 0)
    }

    func testCancelAfterSourceStateDeinitIsSafe() {
        let holder = TestStatesHolder()
        var token: StateListener?

        do {
            let state = State(wrappedValue: 0)
            token = state.listen { _, _ in }
            token?.hold(in: holder)
            XCTAssertEqual(holder.statesValues.heldListeners.count, 1)
        }

        XCTAssertEqual(holder.statesValues.heldListeners.count, 0)

        token?.cancel()
        token?.cancel()
    }

    // MARK: - GROUP E — Snapshot dispatch

    func testListenerCancelledDuringDispatchStillRunsInCurrentSnapshotOnly() {
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

    func testListenerAddedDuringDispatchRunsStartingWithNextMutation() {
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

    func testRemoveAllListenersDuringDispatchAffectsNextMutationOnly() {
        let state = State(wrappedValue: 0)
        var log: [String] = []

        state.listen { _, _ in
            log.append("A")
            state.removeAllListeners()
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

    func testNestedMutationRunsSynchronouslyWithDocumentedOrder() {
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

    // MARK: - GROUP F — Merge handles

    func testMergeWithSelfIsNoOp() {
        let state = State(wrappedValue: 0)
        var count = 0

        let handles = state.merge(with: state)

        XCTAssertTrue(handles.isEmpty)

        state.listen { _, _ in count += 1 }

        state.wrappedValue = 1

        XCTAssertEqual(count, 1)
    }

    func testMergeReturnsHandlesThatCancelSynchronization() {
        let internalState = State(wrappedValue: 1)
        let externalState = State(wrappedValue: 2)

        let handles = internalState.merge(with: externalState)

        XCTAssertEqual(handles.count, 2)

        handles.forEach { $0.cancel() }

        externalState.wrappedValue = 10
        XCTAssertEqual(internalState.wrappedValue, 2)

        internalState.wrappedValue = 20
        XCTAssertEqual(externalState.wrappedValue, 10)
    }

    // MARK: - GROUP G — CodableState forwarding

    func testCodableStateIdForwardsProjectedState() {
        let state = CodableState(wrappedValue: 1)

        XCTAssertEqual(
            state.id,
            state.projectedValue.id
        )
    }

    func testCodableStateListenerTokenCanCancel() {
        let state = CodableState(wrappedValue: 0)
        var count = 0

        let token = state.listen { _, _ in count += 1 }

        state.wrappedValue = 1
        XCTAssertEqual(count, 1)

        token.cancel()

        state.wrappedValue = 2
        XCTAssertEqual(count, 1)
    }

    func testCodableStateRemoveListenerForwardsToProjectedState() {
        let state = CodableState(wrappedValue: 0)
        var count = 0

        let token = state.listen { _, _ in count += 1 }

        state.removeListener(id: token.id)

        state.wrappedValue = 1
        XCTAssertEqual(count, 0)
    }

    func testCodableStateEncodingRemainsUnchanged() throws {
        let state = CodableState(wrappedValue: 42)

        let data = try JSONEncoder().encode(state)
        let json = String(data: data, encoding: .utf8)

        XCTAssertEqual(json, "42")

        let decoded = try JSONDecoder().decode(CodableState<Int>.self, from: data)
        XCTAssertEqual(decoded.wrappedValue, 42)
    }
}
