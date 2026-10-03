## Purpose

Make browser storage and offline startup explicit, testable capabilities, including protection against misleading save state, unsafe concurrent tabs, and incompatible cached application versions.

## ADDED Requirements

### Requirement: Durable-storage capability gate

Before enabling normal fixture writes, the web client SHALL determine whether safe persistent storage is available. A volatile or unsafe concurrent-access fallback SHALL NOT be presented as normal durable storage. Unavailable storage SHALL produce an explanatory state and preserve access to safely recoverable existing data. Persistent-storage permission denial SHALL NOT itself be treated as total storage unavailability when safe durable writes still work.

#### Scenario: Browser offers only volatile storage
- **WHEN** the browser cannot provide an approved durable storage mode
- **THEN** normal write controls are blocked with an explanation
- **AND** the application does not claim that edits survive closing the tab

#### Scenario: Persistence permission is denied
- **WHEN** the browser denies eviction-protection permission but durable database operations work
- **THEN** the client can continue with an accurate storage-risk indication
- **AND** it does not describe that permission as a backup guarantee

### Requirement: Concurrent tabs and upgrades are safe

Concurrent tabs SHALL either coordinate safe access to the same fixture store or prevent an incompatible tab from writing with an actionable explanation. Schema upgrades SHALL prevent incompatible older writers from continuing. Closing or crashing one tab SHALL allow a surviving compatible tab to recover access without resetting data.

#### Scenario: Two compatible tabs write
- **WHEN** two compatible tabs open the same fixture namespace and make independent edits
- **THEN** accepted edits remain durable and visible after reopening
- **AND** no corruption or silent loss occurs because of concurrent database access

#### Scenario: Old tab overlaps schema upgrade
- **WHEN** a new application version requires a schema incompatible with an already-open tab
- **THEN** the upgrade and old writer are coordinated so incompatible writes cannot occur
- **AND** the affected tab receives a reload/update instruction without discarding retained draft text

#### Scenario: Tab holding coordination state crashes
- **WHEN** a tab terminates unexpectedly during coordinated access
- **THEN** a remaining compatible tab can regain access using the documented recovery procedure
- **AND** committed records are preserved

### Requirement: Offline reopening after initial preparation

After successful online initialization and complete shell-asset caching, the web application SHALL reopen offline at a previously valid local route and read/write its fixture store. It SHALL explicitly distinguish incomplete first-visit preparation from a ready offline installation.

#### Scenario: Reload with networking disabled
- **WHEN** shell caching has completed and the user reloads a fixture detail URL offline
- **THEN** the shell and local detail load and a fixture edit can commit

#### Scenario: First cache preparation was interrupted
- **WHEN** required shell assets were not fully cached before connectivity is lost
- **THEN** any available preparation status does not claim offline readiness
- **AND** the documented recovery is to complete preparation online, without resetting stored data

### Requirement: Coherent application updates

An update SHALL activate only a compatible, complete shell asset set. Interrupted updates SHALL leave the prior complete shell usable when compatible with the existing database. Cached authenticated responses and credentials SHALL NOT be part of the app-shell cache.

#### Scenario: Asset download is interrupted
- **WHEN** a new shell version cannot finish downloading all required assets
- **THEN** it does not replace the prior complete active shell
- **AND** the next online attempt can retry preparation

#### Scenario: Database is newer than cached shell
- **WHEN** an older cached shell encounters an unsupported newer database
- **THEN** it requests a compatible application update and blocks writes without reverting the database
