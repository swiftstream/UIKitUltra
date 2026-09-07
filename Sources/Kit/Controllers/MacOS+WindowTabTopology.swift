#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit

/// A validated description of the windows, ordering, and selection in a native
/// AppKit tab topology.
public struct WindowTabTopology<TabID: Hashable>: Equatable {
    /// One native window group and its leading-to-trailing tab order.
    public struct Group: Identifiable, Equatable {
        /// Stable logical identity for the native window group.
        public let id: UUID
        /// Tab identities in leading-to-trailing native tab order.
        public let tabIDs: [TabID]
        /// The tab selected in this group.
        public let selectedTabID: TabID

        /// Creates a non-empty group with a selection that belongs to it.
        public init(id: UUID = UUID(), tabIDs: [TabID], selectedTabID: TabID) {
            precondition(!tabIDs.isEmpty, "A WindowTabTopology group cannot be empty")
            precondition(
                Set(tabIDs).count == tabIDs.count,
                "A WindowTabTopology group cannot contain duplicate tab IDs"
            )
            precondition(
                tabIDs.contains(selectedTabID),
                "A WindowTabTopology group selection must belong to the group"
            )
            self.id = id
            self.tabIDs = tabIDs
            self.selectedTabID = selectedTabID
        }
    }

    /// Native window groups in application-managed order.
    public let groups: [Group]
    /// The group whose selected window is the application presentation target.
    public let activeGroupID: UUID?

    /// Creates a topology and validates group and tab identity invariants.
    public init(groups: [Group], activeGroupID: UUID? = nil) {
        let groupIDs = groups.map(\.id)
        precondition(
            Set(groupIDs).count == groupIDs.count,
            "A WindowTabTopology cannot contain duplicate group IDs"
        )

        let tabIDs = groups.flatMap(\.tabIDs)
        precondition(
            Set(tabIDs).count == tabIDs.count,
            "A WindowTabTopology cannot contain duplicate tab IDs"
        )
        if let activeGroupID {
            precondition(
                groups.contains { $0.id == activeGroupID },
                "The active WindowTabTopology group must exist"
            )
        }

        self.groups = groups
        self.activeGroupID = activeGroupID
    }

    /// An empty topology with no active native window group.
    public static var empty: Self { .init(groups: []) }

    /// Creates one native group from an ordered tab collection.
    public static func singleGroup(
        _ tabIDs: [TabID],
        selectedTabID: TabID? = nil,
        groupID: UUID = UUID()
    ) -> Self {
        guard !tabIDs.isEmpty else { return .empty }
        return .init(
            groups: [
                .init(
                    id: groupID,
                    tabIDs: tabIDs,
                    selectedTabID: selectedTabID ?? tabIDs[0]
                )
            ],
            activeGroupID: groupID
        )
    }

    /// Returns all tab IDs in logical native group order.
    public var tabIDs: [TabID] { groups.flatMap(\.tabIDs) }

    /// Returns the group containing a tab ID, if present.
    public func group(containing tabID: TabID) -> Group? {
        groups.first { $0.tabIDs.contains(tabID) }
    }

    /// Returns a topology with the specified tab selected.
    public func selecting(_ tabID: TabID) -> Self {
        guard let groupIndex = groups.firstIndex(where: { $0.tabIDs.contains(tabID) }) else {
            return self
        }
        var nextGroups = groups
        let group = nextGroups[groupIndex]
        nextGroups[groupIndex] = .init(
            id: group.id,
            tabIDs: group.tabIDs,
            selectedTabID: tabID
        )
        return .init(groups: nextGroups, activeGroupID: group.id)
    }

    /// Returns a topology with a tab inserted into an existing group.
    public func inserting(
        _ tabID: TabID,
        in groupID: UUID,
        at index: Int? = nil,
        selecting: Bool = false
    ) -> Self {
        precondition(!tabIDs.contains(tabID), "The tab ID is already in the topology")
        guard let groupIndex = groups.firstIndex(where: { $0.id == groupID }) else {
            return self
        }
        var nextGroups = groups
        let group = nextGroups[groupIndex]
        var nextTabIDs = group.tabIDs
        let clampedIndex = min(max(index ?? nextTabIDs.count, 0), nextTabIDs.count)
        nextTabIDs.insert(tabID, at: clampedIndex)
        nextGroups[groupIndex] = .init(
            id: group.id,
            tabIDs: nextTabIDs,
            selectedTabID: selecting ? tabID : group.selectedTabID
        )
        return .init(
            groups: nextGroups,
            activeGroupID: selecting ? group.id : activeGroupID
        )
    }

