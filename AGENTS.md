# UIKitPlus Agent Governance

## 1. Repository Identity

UIKitPlus is a declarative, protocol-oriented UI framework built on top of UIKit/AppKit.

Key characteristics:
- Fluent, chain-based API surface (`Self`-returning modifiers).
- Extension-driven feature composition (`DeclarativeProtocol+Feature.swift` pattern).
- Reference-semantic reactive state engine (`State`, `InnerState`, mapped/bound states).
- Deferred + state-backed layout constraint system (`PreConstraint`, solo/super/relative activation).
- Cross-platform abstraction via conditional UIKit/AppKit bridges.
- Ownership-driven application architecture: local UI state belongs to its `UView`/`ViewController`, sibling-shared state to the nearest common composition owner, app-wide environment to `App`, and authoritative runtime state to dedicated domain/runtime owners.

UIKitPlus is **not a game**. There is no deterministic simulation, no Godot, no fixed tick rate, no seeded RNG requirement, and no RenderSnapshot contract.

This repository is documentation-governed and architecture-frozen by default.

## 2. Authoritative Documents

Primary entrypoint:
- `.agent/ARCH_INDEX.md`

Critical architecture contracts:
- `.agent/architecture/LAYER_MODEL.md`
- `.agent/architecture/FLUENT_CHAIN_CONTRACT.md`
- `.agent/architecture/STATE_SYSTEM.md`
- `.agent/architecture/EXTENSION_SYSTEM.md`
- `.agent/architecture/RUNTIME_MODEL.md`
- `.agent/architecture/MUTATION_MODEL.md`

Default UIKitPlus application architecture:
- `.agent/architecture/APPLICATION_STATE_OWNERSHIP.md`
  - Read this for application state placement, dependency contracts, View/ViewController ownership, app-wide state, runtime/domain owner boundaries, fixture policy, and ViewModel/PresentationModel decisions.
  - Its `AO*` invariants are mandatory for UIKitPlus application architecture unless a repository explicitly documents and approves another architecture.

Workflow and governance:
- `.agent/WORKFLOW.md`
- `.agent/DEVELOPMENT_PHASES.md`
- `.agent/PATCH_REVIEW_RULES.md`
- `.agent/SYSTEM_RULES.md`
- `.agent/COMMIT_RULES.md`
- `.agent/VALIDATION_RULES.md`

Source and debt:
- `.agent/SOURCE_MAP.md`
- `.agent/TECH_DEBT.md`
- `.agent/TASKS.md`
- `.agent/TASKS_ARCHIVE.md`

State vNext planning:
- `.agent/STATE_VNEXT_PLAN.md`

Context discipline:
- `.agent/CONTEXT_LOADING_RULES.md`
- `.agent/CONTEXT_BUDGET.md`

## 3. Mandatory Workflow

All tasks must follow:

`PLAN -> IMPLEMENT -> AUDIT -> LOCAL COMMIT`

### Hard Scope Separation

This governance commit is **documentation-only**.

The following are **not** in scope for this docs closure:
- Swift source migration
- Test changes
- Swift 6 strict concurrency migration (deferred to later)
- State vNext implementation (deferred to later)
- 52-commit independent audit (deferred to later)
- Push to origin

### Architecture-ID Traceability (Mandatory)

All workflow artifacts must include architecture ID tags.
Required tag format example: `[ST12][MU04][FC02]`.

This is mandatory for:
- PLAN outputs,
- IMPLEMENT notes,
- AUDIT outputs,
- patch review outputs.

Enforcement:
- planning without architecture-ID grounding is incomplete,
- artifacts without architecture-ID traceability are incomplete,
- review outputs without architecture references fail enforcement.

### PLAN (no mutation)

Must include:
- target files and expected documentation updates,
- layer impact (`DSL`, `Runtime`, `Platform`, `Cross-Layer`),
- fluent-chain compatibility risk,
- mutation-flow impact,
- extension-collision risk,
- state propagation risk,
- application state-ownership and dependency-surface impact when app code is involved,
- platform leakage risk.
- architecture-ID tags for each risk/decision line.

### IMPLEMENT

Rules:
- implement approved scope only,
- do not introduce undocumented contracts,
- do not drift architecture,
- keep UIKitPlus fluent/reference semantics intact,
- keep extension composition stable and predictable,
- keep application state with its natural owner and expose only exact state/value/callback dependencies.
- implementation notes must include architecture-ID tags for each behavior-affecting change.

