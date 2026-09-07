#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
import XCTest
@testable import UIKitPlus

@MainActor
private func assertLayerColor(
    _ actual: CGColor?,
    equals expected: NSColor,
    accuracy: CGFloat = 0.0001,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    guard let actual else {
        XCTFail("Expected a layer color", file: file, line: line)
        return
    }
    guard let actualColor = NSColor(cgColor: actual),
          let actualRGB = actualColor.usingColorSpace(.deviceRGB),
          let expectedRGB = expected.usingColorSpace(.deviceRGB) else {
        XCTFail("Could not convert layer colors to device RGB", file: file, line: line)
        return
    }

    XCTAssertEqual(
        actualRGB.redComponent,
        expectedRGB.redComponent,
        accuracy: accuracy,
        file: file,
        line: line
    )
    XCTAssertEqual(
        actualRGB.greenComponent,
        expectedRGB.greenComponent,
        accuracy: accuracy,
        file: file,
        line: line
    )
    XCTAssertEqual(
        actualRGB.blueComponent,
        expectedRGB.blueComponent,
        accuracy: accuracy,
        file: file,
        line: line
    )
    XCTAssertEqual(
        actualRGB.alphaComponent,
        expectedRGB.alphaComponent,
        accuracy: accuracy,
        file: file,
        line: line
    )
}

@MainActor
final class MacOSTextFieldDeclarativeTests: XCTestCase {
    func testUsesSingleLineModeReturnsSameInstanceAndAppliesTrue() {
        let textField = UTextField()
        let result = textField.usesSingleLineMode()

        XCTAssertTrue(result === textField)
        XCTAssertTrue(textField.usesSingleLineMode)
    }

    func testUsesSingleLineModeCanDisableModeWithoutAddingListeners() {
        let textField = UTextField()
        let initialListenerCount = textField.stateBindingHolder.statesValues.heldListeners.count

        let result = textField.usesSingleLineMode(false)

        XCTAssertTrue(result === textField)
        XCTAssertFalse(textField.usesSingleLineMode)
        XCTAssertEqual(
            textField.stateBindingHolder.statesValues.heldListeners.count,
            initialListenerCount
        )
    }

    func testBackgroundModifierReturnsSameInstanceAndUsesBackingLayer() {
        let textField = UTextField()
        let result = textField.background(Color(NSColor.red))

        XCTAssertTrue(result === textField)
        XCTAssertTrue(textField.wantsLayer)
        XCTAssertTrue((textField.cell as? NSTextFieldCell)?.drawsBackground == false)
        assertLayerColor(
            textField.layer?.backgroundColor,
            equals: .red
        )
    }

    func testClearBackgroundKeepsCellBackgroundDisabled() {
        let textField = UTextField()
        _ = textField.background(Color(NSColor.red))
        _ = textField.background(Color.clear)

        XCTAssertTrue((textField.cell as? NSTextFieldCell)?.drawsBackground == false)
        assertLayerColor(
            textField.layer?.backgroundColor,
            equals: .clear
        )
    }

    func testNilBackgroundClearsLayerThroughInternalWitness() {
        let textField = UTextField()
        textField._setBackgroundColor(NSColor.red)
        textField._setBackgroundColor(nil)

        XCTAssertTrue(textField.wantsLayer)
        XCTAssertNil(textField.layer?.backgroundColor)
        XCTAssertTrue((textField.cell as? NSTextFieldCell)?.drawsBackground == false)
    }
}
#endif
#endif
