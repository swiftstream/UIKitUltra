#if os(macOS)
import AppKit
import XCTest
@testable import UIKitPlus

@MainActor
final class MacOSWindowDeclarativeTests: XCTestCase {
    func testToolbarSetterPreservesNativeNilSemantics() {
        let wrapper = Window()
        let toolbar = NSToolbar(identifier: "UIKitPlusTestToolbar")

        XCTAssertTrue(wrapper.toolbar(toolbar) === wrapper)
        XCTAssertTrue(wrapper.window.toolbar === toolbar)

        XCTAssertTrue(wrapper.toolbar(nil) === wrapper)
        XCTAssertNil(wrapper.window.toolbar)
    }

    func testToolbarWithoutValueCreatesNativeToolbar() {
        let wrapper = Window()

        XCTAssertTrue(wrapper.toolbar() === wrapper)
        XCTAssertNotNil(wrapper.window.toolbar)
    }

    func testStateBindingsApplyInitialValuesRemainLiveAndPreserveIdentity() {
        let wrapper = Window()
        let titleState = State<String>(wrappedValue: "Initial")
        let mouseMovedState = State<Bool>(wrappedValue: false)
        let baselineCount = wrapper.stateBindingHolder.statesValues.heldListeners.count

        XCTAssertTrue(wrapper.title(titleState) === wrapper)
        XCTAssertTrue(wrapper.acceptsMouseMovedEvents(mouseMovedState) === wrapper)
        XCTAssertEqual(
            wrapper.stateBindingHolder.statesValues.heldListeners.count,
            baselineCount + 2
        )
        XCTAssertEqual(wrapper.window.title, "Initial")
        XCTAssertFalse(wrapper.window.acceptsMouseMovedEvents)

        titleState.wrappedValue = "Updated"
        mouseMovedState.wrappedValue = true

        XCTAssertEqual(wrapper.window.title, "Updated")
        XCTAssertTrue(wrapper.window.acceptsMouseMovedEvents)
    }

    func testScalarWindowSettersRemainListenerFree() {
        let wrapper = Window()
        let baselineCount = wrapper.stateBindingHolder.statesValues.heldListeners.count

        XCTAssertTrue(
            wrapper
                .title("Scalar")
                .acceptsMouseMovedEvents(false) === wrapper
        )
        XCTAssertEqual(
            wrapper.stateBindingHolder.statesValues.heldListeners.count,
            baselineCount
        )
        XCTAssertEqual(wrapper.window.title, "Scalar")
        XCTAssertFalse(wrapper.window.acceptsMouseMovedEvents)
    }

    func testWindowTabConfigurationStateBindingsRemainLive() {
        let wrapper = Window()
        let autosaveName = State<NSWindow.FrameAutosaveName>(wrappedValue: "UIKitPlus.WindowTabs")
        let tabbingMode = State<NSWindow.TabbingMode>(wrappedValue: .preferred)
        let tabbingIdentifier = State<NSWindow.TabbingIdentifier>(wrappedValue: "UIKitPlus.WindowTabs")
        let appearance = State<NSAppearance?>(wrappedValue: NSAppearance(named: .darkAqua))

        _ = wrapper
            .frameAutosaveName(autosaveName)
            .tabbingMode(tabbingMode)
            .tabbingIdentifier(tabbingIdentifier)
            .appearance(appearance)

        XCTAssertEqual(wrapper.window.frameAutosaveName, autosaveName.wrappedValue)
        XCTAssertEqual(wrapper.window.tabbingMode, .preferred)
        XCTAssertEqual(wrapper.window.tabbingIdentifier, "UIKitPlus.WindowTabs")
        XCTAssertEqual(wrapper.window.appearance?.name, .darkAqua)

        tabbingMode.wrappedValue = .disallowed
        tabbingIdentifier.wrappedValue = "UIKitPlus.WindowTabs.Updated"
        appearance.wrappedValue = NSAppearance(named: .aqua)

        XCTAssertEqual(wrapper.window.tabbingMode, .disallowed)
        XCTAssertEqual(wrapper.window.tabbingIdentifier, "UIKitPlus.WindowTabs.Updated")
        XCTAssertEqual(wrapper.window.appearance?.name, .aqua)
    }

    func testTitlebarBackgroundBindingsAreChainableAndOwned() {
        let wrapper = Window()
        let colorState = State<UColor>(wrappedValue: UColor(NSColor.red))
        let baselineCount = wrapper.stateBindingHolder.statesValues.heldListeners.count

        XCTAssertTrue(wrapper.titlebarBackground(colorState) === wrapper)
        XCTAssertEqual(
            wrapper.stateBindingHolder.statesValues.heldListeners.count,
            baselineCount + 1
        )

        colorState.wrappedValue = UColor(NSColor.blue)
        XCTAssertTrue(wrapper.titlebarBackground(UColor(NSColor.green)) === wrapper)
        XCTAssertEqual(
            wrapper.stateBindingHolder.statesValues.heldListeners.count,
            baselineCount + 1
        )
    }

    func testRepeatedWindowBindingsRemainAdditiveUntilTeardown() {
        let stateA = State<String>(wrappedValue: "A")
        let stateB = State<String>(wrappedValue: "B")

        weak var weakWrapper: Window?
        weak var weakTokenA: StateListener?
        weak var weakTokenB: StateListener?

        autoreleasepool {
            let wrapper = Window()
            weakWrapper = wrapper

            _ = wrapper.title(stateA).title(stateB)

            let tokens = Array(wrapper.stateBindingHolder.statesValues.heldListeners.values)
            guard tokens.count == 2 else {
                XCTFail("Expected 2 tokens, got \(tokens.count)")
                return
            }

            weakTokenA = tokens[0]
            weakTokenB = tokens[1]

            XCTAssertNotEqual(weakTokenA?.id, weakTokenB?.id)
            XCTAssertEqual(wrapper.window.title, "B")

            stateA.wrappedValue = "A2"
            XCTAssertEqual(wrapper.window.title, "A2")

            stateB.wrappedValue = "B2"
            XCTAssertEqual(wrapper.window.title, "B2")
        }

        XCTAssertNil(weakWrapper)
        XCTAssertNil(weakTokenA)
        XCTAssertNil(weakTokenB)

        stateA.wrappedValue = "AfterA"
        stateB.wrappedValue = "AfterB"
    }
}
#endif
