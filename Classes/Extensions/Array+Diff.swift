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
        var matchedSecondIndexes: Set<Int> = []
        var commonPairs: [(old: T1, new: T2)] = []

        for a in first {
            if let bIndex = second.firstIndex(where: { b in compare(a, b) }), !matchedSecondIndexes.contains(bIndex) {
                commonPairs.append((old: a, new: second[bIndex]))
                matchedSecondIndexes.insert(bIndex)
            }
        }

        let commonSet = Set(commonPairs.map { $0.old })
        var removed: [DiffItem<T1>] = []
        for (index, a) in first.enumerated() {
            if !commonSet.contains(where: { common in common == a }) {
                removed.append(DiffItem(index: index, value: a))
            }
        }

        var inserted: [DiffItem<T2>] = []
        for (index, b) in second.enumerated() {
            if !matchedSecondIndexes.contains(index) {
                inserted.append(DiffItem(index: index, value: b))
            }
        }

        var modified: [DiffItem<T2>] = []
        var removedIndexesToDrop: [Int] = []
        var insertedIndexesToDrop: [Int] = []

        for (insIndex, ins) in inserted.enumerated() {
            guard let _ins = ins.value as? AnyIdentable else { continue }
            for (remIndex, rem) in removed.enumerated() {
                if let _rem = rem.value as? AnyIdentable {
                    if _rem.identValue() == _ins.identValue() {
                        modified.append(ins)
                        removedIndexesToDrop.append(remIndex)
                        insertedIndexesToDrop.append(insIndex)
                        break
                    }
                }
            }
        }

        for i in removedIndexesToDrop.sorted().reversed() {
            removed.remove(at: i)
        }
        for i in insertedIndexesToDrop.sorted().reversed() {
            inserted.remove(at: i)
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
