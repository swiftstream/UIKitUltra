# Development Orchestration

Model-independent authority for coordinating UIKitPlus repository work with LLMs and coding agents.

This file owns **roles, delegation, independent review, and execution gates**. UIKitPlus-specific PLAN/IMPLEMENT/AUDIT mechanics remain in `DEVELOPMENT_PHASES.md`. Detailed `.artifacts/**` structure and task/report mechanics are owned by `ARTIFACTS_WORKFLOW.md`.

## Roles

### Coordinator / Reviewer

For non-trivial work, the stronger reasoning/review layer:

- restores current context from real Git, source, and stable docs;
- performs or directs focused research;
- designs and independently audits the implementation plan;
- grounds behavior-affecting work in the relevant UIKitPlus architecture IDs and owners;
- decomposes substantial work into numbered surgical task files;
- gives the implementation executor only a short coordinator prompt;
- independently inspects actual source, diff, Git state, and validation after execution;
- turns audit findings into focused correction task files;
- synchronizes durable stable documentation after accepted work;
- performs the lazy public-content capture check after meaningful work;
- keeps commit and push as separate explicit gates.

Executor reports are evidence, never proof.

### Implementation Executor

The executor implements an already-reviewed task contract:

- reads the next numbered task immediately before work;
- modifies only its explicit scope/allowlist;
- follows closed mechanics without redesigning UIKitPlus architecture;
- preserves fluent/reference semantics and relevant architecture-ID contracts;
- runs required validation and inspects the actual diff;
- appends execution evidence after the task;
- continues automatically to the next already-approved task after PASS;
- stops the whole run on a genuine out-of-scope blocker.

The executor does not broaden scope merely to keep moving.

## Default Flow

```text
verify current repository state
→ focused research
→ reviewed implementation plan
→ independent plan audit
→ numbered surgical task files when needed
→ short coordinator prompt
→ autonomous sequential execution + append-only evidence
→ independent source/diff/Git audit
→ numbered correction wave if needed
→ independent re-audit
→ durable-doc synchronization
→ lazy public-content capture check
→ explicit commit gate
→ explicit push gate when requested
```

For non-trivial iterative work, `ARTIFACTS_WORKFLOW.md` is mandatory and externalizes this flow under `.artifacts/**`.

## Delegation Rule

Never send an implementation executor one huge prompt containing several independent behaviors or a full correction audit.

Instead:

1. group work into tightly coupled, independently verifiable behaviors;
2. put detailed mechanics, architecture IDs, allowlists, validation, and stop conditions into numbered task files;
3. give the executor one compact coordinator prompt that lists those files and the autonomous task loop.

If the coordinator prompt starts duplicating all task details, fix the decomposition before execution.

## Planning Gate

Non-trivial production work requires reviewed planning when it crosses multiple files/owners, changes public DSL/API behavior, state/listener propagation, layout/runtime lifecycle, platform boundaries, native UIKit/AppKit integration, concurrency, persistence, or other architecture-sensitive behavior.

The plan must be grounded in current source/Git facts and close:

- scope and non-goals;
- relevant architecture owners and IDs;
- analogous existing UIKitPlus implementations and reusable patterns;
- native-wrapper vs UIKitPlus-convenience layering where applicable;
- ownership/lifecycle/mutation mechanics;
- allowed/forbidden mutation paths;
- fluent-chain, state, extension, layout, and platform risks as relevant;
- validation and rendered/live acceptance when applicable;
- documentation synchronization targets;
- stop conditions.

Known plan defects are corrected before implementation.

## Independent Audit

After executor work, independently inspect:

- complete Git status and changed paths;
- actual changed/created source and direct callers;
- relevant architecture owners/IDs;
- fluent-chain/reference semantics;
- state/listener ownership and mutation flow;
- native UIKit/AppKit ownership/lifecycle and platform boundaries;
- project/dependency changes;
- forbidden/deferred scope;
- actual validation evidence.

Do not treat compilation, tests, rendered acceptance, or an executor report alone as architecture proof.

If the coordinator/reviewer cannot directly execute a required verification because its tool surface lacks the necessary command/runtime/UI capability, do not leave that evidence permanently unverified. Create a focused read-only verification task/prompt for an agent that has the required environment/tools, require exact commands/observations and a written report artifact, then review that report together with every repository fact that can still be checked directly. Clearly distinguish delegated execution evidence from directly inspected source/Git evidence.

If defects remain, create a new focused numbered correction wave instead of one large correction prompt.

## Milestone Completion Audit

A roadmap milestone is not complete merely because its implementation tasks, correction waves, builds, tests, and rendered/live acceptance passed.

Before declaring a substantial roadmap milestone complete or moving its implementation to the final commit/integration gate, run one additional independent conformance audit using a different strong reviewer model/session from the implementation executor and, where practical, from the primary coordinator that designed the work.

That final auditor reviews the complete delivered milestone against the current roadmap and relevant stable architecture/governance owners, not only the latest diff. It must inspect actual repository state and verify that resulting public API, fluent semantics, state/runtime ownership, native-platform behavior, lifecycle, and deferred scope still match the intended milestone contract.

Record the final milestone audit under `.artifacts/reviews/`. Any blocker found there reopens a focused correction wave. Only a clean independent milestone-conformance verdict allows stable milestone/task documentation to mark the milestone complete and proceed to the final Git gate.

This extra audit is for substantial roadmap milestones, not every typo, tiny documentation fix, or isolated low-risk patch.

## Prompt Rules

Agent prompts are written in English unless the maintainer explicitly requests otherwise.

Every prompt should identify the repository/context, role, exact scope or task files, mutation permissions, Git prohibitions, stop conditions, and expected evidence.

Do not make prompts self-contained by duplicating large task files. For artifact-driven execution, self-containment means the prompt explicitly points to the authoritative local task artifacts the executor must read.

## Context Discipline

Do not bulk-load all task files into coordinator/executor context.

- Coordinator/reviewer loads only the artifacts, stable owners, and source needed for the current planning/audit step.
- Executor reads the next numbered task immediately before executing it.
- `PUBLIC_CONTENT_IDEAS.md` and its shards are not normal development context. Perform the capture check from current work first; open the router plus one relevant shard only when the check is positive or the task is explicitly public-content work.
- Operational workflow docs do not consume architecture-doc slots; architecture loading remains governed by `CONTEXT_LOADING_RULES.md`.

## Git Gates

Implementation remains unstaged unless the maintainer explicitly authorizes staging/commit scope.

Normal implementation tasks forbid staging, commit/amend, merge/rebase/reset/restore/clean/stash, branch mutation, push, unrelated fixes, and history rewriting.

Commit and push are separate phases governed by `COMMIT_RULES.md` and explicit maintainer authorization. UIKitPlus's existing push lock remains in force until its project-specific prerequisites are satisfied and the maintainer explicitly authorizes push.

## Disposable Working Memory

`.artifacts/**` may be deleted or absent on another machine. Stable workflow/architecture must remain recoverable from `AGENTS.md`, `.agent/**`, Git, source, and current maintainer instruction.

Use `ARTIFACTS_WORKFLOW.md` for artifact structure, `NEW_CHAT.md` reconstruction, task/report conventions, correction waves, verification artifacts, and promotion of durable facts back into stable docs.
