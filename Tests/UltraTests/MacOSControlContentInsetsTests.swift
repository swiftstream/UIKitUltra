#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
import XCTest
@testable import Ultra

@MainActor
private final class InvalidationButton: UButton {
    private(set) var invalidationCount = 0

    override func invalidateIntrinsicContentSize(for cell: NSCell) {
        invalidationCount += 1
        super.invalidateIntrinsicContentSize(for: cell)
    }
}

@MainActor
private final class TextFieldDelegateProbe: NSObject, TextFieldDelegate {}

@MainActor
final class MacOSControlContentInsetsTests: XCTestCase {

    private let zeroInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    private func assertInsets(
        _ control: NSControl,
        top: CGFloat,
        left: CGFloat,
        right: CGFloat,
        bottom: CGFloat,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let actual = control._macOSControlInsetsValue else {
            XCTFail("Expected an inset-capable backing cell", file: file, line: line)
            return
        }
        XCTAssertEqual(actual.top, top, accuracy: 0.0001, file: file, line: line)
        XCTAssertEqual(actual.left, left, accuracy: 0.0001, file: file, line: line)
        XCTAssertEqual(actual.right, right, accuracy: 0.0001, file: file, line: line)
        XCTAssertEqual(actual.bottom, bottom, accuracy: 0.0001, file: file, line: line)
    }

    private func assertSize(
        _ actual: NSSize,
        equals expected: NSSize,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(actual.width, expected.width, accuracy: 0.0001, file: file, line: line)
        XCTAssertEqual(actual.height, expected.height, accuracy: 0.0001, file: file, line: line)
    }

    private func assertRect(
        _ actual: NSRect,
        equals expected: NSRect,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(actual.minX, expected.minX, accuracy: 0.0001, file: file, line: line)
        XCTAssertEqual(actual.minY, expected.minY, accuracy: 0.0001, file: file, line: line)
        XCTAssertEqual(actual.width, expected.width, accuracy: 0.0001, file: file, line: line)
        XCTAssertEqual(actual.height, expected.height, accuracy: 0.0001, file: file, line: line)
    }

    private func nativeButtonReference(from source: NSButtonCell) -> NSButtonCell {
        let reference = NSButtonCell(textCell: source.title)
        reference.title = source.title
        reference.attributedTitle = source.attributedTitle
        reference.alternateTitle = source.alternateTitle
        reference.alternateImage = source.alternateImage
        reference.image = source.image
        reference.imagePosition = source.imagePosition
        reference.bezelStyle = source.bezelStyle
        reference.isBordered = source.isBordered
        reference.controlSize = source.controlSize
        reference.font = source.font
        return reference
    }

    private func nativePopupReference(from source: NSPopUpButtonCell) -> NSPopUpButtonCell {
        let reference = NSPopUpButtonCell(textCell: source.title ?? "", pullsDown: source.pullsDown)
        reference.menu = source.menu
        reference.controlSize = source.controlSize
        reference.font = source.font
        reference.arrowPosition = source.arrowPosition
        reference.preferredEdge = source.preferredEdge
        reference.usesItemFromMenu = source.usesItemFromMenu
        return reference
    }

    private func nativeTextReference(from source: NSTextFieldCell) -> NSTextFieldCell {
        let reference = NSTextFieldCell(textCell: source.stringValue)
        reference.controlSize = source.controlSize
        reference.font = source.font
        reference.alignment = source.alignment
        reference.isBezeled = source.isBezeled
        reference.bezelStyle = source.bezelStyle
        reference.isEditable = source.isEditable
        reference.isSelectable = source.isSelectable
        reference.drawsBackground = source.drawsBackground
        reference.backgroundColor = source.backgroundColor
        reference.textColor = source.textColor
        reference.placeholderAttributedString = source.placeholderAttributedString
        return reference
    }

    private func nativeSecureReference(from source: NSSecureTextFieldCell) -> NSSecureTextFieldCell {
        let reference = NSSecureTextFieldCell(textCell: source.stringValue)
        reference.controlSize = source.controlSize
        reference.font = source.font
        reference.alignment = source.alignment
        reference.isBezeled = source.isBezeled
        reference.bezelStyle = source.bezelStyle
        reference.isEditable = source.isEditable
        reference.isSelectable = source.isSelectable
        reference.drawsBackground = source.drawsBackground
        reference.backgroundColor = source.backgroundColor
        reference.textColor = source.textColor
        reference.placeholderAttributedString = source.placeholderAttributedString
        reference.echosBullets = source.echosBullets
        return reference
    }

