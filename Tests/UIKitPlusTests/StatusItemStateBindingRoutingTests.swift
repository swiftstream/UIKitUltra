import Foundation
import XCTest
@testable import UIKitPlus

#if os(macOS)
import AppKit

@MainActor
final class StatusItemStateBindingRoutingTests: XCTestCase {

    @MainActor
    func testStatusItemTitleBindingRoutesIntoOwnerHolder() {
        let item = StatusItem()
        defer { NSStatusBar.system.removeStatusItem(item.item) }

        let titleState = State<String>(wrappedValue: "Initial")
        let baselineCount = item.stateBindingHolder.statesValues.heldListeners.count

        _ = item.title(titleState)

        XCTAssertEqual(item.stateBindingHolder.statesValues.heldListeners.count, baselineCount + 1)
        XCTAssertEqual(item.item.button?.title, "Initial")

        titleState.wrappedValue = "Updated"
        XCTAssertEqual(item.item.button?.title, "Updated")
    }

    @MainActor
    func testStatusItemAllSevenBindingsRouteIntoHolderAndRemainLive() {
        let item = StatusItem()
        defer { NSStatusBar.system.removeStatusItem(item.item) }

        let titleState = State<String>(wrappedValue: "T")
        let attrTitleState = State<NSAttributedString>(wrappedValue: NSAttributedString(string: "A"))
        let img1 = NSImage(size: NSSize(width: 1, height: 1))
        let img2 = NSImage(size: NSSize(width: 2, height: 2))
        let imageState = State<NSImage?>(wrappedValue: img1)
        let altImageState = State<NSImage?>(wrappedValue: img2)
        let enabledState = State<Bool>(wrappedValue: true)
        let visibleState = State<Bool>(wrappedValue: true)
        let toolTipState = State<String>(wrappedValue: "Tip")

        let baselineCount = item.stateBindingHolder.statesValues.heldListeners.count

        _ = item
            .title(titleState)
            .attributedTitle(attrTitleState)
            .image(imageState)
            .alternateImage(altImageState)
            .enabled(enabledState)
            .visible(visibleState)
            .toolTip(toolTipState)

        XCTAssertEqual(item.stateBindingHolder.statesValues.heldListeners.count, baselineCount + 7)
        XCTAssertEqual(item.item.button?.attributedTitle.string, "A")
        XCTAssertIdentical(item.item.button?.image, img1)
        XCTAssertIdentical(item.item.button?.alternateImage, img2)
        XCTAssertEqual(item.item.button?.isEnabled, true)
        XCTAssertEqual(item.item.isVisible, true)
        XCTAssertEqual(item.item.button?.toolTip, "Tip")

        titleState.wrappedValue = "T2"
        XCTAssertEqual(item.item.button?.title, "T2")

        attrTitleState.wrappedValue = NSAttributedString(string: "A2")
        XCTAssertEqual(item.item.button?.attributedTitle.string, "A2")

        let img3 = NSImage(size: NSSize(width: 3, height: 3))
        imageState.wrappedValue = img3
        XCTAssertIdentical(item.item.button?.image, img3)

        let img4 = NSImage(size: NSSize(width: 4, height: 4))
        altImageState.wrappedValue = img4
        XCTAssertIdentical(item.item.button?.alternateImage, img4)

        enabledState.wrappedValue = false
        XCTAssertEqual(item.item.button?.isEnabled, false)

        visibleState.wrappedValue = false
        XCTAssertEqual(item.item.isVisible, false)

        toolTipState.wrappedValue = "Tip2"
        XCTAssertEqual(item.item.button?.toolTip, "Tip2")
    }

    @MainActor
    func testStatusItemTeardownCancelsAllSevenTokensAndPreservesUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0
        let unrelatedToken = unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        unrelatedToken.hold(in: unrelatedHolder)

        let titleState = State<String>(wrappedValue: "T")
        let attrTitleState = State<NSAttributedString>(wrappedValue: NSAttributedString(string: "A"))
        let imageState = State<NSImage?>(wrappedValue: nil)
        let altImageState = State<NSImage?>(wrappedValue: nil)
        let enabledState = State<Bool>(wrappedValue: true)
        let visibleState = State<Bool>(wrappedValue: true)
        let toolTipState = State<String>(wrappedValue: "Tip")

        weak var weakItem: StatusItem?
        weak var weakToken1: StateListener?
        weak var weakToken2: StateListener?
        weak var weakToken3: StateListener?
        weak var weakToken4: StateListener?
        weak var weakToken5: StateListener?
        weak var weakToken6: StateListener?
        weak var weakToken7: StateListener?

