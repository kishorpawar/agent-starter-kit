# Migrations

`NNN_description.sql`, applied in order. Each file:

- is idempotent (`IF NOT EXISTS`, `CREATE OR REPLACE`),
- enables RLS and adds its policies alongside any new table,
- changes an existing view/function by editing its canonical file and saying here
  (in a comment at the top) which file must be re-applied,
- says at the top whether it must run **before** or **after** the code deploy.

<!-- FILL: how migrations are applied in each environment. -->
