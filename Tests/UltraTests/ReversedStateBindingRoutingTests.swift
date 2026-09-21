#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import XCTest
@testable import Ultra

#if !os(macOS)
import UIKit

private final class ReversedWeakStateListenerBox {
    weak var value: StateListener?

    init(_ value: StateListener) {
        self.value = value
    }
}

private func reversedHeldListeners(
    of holder: TempStatesHolder
) -> [StateListener] {
    Array(holder.statesValues.heldListeners.values)
}

private func reversedHeldListenerCount(of holder: TempStatesHolder) -> Int {
    holder.statesValues.heldListeners.count
}

@MainActor
final class ReversedStateBindingRoutingTests: XCTestCase {

    func testCollectionInitializerRoutesOneReversedTokenAndRemainsLive() {
        let collection = UCollection { }
        let tokens = reversedHeldListeners(
            of: collection.stateBindingHolder
        )

        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(
            reversedHeldListenerCount(of: collection.stateBindingHolder),
            1
        )

        let identity = CGAffineTransform(rotationAngle: 0)
        XCTAssertEqual(collection.collectionView.transform, identity)

        collection.reversed(true)

        let rotated = CGAffineTransform(
            rotationAngle: -(CGFloat)(Double.pi)
        )
        XCTAssertEqual(collection.collectionView.transform, rotated)

        collection.reversed(false)

        XCTAssertEqual(collection.collectionView.transform, identity)
    }

    func testListSingleViewInitializerRoutesOneReversedTokenAndRemainsLive() {
        let list = UList { }
        let tokens = reversedHeldListeners(
            of: list.stateBindingHolder
        )

        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(
            reversedHeldListenerCount(of: list.stateBindingHolder),
            1
        )

        let identity = CGAffineTransform(rotationAngle: 0)
        XCTAssertEqual(list.tableView.transform, identity)

        list.reversed(true)

        let rotated = CGAffineTransform(
            rotationAngle: -(CGFloat)(Double.pi)
        )
        XCTAssertEqual(list.tableView.transform, rotated)

        list.reversed(false)

        XCTAssertEqual(list.tableView.transform, identity)
    }

    func testListSelfAwareInitializerRoutesOneReversedTokenAndRemainsLive() {
        let list = UList { _ in }
        let tokens = reversedHeldListeners(
            of: list.stateBindingHolder
        )

        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(
            reversedHeldListenerCount(of: list.stateBindingHolder),
            1
        )

        let identity = CGAffineTransform(rotationAngle: 0)
        XCTAssertEqual(list.tableView.transform, identity)

        list.reversed(true)

        let rotated = CGAffineTransform(
            rotationAngle: -(CGFloat)(Double.pi)
        )
        XCTAssertEqual(list.tableView.transform, rotated)

        list.reversed(false)

        XCTAssertEqual(list.tableView.transform, identity)
    }

    func testCollectionHolderInvalidationCancelsReversedTokenWhileRealSourceRemainsAlive() {
        let collection = UCollection { }
        let retainedSource = collection.$reversed

        let weakBox = autoreleasepool {
            () -> ReversedWeakStateListenerBox in

            let tokens = reversedHeldListeners(
                of: collection.stateBindingHolder
            )

            XCTAssertEqual(tokens.count, 1)

            return ReversedWeakStateListenerBox(tokens[0])
        }

        XCTAssertNotNil(weakBox.value)
        XCTAssertEqual(
            reversedHeldListenerCount(of: collection.stateBindingHolder),
            1
        )

        retainedSource.wrappedValue = true

        let rotated = CGAffineTransform(
            rotationAngle: -(CGFloat)(Double.pi)
        )
        XCTAssertEqual(collection.collectionView.transform, rotated)

        collection.stateBindingHolder.invalidateStates()

        XCTAssertNil(weakBox.value)
        XCTAssertEqual(
            reversedHeldListenerCount(of: collection.stateBindingHolder),
            0
        )

        let identity = CGAffineTransform(rotationAngle: 0)
        collection.collectionView.transform = identity

        retainedSource.wrappedValue = false
        XCTAssertEqual(collection.collectionView.transform, identity)

        retainedSource.wrappedValue = true
        XCTAssertEqual(collection.collectionView.transform, identity)
    }

    func testListHoldersInvalidationCancelBothInitializerTokensAndPreserveUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let list = UList { }
        let selfAwareList = UList { _ in }

        let retainedSource = list.$reversed
        let retainedSelfAwareSource = selfAwareList.$reversed

        let weakBoxes = autoreleasepool {
            () -> (
                ReversedWeakStateListenerBox,
                ReversedWeakStateListenerBox
            ) in

            let listTokens = reversedHeldListeners(
                of: list.stateBindingHolder
            )
            let selfAwareTokens = reversedHeldListeners(
                of: selfAwareList.stateBindingHolder
            )

            XCTAssertEqual(listTokens.count, 1)
            XCTAssertEqual(selfAwareTokens.count, 1)

            return (
                ReversedWeakStateListenerBox(listTokens[0]),
                ReversedWeakStateListenerBox(selfAwareTokens[0])
            )
        }

        XCTAssertNotNil(weakBoxes.0.value)
        XCTAssertNotNil(weakBoxes.1.value)

        XCTAssertEqual(
            reversedHeldListenerCount(of: list.stateBindingHolder),
            1
        )
        XCTAssertEqual(
            reversedHeldListenerCount(of: selfAwareList.stateBindingHolder),
            1
        )

        retainedSource.wrappedValue = true
        retainedSelfAwareSource.wrappedValue = true

        let rotated = CGAffineTransform(
            rotationAngle: -(CGFloat)(Double.pi)
        )
        XCTAssertEqual(list.tableView.transform, rotated)
        XCTAssertEqual(selfAwareList.tableView.transform, rotated)

        list.stateBindingHolder.invalidateStates()
        selfAwareList.stateBindingHolder.invalidateStates()

        XCTAssertNil(weakBoxes.0.value)
        XCTAssertNil(weakBoxes.1.value)

        XCTAssertEqual(
            reversedHeldListenerCount(of: list.stateBindingHolder),
            0
        )
        XCTAssertEqual(
            reversedHeldListenerCount(of: selfAwareList.stateBindingHolder),
            0
        )

        let identity = CGAffineTransform(rotationAngle: 0)
        list.tableView.transform = identity
        selfAwareList.tableView.transform = identity

        retainedSource.wrappedValue = false
        retainedSelfAwareSource.wrappedValue = false

        XCTAssertEqual(list.tableView.transform, identity)
        XCTAssertEqual(selfAwareList.tableView.transform, identity)

        retainedSource.wrappedValue = true
        retainedSelfAwareSource.wrappedValue = true

        XCTAssertEqual(list.tableView.transform, identity)
        XCTAssertEqual(selfAwareList.tableView.transform, identity)

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
