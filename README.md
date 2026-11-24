# Agent Starter Kit

Drop-in setup for a new repo worked on by coding agents (Claude Code, Codex, Cursor,
Gemini CLI, Copilot). Distilled from what held up on a production FastAPI + Postgres
fintech backend: the practices worth copying, and guard rails against the mistakes it
made.

It is built from parts, so it stays agent- and stack-agnostic:

```
core/            every repo: AGENTS.md, SOUL.md, agent pointer files, the shared
                 check script + hook wiring, pre-commit, tasks/, docs/agents/
stacks/python/   black + flake8, pip-audit, pytest isolation (conftest.py)
stacks/node/     prettier + eslint (typescript-eslint), npm/pnpm/yarn audit,
                 vitest/jest isolation (setup-env.ts)
stacks/flutter/  dart format + dart analyze, osv-scanner, flutter test isolation
                 (flutter_test_config.dart)
addons/web-api/  response-contract + ownership rules, ownership test (py / ts)
addons/postgres/ RLS-first, migration and canonical-definition rules
```

## Install

```bash
# Python API on Postgres
~/workspace/agent-starter-kit/install.sh /path/to/repo --stack python --addon web-api --addon postgres

# Next.js / Node frontend or API
~/workspace/agent-starter-kit/install.sh /path/to/repo --stack node

# Flutter app
~/workspace/agent-starter-kit/install.sh /path/to/repo --stack flutter

# Monorepo: stacks combine
~/workspace/agent-starter-kit/install.sh /path/to/repo --stack python --stack node --addon web-api
```

`--dry-run` lists what would be added. Existing files are never overwritten without
`--force`; skipped ones are listed for a manual merge.

The installer:
- copies core, each stack's files, and each add-on's files (plus its per-stack files,
  e.g. the Python or TypeScript ownership test),
- builds **one AGENTS.md**: core rules, then each stack's and add-on's section,
- merges each stack's allowed commands into `.claude/settings.json`.

## How it stays agnostic

**One instruction file.** AGENTS.md is read natively by Codex, Cursor and others.
`CLAUDE.md` and `GEMINI.md` import it (`@AGENTS.md`); `.github/copilot-instructions.md`
points to it. Rules are added to AGENTS.md only.

**One check script.** `.agents/hooks/check-files.sh <files>` runs every installed
`.agents/hooks/stacks/<stack>.sh`; each formats and lints the extensions it owns and
ignores the rest. Everything calls this one script:

| Caller | Wiring | When |
|--------|--------|------|
| Claude Code | `.claude/settings.json` → `.claude/hooks/on-edit.sh` | after every Edit/Write; exit 2 makes the agent fix it |
| Any agent with an end-of-turn hook | point it at `.agents/hooks/check-changed.sh` | checks every changed file |
| Agents without hooks, and humans | pre-commit `agent-check` | every commit |

Adding a stack means adding one script; no YAML or JSON merging.

**One audit script.** `scripts/dep-check.sh` runs every `scripts/dep-check.d/*.sh` on
pre-push.

## Adding another stack

Create `stacks/<name>/` with:
- `files/.agents/hooks/stacks/<name>.sh`: takes one file path; exit 0 for extensions
  it doesn't own; format in place; exit non-zero with lint output on stderr. If the
  toolchain isn't installed: warn and exit 0, **unless `AGENT_CHECK_STRICT=1`** (set by
  pre-commit), then exit 1, so a commit never passes just because nothing ran. Copy
  the `missing()` helper from an existing stack script.
- `files/scripts/dep-check.d/<name>.sh`: vulnerability audit, non-zero on findings.
- `files/...`: lint config and a test-isolation file that blocks real network/service
  access *by default*.
- `AGENTS.section.md`: a `### Stack: <name>` section with commands and rules.
- `claude-permissions.json`: a JSON array of allowed Bash commands.

## The habits that make it work

The files are scaffolding. The value comes from four habits:

1. **One instruction file.** Add rules only to AGENTS.md.
2. **Corrections become rules.** Every user correction → dated entry in
   `tasks/lessons.md` → recurring themes get folded into AGENTS.md "Hard-Won Rules".
3. **Feature docs are read before touching.** Each non-obvious feature gets a doc from
   the template, plus a row in AGENTS.md saying when to read it.
4. **Done means proven.** Tests fail without the fix, checks pass on every edit, a
   security review on sensitive diffs, every response field traced to its source.

## Mistakes this kit is built to prevent

- **Production credentials reaching tests.** Each stack's isolation file makes this
  impossible by default instead of something an agent has to remember. The Claude
  settings also deny reading `.env`.
- **A broken full test suite.** Once the baseline is red, "run only touched files"
  becomes permanent and regressions hide. Keep the suite green from the first commit.
- **Lint with no config.** Whole-tree lint becomes noise nobody reads. Every stack
  ships its lint config.
- **Instruction files drifting.** One source, pointers elsewhere.
- **Skills documented but not present.** If AGENTS.md lists a skill, check the folder
  has it. See `core/files/docs/agents/TOOLING.md` for what's worth installing.
