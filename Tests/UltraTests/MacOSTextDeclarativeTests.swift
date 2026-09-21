#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
import XCTest
@testable import Ultra

@MainActor
final class MacOSTextDeclarativeTests: XCTestCase {
    func testLinesOneUsesNativeSingleLineCellConfiguration() {
        let text = UText("value")

        let result = text.lines(1)
        guard let cell = text.cell as? NSTextFieldCell else {
            return XCTFail("Expected UText to use NSTextFieldCell")
        }

        XCTAssertTrue(result === text)
        XCTAssertEqual(text.maximumNumberOfLines, 1)
        XCTAssertTrue(text.usesSingleLineMode)
        XCTAssertFalse(cell.wraps)
        XCTAssertTrue(cell.isScrollable)
    }

    func testMultilineUsesNativeWrappingCellConfiguration() {
        let text = UText("value")

        let result = text.multiline()
        guard let cell = text.cell as? NSTextFieldCell else {
            return XCTFail("Expected UText to use NSTextFieldCell")
        }

        XCTAssertTrue(result === text)
        XCTAssertEqual(text.maximumNumberOfLines, 0)
        XCTAssertFalse(text.usesSingleLineMode)
        XCTAssertTrue(cell.wraps)
        XCTAssertFalse(cell.isScrollable)
    }
}
#endif
#endif
