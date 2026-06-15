import Foundation
import XCTest
@testable import UIKitPlus

#if os(macOS)
import AppKit
#endif

private class CapabilityProbe:
    _Enableable,
    _Alternateable,
    _Borderedable,
    _Continuousable,
    _FirstResponderRefusable,
    _MultiClickIgnorable,
    _MixedStateAllowable,
    _Secureable,
    _TextAttributesEditingAllowable,
    _TextAdjustsFontSizeable
{
    var appliedEnabled: Bool?
    var appliedAlternate: Bool?
    var appliedBordered: Bool?
    var appliedContinuous: Bool?
    var appliedRefuseFirstResponder: Bool?
    var appliedIgnoreMultiClick: Bool?
    var appliedAllowMixedState: Bool?
    var appliedSecure: Bool?
    var appliedAllowEditingTextAttributes: Bool?
    var appliedAdjustsFontSizeToFitWidth: Bool?

    let _borderedState = State<Bool>(wrappedValue: false)
    let _continuousState = State<Bool>(wrappedValue: false)
    let _refuseFirstResponderState = State<Bool>(wrappedValue: false)
    let _ignoreMultiClickState = State<Bool>(wrappedValue: false)
    let _allowMixedStateState = State<Bool>(wrappedValue: false)

    func _setEnabled(_ v: Bool) { appliedEnabled = v }
    func _setAlternate(_ v: Bool) { appliedAlternate = v }
    func _setBordered(_ v: Bool) { appliedBordered = v }
    func _setContinuous(_ v: Bool) { appliedContinuous = v }
    func _setRefuseFirstResponder(_ v: Bool) { appliedRefuseFirstResponder = v }
    func _setIgnoreMultiClick(_ v: Bool) { appliedIgnoreMultiClick = v }
    func _setAllowMixedState(_ v: Bool) { appliedAllowMixedState = v }
    func _setSecure(_ v: Bool) { appliedSecure = v }
    func _setAllowEditingTextAttributes(_ v: Bool) { appliedAllowEditingTextAttributes = v }
    func _setAdjustsFontSizeToFitWidth(_ v: Bool) { appliedAdjustsFontSizeToFitWidth = v }
}

private final class OwnedCapabilityProbe: CapabilityProbe, _StateBindingOwner {
    let stateBindingHolder = TempStatesHolder()
}

private final class NonOwnedCapabilityProbe: CapabilityProbe {}

#if os(macOS)
private class MacOSCapabilityProbe:
    _Bezeledable,
    _Editableable,
    _ArrowPositionable,
    _FocusRingTypeable,
    _Soundable,
    _PullsDownable,
    _Keyable,
    _KeyMaskable
{
    var appliedBezeled: Bool?
    var appliedEditable: Bool?
    var appliedArrowPosition: NSPopUpButton.ArrowPosition?
    var appliedFocusRingType: NSFocusRingType?
    var appliedSound: NSSound?
    var appliedPullsDown: Bool?
    var appliedKey: String?
    var appliedKeyMask: NSEvent.ModifierFlags?

    func _setBezeled(_ v: Bool) { appliedBezeled = v }
    func _setEditable(_ v: Bool) { appliedEditable = v }
    func _setArrowPosition(_ v: NSPopUpButton.ArrowPosition) { appliedArrowPosition = v }
    func _setFocusRingType(_ v: NSFocusRingType) { appliedFocusRingType = v }
    func _setSound(_ v: NSSound?) { appliedSound = v }
    func _setPullsDown(_ v: Bool) { appliedPullsDown = v }
    func _setKey(_ v: String) { appliedKey = v }
    func _setKeyMask(_ v: NSEvent.ModifierFlags) { appliedKeyMask = v }
}

private final class OwnedMacOSCapabilityProbe: MacOSCapabilityProbe, _StateBindingOwner {
    let stateBindingHolder = TempStatesHolder()
}

private final class NonOwnedMacOSCapabilityProbe: MacOSCapabilityProbe {}
#endif

