#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import XCTest
@testable import Ultra

private func assertAlpha(
    _ view: UView,
    equals expected: CGFloat,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    #if os(macOS)
    XCTAssertEqual(view.alphaValue, expected, accuracy: 0.0001, file: file, line: line)
    #else
    XCTAssertEqual(view.alpha, expected, accuracy: 0.0001, file: file, line: line)
    #endif
}

private final class WeakBox<Value: AnyObject> {
    weak var value: Value?

    init(_ value: Value?) {
        self.value = value
    }
}

@MainActor
final class OwnerAdoptionTests: XCTestCase {

    @MainActor
    func testDeclarativeViewStateBindingHolderCancelsOnlyOwnedToken() {
        let source = State<Bool>(wrappedValue: false)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        source.listen { _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        weak var weakView: UView?
        weak var weakOwnedToken: StateListener?

        autoreleasepool {
            var view: UView? = UView()
            weakView = view

            view?.hidden(source)

            guard let liveView = view else {
                XCTFail("Expected live view")
                return
            }

            let tokens = Array(
                liveView._properties
                    .stateBindingHolder
                    .statesValues
                    .heldListeners
                    .values
            )

            guard tokens.count == 1, let token = tokens.first else {
                XCTFail("Expected exactly one view-owned token")
                return
            }

            weakOwnedToken = token
            view = nil
        }

        XCTAssertNil(weakView)
        XCTAssertNil(weakOwnedToken)

        source.wrappedValue = true

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)
    }

    @MainActor
    func testDeclarativeViewRepeatedStateBindingRemainsAdditiveUntilTeardown() {
        let sourceA = State<CGFloat>(wrappedValue: 0.1)
        let sourceB = State<CGFloat>(wrappedValue: 0.2)

        let unrelatedHolder = TempStatesHolder()
        var unrelatedACallCount = 0
        var unrelatedBCallCount = 0

        sourceA.listen { _ in
            unrelatedACallCount += 1
        }
        .hold(in: unrelatedHolder)

        sourceB.listen { _ in
            unrelatedBCallCount += 1
        }
        .hold(in: unrelatedHolder)

        weak var weakView: UView?
        weak var weakTokenA: StateListener?
        weak var weakTokenB: StateListener?

        autoreleasepool {
            var view: UView? = UView()
            weakView = view

            view?.alpha(sourceA)
            view?.alpha(sourceB)

            guard let liveView = view else {
                XCTFail("Expected live view")
                return
            }

            let tokens = Array(
                liveView._properties
                    .stateBindingHolder
                    .statesValues
                    .heldListeners
                    .values
            )

            guard tokens.count == 2 else {
                XCTFail("Expected exactly two additive view-owned tokens")
                return
            }

            weakTokenA = tokens[0]
            weakTokenB = tokens[1]

            sourceA.wrappedValue = 0.3
            assertAlpha(liveView, equals: 0.3)

            sourceB.wrappedValue = 0.4
            assertAlpha(liveView, equals: 0.4)

            view = nil
        }

        XCTAssertNil(weakView)
        XCTAssertNil(weakTokenA)
        XCTAssertNil(weakTokenB)

        sourceA.wrappedValue = 0.5
        sourceB.wrappedValue = 0.6

        XCTAssertEqual(unrelatedACallCount, 2)
        XCTAssertEqual(unrelatedBCallCount, 2)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 2)
    }

    @MainActor
    func testDeclarativeViewScalarSetterDoesNotCreateBindingToken() {
        let view = UView()

        view.hidden(true)
        view.alpha(0.5)
        view.opacity(0.25)
        view.corners(8)
        view.border(1, UColor.red)
        view.shadow(UColor.blue)

        #if !os(macOS)
        view.tint(UColor.red)
        view.userInteraction(false)
        #endif

        XCTAssertEqual(
            view._properties
                .stateBindingHolder
                .statesValues
                .heldListeners
                .count,
            0
        )
    }

    @MainActor
    func testDeclarativeViewHolderTeardownCancelsBorderAndShadowBindings() {
        let borderState = State<UColor>(wrappedValue: UColor.red)
        let shadowState = State<UColor>(wrappedValue: UColor.blue)

        weak var weakView: UView?
        weak var weakBorderToken: StateListener?
        weak var weakShadowToken: StateListener?

        autoreleasepool {
            var view: UView? = UView()
            weakView = view

            view?.border(1, borderState)
            view?.shadow(shadowState)

            guard let liveView = view else {
                XCTFail("Expected live view")
                return
            }

            let tokens = Array(
                liveView._properties
                    .stateBindingHolder
                    .statesValues
                    .heldListeners
                    .values
            )

            guard tokens.count == 2 else {
                XCTFail("Expected border and shadow tokens")
                return
            }

            weakBorderToken = tokens[0]
            weakShadowToken = tokens[1]

            borderState.wrappedValue = UColor.green
            shadowState.wrappedValue = UColor.yellow

            XCTAssertEqual(
                liveView._properties
                    .stateBindingHolder
                    .statesValues
                    .heldListeners
                    .count,
                2
            )

            view = nil
        }

        XCTAssertNil(weakView)
        XCTAssertNil(weakBorderToken)
        XCTAssertNil(weakShadowToken)
    }

    #if os(macOS)
    @MainActor
    func testMacOSCornersBindingDoesNotRetainSourceStateWhileViewLives() {
        let view = UView()

        var state: State<CGFloat>? = .init(wrappedValue: 4)
        let weakState = WeakBox(state)

        view.corners(state!)

        XCTAssertEqual(
            view._properties
                .stateBindingHolder
                .statesValues
                .heldListeners
                .count,
            1
        )

        state = nil

        XCTAssertNil(weakState.value)
        XCTAssertEqual(
            view._properties
                .stateBindingHolder
                .statesValues
                .heldListeners
                .count,
            0
        )
    }
    #endif

    #if !os(macOS)
    @MainActor
    func testUIKitDeclarativeViewTintAndUserInteractionBindingsUseHolderUntilTeardown() {
        let tintState = State<UColor>(wrappedValue: UColor.red)
        let interactionState = State<Bool>(wrappedValue: true)

        weak var weakView: UView?
        weak var weakTokenA: StateListener?
        weak var weakTokenB: StateListener?

        autoreleasepool {
            var view: UView? = UView()
            weakView = view

            view?.tint(tintState)
            view?.userInteraction(interactionState)

            XCTAssertEqual(
                view?._properties
                    .stateBindingHolder
                    .statesValues
                    .heldListeners
                    .count,
                2
            )

            guard let liveView = view else {
                XCTFail("Expected live view")
                return
            }

            let tokens = Array(
                liveView._properties
                    .stateBindingHolder
                    .statesValues
                    .heldListeners
                    .values
            )

            guard tokens.count == 2 else {
                XCTFail("Expected tint and user-interaction tokens")
                return
            }

            weakTokenA = tokens[0]
            weakTokenB = tokens[1]

            tintState.wrappedValue = UColor.blue
            interactionState.wrappedValue = false

            XCTAssertEqual(liveView.tintColor, UColor.blue)
            XCTAssertEqual(liveView.isUserInteractionEnabled, false)

            view = nil
        }

        XCTAssertNil(weakView)
        XCTAssertNil(weakTokenA)
        XCTAssertNil(weakTokenB)
    }
    #endif
}
#endif
