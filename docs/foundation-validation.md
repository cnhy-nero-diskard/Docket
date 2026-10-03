# Foundation validation

Validated 2026-10-03 (Asia/Taipei). **Minimum foundation acceptance PASS.** Source base
`9c542bc55b1c96c96e0cf90a1b1afe78758853dc`, branch
`feat/validate-cross-platform-foundations`; implementation is an uncommitted diff.
No deployment, account integration, task schema, or synchronization is included.
The retained [source manifest](evidence/source-manifest.json) identifies the
implementation/configuration files by SHA256. Browser evidence also records the
hash-derived complete release ID. Exact reproduction commands are in the
[platform runbook](platform-runbook.md).

## Toolchain inventory

`flutter --version`, `flutter doctor -v`, and `flutter devices` were run before
implementation. Flutter **3.44.9 stable**, framework `6b182d2c75`, Dart **3.12.2**,
engine `5a2a6a42cc`. The global SDK was not upgraded. The Flutter Git remote is
nonstandard; its URL is excluded from evidence because it contains userinfo.

Host: Windows 11 Pro 23H2, build 22631.6199. Visual Studio Community 2026 18.8.2,
Windows SDK 10.0.26100.0. Android SDK 36.0.0, Java 21.0.10, accepted Android
licenses. Available emulator: Android 15/API 35 x86_64. Chrome 153.0.8010.53 and
Edge 154.0.4258.48 are available. The actual Playwright `chrome` channel used
Chrome **154.0.8037.95**, recorded separately from Flutter doctor's browser
discovery. No macOS/Xcode or Linux host is configured.
Initial plugin setup failed because Windows Developer Mode was disabled; after
the user enabled it, `flutter pub get` passed.

## Package and boundaries

`flutter create --project-name docket --org dev.docket --platforms
android,ios,windows,macos,linux,web --empty .` generated all six target folders.
The existing OpenSpec/tooling files were preserved. `pubspec.lock` records
resolved dependencies, including Drift 2.35.1, SQLite 3.5.2, Riverpod 3.4.3,
go_router 18.0.2. The `.metadata` file pins scaffold provenance.

- `lib/app`: Riverpod composition, startup, and logical router.
- `lib/data/local`: ordinary bootstrap metadata and separate fixture schema.
- `lib/platform`: native background SQLite and browser WASM/coordination.
- `lib/features/shell`: adaptive composition, transient drafts/focus/scroll.
- `lib/main.dart`: empty local-only shell, no fixture writes or auth dependency.
- `lib/main_fixture.dart`: labeled disposable harness; only the namespace
  `docket_foundation_fixture` can be reset by its controls.

The fixture tables are not the future production task domain. The ordinary
`docket_local` store contains only bootstrap metadata. Auth, synchronization,
backups, cloud resources, and final task workflows remain separate proposals.

## Evidence ledger

| Check | Outcome | Evidence / prerequisite |
|---|---|---|
| Toolchain inventory | PASS | Commands and versions above |
| Six target scaffolds | PASS | Generated target directories; original tracked files preserved |
| Dependency resolution | PASS | `flutter pub get`, retained lockfile |
| Common format/analyze/tests | PASS | [Format](evidence/format.txt), [analysis](evidence/analyze.txt), [13 tests](evidence/common-tests.txt), [strict OpenSpec](evidence/openspec.txt) |
| Windows build/runtime acceptance | PASS | [Native checks](evidence/windows-runtime.txt) and [final run](evidence/windows-runtime-final.txt), [forced reopen](evidence/native-reopen.json), [trace](evidence/native-responsiveness.json), screenshot below |
| Chromium built-bundle matrix | PASS | [11 scenarios](evidence/chromium.json), Chrome 154.0.8037.95, release ID in evidence; real headless browser with labeled injected faults |
| Edge specifically | NOT RUN | Installed; repeat Chromium matrix using the Edge channel before claiming Edge-specific acceptance |
| Android emulator build/runtime | PASS | [Actual API 35 emulator output excerpt](evidence/android-runtime.txt); device force-stop/lifecycle gate remains |
| Android physical device/restart | NOT RUN | Connected physical device and forced-process/lifecycle journey required before local-MVP acceptance |
| iOS | NOT RUN | macOS + Xcode + simulator/device; signing for devices/distribution |
| macOS | NOT RUN | macOS + Xcode + native runtime; sandbox acceptance |
| Linux | NOT RUN | Linux desktop + clang/CMake/Ninja/GTK development packages |
| Firefox | NOT RUN | Firefox 157.0 installed, but no configured compatible Gecko automation driver; run its full matrix manually or provision a driver |
| Safari | NOT RUN | macOS with Safari; browser storage and offline checks |
| Android Chrome | NOT RUN | Chrome 152.0.7977.82 on emulator; configure isolated browser automation and a secure/ADB-forwarded origin, then run mobile storage/offline/navigation matrix |
| iOS Safari | NOT RUN | iOS device/simulator and secure test origin |
| Remote CI matrix | NOT RUN | Workflow supplied; no push or CI run was requested |