final class CapabilityProtocolStateBindingOwnerRoutingTests: XCTestCase {

    @MainActor
    func testOwnedProbeRoutesAllTenCrossPlatformCapabilityListenersIntoHolder() {
        let probe = OwnedCapabilityProbe()

        let enabledSource = State<Bool>(wrappedValue: true)
        let alternateSource = State<Bool>(wrappedValue: false)
        let borderedSource = State<Bool>(wrappedValue: true)
        let continuousSource = State<Bool>(wrappedValue: false)
        let refuseFirstResponderSource = State<Bool>(wrappedValue: true)
        let ignoreMultiClickSource = State<Bool>(wrappedValue: false)
        let allowMixedStateSource = State<Bool>(wrappedValue: true)
        let secureSource = State<Bool>(wrappedValue: false)
        let allowEditingTextAttributesSource = State<Bool>(wrappedValue: true)
        let adjustsFontSizeToFitWidthSource = State<Bool>(wrappedValue: false)

        probe.enabled(enabledSource)
        probe.alternate(alternateSource)
        probe.bordered(borderedSource)
        probe.continuous(continuousSource)
        probe.refuseFirstResponder(refuseFirstResponderSource)
        probe.ignoreMultiClick(ignoreMultiClickSource)
        probe.allowMixedState(allowMixedStateSource)
        probe.secure(secureSource)
        probe.allowEditingTextAttributes(allowEditingTextAttributesSource)
        probe.adjustsFontSizeToFitWidth(adjustsFontSizeToFitWidthSource)

        XCTAssertEqual(probe.stateBindingHolder.statesValues.heldListeners.count, 10)
        XCTAssertEqual(probe.appliedEnabled, true)
        XCTAssertEqual(probe.appliedAlternate, false)
        XCTAssertEqual(probe.appliedBordered, true)
        XCTAssertEqual(probe.appliedContinuous, false)
        XCTAssertEqual(probe.appliedRefuseFirstResponder, true)
        XCTAssertEqual(probe.appliedIgnoreMultiClick, false)
        XCTAssertEqual(probe.appliedAllowMixedState, true)
        XCTAssertEqual(probe.appliedSecure, false)
        XCTAssertEqual(probe.appliedAllowEditingTextAttributes, true)
        XCTAssertEqual(probe.appliedAdjustsFontSizeToFitWidth, false)

        enabledSource.wrappedValue = false
        alternateSource.wrappedValue = true
        borderedSource.wrappedValue = false
        continuousSource.wrappedValue = true
        refuseFirstResponderSource.wrappedValue = false
        ignoreMultiClickSource.wrappedValue = true
        allowMixedStateSource.wrappedValue = false
        secureSource.wrappedValue = true
        allowEditingTextAttributesSource.wrappedValue = false
        adjustsFontSizeToFitWidthSource.wrappedValue = true

        XCTAssertEqual(probe.appliedEnabled, false)
        XCTAssertEqual(probe.appliedAlternate, true)
        XCTAssertEqual(probe.appliedBordered, false)
        XCTAssertEqual(probe.appliedContinuous, true)
        XCTAssertEqual(probe.appliedRefuseFirstResponder, false)
        XCTAssertEqual(probe.appliedIgnoreMultiClick, true)
        XCTAssertEqual(probe.appliedAllowMixedState, false)
        XCTAssertEqual(probe.appliedSecure, true)
        XCTAssertEqual(probe.appliedAllowEditingTextAttributes, false)
        XCTAssertEqual(probe.appliedAdjustsFontSizeToFitWidth, true)
    }

