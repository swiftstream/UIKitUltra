import Foundation
import XCTest
@testable import UIKitPlus

#if !os(macOS)
import UIKit

private final class WeakStateListenerBox {
    weak var value: StateListener?

    init(_ value: StateListener) {
        self.value = value
    }
}

private func heldListeners(of image: UImage) -> [StateListener] {
    Array(
        image
            .stateBindingHolder
            .statesValues
            .heldListeners
            .values
    )
}

private func heldListenerCount(of image: UImage) -> Int {
    image.stateBindingHolder.statesValues.heldListeners.count
}

final class ImageDirectBindingRoutingTests: XCTestCase {

    func testUIImageStateInitializerRoutesTokenAndAppliesInitialValue() {
        let source = State<UIImage?>(wrappedValue: UIImage())
        let owner = UImage(source)

        XCTAssertEqual(heldListenerCount(of: owner), 1)
        XCTAssertEqual(heldListeners(of: owner).count, 1)
        XCTAssertNotNil(owner.image)
        XCTAssertEqual(owner.image, source.wrappedValue)

        let newImage = UIImage()
        source.wrappedValue = newImage

        XCTAssertNotNil(owner.image)
        XCTAssertEqual(owner.image, newImage)
    }

    func testUIImageNamedInitializerRoutesTokenAndHandlesUniqueMissingName() {
        let name = State<String>(wrappedValue: UUID().uuidString)

        weak var weakOwner: UImage?
        var weakBox: WeakStateListenerBox?

        autoreleasepool {
            let owner = UImage(named: name)
            weakOwner = owner

            XCTAssertEqual(heldListenerCount(of: owner), 1)

            let listeners = heldListeners(of: owner)

            XCTAssertEqual(listeners.count, 1)

            weakBox = WeakStateListenerBox(listeners[0])

            XCTAssertNil(owner.image)

            name.wrappedValue = UUID().uuidString

            XCTAssertNil(owner.image)
        }

        XCTAssertNil(weakOwner)
        XCTAssertNil(weakBox?.value)

        name.wrappedValue = UUID().uuidString
    }

    func testUIImageDirectInitializerTeardownCancelsOwnedTokenAndPreservesUnrelated() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let source = State<UIImage?>(wrappedValue: UIImage())

        weak var weakOwner: UImage?
        var weakBoxes: [WeakStateListenerBox] = []

        autoreleasepool {
            var owner: UImage? = UImage(source)
            weakOwner = owner

            guard let liveOwner = owner else {
                XCTFail("Expected live owner")
                return
            }

            let listeners = heldListeners(of: liveOwner)

            XCTAssertEqual(listeners.count, 1)

            weakBoxes = listeners.map {
                WeakStateListenerBox($0)
            }

            owner = nil
        }

        XCTAssertNil(weakOwner)

        for (index, box) in weakBoxes.enumerated() {
            XCTAssertNil(
                box.value,
                "Token \(index) should have been deallocated"
            )
        }

        source.wrappedValue = UIImage()

        unrelatedState.wrappedValue = 1

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(
            unrelatedHolder.statesValues.heldListeners.count,
            1
        )
    }
}

#endif

#if os(macOS)
import AppKit

private final class WeakStateListenerBox {
    weak var value: StateListener?

    init(_ value: StateListener) {
        self.value = value
    }
}

private func heldListeners(of image: UImage) -> [StateListener] {
    Array(
        image
            .stateBindingHolder
            .statesValues
            .heldListeners
            .values
    )
}

private func heldListenerCount(of image: UImage) -> Int {
    image.stateBindingHolder.statesValues.heldListeners.count
}

private func makeImage() -> NSImage {
    NSImage(size: NSSize(width: 1, height: 1))
}

final class ImageDirectBindingRoutingTests: XCTestCase {

    func testMacOSImageStateInitializerRoutesTokenAndAppliesInitialValue() {
        let fixture = makeImage()
        let source = State<NSImage?>(wrappedValue: fixture)
        let owner = UImage(source)

        XCTAssertEqual(heldListenerCount(of: owner), 1)
        XCTAssertEqual(heldListeners(of: owner).count, 1)
        XCTAssertNotNil(owner.image)
        XCTAssertEqual(owner.image, fixture)

        let newImage = makeImage()
        source.wrappedValue = newImage

        XCTAssertNotNil(owner.image)
        XCTAssertEqual(owner.image, newImage)
    }

    func testMacOSImageInitializerTeardownCancelsOwnedTokenAndPreservesUnrelated() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let source = State<NSImage?>(wrappedValue: nil)

        weak var weakOwner: UImage?
        var weakBoxes: [WeakStateListenerBox] = []

        autoreleasepool {
            var owner: UImage? = UImage(source)
            weakOwner = owner

            guard let liveOwner = owner else {
                XCTFail("Expected live owner")
                return
            }

            let listeners = heldListeners(of: liveOwner)

            XCTAssertEqual(listeners.count, 1)

            weakBoxes = listeners.map {
                WeakStateListenerBox($0)
            }

            owner = nil
        }

        XCTAssertNil(weakOwner)

        for (index, box) in weakBoxes.enumerated() {
            XCTAssertNil(
                box.value,
                "Token \(index) should have been deallocated"
            )
        }

        source.wrappedValue = makeImage()

        unrelatedState.wrappedValue = 1

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(
            unrelatedHolder.statesValues.heldListeners.count,
            1
        )
    }
}

#endif
