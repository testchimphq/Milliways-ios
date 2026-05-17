# Milliways — TestChimp agent instructions

## Repo layout vs TestChimp mappings

- **SmartTests root:** `tests/` (`.testchimp-tests`, `project_type=mobile`) — iOS + Android via Mobilewright `ios` / `android` projects.
- **Plans root:** `plans/` (`.testchimp-plans`) — unified mobile TestChimp project.
- **TestChimp project ID:** `0853e684-9871-483a-bc71-ca84d922be7c` (staging backend; single project for both platforms).
- **MCP / CLI / runner env:** repo-root `.cursor/mcp.json` → `TESTCHIMP_API_KEY`, `TESTCHIMP_BACKEND_URL` (staging). `npm run test:*` / `scripts/run-smarttests.sh` apply these to the Mobilewright child process automatically. Never commit keys.

## Init progress

### Completed Items

- Unified `tests/` + `plans/` markers; mobile scaffold with `@testchimp/playwright` reporter.
- Workstation MCP at `.cursor/mcp.json` (staging).
- Initial SmartTests: `mobile/e2e/common/menu.spec.js`, `navigation.spec.js` (iOS + Android).
- TrueCoverage RUM wired in app; events documented under `plans/events/` (no expansion in init).

### Pending Items

- Additional scenario coverage beyond menu + navigation smoke paths.
- CI workflow update (deferred by team choice).

### Deferred Items

- AIMock / LLM mocking — N/A.
- CI SmartTests jobs — not needed yet.

---

## Environment Provision Strategy

### Local - Test Authoring

SmartTests root is **`tests/`** at the **repo root** (not under `ios/`).

1. **Backend** (repo root): `docker compose up --build -d` then `curl -fsS http://localhost:3001/health`
2. **iOS app:** `cd ios && make build` → `ios/build/Build/Products/Debug-iphonesimulator/Milliways.app`
3. **Android APK:** `cd android && ./gradlew :app:assembleDebug`
4. **Run** (repo root — recommended):

```bash
./scripts/run-smarttests.sh ios
./scripts/run-smarttests.sh android
```

Or from `tests/` after `npm ci`:

```bash
cd tests
npm run test:ios      # loads .cursor/mcp.json → TESTCHIMP_BACKEND_URL + API key
npm run test:android
```

`scripts/run-mobilewright-with-mcp-env.mjs` **requires** `.cursor/mcp.json` and exports **`TESTCHIMP_API_KEY`** + **`TESTCHIMP_BACKEND_URL`** (staging) on the Mobilewright process. Reporter does **not** use `TESTCHIMP_PROJECT_ID` (that is for app TrueCoverage/RUM only). `TESTCHIMP_TESTS_FOLDER=.` (paths relative to SmartTests root `tests/`).

Overrides: `IOS_APP_PATH`, `ANDROID_APK_PATH`, `MILLIWAYS_API_BASE_URL` (`tests/.env-QA`).

RUM: `android/gradle.properties` + Xcode `TESTCHIMP_*` build settings.

### CI - Test Execution

Deferred. When enabled, use macOS for iOS Simulator + `tests/` as cwd; pass `TESTCHIMP_API_KEY` and `TESTCHIMP_BACKEND_URL` as secrets.

## TrueCoverage Plan

- **Enabled** for staging unified project `0853e684-9871-483a-bc71-ca84d922be7c`.
- **Instrumented events (current slice only):** `auth-session-started`, `menu-loaded`, `order-submitted-success` — see `plans/events/`.
- RUM `environment` aligns with `TESTCHIMP_ENV` / build config (`staging` or `QA` for local Debug).

## Mocking Plan

- **http_mocking:** N/A — local Docker API; mobile UI flows.
- **aimock:** deferred / not applicable.

## ExploreChimp

- Use `markScreenState` in UI SmartTests when running explorations.
- Set `EXPLORECHIMP_ENABLED` per team policy; `TESTCHIMP_BRANCH_NAME` from current git branch for local runs.

## Past learnings — authoring & validation (FAQ)

### Q: Reporter or API returns 401

**A:** Use `npm run test:ios` from `tests/` or `./scripts/run-smarttests.sh ios`. Confirm: `Reporter env: TESTCHIMP_BACKEND_URL=https://featureservice-staging.testchimp.io TESTCHIMP_API_KEY=set`. Do **not** rely on empty `setup/global.setup.spec.js` (removed from config — it was Playwright-only noise in staging). If mobile specs still do not appear, sync the mapped **`tests/`** folder in TestChimp and check reporter logs for `testFound=true` on `menu.spec.js` / `navigation.spec.js`.

### Q: Tests cannot find the app bundle or APK

**A:** Build iOS (`make build`) or Android (`./gradlew :app:assembleDebug`), or set `IOS_APP_PATH` / `ANDROID_APK_PATH`. Defaults are resolved in `tests/mobilewright.config.ts` from repo root.

### Q: Seed user fails

**A:** Ensure Docker backend is up and `curl -fsS http://localhost:3001/health` succeeds before running tests.

### Q: iOS sign-in never reaches “New Order” / simctl launch exit 4

**A:** (1) Docker up + `curl -fsS http://localhost:3001/health`. (2) `cd ios && make build` then `xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/Milliways.app`. (3) Bundle id **`com.mobilenext.Milliways`**. (4) After **Sign In**, iOS may show a system sheet (**Save Password** → tap **Not Now**, or **Local Network** → **Allow**); `tests/shared/ios-helpers.js` dismisses these automatically on the `ios` project. (5) Account toolbar: prefers **Account** a11y label, falls back to **`person.circle`**.
