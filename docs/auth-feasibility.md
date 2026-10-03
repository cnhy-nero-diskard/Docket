# Optional-account candidate: BLOCKED

Assessed 2026-10-03 within one focused documentation session (less than the
one-working-day budget). No provider SDK is imported by the application; no
cloud resources were provisioned. No real-provider or simulated login is
reported as passing. Local startup/storage/navigation tests pass without auth.

## Current official support and one candidate

The [FlutterFire platform matrix](https://firebase.google.com/docs/flutter/setup)
lists Authentication for Android, iOS, Web, other Apple platforms (beta), and
Windows (beta). Its Windows warning limits usage to local development; Linux is
absent. A common production desktop Firebase Flutter SDK cannot be assumed.

Candidate for Windows/Linux: system-browser hosted Firebase login, returning a
short-lived, single-use, challenge-bound code to a loopback desktop callback,
followed by HTTPS exchange and Firebase custom-token sign-in. This broker is
proposed application infrastructure, **not** an existing Firebase desktop flow.
The [Firebase REST reference](https://firebase.google.com/docs/reference/rest/auth)
documents custom-token exchange and refresh-token exchange; that does not prove
the security or operability of this proposed broker.

[RFC 8252](https://www.rfc-editor.org/rfc/rfc8252) supplies the external-browser,
loopback callback, and public-client/PKCE guidance for native OAuth applications.
The candidate still needs a reviewed protocol mapping to Firebase. Use exact
callback binding, random state and verifier, short expiry, one-use redemption,
and no long-lived tokens in URLs or logs. Wrong state, wrong verifier, replay,
expiry, cancellation, callback port collision, and exchange failure must fail
closed without changing the local profile.

Windows requires a tested credential adapter using the user's credential store
([CredWrite](https://learn.microsoft.com/en-us/windows/win32/api/wincred/nf-wincred-credwritew)).
Linux requires an available, unlocked session secret service/keyring and tested
packaging ([Secret Service API](https://specifications.freedesktop.org/secret-service/latest/)).
Neither OS's secure credential persistence was exercised here. Never fall back
to storing refresh tokens in fixture SQLite or shell caches.

## Browser/header interaction

The browser storage test uses COOP `same-origin` and COEP `require-corp` with
same-origin workers/WASM. [Drift documents popup incompatibilities](https://drift.simonbinder.eu/platforms/web/).
The production candidate should evaluate redirect or a separate login origin
with a narrow return flow; popup success is not assumed. Firebase documents
[redirect/storage restrictions and hosting alternatives](https://firebase.google.com/docs/auth/web/redirect-best-practices).
Authentication return must be tested on the exact final origin/header policy.
No authenticated responses, auth pages, tokens, or credentials are in the
versioned Docket shell manifest.

## Missing prerequisites and the account milestone gate

No Docket test identity project, hosted login origin, enabled provider/test
account, broker/code-exchange endpoint, or authorized callback configuration was
explicitly configured or supplied. An unrelated machine/cloud account is not a
test resource for this project. Linux and Apple hosts are also unavailable.

Before `add-optional-accounts`, supply those test resources and validate:

| Check | Result now | Required evidence |
|---|---|---|
| Windows real-provider roundtrip | NOT RUN | Configured project, login host, broker, loopback callback |
| Linux real-provider roundtrip | NOT RUN | Same, plus Linux desktop and keyring |
| Web login with selected storage headers | NOT RUN | Actual auth domain, redirect/callback paths and browser matrix |
| State/verifier mismatch, replay, expiry, cancel | NOT RUN | Real broker enforcement and negative cases |
| Refresh, revocation and refresh failure | NOT RUN | Real provider tokens; secure storage and redacted logs |
| Callback collision and secure credential lifecycle | NOT RUN | Windows/Linux runtime tests |
| Local startup without account tooling | PASS | Common startup, storage, router tests; no auth dependency |

Decision: **blocked candidate**, neither validated nor rejected. Do not select
Firebase as the final desktop provider or begin production account integration
until these gates pass. This assessment does not block local-domain work.
