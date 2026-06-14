# Context Budget

Token discipline is mandatory for stable agent behavior.

## Target Budget

- Typical task context: `3000-7000` tokens.

## Loading Priority

1. Architecture routing (`ARCH_INDEX`, `LAYER_MODEL`)
2. One domain architecture doc
3. One contract doc
4. Targeted source reads
5. Skill and template docs

## Budget Rules

- Keep active architecture docs <= 3 by default.
- Avoid full-file reads for large files when symbol-level reads are enough.
- Do not preload all skills or templates.
- Prefer incremental context growth.

## Safety Override

If budget must be exceeded, load the smallest additional context required and record the reason in PLAN/AUDIT notes.
