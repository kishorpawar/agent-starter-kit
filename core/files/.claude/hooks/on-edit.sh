#!/usr/bin/env bash
# Claude Code PostToolUse adapter: pull the edited path out of the hook JSON and
# hand it to the shared checker.

set -u

if ! command -v jq >/dev/null 2>&1; then
  echo "on-edit hook: jq not installed — format/lint skipped" >&2
  exit 0
fi

f=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty')
[ -n "$f" ] || exit 0

exec "${CLAUDE_PROJECT_DIR:-.}/.agents/hooks/check-files.sh" "$f"
