#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import Ultra

final class StateCombinedStateTests: XCTestCase {

    func testCombinedState3InitialValue() {
        let a = State(wrappedValue: true)
        let b = State(wrappedValue: true)
        let c = State(wrappedValue: 15)

        let mapped = a.and(b).and(c).map { a, b, c in
            a && b && c == 15
        }

        XCTAssertEqual(mapped.wrappedValue, true)
    }

    func testCombinedState3UpdatesFromAnySource() {
        let a = State(wrappedValue: true)
        let b = State(wrappedValue: true)
        let c = State(wrappedValue: 15)

        let mapped = a.and(b).and(c).map { a, b, c in
            a && b && c == 15
        }

        XCTAssertEqual(mapped.wrappedValue, true)

        a.wrappedValue = false
        XCTAssertEqual(mapped.wrappedValue, false)

        a.wrappedValue = true
        XCTAssertEqual(mapped.wrappedValue, true)

        b.wrappedValue = false
        XCTAssertEqual(mapped.wrappedValue, false)

        b.wrappedValue = true
        XCTAssertEqual(mapped.wrappedValue, true)

        c.wrappedValue = 16
        XCTAssertEqual(mapped.wrappedValue, false)

        c.wrappedValue = 15
        XCTAssertEqual(mapped.wrappedValue, true)
    }

    func testCombinedState4Updates() {
        let a = State(wrappedValue: 1)
        let b = State(wrappedValue: 2)
        let c = State(wrappedValue: 3)
        let d = State(wrappedValue: 4)

        let mapped = a.and(b).and(c).and(d).map { a, b, c, d in
            a + b + c + d
        }

        XCTAssertEqual(mapped.wrappedValue, 10)

        d.wrappedValue = 10
        XCTAssertEqual(mapped.wrappedValue, 16)

        a.wrappedValue = 2
        XCTAssertEqual(mapped.wrappedValue, 17)
    }

    func testCombinedState5Updates() {
        let a = State(wrappedValue: 1)
        let b = State(wrappedValue: 2)
        let c = State(wrappedValue: 3)
        let d = State(wrappedValue: 4)
        let e = State(wrappedValue: 5)

        let mapped = a.and(b).and(c).and(d).and(e).map { a, b, c, d, e in
            a + b + c + d + e
        }

        XCTAssertEqual(mapped.wrappedValue, 15)

        e.wrappedValue = 10
        XCTAssertEqual(mapped.wrappedValue, 20)

        a.wrappedValue = 5
        XCTAssertEqual(mapped.wrappedValue, 24)
    }

    func testCombinedState6Updates() {
        let a = State(wrappedValue: 1)
        let b = State(wrappedValue: 2)
        let c = State(wrappedValue: 3)
        let d = State(wrappedValue: 4)
        let e = State(wrappedValue: 5)
        let f = State(wrappedValue: 6)

        let mapped = a.and(b).and(c).and(d).and(e).and(f).map { a, b, c, d, e, f in
            a + b + c + d + e + f
        }

        XCTAssertEqual(mapped.wrappedValue, 21)

        f.wrappedValue = 10
        XCTAssertEqual(mapped.wrappedValue, 25)

        a.wrappedValue = 5
        XCTAssertEqual(mapped.wrappedValue, 29)
    }

    func testCombinedState7Updates() {
        let a = State(wrappedValue: 1)
        let b = State(wrappedValue: 2)
        let c = State(wrappedValue: 3)
        let d = State(wrappedValue: 4)
        let e = State(wrappedValue: 5)
        let f = State(wrappedValue: 6)
        let g = State(wrappedValue: 7)

        let mapped = a.and(b).and(c).and(d).and(e).and(f).and(g).map { a, b, c, d, e, f, g in
            a + b + c + d + e + f + g
        }

        XCTAssertEqual(mapped.wrappedValue, 28)

        g.wrappedValue = 10
        XCTAssertEqual(mapped.wrappedValue, 31)

        a.wrappedValue = 5
        XCTAssertEqual(mapped.wrappedValue, 35)
    }

    func testNestedMapCompositionStillWorks() {
        let a = State(wrappedValue: 1)
        let b = State(wrappedValue: 2)
        let c = State(wrappedValue: 3)

        let combined = a.and(b)
        let ab = combined.map { a, b in a + b }

        XCTAssertEqual(ab.wrappedValue, 3)

        let abc = ab.and(c).map { ab, c in ab + c }

        XCTAssertEqual(abc.wrappedValue, 6)

        a.wrappedValue = 10
        XCTAssertEqual(ab.wrappedValue, 12)
        XCTAssertEqual(abc.wrappedValue, 15)

        b.wrappedValue = 20
        XCTAssertEqual(ab.wrappedValue, 30)
        XCTAssertEqual(abc.wrappedValue, 33)
    }

    func testExistingCombinedState2BehaviorStillWorks() {
        let a = State(wrappedValue: 1)
        let b = State(wrappedValue: 2)

        let mapped = a.and(b).map { a, b in
            a + b
        }

        XCTAssertEqual(mapped.wrappedValue, 3)

        a.wrappedValue = 10
        XCTAssertEqual(mapped.wrappedValue, 12)

        b.wrappedValue = 20
        XCTAssertEqual(mapped.wrappedValue, 30)
    }

