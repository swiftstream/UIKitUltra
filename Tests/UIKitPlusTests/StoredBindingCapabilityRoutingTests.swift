import Foundation
import XCTest
@testable import UIKitPlus

#if os(macOS)
import AppKit

private class ControlStateableProbe: _ControlStateable {
    var _stateState = State<NSControl.StateValue>(wrappedValue: .off)
    private(set) var appliedState: NSControl.StateValue?

    func _setState(_ v: NSControl.StateValue) {
        appliedState = v
    }
}

private final class OwnedControlStateableProbe:
    ControlStateableProbe,
    _StateBindingOwner
{
    let stateBindingHolder = TempStatesHolder()
}

private class PublicControlStateableBase: ControlStateable {
    private(set) var scalarState: NSControl.StateValue?

    @discardableResult
    func state(_ value: NSControl.StateValue) -> Self {
        scalarState = value
        return self
    }
}

private final class PublicWitnessOwnedControlStateableProbe:
    PublicControlStateableBase,
    _ControlStateable,
    _StateBindingOwner
{
    let stateBindingHolder = TempStatesHolder()
    var _stateState = State<NSControl.StateValue>(wrappedValue: .off)
    private(set) var appliedState: NSControl.StateValue?

    func _setState(_ v: NSControl.StateValue) {
        appliedState = v
    }
}

private class BezelStyleableProbe: _BezelStyleable {
    var _bezelStyleState = State<NSButton.BezelStyle>(wrappedValue: .regularSquare)
    private(set) var appliedBezelStyle: NSButton.BezelStyle?

    func _setBezelStyle(_ v: NSButton.BezelStyle) {
        appliedBezelStyle = v
    }
}

private final class OwnedBezelStyleableProbe:
    BezelStyleableProbe,
    _StateBindingOwner
{
    let stateBindingHolder = TempStatesHolder()
}

private class PublicBezelStyleableBase: BezelStyleable {
    private(set) var scalarBezelStyle: NSButton.BezelStyle?

    @discardableResult
    func style(_ value: NSButton.BezelStyle) -> Self {
        scalarBezelStyle = value
        return self
    }
}

private final class PublicWitnessOwnedBezelStyleableProbe:
    PublicBezelStyleableBase,
    _BezelStyleable,
    _StateBindingOwner
{
    let stateBindingHolder = TempStatesHolder()
    var _bezelStyleState = State<NSButton.BezelStyle>(wrappedValue: .regularSquare)
    private(set) var appliedBezelStyle: NSButton.BezelStyle?

    func _setBezelStyle(_ v: NSButton.BezelStyle) {
        appliedBezelStyle = v
    }
}

private func callPublicControlStateable(
    _ value: any ControlStateable,
    _ source: State<NSControl.StateValue>
) {
    value.state(source)
}

private func callPublicBezelStyleable(
    _ value: any BezelStyleable,
    _ source: State<NSButton.BezelStyle>
) {
    value.style(source)
}

private func callRefinedControlStateable<T: _ControlStateable>(
    _ value: T,
    _ source: State<NSControl.StateValue>
) {
    value.state(source)
}

private func callRefinedBezelStyleable<T: _BezelStyleable>(
    _ value: T,
    _ source: State<NSButton.BezelStyle>
) {
    value.style(source)
}

private enum DispatchCanary {
    static var hits: [String] = []
}

private protocol DispatchPublicCapability: AnyObject {
    func bind()
}

private protocol DispatchInternalCapability: DispatchPublicCapability {}

private extension DispatchPublicCapability {
    func bind() { DispatchCanary.hits.append("public") }
}

private extension DispatchInternalCapability {
    func bind() { DispatchCanary.hits.append("internal") }
}

private class DispatchPublicBase: DispatchPublicCapability {}
private final class DispatchInternalSubclass:
    DispatchPublicBase,
    DispatchInternalCapability
{}

final class StoredBindingCapabilityRoutingTests: XCTestCase {

    func testDispatchCanaryForInheritedPublicWitnessSelectsPublicImplementation() {
        DispatchCanary.hits = []

        let publicValue: any DispatchPublicCapability =
            DispatchInternalSubclass()

        publicValue.bind()

        XCTAssertEqual(
            DispatchCanary.hits,
            ["public"]
        )

        DispatchCanary.hits = []

        DispatchInternalSubclass().bind()

        XCTAssertEqual(
            DispatchCanary.hits,
            ["internal"]
        )
    }

