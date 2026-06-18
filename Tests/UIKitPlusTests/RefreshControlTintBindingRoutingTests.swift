import Foundation
import XCTest
@testable import UIKitPlus

#if !os(macOS)
#if !os(tvOS)
import UIKit

private func assertRefreshControlStateBindingOwnerConformance<
    T: _StateBindingOwner
>(
    _ type: T.Type
) {
    _ = type
}

private final class RefreshControlWeakStateListenerBox {
    weak var value: StateListener?

    init(_ value: StateListener) {
        self.value = value
    }
}

private func refreshHeldListenerIDs(
    of control: URefreshControl
) -> Set<UUID> {
    Set(
        control
            .stateBindingHolder
            .statesValues
            .heldListeners
            .values
            .map(\.id)
    )
}

private func refreshHeldListenerCount(
    of control: URefreshControl
) -> Int {
    control.stateBindingHolder.statesValues.heldListeners.count
}

private func newlyHeldRefreshListeners(
    of control: URefreshControl,
    excluding baselineIDs: Set<UUID>
) -> [StateListener] {
    control
        .stateBindingHolder
        .statesValues
        .heldListeners
        .values
        .filter {
            !baselineIDs.contains($0.id)
        }
}

@MainActor
final class RefreshControlTintBindingRoutingTests: XCTestCase {

    func testRefreshControlDeclaresExplicitStateBindingOwnerScaffolding() {
        assertRefreshControlStateBindingOwnerConformance(
            URefreshControl.self
        )

        let control = URefreshControl()

        XCTAssertEqual(
            refreshHeldListenerCount(of: control),
            0
        )
    }

    func testRefreshControlTintBindingRoutesTokenAndRemainsLive() {
        let control = URefreshControl()
        let state = State<UIColor>(wrappedValue: .red)
        let baselineCount = refreshHeldListenerCount(of: control)
        let baselineIDs = refreshHeldListenerIDs(of: control)

        _ = control.tint(state)

        let tokens = newlyHeldRefreshListeners(
            of: control,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            refreshHeldListenerCount(of: control),
            baselineCount + 1
        )
        XCTAssertEqual(tokens.count, 1)
        XCTAssertTrue(control.tintColor?.isEqual(UIColor.red) == true)
        XCTAssertTrue(control.tint.isEqual(UIColor.red))

        state.wrappedValue = .blue

        XCTAssertTrue(control.tintColor?.isEqual(UIColor.blue) == true)
        XCTAssertTrue(control.tint.isEqual(UIColor.blue))
    }

    func testRefreshControlRepeatedTintBindingRemainsAdditive() {
        let control = URefreshControl()
        let state = State<UIColor>(wrappedValue: .red)
        let baselineCount = refreshHeldListenerCount(of: control)
        let baselineIDs = refreshHeldListenerIDs(of: control)

        _ = control.tint(state)
        _ = control.tint(state)

        let tokens = newlyHeldRefreshListeners(
            of: control,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            refreshHeldListenerCount(of: control),
            baselineCount + 2
        )
        XCTAssertEqual(tokens.count, 2)
        XCTAssertNotEqual(tokens[0].id, tokens[1].id)

        state.wrappedValue = .green

        XCTAssertTrue(control.tintColor?.isEqual(UIColor.green) == true)
        XCTAssertTrue(control.tint.isEqual(UIColor.green))
    }

    func testRefreshControlTeardownCancelsOwnedTintTokenAndPreservesUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let tintState = State<UIColor>(wrappedValue: .red)

        weak var weakControl: URefreshControl?
        var weakBoxes: [RefreshControlWeakStateListenerBox] = []

        autoreleasepool {
            var control: URefreshControl? = URefreshControl()
            weakControl = control

            guard let liveControl = control else {
                XCTFail("Expected live refresh control")
                return
            }

            let baselineIDs = refreshHeldListenerIDs(of: liveControl)

            _ = liveControl.tint(tintState)

            let tokens = newlyHeldRefreshListeners(
                of: liveControl,
                excluding: baselineIDs
            )

            XCTAssertEqual(tokens.count, 1)

            weakBoxes = tokens.map {
                RefreshControlWeakStateListenerBox($0)
            }

            control = nil
        }

        XCTAssertNil(weakControl)

        for (index, box) in weakBoxes.enumerated() {
            XCTAssertNil(
                box.value,
                "Token \(index) should have been deallocated"
            )
        }

        tintState.wrappedValue = .yellow

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
