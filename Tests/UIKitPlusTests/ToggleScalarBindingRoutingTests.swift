import Foundation
import XCTest
@testable import UIKitPlus

#if !os(macOS)
#if !os(tvOS)
import UIKit

private final class ToggleWeakStateListenerBox {
    weak var value: StateListener?

    init(_ value: StateListener) {
        self.value = value
    }
}

private func toggleHeldListenerIDs(of toggle: UToggle) -> Set<UUID> {
    Set(
        toggle
            .stateBindingHolder
            .statesValues
            .heldListeners
            .values
            .map(\.id)
    )
}

private func toggleHeldListenerCount(of toggle: UToggle) -> Int {
    toggle.stateBindingHolder.statesValues.heldListeners.count
}

private func newlyHeldToggleListeners(
    of toggle: UToggle,
    excluding baselineIDs: Set<UUID>
) -> [StateListener] {
    toggle
        .stateBindingHolder
        .statesValues
        .heldListeners
        .values
        .filter {
            !baselineIDs.contains($0.id)
        }
}

private final class ToggleBindingSources {
    let onTintUIColor = State<UIColor>(wrappedValue: .red)
    let onTintInt = State<Int>(wrappedValue: 0x00FF00)
    let thumbTintUIColor = State<UIColor>(wrappedValue: .blue)
    let thumbTintInt = State<Int>(wrappedValue: 0xFF0000)
    let onImage = State<UIImage?>(wrappedValue: UIImage())
    let offImage = State<UIImage?>(wrappedValue: UIImage())

    @discardableResult
    func bind(to toggle: UToggle) -> UToggle {
        toggle
            .onTint(onTintUIColor)
            .onTint(onTintInt)
            .thumbTint(thumbTintUIColor)
            .thumbTint(thumbTintInt)
            .onImage(onImage)
            .offImage(offImage)
    }
}

@MainActor
final class ToggleScalarBindingRoutingTests: XCTestCase {

    func testToggleStateInitializerRoutesTokenAndPreservesBidirectionalWitness() {
        let state = State<Bool>(wrappedValue: false)
        let toggle = UToggle(state)

        XCTAssertTrue(toggle.binding === state)
        XCTAssertEqual(toggleHeldListenerCount(of: toggle), 1)
        XCTAssertFalse(toggle.isOn)

        state.wrappedValue = true

        XCTAssertTrue(toggle.isOn)

        toggle.isOn = false

        let changedSelector = NSSelectorFromString("changed")

        XCTAssertTrue(toggle.responds(to: changedSelector))

        _ = toggle.perform(changedSelector)

        XCTAssertFalse(state.wrappedValue)
    }

    func testToggleSixFluentBindingsRouteIntoOwnerHolderAndRemainLive() {
        let toggle = UToggle(frame: .zero)
        let sources = ToggleBindingSources()
        let baselineCount = toggleHeldListenerCount(of: toggle)

        _ = sources.bind(to: toggle)

        XCTAssertEqual(
            toggleHeldListenerCount(of: toggle),
            baselineCount + 6
        )

        XCTAssertTrue(toggle.onTintColor?.isEqual(0x00FF00.color) == true)
        XCTAssertTrue(toggle.thumbTintColor?.isEqual(0xFF0000.color) == true)
        XCTAssertTrue(toggle.onImage?.isEqual(sources.onImage.wrappedValue) == true)
        XCTAssertTrue(toggle.offImage?.isEqual(sources.offImage.wrappedValue) == true)

        sources.onTintUIColor.wrappedValue = .yellow
        XCTAssertTrue(toggle.onTintColor?.isEqual(UIColor.yellow) == true)

        sources.onTintInt.wrappedValue = 0x123456
        XCTAssertTrue(toggle.onTintColor?.isEqual(0x123456.color) == true)

        sources.thumbTintUIColor.wrappedValue = .purple
        XCTAssertTrue(toggle.thumbTintColor?.isEqual(UIColor.purple) == true)

        sources.thumbTintInt.wrappedValue = 0x654321
        XCTAssertTrue(toggle.thumbTintColor?.isEqual(0x654321.color) == true)

        let newOnImage = UIImage()
        sources.onImage.wrappedValue = newOnImage
        XCTAssertTrue(toggle.onImage?.isEqual(newOnImage) == true)

        let newOffImage = UIImage()
        sources.offImage.wrappedValue = newOffImage
        XCTAssertTrue(toggle.offImage?.isEqual(newOffImage) == true)
    }

    func testToggleRepeatedFluentBindingRemainsAdditive() {
        let toggle = UToggle(frame: .zero)
        let state = State<UIColor>(wrappedValue: .red)
        let baselineCount = toggleHeldListenerCount(of: toggle)
        let baselineIDs = toggleHeldListenerIDs(of: toggle)

        _ = toggle.onTint(state)
        _ = toggle.onTint(state)

        let newTokens = newlyHeldToggleListeners(
            of: toggle,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            toggleHeldListenerCount(of: toggle),
            baselineCount + 2
        )
        XCTAssertEqual(newTokens.count, 2)
        XCTAssertNotEqual(newTokens[0].id, newTokens[1].id)

        state.wrappedValue = .green

        XCTAssertTrue(toggle.onTintColor?.isEqual(UIColor.green) == true)
    }

    func testToggleTeardownCancelsAllSevenOwnedTokensAndPreservesUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let isOnState = State<Bool>(wrappedValue: false)
        let sources = ToggleBindingSources()

        weak var weakToggle: UToggle?
        var weakBoxes: [ToggleWeakStateListenerBox] = []

        autoreleasepool {
            var toggle: UToggle? = UToggle(isOnState)
            weakToggle = toggle

            guard let liveToggle = toggle else {
                XCTFail("Expected live toggle")
                return
            }

            XCTAssertEqual(toggleHeldListenerCount(of: liveToggle), 1)

            _ = sources.bind(to: liveToggle)

            let tokens = Array(
                liveToggle
                    .stateBindingHolder
                    .statesValues
                    .heldListeners
                    .values
            )

            XCTAssertEqual(tokens.count, 7)

            weakBoxes = tokens.map {
                ToggleWeakStateListenerBox($0)
            }

            toggle = nil
        }

        XCTAssertNil(weakToggle)

        for (index, box) in weakBoxes.enumerated() {
            XCTAssertNil(
                box.value,
                "Token \(index) should have been deallocated"
            )
        }

        isOnState.wrappedValue = true
        sources.onTintUIColor.wrappedValue = .yellow
        sources.onTintInt.wrappedValue = 0x123456
        sources.thumbTintUIColor.wrappedValue = .purple
        sources.thumbTintInt.wrappedValue = 0x654321
        sources.onImage.wrappedValue = UIImage()
        sources.offImage.wrappedValue = UIImage()

        unrelatedState.wrappedValue = 1

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(
            unrelatedHolder.statesValues.heldListeners.count,
            1
        )
    }
}

#endif
#endif
