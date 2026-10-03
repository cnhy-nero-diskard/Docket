## Purpose

Provide reproducible evidence for foundation decisions and distinguish proven platform behavior from development assumptions before later product and account milestones depend on it.

## ADDED Requirements

### Requirement: Traceable platform evidence

The change SHALL produce an evidence report for Android, iOS, Windows, macOS, Linux, and Web, including desktop Chrome/Edge, Firefox, Safari, Android Chrome, and iOS Safari. Each result SHALL identify the source revision, toolchain/browser/OS, scenario, commands or procedure, outcome, and supporting artifact or error. Build, runtime, automated simulation, and manual checks SHALL remain distinguishable. Outcomes SHALL be PASS, FAIL, or NOT RUN with a reason; unavailable environments SHALL NOT be labeled PASS.

#### Scenario: Required host is unavailable
- **WHEN** an Apple or Linux runtime check cannot be executed on an available host
- **THEN** the report records NOT RUN, the missing prerequisite, and the follow-up acceptance gate
- **AND** no six-platform runtime support claim is made

#### Scenario: A fault is simulated
- **WHEN** a test injects quota or migration failure instead of reproducing it in a browser
- **THEN** the evidence identifies it as simulated
- **AND** actual browser coverage remains separately recorded

### Requirement: Bounded authentication feasibility assessment

The foundation SHALL assess a supported-identity-provider path for Windows and Linux and its interaction with the proposed web storage/header configuration. Experiments SHALL be isolated from normal local startup and use only explicitly configured test resources. The report SHALL distinguish a real provider roundtrip from a simulated callback, classify the candidate as validated, rejected, or blocked, and state what is still required before production account integration.

#### Scenario: Test identity resources are unavailable
- **WHEN** credentials, a configured identity project, or a suitable host are unavailable
- **THEN** the assessment records the unmet prerequisites and a blocked real-provider check
- **AND** local storage/navigation implementation can continue without adding mock sign-in to the product

#### Scenario: Candidate login flow is exercised
- **WHEN** a real-provider desktop or web login experiment is performed
- **THEN** its report covers callback binding/replay handling, token refresh, and the storage/header mode actually used
- **AND** secrets and tokens are excluded from committed evidence

### Requirement: Explicit foundation acceptance and downstream gates

The foundation SHALL be accepted only after common static, transaction/migration, and adaptive navigation checks pass; Windows demonstrates offline startup, committed write/process reopen, migration/failure preservation, and keyboard/resize/scroll behavior; and at least one real desktop Chrome or Edge demonstrates built-bundle offline deep-link reload, persistent writes, concurrent tabs, crash recovery, stale-tab upgrade safety, interrupted shell updates, and storage capability gating. The platform evidence report and auth feasibility assessment SHALL also be delivered. Missing checks on other target environments SHALL remain explicit downstream gates before local MVP release. A blocked real-provider authentication experiment SHALL remain a gate before account integration, not be treated as a successful authentication proof.

#### Scenario: Local foundation passes while another platform remains unverified
- **WHEN** the minimum foundation checks pass but an external-platform runtime check is NOT RUN
- **THEN** the handoff describes the tested foundation and names the unverified platform and required follow-up
- **AND** the local MVP is not described as accepted across all six targets

#### Scenario: Required storage behavior fails
- **WHEN** a required Windows or Chromium durability, migration, or concurrency check fails
- **THEN** the foundation is not marked accepted until the failure is resolved or a reviewed change revises its requirements
