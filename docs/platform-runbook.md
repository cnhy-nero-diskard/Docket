# Build and run the foundation

Toolchain: Flutter 3.44.9 stable / Dart 3.12.2. Keep the checked-in lockfile.
No global SDK upgrade is required. Run from the repository/worktree root:

```text
flutter pub get
dart run build_runner build
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test --reporter expanded
```

`flutter run -t lib/main.dart` is the ordinary empty local shell. Use
`-t lib/main_fixture.dart` for explicitly labeled disposable fixtures. Open
fixture diagnostics to seed/reset records, inject one write failure, copy
diagnostic JSON, or run the 10,000-record batch. Never reset browser site data as
a recovery strategy. Native databases use the application's support directory.

| Target | Host and prerequisites | Build | Runtime |
|---|---|---|---|
| Windows | Windows, Visual Studio C++ desktop workload/SDK, Developer Mode for plugin symlinks | `flutter build windows --release` | `flutter run -d windows -t lib/main_fixture.dart` |
| Android | Windows/Linux/macOS, Android SDK/JDK, accepted licenses | `flutter build apk --debug` | `flutter run -d <device-id> -t lib/main_fixture.dart` |
| Linux | Linux desktop, clang, CMake, Ninja, pkg-config, GTK3 development libraries | `flutter build linux --release` | `flutter run -d linux -t lib/main_fixture.dart` |
| macOS | macOS, Xcode and command-line tools, CocoaPods if required by plugins | `flutter build macos --release` | `flutter run -d macos -t lib/main_fixture.dart` |
| iOS | macOS, Xcode, iOS SDK and simulator | `flutter build ios --release --no-codesign` | `flutter run -d <simulator-id> -t lib/main_fixture.dart` |
| Web | Any Flutter-supported development host, Node 22+, supported secure browser | Commands below | Same-origin static host below |

Unsigned iOS compilation does not install on a physical device or establish App
Store distribution. Devices need signing/team/provisioning; macOS distribution
needs signing/notarization and sandbox review. None is configured here. The CI
matrix is configuration, not evidence of an executed remote build.

## Built browser bundle

Download **both** assets from the pinned Drift 2.35.1 release:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tool/prepare_web.ps1
flutter build web --release --pwa-strategy=none -t lib/main_fixture.dart
node tool/seal_web.mjs
node tool/host_web.mjs
```

On Linux/macOS the equivalent downloads are:

```sh
curl -fL https://github.com/simolus3/drift/releases/download/drift-2.35.1/sqlite3.wasm -o web/sqlite3.wasm
curl -fL https://github.com/simolus3/drift/releases/download/drift-2.35.1/drift_worker.js -o web/drift_worker.js
```

Asset SHA256 values (verify after download):

```text
fbcd2e8214f9231ea961e1b7706a22dd1194cfbfe6f26f13841b5aa7a0be1a1f sqlite3.wasm
fe5f13be0526f78293796aefb9a29d3823a2dbdbf1bccd3f0faeb90eaaafd72a drift_worker.js
```

Open `http://127.0.0.1:8787/lists`. Loopback is a secure browser context. Remote
hosts need HTTPS. The host serves SPA route fallback, WASM MIME, same-origin
CORP, and COOP/COEP isolation. `ISOLATION=off`, `CORS_ORIGIN=<specific origin>`,
and `PORT=<port>` configure deliberate tests. Test each origin independently:
browser storage is origin-bound. The root-path build is intentional.

The custom worker stages every built runtime/font/WASM/worker asset with SHA256
verification. Only complete, schema-compatible shells activate. The old shell
serves active tabs until they all close; updates never force-reload a draft.
Wait for **Ready offline** before testing offline reload. Incomplete preparation
requires reconnecting; do not erase the database. Auth/API responses are outside
the cache allowlist. Keep worker and SQLite versions paired on upgrades.

## Reproduce acceptance

```text
flutter test integration_test/native_foundation_test.dart -d windows --reporter expanded
flutter build windows --release -t lib/main_native_acceptance.dart
powershell -NoProfile -ExecutionPolicy Bypass -File tool/native_reopen.ps1
flutter build web --release --pwa-strategy=none -t lib/main_acceptance.dart
node tool/seal_web.mjs
npm ci
node tool/host_web.mjs
```

In a second terminal: `node tool/browser_acceptance.mjs`. It launches installed
Chrome with a temporary isolated profile, uses a real release bundle, temporarily
changes only the built service worker for interrupted/staged-update tests, and
writes scoped evidence. `main_acceptance.dart` exposes fixture test hooks and
must not be distributed as the ordinary or fixture app. Capability selection and
future schema 99 are explicitly injected; renderer crash and browser restart
are real. The native reopen script kills only the process it starts, after a
flushed commit readiness record. Native HTTP is disabled inside the probe.

Android can use the same integration entrypoint with `-d <device-id>`. Additional
device kill/reopen, OS lifecycle, mobile-browser storage/offline, Linux, and Apple
runtime checks remain release gates until recorded in the validation report.
