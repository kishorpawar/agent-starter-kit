### Add-on: PostgreSQL

- **Row-level security first.** Default to the request-scoped connection and
  `SECURITY INVOKER` functions. If RLS blocks a legitimate operation, the fix is a
  policy that makes it safe under the caller's identity — not a bypass. Service-role
  connections and `SECURITY DEFINER` are last resort and go in the privileged-access
  register.
- **Migrations:** `db/migrations/NNN_description.sql`, sequential, idempotent
  (`IF NOT EXISTS`), with RLS enabled and policies in the same file as the table.
  <!-- FILL: how migrations are applied (tool or manual) and in what order vs deploy. -->
- **Amend a view/function in its canonical definition file** so the diff shows exactly
  what changed. A new migration carries only the delta plus a comment naming the file to
  re-apply. Never restate a large SQL object in a new file.
- Correctness that depends on joins, RLS, or aggregation stays in Postgres (view/RPC),
  never reassembled from separate client-side reads.
- Write policies scoped to the operation (`FOR SELECT`, `FOR UPDATE`); a `FOR ALL`
  policy silently widens writes.
- Verify SQL only on a local throwaway database. Never against a shared or production
  instance.
- Naming: tables plural snake_case, FKs end `_id`, booleans `is_`/`has_`, views
  `vw_`/`mv_`, functions verb_noun.
