# Tasks

Active governance-tracked work items.

## Current

### GOV-001 — Finalize UIKitPlus agent governance docs

- Status: COMPLETE — governance docs audited and committed locally
- Scope: `AGENTS.md`, `.agent/**`, `.gitignore`
- Non-scope: `Sources/Kit/**`, `Tests/**`, Swift 6 migration, State vNext implementation, push

### ULIST-DOC-001 — Define macOS UList/NSTableView golden runtime contract

- Status: COMPLETE — documentation and independent audit accepted; framework source unchanged
- Scope: `MACOS_ULIST_NSTABLEVIEW.md`, routing, runtime facts, validation, patch review, source map, memory, and operational skill
- Non-scope: `Sources/Kit/**`, `Tests/**`, public API, source behavior, push
- Guardrails: preserve the current native AppKit width/reuse/automatic-height graph; no speculative dual-root, forced-layout, responsive-scrolling, cache, or row-height-engine changes

### MACOS-TABS-001 — Native window tabs with declarative topology

- Status: IMPLEMENTED — source, focused tests, and architecture synchronization
  complete; native rendered-app acceptance belongs to the consuming Vortegy
  task
- Scope: `MacOS+WindowTabTopology.swift`,
  `MacOS+WindowTabRuntime.swift`, `MacOS+WindowTab.swift`,
  `MacOS+WindowTabForEach.swift`, `MacOS+WindowTabGroup.swift`,
  `MacOS+OpenPanel.swift`, `MacOS+Alert.swift`, `Window.swift`, `MacApp.swift`,
  and focused tests/docs
- Contract: `architecture/MACOS_WINDOW_TABS.md` (`WT-001`–`WT-007`)
- Guardrails: use native `NSWindowTabGroup` behavior, keep tab content lazy,
  preserve source/topology state invariants, keep `ConfigureHandler` one-shot
  and same-ID metadata changes in the explicit `UpdateHandler`, forward all
  non-owned window-delegate selectors, expose concrete autocomplete overloads
  with per-overload DocC, and do not touch `.artifacts` or the Xcode project

### NATIVE-M2-001 — GTK owned generator + primitive native slice

- Status: COMPLETE / ACCEPTED through the D01 live runtime checkpoint — audited M2 GTK generator + real-native primitive/runtime slice through E1.1 CLEAN final re-audit; this is not a broad Linux support certification
- Depends on: M1 structural native-backend foundation commit `9ded8fabc8ba0d2181d4a630ebc295599c27a87b`
- Scope: authoritative GIR/GObject metadata path, UIKitPlus-owned deterministic importer/generator design, backend-private generated binding provenance, Swift/Linux native interop boundary, dependency isolation, and the smallest real-native GTK primitive slice
- Contract: `architecture/NATIVE_BACKENDS.md` (`NB1`–`NB12`), especially `NB3`–`NB7`, `NB10`, and `NB12`
- Evidence: Ubuntu real-Wayland accepted 83/0/0; macOS accepted 420 executed / 5 skipped / 0 failures with native GTK activity 0; D01 real Wayland runtime PASS on Ubuntu GNOME/Mutter with a 400x400 window, centered UVStack, 20 margin, 12 spacing, real pointer sequence `0 -> 1 -> 2 -> 3`, native interaction, clean close, and no GTK/GLib critical; no broad Linux support claim
- Guardrails: normal consumers remain `import UIKitPlus`; no third-party Swift UI wrapper as production substrate; no cross-toolkit renderer/layout/list engine; no Linux support claim before implementation + audit

### NATIVE-M2-D01 — Live D01 Wayland runtime acceptance

- Status: COMPLETE / ACCEPTED — real Wayland runtime checkpoint accepted
- Depends on: `NATIVE-M2-001` audited through E1.1 CLEAN final re-audit; this stable `.agent` sync accepted
- Scope: accepted live D01 Wayland consumer runtime on Ubuntu GNOME/Mutter; exact ordinary consumer fixture remained `import UIKitPlus` only; 400x400 native GTK window rendered with centered UVStack, 20 margin, 12 spacing, real pointer sequence `0 -> 1 -> 2 -> 3`, native hover/press/focus, clean close/process exit, and no GTK/GLib critical
- Non-scope: E0 census, Unified Layout research, broad E1 parity, T08, State vNext, staging/commit/push

