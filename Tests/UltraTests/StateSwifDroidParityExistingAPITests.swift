#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import Ultra

private final class ParityTestHolder: StatesHolder {
    let statesValues = StatesHolderValuesBox()
}

final class StateSwifDroidParityExistingAPITests: XCTestCase {

    // MARK: - UState Type Alias Compatibility

    func testUStateAliasConstructsState() {
        let state: UState<Int> = UState(wrappedValue: 42)
        XCTAssertEqual(state.wrappedValue, 42)
    }

    func testUStateAliasProjectedValueIdentity() {
        let state: UState<Int> = UState(wrappedValue: 1)
        XCTAssertTrue(state.projectedValue === state)
    }

    func testUStateAliasListenAndCancel() {
        let state: UState<Int> = UState(wrappedValue: 0)
        var count = 0

        let token = state.listen { _, _ in count += 1 }

        state.wrappedValue = 1
        XCTAssertEqual(count, 1)

        token.cancel()

        state.wrappedValue = 2
        XCTAssertEqual(count, 1)
    }

    func testUStateAliasWithEquatableListenDistinct() {
        let state: UState<Int> = UState(wrappedValue: 0)
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

    func testUStateAliasMergeSyncsBidirectionally() {
        let a: UState<Int> = UState(wrappedValue: 1)
        let b: UState<Int> = UState(wrappedValue: 2)

        a.merge(with: b)

        XCTAssertEqual(a.wrappedValue, 2)

        a.wrappedValue = 10
        XCTAssertEqual(b.wrappedValue, 10)

        b.wrappedValue = 20
        XCTAssertEqual(a.wrappedValue, 20)
    }

    func testUStateAliasResetRestoresOriginal() {
        let state: UState<Int> = UState(wrappedValue: 5)
        state.wrappedValue = 10
        state.reset()
        XCTAssertEqual(state.wrappedValue, 5)
    }

    func testUStateAliasHoldInHolderReleasesOnReleaseStates() {
        let state: UState<Int> = UState(wrappedValue: 0)
        let holder = ParityTestHolder()
        var count = 0

        state.listen { _, _ in count += 1 }.hold(in: holder)

        state.wrappedValue = 1
        XCTAssertEqual(count, 1)

        holder.releaseStates()

        state.wrappedValue = 2
        XCTAssertEqual(count, 1)
    }

    // MARK: - removeListeners Canonical Behavior

    func testRemoveListenersRemovesAllThreePhases() {
        let state = State(wrappedValue: 0)
        var begin = 0, listener = 0, end = 0

        state.beginTrigger { begin += 1 }
        state.listen { _, _ in listener += 1 }
        state.endTrigger { end += 1 }

        state.wrappedValue = 1
        XCTAssertEqual(begin, 1)
        XCTAssertEqual(listener, 1)
        XCTAssertEqual(end, 1)

        state.removeListeners()

        state.wrappedValue = 2
        XCTAssertEqual(begin, 1)
        XCTAssertEqual(listener, 1)
        XCTAssertEqual(end, 1)
    }

    func testRemoveListenersCleansHolderBookkeeping() {
        let state = State(wrappedValue: 0)
        let holder = ParityTestHolder()

        let tokenA = state.listen { _, _ in }
        let tokenB = state.listen { _, _ in }
        tokenA.hold(in: holder)
        tokenB.hold(in: holder)

        XCTAssertEqual(holder.statesValues.heldListeners.count, 2)

        state.removeListeners()

        XCTAssertEqual(holder.statesValues.heldListeners.count, 0)
    }

    // MARK: - listenDistinct Through Stateable Generic

    func testListenDistinctWorksThroughStateableGeneric() {
        func makeDistinctListener<S: Stateable>(_ state: S) -> [S.Value] where S.Value: Equatable {
            var values: [S.Value] = []
            state.listenDistinct { newValue in
                values.append(newValue)
            }
            _ = state // retain
            return values
        }

        let state = State(wrappedValue: 0)
        _ = makeDistinctListener(state)

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

    // MARK: - releaseStates Standalone Behavior

    func testReleaseStatesCancelsAllHeldAndFiresCallbacks() {
        let holder = ParityTestHolder()
        let stateA = State(wrappedValue: 0)
        let stateB = State(wrappedValue: 0)
        var callbackFired = false
        var countA = 0, countB = 0

        stateA.listen { _, _ in countA += 1 }.hold(in: holder)
        stateB.listen { _, _ in countB += 1 }.hold(in: holder)

        holder.awaitRelease { callbackFired = true }

        stateA.wrappedValue = 1
        stateB.wrappedValue = 1
        XCTAssertEqual(countA, 1)
        XCTAssertEqual(countB, 1)

        holder.releaseStates()

        XCTAssertTrue(callbackFired)

        stateA.wrappedValue = 2
        stateB.wrappedValue = 2
        XCTAssertEqual(countA, 1)
        XCTAssertEqual(countB, 1)
    }

    func testReleaseStatesIsReusable() {
        let holder = ParityTestHolder()
        let state = State(wrappedValue: 0)
        var count = 0

        state.listen { _, _ in count += 1 }.hold(in: holder)

        state.wrappedValue = 1
        XCTAssertEqual(count, 1)

        holder.releaseStates()
        XCTAssertEqual(holder.statesValues.heldListeners.count, 0)

        state.listen { _, _ in count += 1 }.hold(in: holder)
        state.wrappedValue = 2
        XCTAssertEqual(count, 2)

        holder.releaseStates()
        XCTAssertEqual(holder.statesValues.heldListeners.count, 0)
    }

    // MARK: - awaitRelease On Non-Invalidated Holder

    func testAwaitReleaseOnFreshHolderDefersCallback() {
        let holder = ParityTestHolder()
        var fired = false

        holder.awaitRelease { fired = true }

        XCTAssertFalse(fired)

        holder.releaseStates()

        XCTAssertTrue(fired)
    }

    func testAwaitReleaseOnInvalidatedHolderFiresImmediately() {
        let holder = ParityTestHolder()
        var fired = false

        holder.invalidateStates()

        holder.awaitRelease { fired = true }

        XCTAssertTrue(fired)
    }

    // MARK: - releaseState Targeted Release

    func testReleaseStateCancelsOnlyMatchingSource() {
        let holder = ParityTestHolder()
        let stateA = State(wrappedValue: 0)
        let stateB = State(wrappedValue: 0)
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

    // MARK: - invalidateStates Terminal Behavior

    func testInvalidateStatesPreventsFutureHolds() {
        let holder = ParityTestHolder()

        holder.invalidateStates()

        let state = State(wrappedValue: 0)
        var count = 0

        state.listen { _, _ in count += 1 }.hold(in: holder)

        state.wrappedValue = 1
        XCTAssertEqual(count, 0)
        XCTAssertEqual(holder.statesValues.heldListeners.count, 0)
    }

    func testInvalidateStatesFiresCallbacks() {
        let holder = ParityTestHolder()
        var fired = false

        holder.awaitRelease { fired = true }

        holder.invalidateStates()

        XCTAssertTrue(fired)
    }

    // MARK: - Multi-Holder Release

    func testReleaseStateAcrossMultipleHolders() {
        let holderA = ParityTestHolder()
        let holderB = ParityTestHolder()
        let stateA = State(wrappedValue: 0)
        let stateB = State(wrappedValue: 0)
        var countA = 0, countB = 0

        stateA.listen { _, _ in countA += 1 }.hold(in: holderA)
        stateB.listen { _, _ in countB += 1 }.hold(in: holderB)

        holderA.releaseState(stateA)

        stateA.wrappedValue = 1
        stateB.wrappedValue = 1

        XCTAssertEqual(countA, 0)
        XCTAssertEqual(countB, 1)
    }
}
#endif
