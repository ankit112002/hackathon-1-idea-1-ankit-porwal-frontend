# Security review

Checked against the project checklist and the live database on 26 Oct 2026.

- Sign-in is Supabase Auth. Roles come from `profiles`, not from user-editable JWT metadata.
- Row level security is on. As the `anon` role, `bookings` and `customers` return no rows. `service_shifts`, `settings`, and published `events` are readable.
- Customers manage one booking with `manage_token`. The token is a random UUID. Lists are not available by phone or email.
- `create_booking` checks the shift, the weekday, closed days, the last booking time, group size, the online maximum, capacity (with an advisory lock), and the blocked flag. `create_public_booking` adds a phone rate limit and basic name, phone, and email checks.
- `mark_no_show` requires `is_staff()`.
- Stripe secrets stay in Edge Function secrets. The webhook checks the Stripe signature. `verify_jwt` is off only for the checkout and webhook functions, because the customer has no account and Stripe does not send a Supabase JWT. Checkout still requires the secret manage token.
- `is_staff`, `is_admin`, and `is_owner` are `security definer` with `search_path = public`, so the profiles policy cannot recurse.
- The Flutter app reads only `SUPABASE_URL` and `SUPABASE_ANON_KEY` from `--dart-define-from-file`. `env.json` is gitignored.

Still outside this build: a dedicated IP rate limit in front of the API, and a real refund when someone cancels inside the paid window. The screen states the 48-hour rule. The cancel function releases the seats either way.
