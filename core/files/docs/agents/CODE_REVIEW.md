# Code Review Guidelines

Focus on correctness, security, and regressions. Report P0/P1 first. Stack and add-on
sections in AGENTS.md add their own checks to this list.

## P0/P1 checks
- **Ordering:** nothing irreversible (token spend, write, charge, provider call) happens
  before a check that can still refuse.
- **Guards:** a check reads its inputs the same way the guarded code does
  (including `or`-aliases and permissive models).
- **Elevated access:** justified in a comment and listed in
  `PRIVILEGED_ACCESS_REGISTER.md`; widening who can reach a code path re-audits it.
- **Errors:** every DB/provider/network result is checked before an empty fallback.
- **Async:** un-awaited promises/futures, blocking calls on async paths.
- **Retries:** webhooks/jobs are idempotent under repeated delivery.
- **Sensitive data:** nothing secret or personal in logs, caches, emails, or error
  bodies.
- **Scope:** no fields, params, options, or copy beyond what was requested.

## Test expectations
- New behaviour and edge/failure paths are tested.
- New tests were shown to fail without the fix.
- No test can reach a real service.

## Fix policy
- Low-risk, local issues (unused import): fix directly.
- Anything that changes behaviour or needs a refactor: report and wait for approval.
