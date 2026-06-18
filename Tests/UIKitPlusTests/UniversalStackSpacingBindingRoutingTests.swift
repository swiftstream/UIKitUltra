import Foundation
import XCTest
@testable import UIKitPlus

#if os(macOS)
import AppKit
#else
import UIKit
#endif

private final class StackWeakStateListenerBox {
    weak var value: StateListener?

    init(_ value: StateListener) {
        self.value = value
    }
}

private func heldListenerIDs(of holder: TempStatesHolder) -> Set<UUID> {
    Set(
        holder
            .statesValues
            .heldListeners
            .values
            .map(\.id)
    )
}

private func heldListenerCount(of holder: TempStatesHolder) -> Int {
    holder.statesValues.heldListeners.count
}

private func newlyHeldListeners(
    of holder: TempStatesHolder,
    excluding baselineIDs: Set<UUID>
) -> [StateListener] {
    holder
        .statesValues
        .heldListeners
        .values
        .filter {
            !baselineIDs.contains($0.id)
        }
}

@MainActor
final class UniversalStackSpacingBindingRoutingTests: XCTestCase {

    // MARK: - StackView

    @MainActor
    func testStackViewSpacingBindingRoutesTokenAndRemainsLive() {
        let stack = _StackView()
        let baselineCount = heldListenerCount(of: stack.stateBindingHolder)
        let baselineIDs = heldListenerIDs(of: stack.stateBindingHolder)
        let state = State<CGFloat>(wrappedValue: 8)

        _ = stack.spacing(state)

        let tokens = newlyHeldListeners(
            of: stack.stateBindingHolder,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            heldListenerCount(of: stack.stateBindingHolder),
            baselineCount + 1
        )
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(stack.spacing, 8)

        state.wrappedValue = 16

        XCTAssertEqual(stack.spacing, 16)
    }

    @MainActor
    func testStackViewRepeatedSpacingBindingRemainsAdditive() {
        let stack = _StackView()
        let baselineIDs = heldListenerIDs(of: stack.stateBindingHolder)
        let state = State<CGFloat>(wrappedValue: 4)

        _ = stack.spacing(state)
        _ = stack.spacing(state)

        let tokens = newlyHeldListeners(
            of: stack.stateBindingHolder,
            excluding: baselineIDs
        )

        XCTAssertEqual(tokens.count, 2)
        XCTAssertNotEqual(tokens[0].id, tokens[1].id)
    }

    // MARK: - HScrollStack

    func testHScrollStackSpacingBindingRoutesTokenAndRemainsLive() {
        let stack = UHScrollStack()
        let baselineCount = heldListenerCount(of: stack.stateBindingHolder)
        let baselineIDs = heldListenerIDs(of: stack.stateBindingHolder)
        let state = State<CGFloat>(wrappedValue: 12)

        _ = stack.spacing(state)

        let tokens = newlyHeldListeners(
            of: stack.stateBindingHolder,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            heldListenerCount(of: stack.stateBindingHolder),
            baselineCount + 1
        )
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(stack.stack.spacing, 12)

        state.wrappedValue = 24

        XCTAssertEqual(stack.stack.spacing, 24)
    }

    // MARK: - VScrollStack

    func testVScrollStackSpacingBindingRoutesTokenAndRemainsLive() {
        let stack = UVScrollStack()
        let baselineCount = heldListenerCount(of: stack.stateBindingHolder)
        let baselineIDs = heldListenerIDs(of: stack.stateBindingHolder)
        let state = State<CGFloat>(wrappedValue: 6)

        _ = stack.spacing(state)

        let tokens = newlyHeldListeners(
            of: stack.stateBindingHolder,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            heldListenerCount(of: stack.stateBindingHolder),
            baselineCount + 1
        )
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(stack.stack.spacing, 6)

        state.wrappedValue = 12

        XCTAssertEqual(stack.stack.spacing, 12)
    }

    // MARK: - Teardown

