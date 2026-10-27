-- Schedules. Safe to skip if pg_cron is not enabled on this project.
create extension if not exists pg_cron with schema extensions;

do $$
begin
  if exists (select 1 from cron.job where jobname = 'expire-pending') then
    perform cron.unschedule('expire-pending');
  end if;
  perform cron.schedule(
    'expire-pending',
    '* * * * *',
    'select public.expire_pending_bookings()'
  );

  if exists (select 1 from cron.job where jobname = 'queue-reminders') then
    perform cron.unschedule('queue-reminders');
  end if;
  perform cron.schedule(
    'queue-reminders',
    '0 8 * * *',
    'select public.queue_reminders()'
  );
end $$;
