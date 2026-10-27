# Demo script (about 3 minutes)

1. **Problem (30 s).** Iturrieta still takes bookings by phone and WhatsApp and confirms them by hand. A full Saturday is easy to double-book, and a no-show is invisible until the table stays empty.

2. **Live story (75 s).** On a phone, book Thursday lunch for 12 adults. The form shows the menu total and the deposit. Pay with Stripe test card `4242 4242 4242 4242` if the Stripe secrets are set; otherwise show the pending hold and say the webhook marks it paid. Open the waiter screen: the booking appears, and the allergy note is highlighted. Assign a bench and mark the party seated. As the owner, drag a table, close a day (the warning lists who is already booked), and open the dashboard. In another tab, book the last seats until the shift is full and join the waitlist. Cancel a booking and the oldest waitlist row is marked offered.

3. **How (45 s).** Flutter web and Supabase. Capacity is checked inside `create_booking` with a lock, so two people cannot take the last seats together. Row level security hides customer rows from the public. The waiter screen listens to today's bookings. The same database function is what a later WhatsApp or phone agent would call.

4. **Next (30 s).** Turn on the WhatsApp and voice adapters against `create_public_booking`. Add a static page for search. Offer the same system to other cider houses.

If the network fails, use a screen recording of this path. Demo day is Thursday 29 Oct 2026, when the seeded lunch bookings are "today".
