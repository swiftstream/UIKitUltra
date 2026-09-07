#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import XCTest
@testable import UIKitPlus

#if os(macOS)
import AppKit

@MainActor private func outboundHeldListenerIDs(
    of button: UButton
) -> Set<UUID> {
    Set(
        button
            .stateBindingHolder
            .statesValues
            .heldListeners
            .values
            .map(\.id)
    )
}

@MainActor private func newlyHeldOutboundListeners(
    of button: UButton,
    excluding baselineIDs: Set<UUID>
) -> [StateListener] {
    button
        .stateBindingHolder
        .statesValues
        .heldListeners
        .values
        .filter {
            !baselineIDs.contains($0.id)
        }
}

@MainActor
final class MacOSButtonOutboundHoverBridgeBindingTests: XCTestCase {

    func testOutboundHoverBridgeRoutesOneTokenWithoutInitialSynchronization() {
        let button = UButton("")
        let target = State<Bool>(wrappedValue: true)

        let baselineCount = button.stateBindingHolder.statesValues.heldListeners.count
        let baselineIDs = outboundHeldListenerIDs(of: button)

        XCTAssertEqual(baselineCount, 1)

        _ = button.hoveredByMouse(target)

        XCTAssertEqual(
            button.stateBindingHolder.statesValues.heldListeners.count,
            baselineCount + 1
        )
        XCTAssertEqual(
            newlyHeldOutboundListeners(
                of: button,
                excluding: baselineIDs
            ).count,
            1
        )
        XCTAssertTrue(target.wrappedValue)

        button.isHoveredByMouse.wrappedValue = false

        XCTAssertFalse(target.wrappedValue)
    }

    func testOutboundHoverBridgeUpdatesMultipleTargetsAdditively() {
        let button = UButton("")
        let targetA = State<Bool>(wrappedValue: false)
        let targetB = State<Bool>(wrappedValue: false)

        let baselineCount = button.stateBindingHolder.statesValues.heldListeners.count
        let baselineIDs = outboundHeldListenerIDs(of: button)

        XCTAssertEqual(baselineCount, 1)

        button
            .hoveredByMouse(targetA)
            .hoveredByMouse(targetB)

        let newTokens = newlyHeldOutboundListeners(
            of: button,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            button.stateBindingHolder.statesValues.heldListeners.count,
            baselineCount + 2
        )
        XCTAssertEqual(newTokens.count, 2)
        XCTAssertNotEqual(newTokens[0].id, newTokens[1].id)

        button.isHoveredByMouse.wrappedValue = true

        XCTAssertTrue(targetA.wrappedValue)
        XCTAssertTrue(targetB.wrappedValue)

        button.isHoveredByMouse.wrappedValue = false

        XCTAssertFalse(targetA.wrappedValue)
        XCTAssertFalse(targetB.wrappedValue)
    }

    func testRepeatedOutboundHoverBridgeToSameTargetRemainsAdditiveWithoutDeduplication() {
        let button = UButton("")
        let target = State<Bool>(wrappedValue: false)
        let observerHolder = TempStatesHolder()

        var targetWriteCount = 0

        target.listen { _ in
            targetWriteCount += 1
        }
        .hold(in: observerHolder)

        let baselineCount = button.stateBindingHolder.statesValues.heldListeners.count
        let baselineIDs = outboundHeldListenerIDs(of: button)

        XCTAssertEqual(baselineCount, 1)

        button
            .hoveredByMouse(target)
            .hoveredByMouse(target)

        let newTokens = newlyHeldOutboundListeners(
            of: button,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            button.stateBindingHolder.statesValues.heldListeners.count,
            baselineCount + 2
        )
        XCTAssertEqual(newTokens.count, 2)
        XCTAssertNotEqual(newTokens[0].id, newTokens[1].id)

        button.isHoveredByMouse.wrappedValue = true

        XCTAssertTrue(target.wrappedValue)
        XCTAssertEqual(targetWriteCount, 2)

        button.isHoveredByMouse.wrappedValue = false

        XCTAssertFalse(target.wrappedValue)
        XCTAssertEqual(targetWriteCount, 4)
        XCTAssertEqual(observerHolder.statesValues.heldListeners.count, 1)
    }

    func testOutboundHoverBridgeAllowsExternalTargetDeallocationBeforeButtonTeardown() {
        let button = UButton("")
        let baselineCount = button.stateBindingHolder.statesValues.heldListeners.count

        weak var weakTarget: State<Bool>?

        autoreleasepool {
            var target: State<Bool>? = State<Bool>(wrappedValue: false)
            weakTarget = target

            guard let target else {
                XCTFail("Expected live target")
                return
            }

            _ = button.hoveredByMouse(target)
        }

        XCTAssertNil(weakTarget)
        XCTAssertEqual(
            button.stateBindingHolder.statesValues.heldListeners.count,
            baselineCount + 1
        )

        button.isHoveredByMouse.wrappedValue = true
        button.isHoveredByMouse.wrappedValue = false
    }

    func testOutboundHoverBridgeTokensCancelOnButtonTeardownAndPreserveUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let target = State<Bool>(wrappedValue: false)

        var hoverState: UState<Bool>?
        weak var weakButton: UButton?
        weak var weakBridgeToken: StateListener?

        autoreleasepool {
            var button: UButton? = UButton("")

            guard let liveButton = button else {
                XCTFail("Expected live button")
                return
            }

            XCTAssertEqual(
                liveButton.stateBindingHolder.statesValues.heldListeners.count,
                1
            )

            let baselineIDs = outboundHeldListenerIDs(of: liveButton)
            hoverState = liveButton.isHoveredByMouse
            weakButton = liveButton

            _ = liveButton.hoveredByMouse(target)

            XCTAssertEqual(
                liveButton.stateBindingHolder.statesValues.heldListeners.count,
                2
            )

            let newTokens = newlyHeldOutboundListeners(
                of: liveButton,
                excluding: baselineIDs
            )

            guard newTokens.count == 1 else {
                XCTFail("Expected exactly one outbound hover bridge token")
                return
            }

            weakBridgeToken = newTokens[0]

            button = nil
        }

        XCTAssertNil(weakButton)
        XCTAssertNil(weakBridgeToken)

        hoverState?.wrappedValue = true
        hoverState?.wrappedValue = false

        XCTAssertFalse(target.wrappedValue)

        unrelatedState.wrappedValue = 1

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)
    }
}

#endif
#endif
