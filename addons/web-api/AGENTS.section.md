### Add-on: Web API

- **Name what proves each field.** For every field in a new or changed response, say
  where the value came from and what proves it belongs to the caller. A hardcoded
  default is a claim you must justify too. Fill the interface-contract table in the
  task plan.
- **One response, one row.** If a response mixes facts about "the account", all must
  come from the one record the session belongs to. If you resolve two identities (one
  from caller input, one from the session), compare them and refuse on mismatch. This
  holds after authentication too — being logged in is not owning the record you named.
- **Every endpoint that takes a caller-supplied identifier has an ownership test**,
  copied from the ownership template in the tests folder. It asserts the status code,
  that nothing of the other account leaks, and that no side effect fired.
- **Changing who can reach an endpoint re-audits it**, even if the handler body is
  untouched — the blast radius changed.
- Keep auth middleware/dependencies on every route that needs CSRF or session checks;
  role helpers answer *who*, they don't replace the session check.
- List/search endpoints filter, order, and paginate in the database, and return stable
  navigation identifiers (`id`/`slug`) alongside display fields. Multi-select filters
  get a companion filter-metadata endpoint.
- One shared response envelope and error shape for every route. Errors use product
  terms, never internal field names.
- Webhooks: verify the sender (signature or allow-list), store the raw event first,
  then apply side effects idempotently.
