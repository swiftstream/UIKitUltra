# Artifacts Workflow

Stable operational authority for how UIKitPlus uses transient `.artifacts/**` working memory during research, planning, implementation, correction, audit, verification, and chat handoff.

This file defines the **workflow around artifacts**. Artifact contents never outrank root `AGENTS.md` or stable `.agent/**` authority.

## Core Principle

`.artifacts/**` is disposable working memory.

It exists to keep long iterative work precise without forcing one model prompt or one chat context to carry the whole task.

It may be deleted at any time, unavailable on another machine or clean clone, or intentionally reconstructed from current repository facts.

Therefore:

- stable rules and durable architecture never depend on `.artifacts/**` existing;
- `.artifacts/**` remains ignored by Git;
- plans/reports/task files are evidence and execution instructions, not permanent product authority;
- after meaningful durable changes, synchronize the correct stable `.agent/**` owner rather than relying on an artifact forever;
- if artifacts disappear, reconstruct only what current Git/source/stable docs support. Never invent lost historical evidence;
- keep exactly one clearly active research/plan/task lineage for the current substantial objective. When a maintainer-authorized course correction invalidates an old lineage, consolidate or remove obsolete executor entry points rather than leaving several plausible active prompts side by side;
- build products, dependency checkouts, disposable package/source clones, compiler workspaces, native build trees, CMake/MSBuild intermediates, index stores, caches, generated dependency trees, and other reproducible machine output are **temporary execution material**, not archival evidence;
- before closing a research/implementation/correction/verification/audit lineage, preserve only the smallest evidence needed to prove its conclusions, then remove reproducible heavy machine output owned by that lineage;
- do not copy an existing `.artifacts/**` tree into a disposable build workspace. Copy only the exact source/configuration inputs required by the probe.

## Mandatory End-of-Prompt Build / Temp Cleanup

Every local execution agent that creates disposable machine output MUST clean up that output **before its final response**, regardless of whether the prompt ends in `PASS`, `CLEAN`, `BLOCKED`, `STOP`, `INCOMPLETE`, or another terminal result.

Cleanup is part of prompt completion. It is not optional follow-up maintenance for the coordinator or maintainer.

This rule applies to **every** local prompt that creates temporary build/runtime material, including a single probe or verification task even when the rest of `ARTIFACTS_WORKFLOW.md` would not otherwise be needed for a trivial task.

### What must be cleaned

Before the final response, inspect every prompt-owned temporary location used during execution and remove reproducible residue created by that prompt, including when applicable:

- `.build/`, `build/`, `Build/`, `CMakeFiles/`, CMake caches, MSBuild/intermediate/output trees, DerivedData-like trees, object files, generated binaries, symbol/debug output, index stores, and compiler caches created inside `.artifacts/**` or another disposable workspace;
- dependency/package checkouts, NuGet restore trees, SwiftPM checkout/build trees, generated bindings, cloned external repositories, fixture repositories, temporary virtual environments, package-manager scratch, and source snapshots created only for the prompt;
- Unix-like prompt-local work under `/tmp` or another explicitly disposable temp root;
- Windows prompt-local work under `%TEMP%` or another explicitly disposable temp root;
- native UI/runtime probe directories, copied app bundles/packages, generated XAML/C++/Swift intermediates, screenshots duplicated outside the canonical evidence location, and other replayable machine output;
- superseded raw-command directories or duplicate logs after the smallest canonical evidence set has been retained.

The default rule is:

```text
prompt-owned + reproducible + disposable => delete before final response
```

### What should be preserved

Preserve only evidence intentionally required by the active artifact/evidence contract, normally the smallest set of:

- textual execution reports;
- raw command/runtime logs that are needed for causal or integrity proof;
- compact manifests, hashes, provenance records, metadata dumps, and source snippets/snapshots specifically frozen as evidence;
- screenshots/recordings required to prove rendered/native behavior;
- another exact artifact explicitly required by a frozen audit contract.

Do **not** preserve an entire build tree merely because one file inside it was useful evidence. First extract/copy the required small evidence into the canonical artifact location, record required hashes/provenance, then delete the reproducible build tree.

