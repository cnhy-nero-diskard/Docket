## Context

See [proposal.md](proposal.md) for motivation and scope. Docket currently has OpenSpec exploration and workflow configuration but no application package or main specifications. This workspace runs Windows; Flutter and Dart commands are discoverable at `C:/Users/cnhyn/Flutter/flutter/bin`, but their versions and installed platform toolchains have not been validated by this planning work.

The [reference audit](../../explorations/2026-10-03-taskmaster-reference-audit.md) pins the inspected Taskmaster revision and describes the shell. The [exploration](../../explorations/2026-10-03-docket-foundation.md) contains source links and provisional technology comparisons. This design selects only what the foundation needs. Runtime evidence produced during apply must supersede assumptions in those notes.

## Goals / Non-Goals

**Goals:** establish reusable bootstrap, connection, and navigation boundaries; prove local transaction/migration behavior; exercise production-like web delivery; expose uncertainty through reproducible evidence.

**Non-Goals:** finalize task/domain fields, create a sync queue, ship sign-in, or turn test records into the first production task implementation. Experiments must not silently dictate later product semantics. This change adds no privileged cloud credentials or infrastructure.

## Decisions

### 1. One package with reusable foundation and isolated fixtures

Create the Flutter package at the repository root while preserving existing OpenSpec/tooling files. Scaffold through a temporary location if the generator would overwrite existing files, then copy only intended application files. Generate all six target directories. Record the actual supported stable Flutter/Dart release and retain the dependency lockfile as a project artifact during implementation; do not upgrade the user's global SDK merely because a newer release exists. Git commits and pushes require separate authorization.

Start with `lib/app/`, `lib/features/shell/`, `lib/data/local/`, and narrow `lib/platform/` adapters. Add folders only when they contain code. Riverpod composes dependencies and repository streams; go_router owns route state. UI draft controllers own temporary text; the database owns committed fixture values. Conditional imports and a connection factory isolate web/native differences.

Use an explicit development entry point or compile-time fixture flag with a separate `docket_foundation_fixture` storage namespace. A normal launch shows a clean local shell and storage initialization/error state, with no demo rows or false cloud controls. The initial ordinary store needs only version/bootstrap metadata; production task tables are added by the next domain proposal. The fixture schema and migration versions are separate from that future schema. Any diagnostic export/reset is scoped to fixtures and excluded from the normal release flow.

Alternative: a standalone throwaway sample would isolate experiments more strongly but would fail to prove integration with the real app entry points. The selected approach reuses infrastructure while keeping fixture data and its UI explicit. Multiple Dart packages and generated abstraction frameworks are unnecessary at this size.

### 2. Drift as the connection and query implementation to prove

Use Drift with native SQLite and its supported WASM web connection. Resolve mutually compatible library, SQLite WASM, and worker versions together. Do not substitute a second browser database unless evidence establishes a material blocker and the proposal is revised.

The fixture schema contains only a parent collection and child record with stable IDs and text. Demonstrate a populated v1-to-v2 additive migration with explicit fixtures, foreign keys, transaction rollback, and query observation. A two-row command exercises the transaction boundary without inventing an outbox. Native work uses a background executor where supported; the browser worker strategy is determined by the deployed storage capability probe. Store native databases in app-support storage rather than a synced documents directory.

Record successful saves only after the transaction commits. Retain draft input on failure. A fault-injectable adapter tests write/migration failures; actual process/browser reopen tests establish physical durability. Test foreign-key enforcement and query notifications against real SQLite, not just mocks. Perform a documented 10,000-record batched fixture workload with a responsiveness trace; record observed timings and investigate visible stalls rather than claiming an unmeasured latency target.

Migrations are forward-only with a checked schema version. Incompatible downgrade opens and failed upgrades show recovery/update states. Never automatically delete/recreate a failing database. A consistent pre-migration fixture snapshot plus transaction rollback supplies recovery evidence; do not copy a live native database file without accounting for its journal.

Alternative: sqflite/raw SQLite would require more reactive-query plumbing and separate web integration work without resolving a known Drift failure. Keep repository contracts narrow so storage mechanics do not leak into views.

### 3. Adaptive navigation without full task semantics