### NATIVE-E0-001 — Complete public convenience census

- Status: COMPLETE / ACCEPTED — full Apple/common/GTK public convenience census completed and used by the accepted universal-wrapper/superset architecture discussion
- Depends on: `NATIVE-M2-D01`
- Evidence: `.artifacts/research/native-backend-e0-public-control-convenience-census-2026-09-14/CENSUS_REPORT.md`, SHA-256 `1d10afd96f65202a71f5d3b25199dffa2575b519ea99bc14295823eb08f51e59`
- Non-scope: Unified Layout implementation, broad backend parity implementation

### IDENTITY-ULTRA-001 — Rename UIKitPlus project identity to UIKitUltra and Swift modules to Ultra*

- Status: COMPLETE / FINAL INDEPENDENT AUDIT CLEAN AFTER CORRECTION 01 — the full identity migration is closed. The original final source/evidence/root audit found one stable-doc blocker (`IRFA-001-STABLE-NB4-PUBLIC-MODULE-IDENTITY-STALE`); PRIMARY corrected only the two stale NB4 public-module facts and the focused independent Correction 01 re-audit returned CLEAN with `IRFA-001: CLOSED`, `A11: PASS`, and `A18: PASS`. Active source/filesystem/package/Xcode/template/test/generator identity is accepted under the `UIKitUltra` brand + `Ultra*` Swift module scheme. Historical/frozen evidence and real historical/external URLs retain old spellings where explicitly required.
- Accepted identity: project/repository/framework brand `UIKitUltra`; canonical public Swift module/product `Ultra`; `U` prefix means `Ultra`; Windows backend public naming is `Win`, not `WinUI`
- Public common module target: `Ultra`; current root-owned internal runtime
  targets include `UltraCore`, `UltraQtRuntime`, `UltraWinRuntime`; H3 Wave C
  removed the pre-cutover `UltraGTKRuntime` / `UltraGTKCore` production
  closure in favor of external `UltraGTK`
- Explicit/direct backend modules: external `UltraGTK`, plus `UltraQt`, `UltraWin`, `UltraAndroid`, `UltraTUI`
- Stable naming fact: package/repository name remains `UIKitUltra`; all consumer imports/modules use `Ultra` / `Ultra*`; final backend module names are owned by `.agent/architecture/NATIVE_BACKENDS.md`; one-time rename mechanics stay in `.artifacts/migrations/**`
- Guardrails: preserve historical/frozen evidence verbatim; do not mechanically rewrite old artifact paths/commit messages/accepted evidence; retain intentional compatibility IDs and real historical URLs; do not stage, commit, or push without a separate explicit gate

### H3-ULTRAGTK-PRODUCTION-001 — Production UltraGTK extraction / migration

- Status: COMPLETE / PRIMARY FINAL CLOSED — C01+C02+C03+C04, corrected C05, post-C05 stable agent-doc synchronization, and the final independent Wave C Sol audit are all accepted. Final audit verdict is CLEAN with 60 PASS / 0 FAIL and no findings; no production source, package, or stable-agent correction is required. Historical root SwiftPM planner overbuild remains retained as diagnostic context.
- Accepted direction: sibling repository `UltraGTK`; dependency direction `UltraGTK -> Ultra -> application`; no reverse dependency; same native object; package-only Ultra runtime attachment lifecycle; canonical SwiftStream workspace `/Users/imike/Development/SwiftStream`
- Current gate: Wave C technical/architectural work is closed. Any UIKitUltra staging/commit/tag/push is a separate Git-integration gate and remains unauthorized until the maintainer explicitly authorizes it.
- Production repository identity: `SwiftStream/UltraGTK`; canonical SSH remote `git@github.com:swiftstream/UltraGTK.git`; published `main` root commit `894f4a545e21cc2f1363a231f4f00f69ba2fdb75`; HEAD tree `7eb36dc1f16b7f077469195a98414184825d80b4`; annotated `3.0.0-alpha.5` tag object `a23eacf57ca033f30d42e625de124e9c5846c89e` peels to the root commit
- Release line: continue the existing ex-UIKitPlus/UIKitUltra `3.0.0-alpha.*` sequence; verified previous tag is annotated `3.0.0-alpha.4`; the authorized next UltraGTK production tag is annotated `3.0.0-alpha.5`; the historical disposable `1.0.0` mirror/tag is evidence-only and must never be treated as version-line precedent
- UIKitUltra `Package.swift` carries the hard local-development switch
  `let isLocalDevelopment = false`; canonical production resolves exact
  `swiftstream/UltraGTK@3.0.0-alpha.5`, while `../UltraGTK` is available only
  for uncommitted local development
