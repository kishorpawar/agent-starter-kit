/**
 * Template: prove an endpoint refuses another user's resource.
 *
 * Copy next to the endpoint's tests as `<name>.test.ts` and adapt. (This file is
 * named `.template.ts` so the test runner does not collect it.)
 *
 * The defect it guards against keeps recurring: a handler resolves one identity
 * from the session and a second from something the caller supplied, then acts on
 * the second without comparing them. A written rule competes with every other rule
 * for attention; a failing test does not.
 *
 * Required when a caller-supplied value (path param, body field, token, email,
 * account number, order id) selects a row, a provider record, or an account.
 *
 * Must assert:
 *   1. the status code the contract promises, not just "an error";
 *   2. nothing belonging to the other account is in the body;
 *   3. where the endpoint mutates: the write / provider call / token spend did NOT
 *      happen. Refusing after the side effect fired is the same bug.
 */
import { describe, expect, it } from "vitest";
import request from "supertest";

// FILL: your app factory and fakes.
declare const buildApp: (deps: unknown) => unknown;
declare const fakeDb: { seed(table: string, rows: object[]): void; writes: unknown[] };
declare const providerCalls: unknown[];
declare const sessionFor: (userId: string) => string;

const CALLER_USER_ID = "11111111-1111-1111-1111-111111111111";
const OTHER_USER_ID = "99999999-9999-9999-9999-999999999999";
const OTHER_EMAIL = "other-user@example.com";

describe.skip("template — copy and adapt", () => {
  it("refuses another user's resource", async () => {
    // The lookup is keyed by what the caller supplied, so it realistically
    // returns the OTHER user's record.
    fakeDb.seed("accounts", [{ id: OTHER_USER_ID, email: OTHER_EMAIL }]);

    const res = await request(buildApp({ db: fakeDb }) as never)
      .get(`/accounts/${OTHER_USER_ID}`)
      .set("Authorization", `Bearer ${sessionFor(CALLER_USER_ID)}`);

    expect(res.status).toBe(403);
    expect(res.text).not.toContain(OTHER_EMAIL);
    expect(res.text).not.toContain(OTHER_USER_ID);
    expect(fakeDb.writes).toEqual([]);
    expect(providerCalls).toEqual([]);
  });
});
