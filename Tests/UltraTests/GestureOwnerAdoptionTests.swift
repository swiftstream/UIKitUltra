#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import XCTest
@testable import Ultra

private func assertSwipeDirection(
    _ recognizer: SwipeGestureRecognizer,
    equals expected: USwipeGestureRecognizer.Direction,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    #if os(macOS)
    switch (recognizer.direction, expected) {
    case (.right, .right),
         (.left, .left),
         (.up, .up),
         (.down, .down):
        break
    default:
        XCTFail("Swipe directions do not match", file: file, line: line)
    }
    #else
    XCTAssertEqual(recognizer.direction, expected, file: file, line: line)
    #endif
}

final class GestureOwnerAdoptionTests: XCTestCase {

    @MainActor
    func testCustomSwipeDirectionBindingIsTrackerOwnedAndCancelsOnRecognizerTeardown() {
        let source = State<USwipeGestureRecognizer.Direction>(wrappedValue: .right)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        source.listen { _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        weak var weakRecognizer: SwipeGestureRecognizer?
        weak var weakToken: StateListener?

        autoreleasepool {
            var recognizer: SwipeGestureRecognizer? = .init(direction: .right)
            weakRecognizer = recognizer

            recognizer?.direction(source)

            guard let liveRecognizer = recognizer else {
                XCTFail("Expected live recognizer")
                return
            }

            let tokens = Array(
                liveRecognizer._tracker
                    .statesValues
                    .heldListeners
                    .values
            )

            guard tokens.count == 1, let token = tokens.first else {
                XCTFail("Expected exactly one tracker-owned token")
                return
            }

            weakToken = token

            source.wrappedValue = .left
            assertSwipeDirection(liveRecognizer, equals: .left)

            recognizer = nil
        }

        XCTAssertNil(weakRecognizer)
        XCTAssertNil(weakToken)

        source.wrappedValue = .right

        XCTAssertEqual(unrelatedCallCount, 2)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)
    }

    @MainActor
    func testCustomEnabledBindingIsTrackerOwnedAndPreservesInitialAndLiveUpdates() {
        let source = State<Bool>(wrappedValue: false)

        weak var weakRecognizer: SwipeGestureRecognizer?
        weak var weakToken: StateListener?

        autoreleasepool {
            var recognizer: SwipeGestureRecognizer? = .init(direction: .right)
            weakRecognizer = recognizer

            recognizer?.enabled(source)

            guard let liveRecognizer = recognizer else {
                XCTFail("Expected live recognizer")
                return
            }

            XCTAssertFalse(liveRecognizer.isEnabled)

            let tokens = Array(
                liveRecognizer._tracker
                    .statesValues
                    .heldListeners
                    .values
            )

            guard tokens.count == 1, let token = tokens.first else {
                XCTFail("Expected exactly one tracker-owned token")
                return
            }

            weakToken = token

            source.wrappedValue = true
            XCTAssertTrue(liveRecognizer.isEnabled)

            recognizer = nil
        }

        XCTAssertNil(weakRecognizer)
        XCTAssertNil(weakToken)
    }

    @MainActor
    func testRepeatedCustomEnabledBindingsRemainAdditiveUntilRecognizerTeardown() {
        let sourceA = State<Bool>(wrappedValue: false)
        let sourceB = State<Bool>(wrappedValue: true)

        weak var weakRecognizer: SwipeGestureRecognizer?
        weak var weakTokenA: StateListener?
        weak var weakTokenB: StateListener?

        autoreleasepool {
            var recognizer: SwipeGestureRecognizer? = .init(direction: .right)
            weakRecognizer = recognizer

            recognizer?.enabled(sourceA)
            recognizer?.enabled(sourceB)

            guard let liveRecognizer = recognizer else {
                XCTFail("Expected live recognizer")
                return
            }

            XCTAssertTrue(liveRecognizer.isEnabled)

            let tokens = Array(
                liveRecognizer._tracker
                    .statesValues
                    .heldListeners
                    .values
            )

            guard tokens.count == 2 else {
                XCTFail("Expected exactly two additive tracker-owned tokens")
                return
            }

            weakTokenA = tokens[0]
            weakTokenB = tokens[1]

            sourceB.wrappedValue = false
            XCTAssertFalse(liveRecognizer.isEnabled)

            sourceA.wrappedValue = true
            XCTAssertTrue(liveRecognizer.isEnabled)

            recognizer = nil
        }

        XCTAssertNil(weakRecognizer)
        XCTAssertNil(weakTokenA)
        XCTAssertNil(weakTokenB)
    }

