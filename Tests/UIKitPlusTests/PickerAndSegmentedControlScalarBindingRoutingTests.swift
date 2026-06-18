import Foundation
import XCTest
@testable import UIKitPlus

#if !os(macOS)
#if !os(tvOS)
import UIKit

private final class PickerSegmentedWeakStateListenerBox {
    weak var value: StateListener?

    init(_ value: StateListener) {
        self.value = value
    }
}

private func pickerHeldListenerIDs(of picker: UPickerView) -> Set<UUID> {
    Set(
        picker
            .stateBindingHolder
            .statesValues
            .heldListeners
            .values
            .map(\.id)
    )
}

private func pickerHeldListenerCount(of picker: UPickerView) -> Int {
    picker.stateBindingHolder.statesValues.heldListeners.count
}

private func newlyHeldPickerListeners(
    of picker: UPickerView,
    excluding baselineIDs: Set<UUID>
) -> [StateListener] {
    picker
        .stateBindingHolder
        .statesValues
        .heldListeners
        .values
        .filter {
            !baselineIDs.contains($0.id)
        }
}

private func segmentedHeldListenerIDs(
    of control: USegmentedControl
) -> Set<UUID> {
    Set(
        control
            .stateBindingHolder
            .statesValues
            .heldListeners
            .values
            .map(\.id)
    )
}

private func segmentedHeldListenerCount(
    of control: USegmentedControl
) -> Int {
    control.stateBindingHolder.statesValues.heldListeners.count
}

private func newlyHeldSegmentedListeners(
    of control: USegmentedControl,
    excluding baselineIDs: Set<UUID>
) -> [StateListener] {
    control
        .stateBindingHolder
        .statesValues
        .heldListeners
        .values
        .filter {
            !baselineIDs.contains($0.id)
        }
}

private func pickerTextColor(of picker: UPickerView) -> UIColor? {
    picker.value(forKey: "textColor") as? UIColor
}

@MainActor
final class PickerAndSegmentedControlScalarBindingRoutingTests: XCTestCase {

    func testPickerViewTextColorBindingsRouteIntoOwnerHolderAndRemainLive() {
        let picker = UPickerView(frame: .zero)
        let colorState = State<UIColor>(wrappedValue: .red)
        let hexState = State<Int>(wrappedValue: 0x00FF00)
        let baselineCount = pickerHeldListenerCount(of: picker)

        picker
            .textColor(colorState)
            .textColor(hexState)

        XCTAssertEqual(
            pickerHeldListenerCount(of: picker),
            baselineCount + 2
        )
        XCTAssertTrue(
            pickerTextColor(of: picker)?.isEqual(0x00FF00.color) == true
        )

        colorState.wrappedValue = .yellow

        XCTAssertTrue(
            pickerTextColor(of: picker)?.isEqual(UIColor.yellow) == true
        )

        hexState.wrappedValue = 0x123456

        XCTAssertTrue(
            pickerTextColor(of: picker)?.isEqual(0x123456.color) == true
        )
    }

    func testSegmentedControlSelectBindingRoutesTokenAndPreservesBidirectionalWitness() {
        let control = USegmentedControl(frame: .zero)

        control.insertSegment(
            withTitle: "First",
            at: 0,
            animated: false
        )
        control.insertSegment(
            withTitle: "Second",
            at: 1,
            animated: false
        )

        let state = State<Int>(wrappedValue: 1)
        let baselineCount = segmentedHeldListenerCount(of: control)

        _ = control.select(state)

        XCTAssertTrue(control.selectBinding === state)
        XCTAssertEqual(
            segmentedHeldListenerCount(of: control),
            baselineCount + 1
        )
        XCTAssertEqual(control.selectedSegmentIndex, 1)

        state.wrappedValue = 0

        XCTAssertEqual(control.selectedSegmentIndex, 0)

        control.selectedSegmentIndex = 1

        let valueChangedSelector = NSSelectorFromString("valueChanged")

        XCTAssertTrue(control.responds(to: valueChangedSelector))

        _ = control.perform(valueChangedSelector)

        XCTAssertEqual(state.wrappedValue, 1)
    }