        autoreleasepool {
            let item = StatusItem()
            weakItem = item

            _ = item
                .title(titleState)
                .attributedTitle(attrTitleState)
                .image(imageState)
                .alternateImage(altImageState)
                .enabled(enabledState)
                .visible(visibleState)
                .toolTip(toolTipState)

            let tokens = Array(item.stateBindingHolder.statesValues.heldListeners.values)
            guard tokens.count == 7 else {
                XCTFail("Expected 7 tokens, got \(tokens.count)")
                return
            }

            weakToken1 = tokens[0]
            weakToken2 = tokens[1]
            weakToken3 = tokens[2]
            weakToken4 = tokens[3]
            weakToken5 = tokens[4]
            weakToken6 = tokens[5]
            weakToken7 = tokens[6]

            NSStatusBar.system.removeStatusItem(item.item)
        }

        XCTAssertNil(weakItem)
        XCTAssertNil(weakToken1)
        XCTAssertNil(weakToken2)
        XCTAssertNil(weakToken3)
        XCTAssertNil(weakToken4)
        XCTAssertNil(weakToken5)
        XCTAssertNil(weakToken6)
        XCTAssertNil(weakToken7)

        titleState.wrappedValue = "AfterTeardown"
        attrTitleState.wrappedValue = NSAttributedString(string: "AfterTeardown")
        imageState.wrappedValue = NSImage(size: NSSize(width: 1, height: 1))
        altImageState.wrappedValue = NSImage(size: NSSize(width: 2, height: 2))
        enabledState.wrappedValue = false
        visibleState.wrappedValue = false
        toolTipState.wrappedValue = "AfterTeardown"

        unrelatedState.wrappedValue = 1
        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)
    }

    @MainActor
    func testStatusItemRepeatedTitleBindingsRemainAdditiveUntilTeardown() {
        let stateA = State<String>(wrappedValue: "A")
        let stateB = State<String>(wrappedValue: "B")

        weak var weakItem: StatusItem?
        weak var weakTokenA: StateListener?
        weak var weakTokenB: StateListener?

        autoreleasepool {
            let item = StatusItem()
            weakItem = item

            _ = item.title(stateA).title(stateB)

            let tokens = Array(item.stateBindingHolder.statesValues.heldListeners.values)
            guard tokens.count == 2 else {
                XCTFail("Expected 2 tokens, got \(tokens.count)")
                return
            }

            weakTokenA = tokens[0]
            weakTokenB = tokens[1]

            XCTAssertNotEqual(weakTokenA?.id, weakTokenB?.id)
            XCTAssertEqual(item.item.button?.title, "B")

            stateA.wrappedValue = "A2"
            XCTAssertEqual(item.item.button?.title, "A2")

            stateB.wrappedValue = "B2"
            XCTAssertEqual(item.item.button?.title, "B2")

            NSStatusBar.system.removeStatusItem(item.item)
        }

        XCTAssertNil(weakItem)
        XCTAssertNil(weakTokenA)
        XCTAssertNil(weakTokenB)

        stateA.wrappedValue = "AfterA"
        stateB.wrappedValue = "AfterB"
    }

    @MainActor
    func testStatusItemScalarSettersRemainListenerFree() {
        let item = StatusItem()
        defer { NSStatusBar.system.removeStatusItem(item.item) }

        let image = NSImage(size: NSSize(width: 10, height: 10))
        let alternateImage = NSImage(size: NSSize(width: 20, height: 20))

        let baselineCount = item.stateBindingHolder.statesValues.heldListeners.count

        _ = item
            .title("ScalarTitle")
            .attributedTitle(NSAttributedString(string: "ScalarAttr"))
            .image(image)
            .alternateImage(alternateImage)
            .enabled(false)
            .visible(false)
            .toolTip("ScalarTip")

        XCTAssertEqual(item.stateBindingHolder.statesValues.heldListeners.count, baselineCount)
        XCTAssertEqual(item.item.button?.attributedTitle.string, "ScalarAttr")
        XCTAssertIdentical(item.item.button?.image, image)
        XCTAssertIdentical(item.item.button?.alternateImage, alternateImage)
        XCTAssertEqual(item.item.button?.isEnabled, false)
        XCTAssertEqual(item.item.isVisible, false)
        XCTAssertEqual(item.item.button?.toolTip, "ScalarTip")
    }
}
#endif
