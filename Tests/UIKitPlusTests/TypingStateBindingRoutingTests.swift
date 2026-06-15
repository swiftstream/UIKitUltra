import Foundation
import XCTest
@testable import UIKitPlus

#if os(macOS)
import AppKit
#else
import UIKit
#endif

private final class TypingWeakStateListenerBox {
    weak var value: StateListener?

    init(_ value: StateListener) {
        self.value = value
    }
}

private func typingHeldListenerIDs(of holder: TempStatesHolder) -> Set<UUID> {
    Set(
        holder
            .statesValues
            .heldListeners
            .values
            .map(\.id)
    )
}

private func typingHeldListenerCount(of holder: TempStatesHolder) -> Int {
    holder.statesValues.heldListeners.count
}

private func newlyHeldTypingListeners(
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

#if os(macOS)

final class MacOSTypingStateBindingRoutingTests: XCTestCase {

    @MainActor
    func testMacOSTextFieldTypingBridgeRoutesTokenSynchronizesInitiallyAndRemainsLive() {
        let field = UTextField()
        let baselineCount = typingHeldListenerCount(of: field.stateBindingHolder)
        let baselineIDs = typingHeldListenerIDs(of: field.stateBindingHolder)
        let target = State<Bool>(wrappedValue: true)

        _ = field.typing(target)

        let tokens = newlyHeldTypingListeners(
            of: field.stateBindingHolder,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            typingHeldListenerCount(of: field.stateBindingHolder),
            baselineCount + 1
        )
        XCTAssertEqual(tokens.count, 1)

        XCTAssertFalse(target.wrappedValue)

        field._properties.isTypingState.wrappedValue = true

        XCTAssertTrue(target.wrappedValue)

        field._properties.isTypingState.wrappedValue = false

        XCTAssertFalse(target.wrappedValue)
    }

    @MainActor
    func testMacOSTextFieldTypingBridgeSupportsAdditiveFanOutAndSameTargetRegistration() {
        let field = UTextField()
        let baselineIDs = typingHeldListenerIDs(of: field.stateBindingHolder)
        let targetA = State<Bool>(wrappedValue: false)
        let targetB = State<Bool>(wrappedValue: false)

        _ = field.typing(targetA)
        _ = field.typing(targetB)
        _ = field.typing(targetA)

        let tokens = newlyHeldTypingListeners(
            of: field.stateBindingHolder,
            excluding: baselineIDs
        )

        XCTAssertEqual(tokens.count, 3)
        XCTAssertEqual(Set(tokens.map(\.id)).count, 3)

        XCTAssertEqual(
            typingHeldListenerCount(of: field.stateBindingHolder),
            baselineIDs.count + 3
        )

        field._properties.isTypingState.wrappedValue = true

        XCTAssertTrue(targetA.wrappedValue)
        XCTAssertTrue(targetB.wrappedValue)

        field._properties.isTypingState.wrappedValue = false

        XCTAssertFalse(targetA.wrappedValue)
        XCTAssertFalse(targetB.wrappedValue)
    }

    @MainActor
    func testMacOSTextFieldTypingBridgeAllowsExternalTargetDeallocationBeforeOwnerTeardown() {
        let field = UTextField()
        let baselineCount = typingHeldListenerCount(
            of: field.stateBindingHolder
        )
        let baselineIDs = typingHeldListenerIDs(
            of: field.stateBindingHolder
        )

        weak var weakTarget: State<Bool>?

        autoreleasepool {
            var target: State<Bool>? = State<Bool>(wrappedValue: false)
            weakTarget = target

            guard let liveTarget = target else {
                XCTFail("Expected live target")
                return
            }

            _ = field.typing(liveTarget)

            target = nil
        }

        XCTAssertNil(weakTarget)

        let tokens = newlyHeldTypingListeners(
            of: field.stateBindingHolder,
            excluding: baselineIDs
        )

        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(
            typingHeldListenerCount(of: field.stateBindingHolder),
            baselineCount + 1
        )

        field._properties.isTypingState.wrappedValue = true
        field._properties.isTypingState.wrappedValue = false
    }

    @MainActor
    func testMacOSTextFieldHolderInvalidationCancelsOwnedTypingTokenAndPreservesUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let field = UTextField()
        let target = State<Bool>(wrappedValue: false)
        let retainedSource = field._properties.isTypingState
        let baselineIDs = typingHeldListenerIDs(
            of: field.stateBindingHolder
        )

        var weakBox: TypingWeakStateListenerBox?

        autoreleasepool {
            _ = field.typing(target)

            let tokens = newlyHeldTypingListeners(
                of: field.stateBindingHolder,
                excluding: baselineIDs
            )

            XCTAssertEqual(tokens.count, 1)

            weakBox = TypingWeakStateListenerBox(tokens[0])
        }

        XCTAssertNotNil(weakBox?.value)
        XCTAssertEqual(
            typingHeldListenerCount(of: field.stateBindingHolder),
            baselineIDs.count + 1
        )
        XCTAssertFalse(target.wrappedValue)

        field.stateBindingHolder.invalidateStates()

        XCTAssertNil(weakBox?.value)
        XCTAssertEqual(
            typingHeldListenerCount(of: field.stateBindingHolder),
            0
        )

        retainedSource.wrappedValue = true

        XCTAssertFalse(target.wrappedValue)

        retainedSource.wrappedValue = false

        XCTAssertFalse(target.wrappedValue)

        unrelatedState.wrappedValue = 1

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(
            unrelatedHolder.statesValues.heldListeners.count,
            1
        )
    }
}