    func testCombinedState3ListenersReleaseWhenMappedStateReleases() {
        let a = State(wrappedValue: 1)
        let b = State(wrappedValue: 2)
        let c = State(wrappedValue: 3)

        weak var weakMapped: State<Int>?

        do {
            let mapped = a.and(b).and(c).map { $0 + $1 + $2 }
            weakMapped = mapped
            XCTAssertEqual(mapped.wrappedValue, 6)
        }

        XCTAssertNil(weakMapped)

        a.wrappedValue = 10
        b.wrappedValue = 20
        c.wrappedValue = 30
    }

    func testCombinedState3HoldsOneListenerPerSource() {
        let a = State(wrappedValue: 1)
        let b = State(wrappedValue: 2)
        let c = State(wrappedValue: 3)

        let mapped = a.and(b).and(c).map { a, b, c in
            a + b + c
        }

        XCTAssertEqual(mapped.wrappedValue, 6)
        XCTAssertEqual(mapped.statesValues.heldListeners.count, 3)
    }

    func testCombinedState7HoldsOneListenerPerSource() {
        let a = State(wrappedValue: 1)
        let b = State(wrappedValue: 2)
        let c = State(wrappedValue: 3)
        let d = State(wrappedValue: 4)
        let e = State(wrappedValue: 5)
        let f = State(wrappedValue: 6)
        let g = State(wrappedValue: 7)

        let mapped = a.and(b).and(c).and(d).and(e).and(f).and(g).map { a, b, c, d, e, f, g in
            a + b + c + d + e + f + g
        }

        XCTAssertEqual(mapped.wrappedValue, 28)
        XCTAssertEqual(mapped.statesValues.heldListeners.count, 7)
    }

    func testCombinedState3ExpressionStopsEvaluatingAfterMappedStateDeinit() {
        let a = State(wrappedValue: 1)
        let b = State(wrappedValue: 2)
        let c = State(wrappedValue: 3)

        var evaluationCount = 0
        weak var weakMapped: State<Int>?

        do {
            let mapped = a.and(b).and(c).map { a, b, c in
                evaluationCount += 1
                return a + b + c
            }

            weakMapped = mapped

            XCTAssertEqual(mapped.wrappedValue, 6)
            XCTAssertEqual(evaluationCount, 1)

            a.wrappedValue = 10
            XCTAssertEqual(mapped.wrappedValue, 15)
            XCTAssertEqual(evaluationCount, 2)
        }

        XCTAssertNil(weakMapped)

        a.wrappedValue = 100
        b.wrappedValue = 200
        c.wrappedValue = 300

        XCTAssertEqual(evaluationCount, 2)
    }

    func testCombinedState7ExpressionStopsEvaluatingAfterMappedStateDeinit() {
        let a = State(wrappedValue: 1)
        let b = State(wrappedValue: 2)
        let c = State(wrappedValue: 3)
        let d = State(wrappedValue: 4)
        let e = State(wrappedValue: 5)
        let f = State(wrappedValue: 6)
        let g = State(wrappedValue: 7)

        var evaluationCount = 0
        weak var weakMapped: State<Int>?

        do {
            let mapped = a.and(b).and(c).and(d).and(e).and(f).and(g).map { a, b, c, d, e, f, g in
                evaluationCount += 1
                return a + b + c + d + e + f + g
            }

            weakMapped = mapped

            XCTAssertEqual(mapped.wrappedValue, 28)
            XCTAssertEqual(evaluationCount, 1)

            g.wrappedValue = 70
            XCTAssertEqual(mapped.wrappedValue, 91)
            XCTAssertEqual(evaluationCount, 2)
        }

        XCTAssertNil(weakMapped)

        a.wrappedValue = 10
        b.wrappedValue = 20
        c.wrappedValue = 30
        d.wrappedValue = 40
        e.wrappedValue = 50
        f.wrappedValue = 60
        g.wrappedValue = 70

        XCTAssertEqual(evaluationCount, 2)
    }

    func testCombinedState7ReleaseStatesDisconnectsEverySource() {
        let a = State(wrappedValue: 1)
        let b = State(wrappedValue: 2)
        let c = State(wrappedValue: 3)
        let d = State(wrappedValue: 4)
        let e = State(wrappedValue: 5)
        let f = State(wrappedValue: 6)
        let g = State(wrappedValue: 7)

        var evaluationCount = 0

        let mapped = a.and(b).and(c).and(d).and(e).and(f).and(g).map { a, b, c, d, e, f, g in
            evaluationCount += 1
            return a + b + c + d + e + f + g
        }

        XCTAssertEqual(mapped.wrappedValue, 28)
        XCTAssertEqual(evaluationCount, 1)
        XCTAssertEqual(mapped.statesValues.heldListeners.count, 7)

        mapped.releaseStates()

        XCTAssertEqual(mapped.statesValues.heldListeners.count, 0)

        a.wrappedValue = 10
        b.wrappedValue = 20
        c.wrappedValue = 30
        d.wrappedValue = 40
        e.wrappedValue = 50
        f.wrappedValue = 60
        g.wrappedValue = 70

        XCTAssertEqual(mapped.wrappedValue, 28)
        XCTAssertEqual(evaluationCount, 1)
    }