All NOT RUN rows remain local-MVP acceptance gates. Generated configuration
does not establish build or runtime support. Injected failures are simulations;
they do not establish real quota/full-disk coverage.

## Storage decision and lifecycle

Retain Drift/SQLite for the next local-domain proposal. Native executors run in
background isolates. Browser acceptance selected **opfsLocks** under COOP
`same-origin` / COEP `require-corp`. Persistence permission was actually denied
(`protected: false`), separately from safe durable commits. The fixture still
survived closing/restarting the browser and offline reload.

Each repository operation opens, checks/migrates, executes, and closes its store.
On the web all those steps run under one origin-wide, namespace-scoped Web Lock.
Thus no idle tab retains a database handle across a schema upgrade, and browser
termination releases ownership without a potentially unsafe expiry lease. A
persisted schema marker and SQLite's own version check reject old writers.
Transactions own writes; post-commit invalidations feed repository observations
and a cross-tab BroadcastChannel. This deliberately trades connection overhead
for a small auditable coordination boundary. A future long-lived executor must
preserve the same upgrade/closure contract.

The 10,000-row workload is one transaction, with 250-record batches executed
off the UI isolate and progress between batches. The final Windows debug runtime
trace is [native-responsiveness.json](evidence/native-responsiveness.json).
It records elapsed time, progress, navigation/scroll iterations, and frame build/
raster timings. This is measured fixture responsiveness, not a production task
latency promise or release-mode performance benchmark.

The 684 ms Windows sample includes 40 progress callbacks and 9 navigation/scroll
iterations. See the trace for actual frame timings; no unexplained visible stall
was observed in the tested workload. Android timing artifacts are not retained,
so only its runtime assertions, not a measured performance claim, are reported.

Browser recovery diagnostics export only a readable, explicitly disposable
fixture database. They do not define the product backup/restore format. Unsafe
or volatile capability blocks writes, and the ordinary local store has no reset
control. Failed migrations and unsupported schema versions do not recreate files.

## UI/reference review

The [wide](evidence/foundation-wide.png), [intermediate](evidence/foundation-intermediate.png),
and [compact](evidence/foundation-compact.png) Chromium screenshots are labeled
foundation fixtures. The [Windows runtime capture](evidence/native-foundation.png)
comes from the running native integration-test view. Against the reference audit,
they preserve pale navigation, a distinct collection surface, light vertical
rows, and an optional right detail pane. Intermediate detail replaces collection;
compact detail occupies the page. The implementation uses original composition
and Flutter Material icons/default scaffold assets; no Taskmaster assets or code
were copied. This is not finished To Do/task workflow parity.

Widget checks cover exact width boundaries and 2x text, draft and logical focus
retention, scroll restoration, unknown IDs, deterministic parent navigation,
Ctrl+A text ownership, Enter activation, Escape close, and platform Back. Native
checks dispatch pointer/key input to the real Flutter view and resize its layout
constraints; these are automated runtime checks, not manual OS/screen-reader
acceptance. OS window-drag/accessibility and broader device checks remain useful
local-MVP acceptance work.

## Authentication and downstream handoff

The [auth decision](auth-feasibility.md) refreshes official Firebase, native OAuth,
Windows credential, and Linux keyring sources. Result: **BLOCKED** on explicitly
configured Docket identity resources and callbacks, plus Linux host access.
No provider roundtrip, token refresh or credential lifecycle is claimed passing.
These are gates for `add-optional-accounts`; no auth code/config is loaded by
ordinary startup. There was no cloud provisioning or deployment.

The next local-domain change can reuse bootstrap/composition, connection and
transaction boundaries, stable logical navigation, and draft ownership. It must
design production task/list/step entities, account/profile lifecycle, richer
editing semantics, and migrations independently of this fixture schema. Sync,
outbox, conflict handling, backups, notifications, and production account security
have not been implemented or validated by these fixtures.