    func testControlStateableRefinedPathRoutesIntoHolderAndPreservesStoredBindingOrdering() {
        let source = State<NSControl.StateValue>(wrappedValue: .off)
        var probe: OwnedControlStateableProbe!
        var weakProbe: WeakRef!
        var weakToken: WeakRef!
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0
        let unrelatedSource = State<NSControl.StateValue>(wrappedValue: .mixed)

        unrelatedSource.listen { _ in unrelatedCallCount += 1 }
            .hold(in: unrelatedHolder)

        autoreleasepool {
            let liveProbe = OwnedControlStateableProbe()
            weakProbe = WeakRef(liveProbe)

            callRefinedControlStateable(liveProbe, source)

            XCTAssertTrue(liveProbe._stateState === source)
            XCTAssertEqual(liveProbe.appliedState, .off)
            XCTAssertEqual(liveProbe.stateBindingHolder.statesValues.heldListeners.count, 1)

            source.wrappedValue = .on
            XCTAssertEqual(liveProbe.appliedState, .on)

            weakToken = WeakRef(
                Array(liveProbe.stateBindingHolder.statesValues.heldListeners.values).first!
            )

            probe = liveProbe
            _ = probe
        }

        probe = nil
        XCTAssertNil(weakProbe.value)
        XCTAssertNil(weakToken.value)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)

        unrelatedSource.wrappedValue = .on
        XCTAssertEqual(unrelatedCallCount, 1)

