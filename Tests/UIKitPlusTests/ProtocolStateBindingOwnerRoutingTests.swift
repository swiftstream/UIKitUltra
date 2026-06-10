import Foundation
import XCTest
@testable import UIKitPlus

#if os(macOS)
import AppKit
private typealias ProbePlatformColor = NSColor
#else
import UIKit
private typealias ProbePlatformColor = UIColor
#endif

private func assertPlatformColor(
    _ actual: ProbePlatformColor?,
    equals expected: UColor,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertEqual(actual, expected.current, file: file, line: line)
}

private func assertFont(
    _ actual: UFont?,
    equals expected: UFont,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertEqual(actual?.fontName, expected.fontName, file: file, line: line)
    guard let actualPointSize = actual?.pointSize else {
        XCTFail("Expected non-nil font pointSize", file: file, line: line)
        return
    }
    XCTAssertEqual(actualPointSize, expected.pointSize, accuracy: 0.0001, file: file, line: line)
}

private class ProtocolProbe:
    _Fontable,
    _Textable,
    _Titleable,
    _Messageable,
    _Placeholderable,
    _BackgroundColorable,
    _Colorable,
    _Tintable
{
    var appliedFont: UFont?
    var appliedText: NSAttributedString?
    var appliedTitle: NSAttributedString?
    var appliedMessage: NSAttributedString?
    var appliedPlaceholder: NSAttributedString?
    var appliedBackground: ProbePlatformColor?
    var appliedColor: ProbePlatformColor?
    var appliedTint: ProbePlatformColor?

    let _backgroundColorState = State<UColor>(wrappedValue: .clear)
    let _colorState = State<UColor>(wrappedValue: .clear)
    let _tintState = State<UColor>(wrappedValue: .clear)

    var _currentText: String { appliedText?.string ?? "" }
    var _statedText: AnyStringBuilder.Handler?
    var _statedTitle: AnyStringBuilder.Handler?
    var _statedMessage: AnyStringBuilder.Handler?
    var _statedPlaceholder: AnyStringBuilder.Handler?

    #if !os(macOS)
    var _textChangeTransition: UIView.AnimationOptions?
    var _titleChangeTransition: UIView.AnimationOptions?
    var _messageChangeTransition: UIView.AnimationOptions?
    var _placeholderChangeTransition: UIView.AnimationOptions?

    @discardableResult
    func textChangeTransition(_ value: UIView.AnimationOptions) -> Self {
        _textChangeTransition = value
        return self
    }
    #endif

    func _setFont(_ v: UFont?) { appliedFont = v }
    func _setText(_ v: NSAttributedString?) { appliedText = v }
    func _setTitle(_ v: NSAttributedString?) { appliedTitle = v }
    func _setMessage(_ v: NSAttributedString?) { appliedMessage = v }
    func _setPlaceholder(_ v: NSAttributedString?) { appliedPlaceholder = v }
    func _setBackgroundColor(_ v: ProbePlatformColor?) { appliedBackground = v }
    func _setColor(_ v: ProbePlatformColor?) { appliedColor = v }
    func _setTint(_ v: ProbePlatformColor?) { appliedTint = v }

    @discardableResult
    func text(_ value: [AnyString]) -> Self {
        _changeText(to: value.attributedString)
        return self
    }

    @discardableResult
    func text(@AnyStringBuilder stateString: @escaping AnyStringBuilder.Handler) -> Self {
        _changeText(to: stateString().attributedString)
        return self
    }
}

private final class OwnedProtocolProbe: ProtocolProbe, _StateBindingOwner {
    let stateBindingHolder = TempStatesHolder()
}

private final class NonOwnedProtocolProbe: ProtocolProbe {}

final class ProtocolStateBindingOwnerRoutingTests: XCTestCase {

