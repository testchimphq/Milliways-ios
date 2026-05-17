#!/usr/bin/env bash
# Run SmartTests from repo-root `tests/` (not under ios/ or android/).
#
# Usage (from repo root):
#   ./scripts/run-smarttests.sh ios
#   ./scripts/run-smarttests.sh android
#   ./scripts/run-smarttests.sh ios --grep "main dishes"
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PLATFORM="${1:-ios}"
shift || true

: "${MILLIWAYS_API_BASE_URL:=http://localhost:3001}"
export MILLIWAYS_API_BASE_URL

MCP_JSON="$ROOT/.cursor/mcp.json"
TESTS_ROOT="$ROOT/tests"

if [[ ! -f "$MCP_JSON" ]]; then
  echo "Missing $MCP_JSON — add testchimp MCP env (TESTCHIMP_API_KEY, TESTCHIMP_BACKEND_URL)." >&2
  exit 1
fi

echo "==> Starting local backend"
docker compose up --build -d

echo "==> Waiting for backend at $MILLIWAYS_API_BASE_URL"
for _ in {1..60}; do
  if curl -fsS "$MILLIWAYS_API_BASE_URL/health" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done
curl -fsS "$MILLIWAYS_API_BASE_URL/health" >/dev/null

if [[ "$PLATFORM" == "ios" ]]; then
  : "${DEVICE_NAME:=iPhone 17 Pro}"
  export DEVICE_NAME
  echo "==> Building iOS app ($DEVICE_NAME)"
  make -C "$ROOT/ios" build
  make -C "$ROOT/ios" boot
  export IOS_APP_PATH="$ROOT/ios/build/Build/Products/Debug-iphonesimulator/Milliways.app"
  xcrun simctl install booted "$IOS_APP_PATH"
elif [[ "$PLATFORM" == "android" ]]; then
  echo "==> Building Android debug APK"
  (cd "$ROOT/android" && ./gradlew :app:assembleDebug)
  export ANDROID_APK_PATH="$ROOT/android/app/build/outputs/apk/debug/app-debug.apk"
else
  echo "Usage: $0 ios|android [mobilewright args...]" >&2
  exit 1
fi

echo "==> Installing SmartTests dependencies"
npm ci --prefix "$TESTS_ROOT"

echo "==> Running Mobilewright ($PLATFORM) — TestChimp env from .cursor/mcp.json"
node "$ROOT/scripts/run-mobilewright-with-mcp-env.mjs" \
  --mcp-json "$MCP_JSON" \
  --tests-root "$TESTS_ROOT" \
  -- mobile/e2e/common -c mobilewright.config.ts "--project=$PLATFORM" "$@"
