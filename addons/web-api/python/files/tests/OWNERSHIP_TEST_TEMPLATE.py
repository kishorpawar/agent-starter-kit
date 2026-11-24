"""Template: prove an endpoint refuses another user's resource.

Copy this next to the endpoint's own tests and adapt it. The defect it guards
against keeps recurring: a handler resolves one identity from the session and a
second from something the caller supplied, then acts on the second without
comparing them. A written rule competes with every other rule for attention; a
failing test does not.

**When you need one.** Any handler where a caller-supplied value (path param,
body field, token, email, account number, order id) selects a row, a provider
record, or an account. If what the caller named can differ from what their
session owns, this test is required.

**What it must assert.**
1. The status code the contract promises, not just "an error".
2. The response carries nothing belonging to the other account.
3. Where the endpoint mutates: the write / provider call / token spend did NOT
   happen. Refusing the response after the side effect fired is the same bug.
"""

import pytest

CALLER_USER_ID = "11111111-1111-1111-1111-111111111111"
OTHER_USER_ID = "99999999-9999-9999-9999-999999999999"
OTHER_EMAIL = "other-user@example.com"


@pytest.mark.skip(reason="template — copy and adapt, do not run in place")
def test_another_users_resource_is_refused(fake_db, provider_calls):
    """Caller is authenticated as themselves and names someone else's record."""
    # The lookup is keyed by what the caller supplied, so it realistically
    # returns the OTHER user's record.
    fake_db.records["accounts"] = [{"id": OTHER_USER_ID, "email": OTHER_EMAIL}]

    response = call_the_endpoint(  # noqa: F821 — replace with your client call
        as_user=CALLER_USER_ID, resource_id=OTHER_USER_ID
    )

    # 1. Refused with the promised status.
    assert response.status_code == 403

    # 2. Nothing of theirs leaked into the body.
    body = response.text
    assert OTHER_EMAIL not in body
    assert OTHER_USER_ID not in body

    # 3. No side effect fired.
    assert fake_db.writes == []
    assert provider_calls == []
