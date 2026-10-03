## Purpose

Preserve real local task data through ordinary startup, supported schema upgrades, native and browser restarts, and incompatible clients while keeping development fixtures separate.

## ADDED Requirements

### Requirement: Ordinary production initialization and fixture isolation

Ordinary startup SHALL initialize the production task store and expose its command/query boundary without requiring an account or inserting demonstration tasks. Existing unrelated bootstrap metadata SHALL be retained. Fixture launch, seeding, reset and recovery diagnostics SHALL remain confined to the fixture store; fixture data SHALL never be imported as production tasks automatically. Production storage SHALL expose no fixture reset operation.

#### Scenario: First ordinary startup
- **WHEN** the ordinary application starts with no account and no preexisting store
- **THEN** it creates one empty inbox and stable local identity, exposes the production repository, and adds no example tasks

#### Scenario: Reset fixtures beside real data
- **WHEN** real production lists, tasks and steps exist and the fixture harness is seeded and reset
- **THEN** all production identities, content and ownership remain unchanged

### Requirement: Nondestructive production migration

The production store SHALL support fresh creation and an atomic upgrade from the existing bootstrap-only schema. Successful upgrade SHALL preserve existing bootstrap entries and establish domain constraints and exactly one local identity and inbox. Interrupted or failed migration SHALL preserve the last valid store for retry. Unsupported newer schemas SHALL be reported with writes blocked; no failure SHALL trigger destructive recreation or an automatic downgrade.

#### Scenario: Upgrade populated bootstrap metadata
- **WHEN** the existing bootstrap schema contains its normal entries and an unrelated sentinel entry
- **THEN** upgrade preserves all entries and creates a valid empty task domain that remains stable on repeated initialization

#### Scenario: Failure partway through upgrade
- **WHEN** migration fails after some schema or seed work but before commit
- **THEN** reopening with a compatible client reveals the original schema and metadata, and retry can complete without duplicates

#### Scenario: Store is newer than client
- **WHEN** the client opens an unsupported newer production schema
- **THEN** it reports that a compatible update is required and leaves stored data intact without enabling writes

### Requirement: Production browser coordination and offline durability

Production browser operations SHALL coordinate initialization, migration, version checks and mutations across tabs. Volatile or unsafe storage SHALL block normal domain writes; denial of eviction protection alone SHALL not block an otherwise safe store. A compatible, completely cached shell SHALL reopen offline, read real local task data and commit domain edits. Schema compatibility metadata and cached-shell activation SHALL reflect the production schema; an older client SHALL not write after an incompatible upgrade or replace a newer compatible shell. A crashed client SHALL release coordination so a surviving compatible client can proceed without resetting data.

#### Scenario: Production edits survive offline browser restart
- **WHEN** lists, tasks and steps are committed, the browser closes, and a fully prepared compatible shell is reopened offline
- **THEN** their identities and contents are recovered and a further domain edit can commit

#### Scenario: Old tab encounters production migration
- **WHEN** a newer tab upgrades the production store while an older tab remains open
- **THEN** the older tab is prevented from writing or resetting that store and receives an update-required outcome
- **AND** a compatible tab continues to read the preserved data

#### Scenario: Client crashes while coordinating
- **WHEN** a browser tab terminates while holding production-store coordination
- **THEN** a surviving compatible tab regains access and observes the last committed state

#### Scenario: Browser durability capability differs
- **WHEN** one environment offers only volatile storage and another denies eviction protection but supports safe durable writes
- **THEN** the former rejects production mutations and the latter permits them with an accurate eviction-risk indication

### Requirement: Evidence for the production domain

Acceptance SHALL include passing domain and real-database invariant tests, supported migration and failure-preservation tests, and retained native and browser evidence for production records. Windows SHALL demonstrate committed production write followed by forced process termination and reopen. A real desktop Chromium browser SHALL demonstrate production restart/offline read-write, cross-tab stale-edit rejection and observation, crash recovery, incompatible-version protection and safe shell activation. Existing fixture tests SHALL remain passing. Other target/browser outcomes SHALL be recorded as PASS, FAIL or NOT RUN with evidence or a concrete prerequisite; fixture evidence or target scaffolding SHALL not be substituted for production-domain acceptance.

#### Scenario: Required production check fails
- **WHEN** a required Windows or Chromium production-domain scenario fails or cannot be run
- **THEN** this change remains unaccepted with the missing check identified

#### Scenario: Another host is unavailable
- **WHEN** a non-required platform runtime cannot be exercised on the available host
- **THEN** its result is NOT RUN with a prerequisite and remains a local-MVP release gate
