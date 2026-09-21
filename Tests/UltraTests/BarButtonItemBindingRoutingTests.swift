#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import XCTest
@testable import Ultra

#if !os(macOS)
import UIKit

private func assertBarButtonItemStateBindingOwnerConformance<
    T: _StateBindingOwner
>(
    _ type: T.Type
) {
    _ = type
}

private final class BarButtonItemWeakStateListenerBox {
    weak var value: StateListener?

    init(_ value: StateListener) {
        self.value = value
    }
}

private func barButtonItemHeldListenerIDs(
    of item: UBarButtonItem
) -> Set<UUID> {
    Set(
        item
            .stateBindingHolder
            .statesValues
            .heldListeners
            .values
            .map(\.id)
    )
}

private func barButtonItemHeldListenerCount(
    of item: UBarButtonItem
) -> Int {
    item.stateBindingHolder.statesValues.heldListeners.count
}

private func barButtonItemHeldListeners(
    of item: UBarButtonItem
) -> [StateListener] {
    Array(
        item
            .stateBindingHolder
            .statesValues
            .heldListeners
            .values
    )
}

private func newlyHeldBarButtonItemListeners(
    of item: UBarButtonItem,
    excluding baselineIDs: Set<UUID>
) -> [StateListener] {
    item
        .stateBindingHolder
        .statesValues
        .heldListeners
        .values
        .filter {
            !baselineIDs.contains($0.id)
        }
}

@MainActor
final class BarButtonItemBindingRoutingTests: XCTestCase {

    func testBarButtonItemDeclaresExplicitStateBindingOwnerScaffolding() {
        assertBarButtonItemStateBindingOwnerConformance(
            UBarButtonItem.self
        )

        let item = UBarButtonItem("Title")

        XCTAssertEqual(
            barButtonItemHeldListenerCount(of: item),
            0
        )
    }

    func testBarButtonItemImageStateInitializerRoutesTokenAndRemainsLive() {
        let initialImage = UIImage()
        let updatedImage = UIImage()
        let state = State<UIImage>(wrappedValue: initialImage)

        let item = UBarButtonItem(state)
        let tokens = barButtonItemHeldListeners(of: item)

        XCTAssertEqual(
            barButtonItemHeldListenerCount(of: item),
            1
        )
        XCTAssertEqual(tokens.count, 1)
        XCTAssertTrue(item.image === initialImage)

        state.wrappedValue = updatedImage

        XCTAssertTrue(item.image === updatedImage)
    }

    func testBarButtonItemTintBindingsRouteTokensAndRemainLive() {
        let item = UBarButtonItem("Title")
        let baselineIDs = barButtonItemHeldListenerIDs(of: item)
        let colorState = State<UIColor>(wrappedValue: .red)
        let intState = State<Int>(wrappedValue: 0xFF0000)

        _ = item.tint(colorState)
        _ = item.tint(intState)

        let tokens = newlyHeldBarButtonItemListeners(
            of: item,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            barButtonItemHeldListenerCount(of: item),
            2
        )
        XCTAssertEqual(tokens.count, 2)
        XCTAssertTrue(item.tintColor?.isEqual(UIColor.red) == true)

        colorState.wrappedValue = .blue

        XCTAssertTrue(item.tintColor?.isEqual(UIColor.blue) == true)

        intState.wrappedValue = 0x0000FF

        XCTAssertTrue(item.tintColor?.isEqual(0x0000FF.color) == true)
    }

    func testBarButtonItemRepeatedTintBindingRemainsAdditive() {
        let item = UBarButtonItem("Title")
        let baselineIDs = barButtonItemHeldListenerIDs(of: item)
        let state = State<UIColor>(wrappedValue: .red)

        _ = item.tint(state)
        _ = item.tint(state)

        let tokens = newlyHeldBarButtonItemListeners(
            of: item,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            barButtonItemHeldListenerCount(of: item),
            2
        )
        XCTAssertEqual(tokens.count, 2)
        XCTAssertNotEqual(tokens[0].id, tokens[1].id)

        state.wrappedValue = .green

        XCTAssertTrue(item.tintColor?.isEqual(UIColor.green) == true)
    }

    func testBarButtonItemTeardownCancelsAllThreeOwnedTokensAndPreservesUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let imageState = State<UIImage>(wrappedValue: UIImage())
        let colorState = State<UIColor>(wrappedValue: .red)
        let intState = State<Int>(wrappedValue: 0xFF0000)

        weak var weakItem: UBarButtonItem?
        var weakBoxes: [BarButtonItemWeakStateListenerBox] = []

        autoreleasepool {
            var item: UBarButtonItem? = UBarButtonItem(imageState)
            weakItem = item

            guard let liveItem = item else {
                XCTFail("Expected live bar button item")
                return
            }

            let constructorTokens = barButtonItemHeldListeners(
                of: liveItem
            )

            XCTAssertEqual(constructorTokens.count, 1)

            let tintBaselineIDs = barButtonItemHeldListenerIDs(
                of: liveItem
            )

            _ = liveItem.tint(colorState)
            _ = liveItem.tint(intState)

            let tintTokens = newlyHeldBarButtonItemListeners(
                of: liveItem,
                excluding: tintBaselineIDs
            )

            XCTAssertEqual(tintTokens.count, 2)

            let allTokens = constructorTokens + tintTokens

            XCTAssertEqual(allTokens.count, 3)
            XCTAssertEqual(
                barButtonItemHeldListenerCount(of: liveItem),
                3
            )

            weakBoxes = allTokens.map {
                BarButtonItemWeakStateListenerBox($0)
            }

            item = nil
        }

        XCTAssertNil(weakItem)

        for (index, box) in weakBoxes.enumerated() {
            XCTAssertNil(
                box.value,
                "Token \(index) should have been deallocated"
            )
        }

        imageState.wrappedValue = UIImage()
        colorState.wrappedValue = .yellow
        intState.wrappedValue = 0x0000FF

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
