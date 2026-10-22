-- Customer & seller accounts: run once in Supabase → SQL Editor, AFTER setup.sql.
-- Safe to run again.

-- 1. Tables --------------------------------------------------------------

create table if not exists public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  role        text check (role in ('customer', 'seller')),   -- null until chosen (Google/Facebook sign-ups)
  full_name   text,
  phone       text,
  created_at  timestamptz not null default now()
);

create table if not exists public.customer_details (
  user_id      uuid primary key references public.profiles (id) on delete cascade,
  address      text,
  city         text,
  postal_code  text
);

create table if not exists public.seller_details (
  user_id           uuid primary key references public.profiles (id) on delete cascade,
  shop_name         text not null,
  shop_description  text,
  business_address  text,
  city              text,
  trade_license     text,
  status            text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_at        timestamptz not null default now()
);

-- 2. Fill in role + details (internal; not callable from the browser) ----

create or replace function public.apply_profile(uid uuid, meta jsonb)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  r text := meta->>'role';
begin
  if r is null then return; end if;
  if r not in ('customer', 'seller') then
    raise exception 'Invalid account type';
  end if;

  update public.profiles
     set role      = r,
         full_name = coalesce(nullif(trim(meta->>'full_name'), ''), full_name),
         phone     = coalesce(nullif(trim(meta->>'phone'), ''), phone)
   where id = uid;

  if r = 'customer' then
    insert into public.customer_details (user_id, address, city, postal_code)
    values (uid, meta->>'address', meta->>'city', meta->>'postal_code')
    on conflict (user_id) do nothing;
  else
    if coalesce(trim(meta->>'shop_name'), '') = '' then
      raise exception 'Shop name is required';
    end if;
    insert into public.seller_details (user_id, shop_name, shop_description, business_address, city, trade_license)
    values (uid, trim(meta->>'shop_name'), meta->>'shop_description', meta->>'business_address', meta->>'city', meta->>'trade_license')
    on conflict (user_id) do nothing;
  end if;
end;
$$;

revoke execute on function public.apply_profile(uuid, jsonb) from public, anon, authenticated;

-- 3. Create a profile automatically for every new account ----------------

create or replace function public.handle_new_user()
returns trigger
language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name'))
  on conflict (id) do nothing;
  perform public.apply_profile(new.id, new.raw_user_meta_data);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Profiles for accounts that existed before this script ran
insert into public.profiles (id, full_name)
select id, coalesce(raw_user_meta_data->>'full_name', raw_user_meta_data->>'name')
from auth.users
on conflict (id) do nothing;

-- 4. Choose account type later (Google / Facebook sign-ups) --------------

create or replace function public.complete_profile(meta jsonb)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Not signed in';
  end if;
  if exists (select 1 from public.profiles where id = auth.uid() and role is not null) then
    raise exception 'Account type is already set';
  end if;
  insert into public.profiles (id) values (auth.uid()) on conflict (id) do nothing;
  perform public.apply_profile(auth.uid(), meta);
end;
$$;

revoke execute on function public.complete_profile(jsonb) from public, anon;
grant  execute on function public.complete_profile(jsonb) to authenticated;

-- 5. Security: users see and edit only their own data -------------------
--    Role and seller approval status can't be changed from the browser.

alter table public.profiles         enable row level security;
alter table public.customer_details enable row level security;
alter table public.seller_details   enable row level security;

drop policy if exists "Read own profile"   on public.profiles;
drop policy if exists "Update own profile" on public.profiles;
create policy "Read own profile"   on public.profiles for select to authenticated using (auth.uid() = id);
create policy "Update own profile" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "Read own customer details"   on public.customer_details;
drop policy if exists "Update own customer details" on public.customer_details;
create policy "Read own customer details"   on public.customer_details for select to authenticated using (auth.uid() = user_id);
create policy "Update own customer details" on public.customer_details for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Read own seller details"   on public.seller_details;
drop policy if exists "Update own seller details" on public.seller_details;
create policy "Read own seller details"   on public.seller_details for select to authenticated using (auth.uid() = user_id);
create policy "Update own seller details" on public.seller_details for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

revoke insert, update, delete on public.profiles, public.customer_details, public.seller_details from anon, authenticated;
grant update (full_name, phone)                                                     on public.profiles         to authenticated;
grant update (address, city, postal_code)                                           on public.customer_details to authenticated;
grant update (shop_name, shop_description, business_address, city, trade_license)   on public.seller_details   to authenticated;
