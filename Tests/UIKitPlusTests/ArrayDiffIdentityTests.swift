import XCTest
@testable import UIKitPlus

private struct CollidingValue: Hashable {
    let id: Int

    static func == (lhs: CollidingValue, rhs: CollidingValue) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }
}

private struct CollidingID: Hashable {
    let rawValue: Int

    static func == (lhs: CollidingID, rhs: CollidingID) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }
}

private struct IdentifiedItem: Identable {
    typealias ID = CollidingID

    let id: CollidingID
    let title: String

    static var idKey: IDKey { \.id }

    static func == (lhs: IdentifiedItem, rhs: IdentifiedItem) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
}

final class ArrayDiffIdentityTests: XCTestCase {

    func testPlainHashableValuesWithCollidingHashAreNotCommon() {
        let old = [CollidingValue(id: 1)]
        let new = [CollidingValue(id: 2)]
        let diff = old.difference(new)

        XCTAssertTrue(diff.common.isEmpty)
        XCTAssertEqual(diff.removed.count, 1)
        XCTAssertEqual(diff.removed.first?.index, 0)
        XCTAssertEqual(diff.removed.first?.value.id, 1)
        XCTAssertEqual(diff.inserted.count, 1)
        XCTAssertEqual(diff.inserted.first?.index, 0)
        XCTAssertEqual(diff.inserted.first?.value.id, 2)
        XCTAssertTrue(diff.modified.isEmpty)
    }

    func testRemovedInsertedIndexesRemainCorrectUnderHashCollisions() {
        let old = [
            CollidingValue(id: 1),
            CollidingValue(id: 2),
            CollidingValue(id: 3),
        ]
        let new = [
            CollidingValue(id: 2),
            CollidingValue(id: 4),
        ]
        let diff = old.difference(new)

        XCTAssertEqual(diff.common.count, 1)
        XCTAssertEqual(diff.common.first?.old.id, 2)
        XCTAssertEqual(diff.common.first?.new.id, 2)

        let removedIndexes = diff.removed.map { $0.index }.sorted()
        XCTAssertEqual(removedIndexes, [0, 2])

        let insertedIndexes = diff.inserted.map { $0.index }.sorted()
        XCTAssertEqual(insertedIndexes, [1])

        XCTAssertTrue(diff.modified.isEmpty)
    }

    func testIdentableValuesWithSameIDAndChangedPayloadReportAsModified() {
        let old = [IdentifiedItem(id: .init(rawValue: 1), title: "Old")]
        let new = [IdentifiedItem(id: .init(rawValue: 1), title: "New")]
        let diff = old.difference(new)

        XCTAssertTrue(diff.common.isEmpty)
        XCTAssertTrue(diff.removed.isEmpty)
        XCTAssertTrue(diff.inserted.isEmpty)
        XCTAssertEqual(diff.modified.count, 1)
        XCTAssertEqual(diff.modified.first?.index, 0)
        XCTAssertEqual(diff.modified.first?.value.title, "New")
    }

    func testIdentableValuesWithDifferentIDsAndCollidingHashAreNotModified() {
        let old = [IdentifiedItem(id: .init(rawValue: 1), title: "A")]
        let new = [IdentifiedItem(id: .init(rawValue: 2), title: "A")]
        let diff = old.difference(new)

        XCTAssertTrue(diff.common.isEmpty)
        XCTAssertEqual(diff.removed.count, 1)
        XCTAssertEqual(diff.removed.first?.index, 0)
        XCTAssertEqual(diff.inserted.count, 1)
        XCTAssertEqual(diff.inserted.first?.index, 0)
        XCTAssertTrue(diff.modified.isEmpty)
    }

    func testIdentableExistentialUsesIDKeyIdentValueNotIdentHashFallback() {
        let item = IdentifiedItem(id: .init(rawValue: 42), title: "A")
        let any: AnyIdentable = item

        XCTAssertEqual(any.identValue(), AnyHashable(CollidingID(rawValue: 42)))
        XCTAssertNotEqual(any.identValue(), AnyHashable(any.identHash()))
    }

    func testLegacyHashCompareOverloadStillUsesProvidedIntCompare() {
        let old = [CollidingValue(id: 1)]
        let new = [CollidingValue(id: 2)]
        let diff = old.difference(old, new, with: ==)

        XCTAssertEqual(diff.common.count, 1)
        XCTAssertTrue(diff.removed.isEmpty)
        XCTAssertTrue(diff.inserted.isEmpty)
        XCTAssertTrue(diff.modified.isEmpty)
    }

    func testSimpleHashableDiffBehaviorRemainsCompatible() {
        let old = [1, 2, 3]
        let new = [2, 3, 4]
        let diff = old.difference(new)

        XCTAssertEqual(diff.common.count, 2)
        XCTAssertEqual(diff.removed.count, 1)
        XCTAssertEqual(diff.removed.first?.index, 0)
        XCTAssertEqual(diff.inserted.count, 1)
        XCTAssertEqual(diff.inserted.first?.index, 2)
        XCTAssertTrue(diff.modified.isEmpty)
    }

    func testDuplicatePlainHashableValuesMatchOneToOne() {
        let old = [
            CollidingValue(id: 1),
            CollidingValue(id: 1),
        ]
        let new = [
            CollidingValue(id: 1),
            CollidingValue(id: 1),
        ]
        let diff = old.difference(new)

        XCTAssertEqual(diff.common.count, 2)
        XCTAssertTrue(diff.removed.isEmpty)
        XCTAssertTrue(diff.inserted.isEmpty)
        XCTAssertTrue(diff.modified.isEmpty)
    }

    func testDuplicatePlainHashableValuesPreserveUnmatchedMultiplicity() {
        let old = [
            CollidingValue(id: 1),
            CollidingValue(id: 1),
            CollidingValue(id: 2),
        ]
        let new = [
            CollidingValue(id: 1),
        ]
        let diff = old.difference(new)

        XCTAssertEqual(diff.common.count, 1)
        let removedIndexes = diff.removed.map { $0.index }.sorted()
        XCTAssertEqual(removedIndexes, [1, 2])
        XCTAssertTrue(diff.inserted.isEmpty)
        XCTAssertTrue(diff.modified.isEmpty)
    }

    func testDuplicateIdentableModificationsMatchOneToOne() {
        let old = [
            IdentifiedItem(id: .init(rawValue: 1), title: "Old A"),
            IdentifiedItem(id: .init(rawValue: 1), title: "Old B"),
        ]
        let new = [
            IdentifiedItem(id: .init(rawValue: 1), title: "New A"),
            IdentifiedItem(id: .init(rawValue: 1), title: "New B"),
        ]
        let diff = old.difference(new)

        XCTAssertTrue(diff.common.isEmpty)
        XCTAssertTrue(diff.removed.isEmpty)
        XCTAssertTrue(diff.inserted.isEmpty)
        XCTAssertEqual(diff.modified.count, 2)
        let modifiedIndexes = diff.modified.map { $0.index }.sorted()
        XCTAssertEqual(modifiedIndexes, [0, 1])
    }
}
