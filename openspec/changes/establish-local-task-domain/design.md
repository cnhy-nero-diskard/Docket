## Context

See [proposal.md](proposal.md) for the milestone and exclusions. The merged foundation at `d19958f` provides a Drift native/background connection, a browser WASM backend, per-operation open/check/close coordination, and fixture-only repositories and editing. The ordinary `docket_local` store has `BootstrapEntries` at schema 1. The independent `docket_foundation_fixture` store has its own schema 2; that version has no relationship to production schema numbering.

Ordinary bootstrap currently initializes metadata and exposes no task repository. Browser access hardcodes supported namespace versions in `lib/platform/connection_web.dart`; `tool/seal_web.mjs` declares `localSchema: 1` and `fixtureSchema: 2`, consumed by the service worker. All production schema declarations must change together. The foundation evidence establishes useful adapters, not durability proof for the domain that this change introduces.

## Goals / Non-Goals

**Goals:** Make the domain usable without widgets, preserve the existing ordinary namespace and metadata, provide transactional commands with deterministic errors and local conflict detection, and verify the same repository on native SQLite and browser WASM.

**Non-Goals:** Do not repurpose fixture entities, implement product task screens, or design a cloud replication protocol. Local versions are concurrency tokens, not server revisions. Do not add empty auth, outbox, tombstone, attachment or calendar-membership tables for hypothetical future features. The earlier exploration's My Day queries are deliberately deferred with the related workflow; this proposal establishes only the agreed task fields and owning-list queries.

## Decisions

### One production dataset in the existing ordinary namespace

Evolve the ordinary database to schema 2, retaining `BootstrapEntries` and adding a singleton local-dataset record, lists, tasks and steps. Generate a secure UUIDv4 for the dataset and each independently created entity. Initialize the singleton and inbox within the same transaction, with database uniqueness for the singleton and inbox role. Keep the inbox's generated ID stable; the visible name Tasks is presentation of a protected system role.

The database namespace is the local ownership boundary. Repository instances are bound to it; they do not accept an arbitrary profile/account selector. Foreign keys enforce list/task and task/step ownership. Reject missing IDs rather than resolving by title. UUID collisions return an existing-identity outcome without replacement. Use an injectable secure-ID provider in production and deterministic providers only in tests. No global installation identity or cloud account is introduced.

Alternative: a new file/profile switcher would abandon the existing bootstrap upgrade path and prematurely add lifecycle UX. Importing fixture tables would mix disposable data and real user records. Both are excluded.

### Small domain types with persistence-independent validation

Put entities, command inputs, calendar dates and typed results under a task feature's domain/application boundary; keep Drift rows and native/web imports in data/platform code. Clock and ID generation are injectable. Represent deadlines as a validated year/month/day value serialized as fixed-width `YYYY-MM-DD`, never a midnight timestamp. Explicitly validate month lengths and leap years instead of using permissive date normalization. Instants use UTC and a consistent stored precision.

Lists hold ID, kind, title, creation/update instants, insertion position and local version. Tasks hold ID, list ID, title, exact plain notes, completion flag/nullable completion instant, importance, nullable deadline, placement, creation/update instants and local version. Steps hold ID, task ID, title, completion, insertion position, creation/update instants and local version. Add foreign keys, unique identities, Boolean/check constraints and the completion/instant invariant; index owning-list/completion/placement and task/step order.

Trim labels using a single domain normalization rule and reject empty results. Preserve notes exactly, without markup execution. Do not invent arbitrary truncation or silently normalize invalid dates. If a storage limit rejects a large value, return a storage error with the original input intact. Renaming preserves IDs and allows duplicate labels.

Alternative: passing mutable Drift rows through widgets would couple callers to storage and make validation easy to bypass. Generic field maps would obscure desired-state semantics and permit accidental edits of immutable identity or metadata.

### Stable append order without a reorder subsystem

Allocate monotonically increasing integer positions under the write transaction per collection. Use position then opaque ID as the deterministic tie-breaker; creation timestamps do not decide order. Lists display inbox first. Task queries separate active/completed rows but both use the same placement field, so completion/reopening does not erase order. Moving changes list and appends within the destination; moving to the same list is a no-op. Steps append within their task.

Alternative: fractional ranks and neighbor-based moves are useful for the later drag/manual-order milestone, but unnecessary for append-only placement. The future ordering migration must preserve relative order. Position exhaustion is a rejected mutation rather than wraparound; no timestamp-based fallback.

### One coordinated transaction per command

Reuse the backend's operation lifetime: coordinate, open, check/migrate, transact, close, then notify. Native SQLite constraints and transactions remain authoritative across independent connections; the in-process queue alone is not a cross-process guarantee. Browser origin-wide Web Locks cover the whole lifetime. Enable foreign keys on every production connection. Return errors from busy/locked storage as retryable storage outcomes; do not spin or retry mutations blindly.

Provide explicit create/rename/delete list, create/edit/delete/move task, set completion/importance/deadline/notes, and create/rename/set completion/delete step commands. Task edits are typed patches: omitted means unchanged and an explicit nullable deadline means clear. New create inputs carry their already-generated ID so the caller can keep it across retries. No SQL or generic write callback is part of the public repository interface.

Each mutable entity has a positive local version incremented exactly once per actual change. Compare the caller's expected version inside the transaction, using conditional writes and affected-row checks. Do not overwrite whole stale entity snapshots. A mismatch returns conflict plus current entity; deletion returns not-found. Even disjoint edits to the same entity conservatively conflict in this milestone. Set-state no-ops from a current version preserve version and times. Step edits change their own versions; task-detail observers still refresh. Commands on different tasks do not depend on a list-wide edit version.

