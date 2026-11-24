# <Feature name>

Write one of these for any feature with non-obvious rules, then add a row to
AGENTS.md → "Docs to read first" saying *before touching what* to read it.

## What it does and why
Two paragraphs: the user problem and the shape of the solution.

## Where it lives
| Piece | Location |
|-------|----------|
| Entry points (routes, screens, commands) | |
| Logic | |
| Storage (tables, local DB, cache) | |
| Jobs / webhooks / background work | |

## Rules and invariants
The non-obvious ones, each with the reason. "X must happen before Y because ..."

## Interface contract
Request/response or input/output samples, error codes, and what each field is
sourced from.

## External system behaviour
What the provider actually does (verified against real payloads), especially where it
differs from its docs.

## Operations
Config/env vars, flags, migrations and their apply order, how to debug.

## Known gaps
Link to `tasks/backlog.md` entries.