If a binary or other large generated file itself is explicitly required as frozen evidence, preserve only that exact file and record why it cannot be reduced to a textual/hash/provenance record. This is an exception, not the default.

### Immediate per-probe / per-task cleanup

Do not wait until a long multi-step prompt ends to accumulate gigabytes of disposable output.

After each discrete probe, verification run, or numbered task finishes and its required evidence has been extracted, delete that step's prompt-owned build/temp tree **before moving to the next independent step**.

A temporary tree may survive between steps only when a later step in the **same prompt** explicitly reuses it. In that case:

```text
create once
→ reuse only for the declared dependent steps
→ extract final required evidence
→ delete immediately after the last reuse
→ never leave it behind at final response
```

For example, a Windows WinUI fixture may be intentionally reused by an immediately following UI Automation provenance step, but its generated build/output tree must be removed as soon as the final dependent step has captured the required logs/hashes/screenshots. The same rule applies to Linux GTK/Qt scratch and SwiftPM/CMake probe workspaces.

### Reusable project-local build-state exception

Do not delete build/cache state intentionally created in the actual project as reusable project state for later work. A canonical example is the root SwiftPM `.build/` that normal project work is expected to reuse.

This exception is based on **location + intended reuse**, not merely on the directory name:

```text
repository-root reusable .build/                 => may preserve
.artifacts/**/<scratch>/.build/                   => delete
/tmp/<prompt-workspace>/.build/                   => delete
%TEMP%\<prompt-workspace>\.build\               => delete
disposable clone/workspace build output          => delete
```

Do not move prompt-local build output into the repository merely to avoid cleanup.

### Multi-host ownership rule

Cleanup must happen on the host where the prompt created the material.

For multi-host UIKitPlus work, each local executor is responsible for its own host-local scratch before completion. In particular, Unix-like `/tmp` work and Windows `%TEMP%` work must not be left for a later coordinator session merely because canonical reports live in the shared `.artifacts/**` tree.

Shared `.artifacts/**` should contain evidence, prompts, reports, and compact retained inputs — not persistent host build caches. If a probe must temporarily build beneath `.artifacts/**`, extract the required evidence and remove the heavy build residue immediately after the probe.

### Safety and proof of cleanup

Cleanup must be narrowly owned and non-destructive:

- remove only paths the prompt created or whose disposable ownership was independently established;
- never use broad destructive cleanup against an unknown temp root;
- never delete user-authored source/evidence, unrelated temp data, reusable project caches, or untracked user work merely because it is large;
- never use Git `clean`, reset, checkout, restore, stash, or another Git mutation as a substitute for prompt-local filesystem cleanup unless that exact Git operation was separately authorized.

Every executor/auditor/verification prompt that can create substantial build/temp output MUST restate this cleanup requirement in its completion contract.

The final local-agent response must include a compact cleanup disposition, for example:

```text
prompt-local build/temp cleanup: PASS
preserved heavy generated artifacts: none
```

If any large generated artifact is intentionally preserved, name it and state the evidence/reuse reason. A prompt must not claim `PASS`/`CLEAN` while known disposable prompt-owned build output remains.

If cleanup cannot be completed because the required host connector/session becomes unavailable, the agent must STOP rather than silently declaring completion, identify the known prompt-owned paths that may remain, and clean them immediately when the required host access is restored.

## Mandatory Use for Non-Trivial Iterative Work

For non-trivial development, especially multi-file public API/DSL, state/listener, layout/runtime, concurrency, native-platform, lifecycle, or cross-layer work, use `.artifacts/**` to externalize context before implementation.

Preferred lifecycle:

```text
restore current repo context
→ focused research
→ write research evidence
→ write implementation plan
→ independently audit plan
→ decompose implementation into surgical task files when needed
→ run implementation executor task-by-task
→ append execution evidence after every task
→ independently audit actual source/diff/Git
→ create surgical correction task files when needed
→ validate again
→ final milestone conformance review when applicable
→ synchronize durable docs
→ public-content capture check
→ separate commit gate
```

Do not collapse a large researched implementation into one enormous executor prompt.

## Mandatory Large-Task Decomposition Rule

