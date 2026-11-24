"""Test isolation: no test may reach a real service.

This runs before any app module is imported. It points every live-service
environment variable at an unroutable address, so a forgotten mock fails fast
with a connection error instead of reading or writing real data.

Why *set* rather than *unset*: `python-dotenv`'s `load_dotenv()` does not
override variables that are already set, but it happily fills in ones that are
missing. Unsetting a variable lets the app's own `load_dotenv()` refill it
from `.env` — which is exactly how a test reaches production.

Add every URL / key / DSN for a live service to LIVE_SERVICE_ENV.
"""

import os

UNROUTABLE = "http://127.0.0.1:9"

# FILL: every env var that points at a real database, API, queue, or provider.
LIVE_SERVICE_ENV = {
    "DATABASE_URL": "postgresql://test:test@127.0.0.1:9/test",
    "REDIS_URL": "redis://127.0.0.1:9/0",
    # "SUPABASE_URL": UNROUTABLE,
    # "SUPABASE_SERVICE_KEY": "test-dummy-key",
    # "PAYMENT_API_BASE_URL": UNROUTABLE,
}

for name, value in LIVE_SERVICE_ENV.items():
    os.environ[name] = value
