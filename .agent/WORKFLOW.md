# Workflow

UIKitPlus uses a documentation-governed ChatGPT -> Codex -> ChatGPT loop.

## Loop

```
PLAN -> IMPLEMENT -> AUDIT -> LOCAL COMMIT -> NO PUSH
```

1. ChatGPT or developer defines task intent and scope.
2. Codex performs architecture-grounded planning.
3. Codex implements approved scope.
4. Patch/output is reviewed against architecture contracts.
5. Documentation is synchronized before closure.
6. Local commit after audit acceptance.
7. No push.

## Execution Rules

- Planning precedes mutation.
- Implementation prompt must list allowed/forbidden files.
- Implementation remains patch-minimal and architecture-safe.
- Audit must inspect actual git state and diffs.
- OpenCode reports are not accepted without ChatGPT direct audit.
- No task closes without `.agent` sync.
- PLAN, IMPLEMENT notes, AUDIT, and review outputs must include architecture-ID tags (for example: `[ST12][MU04][FC02]`).
- No push until independent 52-commit audit is accepted.
- Docs-only tasks must not edit Swift source.
- Source tasks must sync docs when durable facts change.

## Traceability Enforcement

- Architecture-aware task flow is invalid without architecture-ID grounding.
- Workflow artifacts without architecture-ID traceability are incomplete.
- Review artifacts without architecture references fail enforcement.

## Entrypoint Order

1. `AGENTS.md`
2. `.agent/ARCH_INDEX.md`
3. `.agent/architecture/LAYER_MODEL.md`

Then load only task-relevant docs.
