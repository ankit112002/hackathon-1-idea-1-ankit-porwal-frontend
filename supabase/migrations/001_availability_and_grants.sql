-- Remaining seats per shift for a date
create or replace function get_availability(p_date date)
returns table (
  shift_id uuid, shift_name text, start_time time, last_booking_time time,
  max_covers int, taken int, remaining int, is_closed boolean
)
language sql security definer stable as $$
  select s.id, s.name, s.start_time, s.last_booking_time, s.max_covers,
    coalesce(sum(b.party_size), 0)::int,
    greatest(s.max_covers - coalesce(sum(b.party_size), 0), 0)::int,
    exists (select 1 from closed_days c where c.day = p_date)
  from service_shifts s
  left join bookings b on b.shift_id = s.id and b.booking_date = p_date
    and b.status in ('pending', 'confirmed', 'seated')
  where s.active and s.weekday = extract(dow from p_date)::int
  group by s.id;
$$;

grant execute on function get_availability(date) to anon, authenticated;
grant execute on function create_booking(text,text,text,text,uuid,date,time,int,int,text,booking_channel)
  to anon, authenticated;
