#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import XCTest
@testable import UIKitPlus

#if os(macOS)
import AppKit

private final class ButtonTypeSpy: UButton {
    private(set) static var appliedTypes: [NSButton.ButtonType] = []

    static func resetAppliedTypes() {
        appliedTypes = []
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
final class MacOSButtonTypeBindingTests: XCTestCase {

    func testButtonTypeSpyFixtureCanObserveSetButtonType() {
        let button = ButtonTypeSpy("")
        ButtonTypeSpy.resetAppliedTypes()

        button.setButtonType(.toggle)

        XCTAssertEqual(ButtonTypeSpy.appliedTypes, [.toggle])
    }

    func testButtonTypeBindingRoutesTokenAndAppliesInitialValue() {
        let button = ButtonTypeSpy("")
        ButtonTypeSpy.resetAppliedTypes()

        let source = State<NSButton.ButtonType>(wrappedValue: .pushOnPushOff)
        let baselineCount = button.stateBindingHolder.statesValues.heldListeners.count
        let baselineIDs = heldListenerIDs(of: button)

        _ = button.type(source)

        XCTAssertEqual(button.stateBindingHolder.statesValues.heldListeners.count, baselineCount + 1)
        XCTAssertTrue(button._buttonTypeState === source)
        XCTAssertEqual(ButtonTypeSpy.appliedTypes, [.pushOnPushOff])

        let newTokens = newlyHeldListeners(
            of: button,
            excluding: baselineIDs
        )

        XCTAssertEqual(newTokens.count, 1)
    }

    func testButtonTypeSourceMutationAppliesLiveValue() {
        let button = ButtonTypeSpy("")
        ButtonTypeSpy.resetAppliedTypes()

        let source = State<NSButton.ButtonType>(wrappedValue: .pushOnPushOff)
        _ = button.type(source)
        let countAfterBinding = button.stateBindingHolder.statesValues.heldListeners.count
        ButtonTypeSpy.resetAppliedTypes()

        source.wrappedValue = .toggle

        XCTAssertEqual(ButtonTypeSpy.appliedTypes, [.toggle])
        XCTAssertEqual(button.stateBindingHolder.statesValues.heldListeners.count, countAfterBinding)
        XCTAssertTrue(button._buttonTypeState === source)
    }

    func testButtonTypeTeardownCancelsOwnedTokenAndPreservesUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0
        let unrelatedToken = unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        unrelatedToken.hold(in: unrelatedHolder)

        let source = State<NSButton.ButtonType>(wrappedValue: .pushOnPushOff)

        weak var weakButton: ButtonTypeSpy?
        weak var weakOwnedToken: StateListener?

        autoreleasepool {
            let button = ButtonTypeSpy("")
            weakButton = button

            let baselineCount = button.stateBindingHolder.statesValues.heldListeners.count
            let baselineIDs = heldListenerIDs(of: button)

            _ = button.type(source)

            XCTAssertEqual(button.stateBindingHolder.statesValues.heldListeners.count, baselineCount + 1)

            let newTokens = newlyHeldListeners(
                of: button,
                excluding: baselineIDs
            )

            guard newTokens.count == 1 else {
                XCTFail("Expected exactly one newly held type-binding token")
                return
            }

            weakOwnedToken = newTokens[0]
        }

        XCTAssertNil(weakButton)
        XCTAssertNil(weakOwnedToken)

        ButtonTypeSpy.resetAppliedTypes()

        source.wrappedValue = .onOff

        XCTAssertEqual(ButtonTypeSpy.appliedTypes, [])

        XCTAssertEqual(unrelatedCallCount, 0)

        unrelatedState.wrappedValue = 42

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)
    }

    func testButtonTypeRepeatedBindingsRemainAdditiveWithLatestWitness() {
        let stateA = State<NSButton.ButtonType>(wrappedValue: .pushOnPushOff)
        let stateB = State<NSButton.ButtonType>(wrappedValue: .onOff)

        weak var weakButton: ButtonTypeSpy?
        weak var weakTokenA: StateListener?
        weak var weakTokenB: StateListener?

        autoreleasepool {
            var button: ButtonTypeSpy? = ButtonTypeSpy("")

            weakButton = button

            guard let liveButton = button else {
                XCTFail("Expected live button")
                return
            }

            let baselineCount = liveButton.stateBindingHolder.statesValues.heldListeners.count
            let baselineIDs = heldListenerIDs(of: liveButton)

            _ = liveButton.type(stateA)
            _ = liveButton.type(stateB)

            XCTAssertEqual(
                liveButton.stateBindingHolder.statesValues.heldListeners.count,
                baselineCount + 2
            )

            XCTAssertTrue(liveButton._buttonTypeState === stateB)

            let newTokens = newlyHeldListeners(
                of: liveButton,
                excluding: baselineIDs
            )

            guard newTokens.count == 2 else {
                XCTFail("Expected exactly two additive type-binding tokens")
                return
            }

            XCTAssertNotEqual(newTokens[0].id, newTokens[1].id)

            weakTokenA = newTokens[0]
            weakTokenB = newTokens[1]

            ButtonTypeSpy.resetAppliedTypes()

            stateA.wrappedValue = .toggle

            XCTAssertEqual(ButtonTypeSpy.appliedTypes, [.toggle])

            ButtonTypeSpy.resetAppliedTypes()

            stateB.wrappedValue = .momentaryPushIn

            XCTAssertEqual(ButtonTypeSpy.appliedTypes, [.momentaryPushIn])

            XCTAssertTrue(liveButton._buttonTypeState === stateB)

            button = nil
        }

        XCTAssertNil(weakButton)
        XCTAssertNil(weakTokenA)
        XCTAssertNil(weakTokenB)

        ButtonTypeSpy.resetAppliedTypes()

        stateA.wrappedValue = .onOff
        stateB.wrappedValue = .toggle

        XCTAssertEqual(ButtonTypeSpy.appliedTypes, [])
    }

    func testButtonTypeScalarSetterRemainsListenerFreeAndDocumentsDoubleApply() {
        let button = ButtonTypeSpy("")
        ButtonTypeSpy.resetAppliedTypes()

        let source = State<NSButton.ButtonType>(wrappedValue: .pushOnPushOff)
        _ = button.type(source)
        let countAfterBinding = button.stateBindingHolder.statesValues.heldListeners.count
        ButtonTypeSpy.resetAppliedTypes()

        _ = button.type(.toggle)

        XCTAssertEqual(button.stateBindingHolder.statesValues.heldListeners.count, countAfterBinding)
        XCTAssertEqual(button._buttonTypeState.wrappedValue, .toggle)
        XCTAssertEqual(ButtonTypeSpy.appliedTypes, [.toggle, .toggle])
    }
}

#endif
#endif