### AUDIT

Must validate:
- fluent chain contract compliance,
- state and binding propagation correctness,
- application state ownership and absence of replacement state bags when relevant,
- extension collision/precedence safety,
- runtime lifecycle consistency,
- layout side-effect safety,
- documentation synchronization.
- every audit finding must include architecture-ID tags.

## 4. Push Lock

DO NOT PUSH.

Push to origin is forbidden until governance docs are committed, independent 52-commit audit is accepted, critical regressions are fixed/deferred, Swift 6 / State vNext risks are documented, and the user explicitly authorizes push.

Local commits are allowed only after ChatGPT audit acceptance.

## 5. `.artifacts` Policy

- `.artifacts/**` is transient planning data.
- `.artifacts/**` must never be committed.
- Promote durable facts from `.artifacts/` to `.agent/` before discarding.
- `.artifacts/` is git-ignored via `.gitignore` entry `.artifacts/`.

## 6. Architecture Lock

- Architecture is frozen by default.
- Any DSL-breaking or contract-changing architecture update requires explicit approval.
- Agents must refuse silent architecture reinterpretation.

## 7. Non-Negotiable Safety Rules

1. Fluent API Safety:
- Chainable methods must preserve `Self`-return semantics and composability.
- Public core setter overloads and their DocC must satisfy FC11 and FC12.

2. Extension Isolation:
- Extensions must remain domain-scoped and avoid hidden global behavior.

3. No Hidden Side Effects:
- State mutations and listener wiring must be explicit and auditable.
- Classify every new or materially changed fluent value setter under ST8.

4. Layout Predictability:
- Constraint behavior must remain explicit, with no undocumented implicit activation side effects.

5. Platform Boundary Integrity:
- UIKit/AppKit conditionals must not leak platform-only APIs into shared contracts.

6. Application State Ownership:
- Do not introduce a ViewModel/PresentationModel by default for UIKitPlus UI state.
- Local UI state belongs to the nearest `UView`/`ViewController`; sibling-shared state belongs to the nearest common composition owner; app-wide environment belongs to `App`; authoritative runtime/domain state belongs to a justified dedicated owner.
- Children receive only exact `UState` references, immutable values, or focused callbacks.
- A renamed context/store/environment object containing unrelated mutable UI state is still a forbidden all-state bag.
- Follow `.agent/architecture/APPLICATION_STATE_OWNERSHIP.md` and cite `AO*` invariants in application architecture work.

## 8. ChatGPT ↔ Codex Compatibility

This repository supports iterative ChatGPT planning/review and Codex implementation loops.

Required:
- architecture-grounded prompts,
- patch-scoped changes,
- post-patch contract review,
- `.agent` synchronization after each completed task.

## 9. Token-Efficient Loading Policy

Required loading strategy:
1. `AGENTS.md`
2. `.agent/ARCH_INDEX.md`
3. `.agent/architecture/LAYER_MODEL.md`
4. one domain architecture doc
5. one contract doc

For UIKitPlus application state placement or application refactors, the domain architecture doc is:
- `.agent/architecture/APPLICATION_STATE_OWNERSHIP.md`

Default maximum active architecture docs: `3`.

Do not bulk-load the entire `.agent` tree unless explicitly required.

## 10. Documentation Synchronization

Task closure is blocked until affected docs are updated.

Minimum sync targets when relevant:
- `AGENTS.md`
- `.agent/ARCH_INDEX.md`
- `.agent/ARCHITECTURE.md`
- `.agent/architecture/*.md`
- `.agent/DEVELOPMENT_PHASES.md`
- `.agent/PATCH_REVIEW_RULES.md`
- `.agent/SKILL_INDEX.md`
- `.agent/skills/*.md`
- `.agent/TEMPLATE_INDEX.md`
- `.agent/templates/*.md`
- `.agent/PROJECT_MEMORY.md`
- `.agent/MODULES.md`
- `.agent/TASKS.md`
- `.agent/TASKS_ARCHIVE.md`
- `.agent/TECH_DEBT.md`
- `.agent/SOURCE_MAP.md`
- `.agent/COMMIT_RULES.md`
- `.agent/VALIDATION_RULES.md`
- `.agent/STATE_VNEXT_PLAN.md`
- `.agent/TODO.md`
