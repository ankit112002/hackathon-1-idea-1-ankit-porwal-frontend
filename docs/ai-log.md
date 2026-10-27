# AI log

- 2026-10-26 — Section 1: added `supabase/migrations/001_availability_and_grants.sql`, `002_harden_and_token_rpcs.sql`, and `003_audit_expiry_stats.sql`. Not applied from the app; waiting for the SQL editor.
- 2026-10-26 — Phase 0: Flutter web shell (theme, en/es/eu, router guard, shared widgets). `flutter analyze` is clean. Home and the locale switch were checked in the browser; `service_shifts` still needs `env.json`.
- 2026-10-26 — Phase 1–4: booking flow on `create_public_booking`, staff screens, floor plan, Stripe functions, waitlist, events, dashboard, and the role-function recursion fix. Error codes and party rules covered by tests.
- 2026-10-26 — Phase 4: database cases (wrong weekday, closed day, late time, group size, blocked customer, full shift) return the expected codes. A web booking for Thursday 29 Oct 14:30 is confirmed. Release build is on http://bucolic-macaron-0b66fc.netlify.app.
