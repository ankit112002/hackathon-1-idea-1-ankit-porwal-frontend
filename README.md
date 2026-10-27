Iturrieta Book

Table bookings for Sidrería Iturrieta in Aramaio. Customers reserve a table on the web. Staff run the service in real time. Owners and managers change shifts, the floor, events, and house rules.

Flutter web, Riverpod, go_router, and Supabase.

What it does





Public home page with upcoming events, opening days, and a link to book.



A booking flow that checks shift capacity, group size, and the last booking time.



Groups of 8 or more pay a EUR 10 deposit per person through Stripe. Smaller groups confirm at once. An unpaid deposit is cancelled after 15 minutes.



A secret manage link so a guest can view, reschedule, or cancel a booking.



A waitlist when a shift is full. Cancelling a booking offers the seat to the oldest waitlist row.



Staff sign-in with three roles: owner, manager, and waiter.



A live waiter screen for today's service, table assignment, and allergy notes.



Owner tools for the floor plan, calendar, events, dashboard, and settings.



Reminder rows for tomorrow's bookings. Email sends when RESEND_API_KEY is set.

The house is open Thursday to Sunday. Times are Europe/Madrid. The app ships in English.

Routes







Path



Who





/



Anyone. Home.





/book



Anyone. New booking.





/book/confirm?token=



Anyone with the confirmation token.





/manage/:token



Anyone with the manage token.





/admin/login



Staff sign-in.





/admin



Owner and manager. Dashboard.





/admin/waiter



Waiter, owner, and manager. Today's service.





/admin/floor



Owner and manager.





/admin/calendar



Owner and manager.





/admin/events



Owner and manager.





/admin/settings



Owner and manager.

A signed-out visit to /admin goes to /admin/login. A waiter who opens any other admin path is sent to /admin/waiter.

Stack





Flutter (web, with Android, iOS, macOS, and Linux shells in the repo)



flutter_riverpod for state



go_router for navigation and the staff guard



supabase_flutter for auth, data, and realtime



Stripe Checkout for deposits (Edge Function secrets, not in the app)



table_calendar, google_fonts, intl



Project layout

lib/
  features/     screens (home, booking, manage, admin)
  repositories/ Supabase reads and writes
  models/       plain Dart models
  providers/    Riverpod providers
  core/         theme, router, widgets, time and money helpers
  l10n/         generated localizations
supabase/
  migrations/   SQL applied after the base schema



Run locally

You need the Flutter SDK that matches pubspec.yaml (sdk: ^3.12.2).

Copy env.example.json to env.json and fill in the Supabase URL and the publishable (anon) key. Do not commit env.json.

{
  "SUPABASE_URL": "",
  "SUPABASE_ANON_KEY": "",
  "PUBLIC_WEB_URL": ""
}

PUBLIC_WEB_URL is the public origin used in manage and confirmation links.

flutter pub get
flutter run -d chrome --dart-define-from-file=env.json

Without env.json the app still starts, and staff routes stay on the login screen.

Database

These migrations are already applied on the iturrieta_book Supabase project. On a new database, apply the base schema first (it is not in this repo), then the files in supabase/migrations/ in order:





001_availability_and_grants.sql



002_harden_and_token_rpcs.sql



003_audit_expiry_stats.sql



004_public_booking_result.sql



005_reschedule_waitlist_reminders.sql



006_schedule_jobs.sql (pg_cron: expire unpaid deposits every minute, queue reminders at 08:00)



007_fix_role_recursion.sql

create_public_booking is the anonymous booking entry point. It returns the booking id, manage token, deposit amount, and payment state. Capacity is checked inside create_booking with a lock.

Staff sign-in

An owner profile is already in Supabase Auth. Sign in with that email and password.

To add a waiter: Authentication → Add user, then insert a profiles row with role = 'waiter' for that user id. Managers use role = 'manager'.

Stripe test mode

Set these secrets on the Supabase project (Edge Functions → Secrets). They never go in the Flutter app.





STRIPE_SECRET_KEY — test secret key



STRIPE_WEBHOOK_SECRET — signing secret for the stripe_webhook function

Point the Stripe webhook at https://<project-ref>.supabase.co/functions/v1/stripe_webhook. Use the test card 4242 4242 4242 4242, any future date, and any CVC.

Until those secrets exist, a deposit booking stays pending and the screen tells the guest to call.

Reminders

queue_reminders writes a message_log row for tomorrow's bookings. The send_reminders function sends them when RESEND_API_KEY is set. Until then the log row is the reminder.

Demo data

Thursday 29 October 2026 through Sunday 1 November 2026 already have bookings, including allergy notes. The floor has tables T1–T6 and benches B1–B2. One published concert is on the home page. The public phone is +34 685 72 15 93.

On a Monday the service screen is empty. Use Show the next open service.

Build and deploy

flutter build web --dart-define-from-file=env.json

netlify.toml publishes build/web and sends every path to index.html, so /book and /manage keep working on refresh. The same redirect rule is in vercel.json.

Live site: http://bucolic-macaron-0b66fc.netlify.app
The drop password is `My-Drop-Site`. Claim the site in the Netlify dashboard within 60 minutes of the deploy or the anonymous address is removed. `netlify.toml` sends every path to `index.html` so `/book` and `/manage` keep working.
# hackathon-1-idea-1-ankit-porwal-frontend
