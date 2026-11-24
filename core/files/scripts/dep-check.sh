#!/usr/bin/env bash
# Pre-push dependency audit. Runs every installed stack's audit in
# scripts/dep-check.d/ and fails if any of them finds a known vulnerability.
#
# To accept a vulnerability, add the ignore in that stack's script WITH a comment
# saying why it is unreachable here and what would make you re-evaluate it. An
# ignore without a justification is a silent hole.

set -u
cd "$(git rev-parse --show-toplevel)" || exit 1

status=0
ran=0
for audit in scripts/dep-check.d/*.sh; do
  [ -x "$audit" ] || continue
  ran=1
  echo "== $(basename "$audit" .sh)"
  "$audit" || status=1
done

[ "$ran" = 1 ] || echo "dep-check: no stack audits installed"
exit "$status"
