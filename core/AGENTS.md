# AGENTS.md

The single source of instructions for every coding agent working in this repo.
Codex, Cursor and other agents read this file natively; `CLAUDE.md`, `GEMINI.md` and
`.github/copilot-instructions.md` only point here. **Edit this file, never those** —
parallel instruction files drift apart within weeks, and the agent reading the stale
one loses the rules that matter most.

Keep this file an index plus rules. Feature detail lives in `docs/agents/` and is
listed under "Docs to read first" so it is loaded only when relevant.

---

## Project

<!-- FILL: 2–4 sentences. What the product is, who uses it, the main external systems. -->

Read [SOUL.md](SOUL.md) before any change that affects product behaviour, security,
data handling, or what an end user sees. It holds the principles and invariants; this
file holds the operating rules.

## Architecture

<!-- FILL: directory map, one line per layer/package, and what is allowed to call what. -->

---

## Working rules

### Workflow
- **Plan first** for anything with 3+ steps or an architectural choice: write the plan
  to `tasks/todo/<branch-name>.md` from [docs/agents/PLANS.md](docs/agents/PLANS.md)
  and check in before implementing. If it goes sideways, stop and re-plan.
- **One worktree per task**, outside the repo (e.g. `../worktrees/<branch>`). Never
  implement in the main checkout. Branch names: `yyyymmdd_snake_case`, off
  `<!-- FILL: integration branch -->`.
- **Never commit, push, or open a PR unless told to in that turn.** Finishing a fix is
  not permission to commit it.
- **Never run scripts, migrations, or data repairs unprompted** — including indirectly
  via sweeps that import/execute modules with side effects.
- Explain current behaviour first, then the change. Ground every proposal in what the
  code does today.

### Scope
- **Ship only what was asked.** No adjacent fields, extra options, "useful" metadata,
  speculative config, or abstractions for single-use code.
- **Surgical changes.** Every changed line traces to the request. Don't reformat,
  refactor, or "improve" neighbouring code; mention unrelated dead code, don't delete
  it. Do remove what *your* change orphaned.
- **Treat review comments as contract changes**: implement exactly that scope and
  update signature, wiring, tests, and docs together.
- **Name things the way the design labels them.**
- **Never author user-facing copy.** Reuse existing copy sources; if the spec doesn't
  literally provide the text, leave it empty and ask.
- If something is ambiguous, say what is unclear and ask. Don't pick an
  interpretation silently.

### Correctness & security
- **Resolve everything that can refuse before anything irreversible.** Authenticate,
  authorize, and validate before spending a one-time token, writing, charging, or
  calling a provider.
- **A guard reads its inputs through the same helper the guarded code uses.** If the
  write reads `a or b`, a check on `a` alone is a bypass.
- **Normalize an identifier once, at the entry point**, and derive every downstream
  form from that one value. Two consumers re-deriving from raw input will diverge.
- **Least privilege.** Default to the caller-scoped credential. Any elevated access
  (admin key, service account, access-control bypass) is justified in a code comment
  and listed in
  [docs/agents/PRIVILEGED_ACCESS_REGISTER.md](docs/agents/PRIVILEGED_ACCESS_REGISTER.md).
- **Check errors explicitly** on every DB/provider/network result before any
  empty-data fallback.
- Never log, cache, or email secrets or personal data.
- Confirm the authoritative source for each value and the live state vocabulary before
  modelling workflow state. Don't model from code constants or one sample payload.

### Verification — definition of done
- **Tests never touch a real service.** Each stack ships an isolation file (see the
  stack section below). Don't weaken it.
- Run the tests for the modules you touched; all must pass. Keep the full suite green —
  a red baseline hides regressions.
- **New tests must fail without the fix.** Run them against the pre-change code; a test
  that passes both ways pins nothing.
- Formatting and lint run automatically on every edit and commit
  (`.agents/hooks/check-files.sh`). Fix what they report; never bypass them.
- **Run a security review** on any diff touching auth, permissions, payments, or
  anything that takes a caller-supplied identifier. Self-review is what misses these.
- Never `git stash` to compare; use a worktree or the diff.
- Ask: "Would a senior engineer approve this, or call it overcomplicated?"

<!-- kit:sections -->

---

## Self-improvement loop

After **any** correction from the user:
1. Append a dated entry to [tasks/lessons.md](tasks/lessons.md) (format is in the file).
2. If it matches a theme, fold the rule into **Hard-Won Rules** below. That section is
   read every session; `lessons.md` is the archive — grep it, don't load it wholesale.

## Hard-Won Rules

<!-- Grows from tasks/lessons.md. One bullet per rule, imperative, with the date and a
     one-clause "why" so nobody deletes it as noise. Example:
- **Keep the auth dependency next to role checks** — role helpers answer *who*, they
  don't run CSRF (2026-11-23).
-->

---

## Task files

- Each branch's notes live in `tasks/todo/<branch-name>.md`: plan as checkboxes, then a
  review section when done. Disjoint paths per branch means no merge conflicts.
- `tasks/todo.md` is a pointer only. Cross-task follow-ups go in `tasks/backlog.md`.
- When a task is done and deployed, move its file to `tasks/archive/`.
- Never bulk-edit another task's file. `.gitattributes` marks these files
  `merge=union`; after a merge, read the result — union keeps both sides silently.

## Pull requests

When asked to prepare a PR, give a **title**, a **description** grouped into 2–4
reviewer-facing sections by change area (not a file inventory), and a **brief commit
message**. Use [.github/pull_request_template.md](.github/pull_request_template.md).
Mention verification gaps only when they materially affect review. List any migration
or manual step that must happen before/after deploy.

## Docs to read first

| Read | Before touching |
|------|-----------------|
| [SOUL.md](SOUL.md) | anything user-facing, security, or data handling |
| [docs/agents/PLANS.md](docs/agents/PLANS.md) | any multi-step task |
| [docs/agents/CODE_REVIEW.md](docs/agents/CODE_REVIEW.md) | reviewing a diff |
| [docs/agents/TOOLING.md](docs/agents/TOOLING.md) | installing a skill, plugin, or hook; list installed ones here |
| [docs/agents/PRIVILEGED_ACCESS_REGISTER.md](docs/agents/PRIVILEGED_ACCESS_REGISTER.md) | any elevated access |
<!-- FILL: one row per feature doc, written from docs/agents/FEATURE_DOC_TEMPLATE.md -->
