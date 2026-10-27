-- is_staff and is_admin read profiles, and the profiles policy calls them back.
-- Security definer stops that loop. The search path stays on public.

create or replace function is_staff()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from profiles where id = auth.uid());
$$;

create or replace function is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from profiles
    where id = auth.uid() and role in ('owner', 'manager')
  );
$$;

create or replace function is_owner()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from profiles where id = auth.uid() and role = 'owner'
  );
$$;
