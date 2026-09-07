#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
import XCTest
@testable import UIKitPlus

@MainActor
private func assertColor(
    _ actual: NSColor?,
    equals expected: NSColor,
    accuracy: CGFloat = 0.0001,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    guard let actual else {
        XCTFail("Expected a color", file: file, line: line)
        return
    }
    guard let actualRGB = actual.usingColorSpace(.deviceRGB),
          let expectedRGB = expected.usingColorSpace(.deviceRGB) else {
        XCTFail("Could not convert colors to device RGB", file: file, line: line)
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
private func ensureUIKitPlusApplication() {
    _ = App.shared
}

@MainActor
final class MacOSTextViewDeclarativeTests: XCTestCase {
    func testAllSupportedInitializersProduceExpectedText() {
        ensureUIKitPlusApplication()
        let stringView = UTextView("string")
        let strings: [AnyString] = ["one", "two"]
        let arrayView = UTextView(strings)
        let localizedView = UTextView(.en("localized"))
        let localizedArrayView = UTextView([.en("localized-array")])
        let state = State<String>(wrappedValue: "state")
        let stateView = UTextView(state)
        let builder: AnyStringBuilder.Handler = { "builder" }
        let builderView = UTextView(stateString: builder)
        let frameView = UTextView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))

        XCTAssertEqual(stringView.stringValue, "string")
        XCTAssertEqual(arrayView.stringValue, "onetwo")
        XCTAssertEqual(localizedView.stringValue, "localized")
        XCTAssertEqual(localizedArrayView.stringValue, "localized-array")
        XCTAssertEqual(stateView.stringValue, "state")
        XCTAssertEqual(builderView.stringValue, "builder")
        XCTAssertEqual(frameView.stringValue, "")
        XCTAssertTrue(stringView.declarativeView === stringView)
        XCTAssertTrue(arrayView.declarativeView === arrayView)
        XCTAssertTrue(localizedView.declarativeView === localizedView)
        XCTAssertTrue(localizedArrayView.declarativeView === localizedArrayView)
        XCTAssertTrue(stateView.declarativeView === stateView)
        XCTAssertTrue(builderView.declarativeView === builderView)
        XCTAssertTrue(frameView.declarativeView === frameView)
    }

    func testStringValueAndTextSetterAreFluentAndPreserveAttributedText() {
        ensureUIKitPlusApplication()
        let view = UTextView("initial")
        var callbackCount = 0
        view.onTextDidChange { callbackCount += 1 }

        let result = view.text("updated")
        XCTAssertTrue(result === view)
        XCTAssertEqual(view.stringValue, "updated")
        XCTAssertEqual(callbackCount, 0)

        let attributed = NSAttributedString(
            string: "styled",
            attributes: [.foregroundColor: NSColor.red]
        )
        _ = view.text(attributed)
        guard let storage = view.textView.textStorage else {
            XCTFail("Expected text storage")
            return
        }
        XCTAssertEqual(storage.string, "styled")
        XCTAssertNotNil(storage.attribute(.foregroundColor, at: 0, effectiveRange: nil))

        view.stringValue = "programmatic"
        XCTAssertEqual(view.stringValue, "programmatic")
        XCTAssertEqual(callbackCount, 0)
    }

    func testStateInitializerRemainsLiveInBothDirections() {
        ensureUIKitPlusApplication()
        let state = State<String>(wrappedValue: "first")
        let view = UTextView(state)

        state.wrappedValue = "second"
        XCTAssertEqual(view.stringValue, "second")

        guard let storage = view.textView.textStorage else {
            XCTFail("Expected text storage")
            return
        }
        storage.setAttributedString(NSAttributedString(string: "third"))
        view.textDidChange(Notification(name: .init("text-change")))

        XCTAssertEqual(state.wrappedValue, "third")
    }

    func testTextBindingListenerRegistrationIsAdditive() {
        ensureUIKitPlusApplication()
        let view = UTextView()
        let first = State<String>(wrappedValue: "first")
        let second = State<String>(wrappedValue: "second")
        _ = view.bind(first)
        _ = view.bind(second)

        guard let storage = view.textView.textStorage else {
            XCTFail("Expected text storage")
            return
        }
        storage.setAttributedString(NSAttributedString(string: "edited"))
        view.textDidChange(Notification(name: .init("text-change")))

        XCTAssertEqual(first.wrappedValue, "edited")
        XCTAssertEqual(second.wrappedValue, "edited")
        XCTAssertEqual(view._properties.textChangeListeners.count, 2)
    }

    func testCoreCapabilityModifiersReturnSameInstanceAndRouteToInnerTextView() {
        ensureUIKitPlusApplication()
        let view = UTextView()
        let font = NSFont.systemFont(ofSize: 17)

        XCTAssertTrue(view.editable(false) === view)
        XCTAssertFalse(view.textView.isEditable)
        XCTAssertTrue(view.enabled(true) === view)
        XCTAssertTrue(view.textView.isEditable)
        XCTAssertTrue(view.font(v: font) === view)
        XCTAssertTrue(view.textView.font == font)
        let colorResult = view.color(Color(NSColor.red))
        XCTAssertTrue(colorResult === view)
        XCTAssertTrue(view.declarativeView === view)
        assertColor(view.textView.textColor, equals: .red)
        XCTAssertTrue(view.alignment(.right) === view)
        XCTAssertEqual(view.textView.alignment, .right)
        let tintResult = view.tint(Color(NSColor.blue))
        XCTAssertTrue(tintResult === view)
        XCTAssertTrue(view.declarativeView === view)
        assertColor(view.textView.insertionPointColor, equals: .blue)
        XCTAssertTrue(view.focusRingType(.exterior) === view)
        XCTAssertEqual(view.textView.focusRingType, .exterior)
    }

    func testTextInsetsOverloadsReturnSameInstanceAndUpdateGeometry() {
        ensureUIKitPlusApplication()
        let view = UTextView("text")
        view.frame = CGRect(x: 0, y: 0, width: 160, height: 80)
        let initialOuterConstraintCount = view.constraints.count
        let initialTextViewConstraintCount = view.textView.constraints.count

        XCTAssertTrue(view.textInsets(NSSize(width: 4, height: 6)) === view)
        XCTAssertTrue(view.textInsets(8) === view)
        XCTAssertTrue(view.textInsets(horizontal: 10, vertical: 12) === view)
        XCTAssertEqual(
            view.constraints.count,
            initialOuterConstraintCount
        )
        XCTAssertEqual(
            view.textView.constraints.count,
            initialTextViewConstraintCount
        )
        XCTAssertEqual(view.textView.textContainerInset, NSSize(width: 10, height: 12))
        view.layout()
        XCTAssertGreaterThanOrEqual(view.intrinsicContentSize.height, 0)
        XCTAssertTrue(view._properties.notAppliedPreConstraintsSolo.isEmpty)
        XCTAssertTrue(view._properties.notAppliedPreConstraintsSuper.isEmpty)
        XCTAssertTrue(view._properties.notAppliedPreConstraintsRelative.isEmpty)
    }

    func testBackgroundModifierUsesClipViewAndKeepsOtherSurfacesTransparent() {
        ensureUIKitPlusApplication()
        let view = UTextView()
        let coloredResult = view.background(Color(NSColor.green))

        XCTAssertTrue(coloredResult === view)
        XCTAssertTrue(view.contentView.drawsBackground)
        assertColor(view.contentView.backgroundColor, equals: .green)
        XCTAssertTrue(view.drawsBackground)
        assertColor(view.backgroundColor, equals: .green)
        XCTAssertFalse(view.textView.drawsBackground)
        assertColor(view.textView.backgroundColor, equals: .clear)

        let clearResult = view.background(.clear)
        XCTAssertTrue(clearResult === view)
        XCTAssertFalse(view.contentView.drawsBackground)
        assertColor(view.contentView.backgroundColor, equals: .clear)
        XCTAssertFalse(view.drawsBackground)
        assertColor(view.backgroundColor, equals: .clear)
        XCTAssertFalse(view.textView.drawsBackground)
        assertColor(view.textView.backgroundColor, equals: .clear)
    }

    func testAutoGrowingClampsHeightAndTogglesVerticalScroller() {
        ensureUIKitPlusApplication()
        let view = UTextView()
            .font(v: NSFont.systemFont(ofSize: 12))
            .textInsets(2)
            .autoGrowing(minHeight: 20, maxHeight: 50)
        view.frame = CGRect(x: 0, y: 0, width: 140, height: 50)
        view.textView.frame.size.width = 140
        view.layout()
        XCTAssertGreaterThanOrEqual(view.intrinsicContentSize.height, 20)

        _ = view.text(String(repeating: "line\n", count: 20))
        view.layout()
        XCTAssertEqual(view.intrinsicContentSize.height, 50, accuracy: 0.5)
        XCTAssertTrue(view.hasVerticalScroller)

        _ = view.text("short")
        view.layout()
        XCTAssertLessThan(view.intrinsicContentSize.height, 50)
        XCTAssertFalse(view.hasVerticalScroller)
    }

    func testDocumentViewAlwaysFillsMinimumVisibleHeight() {
        ensureUIKitPlusApplication()
        let view = UTextView("short")
            .autoGrowing(minHeight: 44, maxHeight: 80)
        view.frame = CGRect(x: 0, y: 0, width: 140, height: 44)
        view.layout()

        XCTAssertGreaterThanOrEqual(
            view.textView.frame.height,
            view.intrinsicContentSize.height
        )
    }

    func testEditingDecisionCallbacksUseReplacementSemantics() {
        ensureUIKitPlusApplication()
        let view = UTextView()
        var replacedBeginCount = 0
        var activeBeginCount = 0
        var activeBeginView: UTextView?
        _ = view.onShouldBeginEditing {
            replacedBeginCount += 1
            return false
        }
        _ = view.onShouldBeginEditing { candidate in
            activeBeginCount += 1
            activeBeginView = candidate
            return true
        }
        XCTAssertTrue(view.textShouldBeginEditing(view.textView))
        XCTAssertEqual(replacedBeginCount, 0)
        XCTAssertEqual(activeBeginCount, 1)
        XCTAssertTrue(activeBeginView === view)

        var replacedEndCount = 0
        var activeEndCount = 0
        _ = view.onShouldEndEditing { (_: UTextView) in
            replacedEndCount += 1
            return false
        }
        _ = view.onShouldEndEditing {
            activeEndCount += 1
            return true
        }
        XCTAssertTrue(view.textShouldEndEditing(view.textView))
        XCTAssertEqual(replacedEndCount, 0)
        XCTAssertEqual(activeEndCount, 1)

        var replacedEmptyChangeCount = 0
        var replacedTypedChangeCount = 0
        var replacedWrapperRangeStringCount = 0
        var finalRangeStringCount = 0
        var finalRange: NSRange?
        var finalReplacement: String?
        let expectedRange = NSRange(location: 2, length: 3)
        let expectedReplacement = "replacement"

        _ = view.onShouldChangeText {
            replacedEmptyChangeCount += 1
            return false
        }
        _ = view.onShouldChangeText { (_: UTextView) in
            replacedTypedChangeCount += 1
            return false
        }
        _ = view.onShouldChangeText { (_: UTextView, _: NSRange, _: String) in
            replacedWrapperRangeStringCount += 1
            return false
        }
        _ = view.onShouldChangeText { range, replacement in
            finalRangeStringCount += 1
            finalRange = range
            finalReplacement = replacement
            return true
        }

        let decision = view.textView(
            view.textView,
            shouldChangeTextIn: expectedRange,
            replacementString: expectedReplacement
        )
        XCTAssertTrue(decision)
        XCTAssertEqual(replacedEmptyChangeCount, 0)
        XCTAssertEqual(replacedTypedChangeCount, 0)
        XCTAssertEqual(replacedWrapperRangeStringCount, 0)
        XCTAssertEqual(finalRangeStringCount, 1)
        XCTAssertEqual(finalRange, expectedRange)
        XCTAssertEqual(finalReplacement, expectedReplacement)
    }

    func testEditingLifecycleCallbacksRouteEmptyAndTypedForms() {
        ensureUIKitPlusApplication()
        let view = UTextView()
        var beginEmpty = 0
        var beginTyped = 0
        var endEmpty = 0
        var endTyped = 0
        var focus = 0
        var unfocus = 0

        _ = view.onDidBeginEditing { beginEmpty += 1 }
        _ = view.onDidBeginEditing { (_: UTextView) in beginTyped += 1 }
        _ = view.onDidEndEditing { endEmpty += 1 }
        _ = view.onDidEndEditing { (_: UTextView) in endTyped += 1 }
        _ = view.onFocus { _ in focus += 1 }
        _ = view.onUnFocus { _ in unfocus += 1 }

        view.textDidBeginEditing(Notification(name: .init("begin")))
        XCTAssertTrue(view.isFirstResponder)
        XCTAssertEqual(beginEmpty, 1)
        XCTAssertEqual(beginTyped, 1)
        XCTAssertEqual(focus, 1)
        XCTAssertEqual(endEmpty, 0)
        XCTAssertEqual(endTyped, 0)
        XCTAssertEqual(unfocus, 0)

        view.textDidEndEditing(Notification(name: .init("end")))

        XCTAssertFalse(view.isFirstResponder)
        XCTAssertEqual(endEmpty, 1)
        XCTAssertEqual(endTyped, 1)
        XCTAssertEqual(unfocus, 1)
        XCTAssertEqual(beginEmpty, 1)
        XCTAssertEqual(beginTyped, 1)
        XCTAssertEqual(focus, 1)
    }

    func testTextChangePipelineUpdatesTypingCallbacksBindingAndGeometryOnce() {
        ensureUIKitPlusApplication()
        let view = UTextView("a")
        view.frame = CGRect(x: 0, y: 0, width: 140, height: 100)
        view.layout()
        let before = view.intrinsicContentSize.height
        let bound = State<String>(wrappedValue: "")
        let typing = State<Bool>(wrappedValue: false)
        let boundListenerHolder = TempStatesHolder()
        var boundMutationCount = 0
        var emptyCount = 0
        var typedCount = 0
        _ = view.bind(bound)
        bound.listen { _, _ in
            boundMutationCount += 1
        }
        .hold(in: boundListenerHolder)
        _ = view.typing(typing)
        _ = view.onTextDidChange { emptyCount += 1 }
        _ = view.onTextDidChange { (_: UTextView) in typedCount += 1 }

        guard let storage = view.textView.textStorage else {
            XCTFail("Expected text storage")
            return
        }
        storage.setAttributedString(NSAttributedString(string: String(repeating: "line\n", count: 8)))
        view.textDidChange(Notification(name: .init("change")))

        XCTAssertTrue(typing.wrappedValue)
        XCTAssertEqual(emptyCount, 1)
        XCTAssertEqual(typedCount, 1)
        XCTAssertEqual(boundMutationCount, 1)
        XCTAssertEqual(bound.wrappedValue, storage.string)
        XCTAssertGreaterThan(view.intrinsicContentSize.height, before)
    }

    func testSelectionCallbacksRouteEmptyAndTypedForms() {
        ensureUIKitPlusApplication()
        let view = UTextView()
        var emptyCount = 0
        var typedCount = 0
        _ = view.onDidChangeSelection { emptyCount += 1 }
        _ = view.onDidChangeSelection { (_: UTextView) in typedCount += 1 }

        view.textViewDidChangeSelection(Notification(name: .init("selection")))

        XCTAssertEqual(emptyCount, 1)
        XCTAssertEqual(typedCount, 1)
    }

    func testOnTextChangedCompatibilityAliasUsesCanonicalTypedSlot() {
        ensureUIKitPlusApplication()
        let view = UTextView()
        var compatibilityCount = 0
        var replacementCount = 0
        _ = view.onTextChanged { _ in compatibilityCount += 1 }

        guard let storage = view.textView.textStorage else {
            XCTFail("Expected text storage")
            return
        }
        storage.setAttributedString(NSAttributedString(string: "one"))
        view.textDidChange(Notification(name: .init("first")))
        XCTAssertEqual(compatibilityCount, 1)

        _ = view.onTextDidChange { (_: UTextView) in replacementCount += 1 }
        storage.setAttributedString(NSAttributedString(string: "two"))
        view.textDidChange(Notification(name: .init("second")))
        XCTAssertEqual(compatibilityCount, 1)
        XCTAssertEqual(replacementCount, 1)
    }

    func testEveryCommandOverloadIsFluent() {
        ensureUIKitPlusApplication()
        let view = UTextView()
        XCTAssertTrue(view.onNewLineAction(pass: false, {}) === view)
        XCTAssertTrue(view.onNewLineAction(pass: false, { (_: UTextView) in }) === view)
        XCTAssertTrue(view.onNewLineAction({ true }) === view)
        XCTAssertTrue(view.onNewLineAction({ (_: UTextView) in true }) === view)
        XCTAssertTrue(view.onCmdEnterAction(pass: false, {}) === view)
        XCTAssertTrue(view.onCmdEnterAction(pass: false, { (_: UTextView) in }) === view)
        XCTAssertTrue(view.onCmdEnterAction({ true }) === view)
        XCTAssertTrue(view.onCmdEnterAction({ (_: UTextView) in true }) === view)
        XCTAssertTrue(view.onOptionEnterAction(pass: false, {}) === view)
        XCTAssertTrue(view.onOptionEnterAction(pass: false, { (_: UTextView) in }) === view)
        XCTAssertTrue(view.onOptionEnterAction({ true }) === view)
        XCTAssertTrue(view.onOptionEnterAction({ (_: UTextView) in true }) === view)
        XCTAssertTrue(view.onShiftEnterAction(pass: false, {}) === view)
        XCTAssertTrue(view.onShiftEnterAction(pass: false, { (_: UTextView) in }) === view)
        XCTAssertTrue(view.onShiftEnterAction({ true }) === view)
        XCTAssertTrue(view.onShiftEnterAction({ (_: UTextView) in true }) === view)
        XCTAssertTrue(view.onDeleteForwardAction(pass: false, {}) === view)
        XCTAssertTrue(view.onDeleteForwardAction(pass: false, { (_: UTextView) in }) === view)
        XCTAssertTrue(view.onDeleteForwardAction({ true }) === view)
        XCTAssertTrue(view.onDeleteForwardAction({ (_: UTextView) in true }) === view)
        XCTAssertTrue(view.onDeleteBackwardAction(pass: false, {}) === view)
        XCTAssertTrue(view.onDeleteBackwardAction(pass: false, { (_: UTextView) in }) === view)
        XCTAssertTrue(view.onDeleteBackwardAction({ true }) === view)
        XCTAssertTrue(view.onDeleteBackwardAction({ (_: UTextView) in true }) === view)
        XCTAssertTrue(view.onInsertTabAction(pass: false, {}) === view)
        XCTAssertTrue(view.onInsertTabAction(pass: false, { (_: UTextView) in }) === view)
        XCTAssertTrue(view.onInsertTabAction({ true }) === view)
        XCTAssertTrue(view.onInsertTabAction({ (_: UTextView) in true }) === view)
        XCTAssertTrue(view.onCancelAction(pass: false, {}) === view)
        XCTAssertTrue(view.onCancelAction(pass: false, { (_: UTextView) in }) === view)
        XCTAssertTrue(view.onCancelAction({ true }) === view)
        XCTAssertTrue(view.onCancelAction({ (_: UTextView) in true }) === view)
    }

    func testPlainNewlinePassSemanticsAndMissingHandlerBehavior() {
        ensureUIKitPlusApplication()
        let view = UTextView()
        let newline = #selector(NSResponder.insertNewline(_:))
        XCTAssertFalse(view.textView(view.textView, doCommandBy: newline))

        var callCount = 0
        _ = view.onNewLineAction(pass: false) { callCount += 1 }
        XCTAssertTrue(view.textView(view.textView, doCommandBy: newline))
        XCTAssertEqual(callCount, 1)

        _ = view.onNewLineAction(pass: true) { callCount += 1 }
        XCTAssertFalse(view.textView(view.textView, doCommandBy: newline))
        XCTAssertEqual(callCount, 2)

        _ = view.onNewLineAction {
            callCount += 1
            return true
        }
        XCTAssertFalse(view.textView(view.textView, doCommandBy: newline))
        XCTAssertEqual(callCount, 3)
        _ = view.onNewLineAction {
            callCount += 1
            return false
        }
        XCTAssertTrue(view.textView(view.textView, doCommandBy: newline))
        XCTAssertEqual(callCount, 4)
    }

    func testModifiedNewlineDispatchUsesExactModifier() {
        ensureUIKitPlusApplication()
        let view = UTextView()
        let newline = #selector(NSResponder.insertNewline(_:))
        var calls: [String] = []
        _ = view.onNewLineAction(pass: false) { calls.append("plain") }
        _ = view.onCmdEnterAction(pass: false) { calls.append("cmd") }
        _ = view.onOptionEnterAction(pass: false) { calls.append("option") }
        _ = view.onShiftEnterAction(pass: false) { calls.append("shift") }

        XCTAssertFalse(view._handleCommand(newline, modifierFlags: [.command, .option]))
        XCTAssertFalse(view._handleCommand(newline, modifierFlags: [.control]))
        XCTAssertTrue(view._handleCommand(newline, modifierFlags: [.command]))
        XCTAssertTrue(view._handleCommand(newline, modifierFlags: [.option]))
        XCTAssertTrue(view._handleCommand(newline, modifierFlags: [.shift]))
        XCTAssertFalse(view._handleCommand(newline, modifierFlags: [.capsLock]))
        XCTAssertEqual(calls, ["cmd", "option", "shift"])
    }

    func testDeleteTabAndCancelHandlersPreservePassSemantics() {
        ensureUIKitPlusApplication()
        let view = UTextView()
        var calls: [String] = []
        let deleteForward = #selector(NSResponder.deleteForward(_:))
        XCTAssertFalse(view.textView(view.textView, doCommandBy: deleteForward))

        _ = view.onDeleteForwardAction(pass: false) { calls.append("forward") }
        _ = view.onDeleteBackwardAction(pass: true) { calls.append("backward") }
        _ = view.onInsertTabAction {
            calls.append("tab")
            return true
        }
        _ = view.onCancelAction {
            calls.append("cancel")
            return false
        }

        XCTAssertTrue(view.textView(view.textView, doCommandBy: deleteForward))
        XCTAssertFalse(view.textView(view.textView, doCommandBy: #selector(NSResponder.deleteBackward(_:))))
        XCTAssertFalse(view.textView(view.textView, doCommandBy: #selector(NSResponder.insertTab(_:))))
        XCTAssertTrue(view.textView(view.textView, doCommandBy: #selector(NSResponder.cancelOperation(_:))))
        XCTAssertEqual(calls, ["forward", "backward", "tab", "cancel"])
    }

    func testCleanupClearsTextAndEmitsCanonicalChangePipelineOnce() {
        ensureUIKitPlusApplication()
        let view = UTextView("content")
        let bound = State<String>(wrappedValue: "content")
        let boundListenerHolder = TempStatesHolder()
        var boundMutationCount = 0
        var callbackCount = 0
        _ = view.bind(bound)
        bound.listen { _, _ in
            boundMutationCount += 1
        }
        .hold(in: boundListenerHolder)
        _ = view.onTextDidChange { callbackCount += 1 }

        _ = view.cleanup()

        XCTAssertEqual(view.stringValue, "")
        XCTAssertEqual(callbackCount, 1)
        XCTAssertEqual(boundMutationCount, 1)
        XCTAssertEqual(bound.wrappedValue, "")
    }

    func testRefreshReevaluatesAnyStringBuilder() {
        ensureUIKitPlusApplication()
        var source = "first"
        let builder: AnyStringBuilder.Handler = { source }
        let view = UTextView(stateString: builder)

        source = "second"
        view.refresh()

        XCTAssertEqual(view.stringValue, "second")
    }

    func testTypingStateBindingUsesOwnerHolderAndRemainsLive() {
        ensureUIKitPlusApplication()
        let view = UTextView()
        let target = State<Bool>(wrappedValue: false)
        let baseline = view.stateBindingHolder.statesValues.heldListeners.count

        _ = view.typing(target)

        XCTAssertEqual(
            view.stateBindingHolder.statesValues.heldListeners.count,
            baseline + 1
        )
        XCTAssertEqual(target.wrappedValue, view._properties.isTyping)

        view._properties.isTypingState.wrappedValue = true
        XCTAssertTrue(target.wrappedValue)
    }
}
#endif
#endif
