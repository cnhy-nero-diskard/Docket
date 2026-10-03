## Why

Docket has a researched product direction but no executable client foundation. Before building persistent task workflows, we need to establish that one Flutter application can provide durable local storage and responsive navigation on native platforms and the Web, and identify any desktop authentication limitation without making local usage depend on it.

## What Changes

- Establish the foundation milestone: one Flutter/Dart package with Android, iOS, Windows, macOS, Linux, and Web targets, repeatable dependency/toolchain setup, and a local-only default entry point.
- Adopt the exploration's feature-first organization, Riverpod dependency composition, and go_router logical navigation for this foundation; keep business data out of widget/provider caches.
- Validate Drift/SQLite through isolated fixture records: transactional/reactive writes, process restart, migrations, failure recovery, and platform-specific connection adapters. Fixture schemas are not the production task schema.
- Provide a reference-informed navigation skeleton that adapts between three panes, two panes with detail replacement, and compact stacked routes while preserving selection, draft, and focus. This establishes composition, not finished Microsoft To Do parity.
- Establish browser storage capability checks, safe multi-tab behavior, coordinated upgrades, and an explicit offline app-shell cache/update policy.
- Produce reproducible platform evidence and a bounded desktop/web authentication feasibility assessment. Distinguish proven behavior, failures, and unavailable environments; unresolved auth does not block local foundation work.
- Promote these scoped exploration recommendations into testable requirements. Exact visual tokens, production domain tables, sync protocol details, and auth-provider commitment remain outside this change.

Non-goals: complete task/list CRUD, steps/My Day/search semantics, production account integration, outbox/sync/backend, cloud provisioning/deployment, attachments, backup/restore, notifications, recurrence, sharing, final visual polish, and app-store distribution.

## Capabilities

### New Capabilities

- `application-foundation`: Shared Flutter bootstrap, local-only lifecycle, dependency boundaries, and six-target build configuration.
- `local-persistence-foundation`: Durable transactional local storage, reactive reads, migrations, and honest failure behavior through a fixture harness.
- `adaptive-navigation-foundation`: Reference-informed pane composition, stable routes, and keyboard/focus continuity.
- `web-offline-foundation`: Durable-storage capability gating, multi-tab/upgrade safety, and offline reopening of a versioned web shell.
- `foundation-validation`: Reproducible platform evidence, isolated auth feasibility experiments, and explicit gates for later milestones.

### Modified Capabilities

None. There are no existing main specifications.

## Impact

Implementation will introduce Flutter platform projects, shared client/bootstrap code, test-only fixture tooling, tests, developer documentation, and build validation configuration. Expected client dependencies are Drift/SQLite, Riverpod, and go_router; compatible versions will be pinned during implementation. Web delivery configuration must cover worker/WASM assets, deep-link fallback, and isolation-header/auth compatibility. Native verification requires appropriate host toolchains; this Windows workspace cannot establish Apple/Linux runtime acceptance by itself.

No existing users, data, public APIs, or deployments are changed. Source and assets will be independently authored, using the [reference audit](../../explorations/2026-10-03-taskmaster-reference-audit.md) and [foundation exploration](../../explorations/2026-10-03-docket-foundation.md) as context.