Use stable logical routes such as `/lists`, `/lists/:collectionId`, and `/lists/:collectionId/items/:itemId` for fixtures. These are foundation route semantics; future task routes may refine names without depending on view labels. Direct-link resolution reads local fixtures. Unknown IDs receive a not-found state, not a network fetch.

Layout is constraint-driven. Initial minimum widths are navigation 240, collection 360, and detail 320 logical pixels; three panes require their combined width plus gutters. Two panes require navigation plus either collection or detail. Below that, use stacked pages. Treat these as centralized tunable constants, tested at transition boundaries and large text rather than OS-specific branches. Intermediate detail replaces collection while retaining navigation; wide detail sits alongside collection. Compact navigation starts at lists.

Store selected IDs in routing, drafts by fixture ID in a controller above the layout branches, and scroll positions by collection. Moving between pane compositions must not dispose that state. Explicit close navigates to the parent route; browser/platform Back follows the same logical hierarchy without adding history on every resize. Restore focus to the invoking row, or a collection control if it is no longer present. A direct deep link has a deterministic parent even with an empty history stack.

Use shared row/pane primitives with independently authored styling informed by the audit. Include visible focus, independent scrolling, keyboard activation and close, and editor-owned text selection. Context menus, multi-select, production drag ordering, detailed smart-list behavior, and final design tokens remain later proposals. The harness validates the foundations those interactions will need.

Alternative: separate navigation implementations per device category would duplicate state and make resize/deep-link behavior diverge. Simple percentage widths from the clone do not establish usable pane sizes.

### 4. Browser capabilities, tabs, and versioned offline delivery

Select storage based on the actual connection result. Approve only durable modes with safe cross-tab access. An in-memory or unsafe mode stops normal fixture writes and explains recovery options; never translate it into a successful local save. Denied persistence permission is a separate eviction-risk state. Diagnostic export of readable fixture data can support failure investigation without establishing the product backup feature.

Use SQLite's supported worker/locking path for data transactions and an application-level upgrade coordinator for version compatibility. Before schema migration, obtain an exclusive upgrade lease; compatible tabs coordinate database closure/reopening, while stale tabs block writes and request reload. Preserve any draft before closing a connection. Browser lock ownership or a tested expiry/heartbeat mechanism must recover from tab termination. Do not implement a sync-worker lease because there is no sync engine yet.

Serve a release-mode web build through a local production-like static host with SPA route fallback, correct WASM MIME, and configurable COOP/COEP/CORS headers. Prefer same-origin shell assets. Test both the selected isolation policy and its auth return behavior; document the actual accepted storage mode rather than assuming headers work equally on all browsers.

Maintain explicit versioned app-shell caching. Stage a complete release asset manifest (HTML, Flutter runtime/app assets, worker, WASM, fonts) before activating it. Retain the previous complete shell until the replacement is ready and database compatibility is known. Do not auto-reload over an unsaved fixture draft. Persist a schema compatibility marker; an old shell must refuse unsupported writes rather than roll back the database. Do not include auth pages, credentials, or API responses in the shell cache. This policy must be validated in a built bundle, not only the Flutter development server.

Alternatives: relying on unspecified generated service-worker behavior leaves update guarantees unproven; forcing only an OPFS path could exclude a safe IndexedDB-backed mode. Choose capabilities based on evidence and retain one domain persistence contract.

### 5. Auth feasibility remains an isolated experiment

Assess the Firebase/Identity Platform candidate described in the exploration using fresh official platform documentation during implementation. The experiment lives under fixture/tooling paths and is not wired into normal bootstrap. Use an existing explicitly configured test project when available; this change does not authorize provisioning or deploying one.

Compare documented native support with a system-browser hosted login plus one-use, challenge-bound return and documented token exchange/refresh path. Check Windows and Linux host/callback and secure-storage prerequisites. Exercise web login using the same headers/storage configuration as the persistence proof. Verify wrong-state, replay, expired return, cancellation, refresh failure, and redaction. Simulated callbacks prove only application plumbing; they never count as real-provider sign-in.