    /// Returns a topology with a tab removed. An empty group is removed too.
    /// If the active group still has tabs after the removal, it remains the
    /// active group so closing a tab cannot move focus to another window.
    public func removing(_ tabID: TabID) -> Self {
        guard let groupIndex = groups.firstIndex(where: { $0.tabIDs.contains(tabID) }) else {
            return self
        }
        var nextGroups = groups
        let group = nextGroups.remove(at: groupIndex)
        let remaining = group.tabIDs.filter { $0 != tabID }
        if !remaining.isEmpty {
            let selection = group.selectedTabID == tabID ? remaining[0] : group.selectedTabID
            nextGroups.insert(
                .init(id: group.id, tabIDs: remaining, selectedTabID: selection),
                at: groupIndex
            )
        }

        let nextActive: UUID?
        if activeGroupID == group.id {
            nextActive = remaining.isEmpty ? nextGroups.first?.id : group.id
        } else if let activeGroupID, nextGroups.contains(where: { $0.id == activeGroupID }) {
            nextActive = activeGroupID
        } else {
            nextActive = nextGroups.first?.id
        }
        return .init(groups: nextGroups, activeGroupID: nextActive)
    }

    /// Returns a topology with a tab moved within or between native groups.
    ///
    /// `index` is the destination index after removing the tab from its
    /// source group, matching AppKit's post-drop ordering semantics.
    public func moving(_ tabID: TabID, to groupID: UUID, at index: Int) -> Self {
        guard let sourceGroup = group(containing: tabID),
              let sourceIndex = groups.firstIndex(where: { $0.id == sourceGroup.id }),
              groups.contains(where: { $0.id == groupID }) else {
            return self
        }

        if sourceGroup.id == groupID {
            var nextGroups = groups
            var tabIDs = sourceGroup.tabIDs
            guard let sourceTabIndex = tabIDs.firstIndex(of: tabID) else { return self }
            tabIDs.remove(at: sourceTabIndex)
            let destinationIndex = min(max(index, 0), tabIDs.count)
            tabIDs.insert(tabID, at: destinationIndex)
            nextGroups[sourceIndex] = .init(
                id: sourceGroup.id,
                tabIDs: tabIDs,
                selectedTabID: sourceGroup.selectedTabID
            )
            return .init(groups: nextGroups, activeGroupID: activeGroupID)
        }

        let removed = removing(tabID)
        let targetCount = removed.groups.first(where: { $0.id == groupID })?.tabIDs.count ?? 0
        let adjustedIndex = min(max(index, 0), targetCount)
        return removed.inserting(tabID, in: groupID, at: adjustedIndex, selecting: false)
    }

    /// Returns a topology with a tab detached into a new native window group.
    public func detaching(_ tabID: TabID, newGroupID: UUID = UUID()) -> Self {
        guard let source = group(containing: tabID), source.tabIDs.count > 1 else {
            return self
        }
        let sourceIndex = groups.firstIndex(where: { $0.id == source.id }) ?? groups.count - 1
        let remaining = removing(tabID)
        var nextGroups = remaining.groups
        let insertionIndex = min(sourceIndex + 1, nextGroups.count)
        nextGroups.insert(
            .init(id: newGroupID, tabIDs: [tabID], selectedTabID: tabID),
            at: insertionIndex
        )
        return .init(groups: nextGroups, activeGroupID: newGroupID)
    }

    /// Returns a topology with one group appended to another.
    public func merging(group groupID: UUID, into targetGroupID: UUID) -> Self {
        guard groupID != targetGroupID,
              let source = groups.first(where: { $0.id == groupID }),
              let target = groups.first(where: { $0.id == targetGroupID }) else {
            return self
        }
        let targetIndex = groups.firstIndex(where: { $0.id == targetGroupID }) ?? groups.count
        var nextGroups = groups.filter { $0.id != groupID }
        let merged = Group(
            id: target.id,
            tabIDs: target.tabIDs + source.tabIDs,
            selectedTabID: target.selectedTabID
        )
        if let existingTargetIndex = nextGroups.firstIndex(where: { $0.id == targetGroupID }) {
            nextGroups[existingTargetIndex] = merged
        } else {
            nextGroups.insert(merged, at: min(targetIndex, nextGroups.count))
        }
        return .init(groups: nextGroups, activeGroupID: target.id)
    }
}
/// A concrete source-array move detected before a native topology update.
public struct WindowTabMove: Equatable {
    /// The stable tab identity that changed position.
    public let id: AnyHashable
    /// The zero-based source index before the move.
    public let fromIndex: Int
    /// The zero-based source index after the move.
    public let toIndex: Int

    /// Creates a source-array move description.
    public init(id: AnyHashable, fromIndex: Int, toIndex: Int) {
        self.id = id
        self.fromIndex = fromIndex
        self.toIndex = toIndex
    }
}
#endif
#endif