    private func assertGeometry(
        control: NSControl,
        cell: NSCell,
        reference: NSCell,
        apply: (NSEdgeInsets) -> Void
    ) {
        apply(zeroInsets)
        assertSize(cell.cellSize, equals: reference.cellSize)

        let unconstrainedBase = cell.cellSize
        apply(.init(top: 3, left: 3, bottom: 3, right: 3))
        let uniform = cell.cellSize
        XCTAssertEqual(uniform.width - unconstrainedBase.width, 6, accuracy: 0.0001)
        XCTAssertEqual(uniform.height - unconstrainedBase.height, 6, accuracy: 0.0001)

        apply(.init(top: 5, left: 4, bottom: 5, right: 4))
        let twoAxis = cell.cellSize
        XCTAssertEqual(twoAxis.width - unconstrainedBase.width, 8, accuracy: 0.0001)
        XCTAssertEqual(twoAxis.height - unconstrainedBase.height, 10, accuracy: 0.0001)

        let edges = NSEdgeInsets(top: 1, left: 2, bottom: 4, right: 3)
        apply(edges)
        let fourEdge = cell.cellSize
        XCTAssertEqual(fourEdge.width - unconstrainedBase.width, 5, accuracy: 0.0001)
        XCTAssertEqual(fourEdge.height - unconstrainedBase.height, 5, accuracy: 0.0001)

        let bounds = NSRect(x: 20, y: 10, width: 1000, height: 300)
        let effectiveBounds = NSRect(
            x: bounds.minX + edges.left,
            y: bounds.minY + edges.bottom,
            width: max(0, bounds.width - edges.left - edges.right),
            height: max(0, bounds.height - edges.top - edges.bottom)
        )
        let expectedConstrained = reference.cellSize(forBounds: effectiveBounds)
        let actualConstrained = cell.cellSize(forBounds: bounds)
        XCTAssertEqual(actualConstrained.width, expectedConstrained.width + edges.left + edges.right, accuracy: 0.0001)
        XCTAssertEqual(actualConstrained.height, expectedConstrained.height + edges.top + edges.bottom, accuracy: 0.0001)

        control.frame = NSRect(x: 4, y: 5, width: 180, height: 42)
        let originalBounds = control.bounds
        apply(edges)
        XCTAssertEqual(control.bounds, originalBounds)
    }

    func testNormalConstructorsUseNativeInsetCellsAndSuppliedCellsStayExact() {
        let button = UButton("Button")
        let buttonFromArray = UButton(["Button"])
        XCTAssertTrue(button.cell is NSButtonCell)
        XCTAssertTrue(button.cell is _MacOSInsettableCell)
        XCTAssertTrue(buttonFromArray.cell is _MacOSInsettableCell)

        let popup = UPopUpButton(Menu())
        let popupFromBuilder = UPopUpButton {
            MenuItem("First")
        }
        XCTAssertTrue(popup.cell is NSPopUpButtonCell)
        XCTAssertTrue(popup.cell is _MacOSInsettableCell)
        XCTAssertTrue(popupFromBuilder.cell is _MacOSInsettableCell)

        let textField = UTextField("Text")
        let textFieldFromArray = UTextField(["Text"])
        let textFieldFromFrame = UTextField(frame: .zero)
        XCTAssertTrue(textField.cell is NSTextFieldCell)
        XCTAssertTrue(textField.cell is _MacOSInsettableCell)
        XCTAssertTrue(textFieldFromArray.cell is _MacOSInsettableCell)
        XCTAssertTrue(textFieldFromFrame.cell is _MacOSInsettableCell)

        let secure = USecureTextField("Secret")
        XCTAssertTrue(secure.cell is NSSecureTextFieldCell)
        XCTAssertTrue(secure.cell is _MacOSInsettableCell)

        let supplied = NSButtonCell(textCell: "Native")
        let suppliedButton = UButton(supplied)
        XCTAssertTrue(suppliedButton.cell === supplied)
        XCTAssertFalse(suppliedButton.cell is _MacOSInsettableCell)

        let scalarResult = suppliedButton.contentInsets(3, 4)
        XCTAssertTrue(scalarResult === suppliedButton)
        XCTAssertTrue(suppliedButton.cell === supplied)
        XCTAssertNil(suppliedButton._macOSControlInsetsValue)

        let baseline = suppliedButton.stateBindingHolder.statesValues.heldListeners.count
        let state = State<NSEdgeInsets>(wrappedValue: .init(top: 1, left: 2, bottom: 3, right: 4))
        XCTAssertTrue(suppliedButton.contentInsets(state) === suppliedButton)
        XCTAssertEqual(suppliedButton.stateBindingHolder.statesValues.heldListeners.count, baseline)
        state.wrappedValue = .init(top: 5, left: 6, bottom: 7, right: 8)
        XCTAssertTrue(suppliedButton.cell === supplied)

        let windowButton = UButton.windowClose
        guard let windowCell = windowButton.cell else {
            XCTFail("Expected the standard window button to retain its native cell")
            return
        }
        XCTAssertFalse(windowCell is _MacOSInsettableCell)
        let windowIdentity = windowCell
        _ = windowButton.contentInsets(2)
        XCTAssertTrue(windowButton.cell === windowIdentity)
    }

