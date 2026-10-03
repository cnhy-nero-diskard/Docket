## 1. Establish the application package

- [ ] 1.1 Inventory Flutter/Dart and platform prerequisites without changing global tooling; record `flutter --version`, `flutter doctor -v`, available targets, and missing host/toolchain prerequisites in the validation report.
- [ ] 1.2 Scaffold one Flutter package with six target configurations while preserving existing files; verify the target directories and diff contain only intended new application/tooling content.
- [ ] 1.3 Add compatible Drift/SQLite, Riverpod, and go_router dependencies and retain the lockfile plus documented SDK version; verify dependency resolution and static analysis succeed.
- [ ] 1.4 Add feature-first bootstrap/composition, a local-only empty shell, and explicit initialization/error state; verify a startup test succeeds with no auth configuration and a failing local-store test preserves the original store.
- [ ] 1.5 Add an opt-in labeled fixture entry point and isolated fixture namespace; verify ordinary launch contains no fixture rows/mock cloud actions and fixture reset leaves a separate sentinel store intact.

## 2. Prove native local persistence

- [ ] 2.1 Implement the native connection factory and minimal bootstrap store, with the fixture parent/child schema in its own namespace; verify an on-disk SQLite integration test creates, closes, and reopens both stores independently.
- [ ] 2.2 Implement fixture repository commands and reactive observations; verify foreign-key rejection, two-observer updates, and rollback after failure between related writes.
- [ ] 2.3 Add commit-aware fixture editing with retained drafts on failure; verify the editor reports success only after commit and retains input under injected storage failure.
- [ ] 2.4 Add populated v1/v2 fixture schemas, forward migration, and incompatible-version handling; verify identities/relationships survive migration and failed migration/newer schema never triggers destructive recreation.
- [ ] 2.5 Exercise the documented bulk-write workload off the UI execution path as appropriate; verify navigation/scrolling remain usable and capture a 10,000-record workload responsiveness trace with timings.

## 3. Establish adaptive navigation

- [ ] 3.1 Add stable collection/item routes and local fixture lookup; verify direct links, refresh resolution, unknown IDs, Back, and parent fallback without history through router tests.
- [ ] 3.2 Implement wide three-pane, intermediate navigation/detail-replacement, and compact stacked composition using centralized width constraints; verify boundary-width and large-text widget tests without clipped essential controls.
- [ ] 3.3 Preserve selected IDs, editor drafts, and collection scroll across layout changes; verify a resize-during-edit test retains text and returns to the previous collection position.
- [ ] 3.4 Add keyboard activation/close, visible focus restoration, editor-owned Ctrl/Cmd+A, and independent pane scrolling; verify focused interaction tests and record representative Windows pointer/keyboard checks.
- [ ] 3.5 Capture wide/intermediate/compact fixture screenshots and compare their hierarchy with the reference audit; verify the evidence labels them as foundation UI, uses original assets, and does not claim finished task workflows.

## 4. Prove browser storage and offline startup

- [ ] 4.1 Add the WASM connection adapter and compatible worker/assets with storage-mode reporting; verify persisted fixture values survive a browser restart and record the actual selected mode.
- [ ] 4.2 Add capability gating, separate persistence-permission risk state, and fixture recovery diagnostics; verify volatile/unsafe fallback blocks normal writes while permission denial alone does not reject otherwise safe storage.
- [ ] 4.3 Add cross-tab schema compatibility and upgrade coordination with crash recovery; verify compatible two-tab edits survive, an old writer cannot mutate a newer schema, and termination releases or recovers coordination safely.
- [ ] 4.4 Provide a production-like local static host configuration for the built app with route fallback, WASM MIME, and configurable security headers; verify worker loading and direct-link startup with the intended headers.
- [ ] 4.5 Add complete-release asset caching and explicit offline-ready state, excluding credentials/authenticated responses; verify a built-bundle offline detail reload allows a local fixture commit after initial preparation.
- [ ] 4.6 Add staged shell update and schema compatibility handling without forced reload over drafts; verify interrupted downloads retain the previous complete shell and an old shell refuses a newer incompatible database without resetting it.
- [ ] 4.7 Run the required desktop Chromium end-to-end matrix covering restart, offline deep link, concurrent edits, crash recovery, stale-tab migration, interrupted update, and capability states; attach procedures/results and leave this task unchecked if a required scenario fails or is unavailable.

## 5. Assess authentication feasibility separately

- [ ] 5.1 Refresh official provider platform/REST/browser-flow documentation and record one Windows/Linux candidate, callback/secure-storage prerequisites, and web-header constraints in an auth feasibility decision record; verify every platform-support claim has a current source.
- [ ] 5.2 Within the design's time box, exercise the candidate using available explicitly configured test resources, or document the exact missing prerequisites; deliver a validated/rejected/blocked result with real-provider versus simulation evidence, callback/refresh/security findings, and no committed credentials.
- [ ] 5.3 Record every unresolved real-provider/host check as a prerequisite for the optional-account proposal; verify normal local startup and fixture storage/navigation still work without loading auth tooling.

## 6. Validate platform coverage and hand off

- [ ] 6.1 Add six-target build/run documentation and host-appropriate build-check configuration; verify commands are mapped to Windows/Linux/macOS hosts, Apple signing limitations are explicit, and no unexecuted build is labeled passing.
- [ ] 6.2 Run common format/analyze, repository/migration, router, adaptive layout, and failure-path tests; retain exact commands and successful results and keep this task unchecked on failure.
- [ ] 6.3 Run the Windows runtime acceptance journey, including offline startup, committed write followed by forced process termination/reopen, migration/failure preservation, keyboard navigation, resize, and pane scrolling; retain logs/screenshots and keep this task unchecked if required evidence is missing.
- [ ] 6.4 Assess Android, iOS, macOS, Linux, Firefox, Safari, Android Chrome, and iOS Safari on available hosts; verify each coverage row records PASS/FAIL/NOT RUN with an artifact or a concrete prerequisite and carries missing acceptance into the local-MVP release gates.
- [ ] 6.5 Complete `docs/foundation-validation.md` with revision/toolchain data, source-linked auth findings, storage decision, reusable boundaries, fixture limitations, and deferred platform/account gates; verify no task/schema/sync or six-platform runtime capability is claimed beyond its evidence.
- [ ] 6.6 Review implementation against all five capability specs and required acceptance checks, then rerun strict OpenSpec validation; verify every required task is complete before declaring this foundation implemented and that no cloud deployment or unrelated workspace change occurred.
