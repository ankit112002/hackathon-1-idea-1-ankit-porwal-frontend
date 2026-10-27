# Assumptions

- Staff roles are `owner`, `manager`, and `waiter`. A signed-out visit to `/admin/*` goes to `/admin/login`. A waiter may open only `/admin/waiter`. Owner and manager may open every `/admin` route.
- Code lives in feature folders under `lib/`. Models stay plain Dart. Freezed is not used.
- Light theme only: paper `#F6F1E7`, surface `#FFFDF8`, ink `#1E2420`, bottle green `#1F4D36`, cider `#C45C26`, hairline `#E4DCCB`. Fraunces for headings, Source Sans 3 for body. Radius 12. Spacing 4, 8, 12, 16, 24, 32, 48.
- The app locale defaults to Spanish (`es`). The switcher keeps the choice in memory.
- `intl` is pinned to `0.20.2` because `flutter_localizations` requires that version. `table_calendar` is `3.2.1` so it can share that pin. `Supabase.initialize` receives the anon key as `publishableKey` (the env name stays `SUPABASE_ANON_KEY`).
- Postgres `extract(dow)` is 0 for Sunday through 6 for Saturday. The house is open Thursday to Sunday.
- `settings` columns in the live database: `menu_price_adult` 45, `menu_price_child` 16, `deposit_per_person` 10, `deposit_min_group` 8, `max_group_online` 20, `cancel_free_hours` 48, `season_start`, `season_end`, and `contact_phone`. The phone was empty, so migration 004 set it to the public number on iturrieta.eus, `+34685721593`.
- `create_booking` stays as it is and returns only a booking id. `create_public_booking` calls it and returns `id`, `manage_token`, `deposit_amount`, and `payment`, because anonymous users cannot read `bookings`.
- The live function raises `SHIFT_NOT_FOUND`, `WRONG_WEEKDAY`, `DAY_CLOSED`, `AFTER_LAST_BOOKING_TIME`, `GROUP_SIZE_NOT_ALLOWED`, `GROUP_TOO_BIG_CALL_US`, `SHIFT_FULL`, and `CUSTOMER_BLOCKED`. The app also accepts the older names (`CLOSED_DAY`, `TOO_LATE`, `PARTY_TOO_SMALL`, `PARTY_TOO_LARGE`, `ONLINE_MAX_EXCEEDED`, `BLACKLISTED`). A blocked customer sees "We cannot confirm this date."
- Web bookings from the same phone are limited to 5 per hour inside `create_public_booking`.
- Times offered in the form are every 15 minutes from the shift start through `last_booking_time`.
- Europe/Madrid is calculated as UTC+1 or UTC+2 from the last Sunday in March and October. Dates in the database are that wall clock.
- `is_staff` and `is_admin` are `security definer`. Otherwise the profiles policy calls them and they read `profiles` again until Postgres runs out of stack.
- Reminder email needs `RESEND_API_KEY`. Without it, `message_log` still records the reminder.
- Stripe checkout needs `STRIPE_SECRET_KEY` and `STRIPE_WEBHOOK_SECRET` in the Edge Function secrets. Until those exist, a deposit booking stays pending and the screen says to call.
- The same product shape (shifts, covers, a fixed menu, a secret manage link) fits another cider house or group-dining room. This build is configured for Iturrieta only.
