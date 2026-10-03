# Docket

An account-independent Flutter foundation for a local-first personal task manager.
The current application provides local bootstrap, isolated storage fixtures and
adaptive navigation. Production task workflows and optional accounts come later.

Use Flutter 3.44.9 / Dart 3.12.2, then `flutter pub get` and `flutter run`.
The ordinary launch is intentionally empty. To exercise disposable records:
`flutter run -t lib/main_fixture.dart`, then open **Fixture diagnostics**.

- [Platform runbook and verification commands](docs/platform-runbook.md)
- [Foundation validation and coverage limits](docs/foundation-validation.md)
- [Optional-account feasibility decision](docs/auth-feasibility.md)
- [Archived foundation change](openspec/changes/archive/2026-10-03-validate-cross-platform-foundations/proposal.md)

The `main_acceptance.dart` and `main_native_acceptance.dart` entrypoints are
explicit test harnesses. Do not distribute them as the ordinary application.
