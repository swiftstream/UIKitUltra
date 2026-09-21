#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import XCTest
@testable import Ultra

#if os(macOS)
import AppKit
#else
import UIKit
#endif

private func assertStateBindingOwnerConformance<T: _StateBindingOwner>(
    _ type: T.Type
) {
    _ = type
}

@MainActor
final class StateBindingOwnerScaffoldingTests: XCTestCase {

    // MARK: - Cross-platform

    func testDeclarativeViewWitnessReusesPropertiesInternalHolder() {
        let view = UView()

        guard let owner = view as? _StateBindingOwner else {
            XCTFail("Expected _StateBindingOwner conformance")
            return
        }

        XCTAssertTrue(
            owner.stateBindingHolder === view._properties.stateBindingHolder
        )

        let source = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        source.listen { _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        weak var weakView: UView?
        weak var weakToken: StateListener?

        autoreleasepool {
            var view: UView? = UView()
            weakView = view

            guard let liveView = view else {
                XCTFail("Expected live view")
                return
            }

            guard let owner = liveView as? _StateBindingOwner else {
                XCTFail("Expected _StateBindingOwner conformance")
                return
            }

            let token = source.listen { _ in }
                .hold(in: owner.stateBindingHolder)

            weakToken = token

            XCTAssertEqual(
                owner.stateBindingHolder.statesValues.heldListeners.count,
                1
            )

            view = nil
        }

        XCTAssertNil(weakView)
        XCTAssertNil(weakToken)

        source.wrappedValue = 1

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)
    }

