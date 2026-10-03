## 1. Define domain values and command contracts

- [ ] 1.1 Add immutable list/task/step models, secure opaque ID generation with injectable test sources, and local-version/result types; verify identities cannot be changed through edit inputs and generated IDs meet the UUIDv4 contract.
- [ ] 1.2 Add shared label validation, exact plain-text notes and calendar-date values; verify whitespace-only rejection, Unicode labels, no text truncation, leap/century/year-boundary cases, invalid date rejection and timezone-independent serialization in pure domain tests.
- [ ] 1.3 Define typed create/patch/set-state/move/delete inputs, stable create-attempt IDs and deletion preconditions; verify omitted versus cleared fields, protected immutable fields, retained input and distinguishable failure outcomes without widget or platform dependencies.

## 2. Establish production schema and safe initialization

- [ ] 2.1 Capture the existing bootstrap schema and add the production schema-2 tables, foreign keys, completion constraints and query indexes; verify fresh creation, invalid relationship rejection, singleton/inbox uniqueness and generated schema reproducibility against real SQLite.
- [ ] 2.2 Implement transactional bootstrap-1 to production-2 migration and stable local identity/inbox initialization; verify extra bootstrap metadata survives, repeated/concurrent initialization produces one inbox and no example tasks, and the inbox cannot be renamed/deleted/converted.
- [ ] 2.3 Add migration fault injection and future-schema rejection tests; verify partial schema/seed failure preserves the original version and metadata, retry succeeds without duplicates, and unsupported newer stores remain untouched.
- [ ] 2.4 Keep production and fixture database namespaces, repositories and recovery/reset capabilities separate; verify fixture seed/reset leaves populated production lists/tasks/steps unchanged and ordinary startup never imports fixture records.

## 3. Implement transactional task commands

- [ ] 3.1 Implement the coordinated production repository operation lifetime, typed error mapping and expected-version conditional writes; verify no pre-commit success, rollback on injected failure, and stale edits from two independent SQLite connections cannot overwrite each other.
- [ ] 3.2 Implement custom-list create/rename and task creation/field edits with inbox defaults and deterministic append positions; verify duplicate titles, exact notes, invalid/missing destinations, ID collision rejection, equal-timestamp order and field isolation after reopen.
- [ ] 3.3 Implement completion/reopening, importance and set/clear deadline commands with injectable UTC clock; verify completion timestamp consistency, current-version no-ops, immutable creation time, timezone-independent deadlines and preservation of unrelated fields.
- [ ] 3.4 Implement flat step create/rename/completion/delete; verify nesting rejection, independent step and parent completion, stable step order, deleted-parent rejection and no modification of sibling steps.
- [ ] 3.5 Implement atomic task moves; verify preserved IDs/content/steps, append at destination, same-list no-op, missing-destination rollback and completion/reopening retaining placement.
- [ ] 3.6 Implement task cascade preconditions and custom-list preview/confirmed cascade; verify current descendant counts, stale preview rejection after additions/edits/moves/deletes, inbox protection, moved-out task survival, unrelated-data isolation and injected mid-cascade rollback.
- [ ] 3.7 Implement recoverable create/readback and version-checked retry behavior; verify a lost acknowledgement can be reconciled by original ID, repeated create never duplicates/upserts, rolled-back create can retry once, and stale desired-state edits cannot recreate deleted records.

## 4. Expose committed queries and ordinary bootstrap

- [ ] 4.1 Implement list, per-list active/completed and task-with-steps snapshots plus observations; verify initial-subscription races, deterministic order, consistent detail transactions, post-commit notifications and explicit not-found after deletion with two consumers.
- [ ] 4.2 Wire the production repository into ordinary startup and preserve explicit storage error/retry handling; verify startup without networking/auth, no fixture controls or diagnostic mutation bridge in the ordinary build, and recoverable failure without resetting user data.
- [ ] 4.3 Integrate production cross-tab invalidation and unsafe-storage gating; verify another compatible client observes commits, rejected writes do not publish success, volatile/unsafe storage blocks commands and eviction-permission denial alone permits safe writes.

## 5. Preserve browser schema and offline compatibility

- [ ] 5.1 Update production schema declarations in browser access and sealed releases while retaining the fixture schema version; add a consistency check and verify the generated release metadata agrees with both database versions.
- [ ] 5.2 Implement/test production migration and marker recovery under namespace coordination; verify marker failure after SQLite upgrade retries safely, missing/stale markers do not bypass SQLite version checks, and newer markers are never lowered.
- [ ] 5.3 Extend an opt-in browser acceptance harness with the production repository and isolated profiles; verify real Chromium restart, prepared offline read/write, stale same-task edit rejection, independent edits, cross-tab observation and coordination recovery after a real tab crash.
- [ ] 5.4 Exercise an actual pre-change schema-1 ordinary bundle beside the new bundle; verify old-client write refusal after upgrade, preserved bootstrap/domain content, compatible shell activation and interrupted update retention. Retain separate evidence for injected faults and real old/new-client behavior.

## 6. Validate and document the domain handoff

- [ ] 6.1 Add and run the Windows production-domain integration and forced process termination/reopen journey using an isolated store with networking disabled; retain proof that list/task/step identities, notes, deadlines, completion and relationships survive the committed-write boundary.
- [ ] 6.2 Run formatting, static analysis, all domain/migration/transaction tests and existing fixture/navigation regressions; verify each command succeeds and retain exact commands and source revision without overwriting historical foundation evidence.
- [ ] 6.3 Run available Android/native/web build or runtime checks and update the six-target/browser matrix; verify each PASS has new evidence and each NOT RUN names a concrete prerequisite, preserving downstream local-MVP gates.
- [ ] 6.4 Deliver `docs/local-task-domain-validation.md` and updated runbook/API examples covering query/command usage, conflict/deletion/retry semantics, migration recovery, fixture separation and deferred UI/My Day/sync work; verify examples match the implemented contracts and include no unsupported product or platform claims.
- [ ] 6.5 Review all three capability specs against retained evidence and run `openspec.cmd validate establish-local-task-domain --strict`; keep required Windows/Chromium tasks incomplete on missing/failing evidence and verify the final diff contains only this domain change and its supporting artifacts.
