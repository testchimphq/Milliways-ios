#!/usr/bin/env bash
# Local SmartTests (tc-tests) on iOS Simulator — no backend.
# Prerequisites: Xcode, CocoaPods (if the app needs them), Makefile `build` / `boot` targets.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

: "${DEVICE_NAME:=iPhone 17 Pro}"
export DEVICE_NAME

echo "==> Building Debug app for Simulator ($DEVICE_NAME)"
make build

echo "==> Booting Simulator"
make boot

export IOS_APP_PATH="$ROOT/build/Build/Products/Debug-iphonesimulator/Milliways.app"
if [[ ! -d "$IOS_APP_PATH" ]]; then
  echo "Expected app not found: $IOS_APP_PATH" >&2
  exit 1
fi

echo "==> Running SmartTests smoke from tc-tests (TestChimp env from .cursor/mcp.json when present)"
cd "$ROOT/tc-tests"
node "$ROOT/scripts/run-mobilewright-with-mcp-env.mjs" smoke.quick.spec.js
