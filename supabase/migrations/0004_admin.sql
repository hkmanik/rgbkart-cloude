-- Admin team: run once in Supabase → SQL Editor, AFTER setup.sql and profiles.sql.
-- Safe to run again.
--
-- Roles
--   master_admin  Everything, plus inviting/removing staff. Set only from this SQL (step 6).
--   co_admin      Approve or reject sellers, view all customers and sellers.
--   editor        View customers and sellers (read-only for now; will edit products/content later).

-- 1. Tables --------------------------------------------------------------

create table if not exists public.staff (
  user_id     uuid primary key references auth.users (id) on delete cascade,
  email       text not null,
  staff_role  text not null check (staff_role in ('master_admin', 'co_admin', 'editor')),
  added_by    uuid references auth.users (id) on delete set null,
  created_at  timestamptz not null default now()
);

create table if not exists public.staff_invites (
  email       text primary key,
  staff_role  text not null check (staff_role in ('co_admin', 'editor')),
  invited_by  uuid references auth.users (id) on delete set null,
  created_at  timestamptz not null default now()
);

-- 2. Helpers -------------------------------------------------------------

create or replace function public.my_staff_role()
returns text language sql stable security definer set search_path = ''
as $$ select staff_role from public.staff where user_id = auth.uid() $$;

create or replace function public.has_staff_role(roles text[])
returns boolean language sql stable security definer set search_path = ''
as $$ select exists (select 1 from public.staff where user_id = auth.uid() and staff_role = any (roles)) $$;

revoke execute on function public.my_staff_role()             from public, anon;
revoke execute on function public.has_staff_role(text[])      from public, anon;
grant  execute on function public.my_staff_role()             to authenticated;
grant  execute on function public.has_staff_role(text[])      to authenticated;

-- 3. Security ------------------------------------------------------------

alter table public.staff         enable row level security;
alter table public.staff_invites enable row level security;
revoke insert, update, delete on public.staff, public.staff_invites from anon, authenticated;

drop policy if exists "See own staff row or all if master" on public.staff;
create policy "See own staff row or all if master" on public.staff for select to authenticated
  using (user_id = auth.uid() or public.has_staff_role(array['master_admin']));

drop policy if exists "Master sees invites" on public.staff_invites;
create policy "Master sees invites" on public.staff_invites for select to authenticated
  using (public.has_staff_role(array['master_admin']));

-- Staff can read customer and seller data
drop policy if exists "Staff read profiles" on public.profiles;
create policy "Staff read profiles" on public.profiles for select to authenticated
  using (public.has_staff_role(array['master_admin', 'co_admin', 'editor']));

drop policy if exists "Staff read customer details" on public.customer_details;
create policy "Staff read customer details" on public.customer_details for select to authenticated
  using (public.has_staff_role(array['master_admin', 'co_admin', 'editor']));

drop policy if exists "Staff read seller details" on public.seller_details;
create policy "Staff read seller details" on public.seller_details for select to authenticated
  using (public.has_staff_role(array['master_admin', 'co_admin', 'editor']));

-- 4. Staff management (Master Admin only) --------------------------------

create or replace function public.invite_staff(p_email text, p_role text)
returns void language plpgsql security definer set search_path = ''
as $$
declare e text := lower(trim(p_email));
begin
  if not public.has_staff_role(array['master_admin']) then raise exception 'Only the Master Admin can invite staff'; end if;
  if p_role not in ('co_admin', 'editor') then raise exception 'Choose Co-admin or Editor'; end if;
  if e !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then raise exception 'Enter a valid email address'; end if;
  if exists (select 1 from public.staff where lower(email) = e) then raise exception 'That person is already on the team'; end if;
  insert into public.staff_invites (email, staff_role, invited_by) values (e, p_role, auth.uid())
  on conflict (email) do update set staff_role = excluded.staff_role, invited_by = excluded.invited_by, created_at = now();
end; $$;

create or replace function public.cancel_staff_invite(p_email text)
returns void language plpgsql security definer set search_path = ''
as $$
begin
  if not public.has_staff_role(array['master_admin']) then raise exception 'Only the Master Admin can cancel invites'; end if;
  delete from public.staff_invites where email = lower(trim(p_email));
