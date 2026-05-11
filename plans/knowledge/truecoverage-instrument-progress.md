# TrueCoverage instrumentation progress

**Platforms:** Native **iOS** (`project_type=ios`) and native **Android** (`project_type=android`).

| App | SDK | Automation |
|-----|-----|------------|
| **iOS** | [TestChimpRum](https://github.com/testchimphq/testchimp-rum-ios) (SPM, ≥ 0.1.0) | `testchimp-rum` URL scheme + `TestChimpRum.handleAutomationURL` in `ios/Milliways/MilliwaysApp.swift` |
| **Android** | [testchimp-rum-android](https://github.com/testchimphq/testchimp-rum-android) (JitPack `0.1.0`) | `testchimp-rum://truecoverage/...` intent filter + `TestChimpRum.handleAutomationIntent` in `android/.../MainActivity.kt`; init in `MilliwaysApplication` via `MilliwaysRum.configureIfNeeded` |

SmartTests / Mobilewright: set **`TESTCHIMP_PROJECT_TYPE`** to **`ios`** or **`android`**, use **`installTestChimp`** in fixtures so the reporter can open automation URLs on the device under test.

**Cross-client metadata:** Every journey emit includes **`platform`** = **`ios`** or **`android`** (set inside `MilliwaysRum.emit` on each native app). The future web client should use **`web`** the same way in its shared emit helper.

## Screens / flows

### Auth

| Event | Status | Notes |
|-------|--------|--------|
| `auth_session_started` | **done** | **iOS:** `SessionManager` after successful sign-in or sign-up. **Android:** `AppViewModel.performSignIn` / `performSignUp`. `plans/events/auth-session-started.event.md` |

### Menu

| Event | Status | Notes |
|-------|--------|--------|
| `menu_loaded` | **done** | **iOS:** after successful `fetchMenu` in `MenuView`. **Android:** after successful menu fetch in `AppViewModel.loadMenu`. `plans/events/menu-loaded.event.md` |

### Checkout

| Event | Status | Notes |
|-------|--------|--------|
| `order_submitted_success` | **done** | **iOS:** after successful `submitOrder` in `OrderView`. **Android:** after successful `submitOrder` in `AppViewModel`. `plans/events/order-submitted-success.event.md` |

## Planned (not yet instrumented)

| Event | Status | Notes |
|-------|--------|--------|
| Menu item added to cart | **planned** | Optional: `cart_item_added` from `MenuItemDetailView` with category bucket only |
| Delivery completion | **planned** | Optional: `delivery_flow_completed` from `DeliveryView` |

## App configuration

### iOS

- **Credentials:** User-defined build settings `TESTCHIMP_PROJECT_ID` and `TESTCHIMP_API_KEY` on the **Milliways** target under **`ios/`** (merged into `ios/Milliways-Info.plist`). Empty defaults skip RUM init (Debug log). Same project API key as SmartTests / MCP is typical.
- **Environment tag:** `TESTCHIMP_ENV` → `TestChimpEnvironment` in the plist (SDK `environment` field). Match the strings you use in TrueCoverage / `list-rum-environments` (e.g. `QA` vs `production`). Runtime override: process env `TESTCHIMP_ENV`.
- **RUM ingest:** `TESTCHIMP_BACKEND_URL` → `TestChimpBackendURL` → SDK `testchimpEndpoint`. Debug and Release both default to **`https://featureservice-staging.testchimp.io`** in the Xcode target; override via process env `TESTCHIMP_BACKEND_URL` if needed.
- **TrueCoverage test linking:** No extra app hooks beyond URL scheme; reporter sets automation context via `testchimp-rum://truecoverage/v1/...` when Mobilewright runs with `installTestChimp`.

### Android

- **Credentials:** Gradle properties **`TESTCHIMP_PROJECT_ID`** and **`TESTCHIMP_API_KEY`** (e.g. in `android/gradle.properties`, `~/.gradle/gradle.properties`, or `-P` on the command line). They are merged into **`BuildConfig`** at compile time. Empty values skip RUM init (same as iOS); see Logcat tag **`Milliways`** for the skip message.
- **Environment tag:** **`BuildConfig.TESTCHIMP_ENV`** — **debug** builds default to **`QA`**; **release** defaults to **`production`**. Override at runtime with process environment **`TESTCHIMP_ENV`** (see `MilliwaysRum`).
- **RUM ingest:** Gradle property **`TESTCHIMP_BACKEND_URL`** (optional); if unset, **`BuildConfig`** defaults to **`https://featureservice-staging.testchimp.io`**. Runtime override: env **`TESTCHIMP_BACKEND_URL`**.
- **TrueCoverage test linking:** `MainActivity` **`singleTop`**, **`VIEW`** intent filter for **`testchimp-rum`**, **`truecoverage`**, path prefix **`/v1`**; **`TestChimpRum.handleAutomationIntent`** in **`onCreate`** / **`onNewIntent`**.