    func testOwnedProbeRoutesAllEightProtocolListenersIntoAuthoritativeHolder() {
        let probe = OwnedProtocolProbe()

        let initialFont = UFont.systemFont(ofSize: 12)
        let updatedFont = UFont.boldSystemFont(ofSize: 18)

        let fontState = State<UFont>(wrappedValue: initialFont)
        let textState = State<String>(wrappedValue: "Text A")
        let titleState = State<String>(wrappedValue: "Title A")
        let messageState = State<String>(wrappedValue: "Message A")
        let placeholderState = State<String>(wrappedValue: "Placeholder A")
        let backgroundState = State<UColor>(wrappedValue: .red)
        let colorState = State<UColor>(wrappedValue: .green)
        let tintState = State<UColor>(wrappedValue: .blue)

        probe.font(fontState)
        probe.text(textState)
        probe.title(titleState)
        probe.message(messageState)
        probe.placeholder(placeholderState)
        probe.background(backgroundState)
        probe.color(colorState)
        probe.tint(tintState)

        XCTAssertEqual(probe.stateBindingHolder.statesValues.heldListeners.count, 8)
        assertFont(probe.appliedFont, equals: initialFont)
        XCTAssertEqual(probe.appliedText?.string, "Text A")
        XCTAssertEqual(probe.appliedTitle?.string, "Title A")
        XCTAssertEqual(probe.appliedMessage?.string, "Message A")
        XCTAssertEqual(probe.appliedPlaceholder?.string, "Placeholder A")
        assertPlatformColor(probe.appliedBackground, equals: .red)
        assertPlatformColor(probe.appliedColor, equals: .green)
        assertPlatformColor(probe.appliedTint, equals: .blue)

        fontState.wrappedValue = updatedFont
        textState.wrappedValue = "Text B"
        titleState.wrappedValue = "Title B"
        messageState.wrappedValue = "Message B"
        placeholderState.wrappedValue = "Placeholder B"
        backgroundState.wrappedValue = .yellow
        colorState.wrappedValue = .purple
        tintState.wrappedValue = .cyan

        assertFont(probe.appliedFont, equals: updatedFont)
        XCTAssertEqual(probe.appliedText?.string, "Text B")
        XCTAssertEqual(probe.appliedTitle?.string, "Title B")
        XCTAssertEqual(probe.appliedMessage?.string, "Message B")
        XCTAssertEqual(probe.appliedPlaceholder?.string, "Placeholder B")
        assertPlatformColor(probe.appliedBackground, equals: .yellow)
        assertPlatformColor(probe.appliedColor, equals: .purple)
        assertPlatformColor(probe.appliedTint, equals: .cyan)
    }