    @MainActor
    func testStackViewTeardownCancelsOwnedSpacingTokenAndPreservesUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let spacingState = State<CGFloat>(wrappedValue: 4)

        weak var weakStack: _StackView?
        var weakBoxes: [StackWeakStateListenerBox] = []

        autoreleasepool {
            var stack: _StackView? = _StackView()
            weakStack = stack

            guard let liveStack = stack else {
                XCTFail("Expected live stack")
                return
            }

            let baselineIDs = heldListenerIDs(of: liveStack.stateBindingHolder)

            _ = liveStack.spacing(spacingState)

            let tokens = newlyHeldListeners(
                of: liveStack.stateBindingHolder,
                excluding: baselineIDs
            )

            XCTAssertEqual(tokens.count, 1)

            weakBoxes = tokens.map {
                StackWeakStateListenerBox($0)
            }

            stack = nil
        }

        XCTAssertNil(weakStack)

        for (index, box) in weakBoxes.enumerated() {
            XCTAssertNil(
                box.value,
                "Token \(index) should have been deallocated"
            )
        }

        spacingState.wrappedValue = 8

        unrelatedState.wrappedValue = 1

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(
            unrelatedHolder.statesValues.heldListeners.count,
            1
        )
    }

    @MainActor
    func testAllThreeStacksTeardownCancelsTokensPreservingUnrelated() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let spacingA = State<CGFloat>(wrappedValue: 4)
        let spacingB = State<CGFloat>(wrappedValue: 8)
        let spacingC = State<CGFloat>(wrappedValue: 12)

        weak var weakStackA: _StackView?
        weak var weakScrollB: UHScrollStack?
        weak var weakScrollC: UVScrollStack?
        var weakBoxes: [StackWeakStateListenerBox] = []

        autoreleasepool {
            var stackA: _StackView? = _StackView()
            var scrollB: UHScrollStack? = UHScrollStack()
            var scrollC: UVScrollStack? = UVScrollStack()

            weakStackA = stackA
            weakScrollB = scrollB
            weakScrollC = scrollC

            guard let liveA = stackA,
                  let liveB = scrollB,
                  let liveC = scrollC else {
                XCTFail("Expected live stacks")
                return
            }

            let baselineA = heldListenerIDs(of: liveA.stateBindingHolder)
            let baselineB = heldListenerIDs(of: liveB.stateBindingHolder)
            let baselineC = heldListenerIDs(of: liveC.stateBindingHolder)

            _ = liveA.spacing(spacingA)
            _ = liveB.spacing(spacingB)
            _ = liveC.spacing(spacingC)

            let tokensA = newlyHeldListeners(of: liveA.stateBindingHolder, excluding: baselineA)
            let tokensB = newlyHeldListeners(of: liveB.stateBindingHolder, excluding: baselineB)
            let tokensC = newlyHeldListeners(of: liveC.stateBindingHolder, excluding: baselineC)

            XCTAssertEqual(tokensA.count, 1)
            XCTAssertEqual(tokensB.count, 1)
            XCTAssertEqual(tokensC.count, 1)

            weakBoxes = tokensA.map { StackWeakStateListenerBox($0) }
                + tokensB.map { StackWeakStateListenerBox($0) }
                + tokensC.map { StackWeakStateListenerBox($0) }

            stackA = nil
            scrollB = nil
            scrollC = nil
        }

        XCTAssertNil(weakStackA)
        XCTAssertNil(weakScrollB)
        XCTAssertNil(weakScrollC)

        for (index, box) in weakBoxes.enumerated() {
            XCTAssertNil(
                box.value,
                "Token \(index) should have been deallocated"
            )
        }

        spacingA.wrappedValue = 16
        spacingB.wrappedValue = 32
        spacingC.wrappedValue = 48

        unrelatedState.wrappedValue = 1

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(
            unrelatedHolder.statesValues.heldListeners.count,
            1
        )
    }
}
