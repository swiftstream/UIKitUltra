import Foundation
import XCTest
@testable import UIKitPlus

#if !os(macOS)
#if !os(tvOS)
import UIKit

private final class ButtonBindingSources {
    let title = State<String>(wrappedValue: "Initial")
    let colorUIColor = State<UIColor>(wrappedValue: .red)
    let colorInt = State<Int>(wrappedValue: 0x00FF00)
    let image = State<UIImage>(wrappedValue: UIImage())

    @discardableResult
    func bind(to button: UButton) -> UButton {
        button
            .title(title)
            .color(colorUIColor)
            .color(colorInt)
            .image(image)
    }
}

private final class WeakStateListenerBox {
    weak var value: StateListener?

    init(_ value: StateListener) {
        self.value = value
    }
}

private func heldListenerIDs(of button: UButton) -> Set<UUID> {
    Set(
        button
            .stateBindingHolder
            .statesValues
            .heldListeners
            .values
            .map(\.id)
    )
}

private func heldListenerCount(of button: UButton) -> Int {
    button.stateBindingHolder.statesValues.heldListeners.count
}

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
final class ButtonScalarBindingRoutingTests: XCTestCase {

    func testButtonFourNonBugBindingsRouteIntoOwnerHolderAndApplyInitialValues() {
        let button = UButton(frame: .zero)
        let baselineCount = heldListenerCount(of: button)
        let baselineIDs = heldListenerIDs(of: button)
        let sources = ButtonBindingSources()

        _ = sources.bind(to: button)

        let tokens = newlyHeldListeners(of: button, excluding: baselineIDs)

        XCTAssertEqual(heldListenerCount(of: button), baselineCount + 4)
        XCTAssertEqual(tokens.count, 4)

        XCTAssertEqual(
            button.attributedTitle(for: .normal)?.string,
            "Initial"
        )
        let initialColor = button.titleColor(for: .normal)
        XCTAssertTrue(
            initialColor?.isEqual(0x00FF00.color) == true
        )
        XCTAssertTrue(
            button.image(for: .normal) === sources.image.wrappedValue
        )
    }

    func testButtonTitleColorAndImageBindingsRemainLive() {
        let button = UButton(frame: .zero)
        let sources = ButtonBindingSources()
        _ = sources.bind(to: button)

        sources.title.wrappedValue = "Updated"
        XCTAssertEqual(
            button.attributedTitle(for: .normal)?.string,
            "Updated"
        )

        sources.colorUIColor.wrappedValue = .blue
        let updatedUIColor = button.titleColor(for: .normal)
        XCTAssertTrue(
            updatedUIColor?.isEqual(UIColor.blue) == true
        )

        sources.colorInt.wrappedValue = 0xFF00FF
        let updatedIntColor = button.titleColor(for: .normal)
        XCTAssertTrue(
            updatedIntColor?.isEqual(0xFF00FF.color) == true
        )

        let newImage = UIImage()
        sources.image.wrappedValue = newImage
        XCTAssertTrue(button.image(for: .normal) === newImage)
    }

    func testButtonRepeatedColorBindingRemainsAdditive() {
        let button = UButton(frame: .zero)
        let baselineCount = heldListenerCount(of: button)
        let baselineIDs = heldListenerIDs(of: button)
        let sources = ButtonBindingSources()

        _ = button.color(sources.colorUIColor)
        _ = button.color(sources.colorUIColor)

        let tokens = newlyHeldListeners(of: button, excluding: baselineIDs)

        XCTAssertEqual(heldListenerCount(of: button), baselineCount + 2)
        XCTAssertEqual(tokens.count, 2)
        XCTAssertNotEqual(tokens[0].id, tokens[1].id)

        sources.colorUIColor.wrappedValue = .green
        let repeatedColor = button.titleColor(for: .normal)
        XCTAssertTrue(
            repeatedColor?.isEqual(UIColor.green) == true
        )
    }

    func testButtonTeardownCancelsFourOwnedTokensAndPreservesUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let sources = ButtonBindingSources()

        weak var weakButton: UButton?
        var weakBoxes: [WeakStateListenerBox] = []

        autoreleasepool {
            var button: UButton? = UButton(frame: .zero)
            weakButton = button

            guard let liveButton = button else {
                XCTFail("Expected live button")
                return
            }

            let baselineIDs = heldListenerIDs(of: liveButton)

            _ = sources.bind(to: liveButton)

            let tokens = newlyHeldListeners(
                of: liveButton,
                excluding: baselineIDs
            )

            XCTAssertEqual(tokens.count, 4)

            weakBoxes = tokens.map { WeakStateListenerBox($0) }

            button = nil
        }

        XCTAssertNil(weakButton)

        for (index, box) in weakBoxes.enumerated() {
            XCTAssertNil(
                box.value,
                "Token \(index) should have been deallocated"
            )
        }

        sources.title.wrappedValue = "AfterTeardown"
        sources.colorUIColor.wrappedValue = .yellow
        sources.colorInt.wrappedValue = 0x0000FF
        sources.image.wrappedValue = UIImage()

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
