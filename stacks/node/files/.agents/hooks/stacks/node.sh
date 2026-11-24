#!/usr/bin/env bash
# Node/TypeScript: format with prettier, lint with eslint (config: eslint.config.mjs).
# Uses the project's own node_modules/.bin (nearest one above the file, so it works
# in monorepos). Run `npm install` first.
# Type errors are not checked per file; run `npx tsc --noEmit` before done.

# Missing toolchain: warn and pass during agent edits; fail when AGENT_CHECK_STRICT=1
# (set by pre-commit), so a commit can never pass just because nothing ran.
missing() { echo "$1" >&2; [ "${AGENT_CHECK_STRICT:-0}" = 1 ] && exit 1; exit 0; }

f="$1"
case "$f" in
  *.ts | *.tsx | *.mts | *.cts | *.js | *.jsx | *.mjs | *.cjs) lint=1 ;;
  *.json | *.css | *.scss | *.md | *.yaml | *.yml) lint=0 ;;
  *) exit 0 ;;
esac
case "$f" in */node_modules/*) exit 0 ;; esac

d="$(cd "$(dirname "$f")" && pwd)"
bin=""
while [ "$d" != "/" ]; do
  [ -d "$d/node_modules/.bin" ] && { bin="$d/node_modules/.bin"; break; }
  d="$(dirname "$d")"
done

if [ -z "$bin" ] || [ ! -x "$bin/prettier" ]; then
  missing "node hook: prettier not installed (npm install) — skipped $f"
fi

"$bin/prettier" --write --log-level warn "$f" >/dev/null 2>&1

[ "$lint" = 1 ] || exit 0
if [ ! -x "$bin/eslint" ]; then
  missing "node hook: eslint not installed (npm install) — lint skipped $f"
fi
out=$("$bin/eslint" --max-warnings=0 "$f" 2>&1) || { printf '%s\n' "$out" >&2; exit 1; }
