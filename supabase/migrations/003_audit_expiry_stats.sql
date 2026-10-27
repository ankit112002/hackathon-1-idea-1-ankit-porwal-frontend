-- Audit log for config changes
create table if not exists audit_log (
  id uuid primary key default gen_random_uuid(),
  actor uuid default auth.uid(),
  table_name text, action text, row_data jsonb,
  created_at timestamptz default now()
);
alter table audit_log enable row level security;
create policy "owner read audit" on audit_log for select
  using (exists (select 1 from profiles where id = auth.uid() and role = 'owner'));

create or replace function log_change() returns trigger
language plpgsql security definer as $$
begin
  insert into audit_log (table_name, action, row_data)
  values (tg_table_name, tg_op, to_jsonb(coalesce(new, old)));
  return coalesce(new, old);
end $$;

create trigger audit_shifts after insert or update or delete on service_shifts
  for each row execute function log_change();
create trigger audit_settings after update on settings
  for each row execute function log_change();
create trigger audit_closed after insert or delete on closed_days
  for each row execute function log_change();
create trigger audit_tables after insert or update or delete on floor_tables
  for each row execute function log_change();

-- Cancel unpaid pending bookings after 15 minutes
create or replace function expire_pending_bookings() returns void
language sql security definer as $$
  update bookings set status = 'cancelled'
  where status = 'pending' and payment = 'pending'
    and created_at < now() - interval '15 minutes';
$$;
-- Enable the pg_cron extension in Supabase (Database > Extensions), then:
-- select cron.schedule('expire-pending', '* * * * *', 'select expire_pending_bookings()');

-- Dashboard numbers (staff only)
create or replace function dashboard_stats(p_date date)
returns json language plpgsql security definer stable as $$
begin
  if not is_staff() then raise exception 'NOT_ALLOWED'; end if;
  return json_build_object(
    'covers_today', (select coalesce(sum(party_size),0) from bookings
      where booking_date = p_date and status in ('pending','confirmed','seated','completed')),
    'bookings_today', (select count(*) from bookings
      where booking_date = p_date and status <> 'cancelled'),
    'covers_tomorrow', (select coalesce(sum(party_size),0) from bookings
      where booking_date = p_date + 1 and status in ('pending','confirmed')),
    'no_shows_30d', (select count(*) from bookings
      where status = 'no_show' and booking_date > p_date - 30),
    'deposits_paid', (select coalesce(sum(deposit_amount),0) from bookings
      where payment = 'paid' and booking_date >= p_date)
  );
end $$;
grant execute on function dashboard_stats(date) to authenticated;