    @MainActor
    func testNonOwnedProbePreservesLiveUpdatesForAllTenCrossPlatformCapabilities() {
        let probe = NonOwnedCapabilityProbe()
        XCTAssertFalse(probe is _StateBindingOwner)

        let enabledSource = State<Bool>(wrappedValue: true)
        let alternateSource = State<Bool>(wrappedValue: false)
        let borderedSource = State<Bool>(wrappedValue: true)
        let continuousSource = State<Bool>(wrappedValue: false)
        let refuseFirstResponderSource = State<Bool>(wrappedValue: true)
        let ignoreMultiClickSource = State<Bool>(wrappedValue: false)
        let allowMixedStateSource = State<Bool>(wrappedValue: true)
        let secureSource = State<Bool>(wrappedValue: false)
        let allowEditingTextAttributesSource = State<Bool>(wrappedValue: true)
        let adjustsFontSizeToFitWidthSource = State<Bool>(wrappedValue: false)

        probe.enabled(enabledSource)
        probe.alternate(alternateSource)
        probe.bordered(borderedSource)
        probe.continuous(continuousSource)
        probe.refuseFirstResponder(refuseFirstResponderSource)
        probe.ignoreMultiClick(ignoreMultiClickSource)
        probe.allowMixedState(allowMixedStateSource)
        probe.secure(secureSource)
        probe.allowEditingTextAttributes(allowEditingTextAttributesSource)
        probe.adjustsFontSizeToFitWidth(adjustsFontSizeToFitWidthSource)

        enabledSource.wrappedValue = false
        alternateSource.wrappedValue = true
        borderedSource.wrappedValue = false
        continuousSource.wrappedValue = true
        refuseFirstResponderSource.wrappedValue = false
        ignoreMultiClickSource.wrappedValue = true
        allowMixedStateSource.wrappedValue = false
        secureSource.wrappedValue = true
        allowEditingTextAttributesSource.wrappedValue = false
        adjustsFontSizeToFitWidthSource.wrappedValue = true

        XCTAssertEqual(probe.appliedEnabled, false)
        XCTAssertEqual(probe.appliedAlternate, true)
        XCTAssertEqual(probe.appliedBordered, false)
        XCTAssertEqual(probe.appliedContinuous, true)
        XCTAssertEqual(probe.appliedRefuseFirstResponder, false)
        XCTAssertEqual(probe.appliedIgnoreMultiClick, true)
        XCTAssertEqual(probe.appliedAllowMixedState, false)
        XCTAssertEqual(probe.appliedSecure, true)
        XCTAssertEqual(probe.appliedAllowEditingTextAttributes, false)
        XCTAssertEqual(probe.appliedAdjustsFontSizeToFitWidth, true)
    }

