import Foundation
import XCTest
@testable import UIKitPlus

private final class WeakBox<Value: AnyObject> {
    weak var value: Value?

    init(_ value: Value?) {
        self.value = value
    }
}

private final class ParagraphStyleDelegateSpy: ParagraphStyleDelegate {
    private(set) var updateCount = 0

    func onParagraphUpdate(_ p: ParagraphStyle) {
        updateCount += 1
    }
}

private func expectedParagraphStylePeerTokenCount() -> Int {
    #if os(macOS)
    return 40
    #else
    return 30
    #endif
}

@MainActor
final class ParagraphStyleOwnerAdoptionTests: XCTestCase {

    func testParagraphStyleExternalLineSpacingBindingIsOwnedAndCancelsOnTeardown() {
        let externalState = State<CGFloat>(wrappedValue: 10)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        externalState.listen { _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let delegate = ParagraphStyleDelegateSpy()

        weak var weakParagraphStyle: ParagraphStyle?
        var tokenBoxes: [WeakBox<StateListener>] = []

        autoreleasepool {
            var paragraphStyle: ParagraphStyle? = .init(delegate)
            weakParagraphStyle = paragraphStyle

            paragraphStyle?.lineSpacing(externalState)

            guard let liveParagraphStyle = paragraphStyle else {
                XCTFail("Expected live paragraph style")
                return
            }

            XCTAssertEqual(
                liveParagraphStyle
                    .stateBindingHolder
                    .statesValues
                    .heldListeners
                    .count,
                2
            )

            tokenBoxes = liveParagraphStyle
                .stateBindingHolder
                .statesValues
                .heldListeners
                .values
                .map(WeakBox.init)

            XCTAssertEqual(liveParagraphStyle.lineSpacing, 10)

            externalState.wrappedValue = 20

            XCTAssertEqual(liveParagraphStyle.lineSpacing, 20)

            liveParagraphStyle.lineSpacingState.wrappedValue = 25

            XCTAssertEqual(externalState.wrappedValue, 25)
            XCTAssertEqual(liveParagraphStyle.lineSpacing, 25)

            paragraphStyle = nil
        }

        XCTAssertNil(weakParagraphStyle)
        XCTAssertTrue(tokenBoxes.allSatisfy { $0.value == nil })

        externalState.wrappedValue = 30

        XCTAssertEqual(unrelatedCallCount, 3)
        XCTAssertEqual(
            unrelatedHolder.statesValues.heldListeners.count,
            1
        )
    }

    func testParagraphStyleRepeatedExternalBindingsRemainAdditiveUntilTeardown() {
        let sourceA = State<CGFloat>(wrappedValue: 0.1)
        let sourceB = State<CGFloat>(wrappedValue: 0.2)
        let delegate = ParagraphStyleDelegateSpy()

        weak var weakParagraphStyle: ParagraphStyle?
        var tokenBoxes: [WeakBox<StateListener>] = []

        autoreleasepool {
            var paragraphStyle: ParagraphStyle? = .init(delegate)
            weakParagraphStyle = paragraphStyle

            paragraphStyle?.lineSpacing(sourceA)
            paragraphStyle?.lineSpacing(sourceB)

            guard let liveParagraphStyle = paragraphStyle else {
                XCTFail("Expected live paragraph style")
                return
            }

            XCTAssertEqual(
                liveParagraphStyle
                    .stateBindingHolder
                    .statesValues
                    .heldListeners
                    .count,
                4
            )

            tokenBoxes = liveParagraphStyle
                .stateBindingHolder
                .statesValues
                .heldListeners
                .values
                .map(WeakBox.init)

            XCTAssertEqual(liveParagraphStyle.lineSpacing, 0.2)

            sourceA.wrappedValue = 0.5
            XCTAssertEqual(liveParagraphStyle.lineSpacing, 0.5)

            sourceB.wrappedValue = 0.6
            XCTAssertEqual(liveParagraphStyle.lineSpacing, 0.6)

            paragraphStyle = nil
        }

        XCTAssertNil(weakParagraphStyle)
        XCTAssertEqual(tokenBoxes.count, 4)
        XCTAssertTrue(tokenBoxes.allSatisfy { $0.value == nil })
    }

    func testParagraphStyleScalarSetterDoesNotCreateMergeHolderTokens() {
        let delegate = ParagraphStyleDelegateSpy()
        let paragraphStyle = ParagraphStyle(delegate)

        paragraphStyle.lineSpacing(4)
        paragraphStyle.paragraphSpacing(8)
        paragraphStyle.alignment(.center)

        XCTAssertEqual(
            paragraphStyle
                .stateBindingHolder
                .statesValues
                .heldListeners
                .count,
            0
        )

        // Scalar setters may install existing internal bridge listeners.
        // Slice 5D intentionally verifies only that no merge-holder token
        // is created for scalar-only API usage.
    }

    func testParagraphStylePeerMergeOwnsAllLinksAndRestoresMissingCrossPlatformCoverage() {
        let leftDelegate = ParagraphStyleDelegateSpy()
        let rightDelegate = ParagraphStyleDelegateSpy()

        let left = ParagraphStyle(leftDelegate)
        let right = ParagraphStyle(rightDelegate)

        // Install the existing internal scalar bridges before mutating
        // peer internal states. Slice 5D does not redesign these bridges.
        left.paragraphSpacing(0)
        left.firstLineHeadIndent(0)
        left.headIndent(0)
        left.tailIndent(0)

        left.mergeWithParagraphStyle(right)

        XCTAssertEqual(
            left
                .stateBindingHolder
                .statesValues
                .heldListeners
                .count,
            expectedParagraphStylePeerTokenCount()
        )

        right.paragraphSpacingState.wrappedValue = 99
        XCTAssertEqual(left.paragraphSpacingState.wrappedValue, 99)
        XCTAssertEqual(left.paragraphSpacing, 99)

        right.firstLineHeadIndentState.wrappedValue = 44
        XCTAssertEqual(left.firstLineHeadIndentState.wrappedValue, 44)
        XCTAssertEqual(left.firstLineHeadIndent, 44)

        right.headIndentState.wrappedValue = 55
        XCTAssertEqual(left.headIndentState.wrappedValue, 55)
        XCTAssertEqual(left.headIndent, 55)

        right.tailIndentState.wrappedValue = 66
        XCTAssertEqual(left.tailIndentState.wrappedValue, 66)
        XCTAssertEqual(left.tailIndent, 66)

        // Representative reverse-direction proof for the restored
        // bidirectional peer merge.
        left.tailIndentState.wrappedValue = 77
        XCTAssertEqual(right.tailIndentState.wrappedValue, 77)
    }

    func testParagraphStylePeerMergeTeardownCancelsOnlyOwnedTokens() {
        let leftDelegate = ParagraphStyleDelegateSpy()
        let rightDelegate = ParagraphStyleDelegateSpy()
        let right = ParagraphStyle(rightDelegate)

        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        right.lineSpacingState.listen { _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        weak var weakLeft: ParagraphStyle?
        var tokenBoxes: [WeakBox<StateListener>] = []

        autoreleasepool {
            var left: ParagraphStyle? = .init(leftDelegate)
            weakLeft = left

            left?.mergeWithParagraphStyle(right)

            guard let liveLeft = left else {
                XCTFail("Expected live left paragraph style")
                return
            }

            XCTAssertEqual(
                liveLeft
                    .stateBindingHolder
                    .statesValues
                    .heldListeners
                    .count,
                expectedParagraphStylePeerTokenCount()
            )

            tokenBoxes = liveLeft
                .stateBindingHolder
                .statesValues
                .heldListeners
                .values
                .map(WeakBox.init)

            left = nil
        }

        XCTAssertNil(weakLeft)
        XCTAssertEqual(
            tokenBoxes.count,
            expectedParagraphStylePeerTokenCount()
        )
        XCTAssertTrue(tokenBoxes.allSatisfy { $0.value == nil })

        right.lineSpacingState.wrappedValue = 999

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(
            unrelatedHolder.statesValues.heldListeners.count,
            1
        )
    }

    #if os(macOS)
    func testParagraphStylePeerMergeMacOSHolderCountIs40() {
        let leftDelegate = ParagraphStyleDelegateSpy()
        let rightDelegate = ParagraphStyleDelegateSpy()

        let left = ParagraphStyle(leftDelegate)
        let right = ParagraphStyle(rightDelegate)

        left.mergeWithParagraphStyle(right)

        XCTAssertEqual(
            left
                .stateBindingHolder
                .statesValues
                .heldListeners
                .count,
            40
        )
    }
    #endif
}
