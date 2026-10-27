import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';

/// Records tomorrow's reminders. Sends email when RESEND_API_KEY is set.
Deno.serve(async () => {
  const admin = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
  );

  const { error } = await admin.rpc('queue_reminders');
  if (error) return Response.json({ error: error.message }, { status: 500 });

  const resend = Deno.env.get('RESEND_API_KEY');
  if (!resend) {
    return Response.json({
      queued: true,
      emailed: false,
      note: 'Set RESEND_API_KEY to send the reminder emails.',
    });
  }

  const { data: rows } = await admin
    .from('message_log')
    .select('id, booking_id, bookings(booking_date, customers(email, name))')
    .eq('kind', 'reminder')
    .eq('channel', 'email')
    .order('sent_at', { ascending: false })
    .limit(50);

  let emailed = 0;
  for (const row of rows ?? []) {
    const booking = row.bookings as { customers?: { email?: string; name?: string } } | null;
    const email = booking?.customers?.email;
    const name = booking?.customers?.name ?? '';
    if (!email) continue;
    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${resend}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'Iturrieta <bookings@iturrieta.eus>',
        to: email,
        subject: 'Iturrieta — your table tomorrow',
        text: `Kaixo ${name}. Your table at Sidrería Iturrieta is tomorrow. Sagarretik txotxera.`,
      }),
    });
    if (response.ok) emailed += 1;
  }

  return Response.json({ queued: true, emailed });
});
