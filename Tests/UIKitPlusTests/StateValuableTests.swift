import XCTest
@testable import UIKitPlus

private final class TitleProbe: StatesHolder {
    let statesValues = StatesHolderValuesBox()
    private(set) var title: String = ""

    deinit {
        invalidateStates()
    }

    @discardableResult
    func text<S: StateValuable>(_ value: S) -> Self where S.Value == String {
        title = value.simpleValue

        value.stateValue?
            .listenDistinct { [weak self] newValue in
                self?.title = newValue
            }
            .hold(in: self)

        return self
    }
}

private final class CountingTitleProbe: StatesHolder {
    let statesValues = StatesHolderValuesBox()
    private(set) var title: String = ""
    private(set) var updateCount = 0

    deinit {
        invalidateStates()
    }

    @discardableResult
    func text<S: StateValuable>(_ value: S) -> Self where S.Value == String {
        title = value.simpleValue
        updateCount += 1

        value.stateValue?
            .listenDistinct { [weak self] newValue in
                self?.title = newValue
                self?.updateCount += 1
            }
            .hold(in: self)

        return self
    }
}

final class StateValuableTests: XCTestCase {

    func testStringStateValuableProvidesSimpleValueOnly() {
        let value = "Hello"

        XCTAssertEqual(value.simpleValue, "Hello")
        XCTAssertNil(value.stateValue)
    }

    func testPrimitiveStateValuableConformancesProvideSimpleValueOnly() {
        XCTAssertEqual(true.simpleValue, true)
        XCTAssertNil(true.stateValue)

        XCTAssertEqual(42.simpleValue, 42)
        XCTAssertNil(42.stateValue)

        XCTAssertEqual(3.5.simpleValue, 3.5)
        XCTAssertNil(3.5.stateValue)
    }

    func testStateConformsToStateValuable() {
        let state = State(wrappedValue: "Initial")

        XCTAssertEqual(state.simpleValue, "Initial")
        XCTAssertTrue(state.stateValue === state)

        state.wrappedValue = "Updated"

        XCTAssertEqual(state.simpleValue, "Updated")
        XCTAssertTrue(state.stateValue === state)
    }

    func testCodableStateConformsToStateValuable() {
        let state = CodableState(wrappedValue: "Initial")

        XCTAssertEqual(state.simpleValue, "Initial")
        XCTAssertTrue(state.stateValue === state.projectedValue)

        state.wrappedValue = "Updated"

        XCTAssertEqual(state.simpleValue, "Updated")
        XCTAssertTrue(state.stateValue === state.projectedValue)
    }

    func testInnerStateConformsToStateValuable() {
        let parent = State(wrappedValue: SampleStateValue(title: "Initial"))
        let inner = InnerState(parent, \.title)

        XCTAssertEqual(inner.simpleValue, "Initial")
        XCTAssertTrue(inner.stateValue === inner.projectedValue)

        inner.wrappedValue = "Updated"

        XCTAssertEqual(inner.simpleValue, "Updated")
        XCTAssertTrue(inner.stateValue === inner.projectedValue)
    }

    func testCustomStateValuableAPIAcceptsPlainValue() {
        let probe = TitleProbe()

        probe.text("Hello")

        XCTAssertEqual(probe.title, "Hello")
    }

    func testCustomStateValuableAPIAcceptsStateValueAndUpdates() {
        let state = State(wrappedValue: "Initial")
        let probe = TitleProbe()

        probe.text(state)

        XCTAssertEqual(probe.title, "Initial")

        state.wrappedValue = "Updated"

        XCTAssertEqual(probe.title, "Updated")
    }

    func testCustomStateValuableAPIReleasesStateListenerWithHolder() {
        let state = State(wrappedValue: "Initial")
        let probe = TitleProbe()

        probe.text(state)

        state.wrappedValue = "First"
        XCTAssertEqual(probe.title, "First")

        probe.invalidateStates()

        state.wrappedValue = "Second"

        XCTAssertEqual(probe.title, "First")
    }

    func testCustomStateValuableAPISkipsDuplicateUpdates() {
        let state = State(wrappedValue: "Initial")
        let probe = CountingTitleProbe()

        probe.text(state)

        state.wrappedValue = "Initial"
        state.wrappedValue = "Updated"
        state.wrappedValue = "Updated"

        XCTAssertEqual(probe.title, "Updated")
        XCTAssertEqual(probe.updateCount, 2)
    }
}

private struct SampleStateValue: Equatable {
    var title: String
}
