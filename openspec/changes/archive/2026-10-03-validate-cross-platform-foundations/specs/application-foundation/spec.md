## Purpose

Establish a runnable, account-independent client foundation with reproducible platform entry points and a clear boundary between development fixtures and future user data.

## ADDED Requirements

### Requirement: Account-independent startup

The application SHALL open its local foundation shell without an account, authentication configuration, or a reachable application backend. It SHALL distinguish local initialization from network activity and SHALL report local initialization failure without destroying existing data.

#### Scenario: Native launch without network or credentials
- **WHEN** a native installation starts with networking disabled and no configured account
- **THEN** the local shell becomes available after successful local initialization
- **AND** no sign-in redirect or backend request is required to navigate

#### Scenario: Local initialization fails
- **WHEN** the existing local store cannot be opened safely
- **THEN** the application shows an actionable local-storage error and a retry action
- **AND** it does not silently replace or delete that store

### Requirement: Reproducible platform configuration

The repository SHALL provide client target configuration and documented build/run prerequisites for Android, iOS, Windows, macOS, Linux, and Web. The documented setup SHALL identify the chosen toolchain and locked dependencies. Platform build configuration SHALL NOT be represented as evidence that the application has run successfully on that platform.

#### Scenario: Developer follows a target runbook
- **WHEN** a developer selects one of the six targets
- **THEN** its runbook identifies the required host, toolchain, dependency setup, and build/run commands
- **AND** the evidence record separately states whether build and runtime verification were performed

### Requirement: Explicit fixture isolation

Development fixtures and diagnostic controls SHALL be opt-in, clearly labeled, and stored separately from future user profiles. The ordinary shell SHALL NOT expose mock account, synchronization, or task-saving success as working product functionality.

#### Scenario: Ordinary launch
- **WHEN** the application is launched without fixture mode
- **THEN** no demonstration tasks are written into a user profile
- **AND** unimplemented task/account actions are not presented as functioning controls

#### Scenario: Fixture reset
- **WHEN** a developer resets the foundation fixture store
- **THEN** only that explicitly selected fixture namespace is cleared
- **AND** other local stores remain untouched
