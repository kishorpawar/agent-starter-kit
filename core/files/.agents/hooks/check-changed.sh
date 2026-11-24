#!/usr/bin/env bash
# Run check-files.sh on every file changed in the working tree (tracked edits +
# new untracked files). For agents whose hooks can't name the edited file —
# wire it to an end-of-turn / stop hook — or run it by hand before committing.

set -u
cd "$(git rev-parse --show-toplevel)" || exit 1

# A brand-new repo has no HEAD yet: then everything staged or untracked counts.
if git rev-parse --verify -q HEAD >/dev/null; then base=HEAD; else base="--cached"; fi

files=$( { git diff --name-only --diff-filter=ACMR "$base"; \
           git ls-files --others --exclude-standard; } | sort -u )

[ -n "$files" ] || exit 0
# shellcheck disable=SC2086
exec "$(dirname "$0")/check-files.sh" $files
