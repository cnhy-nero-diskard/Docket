# Taskmaster reference audit and Docket UI map

Explored 2026-10-03. Companion to [Docket foundation](2026-10-03-docket-foundation.md).

## Evidence and limits

Inspected [Taskmaster](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone) at commit `630b069c33323b9c873517311789bfa6307e139e`: source tree, routing, components, contexts, Mongoose models, task/list endpoints, and server scheduling. Visually inspected the README's desktop detail, phone detail, and tablet navigation screenshots. This is a source-and-screenshot audit, not a running-app acceptance test. Missing features below mean no implementation found in this checkout, not a claim about other versions or deployed services.

No LICENSE, COPYING, or NOTICE file was found in the tracked tree. No source, icons, illustrations, or screenshots were copied into Docket. Use independently written Flutter code and appropriately licensed assets; resemblance is a product reference, not a reuse grant.

Visual evidence: [desktop three-pane screenshot](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone/assets/94924895/3c3ca0ee-7c37-43f5-99c0-89e2d6e91107), [phone detail screenshot](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone/assets/94924895/7555aa27-5f15-4e45-9b6a-d295dae5ee82), [tablet navigation screenshot](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone/assets/94924895/56afdb0f-ff7e-4795-b32f-27f52b1f500d).

## The shared visual reference

The desktop screenshot shows a pale navigation sidebar, blue-violet task canvas, and pale detail pane. The sidebar places account identity above smart lists, a divider above custom lists, and New List at the bottom. The task canvas uses a large list heading, vertically stacked light task cards, left completion circles, right stars, and a bottom composer. Detail uses bordered sections: title and steps, My Day, due date, notes, and a fixed created-date/delete footer. The phone screenshot preserves detail grouping on a full page. The tablet screenshot shows navigation covering roughly half the viewport and obscuring part of the task surface.

Preserve that hierarchy and interaction vocabulary. Improve restrained spacing, readable metadata, explicit selection/focus, useful empty states, and pane widths. Do not turn the application into a dashboard of cards or a bottom-tab mobile app expanded to desktop. Exact colors, typography, illustration style, and density remain design work for the shell proposal.

## Screens and component hierarchy

```text
App
  LoadingProvider -> top loader + session-expired dialog
  AuthProvider
    Layout (React Router)
      /             LandingPage -> Home
      /about        About
      /login        Login
      /signup       Signup
      /app          AppPage (authentication gate)
        TodoApp
          ListProvider -> TodoProvider
            NavigationCol
              profile menu
              DefaultListOption x 4
              ListOption x N
              NewList
            TodosDisplay
              heading / nav toggle
              TodoComponent rows
              completed disclosure
              AddTask
              TodoSidebar
                title / completion / importance
                TodoStep -> StepsMenu; AddStep
                My Day / due date -> Calender
                notes / SidebarFooter
      /app/profile  Profile -> UserInfo
                    resetpassword / editname / editemail forms
      route error   ErrorPage
```

Sources: [routing](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone/blob/630b069c33323b9c873517311789bfa6307e139e/client/src/Layout.jsx), [app composition](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone/blob/630b069c33323b9c873517311789bfa6307e139e/client/src/pages/TodoApp.jsx).

## Behavior established by code

| Area | Observation | Docket implication |
|---|---|---|
| Navigation | Four smart/default entries; custom lists; account menu; new list enters naming; double-click rename; inline list deletion. Group creation is commented out. | Keep hierarchy; add search and contextual menus; distinguish the persisted Tasks inbox from computed views. |
| Task list | Completion and star clicks avoid selecting a row. Other row clicks select details. Completed rows have their own collapsible section. Composer clears after API success. Planned hides the composer. | Keep independent controls and disclosure. Commit composer locally. Permit Planned creation with an explicit date. |
| Details | Editable title, completion/star, steps, My Day, due date, notes, created date, delete. Title and notes save on blur; Enter/Escape blur title. | Preserve grouping; durable draft handling and precise save/cancel semantics must be designed. |
| Steps | Add/edit/complete/delete; overflow menu includes promotion to task. Promotion creates a task through the current-view add handler, then deletes the step in another request. | Steps need separate IDs; promotion should eventually be one atomic command preserving intended destination. |
| Dates | MUI calendar popover with Save/Cancel; removable due date; overdue coloring. Setting a due date to today also sets My Day. | Preserve date affordances; decouple planning membership from deadline. |
| Account | Login, signup, account editing, deletion confirmation, session-expiry modal. | Optional account entry belongs in the shell; auth expiry should pause cloud sync while local editing remains available. |

Sources: [navigation](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone/blob/630b069c33323b9c873517311789bfa6307e139e/client/src/components/NavigationCol.jsx), [task list](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone/blob/630b069c33323b9c873517311789bfa6307e139e/client/src/components/TodosDisplay.jsx), [detail](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone/blob/630b069c33323b9c873517311789bfa6307e139e/client/src/components/TodoSidebar.jsx), [steps](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone/blob/630b069c33323b9c873517311789bfa6307e139e/client/src/components/TodoStep.jsx), [calendar](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone/blob/630b069c33323b9c873517311789bfa6307e139e/client/src/components/Calender.jsx).