    @MainActor
    func testOwnedProbeTeardownCancelsCrossPlatformTokensAndReleasesReceiver() {
        let enabledSource = State<Bool>(wrappedValue: true)
        let borderedSource = State<Bool>(wrappedValue: false)
        let secureSource = State<Bool>(wrappedValue: true)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        enabledSource.listen { _ in unrelatedCallCount += 1 }
            .hold(in: unrelatedHolder)

        weak var weakProbe: OwnedCapabilityProbe?
        weak var weakEnabledToken: StateListener?
        weak var weakBorderedToken: StateListener?
        weak var weakSecureToken: StateListener?

        autoreleasepool {
            var probe: OwnedCapabilityProbe? = .init()
            weakProbe = probe
            probe?.enabled(enabledSource)
            probe?.bordered(borderedSource)
            probe?.secure(secureSource)

            guard let liveProbe = probe else {
                XCTFail("Expected live probe")
                return
            }

            XCTAssertEqual(liveProbe.stateBindingHolder.statesValues.heldListeners.count, 3)
            let tokens = Array(liveProbe.stateBindingHolder.statesValues.heldListeners.values)
            guard tokens.count == 3 else {
                XCTFail("Expected exactly three owned tokens")
                return
            }

            weakEnabledToken = tokens[0]
            weakBorderedToken = tokens[1]
            weakSecureToken = tokens[2]
            enabledSource.wrappedValue = false
            XCTAssertEqual(liveProbe.appliedEnabled, false)
            probe = nil
        }

        XCTAssertNil(weakProbe)
        XCTAssertNil(weakEnabledToken)
        XCTAssertNil(weakBorderedToken)
        XCTAssertNil(weakSecureToken)

        enabledSource.wrappedValue = true
        borderedSource.wrappedValue = true
        secureSource.wrappedValue = false
        XCTAssertEqual(unrelatedCallCount, 2)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)
    }

    @MainActor
    func testOwnedProbeRepeatedCrossPlatformBindingsRemainAdditiveUntilTeardown() {
        let sourceA = State<Bool>(wrappedValue: true)
        let sourceB = State<Bool>(wrappedValue: false)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedACallCount = 0
        var unrelatedBCallCount = 0

        sourceA.listen { _ in unrelatedACallCount += 1 }.hold(in: unrelatedHolder)
        sourceB.listen { _ in unrelatedBCallCount += 1 }.hold(in: unrelatedHolder)

        weak var weakProbe: OwnedCapabilityProbe?
        weak var weakTokenA: StateListener?
        weak var weakTokenB: StateListener?

        autoreleasepool {
            var probe: OwnedCapabilityProbe? = .init()
            weakProbe = probe
            probe?.enabled(sourceA)
            probe?.enabled(sourceB)

            guard let liveProbe = probe else {
                XCTFail("Expected live probe")
                return
            }

            let tokens = Array(liveProbe.stateBindingHolder.statesValues.heldListeners.values)
            guard tokens.count == 2 else {
                XCTFail("Expected exactly two additive enabled tokens")
                return
            }

            XCTAssertNotEqual(tokens[0].id, tokens[1].id)
            weakTokenA = tokens[0]
            weakTokenB = tokens[1]

            sourceA.wrappedValue = false
            XCTAssertEqual(liveProbe.appliedEnabled, false)
            sourceB.wrappedValue = true
            XCTAssertEqual(liveProbe.appliedEnabled, true)
            probe = nil
        }

        XCTAssertNil(weakProbe)
        XCTAssertNil(weakTokenA)
        XCTAssertNil(weakTokenB)

        sourceA.wrappedValue = false
        sourceB.wrappedValue = false
        XCTAssertEqual(unrelatedACallCount, 2)
        XCTAssertEqual(unrelatedBCallCount, 2)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 2)
    }

    #if !os(macOS)
    @MainActor
    func testNonOwnedUIAlertActionEnabledBindingRemainsLiveWithoutOwner() {
        let source = State<Bool>(wrappedValue: true)
        let action = UIAlertAction(title: "Test", style: .default)
        XCTAssertFalse(action is _StateBindingOwner)

        action.enabled(source)
        XCTAssertEqual(action.isEnabled, true)
        source.wrappedValue = false
        XCTAssertEqual(action.isEnabled, false)
    }
    #endif

    #if os(macOS)
    @MainActor
    func testMacOSOwnedProbeRoutesAllEightMacOSCapabilityListenersIntoHolder() {
        let probe = OwnedMacOSCapabilityProbe()

        let bezeledSource = State<Bool>(wrappedValue: true)
        let editableSource = State<Bool>(wrappedValue: false)
        let arrowPositionSource = State<NSPopUpButton.ArrowPosition>(wrappedValue: .noArrow)
        let focusRingTypeSource = State<NSFocusRingType>(wrappedValue: .default)
        let soundSource = State<NSSound?>(wrappedValue: nil)
        let pullsDownSource = State<Bool>(wrappedValue: true)
        let keySource = State<String>(wrappedValue: "a")
        let keyMaskSource = State<NSEvent.ModifierFlags>(wrappedValue: .command)

        guard let updatedSound = NSSound.basso ?? NSSound.glass ?? NSSound.ping else {
            XCTFail("Expected at least one bundled macOS system sound")
            return
        }

        probe.bezeled(bezeledSource)
        probe.editable(editableSource)
        probe.arrowPosition(arrowPositionSource)
        probe.focusRingType(focusRingTypeSource)
        probe.sound(soundSource)
        probe.pullsDown(pullsDownSource)
        probe.key(keySource)
        probe.keyMask(keyMaskSource)

        XCTAssertEqual(probe.stateBindingHolder.statesValues.heldListeners.count, 8)
        XCTAssertEqual(probe.appliedBezeled, true)
        XCTAssertEqual(probe.appliedEditable, false)
        XCTAssertEqual(probe.appliedArrowPosition, .noArrow)
        XCTAssertEqual(probe.appliedFocusRingType, .default)
        XCTAssertNil(probe.appliedSound)
        XCTAssertEqual(probe.appliedPullsDown, true)
        XCTAssertEqual(probe.appliedKey, "a")
        XCTAssertEqual(probe.appliedKeyMask, .command)

        bezeledSource.wrappedValue = false
        editableSource.wrappedValue = true
        arrowPositionSource.wrappedValue = .arrowAtCenter
        focusRingTypeSource.wrappedValue = NSFocusRingType(rawValue: 1)!
        soundSource.wrappedValue = updatedSound
        pullsDownSource.wrappedValue = false
        keySource.wrappedValue = "b"
        keyMaskSource.wrappedValue = .option

        XCTAssertEqual(probe.appliedBezeled, false)
        XCTAssertEqual(probe.appliedEditable, true)
        XCTAssertEqual(probe.appliedArrowPosition, .arrowAtCenter)
        XCTAssertEqual(probe.appliedFocusRingType, NSFocusRingType(rawValue: 1)!)
        XCTAssertIdentical(probe.appliedSound, updatedSound)
        XCTAssertEqual(probe.appliedPullsDown, false)
        XCTAssertEqual(probe.appliedKey, "b")
        XCTAssertEqual(probe.appliedKeyMask, .option)
    }

    @MainActor
    func testMacOSNonOwnedProbePreservesLiveUpdatesForAllEightMacOSCapabilities() {
        let probe = NonOwnedMacOSCapabilityProbe()
        XCTAssertFalse(probe is _StateBindingOwner)

        let bezeledSource = State<Bool>(wrappedValue: true)
        let editableSource = State<Bool>(wrappedValue: false)
        let arrowPositionSource = State<NSPopUpButton.ArrowPosition>(wrappedValue: .noArrow)
        let focusRingTypeSource = State<NSFocusRingType>(wrappedValue: .default)
        let soundSource = State<NSSound?>(wrappedValue: nil)
        let pullsDownSource = State<Bool>(wrappedValue: true)
        let keySource = State<String>(wrappedValue: "a")
        let keyMaskSource = State<NSEvent.ModifierFlags>(wrappedValue: .command)

        guard let updatedSound = NSSound.basso ?? NSSound.glass ?? NSSound.ping else {
            XCTFail("Expected at least one bundled macOS system sound")
            return
        }

        probe.bezeled(bezeledSource)
        probe.editable(editableSource)
        probe.arrowPosition(arrowPositionSource)
        probe.focusRingType(focusRingTypeSource)
        probe.sound(soundSource)
        probe.pullsDown(pullsDownSource)
        probe.key(keySource)
        probe.keyMask(keyMaskSource)

        bezeledSource.wrappedValue = false
        editableSource.wrappedValue = true
        arrowPositionSource.wrappedValue = .arrowAtCenter
        focusRingTypeSource.wrappedValue = NSFocusRingType(rawValue: 1)!
        soundSource.wrappedValue = updatedSound
        pullsDownSource.wrappedValue = false
        keySource.wrappedValue = "b"
        keyMaskSource.wrappedValue = .option

        XCTAssertEqual(probe.appliedBezeled, false)
        XCTAssertEqual(probe.appliedEditable, true)
        XCTAssertEqual(probe.appliedArrowPosition, .arrowAtCenter)
        XCTAssertEqual(probe.appliedFocusRingType, NSFocusRingType(rawValue: 1)!)
        XCTAssertIdentical(probe.appliedSound, updatedSound)
        XCTAssertEqual(probe.appliedPullsDown, false)
        XCTAssertEqual(probe.appliedKey, "b")
        XCTAssertEqual(probe.appliedKeyMask, .option)
    }

    @MainActor
    func testMacOSMenuItemCapabilityBindingsRemainLiveWithoutOwner() {
        let enabledSource = State<Bool>(wrappedValue: true)
        let alternateSource = State<Bool>(wrappedValue: false)
        let keySource = State<String>(wrappedValue: "a")
        let keyMaskSource = State<NSEvent.ModifierFlags>(wrappedValue: .command)

        let item = MenuItem("Test")
        XCTAssertFalse(item is _StateBindingOwner)

        item.enabled(enabledSource)
        item.alternate(alternateSource)
        item.key(keySource)
        item.keyMask(keyMaskSource)

        XCTAssertEqual(item.item.isEnabled, true)
        XCTAssertEqual(item.item.isAlternate, false)
        XCTAssertEqual(item.item.keyEquivalent, "a")
        XCTAssertEqual(item.item.keyEquivalentModifierMask, .command)

        enabledSource.wrappedValue = false
        alternateSource.wrappedValue = true
        keySource.wrappedValue = "b"
        keyMaskSource.wrappedValue = .option

        XCTAssertEqual(item.item.isEnabled, false)
        XCTAssertEqual(item.item.isAlternate, true)
        XCTAssertEqual(item.item.keyEquivalent, "b")
        XCTAssertEqual(item.item.keyEquivalentModifierMask, .option)
    }

    @MainActor
    func testMacOSUButtonCapabilityBindingsUseOwnerHolder() {
        let button = UButton("Test")
        let baselineCount = button
            .stateBindingHolder
            .statesValues
            .heldListeners
            .count

        let enabledSource = State<Bool>(wrappedValue: true)
        let borderedSource = State<Bool>(wrappedValue: false)
        let keySource = State<String>(wrappedValue: "a")
        let keyMaskSource = State<NSEvent.ModifierFlags>(wrappedValue: .command)

        button.enabled(enabledSource)
        button.bordered(borderedSource)
        button.key(keySource)
        button.keyMask(keyMaskSource)

        XCTAssertEqual(
            button.stateBindingHolder.statesValues.heldListeners.count,
            baselineCount + 4
        )

        enabledSource.wrappedValue = false
        borderedSource.wrappedValue = true
        keySource.wrappedValue = "b"
        keyMaskSource.wrappedValue = .option

        XCTAssertEqual(button.isEnabled, false)
        XCTAssertEqual(button.isBordered, true)
        XCTAssertEqual(button.keyEquivalent, "b")
        XCTAssertEqual(button.keyEquivalentModifierMask, .option)
    }

    @MainActor
    func testMacOSOwnedProbeScalarSettersRemainListenerFree() {
        let probe = OwnedMacOSCapabilityProbe()

        probe.bezeled(true)
        probe.editable(true)
        probe.arrowPosition(.arrowAtCenter)
        probe.focusRingType(.default)
        probe.sound(NSSound.basso ?? NSSound.glass ?? NSSound.ping)
        probe.pullsDown(true)
        probe.key("a")
        probe.keyMask(.command)

        XCTAssertEqual(
            probe.stateBindingHolder.statesValues.heldListeners.count,
            0
        )
    }
    #endif

    @MainActor
    func testOwnedProbeCrossPlatformScalarSettersRemainListenerFree() {
        let probe = OwnedCapabilityProbe()

        probe.enabled(true)
        probe.alternate(true)
        probe.bordered(true)
        probe.continuous(true)
        probe.refuseFirstResponder(true)
        probe.ignoreMultiClick(true)
        probe.allowMixedState(true)
        probe.secure(true)
        probe.allowEditingTextAttributes(true)
        probe.adjustsFontSizeToFitWidth(true)

        XCTAssertEqual(
            probe.stateBindingHolder.statesValues.heldListeners.count,
            0
        )
    }
}
