#!/usr/bin/env bash
# Compose the starter kit into a repo: core + chosen stacks + chosen add-ons.
#
#   ./install.sh <target-dir> --stack python [--stack node] [--addon web-api] ...
#   ./install.sh <target-dir> --stack flutter --dry-run
#
# Existing files in the target are never overwritten unless --force is given;
# skipped files are listed so you can merge them by hand.

set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"

usage() {
  echo "usage: $0 <target-dir> --stack <$(ls "$KIT/stacks" | tr '\n' '|' | sed 's/|$//')> ..." \
       "[--addon <$(ls "$KIT/addons" | tr '\n' '|' | sed 's/|$//')>] ... [--force] [--dry-run]" >&2
  exit 1
}

[ $# -ge 1 ] || usage
TARGET="$1"; shift
STACKS=(); ADDONS=(); FORCE=0; DRY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --stack) [ $# -ge 2 ] || usage; STACKS+=("$2"); shift 2 ;;
    --addon) [ $# -ge 2 ] || usage; ADDONS+=("$2"); shift 2 ;;
    --force) FORCE=1; shift ;;
    --dry-run) DRY=1; shift ;;
    *) usage ;;
  esac
done
[ ${#STACKS[@]} -ge 1 ] || { echo "at least one --stack is required" >&2; usage; }
for s in "${STACKS[@]}"; do [ -d "$KIT/stacks/$s" ] || { echo "unknown stack: $s" >&2; usage; }; done
for a in ${ADDONS[@]+"${ADDONS[@]}"}; do [ -d "$KIT/addons/$a" ] || { echo "unknown add-on: $a" >&2; usage; }; done
[ -d "$TARGET" ] || { echo "target does not exist: $TARGET" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

# 1. Files: core, then each stack, then each add-on (and its per-stack files).
cp -R "$KIT/core/files/." "$STAGE/"
for s in "${STACKS[@]}"; do cp -R "$KIT/stacks/$s/files/." "$STAGE/"; done
for a in ${ADDONS[@]+"${ADDONS[@]}"}; do
  [ -d "$KIT/addons/$a/files" ] && cp -R "$KIT/addons/$a/files/." "$STAGE/"
  for s in "${STACKS[@]}"; do
    [ -d "$KIT/addons/$a/$s/files" ] && cp -R "$KIT/addons/$a/$s/files/." "$STAGE/"
  done
done
# The stacks/ and dep-check.d/ placeholders only exist so core has the folders.
rm -f "$STAGE/.agents/hooks/stacks/.gitkeep" "$STAGE/scripts/dep-check.d/.gitkeep"

# 2. AGENTS.md: core with stack + add-on sections inserted at the marker.
SECTIONS="$STAGE/.sections.md"
: > "$SECTIONS"
for s in "${STACKS[@]}"; do
  [ -f "$KIT/stacks/$s/AGENTS.section.md" ] && { cat "$KIT/stacks/$s/AGENTS.section.md"; echo; } >> "$SECTIONS"
done
for a in ${ADDONS[@]+"${ADDONS[@]}"}; do
  [ -f "$KIT/addons/$a/AGENTS.section.md" ] && { cat "$KIT/addons/$a/AGENTS.section.md"; echo; } >> "$SECTIONS"
done
awk -v f="$SECTIONS" '
  /<!-- kit:sections -->/ { while ((getline l < f) > 0) print l; next }
  { print }
' "$KIT/core/AGENTS.md" > "$STAGE/AGENTS.md"
rm -f "$SECTIONS"

# 3. Claude permissions: core settings + each stack's allow-list.
PERMS=("$KIT/core/files/.claude/settings.json")
for s in "${STACKS[@]}"; do
  [ -f "$KIT/stacks/$s/claude-permissions.json" ] && PERMS+=("$KIT/stacks/$s/claude-permissions.json")
done
jq -s '.[0] as $base | reduce .[1:][] as $p ($base; .permissions.allow += $p)
       | .permissions.allow |= unique' "${PERMS[@]}" > "$STAGE/.claude/settings.json"

# 4. Copy into the target, never clobbering without --force.
added=0; skipped=0
while IFS= read -r -d '' src; do
  rel="${src#"$STAGE"/}"
  dst="$TARGET/$rel"
  if [ -e "$dst" ] && [ "$FORCE" = 0 ]; then
    echo "skip (exists): $rel"; skipped=$((skipped + 1)); continue
  fi
  if [ "$DRY" = 1 ]; then echo "would add:     $rel"; else
    mkdir -p "$(dirname "$dst")"; cp -p "$src" "$dst"; echo "add:           $rel"
  fi
  added=$((added + 1))
done < <(find "$STAGE" -type f -print0 | sort -z)

if [ "$DRY" = 0 ]; then
  chmod +x "$TARGET"/.agents/hooks/*.sh "$TARGET"/.agents/hooks/stacks/*.sh \
           "$TARGET"/.claude/hooks/*.sh "$TARGET"/scripts/dep-check.sh \
           "$TARGET"/scripts/dep-check.d/*.sh 2>/dev/null || true
fi

cat <<EOF

$([ "$DRY" = 1 ] && echo "Dry run: " )$added file(s) $([ "$DRY" = 1 ] && echo "would be added" || echo added), $skipped skipped.
Stacks: ${STACKS[*]}   Add-ons: ${ADDONS[*]:-none}

Next:
  1. Fill the markers:     grep -rn "FILL" AGENTS.md SOUL.md tests test 2>/dev/null
  2. Merge any skipped files by hand (listed above).
  3. Install hooks:        pre-commit install --hook-type pre-commit --hook-type pre-push
  4. Stack setup:          see the "Stack:" sections in AGENTS.md
EOF
