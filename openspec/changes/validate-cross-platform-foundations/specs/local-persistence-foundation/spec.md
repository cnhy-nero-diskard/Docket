## Purpose

Define the durability, transaction, observation, and migration behavior required of Docket's local storage, demonstrated using disposable records before the production task schema is introduced.

## ADDED Requirements

### Requirement: Durable local commits

The persistence harness SHALL allow a fixture record to be created and edited without network access, report success only after local commit, and recover committed values when the process or browser is reopened using the same storage namespace. A failed commit SHALL retain the user's input and SHALL NOT display it as saved.

#### Scenario: Commit survives process termination
- **WHEN** a fixture edit commits and the process is terminated and reopened
- **THEN** the same record identity and committed value are recovered from storage

#### Scenario: Storage rejects a write
- **WHEN** a write fails because storage is unavailable or full
- **THEN** the editor retains its proposed input and reports that it was not saved
- **AND** the last committed record remains intact

### Requirement: Atomic relational mutations and reactive reads

Related fixture mutations SHALL commit or roll back as one transaction. Observers SHALL receive committed changes without manual refetch and SHALL NOT observe partially committed related state. Relationship constraints SHALL reject invalid fixture references.

#### Scenario: Transaction fails between related writes
- **WHEN** a failure is injected after the first of two related writes but before commit
- **THEN** neither write becomes committed state
- **AND** reopening the store confirms the original relationship and values

#### Scenario: Multiple observers follow a commit
- **WHEN** one transaction updates a fixture observed in two views
- **THEN** both views reflect the committed value without a network request or manual reload

#### Scenario: Invalid relationship is rejected
- **WHEN** a fixture child references a nonexistent parent
- **THEN** the mutation fails without creating an orphan record

### Requirement: Nondestructive versioned migrations

The foundation SHALL demonstrate a migration from a populated older fixture schema to a newer schema while preserving record identities, values, and relationships. Migration failure and an unsupported newer schema SHALL preserve the existing store and report the incompatibility rather than reset data.

#### Scenario: Older populated store upgrades
- **WHEN** the harness opens the supported older fixture schema
- **THEN** it migrates successfully and verifies expected rows and relationships in the new schema

#### Scenario: Upgrade fails or store is too new
- **WHEN** a migration fails or an older client opens an unsupported newer schema
- **THEN** normal writes are blocked with a recovery or update instruction
- **AND** no destructive recreation is attempted

### Requirement: Responsive storage execution

Storage initialization and batched fixture work SHALL leave the interface responsive, with explicit initialization/progress state where needed. The validation report SHALL distinguish measured responsiveness from an assumption based on database architecture.

#### Scenario: Fixture batch is in progress
- **WHEN** the harness performs the documented bulk-write workload
- **THEN** navigation, scrolling, and progress rendering remain operable
- **AND** a repeatable responsiveness trace or measurement is recorded
