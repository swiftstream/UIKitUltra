import XCTest
@testable import UIKitPlus

final class StateReleaseWithHolderTests: XCTestCase {

    func testStateReleaseWithHolderReleasesStateHeldListenersWhenHolderReleases() {
        let owner = TempStatesHolder()
        let source = State(wrappedValue: 0)
        let derived = source.map { $0 + 1 }

        derived.release(with: owner)

        source.wrappedValue = 1
        XCTAssertEqual(derived.wrappedValue, 2)

        owner.releaseStates()

        source.wrappedValue = 2
        XCTAssertEqual(derived.wrappedValue, 2)
    }

    func testStateReleaseWithHolderIsSafeAfterHolderInvalidation() {
        let owner = TempStatesHolder()
        owner.invalidateStates()

        let source = State(wrappedValue: 0)
        let derived = source.map { $0 + 1 }

        derived.release(with: owner)

        source.wrappedValue = 1
        XCTAssertEqual(derived.wrappedValue, 1)
    }

    func testStateReleaseWithHolderDoesNotReleaseUnrelatedStateHeldListeners() {
        let owner = TempStatesHolder()
        let sourceA = State(wrappedValue: 0)
        let sourceB = State(wrappedValue: 10)
        let derivedA = sourceA.map { $0 + 1 }
        let derivedB = sourceB.map { $0 + 1 }

        derivedA.release(with: owner)

        owner.releaseStates()

        sourceA.wrappedValue = 1
        sourceB.wrappedValue = 11

        XCTAssertEqual(derivedA.wrappedValue, 1)
        XCTAssertEqual(derivedB.wrappedValue, 12)
    }

    func testStateReleaseWithHolderCanBeRegisteredBeforeStateHoldsListeners() {
        let owner = TempStatesHolder()
        let source = State(wrappedValue: 0)

        let derived = State<Int>(source) { value in
            value + 10
        }

        derived.release(with: owner)

        source.wrappedValue = 5
        XCTAssertEqual(derived.wrappedValue, 15)

        owner.releaseStates()

        source.wrappedValue = 99
        XCTAssertEqual(derived.wrappedValue, 15)
    }
}