- No broad Linux support claim follows from H3 technical acceptance

### LEGACY-EXAMPLE-001 — Harvest and retire UIKitPlusExample

- Status: PENDING — inspect and migrate useful material before the maintainer deletes the local legacy folder and archives the old GitHub repository
- Source local path: `/Users/imike/Development/UIKitPlusExample`
- Source GitHub repository: `MihaelIsaev/UIKitPlusExample`
- Goal: identify everything still useful (examples, integration patterns, assets, docs, edge-case demonstrations, test ideas, migration knowledge, or other reusable material), move or rewrite only the useful parts into the correct current SwiftStream repositories/documentation, and leave no active dependency on the legacy example repository
- Destination rule: place each retained item in the current owning project (`UIKitUltra`, `UltraDemoApp`, or another explicit SwiftStream child repository) rather than copying the legacy repository wholesale
- Guardrails: do not delete `/Users/imike/Development/UIKitPlusExample`, archive `MihaelIsaev/UIKitPlusExample`, or mutate its Git history as part of the harvest task; first produce an explicit inventory/disposition and verify all retained material exists in its canonical destination
- Completion gate: after the harvest is reviewed and accepted, tell the maintainer that the local folder is safe to delete manually and the GitHub repository is safe to archive manually

### NATIVE-PARALLEL-001 — Establish parallel backend worktree lanes

- Status: BLOCKED ONLY ON EXPLICIT COMMITTED BASE — `IDENTITY-ULTRA-001` is final-CLEAN and no longer blocks lane setup; the remaining prerequisite is an exact committed primary base suitable for linked worktrees
- Stable workflow authority: `.agent/PARALLEL_DEVELOPMENT.md`
- Scope: isolated GTK, Qt, Win, Android, and TUI linked-worktree development with canonical artifacts under the primary checkout `.artifacts/parallel/**`; exact active paths/branches/base SHAs remain transient artifacts
- Guardrails: never bootstrap a lane by copying current dirty primary bytes; select an exact committed base per lane; primary line owns Apple/common DSL/Unified Layout/shared State/canonical integration; backend lanes are subordinate

### NATIVE-ULAYOUT-001 — Unified Layout Constraint Architecture research

- Status: READY FOR RESEARCH — E0 is complete and `IDENTITY-ULTRA-001` is final-CLEAN; research may proceed using canonical UIKitUltra/Ultra/UltraGTK identities. Implementation and parallel backend lane bootstrap still require their own accepted architecture/integration gates.
- Depends on: `NATIVE-E0-001`; identity transition checkpoint from `IDENTITY-ULTRA-001`
- Scope: research-only Unified Layout Constraint Architecture across Apple, GTK, Qt, Win, Android, and TUI; platform-neutral semantic intent lowered to honest backend mechanisms; declaration-before-parent/deferred intent required; Android parent-owned `LayoutParams` and TUI cell geometry are mandatory evidence; automatic Apple detach/reparent persistence is NOT frozen and requires the `parent A -> detach -> parent B` executable compatibility probe; no pre-authorized custom cross-platform GUI solver
- Non-scope: Unified Layout implementation, broad backend parity implementation, State package migration
- Note: broad backend implementation may proceed in parallel worktrees only after this shared architecture gate is accepted and exact lane bases are frozen

### INTEGRATION-001 — Commit the accepted post-H3 UIKitUltra release block

