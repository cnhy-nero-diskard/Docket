## Purpose

Establish space-aware navigation and selection behavior that supports the reference's desktop pane structure and compact navigation without coupling routes to a specific window size.

## ADDED Requirements

### Requirement: Adaptive pane composition

The shell SHALL expose navigation, collection content, and selected-item detail according to available usable space. Wide layouts SHALL support three panes; intermediate layouts SHALL retain navigation with detail replacing the content area; compact layouts SHALL provide a navigation-to-content-to-detail stack. Text scaling SHALL be considered when deciding usable space.

#### Scenario: Wide to compact resize
- **WHEN** a selected fixture item is open and the window crosses layout thresholds
- **THEN** the same selection is retained in the appropriate composition
- **AND** controls remain reachable without horizontal clipping of the main navigation flow

#### Scenario: Large text reduces usable pane space
- **WHEN** text scaling makes the existing pane arrangement unusable
- **THEN** the shell reduces visible panes or adjusts composition rather than truncating essential navigation controls

### Requirement: Logical routes and predictable back behavior

Collection and selected-item identity SHALL be represented by stable logical routes independent of display names and pane count. Back or close SHALL dismiss detail before leaving its collection context. Direct links without prior history SHALL offer a deterministic parent destination; invalid routes or unknown fixture IDs SHALL show a recoverable not-found state.

#### Scenario: Refresh a selected-item URL
- **WHEN** a valid fixture detail URL is opened directly or refreshed
- **THEN** the same collection and item are selected using local data
- **AND** closing detail reaches the parent collection even without earlier browser history

#### Scenario: Navigate forward and back
- **WHEN** a user opens detail from a collection and invokes browser or platform Back
- **THEN** the selected detail closes and the collection context is retained

#### Scenario: Unknown item
- **WHEN** a route names an unknown fixture item
- **THEN** the shell reports that the item is unavailable and offers navigation to its valid parent or home

### Requirement: Draft and focus continuity

Resizing or recomposing the shell SHALL preserve the active fixture editor's draft, collection scroll position, and logical focus target. Keyboard traversal SHALL expose a visible focus indicator. Closing detail SHALL return focus to the invoking item when it still exists, otherwise to a deterministic collection control.

#### Scenario: Resize during editing
- **WHEN** a user types an unsaved fixture draft and resizes between layouts
- **THEN** the draft is unchanged and remains editable
- **AND** returning to the collection restores its scroll context

#### Scenario: Keyboard opens and closes detail
- **WHEN** a keyboard user activates a focused fixture item, then closes its detail
- **THEN** the detail is operable without a pointer and focus returns to that item

### Requirement: Appropriate pane interaction

Desktop panes SHALL scroll independently where their content overflows. Keyboard commands SHALL be scoped so text selection and text editing continue to work inside editors. Essential actions SHALL remain available without hover.

#### Scenario: Wheel targets one pane
- **WHEN** a user scrolls over overflowing detail content
- **THEN** detail scrolls without unexpectedly moving the navigation or collection panes

#### Scenario: Select all within editor
- **WHEN** Ctrl+A or Cmd+A is invoked in the fixture text editor
- **THEN** the editor's text is selected and no collection-level action is triggered
