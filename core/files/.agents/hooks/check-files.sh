#!/usr/bin/env bash
# Format + lint the given files. The one entry point every agent hook and the
# pre-commit hook call, so all agents and humans get identical checks.
#
#   .agents/hooks/check-files.sh path/a.py path/b.ts ...
#
# Each installed stack drops a script into .agents/hooks/stacks/<stack>.sh.
# A stack script is called once per file, ignores extensions it doesn't own
# (exit 0), formats in place, and exits non-zero with the lint output on stderr.
#
# Exit 2 on any failure: Claude Code feeds exit-2 stderr back to the agent;
# pre-commit and other callers treat any non-zero as failure.

set -u

dir="$(cd "$(dirname "$0")" && pwd)"
status=0

for f in "$@"; do
  [ -f "$f" ] || continue
  for stack in "$dir"/stacks/*.sh; do
    [ -x "$stack" ] || continue
    "$stack" "$f" || status=2
  done
done

exit "$status"
