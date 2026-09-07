#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import UIKitPlus

#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
final class PreConstraintOwnershipTests: XCTestCase {

    func testPreConstraintStateUpdateUpdatesConstraintConstant() {
        let view = BaseView()
        let state = State<CGFloat>(wrappedValue: 10)

        let preConstraint = PreConstraint(
            value: state,
            relation: .equal,
            multiplier: 1,
            priority: .init(1000),
            attribute1: .width,
            attribute2: nil,
            toSafe: false,
            fromView: view,
            destinationView: nil
        )

        let constraint = view.widthAnchor.constraint(equalToConstant: state.wrappedValue)
        preConstraint.constraint = constraint

        XCTAssertEqual(constraint.constant, 10)

        state.wrappedValue = 42

        XCTAssertEqual(constraint.constant, 42)
        XCTAssertNotNil(preConstraint.valueListener)
    }

    func testPreConstraintDeallocCancelsListener() {
        let view = BaseView()
        let state = State<CGFloat>(wrappedValue: 10)

        weak var weakPreConstraint: PreConstraint?
        weak var weakListener: StateListener?

        autoreleasepool {
            var preConstraint: PreConstraint? = PreConstraint(
                value: state,
                relation: .equal,
                multiplier: 1,
                priority: .init(1000),
                attribute1: .width,
                attribute2: nil,
                toSafe: false,
                fromView: view,
                destinationView: nil
            )

            weakPreConstraint = preConstraint
            weakListener = preConstraint?.valueListener

            XCTAssertNotNil(weakPreConstraint)
            XCTAssertNotNil(weakListener)

            preConstraint = nil
        }

        XCTAssertNil(weakPreConstraint)
        XCTAssertNil(
            weakListener,
            "PreConstraint.deinit should cancel and release the self-owned StateListener."
        )

        state.wrappedValue = 20
    }

    func testInvertedPreConstraintListenerIndependentCleanup() {
        let sourceView = BaseView()
        let destinationView = BaseView()
        let state = State<CGFloat>(wrappedValue: 5)

        weak var weakOriginal: PreConstraint?
        weak var weakOriginalListener: StateListener?
        weak var weakInverted: PreConstraint?
        weak var weakInvertedListener: StateListener?

        var inverted: PreConstraint?

        autoreleasepool {
            var original: PreConstraint? = PreConstraint(
                value: state,
                relation: .equal,
                multiplier: 1,
                priority: .init(1000),
                attribute1: .leading,
                attribute2: .trailing,
                toSafe: false,
                fromView: sourceView,
                destinationView: destinationView
            )

            inverted = original?.inverted()

            weakOriginal = original
            weakOriginalListener = original?.valueListener
            weakInverted = inverted
            weakInvertedListener = inverted?.valueListener

            XCTAssertNotNil(weakOriginal)
            XCTAssertNotNil(weakOriginalListener)
            XCTAssertNotNil(weakInverted)
            XCTAssertNotNil(weakInvertedListener)

            original = nil
        }

        XCTAssertNil(weakOriginal)
        XCTAssertNil(weakOriginalListener)

        XCTAssertNotNil(
            weakInverted,
            "Inverted PreConstraint should remain alive while the test holds it strongly."
        )
        XCTAssertNotNil(
            weakInvertedListener,
            "Inverted PreConstraint should keep its own independent listener while alive."
        )

        state.wrappedValue = 6

        inverted = nil

        XCTAssertNil(weakInverted)
        XCTAssertNil(weakInvertedListener)
    }

    func testEphemeralStateConstraintDoesNotLeak() {
        let view = BaseView()

        weak var weakState: State<CGFloat>?
        weak var weakPreConstraint: PreConstraint?
        weak var weakListener: StateListener?

        autoreleasepool {
            var state: State<CGFloat>? = State<CGFloat>(wrappedValue: 12)
            var preConstraint: PreConstraint? = PreConstraint(
                value: state!,
                relation: .equal,
                multiplier: 1,
                priority: .init(1000),
                attribute1: .width,
                attribute2: nil,
                toSafe: false,
                fromView: view,
                destinationView: nil
            )

            weakState = state
            weakPreConstraint = preConstraint
            weakListener = preConstraint?.valueListener

            XCTAssertNotNil(weakState)
            XCTAssertNotNil(weakPreConstraint)
            XCTAssertNotNil(weakListener)

            state = nil
            preConstraint = nil
        }

        XCTAssertNil(weakPreConstraint)
        XCTAssertNil(weakListener)
        XCTAssertNil(weakState)
    }
}
#endif
