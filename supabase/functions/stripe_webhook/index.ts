import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';
import Stripe from 'https://esm.sh/stripe@17.7.0?target=denonext';

Deno.serve(async (req) => {
  const secret = Deno.env.get('STRIPE_SECRET_KEY');
  const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET');
  if (!secret || !webhookSecret) {
    return Response.json({ error: 'STRIPE_NOT_CONFIGURED' }, { status: 503 });
  }

  const signature = req.headers.get('stripe-signature');
  if (!signature) return Response.json({ error: 'NOT_ALLOWED' }, { status: 400 });

  const stripe = new Stripe(secret, { apiVersion: '2024-11-20.acacia' });
  const payload = await req.text();
  let event: Stripe.Event;
  try {
    event = await stripe.webhooks.constructEventAsync(payload, signature, webhookSecret);
  } catch {
    return Response.json({ error: 'NOT_ALLOWED' }, { status: 400 });
  }

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object as Stripe.Checkout.Session;
    const admin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    );
    await admin
      .from('bookings')
      .update({ payment: 'paid', status: 'confirmed' })
      .eq('stripe_session_id', session.id)
      .eq('payment', 'pending');
  }

  return Response.json({ received: true });
});
