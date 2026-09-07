#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

extension Array {
    public struct DiffItem<V> {
        public let index: Int
        public let value: V
    }
    public struct DiffResult<T1, T2> {
        public let common: [(old: T1, new: T2)]
        public let removed: [DiffItem<T1>]
        public let inserted: [DiffItem<T2>]
        public let modified: [DiffItem<T2>]
        public init(common: [(T1, T2)] = [], removed: [DiffItem<T1>] = [], inserted: [DiffItem<T2>] = [], modified: [DiffItem<T2>] = []) {
            self.common = common
            self.removed = removed
            self.inserted = inserted
            self.modified = modified
        }
    }

    public func difference<T1: Hashable, T2: Hashable>(_ first: [T1], _ second: [T2], with compare: (Int,Int) -> Bool) -> DiffResult<T1, T2> {
        difference(first, second, withValues: { compare($0.hashValue, $1.hashValue) })
    }

    public func difference<T1: Hashable, T2: Hashable>(_ first: [T1], _ second: [T2], withValues compare: (T1, T2) -> Bool) -> DiffResult<T1, T2> {
        var matchedFirstIndexes: Set<Int> = []
        var matchedSecondIndexes: Set<Int> = []
        var commonPairs: [(old: T1, new: T2)] = []

        for (oldIndex, oldValue) in first.enumerated() {
            guard let match = second.enumerated().first(where: { newIndex, newValue in
                !matchedSecondIndexes.contains(newIndex) && compare(oldValue, newValue)
            }) else {
                continue
            }
            commonPairs.append((old: oldValue, new: match.element))
            matchedFirstIndexes.insert(oldIndex)
            matchedSecondIndexes.insert(match.offset)
        }

        var removed: [DiffItem<T1>] = []
        for (index, oldValue) in first.enumerated() {
            if !matchedFirstIndexes.contains(index) {
                removed.append(DiffItem(index: index, value: oldValue))
            }
        }

        var inserted: [DiffItem<T2>] = []
        for (index, newValue) in second.enumerated() {
            if !matchedSecondIndexes.contains(index) {
                inserted.append(DiffItem(index: index, value: newValue))
            }
        }

        var modified: [DiffItem<T2>] = []
        var removedIndexesToDrop: Set<Int> = []
        var insertedIndexesToDrop: Set<Int> = []

        for (insertedIndex, insertedItem) in inserted.enumerated() {
            guard let insertedIdentable = insertedItem.value as? AnyIdentable else { continue }

            guard let removedMatch = removed.enumerated().first(where: { removedIndex, removedItem in
                guard !removedIndexesToDrop.contains(removedIndex) else { return false }
                guard let removedIdentable = removedItem.value as? AnyIdentable else { return false }
                return removedIdentable.identValue() == insertedIdentable.identValue()
            }) else {
                continue
            }

            modified.append(insertedItem)
            removedIndexesToDrop.insert(removedMatch.offset)
            insertedIndexesToDrop.insert(insertedIndex)
        }

        for index in removedIndexesToDrop.sorted(by: >) {
            removed.remove(at: index)
        }
        for index in insertedIndexesToDrop.sorted(by: >) {
            inserted.remove(at: index)
        }

        return DiffResult(common: commonPairs, removed: removed, inserted: inserted, modified: modified)
    }
}
extension Array where Element: Hashable {
    public func difference<T2: Hashable>(_ new: [T2]) -> DiffResult<Element, T2> {
        difference(self, new, withValues: {
            AnyHashable($0) == AnyHashable($1)
        })
    }
}
#endif