end; $$;

create or replace function public.change_staff_role(p_user uuid, p_role text)
returns void language plpgsql security definer set search_path = ''
as $$
begin
  if not public.has_staff_role(array['master_admin']) then raise exception 'Only the Master Admin can change roles'; end if;
  if p_role not in ('co_admin', 'editor') then raise exception 'Choose Co-admin or Editor'; end if;
  update public.staff set staff_role = p_role where user_id = p_user and staff_role <> 'master_admin';
end; $$;

create or replace function public.remove_staff(p_user uuid)
returns void language plpgsql security definer set search_path = ''
as $$
begin
  if not public.has_staff_role(array['master_admin']) then raise exception 'Only the Master Admin can remove staff'; end if;
  delete from public.staff where user_id = p_user and staff_role <> 'master_admin';
end; $$;

-- Called after an invited person signs in. Their email must be confirmed.
create or replace function public.claim_staff_invite()
returns text language plpgsql security definer set search_path = ''
as $$
declare
  u   record;
  inv record;
begin
  select id, lower(email) as email, email_confirmed_at into u from auth.users where id = auth.uid();
  if u.id is null or u.email_confirmed_at is null then return public.my_staff_role(); end if;
  select * into inv from public.staff_invites where email = u.email;
  if inv.email is not null and not exists (select 1 from public.staff where user_id = u.id) then
    insert into public.staff (user_id, email, staff_role, added_by) values (u.id, u.email, inv.staff_role, inv.invited_by);
    delete from public.staff_invites where email = u.email;
    insert into public.profiles (id) values (u.id) on conflict (id) do nothing;
  end if;
  return public.my_staff_role();
end; $$;

-- 5. Admin actions -------------------------------------------------------

create or replace function public.set_seller_status(p_user uuid, p_status text)
returns void language plpgsql security definer set search_path = ''
as $$
begin
  if not public.has_staff_role(array['master_admin', 'co_admin']) then raise exception 'You don''t have permission to approve sellers'; end if;
  if p_status not in ('pending', 'approved', 'rejected') then raise exception 'Invalid status'; end if;
  update public.seller_details set status = p_status where user_id = p_user;
end; $$;

-- Customers and sellers with their sign-in email (emails live in auth.users)
create or replace function public.admin_list_users(p_role text)
returns table (
  id uuid, email text, full_name text, phone text, created_at timestamptz,
  address text, city text, postal_code text,
  shop_name text, shop_description text, business_address text, trade_license text, seller_status text
)
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not public.has_staff_role(array['master_admin', 'co_admin', 'editor']) then raise exception 'Staff only'; end if;
  return query
    select p.id, u.email::text, p.full_name, p.phone, p.created_at,
           c.address, coalesce(s.city, c.city), c.postal_code,
           s.shop_name, s.shop_description, s.business_address, s.trade_license, s.status
      from public.profiles p
      join auth.users u on u.id = p.id
      left join public.customer_details c on c.user_id = p.id
      left join public.seller_details  s on s.user_id = p.id
     where p.role = p_role
     order by p.created_at desc;
end; $$;

do $$
declare f text;
begin
  foreach f in array array[
    'public.invite_staff(text, text)', 'public.cancel_staff_invite(text)',
    'public.change_staff_role(uuid, text)', 'public.remove_staff(uuid)',
    'public.claim_staff_invite()', 'public.set_seller_status(uuid, text)',
    'public.admin_list_users(text)'
  ] loop
    execute format('revoke execute on function %s from public, anon', f);
    execute format('grant execute on function %s to authenticated', f);
  end loop;
end $$;

-- 6. Make yourself Master Admin ------------------------------------------
-- First create a normal account in the app (or Authentication → Users → Add user),
-- then replace the email below with yours and run just this statement.

insert into public.staff (user_id, email, staff_role)
select id, lower(email), 'master_admin' from auth.users where lower(email) = lower('YOUR-EMAIL@example.com')
on conflict (user_id) do update set staff_role = 'master_admin';
