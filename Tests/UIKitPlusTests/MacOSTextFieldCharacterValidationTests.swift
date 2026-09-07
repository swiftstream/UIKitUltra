#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
import XCTest
@testable import UIKitPlus

private final class TextFieldValidationDelegateSpy: NSObject, TextFieldDelegate {
    var result = true
    private(set) var receivedRange: NSRange?
    private(set) var receivedReplacement: String?

    func textField(
        _ textField: UTextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        receivedRange = range
        receivedReplacement = string
        return result
    }
}

@MainActor
final class MacOSTextFieldCharacterValidationTests: XCTestCase {

    func testShouldChangeCharactersReceivesCalculatedReplacementSynchronously() {
        let textField = UTextField("abcd")
        var receivedRange: NSRange?
        var receivedReplacement: String?

        textField.shouldChangeCharacters { _, range, replacement in
            receivedRange = range
            receivedReplacement = replacement
            return false
        }

        let result = validate(
            textField,
            proposedString: "aXd",
            originalString: "abcd",
            originalSelectedRange: NSRange(location: 1, length: 2)
        )

        XCTAssertFalse(result)
        XCTAssertEqual(receivedRange, NSRange(location: 1, length: 2))
        XCTAssertEqual(receivedReplacement, "X")
    }

    func testFormatCharactersMutationTriggersEditingChangedSynchronously() {
        let textField = UTextField("abcd")
        var editingChangedCount = 0

        textField.editingChanged { _ in
            editingChangedCount += 1
        }
        textField.formatCharacters { textField, range, replacement in
            XCTAssertEqual(range, NSRange(location: 1, length: 2))
            XCTAssertEqual(replacement, "X")
            textField.stringValue = "formatted"
        }

        let result = validate(
            textField,
            proposedString: "aXd",
            originalString: "abcd",
            originalSelectedRange: NSRange(location: 1, length: 2)
        )

        XCTAssertFalse(result)
        XCTAssertEqual(textField.stringValue, "formatted")
        XCTAssertEqual(editingChangedCount, 1)
    }

    func testOutsideDelegateRetainsPrecedenceOverClosureHandlers() {
        let textField = UTextField("abcd")
        let delegate = TextFieldValidationDelegateSpy()
        delegate.result = false
        var formatCalled = false
        var shouldChangeCalled = false

        textField.delegate(delegate)
        textField.formatCharacters { _, _, _ in
            formatCalled = true
        }
        textField.shouldChangeCharacters { _, _, _ in
            shouldChangeCalled = true
            return true
        }

        let result = validate(
            textField,
            proposedString: "aXd",
            originalString: "abcd",
            originalSelectedRange: NSRange(location: 1, length: 2)
        )

        XCTAssertFalse(result)
        XCTAssertEqual(delegate.receivedRange, NSRange(location: 1, length: 2))
        XCTAssertEqual(delegate.receivedReplacement, "X")
        XCTAssertFalse(formatCalled)
        XCTAssertFalse(shouldChangeCalled)
    }

    private func validate(
        _ textField: UTextField,
        proposedString: NSString,
        originalString: String,
        originalSelectedRange: NSRange
    ) -> Bool {
        guard let formatter = textField.formatter else {
            XCTFail("Expected UIKitPlus text field formatter")
            return false
        }

        var proposedString = proposedString
        var proposedSelectedRange = NSRange(
            location: originalSelectedRange.location + proposedString.length,
            length: 0
        )
        var errorDescription: NSString?

        return formatter.isPartialStringValid(
            &proposedString,
            proposedSelectedRange: &proposedSelectedRange,
            originalString: originalString,
            originalSelectedRange: originalSelectedRange,
            errorDescription: &errorDescription
        )
    }
}
#endif
#endif
