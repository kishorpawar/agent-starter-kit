#!/usr/bin/env bash
# Python: format with black, lint with flake8 (config: .flake8).
# Tools come from $AGENT_VENV/bin if set, else PATH.
# Prefer ruff? Replace both lines with `ruff format "$f"` and `ruff check "$f"`.

# Missing toolchain: warn and pass during agent edits; fail when AGENT_CHECK_STRICT=1
# (set by pre-commit), so a commit can never pass just because nothing ran.
missing() { echo "$1" >&2; [ "${AGENT_CHECK_STRICT:-0}" = 1 ] && exit 1; exit 0; }

f="$1"
case "$f" in *.py | *.pyi) ;; *) exit 0 ;; esac

tool() { if [ -n "${AGENT_VENV:-}" ]; then echo "$AGENT_VENV/bin/$1"; else echo "$1"; fi; }
black=$(tool black)
flake8=$(tool flake8)

if ! command -v "$black" >/dev/null 2>&1 || ! command -v "$flake8" >/dev/null 2>&1; then
  missing "python hook: black/flake8 not found (set AGENT_VENV) — skipped $f"
fi

"$black" -q "$f" >/dev/null 2>&1
out=$("$flake8" "$f" 2>&1) || { printf '%s\n' "$out" >&2; exit 1; }
