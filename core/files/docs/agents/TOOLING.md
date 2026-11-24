# Agent Tooling: Skills, Plugins, Hooks

The general-purpose tooling that has earned its place. None of it is tied to one domain.
Install what fits the project; list what you install in AGENTS.md so every agent
knows it exists.

**Scope rule:** project tooling is committed to the repo (`.claude/skills/`,
`.claude/settings.json`) so teammates get it on pull. Personal preferences go in
`~/.claude/` or `.claude/settings.local.json` (gitignored).

---

## Hooks

Hooks are enforced by the harness, not remembered by the agent. Anything you would
otherwise write as "always do X after Y" belongs here.

All format/lint hooks call one script, `.agents/hooks/check-files.sh`, which runs
each installed stack's checker. Different agents only differ in how they call it.

| Hook | Agent | Event | What it does | In kit |
|------|-------|-------|--------------|--------|
| `.claude/hooks/on-edit.sh` | Claude Code | PostToolUse on Edit/Write | Formats and lints the edited file; exit 2 makes the agent fix it | ✅ |
| `.agents/hooks/check-changed.sh` | any agent with an end-of-turn/stop hook | end of turn | Checks every changed file in the working tree | ✅ script; wire per agent |
| pre-commit `agent-check` | all (git) | commit | Same checks for agents without hooks, and for humans | ✅ |
| pre-commit `dep-audit` | all (git) | push | Runs each stack's vulnerability audit; every ignore needs a written justification | ✅ |
| `graphify hook-check` | Codex | PreToolUse on Bash | Keeps a codebase knowledge graph current (see graphify below) | optional |

Ideas worth adding when they come up:
- **Block dangerous commands** (PreToolUse on Bash): refuse `git push --force`,
  `git stash`, or scripts that load production env.
- **Deny reading secrets**: `permissions.deny` on `.env*` (already in the kit's
  `settings.json`).

Gotcha: a format-on-edit hook reformats the whole file, so editing a not-yet-formatted
legacy file produces a noisy diff. Either format the repo once up front, or make
the hook format only new files.

---

## Skills

### Built into Claude Code (no install)

| Skill | Use |
|-------|-----|
| `/security-review` | Security review of the branch diff. Required step for auth/permission/caller-supplied-id changes |
| `/code-review` | Correctness review of a diff or PR, at a chosen effort level; `--fix` applies findings |
| `/simplify` | Reuse/simplification pass on changed code (quality only, not bugs) |
| `/ship` | Commit, push, open PR, review, then watch CI and comments until merged (user-typed only) |
| `/steward` | Watch an existing PR's CI/conflicts/comments (user-typed only) |
| `/init` | Generate a first CLAUDE.md — then fold it into AGENTS.md |
| `/fewer-permission-prompts` | Build a read-only allowlist for `settings.json` from past sessions |
| `/loop`, `/schedule` | Recurring local polls / scheduled cloud agents |

### Worth committing to the repo (`.claude/skills/`)

| Skill | Source | Use |
|-------|--------|-----|
| `write-safe-migrations` | [docfork/db-skills](https://github.com/docfork/db-skills) | Any schema change, backfill, index, constraint |
| `query-database-schema` | docfork/db-skills | Explore tables/relationships before joins or migrations |
| `debug-slow-queries` | docfork/db-skills | Slow endpoint, timeouts, plan flipped to seq scan |
| `data-quality-audit` | docfork/db-skills | Data drift, validating a backfill, reconciling counts |

Copy the `SKILL.md` files (don't `npm install db-skills` — its CLI only copies markdown
and its global install shipped no skill files), then append a "<Project> specifics"
block with your conventions (migration naming, access-control rules, sensitive
columns). To update: re-copy upstream and re-apply that block.

### Personal (`~/.claude/skills/` or `.agents/skills/`)

| Skill | Use |
|-------|-----|
| `skill-inspector` | Vet a third-party skill before installing it (over-permissioned, malicious, unsafe scripts). Run it on every skill you didn't write |
| `caveman` / `cavecrew` / `caveman-commit` | Compressed output when token cost matters; terse Conventional-Commit messages. A preference, not a team default |

---

## Plugins

| Plugin | Use | Notes |
|--------|-----|-------|
| **Postman** | API contracts, collections, tests, mocks, monitors, webhook capture/replay, CI lint | Start at `postman:api-engineer`. Keep collections in `docs/agents/postman/` or `postman/` and in sync when endpoints change |
| **Sentry** | Debug an issue from its stack trace, create alerts, set up releases + suspect commits | Needs the Sentry connector authorized |
| **impeccable** | Frontend design, critique, polish, accessibility, DESIGN.md | Frontend repos only |
| **ui-ux-pro-max** | UI/UX reference data: palettes, type pairings, UX guidelines, design tokens | Frontend repos only |
| **taste-skill** | Art direction for marketing/landing pages; anti-template checks | Frontend repos only |

### Per stack

| Stack | Tool | Use |
|-------|------|-----|
| Flutter | **Dart & Flutter MCP server** (`dart mcp-server`, ships with the Dart SDK) | Lets the agent run analysis, tests, hot reload, inspect the widget tree and search pub.dev. Add it as an MCP server in each agent's config |
| Node / web frontend | the frontend design plugins above | UI work only |
| Python | none beyond the core set | |

### Optional

| Tool | Use | Cost |
|------|-----|------|
| **graphify** | Codebase knowledge graph: `graphify query "<question>"`, `graphify path A B`, `graphify explain X` return a scoped subgraph instead of grep dumps; `graphify update .` after edits (AST-only, no API cost) | Generated `graphify-out/` files churn in git; needs an AGENTS.md section telling agents to query it first |

---

## Connectors (claude.ai MCP)

Authorize per person, not per repo. Useful general ones: **Sentry** (errors),
**Linear/Jira/Asana** (tickets), **Slack** (incident context), **Notion/Google
Docs** (specs), **Figma** (designs). Agents can't run the OAuth flow
themselves; authorize them in claude.ai connector settings.
