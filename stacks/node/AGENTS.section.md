### Stack: Node / TypeScript

<!-- FILL: real commands and package manager. -->
```bash
npm run dev                                  # dev server
npx vitest run path/to/file.test.ts          # one test file (preferred)
npx tsc --noEmit                             # type check — required before done
.agents/hooks/check-files.sh path/to/file.ts # format + lint one file
```

- **Test isolation:** `test/setup-env.ts` sets every live-service env var to an
  unroutable address and must be registered as a setup file (see its header). Add
  every new service URL/key there in the same PR that introduces it.
- **Type check is part of done.** The edit hook formats and lints per file but cannot
  type-check; run `npx tsc --noEmit` before calling a task finished.
- No floating promises: `await` it, return it, or `void` it with a comment saying why
  fire-and-forget is safe. eslint enforces this.
- No `any`. Parse untrusted input (request bodies, env, provider responses) with a
  schema (zod/valibot) at the boundary; trust types only after parsing.
- Server-only secrets never reach client bundles: nothing secret in `NEXT_PUBLIC_*` /
  `VITE_*` variables or shared modules imported by the browser.
- Frontend: entity pages call id/slug-scoped endpoints — never fetch a whole dataset
  to filter on the client.
