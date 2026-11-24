@AGENTS.md

<!--
  All shared instructions live in AGENTS.md, imported above. Do not add project
  rules here; add them to AGENTS.md so every agent gets them.
  Only Claude Code-specific notes belong below.
-->

## Claude Code specifics

- A PostToolUse hook (`.claude/hooks/on-edit.sh`) formats and lints each file you
  Edit/Write through `.agents/hooks/check-files.sh`, and blocks on lint errors. Fix
  what it reports; don't work around it.
- Use `/security-review` for the security-review step in AGENTS.md → Verification.
- Project skills live in `.claude/skills/` and are committed. Keep the list in
  AGENTS.md in sync with what is actually in that folder.
