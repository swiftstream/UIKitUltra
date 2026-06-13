import Foundation
import XCTest
@testable import UIKitPlus

#if os(macOS)
import AppKit
#else
import UIKit
#endif

private final class ActivityIndicatorWeakStateListenerBox {
    weak var value: StateListener?

    init(_ value: StateListener) {
        self.value = value
    }
}

private func heldListenerIDs(of holder: TempStatesHolder) -> Set<UUID> {
    Set(
        holder
            .statesValues
            .heldListeners
            .values
            .map(\.id)
    )
}

private func heldListenerCount(of holder: TempStatesHolder) -> Int {
    holder.statesValues.heldListeners.count
}

private func newlyHeldListeners(
    of holder: TempStatesHolder,
    excluding baselineIDs: Set<UUID>
) -> [StateListener] {
    holder
        .statesValues
        .heldListeners
        .values
        .filter {
            !baselineIDs.contains($0.id)
        }
}

#if os(macOS)

private final class RecordingMacOSActivityIndicator: UActivityIndicator {
    private(set) var startAnimationCallCount = 0
    private(set) var stopAnimationCallCount = 0

    override func startAnimation(_ sender: Any?) {
        startAnimationCallCount += 1
    }

    override func stopAnimation(_ sender: Any?) {
        stopAnimationCallCount += 1
    }
}

final class MacOSActivityIndicatorBindingRoutingTests: XCTestCase {

    func testMacOSActivityIndicatorStartedBindingRoutesTokenAndRemainsLive() {
        let indicator = RecordingMacOSActivityIndicator(frame: .zero)
        let baselineCount = heldListenerCount(of: indicator.stateBindingHolder)
        let baselineIDs = heldListenerIDs(of: indicator.stateBindingHolder)
        let state = State<Bool>(wrappedValue: false)

        _ = indicator.started(state)

        let tokens = newlyHeldListeners(
            of: indicator.stateBindingHolder,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            heldListenerCount(of: indicator.stateBindingHolder),
            baselineCount + 1
        )
        XCTAssertEqual(tokens.count, 1)

        XCTAssertEqual(indicator.startAnimationCallCount, 0)
        XCTAssertEqual(indicator.stopAnimationCallCount, 1)

        state.wrappedValue = true

        XCTAssertEqual(indicator.startAnimationCallCount, 1)
        XCTAssertEqual(indicator.stopAnimationCallCount, 1)

        state.wrappedValue = false

        XCTAssertEqual(indicator.startAnimationCallCount, 1)
        XCTAssertEqual(indicator.stopAnimationCallCount, 2)
    }

    func testMacOSActivityIndicatorRepeatedStartedBindingRemainsAdditive() {
        let indicator = RecordingMacOSActivityIndicator(frame: .zero)
        let baselineIDs = heldListenerIDs(of: indicator.stateBindingHolder)
        let state = State<Bool>(wrappedValue: false)

        _ = indicator.started(state)
        _ = indicator.started(state)

        let tokens = newlyHeldListeners(
            of: indicator.stateBindingHolder,
            excluding: baselineIDs
        )

        XCTAssertEqual(tokens.count, 2)
        XCTAssertNotEqual(tokens[0].id, tokens[1].id)
    }

    func testMacOSActivityIndicatorTeardownCancelsOwnedStartedTokenAndPreservesUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let startedState = State<Bool>(wrappedValue: false)

        weak var weakIndicator: RecordingMacOSActivityIndicator?
        var weakBoxes: [ActivityIndicatorWeakStateListenerBox] = []

        autoreleasepool {
            var indicator: RecordingMacOSActivityIndicator? = RecordingMacOSActivityIndicator(frame: .zero)
            weakIndicator = indicator

            guard let liveIndicator = indicator else {
                XCTFail("Expected live indicator")
                return
            }

            let baselineIDs = heldListenerIDs(of: liveIndicator.stateBindingHolder)

            _ = liveIndicator.started(startedState)

            let tokens = newlyHeldListeners(
                of: liveIndicator.stateBindingHolder,
                excluding: baselineIDs
            )

            XCTAssertEqual(tokens.count, 1)

            weakBoxes = tokens.map {
                ActivityIndicatorWeakStateListenerBox($0)
            }

            indicator = nil
        }

        XCTAssertNil(weakIndicator)

        for (index, box) in weakBoxes.enumerated() {
            XCTAssertNil(
                box.value,
                "Token \(index) should have been deallocated"
            )
        }

        startedState.wrappedValue = true

        unrelatedState.wrappedValue = 1

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(
            unrelatedHolder.statesValues.heldListeners.count,
            1
        )
    }
}

#else

final class UIKitActivityIndicatorBindingRoutingTests: XCTestCase {

