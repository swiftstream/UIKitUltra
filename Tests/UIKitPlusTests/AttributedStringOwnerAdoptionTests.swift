import Foundation
import XCTest
@testable import UIKitPlus

@MainActor
private func assertColorAttribute(
    _ key: NSAttributedString.Key,
    in attributedString: UIKitPlus.AttributedString,
    equals expected: UColor,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    guard attributedString.attributedString.length > 0 else {
        XCTFail("Expected a non-empty attributed string", file: file, line: line)
        return
    }

    guard let actual = attributedString.attributedString.attribute(
        key,
        at: 0,
        effectiveRange: nil
    ) as? NSObject else {
        XCTFail("Expected a color attribute", file: file, line: line)
        return
    }

    XCTAssertTrue(
        actual.isEqual(expected.current),
        "Color attributes do not match",
        file: file,
        line: line
    )
}

@MainActor
final class AttributedStringOwnerAdoptionTests: XCTestCase {

    func testAttributedStringBackgroundBindingIsOwnedAndCancelsOnTeardown() {
        let source = State<UColor>(wrappedValue: UColor.red)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        source.listen { _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        weak var weakAttributedString: UIKitPlus.AttributedString?
        weak var weakToken: StateListener?

        autoreleasepool {
            var attributedString: UIKitPlus.AttributedString? = .init("A")
            weakAttributedString = attributedString

            attributedString?.background(source)

            guard let liveAttributedString = attributedString else {
                XCTFail("Expected live attributed string")
                return
            }

            let tokens = Array(
                liveAttributedString
                    .stateBindingHolder
                    .statesValues
                    .heldListeners
                    .values
            )

            guard tokens.count == 1, let token = tokens.first else {
                XCTFail("Expected exactly one attributed-string-owned token")
                return
            }

            weakToken = token

            assertColorAttribute(
                .backgroundColor,
                in: liveAttributedString,
                equals: UColor.red
            )

            source.wrappedValue = UColor.blue

            assertColorAttribute(
                .backgroundColor,
                in: liveAttributedString,
                equals: UColor.blue
            )

            attributedString = nil
        }

        XCTAssertNil(weakAttributedString)
        XCTAssertNil(weakToken)

        source.wrappedValue = UColor.green

        XCTAssertEqual(unrelatedCallCount, 2)
        XCTAssertEqual(unrelatedHolder.statesValues.heldListeners.count, 1)
    }

    func testAttributedStringForegroundBindingIsOwnedAndCancelsOnTeardown() {
        let source = State<UColor>(wrappedValue: UColor.red)

        weak var weakAttributedString: UIKitPlus.AttributedString?
        weak var weakToken: StateListener?

        autoreleasepool {
            var attributedString: UIKitPlus.AttributedString? = .init("A")
            weakAttributedString = attributedString

            attributedString?.foreground(source)

            guard let liveAttributedString = attributedString else {
                XCTFail("Expected live attributed string")
                return
            }

            let tokens = Array(
                liveAttributedString
                    .stateBindingHolder
                    .statesValues
                    .heldListeners
                    .values
            )

            guard tokens.count == 1, let token = tokens.first else {
                XCTFail("Expected exactly one attributed-string-owned token")
                return
            }

            weakToken = token

            assertColorAttribute(
                .foregroundColor,
                in: liveAttributedString,
                equals: UColor.red
            )

            source.wrappedValue = UColor.blue

            assertColorAttribute(
                .foregroundColor,
                in: liveAttributedString,
                equals: UColor.blue
            )

            attributedString = nil
        }

        XCTAssertNil(weakAttributedString)
        XCTAssertNil(weakToken)
    }

    func testAttributedStringRepeatedColorBindingsRemainAdditiveUntilTeardown() {
        let sourceA = State<UColor>(wrappedValue: UColor.red)
        let sourceB = State<UColor>(wrappedValue: UColor.blue)

        weak var weakAttributedString: UIKitPlus.AttributedString?
        weak var weakTokenA: StateListener?
        weak var weakTokenB: StateListener?

        autoreleasepool {
            var attributedString: UIKitPlus.AttributedString? = .init("A")
            weakAttributedString = attributedString

            attributedString?.background(sourceA)
            attributedString?.background(sourceB)

            guard let liveAttributedString = attributedString else {
                XCTFail("Expected live attributed string")
                return
            }

            let tokens = Array(
                liveAttributedString
                    .stateBindingHolder
                    .statesValues
                    .heldListeners
                    .values
            )

            guard tokens.count == 2 else {
                XCTFail("Expected exactly two additive attributed-string-owned tokens")
                return
            }

            weakTokenA = tokens[0]
            weakTokenB = tokens[1]

            sourceA.wrappedValue = UColor.green

            assertColorAttribute(
                .backgroundColor,
                in: liveAttributedString,
                equals: UColor.green
            )

            sourceB.wrappedValue = UColor.yellow

            assertColorAttribute(
                .backgroundColor,
                in: liveAttributedString,
                equals: UColor.yellow
            )

            attributedString = nil
        }

        XCTAssertNil(weakAttributedString)
        XCTAssertNil(weakTokenA)
        XCTAssertNil(weakTokenB)
    }

    func testAttributedStringScalarColorSettersRemainListenerFree() {
        let attributedString = UIKitPlus.AttributedString("A")

        attributedString.background(UColor.red)
        attributedString.foreground(UColor.blue)

        XCTAssertEqual(
            attributedString
                .stateBindingHolder
                .statesValues
                .heldListeners
                .count,
            0
        )

        assertColorAttribute(
            .backgroundColor,
            in: attributedString,
            equals: UColor.red
        )

        assertColorAttribute(
            .foregroundColor,
            in: attributedString,
            equals: UColor.blue
        )
    }

    func testStringColorStateConvenienceReturnsOwnedAttributedString() {
        let source = State<UColor>(wrappedValue: UColor.red)

        weak var weakAttributedString: UIKitPlus.AttributedString?
        weak var weakToken: StateListener?

        autoreleasepool {
            var attributedString: UIKitPlus.AttributedString? = "A".background(source)
            weakAttributedString = attributedString

            guard let liveAttributedString = attributedString else {
                XCTFail("Expected live attributed string")
                return
            }

            let tokens = Array(
                liveAttributedString
                    .stateBindingHolder
                    .statesValues
                    .heldListeners
                    .values
            )

            guard tokens.count == 1, let token = tokens.first else {
                XCTFail("Expected exactly one delegated attributed-string-owned token")
                return
            }

            weakToken = token

            source.wrappedValue = UColor.blue

            assertColorAttribute(
                .backgroundColor,
                in: liveAttributedString,
                equals: UColor.blue
            )

            attributedString = nil
        }

        XCTAssertNil(weakAttributedString)
        XCTAssertNil(weakToken)
    }
}
