# Iturrieta Book

Table bookings for Sidrería Iturrieta in Aramaio. Customers reserve on the web. Staff run the service in real time. Owners change shifts, the floor, and the rules from a phone.

Flutter web, Riverpod, go_router, Supabase.

## Run

Copy `env.example.json` to `env.json` and fill in the Supabase URL and the publishable (anon) key. Do not commit `env.json`.

```bash
flutter run -d chrome --dart-define-from-file=env.json
```

## Migrations

These are already applied on the `iturrieta_book` Supabase project. On a new database, run `supabase/schema.sql` first (it is not in this repo; it was applied before this app), then the files in `supabase/migrations/` in order:

1. `001_availability_and_grants.sql`
2. `002_harden_and_token_rpcs.sql`
3. `003_audit_expiry_stats.sql`
4. `004_public_booking_result.sql`
5. `005_reschedule_waitlist_reminders.sql`
6. `006_schedule_jobs.sql` (`pg_cron`: expire unpaid deposits every minute, queue reminders at 08:00)
7. `007_fix_role_recursion.sql`

## Staff sign-in

An owner profile is already in Supabase Auth. Sign in with that email and password.

To add a waiter: Authentication → Add user, then insert a `profiles` row with `role = 'waiter'` for that user id. Waiters only open `/admin/waiter`. Owners and managers open the dashboard, floor, calendar, events, and settings.

## Stripe test mode

Set these secrets on the Supabase project (Edge Functions → Secrets). They never go in the Flutter app.

- `STRIPE_SECRET_KEY` — test secret key
- `STRIPE_WEBHOOK_SECRET` — signing secret for `stripe_webhook`

The webhook URL is `https://lwcktydbthxnjzpvkmni.supabase.co/functions/v1/stripe_webhook`. Use the test card `4242 4242 4242 4242`, any future date, any CVC.

Groups of 8 or more are asked for a EUR 10 deposit per person. Smaller groups confirm at once. An unpaid deposit is cancelled after 15 minutes.

## Reminders

`queue_reminders` writes a `message_log` row for tomorrow's bookings. The `send_reminders` function sends them when `RESEND_API_KEY` is set. Until then the log row is the reminder.

## Demo data

Thursday 29 October 2026 through Sunday 1 November 2026 already have bookings, including allergy notes. The floor has tables T1–T6 and benches B1–B2. One published concert is on the home page. The public phone is `+34 685 72 15 93`.

On a Monday the service screen is empty. Use **Show the next open service**.

## Build the site

```bash
flutter build web --dart-define-from-file=env.json
```

The site is on Netlify: http://bucolic-macaron-0b66fc.netlify.app

The drop password is `My-Drop-Site`. Claim the site in the Netlify dashboard within 60 minutes of the deploy or the anonymous address is removed. `netlify.toml` sends every path to `index.html` so `/book` and `/manage` keep working.
# hackathon-1-idea-1-ankit-porwal-frontend
