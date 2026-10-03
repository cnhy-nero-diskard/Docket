## Purpose

Provide a transactional local command and observation contract that preserves committed task data and recoverable caller intent under failures, retries and concurrent clients.

## ADDED Requirements

### Requirement: Atomic local command boundary

Supported list, task and step mutations SHALL validate their inputs and current ownership and commit all related changes atomically without authentication or application-backend access. Commands SHALL return success only after durable local commit. Invalid input, missing entities, conflicts, unavailable storage and incompatible schemas SHALL produce distinguishable outcomes. An outcome SHALL leave the caller's proposed input available for correction or retry, and rejected transactions SHALL leave committed data unchanged.

#### Scenario: Failure during a related mutation
- **WHEN** a task move or cascading deletion fails after part of its writes have executed but before commit
- **THEN** reopening shows the entire previous state and the caller receives no saved-success result

#### Scenario: Offline edit and write failure
- **WHEN** a client edits notes offline and storage rejects the write
- **THEN** the prior notes remain committed, the proposed text remains available to the caller, and the result identifies storage failure

### Requirement: Stale writes cannot silently overwrite

Mutations of existing entities SHALL be conditional on the version observed by the caller. Version checking and writing SHALL be atomic. A stale edit SHALL be rejected with the current committed entity when it exists; a deleted target SHALL return not-found. The caller SHALL retain its proposed changes and decide whether to resubmit after inspecting current state. Commands SHALL NOT automatically overwrite, recreate a deleted entity or resolve conflicts using wall-clock time. Changes to different entities SHALL be independently committable when ownership remains valid.

#### Scenario: Two clients edit one task
- **WHEN** two clients edit the same task from the same version and the first commits
- **THEN** the second receives a conflict with the first client's committed state, retaining its own proposed input

#### Scenario: Independent task edits
- **WHEN** two clients edit different tasks in the same list from current versions
- **THEN** both edits commit without an unnecessary list-wide edit conflict

#### Scenario: Deletion races an edit
- **WHEN** a task is deleted before another client's stale edit or step creation commits
- **THEN** that command fails without recreating the task or adding an orphan step

### Requirement: Task movement preserves content

Moving a task SHALL atomically change its owning list and destination placement while preserving its identity, notes, importance, deadline, completion and steps. A current-version move to the same list SHALL be a no-op. A missing destination SHALL reject the entire move. A move committed before deletion of its former list SHALL preserve the moved task; a deletion committed first SHALL prevent a stale move from resurrecting it.

#### Scenario: Move a completed task with steps
- **WHEN** a completed task with a deadline and steps moves to a custom list
- **THEN** it appears once in that list's completed result with all content and relationships intact
- **AND** it no longer appears in its former list

#### Scenario: Destination was deleted
- **WHEN** a task move targets a list deleted by another client
- **THEN** the task remains in its original list with unchanged placement and content

### Requirement: Explicit and bounded deletion

Deleting a step SHALL affect only that step. Deleting a task SHALL remove that task and its steps atomically, conditional on the observed task and step state; a concurrent step addition, edit or removal SHALL invalidate a stale task deletion. Deleting a custom list SHALL require an explicit cascade request based on a preview identifying the list and affected task and step counts. If the previewed list or affected contents change before commit, deletion SHALL reject the stale preview and require a refreshed one. A successful cascade SHALL remove only the approved list and its currently owned descendants. The inbox SHALL never be a valid cascade target. Deletion is permanent in this local milestone; a trash or undo capability is not promised.

#### Scenario: Step changes before parent deletion
- **WHEN** a client prepares to delete a task and another client edits one of its steps before deletion commits
- **THEN** the stale deletion is rejected and the task and edited step remain intact

#### Scenario: List deletion preview becomes stale
- **WHEN** a caller previews a custom-list deletion and another client creates, edits or moves an affected task or step before confirmation
- **THEN** deletion rejects the stale preview and preserves the list and remaining contents

#### Scenario: Confirmed cascade is isolated
- **WHEN** a matching custom-list deletion preview is explicitly confirmed
- **THEN** that list and its tasks and steps are removed together while the inbox and unrelated lists are unchanged

### Requirement: Committed reactive queries

Consumers SHALL be able to read and observe lists, per-list active/completed tasks and task detail including steps. Observers SHALL receive an initial committed snapshot and subsequent committed changes without manual reload or backend access, including changes from another compatible browser tab. Snapshots SHALL not contain partial transactions. Subscription setup SHALL not lose a commit that races the initial query. Missing detail SHALL have an explicit not-found state; deleting an observed entity SHALL not leave a stale success snapshot indefinitely.

#### Scenario: Subscribe during a commit
- **WHEN** a consumer subscribes while another command commits
- **THEN** it receives the current committed state without requiring another mutation to trigger refresh

#### Scenario: Cascade observed in another tab
- **WHEN** one tab deletes a task with steps and another observes its detail and list
- **THEN** the other tab sees committed removal and a not-found detail without orphan steps or a manual refresh

### Requirement: Retry without accidental duplication

A logical create attempt SHALL retain its proposed identity across retries. If that identity already exists, creation SHALL not overwrite it or create another entity under a replacement identity automatically. After an ambiguous interrupted result, the caller SHALL be able to query the original identity and inspect committed state before retrying. Set-state commands SHALL use desired values rather than blind toggles; automatic mutation retries SHALL not bypass version checks. A failed initialization or read may be retried without erasing the store.

#### Scenario: Acknowledgement is interrupted
- **WHEN** a create commits but the client loses its result before observing success
- **THEN** reopening and querying the original identity reveals the committed record
- **AND** resubmitting that create does not add a duplicate or overwrite the existing record

#### Scenario: Retry an uncommitted create
- **WHEN** a create rolls back and the caller retries with the same identity after storage recovers
- **THEN** one record is created and observed after commit
