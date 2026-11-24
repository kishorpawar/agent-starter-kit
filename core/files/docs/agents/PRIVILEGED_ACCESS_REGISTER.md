# Privileged Access Register

Every place the code uses more access than the caller has — an admin API key, a
service account, a database role that bypasses access control, a superuser query —
is listed here. If it isn't listed, it shouldn't exist.

## Rule

1. **Default:** the caller-scoped credential (the user's token, row-level security,
   queries scoped by the session's identity).
2. If that blocks a legitimate operation, **widen the scoped permission** so the
   operation is expressible under the caller's identity.
3. **Elevate only** when the scoped path genuinely can't express it (e.g. append-only
   audit writes, a pre-auth flow with no identity yet) — and then:
   - put a `privileged: <reason>` comment at the call site,
   - add a row below,
   - name, for each caller-supplied identifier, the check that proves the caller owns
     it. On an elevated path a missing check is a data leak, not an empty result.

## Register

| Location | Operation | Why the scoped path can't do it | Ownership check | Added |
|----------|-----------|---------------------------------|-----------------|-------|
| <!-- path:function --> | | | | |
