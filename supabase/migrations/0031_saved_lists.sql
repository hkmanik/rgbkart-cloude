-- Wishlist & cart in the customer's account (plan 2.5 / 2.6).
-- One row per signed-in customer with their saved items (product ids) and cart (the same list the site keeps on the device).
-- The site merges the device's lists into the account at sign-in, then keeps them in step, so they follow the customer
-- to every phone and computer. Prices and stock are always checked again live, and again by place_order.
-- Run once in Supabase → SQL Editor, AFTER 0030_reports_fraud.sql. Safe to run again.

create table if not exists public.customer_lists (
  user_id     uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  wishlist    bigint[] not null default '{}',
  cart        jsonb not null default '[]',
  updated_at  timestamptz not null default now(),
  constraint customer_lists_wishlist_size check (cardinality(wishlist) <= 300),
  constraint customer_lists_cart_shape check (jsonb_typeof(cart) = 'array' and jsonb_array_length(cart) <= 100 and octet_length(cart::text) <= 100000)
);

alter table public.customer_lists enable row level security;
revoke all on public.customer_lists from anon, authenticated;
grant select, insert, update, delete on public.customer_lists to authenticated;
drop policy if exists "Own lists" on public.customer_lists;
create policy "Own lists" on public.customer_lists for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create or replace function public.customer_lists_touch()
returns trigger language plpgsql set search_path = ''
as $$
begin
  new.updated_at := now();
  new.wishlist := coalesce((select array_agg(distinct x) from unnest(new.wishlist) x where x is not null), '{}');
  return new;
end; $$;
drop trigger if exists customer_lists_touch on public.customer_lists;
create trigger customer_lists_touch before insert or update on public.customer_lists for each row execute function public.customer_lists_touch();

select to_regclass('public.customer_lists') is not null as saved_lists_ready;