    @MainActor
    func testSystemEnabledBindingPreservesLiveUpdatesAndRemainsUnowned() {
        let source = State<Bool>(wrappedValue: false)
        let recognizer = UGestureRecognizer(target: nil, action: nil)

        XCTAssertNil(recognizer as? _GestureTrackable)

        recognizer.enabled(source)
        XCTAssertFalse(recognizer.isEnabled)

        source.wrappedValue = true
        XCTAssertTrue(recognizer.isEnabled)

        // Intentionally no owner-scoped teardown assertion:
        // arbitrary system recognizers remain explicit deferred unowned-listener debt.
    }

    #if os(iOS)
    @MainActor
    func testUIKitSystemGesturePropertyBindingsPreserveLiveUpdatesAndRemainUnowned() {
        let recognizer = UGestureRecognizer(target: nil, action: nil)

        XCTAssertNil(recognizer as? _GestureTrackable)

        let cancelsTouches = State<Bool>(wrappedValue: false)
        let delaysBegan = State<Bool>(wrappedValue: false)
        let delaysEnded = State<Bool>(wrappedValue: false)

        recognizer.cancelsTouchesInView(cancelsTouches)
        recognizer.delaysTouchesBegan(delaysBegan)
        recognizer.delaysTouchesEnded(delaysEnded)

        XCTAssertFalse(recognizer.cancelsTouchesInView)
        XCTAssertFalse(recognizer.delaysTouchesBegan)
        XCTAssertFalse(recognizer.delaysTouchesEnded)

        cancelsTouches.wrappedValue = true
        delaysBegan.wrappedValue = true
        delaysEnded.wrappedValue = true

        XCTAssertTrue(recognizer.cancelsTouchesInView)
        XCTAssertTrue(recognizer.delaysTouchesBegan)
        XCTAssertTrue(recognizer.delaysTouchesEnded)

        if #available(iOS 9.2, *) {
            let exclusiveTouch = State<Bool>(wrappedValue: false)

            recognizer.requiresExclusiveTouchType(exclusiveTouch)
            XCTAssertFalse(recognizer.requiresExclusiveTouchType)

            exclusiveTouch.wrappedValue = true
            XCTAssertTrue(recognizer.requiresExclusiveTouchType)
        }

        // Intentionally no owner-scoped teardown assertion:
        // arbitrary system recognizers remain explicit deferred unowned-listener debt.
    }
    #endif

    @MainActor
    func testGestureScalarSettersRemainListenerFree() {
        let customRecognizer = SwipeGestureRecognizer(direction: .right)

        customRecognizer.direction(.left)
        customRecognizer.enabled(false)

        #if !os(tvOS)
        customRecognizer.numberOfTouchesRequired(1)
        #endif

        XCTAssertEqual(
            customRecognizer._tracker
                .statesValues
                .heldListeners
                .count,
            0
        )

        let systemRecognizer = UGestureRecognizer(target: nil, action: nil)

        XCTAssertNil(systemRecognizer as? _GestureTrackable)

        systemRecognizer.enabled(false)
        XCTAssertFalse(systemRecognizer.isEnabled)
    }

    @MainActor
    func testGestureTrackerDeinitInvalidatesHeldListenersAndCleansSourceRegistry() {
        let source = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()

        var trackerOwnedCallCount = 0
        var unrelatedCallCount = 0

        source.listen { _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        weak var weakTracker: _GestureTracker?
        weak var weakToken: StateListener?

        autoreleasepool {
            var tracker: _GestureTracker? = .init()
            weakTracker = tracker

            guard let liveTracker = tracker else {
                XCTFail("Expected live tracker")
                return
            }

            let token = source.listen { _ in
                trackerOwnedCallCount += 1
            }
            .hold(in: liveTracker)

            weakToken = token

            XCTAssertEqual(
                liveTracker.statesValues.heldListeners.count,
                1
            )

            tracker = nil
        }

        XCTAssertNil(weakTracker)
        XCTAssertNil(weakToken)

        source.wrappedValue = 1

        XCTAssertEqual(trackerOwnedCallCount, 0)
        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)
    }
}
#endif