        source.wrappedValue = .mixed
    }

    func testControlStateablePublicPathRoutesIntoHolderAndPreservesStoredBindingOrdering() {
        let source = State<NSControl.StateValue>(wrappedValue: .off)
        var probe: PublicWitnessOwnedControlStateableProbe!
        var weakProbe: WeakRef!
        var weakToken: WeakRef!
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0
        let unrelatedSource = State<NSControl.StateValue>(wrappedValue: .mixed)

        unrelatedSource.listen { _ in unrelatedCallCount += 1 }
            .hold(in: unrelatedHolder)

        autoreleasepool {
            let liveProbe = PublicWitnessOwnedControlStateableProbe()
            weakProbe = WeakRef(liveProbe)

            callPublicControlStateable(liveProbe, source)

            XCTAssertTrue(liveProbe._stateState === source)
            XCTAssertEqual(liveProbe.appliedState, .off)
            XCTAssertEqual(liveProbe.stateBindingHolder.statesValues.heldListeners.count, 1)

            source.wrappedValue = .on
            XCTAssertEqual(liveProbe.appliedState, .on)

            weakToken = WeakRef(
                Array(liveProbe.stateBindingHolder.statesValues.heldListeners.values).first!
            )

            probe = liveProbe
            _ = probe
        }

        probe = nil
        XCTAssertNil(weakProbe.value)
        XCTAssertNil(weakToken.value)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)

        unrelatedSource.wrappedValue = .on
        XCTAssertEqual(unrelatedCallCount, 1)

        source.wrappedValue = .mixed
    }

    func testControlStateableRepeatedBindingsRemainAdditiveUntilTeardown() {
        let sourceA = State<NSControl.StateValue>(wrappedValue: .off)
        let sourceB = State<NSControl.StateValue>(wrappedValue: .on)
        var weakProbe: WeakRef!
        var weakTokenA: WeakRef!
        var weakTokenB: WeakRef!

        autoreleasepool {
            let liveProbe = OwnedControlStateableProbe()
            weakProbe = WeakRef(liveProbe)

            callRefinedControlStateable(liveProbe, sourceA)
            callRefinedControlStateable(liveProbe, sourceB)

            XCTAssertEqual(liveProbe.stateBindingHolder.statesValues.heldListeners.count, 2)
            XCTAssertTrue(liveProbe._stateState === sourceB)

            let keys = Array(liveProbe.stateBindingHolder.statesValues.heldListeners.keys)
            let tokens = Array(liveProbe.stateBindingHolder.statesValues.heldListeners.values)
            XCTAssertNotEqual(keys[0], keys[1])

            weakTokenA = WeakRef(tokens[0])
            weakTokenB = WeakRef(tokens[1])

            sourceA.wrappedValue = .mixed
            XCTAssertEqual(liveProbe.appliedState, .mixed)

            sourceB.wrappedValue = .off
            XCTAssertEqual(liveProbe.appliedState, .off)
        }

        XCTAssertNil(weakProbe.value)
        XCTAssertNil(weakTokenA.value)
        XCTAssertNil(weakTokenB.value)
    }

    func testControlStateableScalarSetterRemainsListenerFree() {
        let probe = OwnedControlStateableProbe()

        probe.state(.on)

        XCTAssertEqual(probe.appliedState, .on)
        XCTAssertEqual(probe._stateState.wrappedValue, .on)
        XCTAssertEqual(probe.stateBindingHolder.statesValues.heldListeners.count, 0)
    }

    func testMenuItemControlStateBindingFallbackRemainsLiveWithoutOwner() {
        let item = MenuItem("Test")
        let source = State<NSControl.StateValue>(wrappedValue: .off)

        XCTAssertFalse(item is _StateBindingOwner)

        item.state(source)

        XCTAssertEqual(item.item.state, .off)

        source.wrappedValue = .on

        XCTAssertEqual(item.item.state, .on)
    }

    func testMacOSUButtonControlStateBindingUsesOwnerHolder() {
        let button = UButton("Test")
        let source = State<NSControl.StateValue>(wrappedValue: .off)

        let baselineCount =
            button
                .stateBindingHolder
                .statesValues
                .heldListeners
                .count

        button.state(source)

        XCTAssertEqual(
            button.stateBindingHolder.statesValues.heldListeners.count,
            baselineCount + 1
        )
        XCTAssertTrue(button._stateState === source)
        XCTAssertEqual(button.state, .off)

        source.wrappedValue = .on

        XCTAssertEqual(button.state, .on)
    }

    func testBezelStyleableRefinedPathRoutesIntoHolderAndPreservesStoredBindingOrdering() {
        let source = State<NSButton.BezelStyle>(wrappedValue: .regularSquare)
        var probe: OwnedBezelStyleableProbe!
        var weakProbe: WeakRef!
        var weakToken: WeakRef!
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0
        let unrelatedSource = State<NSButton.BezelStyle>(wrappedValue: .regularSquare)

        unrelatedSource.listen { _ in unrelatedCallCount += 1 }
            .hold(in: unrelatedHolder)

        autoreleasepool {
            let liveProbe = OwnedBezelStyleableProbe()
            weakProbe = WeakRef(liveProbe)

            callRefinedBezelStyleable(liveProbe, source)

            XCTAssertTrue(liveProbe._bezelStyleState === source)
            XCTAssertEqual(liveProbe.appliedBezelStyle, .regularSquare)
            XCTAssertEqual(liveProbe.stateBindingHolder.statesValues.heldListeners.count, 1)

            source.wrappedValue = .rounded
            XCTAssertEqual(liveProbe.appliedBezelStyle, .rounded)

            weakToken = WeakRef(
                Array(liveProbe.stateBindingHolder.statesValues.heldListeners.values).first!
            )

            probe = liveProbe
            _ = probe
        }

        probe = nil
        XCTAssertNil(weakProbe.value)
        XCTAssertNil(weakToken.value)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)

        unrelatedSource.wrappedValue = .rounded
        XCTAssertEqual(unrelatedCallCount, 1)

        source.wrappedValue = .regularSquare
    }

    func testBezelStyleablePublicPathRepairsStrongCaptureAndReleasesOnTeardown() {
        let source = State<NSButton.BezelStyle>(wrappedValue: .regularSquare)
        var probe: PublicWitnessOwnedBezelStyleableProbe!
        var weakProbe: WeakRef!
        var weakToken: WeakRef!
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0
        let unrelatedSource = State<NSButton.BezelStyle>(wrappedValue: .rounded)

        unrelatedSource.listen { _ in unrelatedCallCount += 1 }
            .hold(in: unrelatedHolder)

        autoreleasepool {
            let liveProbe = PublicWitnessOwnedBezelStyleableProbe()
            weakProbe = WeakRef(liveProbe)

            callPublicBezelStyleable(liveProbe, source)

            XCTAssertTrue(liveProbe._bezelStyleState === source)
            XCTAssertEqual(liveProbe.appliedBezelStyle, .regularSquare)
            XCTAssertEqual(liveProbe.stateBindingHolder.statesValues.heldListeners.count, 1)

            source.wrappedValue = .rounded
            XCTAssertEqual(liveProbe.appliedBezelStyle, .rounded)

            weakToken = WeakRef(
                Array(liveProbe.stateBindingHolder.statesValues.heldListeners.values).first!
            )

            probe = liveProbe
            _ = probe
        }

        probe = nil
        XCTAssertNil(weakProbe.value)
        XCTAssertNil(weakToken.value)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)

        unrelatedSource.wrappedValue = .regularSquare
        XCTAssertEqual(unrelatedCallCount, 1)

        source.wrappedValue = .regularSquare
    }

    func testBezelStyleableRepeatedBindingsRemainAdditiveUntilTeardown() {
        let sourceA = State<NSButton.BezelStyle>(wrappedValue: .regularSquare)
        let sourceB = State<NSButton.BezelStyle>(wrappedValue: .rounded)
        var weakProbe: WeakRef!
        var weakTokenA: WeakRef!
        var weakTokenB: WeakRef!

        autoreleasepool {
            let liveProbe = OwnedBezelStyleableProbe()
            weakProbe = WeakRef(liveProbe)

            callRefinedBezelStyleable(liveProbe, sourceA)
            callRefinedBezelStyleable(liveProbe, sourceB)

            XCTAssertEqual(liveProbe.stateBindingHolder.statesValues.heldListeners.count, 2)
            XCTAssertTrue(liveProbe._bezelStyleState === sourceB)

            let keys = Array(liveProbe.stateBindingHolder.statesValues.heldListeners.keys)
            let tokens = Array(liveProbe.stateBindingHolder.statesValues.heldListeners.values)
            XCTAssertNotEqual(keys[0], keys[1])

            weakTokenA = WeakRef(tokens[0])
            weakTokenB = WeakRef(tokens[1])

            sourceA.wrappedValue = .regularSquare
            XCTAssertEqual(liveProbe.appliedBezelStyle, .regularSquare)

            sourceB.wrappedValue = .rounded
            XCTAssertEqual(liveProbe.appliedBezelStyle, .rounded)
        }

        XCTAssertNil(weakProbe.value)
        XCTAssertNil(weakTokenA.value)
        XCTAssertNil(weakTokenB.value)
    }

    func testBezelStyleableScalarSetterRemainsListenerFree() {
        let probe = OwnedBezelStyleableProbe()

        probe.style(.regularSquare)

        XCTAssertEqual(probe.appliedBezelStyle, .regularSquare)
        XCTAssertEqual(probe._bezelStyleState.wrappedValue, .regularSquare)
        XCTAssertEqual(probe.stateBindingHolder.statesValues.heldListeners.count, 0)
    }

    func testMacOSUButtonAndUPopUpButtonBezelStyleBindingsUseOwnerHolder() {
        do {
            let button = UButton("Test")
            let buttonSource =
                State<NSButton.BezelStyle>(
                    wrappedValue: .regularSquare
                )

            let baselineCount =
                button
                    .stateBindingHolder
                    .statesValues
                    .heldListeners
                    .count

            button.style(buttonSource)

            XCTAssertEqual(
                button.stateBindingHolder.statesValues.heldListeners.count,
                baselineCount + 1
            )
            XCTAssertTrue(button._bezelStyleState === buttonSource)
            XCTAssertEqual(button.bezelStyle, .regularSquare)

            buttonSource.wrappedValue = .rounded

            XCTAssertEqual(button.bezelStyle, .rounded)
        }

        do {
            let popup = UPopUpButton {
                MenuItem("First")
            }

            let popupSource =
                State<NSButton.BezelStyle>(
                    wrappedValue: .regularSquare
                )

            let baselineCount =
                popup
                    .stateBindingHolder
                    .statesValues
                    .heldListeners
                    .count

            popup.style(popupSource)

            XCTAssertEqual(
                popup.stateBindingHolder.statesValues.heldListeners.count,
                baselineCount + 1
            )
            XCTAssertTrue(popup._bezelStyleState === popupSource)
            XCTAssertEqual(popup.bezelStyle, .regularSquare)

            popupSource.wrappedValue = .rounded

            XCTAssertEqual(popup.bezelStyle, .rounded)
        }
    }
}

private final class WeakRef {
    weak var value: AnyObject?
    init(_ value: AnyObject) { self.value = value }
}
#endif
