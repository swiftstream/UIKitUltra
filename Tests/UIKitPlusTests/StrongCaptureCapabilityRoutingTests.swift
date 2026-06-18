import Foundation
import XCTest
@testable import UIKitPlus

#if os(macOS)
import AppKit
#endif

private final class StrongCaptureBoolRecorder {
    var value: Bool?

    init(_ value: Bool? = nil) {
        self.value = value
    }
}

private class HiddenableProbe: _Hiddenable {
    let _hiddenState = State<Bool>(wrappedValue: false)
    private(set) var appliedHidden: Bool?

    func _setHidden(_ v: Bool) {
        appliedHidden = v
    }
}

private final class OwnedHiddenableProbe:
    HiddenableProbe,
    _StateBindingOwner
{
    let stateBindingHolder = TempStatesHolder()
}

private final class NonOwnedHiddenableProbe: HiddenableProbe {}

private struct ValueHiddenableProbe: Hiddenable {
    let recorder: StrongCaptureBoolRecorder

    @discardableResult
    func hidden(_ value: Bool) -> Self {
        recorder.value = value
        return self
    }
}

private class BulletsEchoableProbe: _BulletsEchoable {
    private(set) var appliedEchosBullets: Bool?

    func _setEchosBullets(_ v: Bool) {
        appliedEchosBullets = v
    }
}

private final class OwnedBulletsEchoableProbe:
    BulletsEchoableProbe,
    _StateBindingOwner
{
    let stateBindingHolder = TempStatesHolder()
}

private final class NonOwnedBulletsEchoableProbe: BulletsEchoableProbe {}

private struct ValueBulletsEchoableProbe: BulletsEchoable {
    let recorder: StrongCaptureBoolRecorder

    @discardableResult
    func echosBullets(_ value: Bool) -> Self {
        recorder.value = value
        return self
    }
}

@MainActor
final class StrongCaptureCapabilityRoutingTests: XCTestCase {

