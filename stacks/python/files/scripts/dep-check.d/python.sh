#!/usr/bin/env bash
# Python dependency audit with pip-audit.
# Add `--ignore-vuln <ID>` only with a comment: why it's unreachable here, and what
# would make you re-evaluate it.

set -euo pipefail

REQUIREMENTS="${PY_REQUIREMENTS:-requirements.txt}"

if [ ! -f "$REQUIREMENTS" ]; then
  echo "python audit: $REQUIREMENTS not found (set PY_REQUIREMENTS=path)" >&2
  exit 1
fi

if ! command -v pip-audit >/dev/null 2>&1; then
  echo "python audit: pip-audit not installed (pip install pip-audit)" >&2
  exit 1
fi

pip-audit --requirement "$REQUIREMENTS"