#else

final class UIKitTypingStateBindingRoutingTests: XCTestCase {

    func testUIKitTextFieldTypingBridgeRoutesTokenSynchronizesInitiallyAndRemainsLive() {
        let field = UTextField()
        let baselineCount = typingHeldListenerCount(of: field.stateBindingHolder)
        let baselineIDs = typingHeldListenerIDs(of: field.stateBindingHolder)
        let target = State<Bool>(wrappedValue: true)

        _ = field.typing(target)

        let tokens = newlyHeldTypingListeners(
            of: field.stateBindingHolder,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            typingHeldListenerCount(of: field.stateBindingHolder),
            baselineCount + 1
        )
        XCTAssertEqual(tokens.count, 1)

        XCTAssertFalse(target.wrappedValue)

        field._properties.isTypingState.wrappedValue = true

        XCTAssertTrue(target.wrappedValue)

        field._properties.isTypingState.wrappedValue = false

        XCTAssertFalse(target.wrappedValue)
    }

    func testUIKitTextViewTypingBridgeRoutesTokenSynchronizesInitiallyAndRemainsLive() {
        let textView = UTextView()
        let baselineCount = typingHeldListenerCount(of: textView.stateBindingHolder)
        let baselineIDs = typingHeldListenerIDs(of: textView.stateBindingHolder)
        let target = State<Bool>(wrappedValue: true)

        _ = textView.typing(target)

        let tokens = newlyHeldTypingListeners(
            of: textView.stateBindingHolder,
            excluding: baselineIDs
        )

        XCTAssertEqual(
            typingHeldListenerCount(of: textView.stateBindingHolder),
            baselineCount + 1
        )
        XCTAssertEqual(tokens.count, 1)

        XCTAssertFalse(target.wrappedValue)

        textView._properties.isTypingState.wrappedValue = true

        XCTAssertTrue(target.wrappedValue)

        textView._properties.isTypingState.wrappedValue = false

        XCTAssertFalse(target.wrappedValue)
    }

    func testUIKitTextFieldTypingBridgeSupportsAdditiveFanOutAndSameTargetRegistration() {
        let field = UTextField()
        let baselineIDs = typingHeldListenerIDs(of: field.stateBindingHolder)
        let targetA = State<Bool>(wrappedValue: false)
        let targetB = State<Bool>(wrappedValue: false)

        _ = field.typing(targetA)
        _ = field.typing(targetB)
        _ = field.typing(targetA)

        let tokens = newlyHeldTypingListeners(
            of: field.stateBindingHolder,
            excluding: baselineIDs
        )

        XCTAssertEqual(tokens.count, 3)
        XCTAssertEqual(Set(tokens.map(\.id)).count, 3)

        XCTAssertEqual(
            typingHeldListenerCount(of: field.stateBindingHolder),
            baselineIDs.count + 3
        )

        field._properties.isTypingState.wrappedValue = true

        XCTAssertTrue(targetA.wrappedValue)
        XCTAssertTrue(targetB.wrappedValue)

        field._properties.isTypingState.wrappedValue = false

        XCTAssertFalse(targetA.wrappedValue)
        XCTAssertFalse(targetB.wrappedValue)
    }

