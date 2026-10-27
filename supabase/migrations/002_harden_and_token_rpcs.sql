-- Lock down mark_no_show: staff only
revoke execute on function mark_no_show(uuid) from public, anon;
grant execute on function mark_no_show(uuid) to authenticated;

create or replace function mark_no_show(p_booking uuid) returns void
language plpgsql security definer as $$
declare v_c uuid;
begin
  if not is_staff() then raise exception 'NOT_ALLOWED'; end if;
  update bookings set status = 'no_show' where id = p_booking
    returning customer_id into v_c;
  update customers set no_show_count = no_show_count + 1,
    blacklisted = (no_show_count + 1 >= 2) where id = v_c;
end $$;

-- Customer views own booking by secret token
create or replace function get_booking_by_token(p_token uuid)
returns table (
  id uuid, booking_date date, booking_time time, adults int, children int,
  party_size int, status booking_status, notes text, deposit_amount numeric,
  payment payment_status, shift_name text, customer_name text
)
language sql security definer stable as $$
  select b.id, b.booking_date, b.booking_time, b.adults, b.children,
    b.party_size, b.status, b.notes, b.deposit_amount, b.payment,
    s.name, c.name
  from bookings b
  join service_shifts s on s.id = b.shift_id
  join customers c on c.id = b.customer_id
  where b.manage_token = p_token;
$$;
grant execute on function get_booking_by_token(uuid) to anon, authenticated;

-- Customer cancels by token
create or replace function cancel_booking_by_token(p_token uuid) returns void
language plpgsql security definer as $$
begin
  update bookings set status = 'cancelled'
  where manage_token = p_token and status in ('pending', 'confirmed');
  if not found then raise exception 'BOOKING_NOT_CANCELLABLE'; end if;
end $$;
grant execute on function cancel_booking_by_token(uuid) to anon, authenticated;

-- Customer joins waitlist when a shift is full
create or replace function join_waitlist(
  p_name text, p_phone text, p_email text, p_lang text,
  p_shift uuid, p_date date, p_party int
) returns uuid
language plpgsql security definer as $$
declare v_c uuid; v_id uuid;
begin
  insert into customers (name, phone, email, language)
  values (p_name, p_phone, p_email, coalesce(p_lang, 'es'))
  on conflict (phone) do update set name = excluded.name
  returning id into v_c;
  insert into waitlist (customer_id, shift_id, booking_date, party_size)
  values (v_c, p_shift, p_date, p_party) returning id into v_id;
  return v_id;
end $$;
grant execute on function join_waitlist(text,text,text,text,uuid,date,int) to anon, authenticated;
