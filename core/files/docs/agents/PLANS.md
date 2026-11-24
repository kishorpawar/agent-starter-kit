# Task Plan Template

Copy to `tasks/todo/<branch-name>.md`. Keep it short; tick items as you go.

## Goal
What is true when this is done? Quote the request's exact words for any field,
gating rule, or precedence the user specified.

## Current behaviour
What the code does today, with file:line references. The change is described
against this.

## Context
- Files to touch
- Existing helpers/constants/envelopes to reuse (grepped, not assumed)
- Constraints and non-goals

## Plan
- [ ] Step 1
- [ ] Step 2

## Interface contract (if an API, schema, or public interface changes)
| Field / param | Source | What proves it is the caller's |
|---------------|--------|--------------------------------|

## Validation
- Test files to run; which new tests must fail without the fix
- Security review needed? (auth, permissions, payments, caller-supplied ids)

## Deploy & rollback
- Migrations and their order relative to the code deploy
- How to revert safely

## Open questions

## Review (fill in when done)
- What changed, what was verified, what is left for the backlog
