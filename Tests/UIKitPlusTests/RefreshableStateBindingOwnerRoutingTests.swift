import Foundation
import XCTest
@testable import UIKitPlus

private class RefreshableProbe: Refreshable {
    private(set) var refreshCallCount = 0

    func refresh() {
        refreshCallCount += 1
    }
}

private final class OwnedRefreshableProbe:
    RefreshableProbe,
    _StateBindingOwner
{
    let stateBindingHolder = TempStatesHolder()
}

private final class NonOwnedRefreshableProbe: RefreshableProbe {}

final class RefreshableStateBindingOwnerRoutingTests: XCTestCase {

    func testOwnedProbeRoutesOneStateReactionIntoAuthoritativeHolder() {
        let source = State<Int>(wrappedValue: 0)
        let probe = OwnedRefreshableProbe()

        probe.react(to: source)

        XCTAssertEqual(probe.stateBindingHolder.statesValues.heldListeners.count, 1)
        XCTAssertEqual(probe.refreshCallCount, 0)

        source.wrappedValue = 1

        XCTAssertEqual(probe.refreshCallCount, 1)
    }

    func testOwnedProbeRoutesTwoStateReactionIntoAuthoritativeHolder() {
        let a = State<Int>(wrappedValue: 0)
        let b = State<Int>(wrappedValue: 0)
        let probe = OwnedRefreshableProbe()

        probe.react(to: a, b)

        XCTAssertEqual(probe.stateBindingHolder.statesValues.heldListeners.count, 2)
        XCTAssertEqual(probe.refreshCallCount, 0)

        a.wrappedValue = 1
        b.wrappedValue = 1

        XCTAssertEqual(probe.refreshCallCount, 2)
    }

    func testOwnedProbeRoutesThreeStateReactionIntoAuthoritativeHolder() {
        let a = State<Int>(wrappedValue: 0)
        let b = State<Int>(wrappedValue: 0)
        let c = State<Int>(wrappedValue: 0)
        let probe = OwnedRefreshableProbe()

        probe.react(to: a, b, c)

        XCTAssertEqual(probe.stateBindingHolder.statesValues.heldListeners.count, 3)

        a.wrappedValue = 1
        b.wrappedValue = 1
        c.wrappedValue = 1

        XCTAssertEqual(probe.refreshCallCount, 3)
    }

    func testOwnedProbeRoutesFourStateReactionIntoAuthoritativeHolder() {
        let a = State<Int>(wrappedValue: 0)
        let b = State<Int>(wrappedValue: 0)
        let c = State<Int>(wrappedValue: 0)
        let d = State<Int>(wrappedValue: 0)
        let probe = OwnedRefreshableProbe()

        probe.react(to: a, b, c, d)

        XCTAssertEqual(probe.stateBindingHolder.statesValues.heldListeners.count, 4)

        a.wrappedValue = 1
        b.wrappedValue = 1
        c.wrappedValue = 1
        d.wrappedValue = 1

        XCTAssertEqual(probe.refreshCallCount, 4)
    }

    func testOwnedProbeRoutesFiveStateReactionIntoAuthoritativeHolder() {
        let a = State<Int>(wrappedValue: 0)
        let b = State<Int>(wrappedValue: 0)
        let c = State<Int>(wrappedValue: 0)
        let d = State<Int>(wrappedValue: 0)
        let e = State<Int>(wrappedValue: 0)
        let probe = OwnedRefreshableProbe()

        probe.react(to: a, b, c, d, e)

        XCTAssertEqual(probe.stateBindingHolder.statesValues.heldListeners.count, 5)

        a.wrappedValue = 1
        b.wrappedValue = 1
        c.wrappedValue = 1
        d.wrappedValue = 1
        e.wrappedValue = 1

        XCTAssertEqual(probe.refreshCallCount, 5)
    }

