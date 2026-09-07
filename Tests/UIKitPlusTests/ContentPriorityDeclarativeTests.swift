#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import XCTest
@testable import UIKitPlus

#if os(macOS)
private typealias TestContentPriority = NSLayoutConstraint.Priority
private typealias TestContentAxis = NSLayoutConstraint.Orientation
#else
private typealias TestContentPriority = UILayoutPriority
private typealias TestContentAxis = NSLayoutConstraint.Axis
#endif

@MainActor
final class ContentPriorityDeclarativeTests: XCTestCase {
    func testContentHuggingPriorityReturnsSameViewUsesNativeGetterAndOverwrites() {
        let view = makeView()

        XCTAssertTrue(
            view.contentHuggingPriority(.defaultLow, for: horizontalAxis) === view
        )
        XCTAssertEqual(
            view.contentHuggingPriority(for: horizontalAxis),
            TestContentPriority.defaultLow
        )

        XCTAssertTrue(
            view.contentHuggingPriority(.required, for: horizontalAxis) === view
        )
        XCTAssertEqual(
            view.contentHuggingPriority(for: horizontalAxis),
            TestContentPriority.required
        )
        assertNoContentPrioritySideEffects(on: view)
    }

    func testContentCompressionResistancePriorityReturnsSameViewUsesNativeGetterAndOverwrites() {
        let view = makeView()

        XCTAssertTrue(
            view.contentCompressionResistancePriority(.required, for: horizontalAxis) === view
        )
        XCTAssertEqual(
            view.contentCompressionResistancePriority(for: horizontalAxis),
            TestContentPriority.required
        )

        XCTAssertTrue(
            view.contentCompressionResistancePriority(.defaultLow, for: horizontalAxis) === view
        )
        XCTAssertEqual(
            view.contentCompressionResistancePriority(for: horizontalAxis),
            TestContentPriority.defaultLow
        )
        assertNoContentPrioritySideEffects(on: view)
    }

    private var horizontalAxis: TestContentAxis {
        .horizontal
    }

    private func makeView() -> UView {
        #if os(macOS)
        _ = App.shared
        #endif
        return UView()
    }

    private func assertNoContentPrioritySideEffects(on view: UView) {
        XCTAssertTrue(view.constraints.isEmpty)
        XCTAssertTrue(view._properties.notAppliedPreConstraintsSolo.isEmpty)
        XCTAssertTrue(view._properties.appliedPreConstraintsSolo.isEmpty)
        XCTAssertTrue(view._properties.notAppliedPreConstraintsSuper.isEmpty)
        XCTAssertTrue(view._properties.appliedPreConstraintsSuper.isEmpty)
        XCTAssertTrue(view._properties.notAppliedPreConstraintsRelative.isEmpty)
        XCTAssertTrue(view._properties.appliedPreConstraintsRelative.isEmpty)
        XCTAssertTrue(view._properties.stateBindingHolder.statesValues.heldListeners.isEmpty)
    }
}
#endif
