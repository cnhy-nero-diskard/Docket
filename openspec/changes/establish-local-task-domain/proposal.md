## Why

Docket has validated local storage and adaptive navigation, but its editable records are disposable fixtures. A production local task model and transactional command boundary are needed before the shell and core workflows can safely manage real personal data.

## What Changes

- Establish the domain milestone of the local MVP: one account-independent local dataset with a protected Tasks inbox, custom lists, tasks, and flat checklist steps.
- Support list and task creation, renaming, editing, movement and deletion; task completion/reopening, importance, plain-text notes and optional calendar-date deadlines; and independent step creation, editing, completion and deletion.
- Define stable identities, validation, deterministic collection order, committed reactive queries, stale-edit rejection, and recoverable command failures on desktop and web.
- Upgrade the ordinary local store without importing fixtures or replacing existing data. Preserve the foundation's browser concurrency, offline operation and incompatible-version protections for production records.
- Promote these exploration recommendations into requirements: Tasks is a real inbox rather than an all-tasks view; each task belongs to one list; steps have independent identities; parent and step completion do not cascade; deadlines are date-only; normal commands commit locally without accounts or networking.

This change delivers the data/domain layer and ordinary startup wiring. Product editors, composers, finished task rows and new navigation screens remain the later shell/core-workflow changes. Also excluded: My Day memberships and smart-list experiences, search, manual reorder/dragging, notifications, recurrence, attachments, list groups, export/import, multiple-profile switching, accounts, synchronization, outbox and cloud infrastructure. Importance and due-date fields are included without requiring those later experiences.

## Capabilities

### New Capabilities

- `local-task-domain`: Local ownership, inbox/list/task/step invariants, task field semantics and calendar-date validation.
- `local-task-commands`: Atomic local mutations, deletion and movement rules, stale-edit handling, committed observation and retry behavior.
- `local-task-storage`: Production-store initialization and migration, fixture isolation, offline durability and native/browser compatibility evidence.

### Modified Capabilities

None. The existing foundation specs continue to govern the isolated fixture harness and platform safeguards; these capabilities add production domain behavior without weakening those contracts.

## Impact

Implementation will add Dart domain types and a production repository, evolve the ordinary database and its generated schema, and wire the ordinary bootstrap to it. Native and web adapters, namespace-specific schema compatibility metadata, offline release compatibility declarations, tests and runbooks will need coordinated updates. The fixture schema and opt-in entry point remain isolated.

The ordinary store currently has schema version 1 with bootstrap metadata only; its supported upgrade becomes the first production-domain migration. Desktop tests must prove real file persistence and transactional concurrency; browser tests must exercise the production namespace, multiple tabs and cached-shell upgrade safety. Existing unverified target/browser rows remain explicit local-MVP gates, not implied platform passes. No backend API, auth setup, deployment or global tooling change is required.