When implementation contains multiple natural behavior groups, multiple independent mutations, cross-file lifecycle work, or enough detail that one executor prompt becomes long/cognitively dense, the coordinator MUST decompose it before asking an implementation executor to execute.

Detailed implementation mechanics belong in numbered `.md` task files under `.artifacts/**`.

The executor receives one **short coordinator prompt** that tells it only:

- which repository to work in;
- which numbered task files to execute and in what order;
- to read each task immediately before executing it;
- to obey each task's allowlist, architecture IDs, verification, and stop conditions;
- to append a report after every task;
- to continue automatically to the next task after PASS;
- to stop the whole run on an out-of-scope blocker rather than redesigning;
- not to stage/commit/push unless separately authorized.

The coordinator prompt must NOT duplicate detailed task requirements.

### Practical split threshold

Split rather than sending one large implementation prompt whenever any of these is true:

- more than one independently verifiable behavior is changing;
- more than one subsystem/architecture boundary is involved;
- implementation and validation have several distinct phases;
- concurrency/lifecycle corrections contain more than one independent race/ownership issue;
- the prompt would need long implementation-mechanics sections;
- a failed middle step should prevent later work from executing.

Prefer precise behavior-group tasks over one overloaded prompt, but do not create artificial one-line tasks that destroy locality.

## Recommended Directory Structure

Use a work-specific slug rather than one global plan for substantial work.

```text
.artifacts/
├── NEW_CHAT.md
├── planning/
│   └── <work-slug>/
│       ├── RESEARCH_REPORT.md
│       ├── IMPLEMENTATION_PLAN.md
│       └── PLAN_AUDIT.md
├── implementation/
│   └── <work-slug>/
│       ├── 01-<task>.md
│       ├── 02-<task>.md
│       ├── ...
│       ├── EXECUTION_REPORT.md
│       └── COORDINATOR_PROMPT.md
├── corrections/
│   └── <work-slug>/
│       ├── 01-<correction>.md
│       ├── 02-<correction>.md
│       ├── ...
│       ├── EXECUTION_REPORT.md
│       └── COORDINATOR_PROMPT.md
├── verification/
│   └── <work-slug>/
│       ├── VERIFICATION_TASK.md
│       ├── VERIFICATION_REPORT.md
│       └── COORDINATOR_PROMPT.md   # only when needed
├── reviews/
│   └── <focused-review>.md
└── patches/
    └── <temporary-patch-evidence>
```

Use only files/directories the current work needs. Do not manufacture empty bureaucracy.

## Planning Artifacts

### `RESEARCH_REPORT.md`

Stores verified evidence needed to design the work, for example:

- current Git/source state;
- relevant public APIs/types/ownership boundaries;
- architecture IDs and owning stable docs;
- analogous UIKitPlus implementations/patterns;
- dependency/native-platform behavior;
- current external API documentation when time-sensitive;
- known constraints and unknowns;
- facts implementation tasks must not rediscover from memory.

Research must distinguish verified facts from architectural conclusions.

### `IMPLEMENTATION_PLAN.md`

Contains the reviewed implementation design:

- exact goal/scope and non-goals;
- architecture owners/IDs;
- public API/DSL effects;
- native-wrapper vs UIKitPlus-convenience layering when applicable;
- ownership/lifecycle/mutation mechanics;
- source topology;
- fluent/state/extension/platform implications;
- validation strategy;
- explicit deferred work.

It must be implementation-ready before an executor receives production mutation work.

### `PLAN_AUDIT.md`

Records the coordinator/reviewer's independent audit of the plan against actual source, governance, architecture IDs, native/dependency facts, and Git state.

A plan is not accepted merely because the planning agent wrote it.

## Surgical Implementation Task Contract

Each numbered implementation/correction task should contain only context needed for one tightly coupled behavior group.

Use this shape when applicable:

```text
# Task NN - Title

## Goal
## Preconditions
## Architecture owners / IDs
## Allowed production paths
## Required implementation
## Ownership / lifecycle / concurrency rules
## Explicitly forbidden work
## Verification
## Completion report
## Stop conditions
```

Every task must be mechanically clear enough that the executor does not need to invent architecture.

Important:

