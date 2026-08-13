# Context Budget

Token discipline is mandatory for stable agent behavior.

## Target Budget

- Typical task context: `3000-7000` tokens when the task can safely fit there.

## Loading Priority

1. Root routing (`AGENTS.md`).
2. Operational orchestration/artifact owners only for non-trivial iterative work.
3. Architecture routing (`ARCH_INDEX.md`, `LAYER_MODEL.md`).
4. One domain architecture doc.
5. One supporting contract doc when needed.
6. Targeted source reads.
7. One relevant skill/template only when useful.

## Budget Rules

- Keep active architecture docs <= 3 by default.
- `DEVELOPMENT_ORCHESTRATION.md` and `ARTIFACTS_WORKFLOW.md` are operational workflow docs and do not consume architecture-doc slots.
- `PUBLIC_CONTENT_IDEAS.md` and its shards are lazy communication context. Do not preload them; after a positive capture check load only the router plus the relevant shard.
- Do not bulk-load `.artifacts/**`. Read only the active research/plan/review artifact or the next numbered task needed for the current step.
- Avoid full-file source reads when symbol/section-level reads are enough.
- Do not preload all skills/templates.
- Prefer incremental context growth and stop at decision-complete context.

## Safety Override

If the budget must be exceeded for a cross-cutting architecture/governance audit or safety-critical task, load the smallest additional context required and record why in the relevant plan/audit artifact.
