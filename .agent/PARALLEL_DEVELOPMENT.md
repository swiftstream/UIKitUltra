# Parallel Development

Focused stable owner for UIKitUltra linked-worktree development.

**Lazy-load rule:** do not read this file for ordinary single-checkout work. Load it only when creating, operating, auditing, handing off, or integrating a parallel worktree lane.

Concrete active paths, branches, base SHAs, lane status, launch prompts, and migration state belong in canonical `.artifacts/parallel/**`, not here.

## Core Model

Exactly one checkout is the **primary canonical development line**.

Primary owns:

- Apple implementation/compatibility;
- shared/common `U*` API and backend-neutral values;
- package-wide architecture;
- Unified Layout and shared State integration;
- stable governance;
- final cross-lane reconciliation/integration.

A parallel lane is subordinate even when locally complete/audited.

## Lane Bootstrap

Create a lane only when isolated parallel work is materially useful and its scope/integration boundary are clear.

Every lane starts from an explicit committed base:

```text
BASE_COMMIT
BASE_SUBJECT
BASE_RATIONALE
```

Never:

- copy dirty primary files into a lane;
- treat uncommitted primary bytes as ancestry;
- delete/recreate an unexplained existing worktree for convenience;
- use detached-first development as the normal lane model.

If a required shared capability exists only in newer/uncommitted primary work, use `PRIMARY_SYNC_REQUIRED` and reconcile through primary rather than silently copying/merging it.

## Canonical Artifact Authority

Lane coordination artifacts live only under the **primary checkout**:

```text
<PRIMARY_REPO>/.artifacts/parallel/<lane-slug>/
```

A lane worktree must not establish a competing coordination `.artifacts` authority.

Use the lane worktree for source/Git/project operations and the primary checkout for current stable-governance reads plus canonical lane-artifact writes.

When multiple local project contexts are open, route operations with explicit context identity.

## Governance Loading

A lane uses **current primary stable governance**, not merely the historical docs frozen in its base commit.

Load only the owners required by the current lane task under `CONTEXT_LOADING_RULES.md`; do not preload the whole primary documentation tree.

Architecture/source facts tied to the lane revision must still be verified against actual lane source.

## Development Quality

Parallelism does not lower the normal workflow or audit bar. Use `DEVELOPMENT_ORCHESTRATION.md`, `ARTIFACTS_WORKFLOW.md`, validation owners, and the relevant architecture owner exactly as the current task requires.

A lane may reach local implementation/audit/runtime/conformance completion without becoming canonically integrated.

## Shared-Contract Gates

If a lane needs a newer shared primary capability not in its base:

`PRIMARY_SYNC_REQUIRED`

If a lane discovers/proposes a change to common/shared behavior, including universal DSL, common values, State, layout, package graph, lifecycle, or another backend:

`CROSS_LANE_INTEGRATION_REQUIRED`

The lane may research/propose or build an explicitly authorized branch-local candidate, but final shared-contract acceptance belongs to primary.

Do not silently merge/rebase/copy primary dirty state to resolve either gate.

## Integration Handoff

Before primary integration, a lane reports at minimum:

```text
base commit
exact branch HEAD
checkpoint commit inventory
changed paths vs base
validation/audit/runtime status
stable-doc candidate changes
known primary overlap
PRIMARY_SYNC_REQUIRED state
CROSS_LANE_INTEGRATION_REQUIRED state
recommended reconciliation strategy
```

Primary/maintainer chooses merge/cherry-pick/rebase/reimplementation/reconciliation strategy. A lane never integrates itself into primary merely because its local branch is clean.

## Backend Lanes

Substantial GTK, Qt, Win, Android, and TUI implementation is expected to use isolated linked worktrees once exact committed bases are frozen.

Backend lanes own backend implementation/evidence. Primary retains common/API/layout/State/package-wide authority.

Exact lane roster, paths, branches, base commits, and current blockers belong in the active `.artifacts/parallel/**` / migration lineage.

## Git Safety

Lane staging/commit/push follows `COMMIT_RULES.md` and explicit authorization.

Checkpoint commits belong only to the lane branch. A subordinate lane must not stage/commit primary source or canonical `.artifacts/**`.

Push/history rewriting remain separate gates.

## Stable vs Transient Boundary

Keep here only reusable worktree invariants.

Keep transient:

```text
absolute worktree paths
active lane roster
branch names/base SHAs
current phase/status/blockers
artifact/report SHAs
session prompts
one-time migration instructions
handoff snapshots
```

If a transient procedure proves generally reusable, promote only that rule and leave execution history in artifacts.