    func testUIKitActivityIndicatorUIColorBindingRoutesTokenAndRemainsLive() {
        let indicator = UActivityIndicator(frame: .zero)
        let baselineCount = heldListenerCount(of: indicator.stateBindingHolder)
        let baselineIDs = heldListenerIDs(of: indicator.stateBindingHolder)
        let state = State<UIColor>(wrappedValue: .red)

        _ = indicator.color(state)

        let tokens = newlyHeldListeners(
            of: indicator.stateBindingHolder,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            heldListenerCount(of: indicator.stateBindingHolder),
            baselineCount + 1
        )
        XCTAssertEqual(tokens.count, 1)
        XCTAssertTrue(indicator.color?.isEqual(UIColor.red) == true)

        state.wrappedValue = .blue

        XCTAssertTrue(indicator.color?.isEqual(UIColor.blue) == true)
    }

    func testUIKitActivityIndicatorIntColorBindingRoutesTokenAndRemainsLive() {
        let indicator = UActivityIndicator(frame: .zero)
        let baselineCount = heldListenerCount(of: indicator.stateBindingHolder)
        let baselineIDs = heldListenerIDs(of: indicator.stateBindingHolder)
        let redInt = 0xFF0000
        let blueInt = 0x0000FF
        let state = State<Int>(wrappedValue: redInt)

        _ = indicator.color(state)

        let tokens = newlyHeldListeners(
            of: indicator.stateBindingHolder,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            heldListenerCount(of: indicator.stateBindingHolder),
            baselineCount + 1
        )
        XCTAssertEqual(tokens.count, 1)
        XCTAssertTrue(indicator.color?.isEqual(redInt.color) == true)

        state.wrappedValue = blueInt

        XCTAssertTrue(indicator.color?.isEqual(blueInt.color) == true)
    }

    func testUIKitActivityIndicatorStartedBindingRoutesTokenAndRemainsLive() {
        let indicator = UActivityIndicator(frame: .zero)
        let baselineCount = heldListenerCount(of: indicator.stateBindingHolder)
        let baselineIDs = heldListenerIDs(of: indicator.stateBindingHolder)
        let state = State<Bool>(wrappedValue: false)

        _ = indicator.started(state)

        let tokens = newlyHeldListeners(
            of: indicator.stateBindingHolder,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            heldListenerCount(of: indicator.stateBindingHolder),
            baselineCount + 1
        )
        XCTAssertEqual(tokens.count, 1)
        XCTAssertFalse(indicator.isAnimating)

        state.wrappedValue = true

        XCTAssertTrue(indicator.isAnimating)

        state.wrappedValue = false

        XCTAssertFalse(indicator.isAnimating)
    }

    func testUIKitActivityIndicatorRepeatedStartedBindingRemainsAdditive() {
        let indicator = UActivityIndicator(frame: .zero)
        let baselineIDs = heldListenerIDs(of: indicator.stateBindingHolder)
        let state = State<Bool>(wrappedValue: false)

        _ = indicator.started(state)
        _ = indicator.started(state)

        let tokens = newlyHeldListeners(
            of: indicator.stateBindingHolder,
            excluding: baselineIDs
        )

        XCTAssertEqual(tokens.count, 2)
        XCTAssertNotEqual(tokens[0].id, tokens[1].id)
    }

    func testUIKitActivityIndicatorTeardownCancelsAllThreeOwnedTokensAndPreservesUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let colorState = State<UIColor>(wrappedValue: .red)
        let intColorState = State<Int>(wrappedValue: 0xFF0000)
        let startedState = State<Bool>(wrappedValue: false)

        weak var weakIndicator: UActivityIndicator?
        var weakBoxes: [ActivityIndicatorWeakStateListenerBox] = []

        autoreleasepool {
            var indicator: UActivityIndicator? = UActivityIndicator(frame: .zero)
            weakIndicator = indicator

            guard let liveIndicator = indicator else {
                XCTFail("Expected live indicator")
                return
            }

            let baselineIDs = heldListenerIDs(of: liveIndicator.stateBindingHolder)

            _ = liveIndicator.color(colorState)
            _ = liveIndicator.color(intColorState)
            _ = liveIndicator.started(startedState)

            let tokens = newlyHeldListeners(
                of: liveIndicator.stateBindingHolder,
                excluding: baselineIDs
            )

            XCTAssertEqual(tokens.count, 3)

            weakBoxes = tokens.map {
                ActivityIndicatorWeakStateListenerBox($0)
            }

            indicator = nil
        }

        XCTAssertNil(weakIndicator)

        for (index, box) in weakBoxes.enumerated() {
            XCTAssertNil(
                box.value,
                "Token \(index) should have been deallocated"
            )
        }

        colorState.wrappedValue = .blue
        intColorState.wrappedValue = 0x0000FF
        startedState.wrappedValue = true

        unrelatedState.wrappedValue = 1

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(
            unrelatedHolder.statesValues.heldListeners.count,
            1
        )
    }
}

#endif
