#!/usr/bin/env bash
# Flutter/Dart dependency audit. pub has no built-in vulnerability audit, so this
# uses osv-scanner against pubspec.lock (https://google.github.io/osv-scanner/).
# To accept a vulnerability, add it to osv-scanner.toml WITH a reason: why it's
# unreachable here, and what would make you re-evaluate it.

set -euo pipefail

if [ ! -f pubspec.lock ]; then
  echo "flutter audit: pubspec.lock not found — commit it (apps should)" >&2
  exit 1
fi

if ! command -v osv-scanner >/dev/null 2>&1; then
  echo "flutter audit: osv-scanner not installed (brew install osv-scanner)" >&2
  exit 1
fi

osv-scanner scan source --lockfile pubspec.lock