Limit initial investigation to one candidate and one focused experiment per accessible desktop environment, with a one-working-day investigation budget before writing a decision record. Outcomes are validated candidate, rejected candidate, or blocked by a named external prerequisite. An unresolved result creates an explicit prerequisite for `add-optional-accounts`; it neither introduces fake login nor blocks local domain work. Provider selection is not final until the real integration is proven.

Alternative: integrating a partially supported SDK into all production targets now would couple local startup to an unproven account stack. Building an identity service is out of scope.

### 6. Evidence, verification, and completion gates

Write `docs/foundation-validation.md` during implementation, with supporting screenshots/logs/traces under a scoped evidence directory or links to CI artifacts. Each row records revision, environment/version, exact command/procedure, expected/actual result, PASS/FAIL/NOT RUN, and artifact/error. Redact secrets and user-machine identifiers not needed for reproduction.

Minimum acceptance for **this foundation change**:

- Common format/analyze checks, domain-free repository/transaction/migration tests, and adaptive widget/navigation tests pass.
- Windows native: build and runtime startup, offline fixture write, forced process termination/reopen, migration/failure preservation, and keyboard/resize/scroll checks pass.
- At least one real desktop Chromium browser (Chrome or Edge): built-bundle offline reload/deep link, persistent write/reopen, two-tab independent edits, tab crash/recovery, stale-tab upgrade, interrupted asset update, and storage-fallback behavior pass. Injected errors are labeled; actual browser capability checks remain separate.
- All six target configurations and platform runbooks exist. A desktop/native/web/Android build matrix and macOS unsigned iOS build instructions are supplied; passing remote builds are reported only when actually executed. There is no external deployment requirement.
- Each environment in the following matrix is assessed or recorded NOT RUN with exact prerequisites. The auth decision record exists; a blocked provider roundtrip is an unresolved account milestone gate, not a passing runtime check.

| Environment | Required evidence tracking |
|---|---|
| Android | Build + device/emulator persistence, restart, navigation |
| iOS | Build + simulator/device persistence, lifecycle, navigation |
| Windows | Required native baseline above |
| macOS | Build + runtime persistence, navigation, sandbox/credential prerequisites |
| Linux | Build + runtime persistence, navigation, packaging/credential prerequisites |
| Web desktop | Chrome/Edge family baseline, Firefox, Safari; record exact browser versions |
| Web mobile | Android Chrome and iOS Safari; storage mode, offline reload, layout |

Missing external-host checks are not silently waived. They are named gates before six-platform local MVP acceptance. Failure of a minimum foundation check leaves its implementation task incomplete; generating files or recording FAIL is not sufficient. A blocked optional auth experiment can complete its assessment task only when the blocked result and later gate are explicit.

## Risks / Trade-offs

- Fixture behavior could be mistaken for task support -> isolate storage, label fixture mode, and omit fake actions from normal UI.
- Browser persistence and auth headers may conflict -> test them together and record a rejected/blocked candidate instead of weakening durable storage silently.
- Single-host checks can overstate multiplatform readiness -> separate configuration/build/runtime evidence and retain release gates.
- Offline shell update races can open a new schema with an old writer -> stage assets and coordinate schema compatibility across tabs; test interruption and old-tab access.
- Auth feasibility could grow into account implementation -> time-box the experiment, keep normal startup auth-free, and carry prerequisites forward.
- Foundation work overlaps later shell/domain proposals -> retain connection/router primitives, but keep business semantics and fixture schemas outside the future production domain.

## Migration Plan

There is no deployed app or user dataset to migrate. Introduce the package, isolated harness, and runbooks incrementally; no cloud rollout is part of this change. Demonstrate fixture v1-to-v2 migration and explicit incompatibility handling before declaring the storage boundary proven.

Rollback means reverting application changes and resetting only an explicitly disposable fixture namespace when requested. An older binary must not open a newer fixture schema for writing. Never delete existing OpenSpec artifacts or unrelated workspace content during scaffolding/rollback.

Handoff to the local-domain proposal includes retained foundation primitives, evidence and known gaps, the Drift decision, and production schema requirements still to design. Handoff to optional accounts includes the auth candidate result and every unresolved host/provider prerequisite. No synchronization, tombstone, or user restore guarantees are claimed by these fixture migrations.
