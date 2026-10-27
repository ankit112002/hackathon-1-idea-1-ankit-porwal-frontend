-- Change a booking by its secret link, offer a waitlist seat after a cancel,
-- and record reminder rows for the next Madrid day.

create or replace function offer_waitlist(p_shift uuid, p_date date) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_remaining int;
  v_id uuid;
begin
  select remaining into v_remaining
  from get_availability(p_date)
  where shift_id = p_shift;

  if v_remaining is null or v_remaining <= 0 then
    return;
  end if;

  select id into v_id
  from waitlist
  where shift_id = p_shift
    and booking_date = p_date
    and notified = false
    and party_size <= v_remaining
  order by created_at
  limit 1;

  if v_id is null then
    return;
  end if;

  update waitlist set notified = true where id = v_id;
end $$;

revoke all on function offer_waitlist(uuid, date) from public;
grant execute on function offer_waitlist(uuid, date) to authenticated;

create or replace function cancel_booking_by_token(p_token uuid) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_shift uuid;
  v_date date;
begin
  select shift_id, booking_date into v_shift, v_date
  from bookings
  where manage_token = p_token and status in ('pending', 'confirmed');
  if not found then
    raise exception 'BOOKING_NOT_CANCELLABLE';
  end if;
  update bookings set status = 'cancelled' where manage_token = p_token;
  perform offer_waitlist(v_shift, v_date);
end $$;

revoke all on function cancel_booking_by_token(uuid) from public;
grant execute on function cancel_booking_by_token(uuid) to anon, authenticated;

create or replace function reschedule_booking_by_token(
  p_token uuid,
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
  v_old bookings;
  v_cust customers;
  v_new uuid;
begin
  select * into v_old
  from bookings
  where manage_token = p_token and status in ('pending', 'confirmed');
  if not found then
    raise exception 'BOOKING_NOT_CANCELLABLE';
  end if;

  select * into v_cust from customers where id = v_old.customer_id;

  -- Release the secret link before the new row reuses it.
  update bookings
  set status = 'cancelled', manage_token = gen_random_uuid()
  where id = v_old.id;

  v_new := create_booking(
    v_cust.name, v_cust.phone, v_cust.email, v_cust.language,
    p_shift, p_date, p_time, v_old.adults, v_old.children, v_old.notes, v_old.channel
  );

  update bookings
  set manage_token = p_token
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

revoke all on function reschedule_booking_by_token(uuid, uuid, date, time) from public;
grant execute on function reschedule_booking_by_token(uuid, uuid, date, time) to anon, authenticated;

create or replace function queue_reminders() returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into message_log (booking_id, channel, kind)
  select b.id, 'email', 'reminder'
  from bookings b
  where b.booking_date = ((now() at time zone 'Europe/Madrid')::date + 1)
    and b.status in ('confirmed', 'pending')
    and not exists (
      select 1 from message_log m
      where m.booking_id = b.id and m.kind = 'reminder'
    );
end $$;

revoke all on function queue_reminders() from public, anon;
grant execute on function queue_reminders() to authenticated;
