#!/usr/bin/env bash
# Flutter/Dart: format with `dart format`, analyze with `dart analyze`
# (config: analysis_options.yaml). Runs from the nearest pubspec.yaml so
# monorepos with several packages work.

# Missing toolchain: warn and pass during agent edits; fail when AGENT_CHECK_STRICT=1
# (set by pre-commit), so a commit can never pass just because nothing ran.
missing() { echo "$1" >&2; [ "${AGENT_CHECK_STRICT:-0}" = 1 ] && exit 1; exit 0; }

f="$1"
case "$f" in *.dart) ;; *) exit 0 ;; esac
# Generated code is rewritten by build_runner; never format or lint it by hand.
case "$f" in *.g.dart | *.freezed.dart | *.mocks.dart) exit 0 ;; esac

if ! command -v dart >/dev/null 2>&1; then
  missing "flutter hook: dart not on PATH — skipped $f"
fi

abs="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
d="$(dirname "$abs")"
while [ "$d" != "/" ] && [ ! -f "$d/pubspec.yaml" ]; do d="$(dirname "$d")"; done
[ -f "$d/pubspec.yaml" ] || missing "flutter hook: no pubspec.yaml above $f"

dart format "$abs" >/dev/null 2>&1
out=$(cd "$d" && dart analyze --fatal-infos "$abs" 2>&1) || { printf '%s\n' "$out" >&2; exit 1; }