    func testAttributedStringReusesSlice5CHolder() {
        let attr = Ultra.AttributedString("hello")

        guard let owner = attr as? _StateBindingOwner else {
            XCTFail("Expected _StateBindingOwner conformance")
            return
        }

        XCTAssertTrue(
            owner.stateBindingHolder === attr.stateBindingHolder
        )

        let source = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        source.listen { _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        weak var weakAttr: Ultra.AttributedString?
        weak var weakToken: StateListener?

        autoreleasepool {
            var attr: Ultra.AttributedString? = Ultra.AttributedString("hello")
            weakAttr = attr

            guard let liveAttr = attr else {
                XCTFail("Expected live attributed string")
                return
            }

            guard let owner = liveAttr as? _StateBindingOwner else {
                XCTFail("Expected _StateBindingOwner conformance")
                return
            }

            let token = source.listen { _ in }
                .hold(in: owner.stateBindingHolder)

            weakToken = token

            XCTAssertEqual(
                owner.stateBindingHolder.statesValues.heldListeners.count,
                1
            )

            attr = nil
        }

        XCTAssertNil(weakAttr)
        XCTAssertNil(weakToken)

        source.wrappedValue = 1

        XCTAssertEqual(unrelatedCallCount, 1)
    }

    func testViewControllerAdoptsStateBindingOwner() {
        let source = State<Bool>(wrappedValue: false)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        source.listen { _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        weak var weakVC: ViewController?
        weak var weakToken: StateListener?

        autoreleasepool {
            var vc: ViewController? = ViewController()
            weakVC = vc

            guard let liveVC = vc else {
                XCTFail("Expected live view controller")
                return
            }

            guard let owner = liveVC as? _StateBindingOwner else {
                XCTFail("Expected _StateBindingOwner conformance")
                return
            }

            XCTAssertEqual(
                owner.stateBindingHolder.statesValues.heldListeners.count,
                0
            )

            let token = source.listen { _ in }
                .hold(in: owner.stateBindingHolder)

            weakToken = token

            XCTAssertEqual(
                owner.stateBindingHolder.statesValues.heldListeners.count,
                1
            )

            vc = nil
        }

        XCTAssertNil(weakVC)
        XCTAssertNil(weakToken)

        source.wrappedValue = true

        XCTAssertEqual(unrelatedCallCount, 1)
    }

    func testGestureTrackerDoesNotConformToStateBindingOwner() {
        let tracker: AnyObject = _GestureTracker()

        XCTAssertFalse(tracker is _StateBindingOwner)
    }

    // MARK: - holdInStateBindingOwnerIfAvailable helper characterization

    func testHoldInStateBindingOwnerIfAvailableRoutesOwnerAndReturnsSameToken() {
        let view = UView()
        let source = State<Int>(wrappedValue: 0)

        guard let owner = view as? _StateBindingOwner else {
            XCTFail("Expected _StateBindingOwner conformance")
            return
        }

        let token = source.listen { _ in }

        let returned = token.holdInStateBindingOwnerIfAvailable(view)

        XCTAssertTrue(returned === token)
        XCTAssertEqual(owner.stateBindingHolder.statesValues.heldListeners.count, 1)

        source.wrappedValue = 1
    }

    func testHoldInStateBindingOwnerIfAvailableLeavesNonOwnerTokenLiveAndReturnsSameToken() {
        let candidate: AnyObject = _GestureTracker()
        let source = State<Int>(wrappedValue: 0)

        var calls = 0

        let token = source.listen { _ in
            calls += 1
        }

        let returned = token.holdInStateBindingOwnerIfAvailable(candidate)

        XCTAssertTrue(returned === token)

        source.wrappedValue = 1

        XCTAssertEqual(calls, 1)
    }

    func testHoldInStateBindingOwnerIfAvailableInvalidatesWithOwnerHolder() {
        let view = UView()
        let source = State<Int>(wrappedValue: 0)

        guard let owner = view as? _StateBindingOwner else {
            XCTFail("Expected _StateBindingOwner conformance")
            return
        }

        var calls = 0

        source.listen { _ in
            calls += 1
        }
        .holdInStateBindingOwnerIfAvailable(view)

        source.wrappedValue = 1
        XCTAssertEqual(calls, 1)

        owner.stateBindingHolder.invalidateStates()

        source.wrappedValue = 2
        XCTAssertEqual(calls, 1)
        XCTAssertEqual(owner.stateBindingHolder.statesValues.heldListeners.count, 0)
    }

    // MARK: - macOS-only

    #if os(macOS)

    func testWindowDeclaresStateBindingOwnerConformance() {
        assertStateBindingOwnerConformance(Window.self)
    }

    @MainActor
    func testStatusItemAdoptsStateBindingOwner() {
        let source = State<Bool>(wrappedValue: false)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        source.listen { _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        weak var weakStatusItem: StatusItem?
        weak var weakToken: StateListener?

        autoreleasepool {
            var statusItem: StatusItem? = StatusItem()
            weakStatusItem = statusItem

            guard let liveStatusItem = statusItem else {
                XCTFail("Expected live status item")
                return
            }

            guard let owner = liveStatusItem as? _StateBindingOwner else {
                XCTFail("Expected _StateBindingOwner conformance")
                return
            }

            XCTAssertEqual(
                owner.stateBindingHolder.statesValues.heldListeners.count,
                0
            )

            let token = source.listen { _ in }
                .hold(in: owner.stateBindingHolder)

            weakToken = token

            XCTAssertEqual(
                owner.stateBindingHolder.statesValues.heldListeners.count,
                1
            )

            NSStatusBar.system.removeStatusItem(liveStatusItem.item)

            statusItem = nil
        }

        XCTAssertNil(weakStatusItem)
        XCTAssertNil(weakToken)

        source.wrappedValue = true

        XCTAssertEqual(unrelatedCallCount, 1)
    }

    func testMacOSColorThemeBindingHolderRemainsSeparate() throws {
        guard !Bundle.main.bundlePath.hasSuffix(".appex") else {
            throw XCTSkip(
                "Dynamic Color theme listener is intentionally disabled in extension bundles"
            )
        }

        let color = Color(
            light: NSColor.red,
            dark: NSColor.blue
        )

        let anyColor: AnyObject = color

        XCTAssertFalse(anyColor is _StateBindingOwner)

        XCTAssertEqual(
            color
                .themeBindingHolder
                .statesValues
                .heldListeners
                .count,
            1
        )
    }

    #endif

    // MARK: - UIKit-family-only

    #if !os(macOS)

    func testNavigationControllerAdoptsStateBindingOwner() {
        let source = State<Bool>(wrappedValue: false)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        source.listen { _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        weak var weakNC: NavigationController<UIViewController>?
        weak var weakToken: StateListener?

        autoreleasepool {
            var nc: NavigationController<UIViewController>? = NavigationController<UIViewController>()
            weakNC = nc

            guard let liveNC = nc else {
                XCTFail("Expected live navigation controller")
                return
            }

            guard let owner = liveNC as? _StateBindingOwner else {
                XCTFail("Expected _StateBindingOwner conformance")
                return
            }

            XCTAssertEqual(
                owner.stateBindingHolder.statesValues.heldListeners.count,
                0
            )

            let token = source.listen { _ in }
                .hold(in: owner.stateBindingHolder)

            weakToken = token

            XCTAssertEqual(
                owner.stateBindingHolder.statesValues.heldListeners.count,
                1
            )

            nc = nil
        }

        XCTAssertNil(weakNC)
        XCTAssertNil(weakToken)

        source.wrappedValue = true

        XCTAssertEqual(unrelatedCallCount, 1)
    }

    func testActionSheetDeclaresStateBindingOwnerConformance() {
        assertStateBindingOwnerConformance(ActionSheet.self)
    }

    func testAlertControllerAdoptsStateBindingOwner() {
        let source = State<Bool>(wrappedValue: false)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        source.listen { _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        weak var weakAlert: AlertController?
        weak var weakToken: StateListener?

        autoreleasepool {
            var alert: AlertController? = AlertController(.alert)
            weakAlert = alert

            guard let liveAlert = alert else {
                XCTFail("Expected live alert controller")
                return
            }

            guard let owner = liveAlert as? _StateBindingOwner else {
                XCTFail("Expected _StateBindingOwner conformance")
                return
            }

            XCTAssertEqual(
                owner.stateBindingHolder.statesValues.heldListeners.count,
                0
            )

            let token = source.listen { _ in }
                .hold(in: owner.stateBindingHolder)

            weakToken = token

            XCTAssertEqual(
                owner.stateBindingHolder.statesValues.heldListeners.count,
                1
            )

            alert = nil
        }

        XCTAssertNil(weakAlert)
        XCTAssertNil(weakToken)

        source.wrappedValue = true

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)
    }

    func testPlainUIViewControllerRemainsNonOwner() {
        let vc = UIViewController()
        XCTAssertFalse(vc is _StateBindingOwner)
    }

    func testPlainUIAlertControllerRemainsNonOwner() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        XCTAssertFalse(alert is _StateBindingOwner)
    }

    func testPlainUIAlertActionRemainsNonOwner() {
        let action = UIAlertAction(title: "OK", style: .default)
        XCTAssertFalse(action is _StateBindingOwner)
    }

    #endif
}
#endif
