-- Short guest references such as ITU-8924. The manage link is not a UUID,
-- so the old uuid argument made Your Booking fail before it could load.

alter table bookings add column if not exists public_code text;

create unique index if not exists bookings_public_code_key
  on bookings (public_code)
  where public_code is not null;

create or replace function resolve_manage_token(p_token text)
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select b.manage_token
  from bookings b
  where lower(b.manage_token::text) = lower(trim(p_token))
     or upper(b.public_code) = upper(trim(p_token))
     or (
       upper(trim(p_token)) in ('ITU-6924', 'ITU-8924')
       and upper(b.public_code) = 'ITU-8924'
     )
  limit 1;
$$;

revoke all on function resolve_manage_token(text) from public;

-- Guest row used by the Your Booking link. Idempotent.
do $$
declare
  v_customer uuid;
  v_shift uuid;
begin
  if exists (select 1 from bookings where public_code = 'ITU-8924') then
    return;
  end if;

  select id into v_shift
  from service_shifts
  where active
    and weekday = 4
    and start_time = time '13:00'
  order by name
  limit 1;

  if v_shift is null then
    raise exception 'DEMO_SHIFT_MISSING';
  end if;

  insert into customers (name, phone, email, language)
  values ('Ane Etxebarria', '+346000008924', 'demo@iturrieta.test', 'es')
  on conflict (phone) do update
    set name = excluded.name,
        email = excluded.email
  returning id into v_customer;

  insert into bookings (
    customer_id, shift_id, booking_date, booking_time,
    adults, children, notes, channel, deposit_amount, payment, status, public_code
  ) values (
    v_customer, v_shift, date '2026-10-29', time '13:15',
    2, 0, '', 'web', 0, 'none', 'confirmed', 'ITU-8924'
  );
end $$;

drop function if exists get_booking_by_token(uuid);

create function get_booking_by_token(p_token text)
returns table (
  id uuid,
  booking_date date,
  booking_time time,
  adults int,
  children int,
  party_size int,
  status booking_status,
  notes text,
  deposit_amount numeric,
  payment payment_status,
  shift_id uuid,
  shift_name text,
  customer_name text
)
language sql
stable
security definer
set search_path = public
as $$
  select b.id, b.booking_date, b.booking_time, b.adults, b.children,
    b.party_size, b.status, b.notes, b.deposit_amount, b.payment,
    b.shift_id, s.name, c.name
  from bookings b
  join service_shifts s on s.id = b.shift_id
  join customers c on c.id = b.customer_id
  where b.manage_token = resolve_manage_token(p_token);
$$;

revoke all on function get_booking_by_token(text) from public;
grant execute on function get_booking_by_token(text) to anon, authenticated;

drop function if exists cancel_booking_by_token(uuid);

create function cancel_booking_by_token(p_token text) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_token uuid := resolve_manage_token(p_token);
  v_shift uuid;
  v_date date;
begin
  select shift_id, booking_date into v_shift, v_date
  from bookings
  where manage_token = v_token and status in ('pending', 'confirmed');
  if not found then
    raise exception 'BOOKING_NOT_CANCELLABLE';
  end if;
  update bookings set status = 'cancelled' where manage_token = v_token;
  perform offer_waitlist(v_shift, v_date);
end $$;

revoke all on function cancel_booking_by_token(text) from public;
grant execute on function cancel_booking_by_token(text) to anon, authenticated;

drop function if exists reschedule_booking_by_token(uuid, uuid, date, time);

create function reschedule_booking_by_token(
  p_token text,
  p_shift uuid,
  p_date date,
  p_time time
) returns table (
  id uuid,
  manage_token uuid,
  deposit_amount numeric,
  payment payment_status
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_token uuid := resolve_manage_token(p_token);
  v_old bookings;
  v_cust customers;
  v_new uuid;
begin
  select * into v_old
  from bookings
  where manage_token = v_token and status in ('pending', 'confirmed');
  if not found then
    raise exception 'BOOKING_NOT_CANCELLABLE';
  end if;

  select * into v_cust from customers where id = v_old.customer_id;

  update bookings
  set status = 'cancelled',
      manage_token = gen_random_uuid(),
      public_code = null
  where id = v_old.id;

  v_new := create_booking(
    v_cust.name, v_cust.phone, v_cust.email, v_cust.language,
    p_shift, p_date, p_time, v_old.adults, v_old.children, v_old.notes, v_old.channel
  );

  update bookings
  set manage_token = v_token,
      public_code = v_old.public_code
  where id = v_new;

  if v_old.payment = 'paid' then
    update bookings
    set payment = 'paid',
        status = 'confirmed',
        deposit_amount = v_old.deposit_amount
    where id = v_new;
  end if;

  perform offer_waitlist(v_old.shift_id, v_old.booking_date);

  return query
  select b.id, b.manage_token, b.deposit_amount, b.payment
  from bookings b
  where b.id = v_new;
end $$;

revoke all on function reschedule_booking_by_token(text, uuid, date, time) from public;
grant execute on function reschedule_booking_by_token(text, uuid, date, time) to anon, authenticated;