    func testUIKitTextFieldTypingBridgeAllowsExternalTargetDeallocationBeforeOwnerTeardown() {
        let field = UTextField()
        let baselineCount = typingHeldListenerCount(
            of: field.stateBindingHolder
        )
        let baselineIDs = typingHeldListenerIDs(
            of: field.stateBindingHolder
        )

        weak var weakTarget: State<Bool>?

        autoreleasepool {
            var target: State<Bool>? = State<Bool>(wrappedValue: false)
            weakTarget = target

            guard let liveTarget = target else {
                XCTFail("Expected live target")
                return
            }

            _ = field.typing(liveTarget)

            target = nil
        }

        XCTAssertNil(weakTarget)

        let tokens = newlyHeldTypingListeners(
            of: field.stateBindingHolder,
            excluding: baselineIDs
        )

        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(
            typingHeldListenerCount(of: field.stateBindingHolder),
            baselineCount + 1
        )

        field._properties.isTypingState.wrappedValue = true
        field._properties.isTypingState.wrappedValue = false
    }

    func testUIKitTypingOwnerHoldersInvalidationCancelTextFieldAndTextViewTokensAndPreserveUnrelatedListener() {
        let unrelatedState = State<Int>(wrappedValue: 0)
        let unrelatedHolder = TempStatesHolder()
        var unrelatedCallCount = 0

        unrelatedState.listen { _, _ in
            unrelatedCallCount += 1
        }
        .hold(in: unrelatedHolder)

        let field = UTextField()
        let textView = UTextView()

        let textFieldTarget = State<Bool>(wrappedValue: false)
        let textViewTarget = State<Bool>(wrappedValue: false)

        let retainedFieldSource = field._properties.isTypingState
        let retainedTextViewSource = textView._properties.isTypingState

        let fieldBaselineIDs = typingHeldListenerIDs(
            of: field.stateBindingHolder
        )
        let textViewBaselineIDs = typingHeldListenerIDs(
            of: textView.stateBindingHolder
        )

        var weakFieldBox: TypingWeakStateListenerBox?
        var weakTextViewBox: TypingWeakStateListenerBox?

        autoreleasepool {
            _ = field.typing(textFieldTarget)
            _ = textView.typing(textViewTarget)

            let fieldTokens = newlyHeldTypingListeners(
                of: field.stateBindingHolder,
                excluding: fieldBaselineIDs
            )
            let textViewTokens = newlyHeldTypingListeners(
                of: textView.stateBindingHolder,
                excluding: textViewBaselineIDs
            )

            XCTAssertEqual(fieldTokens.count, 1)
            XCTAssertEqual(textViewTokens.count, 1)

            weakFieldBox = TypingWeakStateListenerBox(fieldTokens[0])
            weakTextViewBox = TypingWeakStateListenerBox(
                textViewTokens[0]
            )
        }

        XCTAssertNotNil(weakFieldBox?.value)
        XCTAssertNotNil(weakTextViewBox?.value)

        XCTAssertFalse(textFieldTarget.wrappedValue)
        XCTAssertFalse(textViewTarget.wrappedValue)

        field.stateBindingHolder.invalidateStates()
        textView.stateBindingHolder.invalidateStates()

        XCTAssertNil(weakFieldBox?.value)
        XCTAssertNil(weakTextViewBox?.value)

        XCTAssertEqual(
            typingHeldListenerCount(of: field.stateBindingHolder),
            0
        )
        XCTAssertEqual(
            typingHeldListenerCount(of: textView.stateBindingHolder),
            0
        )

        retainedFieldSource.wrappedValue = true
        retainedTextViewSource.wrappedValue = true

        XCTAssertFalse(textFieldTarget.wrappedValue)
        XCTAssertFalse(textViewTarget.wrappedValue)

        retainedFieldSource.wrappedValue = false
        retainedTextViewSource.wrappedValue = false

        XCTAssertFalse(textFieldTarget.wrappedValue)
        XCTAssertFalse(textViewTarget.wrappedValue)

        unrelatedState.wrappedValue = 1

        XCTAssertEqual(unrelatedCallCount, 1)
        XCTAssertEqual(
            unrelatedHolder.statesValues.heldListeners.count,
            1
        )
    }
}

#endif
