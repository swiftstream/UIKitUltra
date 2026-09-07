# Public Content Ideas

Stable low-context workflow owner for preserving high-value user-facing examples, capabilities, documentation angles, README material, website-documentation ideas, release/migration stories, and publication/post concepts discovered during UIKitPlus development.

This is an **idea bank, not normal implementation context**. Detailed entries live in focused shards under `.agent/public-content-ideas/` so ordinary development does not pay their context cost.

## Why this exists

Architecture, implementation, native validation, audits, and corrections often reveal examples that explain UIKitPlus better than a later documentation pass could reconstruct from memory.

Useful material may include:

- a clean declarative API example;
- a before/after native UIKit/AppKit wrapper story;
- a feature that demonstrates UIKitPlus's native-first design advantage;
- a non-obvious compatibility or lifecycle guarantee;
- a migration example for a changed public API;
- a rendered/native validation result that increases user trust;
- an engineering story suitable for an article or short post;
- a diagram that makes fluent/state/native ownership easier to understand.

Capture these while evidence/reasoning is fresh. Publication/editing happens later and only with maintainer approval.

## Capture Rule

After meaningful research, design, implementation, correction, audit, or an accepted checkpoint, the coordinator/reviewer MUST perform a very short **public-content capture check** from information already in context:

> Did this work produce a genuinely useful public-facing example, capability, explanation, migration note, validation result, or publication angle that would be difficult or wasteful to rediscover later?

If **no**:

- do nothing;
- do not open this bank.

If **yes**:

1. open only this router and the single relevant thematic shard;
2. append the smallest useful entry while context is fresh;
3. record truthful lifecycle/status, provenance, and publication caveats;
4. do not polish into final marketing copy unless the current task is explicitly public documentation/content work;
5. continue normal development without loading unrelated shards.

This check is analogous in timing to keeping `.artifacts/NEW_CHAT.md` current, but their ownership/lifecycles differ:

- `.artifacts/NEW_CHAT.md` preserves transient execution continuity and is disposable;
- this bank preserves durable **candidate public communication value** and is versioned under `.agent/**` until the maintainer explicitly curates/removes/promotes entries.

## Context-Budget Rule

Do **not** load this bank or its shards during ordinary source work merely because they exist.

Load them only when:

- the capture check is positive;
- the task is README/public docs/website docs/release notes/migration guide/article/post preparation;
- the maintainer explicitly asks to review/curate public-content ideas.

Never bulk-load all shards. Read the router, then exactly the relevant shard(s).

This bank does not consume architecture-doc slots.

## Shard Layout

Current shards:

- `public-content-ideas/NATIVE_PLATFORM_INTEGRATION.md` - native-first UIKit/AppKit integration stories, declarative wrappers, native topology/lifecycle preservation, platform-feature mapping, and native validation evidence.
- `public-content-ideas/PACKAGING_MIGRATIONS.md` - dependency-manager support changes, package-layout migrations, release-note requirements, and user migration guidance.

Create a new shard only when a topic becomes independently useful enough that adding it to an existing shard would create context noise. Prefer stable topic names over one file per small idea.

Potential future shards, only when justified by real captured material, might cover:

- state/binding developer experience;
- fluent DSL evolution and compatibility;
- layout/constraint architecture;
- migration stories;
- validation/correctness engineering.

Do not pre-create empty shards.

## Entry Contract

Each captured entry should be compact and include only what future public-writing work needs:

```text
## Short descriptive title

Status: idea | architecture-approved | implemented | validated | shipped | superseded
Good for: README | website docs | migration guide | release notes | article | short post

### Why users should care
A few sentences describing user/engineering value.

### Candidate example / visual
Small code/diagram/snippet worth preserving.

### Evidence / provenance
Stable owner, source/test/native evidence, and/or commit when useful.

### Publication caveat
Anything future writers must not overclaim.
```

Entries may omit sections that add no value, but **status and publication caveat are mandatory for anything not already verified as shipped**.

## Status Discipline

Use status truthfully:

- `idea` - worth preserving, not approved architecture;
- `architecture-approved` - accepted design, not implemented/shipped;
- `implemented` - source exists but final validation/release may still be pending;
- `validated` - intended behavior passed the relevant repository/native validation gate;
- `shipped` - part of an actual released/publicly supported version;
- `superseded` - retained only when historical/migration/publication value remains.

Never turn an implemented or architecture-approved example into public wording that implies it has shipped.

## Provenance and Commits

When an idea is captured before an implementation commit exists, record current architecture/evidence source and add a future commit hash only if it materially helps verification.

Do not require every tiny idea to carry a hash. Use hashes where they anchor a meaningful design/implementation/validation milestone.

## Promotion and Cleanup

This bank is a staging area for communication value, not permanent duplication of public docs.

Only with explicit maintainer approval may future work:

- promote entries into `README.md`;
- promote them into public website/docs sources;
- use them for release notes or migration guides;
- turn them into article/post outlines;
- merge/deduplicate shards;
- remove entries that are fully published, superseded, or no longer useful.

Do not automatically delete an entry merely because one public document used it; the same idea may still matter for another channel. Curation/removal is maintainer-controlled.

## Quality Bar

Capture only material with real future communication value.

Good candidates answer at least one:

- "This makes UIKitPlus noticeably easier/cleaner/safer for users."
- "This example explains an important capability in a few lines."
- "This native integration choice is a strong engineering story."
- "Users upgrading or extending UIKitPlus will benefit from knowing this."
- "This native/rendered validation result meaningfully increases trust."

Do not fill the bank with routine refactors, generic praise, task bookkeeping, or test counts without a meaningful user/engineering story.