    func testPickerViewRepeatedTextColorBindingRemainsAdditive() {
        let picker = UPickerView(frame: .zero)
        let state = State<UIColor>(wrappedValue: .red)
        let baselineCount = pickerHeldListenerCount(of: picker)
        let baselineIDs = pickerHeldListenerIDs(of: picker)

        _ = picker.textColor(state)
        _ = picker.textColor(state)

        let newTokens = newlyHeldPickerListeners(
            of: picker,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            pickerHeldListenerCount(of: picker),
            baselineCount + 2
        )
        XCTAssertEqual(newTokens.count, 2)
        XCTAssertNotEqual(newTokens[0].id, newTokens[1].id)

        state.wrappedValue = .green

        XCTAssertTrue(
            pickerTextColor(of: picker)?.isEqual(UIColor.green) == true
        )
    }

    func testSegmentedControlRepeatedSelectBindingRemainsAdditive() {
        let control = USegmentedControl(frame: .zero)

        control.insertSegment(withTitle: "A", at: 0, animated: false)
        control.insertSegment(withTitle: "B", at: 1, animated: false)

        let state = State<Int>(wrappedValue: 0)
        let baselineCount = segmentedHeldListenerCount(of: control)
        let baselineIDs = segmentedHeldListenerIDs(of: control)

        _ = control.select(state)
        _ = control.select(state)

        let newTokens = newlyHeldSegmentedListeners(
            of: control,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            segmentedHeldListenerCount(of: control),
            baselineCount + 2
        )
        XCTAssertEqual(newTokens.count, 2)
        XCTAssertNotEqual(newTokens[0].id, newTokens[1].id)

        state.wrappedValue = 1

        XCTAssertEqual(control.selectedSegmentIndex, 1)
    }

    func testPickerAndSegmentedControlTeardownCancelOwnedTokensAndPreserveUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let pickerColorState = State<UIColor>(wrappedValue: .red)
        let pickerHexState = State<Int>(wrappedValue: 0x00FF00)
        let selectedState = State<Int>(wrappedValue: 0)

        weak var weakPicker: UPickerView?
        weak var weakSegmented: USegmentedControl?
        var weakBoxes: [PickerSegmentedWeakStateListenerBox] = []

        autoreleasepool {
            var picker: UPickerView? = UPickerView(frame: .zero)
            var segmented: USegmentedControl? = USegmentedControl(
                frame: .zero
            )

            weakPicker = picker
            weakSegmented = segmented

            guard
                let livePicker = picker,
                let liveSegmented = segmented
            else {
                XCTFail("Expected live picker and segmented control")
                return
            }

            let pickerBaselineIDs = pickerHeldListenerIDs(of: livePicker)
            let segmentedBaselineIDs = segmentedHeldListenerIDs(
                of: liveSegmented
            )

            livePicker
                .textColor(pickerColorState)
                .textColor(pickerHexState)

            _ = liveSegmented.select(selectedState)

            let pickerTokens = newlyHeldPickerListeners(
                of: livePicker,
                excluding: pickerBaselineIDs
            )
            let segmentedTokens = newlyHeldSegmentedListeners(
                of: liveSegmented,
                excluding: segmentedBaselineIDs
            )

            XCTAssertEqual(pickerTokens.count, 2)
            XCTAssertEqual(segmentedTokens.count, 1)

            weakBoxes = (pickerTokens + segmentedTokens).map {
                PickerSegmentedWeakStateListenerBox($0)
            }

            picker = nil
            segmented = nil
        }

        XCTAssertNil(weakPicker)
        XCTAssertNil(weakSegmented)

        for (index, box) in weakBoxes.enumerated() {
            XCTAssertNil(
                box.value,
                "Token \(index) should have been deallocated"
            )
        }

        pickerColorState.wrappedValue = .yellow
        pickerHexState.wrappedValue = 0x123456
        selectedState.wrappedValue = 1

        unrelatedState.wrappedValue = 1

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(
            unrelatedHolder.statesValues.heldListeners.count,
            1
        )
    }
}

#endif
#endif
