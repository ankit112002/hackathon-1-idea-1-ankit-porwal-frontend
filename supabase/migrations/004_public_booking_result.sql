-- Public booking result, richer availability, and a contact phone the owner can edit.
-- Does not replace create_booking. The wrapper calls it and returns the secret link.

alter table settings add column if not exists contact_phone text not null default '';

update settings set contact_phone = '+34685721593'
where id = 1 and contact_phone = '';

create or replace function is_owner()
returns boolean
language sql
stable
security invoker
set search_path = public
as $$
  select exists (
    select 1 from profiles where id = auth.uid() and role = 'owner'
  );
$$;

drop policy if exists "owner updates profiles" on profiles;
create policy "owner updates profiles" on profiles
  for update
  using (is_owner())
  with check (is_owner());

drop function if exists get_availability(date);

create function get_availability(p_date date)
returns table (
  shift_id uuid,
  shift_name text,
  start_time time,
  end_time time,
  last_booking_time time,
  max_covers int,
  min_group int,
  max_group int,
  taken int,
  remaining int,
  is_closed boolean
)
language sql
stable
security definer
set search_path = public
as $$
  select s.id, s.name, s.start_time, s.end_time, s.last_booking_time, s.max_covers,
    s.min_group, s.max_group,
    coalesce(sum(b.party_size), 0)::int,
    greatest(s.max_covers - coalesce(sum(b.party_size), 0), 0)::int,
    exists (select 1 from closed_days c where c.day = p_date)
  from service_shifts s
  left join bookings b on b.shift_id = s.id and b.booking_date = p_date
    and b.status in ('pending', 'confirmed', 'seated')
  where s.active and s.weekday = extract(dow from p_date)::int
  group by s.id;
$$;

revoke all on function get_availability(date) from public;
grant execute on function get_availability(date) to anon, authenticated;

create or replace function create_public_booking(
  p_name text,
  p_phone text,
  p_email text,
  p_lang text,
  p_shift uuid,
  p_date date,
  p_time time,
  p_adults int,
  p_children int,
  p_notes text,
  p_channel booking_channel
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
  v_id uuid;
  v_recent int;
begin
  p_name := trim(coalesce(p_name, ''));
  p_phone := trim(coalesce(p_phone, ''));
  p_email := trim(coalesce(p_email, ''));
  if p_name = '' or length(regexp_replace(p_phone, '\D', '', 'g')) < 9
     or position('@' in p_email) = 0 then
    raise exception 'NOT_ALLOWED';
  end if;
  if p_adults < 0 or p_children < 0 or p_adults + p_children < 1 then
    raise exception 'GROUP_SIZE_NOT_ALLOWED';
  end if;
  if p_date < (now() at time zone 'Europe/Madrid')::date then
    raise exception 'DAY_CLOSED';
  end if;

  if p_channel = 'web' then
    select count(*) into v_recent
    from bookings b
    join customers c on c.id = b.customer_id
    where c.phone = p_phone
      and b.created_at > now() - interval '1 hour';
    if v_recent >= 5 then
      raise exception 'TOO_MANY_BOOKINGS';
    end if;
  end if;

  v_id := create_booking(
    p_name, p_phone, p_email, p_lang, p_shift, p_date, p_time,
    p_adults, p_children, p_notes, p_channel
  );

  return query
  select b.id, b.manage_token, b.deposit_amount, b.payment
  from bookings b
  where b.id = v_id;
end $$;

revoke all on function create_public_booking(text, text, text, text, uuid, date, time, int, int, text, booking_channel) from public;
grant execute on function create_public_booking(text, text, text, text, uuid, date, time, int, int, text, booking_channel) to anon, authenticated;

drop function if exists get_booking_by_token(uuid);

create function get_booking_by_token(p_token uuid)
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
  where b.manage_token = p_token;
$$;

revoke all on function get_booking_by_token(uuid) from public;
grant execute on function get_booking_by_token(uuid) to anon, authenticated;

create or replace function mark_no_show(p_booking uuid) returns void
language plpgsql
security definer
set search_path = public
as $$
declare v_c uuid;
begin
  if not is_staff() then raise exception 'NOT_ALLOWED'; end if;
  update bookings set status = 'no_show' where id = p_booking
    returning customer_id into v_c;
  if v_c is null then return; end if;
  update customers set no_show_count = no_show_count + 1,
    blacklisted = (no_show_count + 1 >= 2) where id = v_c;
end $$;

revoke all on function mark_no_show(uuid) from public, anon;
grant execute on function mark_no_show(uuid) to authenticated;

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'bookings'
  ) then
    alter publication supabase_realtime add table bookings;
  end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'booking_tables'
  ) then
    alter publication supabase_realtime add table booking_tables;
  end if;
end $$;

alter table bookings replica identity full;