    func testOwnedProbeTeardownCancelsOwnedTextTokenAndRepairsTextableCapture() {
        let source = State<String>(wrappedValue: "Initial")
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        source.listen { _ in unrelatedCallCount += 1 }
            .hold(in: unrelatedHolder)

        weak var weakProbe: OwnedProtocolProbe?
        weak var weakToken: StateListener?

        autoreleasepool {
            var probe: OwnedProtocolProbe? = .init()
            weakProbe = probe
            probe?.text(source)

            guard let liveProbe = probe else {
                XCTFail("Expected live probe")
                return
            }

            XCTAssertEqual(liveProbe.stateBindingHolder.statesValues.heldListeners.count, 1)
            let tokens = Array(liveProbe.stateBindingHolder.statesValues.heldListeners.values)
            guard tokens.count == 1, let token = tokens.first else {
                XCTFail("Expected exactly one owned text token")
                return
            }

            weakToken = token
            source.wrappedValue = "Alive"
            XCTAssertEqual(liveProbe.appliedText?.string, "Alive")
            probe = nil
        }

        XCTAssertNil(weakProbe)
        XCTAssertNil(weakToken)

        source.wrappedValue = "After teardown"
        XCTAssertEqual(unrelatedCallCount, 2)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)
    }

    func testOwnedProbeRepeatedBackgroundBindingsRemainAdditiveUntilTeardown() {
        let sourceA = State<UColor>(wrappedValue: .red)
        let sourceB = State<UColor>(wrappedValue: .blue)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedACallCount = 0
        var unrelatedBCallCount = 0

        sourceA.listen { _ in unrelatedACallCount += 1 }.hold(in: unrelatedHolder)
        sourceB.listen { _ in unrelatedBCallCount += 1 }.hold(in: unrelatedHolder)

        weak var weakProbe: OwnedProtocolProbe?
        weak var weakTokenA: StateListener?
        weak var weakTokenB: StateListener?

        autoreleasepool {
            var probe: OwnedProtocolProbe? = .init()
            weakProbe = probe
            probe?.background(sourceA)
            probe?.background(sourceB)

            guard let liveProbe = probe else {
                XCTFail("Expected live probe")
                return
            }

            let tokens = Array(liveProbe.stateBindingHolder.statesValues.heldListeners.values)
            guard tokens.count == 2 else {
                XCTFail("Expected exactly two additive background tokens")
                return
            }

            XCTAssertNotEqual(tokens[0].id, tokens[1].id)
            weakTokenA = tokens[0]
            weakTokenB = tokens[1]

            sourceA.wrappedValue = .green
            assertPlatformColor(liveProbe.appliedBackground, equals: .green)
            sourceB.wrappedValue = .yellow
            assertPlatformColor(liveProbe.appliedBackground, equals: .yellow)
            probe = nil
        }

        XCTAssertNil(weakProbe)
        XCTAssertNil(weakTokenA)
        XCTAssertNil(weakTokenB)

        sourceA.wrappedValue = .purple
        sourceB.wrappedValue = .cyan
        XCTAssertEqual(unrelatedACallCount, 2)
        XCTAssertEqual(unrelatedBCallCount, 2)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 2)
    }

    func testNonOwnedProbePreservesLiveUpdatesForAllEightProtocolFamilies() {
        let probe = NonOwnedProtocolProbe()
        XCTAssertFalse(probe is _StateBindingOwner)

        let initialFont = UFont.systemFont(ofSize: 12)
        let updatedFont = UFont.boldSystemFont(ofSize: 18)
        let fontState = State<UFont>(wrappedValue: initialFont)
        let textState = State<String>(wrappedValue: "Text A")
        let titleState = State<String>(wrappedValue: "Title A")
        let messageState = State<String>(wrappedValue: "Message A")
        let placeholderState = State<String>(wrappedValue: "Placeholder A")
        let backgroundState = State<UColor>(wrappedValue: .red)
        let colorState = State<UColor>(wrappedValue: .green)
        let tintState = State<UColor>(wrappedValue: .blue)

        probe.font(fontState)
        probe.text(textState)
        probe.title(titleState)
        probe.message(messageState)
        probe.placeholder(placeholderState)
        probe.background(backgroundState)
        probe.color(colorState)
        probe.tint(tintState)

        assertFont(probe.appliedFont, equals: initialFont)

        fontState.wrappedValue = updatedFont
        textState.wrappedValue = "Text B"
        titleState.wrappedValue = "Title B"
        messageState.wrappedValue = "Message B"
        placeholderState.wrappedValue = "Placeholder B"
        backgroundState.wrappedValue = .yellow
        colorState.wrappedValue = .purple
        tintState.wrappedValue = .cyan

        assertFont(probe.appliedFont, equals: updatedFont)
        XCTAssertEqual(probe.appliedText?.string, "Text B")
        XCTAssertEqual(probe.appliedTitle?.string, "Title B")
        XCTAssertEqual(probe.appliedMessage?.string, "Message B")
        XCTAssertEqual(probe.appliedPlaceholder?.string, "Placeholder B")
        assertPlatformColor(probe.appliedBackground, equals: .yellow)
        assertPlatformColor(probe.appliedColor, equals: .purple)
        assertPlatformColor(probe.appliedTint, equals: .cyan)
    }

    func testPlainBaseViewControllerTitleBindingRemainsLiveWithoutOwner() {
        let source = State<String>(wrappedValue: "Initial")
        let controller = BaseViewController()
        XCTAssertFalse(controller is _StateBindingOwner)

        controller.title(source)
        XCTAssertEqual(controller.title, "Initial")
        source.wrappedValue = "Updated"
        XCTAssertEqual(controller.title, "Updated")
    }

    func testDeclarativeUViewBackgroundBindingUsesExistingPropertiesHolder() {
        let source = State<UColor>(wrappedValue: .red)
        let view = UView()

        view.background(source)
        XCTAssertEqual(view._properties.stateBindingHolder.statesValues.heldListeners.count, 1)
        assertPlatformColor(view.background.wrappedValue.current, equals: .red)

        source.wrappedValue = .blue
        assertPlatformColor(view.background.wrappedValue.current, equals: .blue)
    }

    #if !os(macOS)
    func testUIKitPlainBaseViewControllerBackgroundBindingRemainsLiveWithoutOwner() {
        let source = State<UColor>(wrappedValue: .red)
        let controller = BaseViewController()
        XCTAssertFalse(controller is _StateBindingOwner)

        controller.background(source)
        XCTAssertEqual(controller.view.backgroundColor, UColor.red)
        source.wrappedValue = .blue
        XCTAssertEqual(controller.view.backgroundColor, UColor.blue)
    }

    func testUIKitPlainUIAlertControllerMessageBindingRemainsLiveWithoutOwner() {
        let source = State<String>(wrappedValue: "Initial")
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        XCTAssertFalse(alert is _StateBindingOwner)

        alert.message(source)
        XCTAssertEqual(alert.message, "Initial")
        source.wrappedValue = "Updated"
        XCTAssertEqual(alert.message, "Updated")
    }

    func testUIKitBaseAppShortcutTitleBindingRemainsLiveWithoutOwner() {
        let source = State<String>(wrappedValue: "Initial")
        let shortcut = BaseApp.Shortcut("com.example.uikitplus.tests")
        XCTAssertFalse(shortcut is _StateBindingOwner)

        shortcut.title(source)
        XCTAssertEqual(shortcut.item.localizedTitle, "Initial")
        source.wrappedValue = "Updated"
        XCTAssertEqual(shortcut.item.localizedTitle, "Updated")
    }

    func testUIKitAlertControllerMessageBindingUsesOwnerHolder() {
        let source = State<String>(wrappedValue: "Initial")
        let alert = AlertController(.alert)

        alert.message(source)
        XCTAssertEqual(alert.stateBindingHolder.statesValues.heldListeners.count, 1)
        XCTAssertEqual(alert.message, "Initial")
        source.wrappedValue = "Updated"
        XCTAssertEqual(alert.message, "Updated")
    }
    #endif

    #if os(macOS)
    func testMacOSMenuItemTitleBindingRemainsLiveWithoutOwner() {
        let source = State<String>(wrappedValue: "Initial")
        let item = MenuItem("Initial")
        XCTAssertFalse(item is _StateBindingOwner)

        item.title(source)
        XCTAssertEqual(item.title, "Initial")
        source.wrappedValue = "Updated"
        XCTAssertEqual(item.title, "Updated")
    }

    func testMacOSTextFieldTintBindingUsesOwnerHolder() {
        let source = State<UColor>(wrappedValue: .red)
        let textField = UTextField()

        textField.tint(source)
        XCTAssertEqual(textField.stateBindingHolder.statesValues.heldListeners.count, 1)
        assertPlatformColor(textField._tintColor, equals: .red)
        source.wrappedValue = .blue
        assertPlatformColor(textField._tintColor, equals: .blue)
    }
    #endif
}
