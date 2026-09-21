#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import XCTest
@testable import Ultra

#if os(macOS)
import AppKit

private final class SetupHoverSpy: UButton {
    private(set) static var trackingAreaUpdateCount = 0
    private(set) static var appliedTypes: [NSButton.ButtonType] = []

    static func resetTrackingAreaUpdateCount() {
        trackingAreaUpdateCount = 0
    }

    static func resetAppliedTypes() {
        appliedTypes = []
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        Self.trackingAreaUpdateCount += 1
    }

    override func setButtonType(_ type: NSButton.ButtonType) {
        super.setButtonType(type)
        Self.appliedTypes.append(type)
    }
}

@MainActor
private func heldListenerIDs(
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

@MainActor
private func newlyHeldListeners(
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
final class MacOSButtonSetupHoverBindingTests: XCTestCase {

    func testSetupRoutesExactlyOneHoverListenerIntoAuthoritativeHolder() {
        let button = SetupHoverSpy("")
        SetupHoverSpy.resetTrackingAreaUpdateCount()
        SetupHoverSpy.resetAppliedTypes()

        XCTAssertEqual(button.stateBindingHolder.statesValues.heldListeners.count, 1)
        XCTAssertEqual(heldListenerIDs(of: button).count, 1)
    }

    func testSetupHoverListenerInvokesHandlersForDistinctTransitionsOnly() {
        let button = SetupHoverSpy("")
        SetupHoverSpy.resetTrackingAreaUpdateCount()
        SetupHoverSpy.resetAppliedTypes()

        var hoverCallCount = 0
        var unhoverCallCount = 0

        button
            .onMouseHover {
                hoverCallCount += 1
            }
            .onMouseUnhover {
                unhoverCallCount += 1
            }

        button.isHoveredByMouse.wrappedValue = true
        button.isHoveredByMouse.wrappedValue = true
        button.isHoveredByMouse.wrappedValue = false
        button.isHoveredByMouse.wrappedValue = false

        XCTAssertEqual(hoverCallCount, 1)
        XCTAssertEqual(unhoverCallCount, 1)
    }

    func testRepeatedSetupDoesNotDuplicateHoverListenerAndStillRefreshesTrackingArea() {
        let button = SetupHoverSpy("")
        SetupHoverSpy.resetTrackingAreaUpdateCount()
        SetupHoverSpy.resetAppliedTypes()

        let baselineCount = button.stateBindingHolder.statesValues.heldListeners.count
        let baselineIDs = heldListenerIDs(of: button)

        button._setup()
        button._setup()

        XCTAssertEqual(button.stateBindingHolder.statesValues.heldListeners.count, baselineCount)
        XCTAssertEqual(heldListenerIDs(of: button), baselineIDs)
        XCTAssertEqual(SetupHoverSpy.trackingAreaUpdateCount, 2)
        XCTAssertFalse(button.translatesAutoresizingMaskIntoConstraints)
        XCTAssertTrue(button.target === button)
        XCTAssertEqual(button.bezelStyle, .regularSquare)
        XCTAssertFalse(button.isBordered)
        XCTAssertEqual(button.action, #selector(UButton.pushHandler))
    }

    func testSetupHoverListenerCancelsOnButtonTeardownAndPreservesUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        var hoverState: UState<Bool>?
        var hoverCallCount = 0
        var unhoverCallCount = 0
        weak var weakButton: SetupHoverSpy?
        weak var weakSetupToken: StateListener?

        autoreleasepool {
            var button: SetupHoverSpy? = SetupHoverSpy("")

            guard let liveButton = button else {
                XCTFail("Expected live button")
                return
            }

            XCTAssertEqual(liveButton.stateBindingHolder.statesValues.heldListeners.count, 1)

            hoverState = liveButton.isHoveredByMouse
            weakButton = liveButton

            let tokens = Array(
                liveButton
                    .stateBindingHolder
                    .statesValues
                    .heldListeners
                    .values
            )

            guard tokens.count == 1 else {
                XCTFail("Expected exactly one setup hover token")
                return
            }

            weakSetupToken = tokens[0]

            liveButton
                .onMouseHover {
                    hoverCallCount += 1
                }
                .onMouseUnhover {
                    unhoverCallCount += 1
                }

            button = nil
        }

        XCTAssertNil(weakButton)
        XCTAssertNil(weakSetupToken)

        hoverState?.wrappedValue = true
        hoverState?.wrappedValue = false

        XCTAssertEqual(hoverCallCount, 0)
        XCTAssertEqual(unhoverCallCount, 0)

        unrelatedState.wrappedValue = 1

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)
    }

    func testSetupHoverListenerCoexistsWithTypeBindingBaselineDeltas() {
        let button = SetupHoverSpy("")
        SetupHoverSpy.resetTrackingAreaUpdateCount()
        SetupHoverSpy.resetAppliedTypes()

        XCTAssertEqual(button.stateBindingHolder.statesValues.heldListeners.count, 1)

        let baselineCount = button.stateBindingHolder.statesValues.heldListeners.count
        let baselineIDs = heldListenerIDs(of: button)
        let source = State<NSButton.ButtonType>(wrappedValue: .pushOnPushOff)

        _ = button.type(source)

        XCTAssertEqual(button.stateBindingHolder.statesValues.heldListeners.count, baselineCount + 1)
        XCTAssertEqual(SetupHoverSpy.appliedTypes, [.pushOnPushOff])

        let newTokens = newlyHeldListeners(
            of: button,
            excluding: baselineIDs
        )

        XCTAssertEqual(newTokens.count, 1)
        XCTAssertTrue(baselineIDs.isSubset(of: heldListenerIDs(of: button)))

        SetupHoverSpy.resetAppliedTypes()

        source.wrappedValue = .toggle

        XCTAssertEqual(SetupHoverSpy.appliedTypes, [.toggle])
        XCTAssertEqual(button.stateBindingHolder.statesValues.heldListeners.count, baselineCount + 1)
    }
}

#endif
#endif
