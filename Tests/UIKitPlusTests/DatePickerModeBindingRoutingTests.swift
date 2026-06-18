import Foundation
import XCTest
@testable import UIKitPlus

#if !os(macOS)
import UIKit
#if !os(tvOS)

@MainActor
final class DatePickerModeBindingRoutingTests: XCTestCase {

    func testDatePickerModeBindingRoutesIntoOwnerHolder() {
        let picker = UDatePicker()
        let modeState = State<UIDatePicker.Mode>(wrappedValue: .date)

        let baselineCount = picker.stateBindingHolder.statesValues.heldListeners.count

        _ = picker.mode(modeState)

        XCTAssertEqual(
            picker.stateBindingHolder.statesValues.heldListeners.count,
            baselineCount + 1
        )
        XCTAssertEqual(picker.datePickerMode, .date)

        modeState.wrappedValue = .time
        XCTAssertEqual(picker.datePickerMode, .time)
    }

    func testDatePickerModeBindingTeardownReleasesTokenAndPreservesUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0
        unrelatedState.listen { _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let modeState = State<UIDatePicker.Mode>(wrappedValue: .date)

        weak var weakPicker: UDatePicker?
        weak var weakToken: StateListener?

        autoreleasepool {
            var picker: UDatePicker? = UDatePicker()

            guard let livePicker = picker else {
                XCTFail("Expected live picker")
                return
            }

            _ = livePicker.mode(modeState)

            let tokens = Array(
                livePicker
                    .stateBindingHolder
                    .statesValues
                    .heldListeners
                    .values
            )

            guard tokens.count == 1 else {
                XCTFail("Expected exactly one mode token")
                return
            }

            weakToken = tokens[0]
            weakPicker = livePicker

            picker = nil
        }

        XCTAssertNil(weakPicker)
        XCTAssertNil(weakToken)

        modeState.wrappedValue = .countDownTimer

        unrelatedState.wrappedValue = 1
        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)
    }
}

#endif
#endif