### Responsive and desktop behavior

Tailwind defaults apply: below 768 CSS pixels, opening detail hides the task list; navigation is a full-width fixed sliding surface. At 768–1023, navigation becomes a half-width overlay and task/detail can coexist. At 1024+, navigation is a static nominal 30% width; detail uses percentages of the remaining flex area, changing again at 1280. Flex shrinking means these percentages are not reliable final pane dimensions. A resize handler forces navigation open on large windows. Selection is context state rather than task-specific routes.

There is hover feedback, double-click rename, form submission, and several Escape handlers. No implemented right-click task/list menu, application shortcut map, multi-selection, drag reorder, pane splitter, or systematic keyboard focus model was found. Many controls are clickable divs/images rather than keyboard-operable buttons. These observations do not establish actual screen-reader behavior. Docket should preserve pane composition, but derive transitions from minimum usable widths and test accessibility directly. Sources: navigation/task-list components above and [Tailwind configuration](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone/blob/630b069c33323b9c873517311789bfa6307e139e/client/tailwind.config.js).

## State, API, and backend assumptions not to inherit

- `TodoContext` stores selected task and task arrays separately. Task selection fetches details; editing waits for PUT and often fetches again. Smart lists fetch all tasks then filter. `ListContext` separately stores selected list, its name, default-list mode, and navigation visibility. This duplicates mutable state and makes ordinary actions network-dependent. Docket should watch local queries and route by IDs. Sources: [TodoContext](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone/blob/630b069c33323b9c873517311789bfa6307e139e/client/src/contexts/TodoContext.jsx), [ListContext](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone/blob/630b069c33323b9c873517311789bfa6307e139e/client/src/contexts/ListContext.jsx).
- The global loading wrapper drives both progress and session-expiry handling; closing the expiry dialog reloads the page. Docket needs independent local-write, sync, attachment, and account status. Source: [LoadingContext](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone/blob/630b069c33323b9c873517311789bfa6307e139e/client/src/contexts/LoadingContext.jsx).
- MongoDB tasks embed steps and point to a list; lists also keep a task-ID array. Dates are timestamps and My Day is a boolean. There is no application sync cursor, outbox, tombstone, or explicit conflict contract. Docket needs relational parent ownership, date-only deadlines, and durable sync metadata. Sources: [task model](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone/blob/630b069c33323b9c873517311789bfa6307e139e/server/models/ToDo.js), [list model](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone/blob/630b069c33323b9c873517311789bfa6307e139e/server/models/ToDoList.js).
- REST CRUD uses credentialed cookies, a list-ID header, string boolean values, and magic removal strings. Task creation does not visibly check ownership of the referenced list before writing. Task deletion uses an AND between two ownership-mismatch checks. Some routes start a transaction but do not pass the session to the database operations. These are source-level correctness concerns, not live exploit tests; Docket must implement independent authorization and genuinely atomic writes. Sources: [task endpoints](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone/blob/630b069c33323b9c873517311789bfa6307e139e/server/routes/toDo.js), [list endpoints](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone/blob/630b069c33323b9c873517311789bfa6307e139e/server/routes/toDoList.js).
- In-process cron resets My Day at 23:59 and adds today's deadlines at midnight using an Asia/Kolkata schedule; date-boundary construction also depends on process timezone. It is unsuitable for per-user offline planning and a scale-to-zero, multi-instance service. Docket can derive today's membership locally without destructive nightly mutation. Source: [server scheduling](https://github.com/maanasb01/Taskmaster-Microsoft-Todo-PC-App-FullStack-Clone/blob/630b069c33323b9c873517311789bfa6307e139e/server/index.js).

Microsoft describes My Day as a fresh daily selection with suggestions, while tasks remain in their underlying lists. Docket should use that deliberate planning model; exact automatic due-today population is not treated as a universal parity requirement. Source: [Microsoft My Day guidance](https://support.microsoft.com/en-us/todo/my-day-and-suggestions).

## Comprehensive UI surface inventory

Legend: **M** local MVP; **S** sync/account milestone; **C** cloud/files/recovery milestone; **L** later. “Absent” means not found in inspected clone code. These are proposed Docket boundaries, not claims that the clone implements Microsoft To Do fully.

| Surface | Clone coverage | Proposed Docket behavior / stage |
|---|---|---|
| Profile/account control | Avatar, name/email, account/logout menu | Local profile/settings in M; sign-in/link/sign-out/delete account in S |
| Navigation sidebar | Four entries + custom lists | Selection indicator, counts, scrolling, keyboard focus: M |
| Search entry and results | Absent | Local title/notes/steps search; source-list context and no-results state: M |
| My Day | Boolean membership and due-today auto-add | Date-scoped explicit membership, today heading: M |
| Suggestions | Absent | Small local panel for overdue/due-today/previously planned unfinished tasks; explicit add: M |
| Important | Star filter | Derived incomplete tasks, completed disclosure: M |
| Planned | Any due date; no grouped periods | Overdue/today/upcoming/later grouping, date-aware add: M |
| Tasks | Default stored list | Persisted inbox for otherwise unfiled tasks; not All Tasks: M |
| Completed tasks | Section within current list | Disclosure and count in current view; no separate global view initially: M |
| Custom lists | Create, select, rename, delete | Add move-to-list, color/icon, menu and safe deletion: M |
| List groups / create group | Folder creation commented out | Nested sidebar organization, not task ownership: L |
| Collapsed navigation | Sliding hidden sidebar | Drawer/rail/full sidebar as space permits, accessible toggle: M |
| List header/title | Large title | Title, optional icon/emoji and accent, count, overflow: M |
| List icon/emoji | Fixed icons | Small curated icon/color choice: M; full emoji picker L |
| Sort | Absent | Manual/title/due/importance/created, stable tie-breaks: M |
| List menu/options/context menu | Inline delete, double-click rename | Rename, appearance, sort, completed visibility, delete: M |
| Sharing control/share dialog | Absent | Omit until permissions/collaboration exist: L |
| Active tasks / task rows | Circle, title, star | Selected/focused/hover states; due, steps, note and source-list metadata: M |
| Completed task rows | Strike-through, disclosure | Reopen task, preserve detail access: M |
| Add-task control | Bottom composer, submit | Keyboard-aware persistent composer; local save feedback: M |
| Task context menu | Absent | Complete, important, My Day, date, move, delete: M |
| Task detail title/completion/star | Present | Shared detail editor in pane or route: M |
| Steps / add step | Present incl. promotion | Flat checklist add/edit/check/delete/reorder: M; atomic promotion L |
| My Day detail action | Present | Add/remove today's dated membership: M |
| Due date / date picker | Present | Today/tomorrow/custom/clear; localized date-only value: M |
| Reminder / reminder picker | Absent | Permission-aware date/time/timezone, missed-delivery behavior: L |
| Recurrence / recurrence picker | Absent | Series/occurrence model and explicit schedule semantics: L |
| Notes | Plain textarea | Plain text, local durable edits, text selection: M |
| Attachments / file picker / transfers | Absent | Pending/uploading/available/unavailable states, preview/download/remove: C |
| Assignment | Absent | Excluded until collaboration proposal: L |
| Created date / delete task | Present | Localized footer; delete with undo and recoverability: M |
| Delete confirmations | Account confirmation; task/list direct deletion | Confirm destructive list/bulk operations with counts; single-task undo: M |
| Settings | Profile forms only | Theme/system theme, date/week preferences, density, data/export, shortcuts: M; cloud/recovery sections S/C |
| Authentication | Required, email/password | Optional email/password and recovery; social login additions after platform proof: S |
| Empty states | Generic list text | Distinct My Day/Planned/Important/list/search, useful actions: M |
| Loading states | Global loader and list text | Local DB open/migration state; ordinary lists never wait for network: M |
| Offline state | No explicit durable workflow | Usable app; local-only identity in M, queued-change indication in S |
| Error states | Route error / console errors | Retained input after local save failure, recoverable storage/migration errors: M; per-operation cloud errors S |
| Sync status / conflict review | Absent | Account indicator, queue count, last successful sync, retry/sign-in/review: S |
| Backup history / create / verify | Absent | Timestamp, source, completeness, size, status, retention: C |
| Restore / export / import | Absent | Early local export in M; validated preview and import-as-copy in C |

## Desktop interaction contract to carry into proposals

| Interaction | Intended behavior |
|---|---|
| Hover | Subtle row/control feedback without hiding essential controls from touch users. |
| Right click | Task/list context menu; Shift+F10 or menu key offers the same commands. |
| Keyboard navigation | Arrow-key task movement, Enter opens detail, Space completes when row-focused; no interception inside text editors. |
| Focus traversal | Deliberate pane order, visible rings, modal focus containment, return focus to invoking control; no focus loss on query refresh. |
| Shortcuts | Ctrl/Cmd+N focuses add task, Ctrl/Cmd+F search, Escape closes the top surface; expose discoverable help. Validate browser/system conflicts. |
| Delete | Deletes focused/selected tasks with undo/confirmation policy; edits text normally when an editor owns focus. |
| Ctrl/Cmd+A | Select all text inside an editor; select visible task results when the task surface owns focus. Basic multi-select belongs in M. |
| Drag and drop | Reorder within manual sort and move to a list; include keyboard/menu alternatives. External file drops arrive with attachments. |
| Scrolling | Independent pane scrolling, visible desktop scrollbars, wheel over a pane scrolls that pane, composer stays reachable. |
| Resizing | Width changes preserve selected IDs, drafts, focus, and scroll; bounded pane splitters where space permits. |
| Multi-pane navigation | Browser Back/mobile Back closes detail before leaving the list; closing detail does not clear list selection. |
| Accessibility | Screen-reader names/states, touch targets, contrast, large text, reduced motion, RTL/localization readiness; verify on actual target platforms. |

Desktop behavior is part of the local MVP acceptance boundary, even if its implementation is split into a dedicated proposal. Responsive screenshots alone do not prove it.
