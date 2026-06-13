import Foundation
import XCTest
@testable import UIKitPlus

#if !os(macOS)
#if !os(tvOS)
import UIKit

private final class ButtonBackgroundImageWeakStateListenerBox {
    weak var value: StateListener?

    init(_ value: StateListener) {
        self.value = value
    }
}

private func backgroundImageHeldListenerIDs(
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

private func backgroundImageHeldListenerCount(
    of button: UButton
) -> Int {
    button.stateBindingHolder.statesValues.heldListeners.count
}

private func newlyHeldBackgroundImageListeners(
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

final class ButtonBackgroundImageBindingRoutingTests: XCTestCase {

    func testButtonBackgroundImageBindingRoutesTokenAndAppliesInitialValueWithoutChangingForegroundImage() {
        let button = UButton(frame: .zero)
        let foregroundImage = UIImage()
        let initialBackgroundImage = UIImage()
        let state = State<UIImage>(
            wrappedValue: initialBackgroundImage
        )
        let baselineCount = backgroundImageHeldListenerCount(
            of: button
        )
        let baselineIDs = backgroundImageHeldListenerIDs(of: button)

        _ = button.image(foregroundImage)
        _ = button.backgroundImage(state)

        let tokens = newlyHeldBackgroundImageListeners(
            of: button,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            backgroundImageHeldListenerCount(of: button),
            baselineCount + 1
        )
        XCTAssertEqual(tokens.count, 1)
        XCTAssertTrue(
            button.backgroundImage(for: .normal)
                === initialBackgroundImage
        )
        XCTAssertTrue(
            button.image(for: .normal) === foregroundImage
        )
    }

    func testButtonBackgroundImageBindingUpdatesBackgroundWithoutOverwritingForegroundImage() {
        let button = UButton(frame: .zero)
        let foregroundImage = UIImage()
        let state = State<UIImage>(wrappedValue: UIImage())

        _ = button.image(foregroundImage)
        _ = button.backgroundImage(state)

        let updatedBackgroundImage = UIImage()
        state.wrappedValue = updatedBackgroundImage

        XCTAssertTrue(
            button.backgroundImage(for: .normal)
                === updatedBackgroundImage
        )
        XCTAssertTrue(
            button.image(for: .normal) === foregroundImage
        )
    }

    func testButtonRepeatedBackgroundImageBindingRemainsAdditive() {
        let button = UButton(frame: .zero)
        let foregroundImage = UIImage()
        let state = State<UIImage>(wrappedValue: UIImage())
        let baselineCount = backgroundImageHeldListenerCount(
            of: button
        )
        let baselineIDs = backgroundImageHeldListenerIDs(of: button)

        _ = button.image(foregroundImage)
        _ = button.backgroundImage(state)
        _ = button.backgroundImage(state)

        let tokens = newlyHeldBackgroundImageListeners(
            of: button,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            backgroundImageHeldListenerCount(of: button),
            baselineCount + 2
        )
        XCTAssertEqual(tokens.count, 2)
        XCTAssertNotEqual(tokens[0].id, tokens[1].id)

        let updatedBackgroundImage = UIImage()
        state.wrappedValue = updatedBackgroundImage

        XCTAssertTrue(
            button.backgroundImage(for: .normal)
                === updatedBackgroundImage
        )
        XCTAssertTrue(
            button.image(for: .normal) === foregroundImage
        )
    }

    func testButtonBackgroundImageBindingTokenCancelsOnTeardownAndPreservesUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let backgroundImageState = State<UIImage>(
            wrappedValue: UIImage()
        )

        weak var weakButton: UButton?
        var weakBoxes: [ButtonBackgroundImageWeakStateListenerBox] = []

        autoreleasepool {
            var button: UButton? = UButton(frame: .zero)
            weakButton = button

            guard let liveButton = button else {
                XCTFail("Expected live button")
                return
            }

            let baselineIDs = backgroundImageHeldListenerIDs(
                of: liveButton
            )

            _ = liveButton.backgroundImage(backgroundImageState)

            let tokens = newlyHeldBackgroundImageListeners(
                of: liveButton,
                excluding: baselineIDs
            )

            XCTAssertEqual(tokens.count, 1)

            weakBoxes = tokens.map {
                ButtonBackgroundImageWeakStateListenerBox($0)
            }

            button = nil
        }

        XCTAssertNil(weakButton)

        for (index, box) in weakBoxes.enumerated() {
            XCTAssertNil(
                box.value,
                "Token \(index) should have been deallocated"
            )
        }

        backgroundImageState.wrappedValue = UIImage()

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