    func testOwnedProbeTwoStateReactionTeardownCancelsTokensAndRepairsStrongCapture() {
        let a = State<Int>(wrappedValue: 0)
        let b = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedACallCount = 0
        var unrelatedBCallCount = 0

        a.listen { _ in unrelatedACallCount += 1 }
            .hold(in: unrelatedHolder)

        b.listen { _ in unrelatedBCallCount += 1 }
            .hold(in: unrelatedHolder)

        weak var weakProbe: OwnedRefreshableProbe?
        weak var weakTokenA: StateListener?
        weak var weakTokenB: StateListener?

        autoreleasepool {
            var probe: OwnedRefreshableProbe? = .init()
            weakProbe = probe
            probe?.react(to: a, b)

            guard let liveProbe = probe else {
                XCTFail("Expected live probe")
                return
            }

            let tokens = Array(
                liveProbe.stateBindingHolder
                    .statesValues
                    .heldListeners
                    .values
            )

            guard tokens.count == 2 else {
                XCTFail("Expected exactly two owned Refreshable tokens")
                return
            }

            XCTAssertNotEqual(tokens[0].id, tokens[1].id)
            weakTokenA = tokens[0]
            weakTokenB = tokens[1]

            a.wrappedValue = 1
            b.wrappedValue = 1
            XCTAssertEqual(liveProbe.refreshCallCount, 2)

            probe = nil
        }

        XCTAssertNil(weakProbe)
        XCTAssertNil(weakTokenA)
        XCTAssertNil(weakTokenB)

        a.wrappedValue = 2
        b.wrappedValue = 2

        XCTAssertEqual(unrelatedACallCount, 2)
        XCTAssertEqual(unrelatedBCallCount, 2)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 2)
    }

    func testNonOwnedProbeTwoStateReactionDoesNotRetainReceiver() {
        let a = State<Int>(wrappedValue: 0)
        let b = State<Int>(wrappedValue: 0)

        weak var weakProbe: NonOwnedRefreshableProbe?

        autoreleasepool {
            var probe: NonOwnedRefreshableProbe? = .init()
            weakProbe = probe
            probe?.react(to: a, b)

            a.wrappedValue = 1
            b.wrappedValue = 1
            XCTAssertEqual(probe?.refreshCallCount, 2)

            probe = nil
        }

        XCTAssertNil(weakProbe)

        a.wrappedValue = 2
        b.wrappedValue = 2
    }

    func testNonOwnedProbePreservesFiveStateLiveUpdates() {
        let a = State<Int>(wrappedValue: 0)
        let b = State<Int>(wrappedValue: 0)
        let c = State<Int>(wrappedValue: 0)
        let d = State<Int>(wrappedValue: 0)
        let e = State<Int>(wrappedValue: 0)
        let probe = NonOwnedRefreshableProbe()

        XCTAssertFalse(probe is _StateBindingOwner)

        probe.react(to: a, b, c, d, e)

        a.wrappedValue = 1
        b.wrappedValue = 1
        c.wrappedValue = 1
        d.wrappedValue = 1
        e.wrappedValue = 1

        XCTAssertEqual(probe.refreshCallCount, 5)
    }

    func testOwnedProbeRepeatedReactionsRemainAdditiveUntilTeardown() {
        let sourceA = State<Int>(wrappedValue: 0)
        let sourceB = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedACallCount = 0
        var unrelatedBCallCount = 0

        sourceA.listen { _ in unrelatedACallCount += 1 }
            .hold(in: unrelatedHolder)

        sourceB.listen { _ in unrelatedBCallCount += 1 }
            .hold(in: unrelatedHolder)

        weak var weakProbe: OwnedRefreshableProbe?
        weak var weakTokenA: StateListener?
        weak var weakTokenB: StateListener?

        autoreleasepool {
            var probe: OwnedRefreshableProbe? = .init()
            weakProbe = probe

            probe?.react(to: sourceA)
            probe?.react(to: sourceB)

            guard let liveProbe = probe else {
                XCTFail("Expected live probe")
                return
            }

            let tokens = Array(
                liveProbe.stateBindingHolder
                    .statesValues
                    .heldListeners
                    .values
            )

            guard tokens.count == 2 else {
                XCTFail("Expected exactly two additive Refreshable tokens")
                return
            }

            XCTAssertNotEqual(tokens[0].id, tokens[1].id)
            weakTokenA = tokens[0]
            weakTokenB = tokens[1]

            sourceA.wrappedValue = 1
            sourceB.wrappedValue = 1
            XCTAssertEqual(liveProbe.refreshCallCount, 2)

            probe = nil
        }

        XCTAssertNil(weakProbe)
        XCTAssertNil(weakTokenA)
        XCTAssertNil(weakTokenB)

        sourceA.wrappedValue = 2
        sourceB.wrappedValue = 2

        XCTAssertEqual(unrelatedACallCount, 2)
        XCTAssertEqual(unrelatedBCallCount, 2)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 2)
    }

    func testDeclarativeUTextReactionUsesExistingPropertiesHolder() {
        let source = State<Int>(wrappedValue: 0)
        let text = UText("Initial")

        text.react(to: source)

        XCTAssertEqual(
            text._properties
                .stateBindingHolder
                .statesValues
                .heldListeners
                .count,
            1
        )

        source.wrappedValue = 1

        XCTAssertEqual(
            text._properties
                .stateBindingHolder
                .statesValues
                .heldListeners
                .count,
            1
        )
    }
}
