-- 0072 Courier booking from Seller Center: Steadfast, Pathao, RedX (owner, 30 Oct 2026).
-- Each shop connects ITS OWN courier merchant account(s) (Seller Center → Delivery → Courier accounts) and chooses the
-- courier for each order. The "courier" Edge Function talks to the couriers; the shop's keys are kept only on the server:
-- nobody (not even the shop itself) can read them back from the website.
-- Safe to run more than once.

-- 1. Courier details on orders (filled only by the courier function) --------------------------------------------------------
alter table public.orders add column if not exists courier text;               -- steadfast | pathao | redx
alter table public.orders add column if not exists courier_tracking text;      -- code the buyer can track with
alter table public.orders add column if not exists courier_ref text;           -- the courier's consignment id
alter table public.orders add column if not exists courier_status text;        -- last status the courier reported
alter table public.orders add column if not exists courier_booked_at timestamptz;
alter table public.orders add column if not exists courier_checked_at timestamptz;
do $$ begin
  alter table public.orders add constraint orders_courier_check check (courier is null or courier in ('steadfast', 'pathao', 'redx'));
exception when duplicate_object then null; end $$;
-- shops and buyers read these with the rest of the order (existing rules); only the server writes them

-- 2. Each shop's courier accounts (server only) ------------------------------------------------------------------------------
create table if not exists public.courier_accounts (
  seller_id    uuid not null references public.profiles (id) on delete cascade,
  courier      text not null check (courier in ('steadfast', 'pathao', 'redx')),
  creds        jsonb not null,                    -- API keys / login: never sent to the website
  token        jsonb,                             -- Pathao access token (renewed by the server)
  settings     jsonb not null default '{}'::jsonb, -- e.g. Pathao store id and name
  connected_at timestamptz not null default now(),
  primary key (seller_id, courier)
);
alter table public.courier_accounts enable row level security;
revoke all on public.courier_accounts from anon, authenticated;

-- What the shop may see: which couriers are connected (no keys)
create or replace function public.my_couriers()
returns table (courier text, store_name text, connected_at timestamptz)
language sql stable security definer set search_path = ''
as $$ select c.courier, c.settings->>'store_name', c.connected_at from public.courier_accounts c where c.seller_id = auth.uid() order by c.courier $$;
revoke execute on function public.my_couriers() from public, anon;
grant  execute on function public.my_couriers() to authenticated;

create or replace function public.disconnect_courier(p_courier text)
returns void language sql security definer set search_path = ''
as $$ delete from public.courier_accounts where seller_id = auth.uid() and courier = p_courier $$;
revoke execute on function public.disconnect_courier(text) from public, anon;
grant  execute on function public.disconnect_courier(text) to authenticated;

select count(*) as courier_accounts from public.courier_accounts;