    @MainActor
    func testOwnedHiddenableProbeRoutesIntoHolderAndReleasesOnTeardown() {
        let source = State<Bool>(wrappedValue: false)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        source.listen { _ in unrelatedCallCount += 1 }
            .hold(in: unrelatedHolder)

        weak var weakProbe: OwnedHiddenableProbe?
        weak var weakOwnedToken: StateListener?

        autoreleasepool {
            var probe: OwnedHiddenableProbe? = .init()
            weakProbe = probe
            probe?.hidden(source)

            guard let liveProbe = probe else {
                XCTFail("Expected live probe")
                return
            }

            XCTAssertEqual(liveProbe.stateBindingHolder.statesValues.heldListeners.count, 1)
            let tokens = Array(liveProbe.stateBindingHolder.statesValues.heldListeners.values)
            guard tokens.count == 1, let token = tokens.first else {
                XCTFail("Expected exactly one owned token")
                return
            }

            weakOwnedToken = token
            source.wrappedValue = true
            XCTAssertEqual(liveProbe.appliedHidden, true)
            probe = nil
        }

        XCTAssertNil(weakProbe)
        XCTAssertNil(weakOwnedToken)

        source.wrappedValue = false
        XCTAssertEqual(unrelatedCallCount, 2)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)
    }

    @MainActor
    func testOwnedHiddenableProbeRepeatedBindingsRemainAdditiveUntilTeardown() {
        let sourceA = State<Bool>(wrappedValue: false)
        let sourceB = State<Bool>(wrappedValue: true)

        weak var weakProbe: OwnedHiddenableProbe?
        weak var weakTokenA: StateListener?
        weak var weakTokenB: StateListener?

        autoreleasepool {
            var probe: OwnedHiddenableProbe? = .init()
            weakProbe = probe
            probe?.hidden(sourceA)
            probe?.hidden(sourceB)

            guard let liveProbe = probe else {
                XCTFail("Expected live probe")
                return
            }

            let tokens = Array(liveProbe.stateBindingHolder.statesValues.heldListeners.values)
            guard tokens.count == 2 else {
                XCTFail("Expected exactly two additive tokens")
                return
            }

            XCTAssertNotEqual(tokens[0].id, tokens[1].id)
            weakTokenA = tokens[0]
            weakTokenB = tokens[1]
            sourceA.wrappedValue = true
            XCTAssertEqual(liveProbe.appliedHidden, true)
            sourceB.wrappedValue = false
            XCTAssertEqual(liveProbe.appliedHidden, false)
            probe = nil
        }

        XCTAssertNil(weakProbe)
        XCTAssertNil(weakTokenA)
        XCTAssertNil(weakTokenB)
    }

    @MainActor
    func testNonOwnedHiddenableProbePreservesHistoricalLiveUpdateFallback() {
        let source = State<Bool>(wrappedValue: false)

        weak var weakProbe: NonOwnedHiddenableProbe?

        autoreleasepool {
            var probe: NonOwnedHiddenableProbe? = .init()
            weakProbe = probe

            guard let liveProbe = probe else {
                XCTFail("Expected live probe")
                return
            }

            XCTAssertFalse(liveProbe is _StateBindingOwner)

            liveProbe.hidden(source)

            source.wrappedValue = true
            XCTAssertEqual(liveProbe.appliedHidden, true)

            probe = nil
        }

        guard let retainedProbe = weakProbe else {
            XCTFail("Expected historical non-owner fallback to retain receiver")
            return
        }

        source.wrappedValue = false
        XCTAssertEqual(retainedProbe.appliedHidden, false)
    }

    @MainActor
    func testValueTypeHiddenableProbePreservesSourceCompatibility() {
        let recorder = StrongCaptureBoolRecorder()
        let probe = ValueHiddenableProbe(recorder: recorder)
        let source = State<Bool>(wrappedValue: false)

        probe.hidden(source)

        XCTAssertEqual(recorder.value, false)
        source.wrappedValue = true
        XCTAssertEqual(recorder.value, true)
    }

    @MainActor
    func testOwnedHiddenableProbeScalarSetterRemainsListenerFree() {
        let probe = OwnedHiddenableProbe()

        probe.hidden(true)

        XCTAssertEqual(probe.appliedHidden, true)
        XCTAssertEqual(probe.stateBindingHolder.statesValues.heldListeners.count, 0)
    }

    @MainActor
    func testOwnedBulletsEchoableProbeRoutesIntoHolderAndReleasesOnTeardown() {
        let source = State<Bool>(wrappedValue: false)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        source.listen { _ in unrelatedCallCount += 1 }
            .hold(in: unrelatedHolder)

        weak var weakProbe: OwnedBulletsEchoableProbe?
        weak var weakOwnedToken: StateListener?

        autoreleasepool {
            var probe: OwnedBulletsEchoableProbe? = .init()
            weakProbe = probe
            probe?.echosBullets(source)

            guard let liveProbe = probe else {
                XCTFail("Expected live probe")
                return
            }

            XCTAssertEqual(liveProbe.stateBindingHolder.statesValues.heldListeners.count, 1)
            let tokens = Array(liveProbe.stateBindingHolder.statesValues.heldListeners.values)
            guard tokens.count == 1, let token = tokens.first else {
                XCTFail("Expected exactly one owned token")
                return
            }

            weakOwnedToken = token
            source.wrappedValue = true
            XCTAssertEqual(liveProbe.appliedEchosBullets, true)
            probe = nil
        }

        XCTAssertNil(weakProbe)
        XCTAssertNil(weakOwnedToken)

        source.wrappedValue = false
        XCTAssertEqual(unrelatedCallCount, 2)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)
    }

    @MainActor
    func testOwnedBulletsEchoableProbeRepeatedBindingsRemainAdditiveUntilTeardown() {
        let sourceA = State<Bool>(wrappedValue: false)
        let sourceB = State<Bool>(wrappedValue: true)

        weak var weakProbe: OwnedBulletsEchoableProbe?
        weak var weakTokenA: StateListener?
        weak var weakTokenB: StateListener?

        autoreleasepool {
            var probe: OwnedBulletsEchoableProbe? = .init()
            weakProbe = probe
            probe?.echosBullets(sourceA)
            probe?.echosBullets(sourceB)

            guard let liveProbe = probe else {
                XCTFail("Expected live probe")
                return
            }

            let tokens = Array(liveProbe.stateBindingHolder.statesValues.heldListeners.values)
            guard tokens.count == 2 else {
                XCTFail("Expected exactly two additive tokens")
                return
            }

            XCTAssertNotEqual(tokens[0].id, tokens[1].id)
            weakTokenA = tokens[0]
            weakTokenB = tokens[1]
            sourceA.wrappedValue = true
            XCTAssertEqual(liveProbe.appliedEchosBullets, true)
            sourceB.wrappedValue = false
            XCTAssertEqual(liveProbe.appliedEchosBullets, false)
            probe = nil
        }

        XCTAssertNil(weakProbe)
        XCTAssertNil(weakTokenA)
        XCTAssertNil(weakTokenB)
    }

    @MainActor
    func testNonOwnedBulletsEchoableProbePreservesHistoricalLiveUpdateFallback() {
        let source = State<Bool>(wrappedValue: false)

        weak var weakProbe: NonOwnedBulletsEchoableProbe?

        autoreleasepool {
            var probe: NonOwnedBulletsEchoableProbe? = .init()
            weakProbe = probe

            guard let liveProbe = probe else {
                XCTFail("Expected live probe")
                return
            }

            XCTAssertFalse(liveProbe is _StateBindingOwner)

            liveProbe.echosBullets(source)

            source.wrappedValue = true
            XCTAssertEqual(liveProbe.appliedEchosBullets, true)

            probe = nil
        }

        guard let retainedProbe = weakProbe else {
            XCTFail("Expected historical non-owner fallback to retain receiver")
            return
        }

        source.wrappedValue = false
        XCTAssertEqual(retainedProbe.appliedEchosBullets, false)
    }

    @MainActor
    func testValueTypeBulletsEchoableProbePreservesSourceCompatibility() {
        let recorder = StrongCaptureBoolRecorder()
        let probe = ValueBulletsEchoableProbe(recorder: recorder)
        let source = State<Bool>(wrappedValue: false)

        probe.echosBullets(source)

        XCTAssertEqual(recorder.value, false)
        source.wrappedValue = true
        XCTAssertEqual(recorder.value, true)
    }

    @MainActor
    func testOwnedBulletsEchoableProbeScalarSetterRemainsListenerFree() {
        let probe = OwnedBulletsEchoableProbe()

        probe.echosBullets(true)

        XCTAssertEqual(probe.appliedEchosBullets, true)
        XCTAssertEqual(probe.stateBindingHolder.statesValues.heldListeners.count, 0)
    }

    #if os(macOS)
    @MainActor
    func testStatusItemHiddenBindingRoutesIntoOwnerHolder() {
        let source = State<Bool>(wrappedValue: false)
        let statusItem = StatusItem()
        let baselineCount = statusItem
            .stateBindingHolder
            .statesValues
            .heldListeners
            .count

        statusItem.hidden(source)

        XCTAssertEqual(
            statusItem.stateBindingHolder.statesValues.heldListeners.count,
            baselineCount + 1
        )
        XCTAssertEqual(statusItem.item.isVisible, true)

        source.wrappedValue = true
        XCTAssertEqual(statusItem.item.isVisible, false)

        NSStatusBar.system.removeStatusItem(statusItem.item)
    }

    @MainActor
    func testMacOSUSecureTextFieldBulletsEchoBindingUsesOwnerHolder() {
        let source = State<Bool>(wrappedValue: false)
        let textField = USecureTextField()
        let baselineCount = textField
            .stateBindingHolder
            .statesValues
            .heldListeners
            .count

        textField.echosBullets(source)

        XCTAssertEqual(
            textField.stateBindingHolder.statesValues.heldListeners.count,
            baselineCount + 1
        )
        XCTAssertEqual(
            (textField.cell as? NSSecureTextFieldCell)?.echosBullets,
            false
        )

        source.wrappedValue = true
        XCTAssertEqual(
            (textField.cell as? NSSecureTextFieldCell)?.echosBullets,
            true
        )
    }
    #endif
}