Results distinguish invalid input, protected inbox, not-found, existing identity, conflict/stale preview, unsafe storage, update-required and storage failure. A committed result contains the resulting identity/version where applicable. Retain immutable command input at the calling layer on any rejected or ambiguous outcome. Repository code never clears drafts. The later editor will translate these outcomes into UI; this change tests the contract directly.

If an acknowledgement is lost after commit, query by the original ID before deciding whether to retry. Reissuing create never upserts. Reissuing a stale edit conflicts rather than repeats an effect. This provides recoverable local intent without claiming durable deduplication receipts or unattended exactly-once retries.

Alternative: last-write-wins loses stale text even with serialized database access. Per-field merge and durable receipts belong to future collaboration/sync design and are unnecessary for safe local rejection.

### Deletion is local and explicitly scoped

Use transactional hard deletion in this unsynchronized milestone. Steps delete independently; task deletion cascades to its steps. A task-deletion precondition covers its version and current step IDs/versions, so a newly edited step is not silently discarded by a stale parent delete. Custom-list deletion uses a read-only preview containing list identity/version, task and step counts and an opaque fingerprint of the affected IDs, versions and memberships. Recompute and compare that fingerprint inside the delete transaction. Include every descendant so moves, additions, edits and removals invalidate the old preview. The command requires the explicit preview token; reading a preview alone never mutates data.

A task moved out before a list cascade survives: its move invalidates any previous preview, and a fresh preview excludes it. If deletion commits first, later edits/moves fail because the task is missing. Foreign keys and transaction rollback prevent half-deleted graphs. No undo or trash promise is exposed.

Alternative: automatically reusing an old count can delete newly added work. Deleting lists while retaining orphan tasks violates ownership. Tombstones are deferred until there is a replication/restore consumer; synchronization must introduce deletion history before any remote dataset is published.

### Query and bootstrap integration without feature UI

Expose committed immutable list snapshots, per-list active/completed task queries, and task detail with ordered steps. Subscribe before the initial read and serialize refreshes to avoid missed updates. Query detail and steps in one consistent read transaction. Broadcast only successful commits, re-read on compatible cross-tab notifications, and report errors or not-found explicitly. Notifications may coalesce to the latest committed state; no partial state or guarantee of one event per mutation is promised.

Wire a production repository into ordinary `AppResources` alongside the separate optional fixture repository. Ordinary startup performs production initialization while preserving its local-storage error/retry state and safe-storage gate. It continues to display the existing shell until the UI change; no diagnostic mutation API is exposed in the ordinary build. Dedicated test entry points use isolated temporary native directories or browser profiles with the real production schema.

Alternative: adapting the fixture repository into the product would retain reset/seed behavior and blur ownership. Adding complete editors now would merge the independently planned shell/workflow milestones into a domain change.

### Production schema compatibility is a release contract

Advance ordinary schema 1 to 2 while leaving fixture schema 2 unchanged. Update the browser's ordinary supported version and release manifest together, with a check that these declarations agree with the database. Run migration and the schema-marker update under the same namespace lock. Record the marker only after successful database initialization. Because SQLite and IndexedDB cannot share a transaction, handle a marker-write failure as an initialization error that can retry the already-upgraded SQLite store; test the gap explicitly. SQLite's own version check remains authoritative when the marker is missing or stale. Never lower a newer marker.

Keep complete-release caching and compatible activation. Demonstrate an old schema-1 ordinary client being blocked after the production upgrade, including when it predates the current release; a current client's artificially injected error is not sufficient proof of old-client behavior. Test release metadata, pending service workers and marker-failure recovery using isolated browser profiles. Do not reuse the old fixture upgrade test as the production upgrade result.

## Risks / Trade-offs

- **Conservative conflicts can reject disjoint edits to one task** → Preserve proposed input and current committed state; defer automatic field merging until there is a reviewed conflict policy.
- **Cascade previews grow with list contents** → Hash a deterministic sequence of identities/versions rather than returning task text; recheck within a transaction and test rollback and changed descendants.
- **Local permanent deletion has no recovery feature** → Require explicit cascade intent and stale-preview protection; document no undo. Portable export and recoverable deletion remain later work.
- **Schema declarations can drift between Dart and the web release tools** → Add a release consistency assertion and real old/new-client acceptance, including the SQLite/marker failure gap.
- **Per-operation connections add overhead** → Retain the validated lifetime and measure representative domain operations before considering long-lived connections; do not weaken upgrade safety for optimization.
- **Missing Apple/Linux/browser hosts remain unproven** → Carry exact prerequisites into the report and later local-MVP gates; require Windows and desktop Chromium evidence for this change.

## Migration Plan

1. Preserve a schema-1 bootstrap snapshot including extra metadata. Define schema-2 constraints, generated schema snapshots and both fresh-create and upgrade paths.
2. Within one database transaction, preserve bootstrap entries, add the domain tables, create the singleton local identity and inbox once, and advance the schema version. Repeated initialization is read/ensure only, never reseeding user content.
3. Verify injected partial migration failure rolls back schema and rows; reject unsupported future versions and exercise retry after marker-update failure. Keep fixtures in their current namespace and schema.
4. Wire ordinary bootstrap and coordinate browser/release version declarations. Run domain/SQLite tests, foundation regressions, Windows force-kill/reopen and the production browser matrix before accepting the change.
5. Record tested revisions, commands and coverage in a new local-domain report and update the runbook. No cloud rollout is involved. Code rollback after data upgrades requires a compatible reader; do not downgrade the database or advise deleting local data. A failed supported migration retries from its preserved state; a committed upgrade requires a forward fix or compatible application build.