    func testPopupReplacementCellPreservesNativeIdentityAndSkipsInsetBindings() {
        let menu = Menu()
        menu.menu.addItem(withTitle: "Native", action: nil, keyEquivalent: "")
        let popup = UPopUpButton(menu)
        XCTAssertTrue(popup.cell is _MacOSInsettableCell)

        let nativeMenu = popup.menu
        let replacement = NSPopUpButtonCell(textCell: "Native", pullsDown: false)
        replacement.menu = nativeMenu
        popup.cell = replacement

        let baselineListeners = popup.stateBindingHolder.statesValues.heldListeners.count
        let nativeIntrinsic = popup.intrinsicContentSize
        let nativeFitting = popup.fittingSize
        let nativeTitle = replacement.title

        _ = popup.contentInsets(10, 6)

        XCTAssertTrue(popup.cell === replacement)
        XCTAssertNil(popup._macOSControlInsetsValue)
        XCTAssertTrue(popup.menu === nativeMenu)
        XCTAssertEqual(replacement.title, nativeTitle)
        assertSize(popup.intrinsicContentSize, equals: nativeIntrinsic)
        assertSize(popup.fittingSize, equals: nativeFitting)

        let state = State<NSEdgeInsets>(wrappedValue: .init(top: 1, left: 2, bottom: 3, right: 4))
        _ = popup.contentInsets(state)
        XCTAssertEqual(popup.stateBindingHolder.statesValues.heldListeners.count, baselineListeners)

        state.wrappedValue = .init(top: 5, left: 6, bottom: 7, right: 8)
        XCTAssertTrue(popup.cell === replacement)
        XCTAssertNil(popup._macOSControlInsetsValue)
        XCTAssertTrue(popup.menu === nativeMenu)
        XCTAssertEqual(replacement.title, nativeTitle)
        assertSize(popup.intrinsicContentSize, equals: nativeIntrinsic)
        assertSize(popup.fittingSize, equals: nativeFitting)
    }

    func testTextAndSecureReplacementCellsPreserveNativeIdentityAndSkipInsetBindings() {
        let textField = UTextField("Text")
        let formatter = NumberFormatter()
        let replacement = NSTextFieldCell(textCell: "Native")
        replacement.isEditable = true
        replacement.isSelectable = true
        replacement.placeholderAttributedString = NSAttributedString(string: "Placeholder")
        textField.cell = replacement
        textField.formater(formatter)
        textField.stringValue = "Native"

        let baselineListeners = textField.stateBindingHolder.statesValues.heldListeners.count
        let nativeString = textField.stringValue
        let nativePlaceholder = replacement.placeholderAttributedString?.string

        _ = textField.textInsets(10, 6)

        XCTAssertTrue(textField.cell === replacement)
        XCTAssertNil(textField._macOSControlInsetsValue)
        XCTAssertEqual(textField.stringValue, nativeString)
        XCTAssertEqual(replacement.placeholderAttributedString?.string, nativePlaceholder)
        XCTAssertTrue(textField.formatter === formatter)

        let state = State<NSEdgeInsets>(wrappedValue: .init(top: 1, left: 2, bottom: 3, right: 4))
        _ = textField.textInsets(state)
        XCTAssertEqual(textField.stateBindingHolder.statesValues.heldListeners.count, baselineListeners)

        state.wrappedValue = .init(top: 5, left: 6, bottom: 7, right: 8)
        XCTAssertTrue(textField.cell === replacement)
        XCTAssertNil(textField._macOSControlInsetsValue)
        XCTAssertEqual(textField.stringValue, nativeString)
        XCTAssertEqual(replacement.placeholderAttributedString?.string, nativePlaceholder)
        XCTAssertTrue(textField.formatter === formatter)

        let secure = USecureTextField("Secret")
        let secureReplacement = NSSecureTextFieldCell(textCell: "Secret")
        secureReplacement.echosBullets = true
        secure.cell = secureReplacement
        let secureBaselineListeners = secure.stateBindingHolder.statesValues.heldListeners.count
        let secureState = State<CGFloat>(wrappedValue: 2)

        _ = secure.textInsets(4)
        _ = secure.textInsets(secureState)
        XCTAssertTrue(secure.cell === secureReplacement)
        XCTAssertNil(secure._macOSControlInsetsValue)
        XCTAssertTrue(secureReplacement.echosBullets)
        XCTAssertEqual(secure.stateBindingHolder.statesValues.heldListeners.count, secureBaselineListeners)

        secureState.wrappedValue = 6
        XCTAssertTrue(secure.cell === secureReplacement)
        XCTAssertNil(secure._macOSControlInsetsValue)
        XCTAssertTrue(secureReplacement.echosBullets)
        XCTAssertEqual(secure.stateBindingHolder.statesValues.heldListeners.count, secureBaselineListeners)
    }

    func testScalarOverloadsMapEdgesAndRemainListenerFreeAcrossFamilies() {
        let direct = NSEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)

        let button = UButton("Button")
        let buttonListeners = button.stateBindingHolder.statesValues.heldListeners.count
        XCTAssertTrue(button.contentInsets(direct) === button)
        assertInsets(button, top: 1, left: 2, right: 4, bottom: 3)
        XCTAssertTrue(button.contentInsets(5, 6) === button)
        assertInsets(button, top: 6, left: 5, right: 5, bottom: 6)
        XCTAssertTrue(button.contentInsets(7) === button)
        assertInsets(button, top: 7, left: 7, right: 7, bottom: 7)
        XCTAssertTrue(button.contentInsets(top: 8, left: 9, right: 10, bottom: 11) === button)
        assertInsets(button, top: 8, left: 9, right: 10, bottom: 11)
        _ = button.contentInsets(top: 8, left: 9, right: 10, bottom: 11)
        XCTAssertEqual(button.stateBindingHolder.statesValues.heldListeners.count, buttonListeners)