    func testCombinedState3MappedStateDoesNotRetainSourceStates() {
        weak var weakA: State<CombinedSourceBox>?
        weak var weakB: State<CombinedSourceBox>?
        weak var weakC: State<CombinedSourceBox>?

        let mapped: State<Int>

        do {
            let a = State(wrappedValue: CombinedSourceBox(1))
            let b = State(wrappedValue: CombinedSourceBox(2))
            let c = State(wrappedValue: CombinedSourceBox(3))

            weakA = a
            weakB = b
            weakC = c

            mapped = a.and(b).and(c).map { a, b, c in
                a.value + b.value + c.value
            }

            XCTAssertEqual(mapped.wrappedValue, 6)
        }

        XCTAssertNil(weakA)
        XCTAssertNil(weakB)
        XCTAssertNil(weakC)
    }

    func testCombinedState7MappedStateDoesNotRetainSourceStates() {
        weak var weakA: State<CombinedSourceBox>?
        weak var weakB: State<CombinedSourceBox>?
        weak var weakC: State<CombinedSourceBox>?
        weak var weakD: State<CombinedSourceBox>?
        weak var weakE: State<CombinedSourceBox>?
        weak var weakF: State<CombinedSourceBox>?
        weak var weakG: State<CombinedSourceBox>?

        let mapped: State<Int>

        do {
            let a = State(wrappedValue: CombinedSourceBox(1))
            let b = State(wrappedValue: CombinedSourceBox(2))
            let c = State(wrappedValue: CombinedSourceBox(3))
            let d = State(wrappedValue: CombinedSourceBox(4))
            let e = State(wrappedValue: CombinedSourceBox(5))
            let f = State(wrappedValue: CombinedSourceBox(6))
            let g = State(wrappedValue: CombinedSourceBox(7))

            weakA = a
            weakB = b
            weakC = c
            weakD = d
            weakE = e
            weakF = f
            weakG = g

            mapped = a.and(b).and(c).and(d).and(e).and(f).and(g).map { a, b, c, d, e, f, g in
                a.value + b.value + c.value + d.value + e.value + f.value + g.value
            }

            XCTAssertEqual(mapped.wrappedValue, 28)
        }

        XCTAssertNil(weakA)
        XCTAssertNil(weakB)
        XCTAssertNil(weakC)
        XCTAssertNil(weakD)
        XCTAssertNil(weakE)
        XCTAssertNil(weakF)
        XCTAssertNil(weakG)
    }

    func testCombinedState7HeldListenerTokensDeallocateAfterMappedStateDeinit() {
        let a = State(wrappedValue: 1)
        let b = State(wrappedValue: 2)
        let c = State(wrappedValue: 3)
        let d = State(wrappedValue: 4)
        let e = State(wrappedValue: 5)
        let f = State(wrappedValue: 6)
        let g = State(wrappedValue: 7)

        var weakTokens: [WeakStateListenerBox] = []

        do {
            let mapped = a.and(b).and(c).and(d).and(e).and(f).and(g).map { a, b, c, d, e, f, g in
                a + b + c + d + e + f + g
            }

            XCTAssertEqual(mapped.statesValues.heldListeners.count, 7)

            weakTokens = mapped.statesValues.heldListeners.values.map {
                WeakStateListenerBox($0)
            }
        }

        XCTAssertEqual(weakTokens.count, 7)
        XCTAssertTrue(weakTokens.allSatisfy { $0.listener == nil })
    }

    func testCombinedState7MappedStateCanBeListenedTo() {
        let a = State(wrappedValue: 1)
        let b = State(wrappedValue: 2)
        let c = State(wrappedValue: 3)
        let d = State(wrappedValue: 4)
        let e = State(wrappedValue: 5)
        let f = State(wrappedValue: 6)
        let g = State(wrappedValue: 7)

        let mapped = a.and(b).and(c).and(d).and(e).and(f).and(g).map { a, b, c, d, e, f, g in
            a + b + c + d + e + f + g
        }

        var values: [Int] = []

        mapped.listenDistinct { newValue in
            values.append(newValue)
        }

        XCTAssertEqual(mapped.wrappedValue, 28)

        a.wrappedValue = 10
        XCTAssertEqual(mapped.wrappedValue, 37)
        XCTAssertEqual(values, [37])

        a.wrappedValue = 10
        XCTAssertEqual(values, [37])

        b.wrappedValue = 20
        XCTAssertEqual(mapped.wrappedValue, 55)
        XCTAssertEqual(values, [37, 55])
    }
}

private final class CombinedSourceBox {
    var value: Int

    init(_ value: Int) {
        self.value = value
    }
}

private final class WeakStateListenerBox {
    weak var listener: StateListener?

    init(_ listener: StateListener) {
        self.listener = listener
    }
}
#endif
