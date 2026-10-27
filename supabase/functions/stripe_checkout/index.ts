import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';
import Stripe from 'https://esm.sh/stripe@17.7.0?target=denonext';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });

  const secret = Deno.env.get('STRIPE_SECRET_KEY');
  if (!secret) {
    return Response.json({ error: 'STRIPE_NOT_CONFIGURED' }, { status: 503, headers: cors });
  }

  const body = await req.json();
  const token = body.manage_token as string | undefined;
  const successUrl = body.success_url as string | undefined;
  const cancelUrl = body.cancel_url as string | undefined;
  if (!token || !successUrl || !cancelUrl) {
    return Response.json({ error: 'NOT_ALLOWED' }, { status: 400, headers: cors });
  }

  const admin = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
  );
  const { data, error } = await admin
    .from('bookings')
    .select('id, deposit_amount, payment')
    .eq('manage_token', token)
    .maybeSingle();
  if (error || !data) {
    return Response.json({ error: 'NOT_FOUND' }, { status: 404, headers: cors });
  }
  if (data.payment !== 'pending' || Number(data.deposit_amount) <= 0) {
    return Response.json({ error: 'NO_DEPOSIT' }, { status: 400, headers: cors });
  }

  const stripe = new Stripe(secret, { apiVersion: '2024-11-20.acacia' });
  const session = await stripe.checkout.sessions.create({
    mode: 'payment',
    success_url: successUrl,
    cancel_url: cancelUrl,
    line_items: [
      {
        quantity: 1,
        price_data: {
          currency: 'eur',
          unit_amount: Math.round(Number(data.deposit_amount) * 100),
          product_data: { name: 'Iturrieta deposit' },
        },
      },
    ],
    metadata: { booking_id: data.id },
  });

  await admin.from('bookings').update({ stripe_session_id: session.id }).eq('id', data.id);
  return Response.json({ url: session.url }, { headers: cors });
});
