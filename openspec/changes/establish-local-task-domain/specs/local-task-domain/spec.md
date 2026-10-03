## Purpose

Define account-independent lists, tasks and checklist steps with stable ownership and field semantics that later task interfaces can rely on across native and browser clients.

## ADDED Requirements

### Requirement: Local identity and protected inbox

An initialized local dataset SHALL have a stable identity and exactly one system inbox, displayed as Tasks. Reopening or concurrently initializing the dataset SHALL retain that identity and inbox. The inbox SHALL NOT be renamed, deleted or converted to a custom list. Inbox queries SHALL contain only its own tasks, not all tasks in the dataset.

#### Scenario: Repeated initialization
- **WHEN** two clients initialize the same local dataset and later reopen it
- **THEN** both observe the same dataset identity and exactly one inbox with a stable identity
- **AND** no example tasks or custom lists have been inserted

#### Scenario: Inbox protection and scope
- **WHEN** a caller attempts to rename or delete the inbox while another custom list contains tasks
- **THEN** the operation is rejected without changes
- **AND** querying the inbox does not include the custom list's tasks

### Requirement: Stable list and task ownership

Lists, tasks and steps SHALL have opaque identities independent of titles and display order. Each task SHALL belong to exactly one existing list in its local dataset; each step SHALL belong to exactly one existing task. Duplicate titles SHALL be allowed. Custom lists SHALL support creation and renaming. New tasks SHALL default to the inbox when no destination is supplied; an explicitly missing destination SHALL be rejected rather than silently replaced by the inbox. Referencing a missing parent or an entity outside the current dataset SHALL fail without creating an orphan or modifying another dataset.

#### Scenario: Rename without changing identity
- **WHEN** two custom lists have identical titles and one is renamed
- **THEN** their identities remain distinct and all task ownership is unchanged

#### Scenario: Default and invalid destinations
- **WHEN** a task is created without a destination, then another creation specifies a missing list
- **THEN** the first task belongs to the inbox and the second creation fails without writing a task

#### Scenario: Invalid step parent
- **WHEN** a caller adds a step to a missing task or supplies a parent from a different dataset
- **THEN** the command rejects the reference without writing any child data

### Requirement: Validated text and independent task fields

List names, task titles and step titles SHALL be trimmed at their boundaries and SHALL contain at least one non-whitespace character. Whitespace-only input SHALL be rejected without replacing committed text. Notes SHALL be plain text, permit empty content and preserve supplied whitespace and line breaks. New tasks SHALL have empty notes, be incomplete and not important, and have no deadline. Editing one field SHALL leave all other task fields unchanged unless they are explicitly part of the same command. No command SHALL silently truncate accepted text.

#### Scenario: Invalid rename and exact notes
- **WHEN** a whitespace-only rename is submitted and a separate valid notes edit contains blank lines and trailing spaces
- **THEN** the rename leaves the existing title intact and the notes round-trip exactly as supplied

#### Scenario: Change importance only
- **WHEN** the importance of a task with notes, a deadline and completed steps is changed
- **THEN** only importance and mutation metadata change
- **AND** ownership, notes, deadline and step state remain unchanged

### Requirement: Independent completion and event times

Completing a task SHALL set its completed state and completion instant together; reopening SHALL clear that instant. Repeating the current completion state with a current version SHALL be a no-op that preserves the recorded instant. Task completion or reopening SHALL NOT change step completion; completing all steps SHALL NOT complete the task. Creation and actual mutation times SHALL represent UTC instants, with creation time immutable; those times SHALL NOT decide conflict precedence.

#### Scenario: Complete and reopen a parent
- **WHEN** a task with one completed and one incomplete step is completed and then reopened
- **THEN** its completion instant is set and then cleared while both step states remain unchanged

#### Scenario: Complete all steps
- **WHEN** the last incomplete step is completed on an incomplete task
- **THEN** the task remains incomplete

#### Scenario: Repeated completion
- **WHEN** a completed task is set to completed again using its current version
- **THEN** its completion instant, version and mutation time remain unchanged

### Requirement: Calendar-date deadlines

A deadline SHALL be absent or a valid Gregorian calendar date from year 0001 through 9999, without a time of day or UTC offset. Invalid dates SHALL be rejected rather than normalized. Saving, reopening, changing device timezone or crossing daylight-saving transitions SHALL NOT change the selected date. Clearing a deadline SHALL leave task completion and all other content unchanged. Setting a deadline SHALL NOT schedule a notification.

#### Scenario: Invalid date and leap day
- **WHEN** a caller supplies 2027-02-29 and then 2028-02-29
- **THEN** the first edit is rejected and the second round-trips as 2028-02-29

#### Scenario: Travel and clearing a deadline
- **WHEN** a task due on 2026-10-03 is reopened in a different device timezone and its deadline is then cleared
- **THEN** it initially remains due on 2026-10-03 and subsequently has no deadline, without changing other content

### Requirement: Flat steps and deterministic order

Steps SHALL be a flat checklist with independently editable titles and completion states; nested steps SHALL NOT be accepted. Lists SHALL return the inbox first followed by custom lists in creation order. Task collections SHALL expose separate active and completed results, each in placement order within the owning list. Steps SHALL remain in creation order within their task. Order SHALL remain deterministic after reopen and under equal timestamps. Changing completion SHALL NOT change placement; moving to another list SHALL append the task there. Manual reorder is outside this capability.

#### Scenario: Equal timestamps and reopen
- **WHEN** multiple lists, tasks or steps are created with equal recorded timestamps and the store is reopened
- **THEN** their respective queries return the same deterministic order

#### Scenario: Complete and reopen without moving
- **WHEN** a task is completed and reopened in its existing list
- **THEN** it returns to its original relative placement among active tasks that have not moved

#### Scenario: Reject nesting
- **WHEN** a caller attempts to use a step as the parent of another step
- **THEN** creation is rejected without adding a nested record