- Status: GIT INTEGRATION IN PROGRESS — Index Transition 01 passed 22/22 predicates and the historical 296-record checkpoint is retired. PRIMARY froze a complete 315-leaf semantic partition with 287 exact Commit R paths and 28 exact governance remainder paths. Commit R may be created only after its exact staged candidate passes the required independent audit and PRIMARY acceptance; Commit G remains a separate governance/orchestration commit with its own complete staged review. Tag/push remain unauthorized until the later post-integration release-block gate.
- Required decomposition after Correction 01 acceptance: Commit R = final product/package/tests/templates plus load-bearing public/product/architecture truth; Commit G = development governance/orchestration whole-files. Exact path inventories are frozen only after an explicitly authorized index transition and fresh status inspection.
- Index transition rule: no reset/restore/unstage/restage until a frozen integration plan passes independent audit and the maintainer explicitly authorizes the exact index-transition operation. Stable `.agent/**` content remains PRIMARY-owned and must not be delegated to Codex/Luna.
- Completion gate: all intended local commits created from independently reviewed staged snapshots, followed by a fresh post-integration release-block audit. Tag/push remain later release gates.

## Blocked

### AUDIT-001 — Post-integration release-block audit before tag/push

- Status: BLOCKED ON `INTEGRATION-001` COMMIT COMPLETION
- Depends on: exact local commits produced by the accepted post-H3 Git-integration plan
- Scope: audit the complete local release block from the remote baseline through M1 plus the new accepted identity/H3/documentation/governance commits; verify commit identities/parents/subjects/path scopes, no `.artifacts/**` inclusion, release-safe `Package.swift`, clean final working/index state, and consistency with accepted identity + H3 audit lineage
- Push/tag remain locked until this audit is accepted and the release gate permits the next exact alpha tag

### MIGRATION-001 — Swift 6 strict concurrency migration

- Status: BLOCKED on AUDIT-001
- Depends on: post-integration release-block audit accepted
- Scope: `Sources/Kit/**` Swift 6 strict concurrency annotations
- Reference: `.agent/STATE_VNEXT_PLAN.md` §5

### STATE-001 — State vNext after Swift 6 baseline

- Status: BLOCKED on MIGRATION-001
- Depends on: Swift 6 migration complete and accepted
- Scope: State vNext implementation
- Reference: `.agent/STATE_VNEXT_PLAN.md`

## Current Known Baseline

- Current committed M1 HEAD: `9ded8fabc8ba0d2181d4a630ebc295599c27a87b` — `🪚 Add native Linux and Windows backend foundation`
- Direct parent / expected upstream baseline: `69c3aaaa7b8e040bc206d0e9243dc90c1f23cb11`
- Current post-commit branch: `master...origin/master [ahead 1]`
- Push: LOCKED pending AUDIT-001 acceptance + separate maintainer authorization
- M1 macOS accepted validation: 420 tests executed, 5 skipped, 0 failures; ordinary build/consumer/iOS generic target PASS; tvOS PASS relative to known historical availability baseline
- M1 Ubuntu ARM64 accepted validation: Core, GTK-only, Qt-only, both/neither diagnostics, and `import UIKitPlus` consumer contract PASS
- M1 Windows ARM64 accepted validation: selected closure + external consumer/direct canary PASS; RAW-byte evidence identity defect corrected and focused re-audit CLEAN
- M2 GTK E1.1 accepted evidence: generator arithmetic `29/17/41/2/39/7` with diagnostics/blockers `0/0` and overrides empty; Ubuntu real-Wayland `83/0/0`; macOS `420/5/0` with native GTK activity `0`; D01 real Wayland runtime PASS/accepted with exact `400x400` fixture, centered UVStack, 20 margin, 12 spacing, real pointer sequence `0 -> 1 -> 2 -> 3`, native interaction, clean close, and no GTK/GLib critical; no broad Linux support claim
- Current sequence: D01 accepted -> E0 COMPLETE -> finish UIKitUltra/Ultra identity cleanup + validation -> `NATIVE-ULAYOUT-001` -> freeze exact committed lane bases -> audited parallel GTK/Qt/Win/Android/TUI production lanes

## Ongoing Maintenance

1. Keep architecture contracts synchronized with runtime changes.
2. Keep skill routing aligned with architecture evolution.
3. Re-audit context budget/load rules after major module additions.