- exact path allowlists are strongly preferred;
- state which earlier task output may be relied on;
- identify relevant fluent/state/extension/platform invariants;
- state what must be revalidated after `await`/external work when relevant;
- include the smallest meaningful build/test/rendered/native gate;
- if a task exposes a plan contradiction requiring broader scope, stop rather than silently widen scope.

## Autonomous Executor Loop

For a prepared multi-task implementation, the executor follows:

```text
read Task NN completely
→ inspect required current Git/source facts
→ implement only Task NN allowlist
→ run Task NN verification
→ inspect actual diff
→ append Task NN result to EXECUTION_REPORT.md
→ if PASS: immediately continue to Task NN+1
→ if BLOCKED: append blocker and stop entire run
```

The executor does not ask the maintainer for confirmation between already-approved numbered tasks.

## `EXECUTION_REPORT.md`

Execution reports are append-only evidence.

After each task append a distinct section containing:

- actual paths changed;
- implementation facts;
- architecture IDs/contracts applied;
- exact validation commands/results;
- rendered/native/live evidence when actually observed;
- Git state;
- deviations/blockers.

Never rewrite earlier task sections to hide a failed/stopped attempt. A resumed task appends a new clearly named section.

An executor report is never proof by itself. The coordinator/reviewer independently inspects actual source/diff/Git afterward.

## Verification Delegation

When the coordinator/reviewer lacks a direct tool needed for a required build/test/runtime/UI/native check, create a focused verification artifact instead of accepting a blind spot.

Recommended shape:

```text
.artifacts/verification/<work-slug>/
├── VERIFICATION_TASK.md
├── VERIFICATION_REPORT.md
└── COORDINATOR_PROMPT.md   # only when delegation needs a separate prompt
```

The verification task is read-only unless the maintainer explicitly authorizes otherwise. It states exact commands/actions, required observations, environment assumptions, report format, and Git-mutation prohibitions.

For rendered UIKit/AppKit/UIKitPlus diagnostics on any UI surface, use `.agent/skills/uikitplus-visual-ui-diagnostics/SKILL.md` when temporary high-contrast markers can objectively prove the target's actual rendered presence, boundary, viewport relationship, clipping, or native ownership. Keep the real repository read-only for read-only verification and place any instrumented source/build in a disposable `/tmp` copy or another explicitly disposable verification-only copy. Save screenshots/recordings plus the relevant geometry/runtime evidence under the verification artifact directory and record a marker legend explaining exactly what each diagnostic color/boundary represented. Diagnostic instrumentation must never become a production change merely because it made the bug observable.

The delegated agent writes the report from actual execution. The coordinator/reviewer then checks the report plus every repository fact available through its own tools. Delegated evidence fills an execution-capability gap; it does not replace independent source/Git review.

## Final Milestone Conformance Review

After implementation, corrections, strict validation, and rendered/native/live acceptance pass for a substantial roadmap milestone, create one final milestone review under `.artifacts/reviews/` before stable docs mark that milestone complete.

Use a different strong reviewer model/session from the implementation executor and, where practical, from the primary coordinator. The review evaluates the **whole delivered milestone** against current roadmap and relevant stable owners, including public API, fluent semantics, state/runtime ownership, native-platform behavior, lifecycle, and deferred scope.

A clean final conformance verdict is required before the milestone completion/commit/integration gate. Findings become a new focused correction wave.

Do not impose this whole-milestone ceremony on trivial documentation or isolated low-risk fixes.

## Correction Waves

After independent implementation audit, do not send one giant correction prompt containing every defect.

Instead:

1. group findings into the smallest coherent correction behaviors;
2. create numbered files under `.artifacts/corrections/<work-slug>/`;
3. define exact allowlists, architecture IDs, and validation for each;
4. create/reset an append-only correction `EXECUTION_REPORT.md` for that wave;
5. give the executor one short coordinator prompt pointing to those files;
6. let the executor run them sequentially and automatically;
7. independently audit the final source again.

If another materially distinct issue appears, create another focused correction wave rather than growing the old coordinator prompt.

## `COORDINATOR_PROMPT.md`

This file is intentionally compact and contains orchestration only.

Minimum responsibilities:

```text
repository / role
baseline Git expectations
list of numbered task files
execute numerically
read one task immediately before work
append report after each task
continue automatically after PASS
stop on blocker
Git mutation prohibitions
per-probe/per-task disposable build-temp cleanup
final cleanup disposition
compact final report shape
```

If it starts restating detailed implementation requirements from every task, the decomposition has failed.

## `NEW_CHAT.md` Purpose

`.artifacts/NEW_CHAT.md` is transient continuity handoff for the **next coordinator/reviewer conversation**, not stable governance.

It should preserve enough current context to continue without repeating long prior discussions or reopening accepted decisions.

Refresh it after continuity-critical transitions such as:

- branch/HEAD phase changes;
- accepted audit/correction verdicts;
- prerequisite completion;
- new active planning/implementation/correction artifacts;
- important stop/blocker state;
- exact next intended action;
- workflow constraints needed for continuation but not stable architecture.

Do not turn it into an ever-growing transcript. Supersede stale continuation instructions with a current snapshot while preserving only rationale that remains useful.

## Recreating `.artifacts` on a New Machine or After Deletion

If `.artifacts/` or `NEW_CHAT.md` is missing:

1. read root `AGENTS.md` and the minimum stable `.agent/**` governance needed for the task;
2. inspect current Git branch/HEAD/status directly;
3. inspect `TASKS.md`, `PROJECT_MEMORY.md`, `SOURCE_MAP.md`, `TODO.md`, `TECH_DEBT.md`, and relevant architecture owners only as needed;
4. inspect actual changed source and recent relevant Git history rather than guessing unfinished work;
5. identify the current work phase from repository evidence and maintainer instruction;
6. create `.artifacts/` directories only as needed;
7. create a fresh `.artifacts/NEW_CHAT.md` from **verified current facts**;
8. if non-trivial work is continuing, recreate fresh research/plan/task artifacts rather than pretending deleted transient plans still exist;
9. never infer uncommitted/lost implementation evidence no longer present on disk.

A reconstructed `NEW_CHAT.md` should normally contain:

```text
repository identity/path used in this environment
current branch / HEAD / Git status
current milestone/work phase
stable governance and architecture owners relevant to continuation
verified completed/accepted work that constrains the next step
current uncommitted user/agent changes and preservation rules
active dependency/native API facts needed by the work
current artifact index, if artifacts were recreated
next intended action
agent/orchestration rules required for continuation
```

Machine-local paths/tool context IDs are allowed in `NEW_CHAT.md` because it is transient. Stable `.agent/**` documentation must remain portable.

## Promotion to Stable Documentation and Public-Content Capture

At the end of an accepted implementation/correction cycle, decide what learned information is durable.

At the same continuity-critical checkpoints where `NEW_CHAT.md` is refreshed, perform the lazy public-content capture check owned by `PUBLIC_CONTENT_IDEAS.md`. Do **not** open the bank automatically. First decide from current work whether a genuinely useful README/docs/website/release/migration/publication example, capability, validation result, or explanation appeared. Only on a positive result open the router plus one relevant shard and append the smallest useful entry while context is fresh.

`NEW_CHAT.md` and the public-content bank have different lifecycles:

- `NEW_CHAT.md` is transient/disposable execution continuity;
- `PUBLIC_CONTENT_IDEAS.md` and its shards are durable versioned candidate communication material.

Promote durable facts/rules into the correct stable owner:

- architecture rule -> owning architecture document;
- workflow rule -> `WORKFLOW.md` / `DEVELOPMENT_ORCHESTRATION.md` / this file / `COMMIT_RULES.md`;
- source navigation fact -> `SOURCE_MAP.md`;
- durable current-state fact -> `PROJECT_MEMORY.md`;
- active executable work -> `TASKS.md`;
- low-priority future idea -> `TODO.md`;
- verified debt -> `TECH_DEBT.md`.

Do not promote execution diaries, transient commit hashes, local tool IDs, temporary logs, or massive implementation reports.

## Git Rule

`.artifacts/` must remain ignored by repository `.gitignore`.

Do not stage/commit artifacts merely because they were useful during development. They are intentionally local/transient unless the maintainer explicitly changes this repository policy.