        let popup = UPopUpButton(Menu())
        let popupListeners = popup.stateBindingHolder.statesValues.heldListeners.count
        _ = popup.contentInsets(direct)
        assertInsets(popup, top: 1, left: 2, right: 4, bottom: 3)
        _ = popup.contentInsets(5, 6)
        assertInsets(popup, top: 6, left: 5, right: 5, bottom: 6)
        _ = popup.contentInsets(7)
        assertInsets(popup, top: 7, left: 7, right: 7, bottom: 7)
        _ = popup.contentInsets(top: 8, left: 9, right: 10, bottom: 11)
        assertInsets(popup, top: 8, left: 9, right: 10, bottom: 11)
        _ = popup.contentInsets(top: 8, left: 9, right: 10, bottom: 11)
        XCTAssertEqual(popup.stateBindingHolder.statesValues.heldListeners.count, popupListeners)

        let textField = UTextField("Text")
        let textListeners = textField.stateBindingHolder.statesValues.heldListeners.count
        _ = textField.textInsets(direct)
        assertInsets(textField, top: 1, left: 2, right: 4, bottom: 3)
        _ = textField.textInsets(5, 6)
        assertInsets(textField, top: 6, left: 5, right: 5, bottom: 6)
        _ = textField.textInsets(7)
        assertInsets(textField, top: 7, left: 7, right: 7, bottom: 7)
        _ = textField.textInsets(top: 8, left: 9, right: 10, bottom: 11)
        assertInsets(textField, top: 8, left: 9, right: 10, bottom: 11)
        _ = textField.textInsets(top: 8, left: 9, right: 10, bottom: 11)
        XCTAssertEqual(textField.stateBindingHolder.statesValues.heldListeners.count, textListeners)
    }

    func testScalarChangesInvalidateIntrinsicSizeOnlyWhenEffectiveEdgesChange() {
        let button = InvalidationButton("Button")
        let baseline = button.invalidationCount

        _ = button.contentInsets(2)
        XCTAssertEqual(button.invalidationCount, baseline + 1)

        _ = button.contentInsets(2)
        XCTAssertEqual(button.invalidationCount, baseline + 1)

        _ = button.contentInsets(3)
        XCTAssertEqual(button.invalidationCount, baseline + 2)
    }

    func testButtonStateSurfacesAreImmediateWeakHolderOwnedAndAdditive() {
        let edgeState = State<NSEdgeInsets>(wrappedValue: .init(top: 1, left: 2, bottom: 3, right: 4))
        let button = UButton("Button")
        let baseline = button.stateBindingHolder.statesValues.heldListeners.count
        XCTAssertTrue(button.contentInsets(edgeState) === button)
        XCTAssertEqual(button.stateBindingHolder.statesValues.heldListeners.count, baseline + 1)
        assertInsets(button, top: 1, left: 2, right: 4, bottom: 3)
        edgeState.wrappedValue = .init(top: 5, left: 6, bottom: 7, right: 8)
        assertInsets(button, top: 5, left: 6, right: 8, bottom: 7)

        let horizontal = State<CGFloat>(wrappedValue: 9)
        let vertical = State<CGFloat>(wrappedValue: 10)
        let axisButton = UButton("Axis")
        let axisBaseline = axisButton.stateBindingHolder.statesValues.heldListeners.count
        _ = axisButton.contentInsets(horizontal, vertical)
        XCTAssertEqual(axisButton.stateBindingHolder.statesValues.heldListeners.count, axisBaseline + 2)
        horizontal.wrappedValue = 11
        assertInsets(axisButton, top: 10, left: 11, right: 11, bottom: 10)
        vertical.wrappedValue = 12
        assertInsets(axisButton, top: 12, left: 11, right: 11, bottom: 12)

        let uniform = State<CGFloat>(wrappedValue: 13)
        let uniformButton = UButton("Uniform")
        _ = uniformButton.contentInsets(uniform)
        assertInsets(uniformButton, top: 13, left: 13, right: 13, bottom: 13)
        uniform.wrappedValue = 14
        assertInsets(uniformButton, top: 14, left: 14, right: 14, bottom: 14)

        let top = State<CGFloat>(wrappedValue: 15)
        let left = State<CGFloat>(wrappedValue: 16)
        let right = State<CGFloat>(wrappedValue: 17)
        let bottom = State<CGFloat>(wrappedValue: 18)
        let edgeButton = UButton("Edges")
        _ = edgeButton.contentInsets(top: top, left: left, right: right, bottom: bottom)
        assertInsets(edgeButton, top: 15, left: 16, right: 17, bottom: 18)
        left.wrappedValue = 19
        assertInsets(edgeButton, top: 15, left: 19, right: 17, bottom: 18)

        let additiveA = State<CGFloat>(wrappedValue: 20)
        let additiveB = State<CGFloat>(wrappedValue: 21)
        let additiveButton = UButton("Additive")
        let additiveBaseline = additiveButton.stateBindingHolder.statesValues.heldListeners.count
        _ = additiveButton.contentInsets(additiveA)
        _ = additiveButton.contentInsets(additiveB)
        XCTAssertEqual(additiveButton.stateBindingHolder.statesValues.heldListeners.count, additiveBaseline + 2)
        _ = additiveButton.contentInsets(22)
        XCTAssertEqual(additiveButton.stateBindingHolder.statesValues.heldListeners.count, additiveBaseline + 2)
        additiveA.wrappedValue = 23
        additiveB.wrappedValue = 24
        assertInsets(additiveButton, top: 24, left: 24, right: 24, bottom: 24)

        let teardownState = State<CGFloat>(wrappedValue: 25)
        weak var weakButton: UButton?
        weak var weakToken: StateListener?
        autoreleasepool {
            var ownedButton: UButton? = UButton("Teardown")
            weakButton = ownedButton
            _ = ownedButton?.contentInsets(teardownState)
            weakToken = ownedButton?.stateBindingHolder.statesValues.heldListeners.values.first
            ownedButton = nil
        }
        XCTAssertNil(weakButton)
        XCTAssertNil(weakToken)
        teardownState.wrappedValue = 26
    }

    func testPopupAndTextStateSurfacesPropagateWithoutPeerRetention() {
        let popup = UPopUpButton(Menu())
        let popupHorizontal = State<CGFloat>(wrappedValue: 2)
        let popupVertical = State<CGFloat>(wrappedValue: 3)
        let popupBaseline = popup.stateBindingHolder.statesValues.heldListeners.count
        _ = popup.contentInsets(popupHorizontal, popupVertical)
        XCTAssertEqual(popup.stateBindingHolder.statesValues.heldListeners.count, popupBaseline + 2)
        popupHorizontal.wrappedValue = 4
        assertInsets(popup, top: 3, left: 4, right: 4, bottom: 3)
        popupVertical.wrappedValue = 5
        assertInsets(popup, top: 5, left: 4, right: 4, bottom: 5)

        let popupTop = State<CGFloat>(wrappedValue: 6)
        let popupLeft = State<CGFloat>(wrappedValue: 7)
        let popupRight = State<CGFloat>(wrappedValue: 8)
        let popupBottom = State<CGFloat>(wrappedValue: 9)
        _ = popup.contentInsets(top: popupTop, left: popupLeft, right: popupRight, bottom: popupBottom)
        popupRight.wrappedValue = 10
        assertInsets(popup, top: 6, left: 7, right: 10, bottom: 9)

        let textField = UTextField("Text")
        let textState = State<NSEdgeInsets>(wrappedValue: .init(top: 1, left: 2, bottom: 3, right: 4))
        let textBaseline = textField.stateBindingHolder.statesValues.heldListeners.count
        _ = textField.textInsets(textState)
        XCTAssertEqual(textField.stateBindingHolder.statesValues.heldListeners.count, textBaseline + 1)
        assertInsets(textField, top: 1, left: 2, right: 4, bottom: 3)
        textState.wrappedValue = .init(top: 5, left: 6, bottom: 7, right: 8)
        assertInsets(textField, top: 5, left: 6, right: 8, bottom: 7)

        let textHorizontal = State<CGFloat>(wrappedValue: 9)
        let textVertical = State<CGFloat>(wrappedValue: 10)
        _ = textField.textInsets(textHorizontal, textVertical)
        textHorizontal.wrappedValue = 11
        assertInsets(textField, top: 10, left: 11, right: 11, bottom: 10)

        let secure = USecureTextField("Secret")
        let secureState = State<CGFloat>(wrappedValue: 12)
        _ = secure.textInsets(secureState)
        secureState.wrappedValue = 13
        assertInsets(secure, top: 13, left: 13, right: 13, bottom: 13)
        XCTAssertTrue(secure.cell is NSSecureTextFieldCell)
    }

    func testNativeZeroAndOneTimeSizingRelationshipsHoldForAllCellFamilies() {
        let button = UButton("Button")
        let buttonCell = try! XCTUnwrap(button.cell)
        let buttonReference = nativeButtonReference(from: try! XCTUnwrap(buttonCell as? NSButtonCell))
        assertGeometry(control: button, cell: buttonCell, reference: buttonReference) { button.contentInsets($0) }

        let popup = UPopUpButton(Menu())
        let popupCell = try! XCTUnwrap(popup.cell)
        let popupReference = nativePopupReference(from: try! XCTUnwrap(popupCell as? NSPopUpButtonCell))
        assertGeometry(control: popup, cell: popupCell, reference: popupReference) { popup.contentInsets($0) }

        let textField = UTextField("Text")
        let textCell = try! XCTUnwrap(textField.cell)
        let textReference = nativeTextReference(from: try! XCTUnwrap(textCell as? NSTextFieldCell))
        assertGeometry(control: textField, cell: textCell, reference: textReference) { textField.textInsets($0) }

        let secure = USecureTextField("Secret")
        let secureCell = try! XCTUnwrap(secure.cell)
        let secureReference = nativeSecureReference(from: try! XCTUnwrap(secureCell as? NSSecureTextFieldCell))
        assertGeometry(control: secure, cell: secureCell, reference: secureReference) { secure.textInsets($0) }
    }

    func testButtonNativeContentAndFullBoundsRemainNative() {
        let button = UButton("Title")
        let image = NSImage(size: NSSize(width: 8, height: 8))
        let alternateImage = NSImage(size: NSSize(width: 9, height: 9))
        button.image = image
        button.imagePosition = .imageLeft
        button.alternateTitle = "Alternate"
        button.alternateImage = alternateImage
        _ = button.type(.toggle)
        button.isBordered = true
        button.isHighlighted = true
        button.frame = NSRect(x: 2, y: 3, width: 180, height: 40)
        let originalBounds = button.bounds

        _ = button.contentInsets(4, 5)

        XCTAssertEqual(button.title, "Title")
        XCTAssertTrue(button.image === image)
        XCTAssertEqual(button.imagePosition, .imageLeft)
        XCTAssertEqual(button.alternateTitle, "Alternate")
        XCTAssertTrue(button.alternateImage === alternateImage)
        XCTAssertEqual(button._buttonTypeState.wrappedValue, .toggle)
        XCTAssertTrue(button.isBordered)
        XCTAssertTrue(button.isHighlighted)
        XCTAssertEqual(button.bounds, originalBounds)
    }

    func testPopupNativeMenuSelectionAndAttachmentPropertiesRemainNative() {
        let menu = Menu()
        menu.menu.addItem(withTitle: "First", action: nil, keyEquivalent: "")
        menu.menu.addItem(withTitle: "Second", action: nil, keyEquivalent: "")
        let popup = UPopUpButton(menu)
        popup.selectItem(at: 1)
        let selected = popup.selectedItem
        let nativeMenu = popup.menu
        let cell = try! XCTUnwrap(popup.cell as? NSPopUpButtonCell)
        popup.pullsDown = true
        cell.arrowPosition = .arrowAtBottom
        popup.preferredEdge = .maxY
        let originalBounds = popup.bounds

        _ = popup.contentInsets(3, 4)

        XCTAssertTrue(popup.menu === nativeMenu)
        XCTAssertTrue(popup.selectedItem === selected)
        XCTAssertTrue(popup.pullsDown)
        XCTAssertEqual(cell.arrowPosition, .arrowAtBottom)
        XCTAssertEqual(popup.preferredEdge, .maxY)
        XCTAssertEqual(popup.bounds, originalBounds)
    }

    func testPopupIntrinsicAndFittingSizesDriveInsetAwareAutoLayout() {
        func makePopup() -> UPopUpButton {
            let menu = Menu()
            menu.menu.addItem(withTitle: "First", action: nil, keyEquivalent: "")
            menu.menu.addItem(withTitle: "Second", action: nil, keyEquivalent: "")
            return UPopUpButton(menu)
        }

        let zero = makePopup()
        let padded = makePopup()
        zero.contentInsets(zeroInsets)
        padded.contentInsets(zeroInsets)

        let zeroIntrinsic = zero.intrinsicContentSize
        let zeroFitting = zero.fittingSize
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 180))
        zero.translatesAutoresizingMaskIntoConstraints = false
        padded.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(zero)
        container.addSubview(padded)
        NSLayoutConstraint.activate([
            zero.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            zero.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            padded.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 300),
            padded.topAnchor.constraint(equalTo: container.topAnchor, constant: 20)
        ])
        container.layoutSubtreeIfNeeded()

        let zeroFrame = zero.frame
        assertSize(zero.frame.size, equals: zeroFitting)
        assertSize(zero.bounds.size, equals: zeroFrame.size)

        padded.contentInsets(10, 6)
        container.layoutSubtreeIfNeeded()

        let paddedIntrinsic = padded.intrinsicContentSize
        let paddedFitting = padded.fittingSize
        XCTAssertEqual(paddedIntrinsic.width - zeroIntrinsic.width, 20, accuracy: 0.0001)
        XCTAssertEqual(paddedIntrinsic.height - zeroIntrinsic.height, 12, accuracy: 0.0001)
        XCTAssertEqual(paddedFitting.width - zeroFitting.width, 20, accuracy: 0.0001)
        XCTAssertEqual(paddedFitting.height - zeroFitting.height, 12, accuracy: 0.0001)
        XCTAssertEqual(padded.frame.width - zeroFrame.width, 20, accuracy: 0.0001)
        XCTAssertEqual(padded.frame.height - zeroFrame.height, 12, accuracy: 0.0001)
        assertSize(padded.frame.size, equals: paddedFitting)
        assertSize(padded.bounds.size, equals: padded.frame.size)

        let stableIntrinsic = paddedIntrinsic
        let stableFitting = paddedFitting
        let stableFrame = padded.frame
        _ = padded.contentInsets(10, 6)
        container.layoutSubtreeIfNeeded()
        assertSize(padded.intrinsicContentSize, equals: stableIntrinsic)
        assertSize(padded.fittingSize, equals: stableFitting)
        XCTAssertEqual(padded.frame, stableFrame)
        XCTAssertEqual(padded.bounds, NSRect(origin: .zero, size: stableFrame.size))
    }

    func testTextAndSecureNativeStateSurvivesInsetMutationAndEditorEntryPoints() {
        let textField = UTextField("Text")
        let textCell = try! XCTUnwrap(textField.cell as? NSTextFieldCell)
        textCell.placeholderAttributedString = NSAttributedString(string: "Placeholder")
        let formatter = NumberFormatter()
        let delegate = TextFieldDelegateProbe()
        textField.formater(formatter)
        textField.delegate(delegate)
        textField.frame = NSRect(x: 1, y: 2, width: 220, height: 34)
        let originalBounds = textField.bounds
        let editor = NSTextView(frame: .zero)

        _ = textField.textInsets(4, 5)
        textCell.edit(withFrame: originalBounds, in: textField, editor: editor, delegate: nil, event: nil)
        textCell.select(withFrame: originalBounds, in: textField, editor: editor, delegate: nil, start: 0, length: 0)

        XCTAssertTrue(textField.cell === textCell)
        XCTAssertEqual(textField.stringValue, "Text")
        XCTAssertEqual(textCell.placeholderAttributedString?.string, "Placeholder")
        XCTAssertTrue(textField.formatter === formatter)
        XCTAssertEqual(textField.bounds, originalBounds)

        let secure = USecureTextField("Secret")
        let secureCell = try! XCTUnwrap(secure.cell as? NSSecureTextFieldCell)
        secureCell.echosBullets = true
        let secureIdentity = secure.cell
        _ = secure.textInsets(2, 3)
        XCTAssertTrue(secure.cell === secureIdentity)
        XCTAssertTrue(secure.cell === secureCell)
        XCTAssertTrue(secureCell.echosBullets)
        XCTAssertTrue(secure.cell is NSSecureTextFieldCell)
    }

    func testOrdinaryAndSecureEditorGeometryMatchesNativeReference() {
        let controlFrame = NSRect(x: 7, y: 8, width: 220, height: 34)
        let edges = NSEdgeInsets(top: 5, left: 4, bottom: 3, right: 6)

        func effectiveFrame(for bounds: NSRect, edges: NSEdgeInsets) -> NSRect {
            NSRect(
                x: bounds.minX + edges.left,
                y: bounds.minY + edges.bottom,
                width: max(0, bounds.width - edges.left - edges.right),
                height: max(0, bounds.height - edges.top - edges.bottom)
            )
        }

        let textField = UTextField("Text")
        textField.frame = controlFrame
        let textCell = try! XCTUnwrap(textField.cell as? NSTextFieldCell)
        let textReferenceControl = NSTextField(frame: controlFrame)
        let textReferenceCell = nativeTextReference(from: textCell)
        textReferenceControl.cell = textReferenceCell
        let originalTextBounds = textField.bounds

        textField.textInsets(zeroInsets)
        let textZeroProductionEdit = NSTextView.fieldEditor()
        let textZeroReferenceEdit = NSTextView.fieldEditor()
        textCell.edit(withFrame: textField.bounds, in: textField, editor: textZeroProductionEdit, delegate: nil, event: nil)
        textReferenceCell.edit(withFrame: textReferenceControl.bounds, in: textReferenceControl, editor: textZeroReferenceEdit, delegate: nil, event: nil)
        assertRect(textZeroProductionEdit.frame, equals: textZeroReferenceEdit.frame)
        XCTAssertGreaterThan(textZeroProductionEdit.frame.width, 0)
        XCTAssertGreaterThan(textZeroProductionEdit.frame.height, 0)

        let textZeroProductionSelect = NSTextView.fieldEditor()
        let textZeroReferenceSelect = NSTextView.fieldEditor()
        textCell.select(withFrame: textField.bounds, in: textField, editor: textZeroProductionSelect, delegate: nil, start: 0, length: 0)
        textReferenceCell.select(withFrame: textReferenceControl.bounds, in: textReferenceControl, editor: textZeroReferenceSelect, delegate: nil, start: 0, length: 0)
        assertRect(textZeroProductionSelect.frame, equals: textZeroReferenceSelect.frame)
        assertRect(textZeroProductionEdit.frame, equals: textZeroProductionSelect.frame)
        XCTAssertEqual(textField.bounds, originalTextBounds)

        textField.textInsets(edges)
        let textEffectiveFrame = effectiveFrame(for: textField.bounds, edges: edges)
        let textPaddedProductionEdit = NSTextView.fieldEditor()
        let textPaddedReferenceEdit = NSTextView.fieldEditor()
        textCell.edit(withFrame: textField.bounds, in: textField, editor: textPaddedProductionEdit, delegate: nil, event: nil)
        textReferenceCell.edit(withFrame: textEffectiveFrame, in: textReferenceControl, editor: textPaddedReferenceEdit, delegate: nil, event: nil)
        assertRect(textPaddedProductionEdit.frame, equals: textPaddedReferenceEdit.frame)
        XCTAssertGreaterThan(textPaddedProductionEdit.frame.width, 0)
        XCTAssertGreaterThan(textPaddedProductionEdit.frame.height, 0)

        let textPaddedProductionSelect = NSTextView.fieldEditor()
        let textPaddedReferenceSelect = NSTextView.fieldEditor()
        textCell.select(withFrame: textField.bounds, in: textField, editor: textPaddedProductionSelect, delegate: nil, start: 0, length: 0)
        textReferenceCell.select(withFrame: textEffectiveFrame, in: textReferenceControl, editor: textPaddedReferenceSelect, delegate: nil, start: 0, length: 0)
        assertRect(textPaddedProductionSelect.frame, equals: textPaddedReferenceSelect.frame)
        assertRect(textPaddedProductionEdit.frame, equals: textPaddedProductionSelect.frame)
        XCTAssertEqual(textZeroProductionEdit.frame.width - textPaddedProductionEdit.frame.width, edges.left + edges.right, accuracy: 0.0001)
        XCTAssertEqual(textZeroProductionEdit.frame.height - textPaddedProductionEdit.frame.height, edges.top + edges.bottom, accuracy: 0.0001)
        XCTAssertEqual(textField.bounds, originalTextBounds)

        let secureField = USecureTextField("Secret")
        secureField.frame = controlFrame
        let secureCell = try! XCTUnwrap(secureField.cell as? NSSecureTextFieldCell)
        secureCell.echosBullets = true
        let secureReferenceControl = NSSecureTextField(frame: controlFrame)
        let secureReferenceCell = nativeSecureReference(from: secureCell)
        secureReferenceControl.cell = secureReferenceCell
        let originalSecureBounds = secureField.bounds
        let secureProductionWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 100), styleMask: [], backing: .buffered, defer: false)
        let secureReferenceWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 100), styleMask: [], backing: .buffered, defer: false)
        secureProductionWindow.contentView?.addSubview(secureField)
        secureReferenceWindow.contentView?.addSubview(secureReferenceControl)
        let secureProductionEditor = try! XCTUnwrap(secureProductionWindow.fieldEditor(true, for: secureField) as? NSTextView)
        let secureReferenceEditor = try! XCTUnwrap(secureReferenceWindow.fieldEditor(true, for: secureReferenceControl) as? NSTextView)

        XCTAssertTrue(secureField.cell is NSSecureTextFieldCell)
        XCTAssertTrue(secureCell.echosBullets)

        secureField.textInsets(zeroInsets)
        secureCell.edit(withFrame: secureField.bounds, in: secureField, editor: secureProductionEditor, delegate: nil, event: nil)
        secureReferenceCell.edit(withFrame: secureReferenceControl.bounds, in: secureReferenceControl, editor: secureReferenceEditor, delegate: nil, event: nil)
        let secureZeroEditFrame = secureProductionEditor.frame
        assertRect(secureZeroEditFrame, equals: secureReferenceEditor.frame)
        XCTAssertGreaterThan(secureZeroEditFrame.width, 0)
        XCTAssertGreaterThan(secureZeroEditFrame.height, 0)

        secureCell.select(withFrame: secureField.bounds, in: secureField, editor: secureProductionEditor, delegate: nil, start: 0, length: 0)
        secureReferenceCell.select(withFrame: secureReferenceControl.bounds, in: secureReferenceControl, editor: secureReferenceEditor, delegate: nil, start: 0, length: 0)
        assertRect(secureProductionEditor.frame, equals: secureReferenceEditor.frame)
        assertRect(secureZeroEditFrame, equals: secureProductionEditor.frame)

        secureField.textInsets(edges)
        let secureEffectiveFrame = effectiveFrame(for: secureField.bounds, edges: edges)
        secureCell.edit(withFrame: secureField.bounds, in: secureField, editor: secureProductionEditor, delegate: nil, event: nil)
        secureReferenceCell.edit(withFrame: secureEffectiveFrame, in: secureReferenceControl, editor: secureReferenceEditor, delegate: nil, event: nil)
        let securePaddedEditFrame = secureProductionEditor.frame
        assertRect(securePaddedEditFrame, equals: secureReferenceEditor.frame)
        XCTAssertGreaterThan(securePaddedEditFrame.width, 0)
        XCTAssertGreaterThan(securePaddedEditFrame.height, 0)

        secureCell.select(withFrame: secureField.bounds, in: secureField, editor: secureProductionEditor, delegate: nil, start: 0, length: 0)
        secureReferenceCell.select(withFrame: secureEffectiveFrame, in: secureReferenceControl, editor: secureReferenceEditor, delegate: nil, start: 0, length: 0)
        assertRect(securePaddedEditFrame, equals: secureProductionEditor.frame)
        assertRect(secureProductionEditor.frame, equals: secureReferenceEditor.frame)
        XCTAssertEqual(secureZeroEditFrame.width - securePaddedEditFrame.width, edges.left + edges.right, accuracy: 0.0001)
        XCTAssertEqual(secureZeroEditFrame.height - securePaddedEditFrame.height, edges.top + edges.bottom, accuracy: 0.0001)
        XCTAssertEqual(secureField.bounds, originalSecureBounds)
        XCTAssertTrue(secureField.cell is NSSecureTextFieldCell)
        XCTAssertTrue(secureCell.echosBullets)
    }
}
#endif
#endif
