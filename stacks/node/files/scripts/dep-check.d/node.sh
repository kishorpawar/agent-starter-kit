#!/usr/bin/env bash
# Node dependency audit, using whichever package manager owns the lockfile.
# Fails on high/critical advisories. To accept one, use the package manager's
# override/resolution mechanism WITH a comment: why it's unreachable here, and what
# would make you re-evaluate it.

set -euo pipefail

if [ -f pnpm-lock.yaml ]; then
  pnpm audit --audit-level high
elif [ -f yarn.lock ]; then
  yarn npm audit --severity high
elif [ -f package-lock.json ]; then
  npm audit --audit-level=high
else
  echo "node audit: no lockfile found — commit one" >&2
  exit 1
fi
