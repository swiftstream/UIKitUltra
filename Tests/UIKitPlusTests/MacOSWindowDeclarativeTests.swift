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
}
#endif
