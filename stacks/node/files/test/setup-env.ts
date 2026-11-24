/**
 * Test isolation: no test may reach a real service.
 *
 * Register as a setup file so it runs before any test file imports app code:
 *   vitest.config.ts → test: { setupFiles: ["./test/setup-env.ts"] }
 *   jest.config.ts   → setupFiles: ["<rootDir>/test/setup-env.ts"]
 *
 * It points every live-service env var at an unroutable address, so a forgotten
 * mock fails fast with a connection error instead of touching real data.
 *
 * Why *set* rather than delete: `dotenv` does not override variables that are
 * already set, but it fills in missing ones. Deleting a variable lets the app's
 * own `dotenv.config()` refill it from `.env` — which is how a test reaches
 * production.
 */

const UNROUTABLE = "http://127.0.0.1:9";

// FILL: every env var that points at a real database, API, queue, or provider.
const LIVE_SERVICE_ENV: Record<string, string> = {
  DATABASE_URL: "postgresql://test:test@127.0.0.1:9/test",
  REDIS_URL: "redis://127.0.0.1:9/0",
  // API_BASE_URL: UNROUTABLE,
  // PAYMENT_API_KEY: "test-dummy-key",
};

for (const [name, value] of Object.entries(LIVE_SERVICE_ENV)) {
  process.env[name] = value;
}

export { UNROUTABLE };
