# <!-- FILL: Product name --> Soul

The principles and invariants behind this codebase. AGENTS.md says *how* to work;
this file says *what must stay true* and *how to choose* when rules don't decide.
Keep it under ~150 lines and change it only by a deliberate, reviewed decision.

## What This System Is

<!-- FILL: who uses it, what they trust it with, what failure costs them. -->

## Core Principles

<!-- Rewrite in this product's terms. These five generalise well. -->

### 1. Correctness Over Convenience
A response means the system can stand behind that state later. Never report success
the system hasn't verified.

### 2. Accuracy Over Assumption
Model real states from real data and real payloads, not from constants or one sample.
Third-party systems will misbehave; plan for it.

### 3. The End User Comes First
Clear states, honest errors, no confusing partial outcomes.

### 4. Trust Is Hard to Earn and Easy to Lose
Data isolation, explicit auth boundaries, and protected personal data are not
trade-offs.

### 5. Reliability Beats Cleverness
Prefer the boring, auditable implementation an operator can debug at 2 a.m.

## Non-Negotiable Invariants

These stay true unless a deliberate, reviewed decision changes them.

- User data isolation is mandatory.
- Authentication and authorization boundaries are explicit, never implied.
- Sensitive data is protected at rest and in transit, and never logged.
- Records support audit and debugging without exposing personal data.
- Webhooks and async jobs are safe under retries and repeated delivery.
- External failures never silently corrupt internal truth.
<!-- FILL: domain invariants, e.g. "money state changes only from provider-confirmed events". -->

## Decision Lens

When choosing between implementations, prefer the one that best answers:

1. Is it correct in edge cases, retries, and partial failures?
2. Does it preserve security, privacy, and isolation?
3. Does it protect the end user's trust and clarity?
4. Will an engineer or operator understand it later?
5. <!-- FILL: domain question, e.g. "Is it compliant with the regulated workflow?" -->

If any answer is unclear, the design is not ready.

## What We Avoid

- shortcuts that bypass proper state tracking
- convenience changes that weaken auth, isolation, or auditability
- optimistic assumptions about third parties
- hidden side effects in critical flows
- logging sensitive data for debugging convenience
- trading correctness for speed

## What Good Looks Like

- matches the real-world workflow, not just the API contract
- makes state transitions clearer, not more implicit
- tests the important edge and failure paths
- leaves an audit trail operators can follow

## Final Standard

Would we be comfortable explaining this change to the user it affects, and to an
auditor, a year from now?
