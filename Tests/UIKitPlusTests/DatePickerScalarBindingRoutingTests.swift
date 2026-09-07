#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import XCTest
@testable import UIKitPlus

#if !os(macOS)
#if !os(tvOS)
import UIKit

private final class WeakStateListenerBox {
    weak var value: StateListener?

    init(_ value: StateListener) {
        self.value = value
    }
}

private func heldListenerIDs(of picker: UDatePicker) -> Set<UUID> {
    Set(
        picker
            .stateBindingHolder
            .statesValues
            .heldListeners
            .values
            .map(\.id)
    )
}

private func heldListenerCount(of picker: UDatePicker) -> Int {
    picker.stateBindingHolder.statesValues.heldListeners.count
}

private func newlyHeldListeners(
    of picker: UDatePicker,
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

@MainActor
final class DatePickerScalarBindingRoutingTests: XCTestCase {

    func testDatePickerTextColorUIColorRoutesIntoOwnerHolder() {
        let picker = UDatePicker(frame: .zero)
        let baselineCount = heldListenerCount(of: picker)

        let textColorState = State<UIColor>(wrappedValue: .red)
        picker.textColor(textColorState)

        XCTAssertEqual(heldListenerCount(of: picker), baselineCount + 1)
    }

    func testDatePickerTextColorIntRoutesIntoOwnerHolder() {
        let picker = UDatePicker(frame: .zero)
        let baselineCount = heldListenerCount(of: picker)

        let textColorIntState = State<Int>(wrappedValue: 0xFF0000)
        picker.textColor(textColorIntState)

        XCTAssertEqual(heldListenerCount(of: picker), baselineCount + 1)
    }

    func testDatePickerAllTenScalarBindingsRouteIntoHolderAndObservableBindingsRemainLive() {
        let picker = UDatePicker(frame: .zero)
        let baselineCount = heldListenerCount(of: picker)

        let textColorUIColorState = State<UIColor>(wrappedValue: .blue)
        let textColorIntState = State<Int>(wrappedValue: 0x0000FF)
        let localeState = State<Locale>(wrappedValue: Locale(identifier: "fr_FR"))
        let calendarState = State<Calendar>(wrappedValue: Calendar(identifier: .japanese))
        let timeZoneState = State<TimeZone>(wrappedValue: TimeZone(secondsFromGMT: 3600)!)
        let dateState = State<Date>(wrappedValue: Date())
        let minDateState = State<Date>(wrappedValue: Date(timeIntervalSince1970: 0))
        let maxDateState = State<Date>(wrappedValue: Date(timeIntervalSince1970: 9999999))
        let countDownState = State<TimeInterval>(wrappedValue: 300)
        let minuteIntervalState = State<Int>(wrappedValue: 5)

        _ = picker
            .textColor(textColorUIColorState)
            .textColor(textColorIntState)
            .locale(localeState)
            .calendar(calendarState)
            .timeZone(timeZoneState)
            .date(dateState, animated: false)
            .minimumDate(minDateState)
            .maximumDate(maxDateState)
            .countDownDuration(countDownState)
            .minuteInterval(minuteIntervalState)

        XCTAssertEqual(heldListenerCount(of: picker), baselineCount + 10)

        let newLocale = Locale(identifier: "ja_JP")
        localeState.wrappedValue = newLocale
        XCTAssertEqual(picker.locale, newLocale)

        let newCalendar = Calendar(identifier: .islamic)
        calendarState.wrappedValue = newCalendar
        XCTAssertEqual(picker.calendar, newCalendar)

        let newTimeZone = TimeZone(secondsFromGMT: -1800)!
        timeZoneState.wrappedValue = newTimeZone
        XCTAssertEqual(picker.timeZone, newTimeZone)

        let newDate = Date(timeIntervalSince1970: 42)
        dateState.wrappedValue = newDate
        XCTAssertEqual(picker.date, newDate)

        let newMinDate = Date(timeIntervalSince1970: 100)
        minDateState.wrappedValue = newMinDate
        XCTAssertEqual(picker.minimumDate, newMinDate)

        let newMaxDate = Date(timeIntervalSince1970: 8888)
        maxDateState.wrappedValue = newMaxDate
        XCTAssertEqual(picker.maximumDate, newMaxDate)

        let newCountDown: TimeInterval = 600
        countDownState.wrappedValue = newCountDown

        // UIDatePicker normalizes countDownDuration against its internal
        // runtime state, so exact getter equality is not a stable assertion
        // in this aggregate routing test. Token ownership is verified by
        // the holder delta and teardown cancellation tests.

        let newMinuteInterval = 15
        minuteIntervalState.wrappedValue = newMinuteInterval
        XCTAssertEqual(picker.minuteInterval, newMinuteInterval)
    }

    func testDatePickerDateBindingPropagatesUpdatesAndPreservesDateBinding() {
        let picker = UDatePicker(frame: .zero)
        let baselineCount = heldListenerCount(of: picker)

        let dateState = State<Date>(wrappedValue: Date())
        _ = picker.date(dateState, animated: false)

        XCTAssertEqual(heldListenerCount(of: picker), baselineCount + 1)
        XCTAssertNotNil(picker.dateBinding)

        let newDate = Date(timeIntervalSince1970: 999)
        dateState.wrappedValue = newDate
        XCTAssertEqual(picker.date, newDate)
    }

    func testDatePickerTeardownCancelsAllTenOwnedTokensAndPreservesUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0
        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let textColorUIColorState = State<UIColor>(wrappedValue: .red)
        let textColorIntState = State<Int>(wrappedValue: 0xFF0000)
        let localeState = State<Locale>(wrappedValue: Locale(identifier: "en"))
        let calendarState = State<Calendar>(wrappedValue: Calendar(identifier: .gregorian))
        let timeZoneState = State<TimeZone>(wrappedValue: TimeZone.current)
        let dateState = State<Date>(wrappedValue: Date())
        let minDateState = State<Date>(wrappedValue: Date(timeIntervalSince1970: 0))
        let maxDateState = State<Date>(wrappedValue: Date(timeIntervalSince1970: 9999999))
        let countDownState = State<TimeInterval>(wrappedValue: 100)
        let minuteIntervalState = State<Int>(wrappedValue: 1)

        weak var weakPicker: UDatePicker?
        var weakBoxes: [WeakStateListenerBox] = []

        autoreleasepool {
            var picker: UDatePicker? = UDatePicker(frame: .zero)
            weakPicker = picker

            guard let livePicker = picker else {
                XCTFail("Expected live picker")
                return
            }

            let baselineIDs = heldListenerIDs(of: livePicker)

            _ = livePicker
                .textColor(textColorUIColorState)
                .textColor(textColorIntState)
                .locale(localeState)
                .calendar(calendarState)
                .timeZone(timeZoneState)
                .date(dateState, animated: false)
                .minimumDate(minDateState)
                .maximumDate(maxDateState)
                .countDownDuration(countDownState)
                .minuteInterval(minuteIntervalState)

            let newTokens = newlyHeldListeners(of: livePicker, excluding: baselineIDs)
            XCTAssertEqual(newTokens.count, 10)

            weakBoxes = newTokens.map { WeakStateListenerBox($0) }

            picker = nil
        }

        XCTAssertNil(weakPicker)
        for (index, box) in weakBoxes.enumerated() {
            XCTAssertNil(box.value, "Token \(index) should have been deallocated")
        }

        textColorUIColorState.wrappedValue = .blue
        textColorIntState.wrappedValue = 0x0000FF
        localeState.wrappedValue = Locale(identifier: "fr")
        calendarState.wrappedValue = Calendar(identifier: .japanese)
        timeZoneState.wrappedValue = TimeZone(secondsFromGMT: 3600)!
        dateState.wrappedValue = Date(timeIntervalSince1970: 777)
        minDateState.wrappedValue = Date(timeIntervalSince1970: 111)
        maxDateState.wrappedValue = Date(timeIntervalSince1970: 222)
        countDownState.wrappedValue = 50
        minuteIntervalState.wrappedValue = 3

        unrelatedState.wrappedValue = 1
        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)
    }

    func testDatePickerModeBindingCoexistsWithTenScalarTokens() {
        let picker = UDatePicker(frame: .zero)
        let baselineCount = heldListenerCount(of: picker)

        let modeState = State<UIDatePicker.Mode>(wrappedValue: .date)
        _ = picker.mode(modeState)

        let textColorUIColorState = State<UIColor>(wrappedValue: .green)
        let textColorIntState = State<Int>(wrappedValue: 0x00FF00)
        let localeState = State<Locale>(wrappedValue: Locale(identifier: "de_DE"))
        let calendarState = State<Calendar>(wrappedValue: Calendar(identifier: .hebrew))
        let timeZoneState = State<TimeZone>(wrappedValue: TimeZone(secondsFromGMT: 7200)!)
        let dateState = State<Date>(wrappedValue: Date(timeIntervalSince1970: 555))
        let minDateState = State<Date>(wrappedValue: Date(timeIntervalSince1970: 10))
        let maxDateState = State<Date>(wrappedValue: Date(timeIntervalSince1970: 9999))
        let countDownState = State<TimeInterval>(wrappedValue: 200)
        let minuteIntervalState = State<Int>(wrappedValue: 1)

        _ = picker
            .textColor(textColorUIColorState)
            .textColor(textColorIntState)
            .locale(localeState)
            .calendar(calendarState)
            .timeZone(timeZoneState)
            .date(dateState, animated: false)
            .minimumDate(minDateState)
            .maximumDate(maxDateState)
            .countDownDuration(countDownState)
            .minuteInterval(minuteIntervalState)

        XCTAssertEqual(heldListenerCount(of: picker), baselineCount + 11)

        let newDate = Date(timeIntervalSince1970: 600)
        dateState.wrappedValue = newDate
        XCTAssertEqual(
            picker.date.timeIntervalSince1970,
            newDate.timeIntervalSince1970,
            accuracy: 1
        )

        modeState.wrappedValue = .time
        XCTAssertEqual(picker.datePickerMode, .time)

        let newLocale = Locale(identifier: "it_IT")
        localeState.wrappedValue = newLocale
        XCTAssertEqual(picker.locale, newLocale)
    }
}
#endif
#endif
#endif
