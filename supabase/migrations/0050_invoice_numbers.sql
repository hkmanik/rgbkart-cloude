-- Invoice numbers per shop (owner, 24 Oct 2026). Every order keeps its RGB-… order number and also gets the shop's own
-- invoice number, e.g. TGH-2026-00001, TGH-2026-00002 … in an unbroken series for each shop and calendar year (Dhaka time).
-- 1. seller_details.invoice_code: the shop's short code (2–8 letters/digits), made from the shop name when the shop is
--    created (Test Gadget House → TGH). Shops can't change it (no column right); Master Admin / Co-admins can, with
--    admin_set_invoice_code(). A code already used on another shop's invoices is refused, so numbers never clash.
-- 2. orders.invoice_no: given by the database when the order is placed, never changed or reused. The counter moves in
--    the same transaction as the order, so a checkout that fails gives its number back (no gaps). A cancelled order
--    keeps its number; its invoice prints as cancelled.
-- 3. Existing shops get a code and existing orders get numbers in the order they were placed.
-- Run once in Supabase → SQL Editor, AFTER 0049_seller_rules_agree.sql. Safe to run again.

alter table public.seller_details add column if not exists invoice_code text;
alter table public.orders         add column if not exists invoice_no   text;
alter table public.seller_details drop constraint if exists seller_details_invoice_code_check;
alter table public.seller_details add constraint seller_details_invoice_code_check check (invoice_code is null or invoice_code ~ '^[A-Z0-9]{2,8}$');
create unique index if not exists seller_details_invoice_code_uniq on public.seller_details (invoice_code) where invoice_code is not null;
create unique index if not exists orders_invoice_no_uniq on public.orders (invoice_no) where invoice_no is not null;

-- Last number used, per shop and year. Only the database functions below touch it.
create table if not exists public.invoice_counters (
  seller_id  uuid not null references public.profiles (id) on delete cascade,
  yr         int  not null,
  last_no    int  not null default 0,
  primary key (seller_id, yr)
);
alter table public.invoice_counters enable row level security;
revoke all on public.invoice_counters from public, anon, authenticated;

-- Is this code in use by another shop (now, or on its old invoices)?
create or replace function public.invoice_code_taken(p_code text, p_seller uuid)
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.seller_details where invoice_code = p_code and user_id <> p_seller)
      or exists (select 1 from public.orders where invoice_no like p_code || '-%' and seller_id <> p_seller)
$$;
revoke execute on function public.invoice_code_taken(text, uuid) from public, anon, authenticated;

-- A free code from the shop name: first letters of up to 4 words (else the first 3 letters), then TGH2, TGH3 … if taken
create or replace function public.make_invoice_code(p_name text, p_seller uuid)
returns text language plpgsql stable security definer set search_path = ''
as $$
declare
  words text[] := array(select w from regexp_split_to_table(upper(coalesce(p_name, '')), '[^A-Z0-9]+') w where w <> '');
  base text := ''; c text; k int := 1;
begin
  for i in 1 .. least(coalesce(array_length(words, 1), 0), 4) loop base := base || left(words[i], 1); end loop;
  if length(base) < 2 then base := left(array_to_string(words, ''), 3); end if;
  if length(base) < 2 then base := 'SHOP'; end if;
  if base = 'RGB' then base := 'RGBS'; end if;          -- keep RGB-… for order numbers
  base := left(base, 6);
  c := base;
  while public.invoice_code_taken(c, p_seller) loop
    k := k + 1; c := base || k;
  end loop;
  return c;
end; $$;
revoke execute on function public.make_invoice_code(text, uuid) from public, anon, authenticated;

-- New shops get a code at once
create or replace function public.seller_invoice_code()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  if new.invoice_code is null then new.invoice_code := public.make_invoice_code(new.shop_name, new.user_id); end if;
  return new;
end; $$;
drop trigger if exists seller_invoice_code on public.seller_details;
create trigger seller_invoice_code before insert on public.seller_details for each row execute function public.seller_invoice_code();
revoke execute on function public.seller_invoice_code() from public, anon, authenticated;

-- Next number for a shop (moves the counter; rolled back with the order if the checkout fails)
create or replace function public.next_invoice_no(p_seller uuid, p_at timestamptz)
returns text language plpgsql security definer set search_path = ''
as $$
declare code text; y int := extract(year from coalesce(p_at, now()) at time zone 'Asia/Dhaka')::int; n int;
begin
  select invoice_code into code from public.seller_details where user_id = p_seller;
  if code is null then
    if exists (select 1 from public.seller_details where user_id = p_seller) then
      code := public.make_invoice_code((select shop_name from public.seller_details where user_id = p_seller), p_seller);
      update public.seller_details set invoice_code = code where user_id = p_seller;
    else
      code := 'S' || upper(left(replace(p_seller::text, '-', ''), 5));
    end if;
  end if;
  insert into public.invoice_counters (seller_id, yr, last_no) values (p_seller, y, 1)
    on conflict (seller_id, yr) do update set last_no = public.invoice_counters.last_no + 1
    returning last_no into n;
  return code || '-' || y || '-' || case when n < 100000 then lpad(n::text, 5, '0') else n::text end;
end; $$;
revoke execute on function public.next_invoice_no(uuid, timestamptz) from public, anon, authenticated;

create or replace function public.order_invoice_no()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  new.invoice_no := public.next_invoice_no(new.seller_id, coalesce(new.created_at, now()));
  return new;
end; $$;
drop trigger if exists order_invoice_no on public.orders;
create trigger order_invoice_no before insert on public.orders for each row execute function public.order_invoice_no();
revoke execute on function public.order_invoice_no() from public, anon, authenticated;

-- Admin: change a shop's code (new invoices only; old invoices keep their numbers)
create or replace function public.admin_set_invoice_code(p_seller uuid, p_code text)
returns text language plpgsql security definer set search_path = ''
as $$
declare c text := upper(regexp_replace(coalesce(p_code, ''), '\s', '', 'g'));
begin
  if not public.has_staff_role(array['master_admin', 'co_admin']) then raise exception 'Only the Master Admin or a Co-admin can change invoice codes'; end if;
  if c !~ '^[A-Z0-9]{2,8}$' then raise exception 'Use 2 to 8 letters or digits, e.g. TGH'; end if;
  if c ~ '^RGB' and length(c) = 3 then raise exception 'RGB is kept for order numbers. Choose another code'; end if;
  if not exists (select 1 from public.seller_details where user_id = p_seller) then raise exception 'Shop not found'; end if;
  if public.invoice_code_taken(c, p_seller) then raise exception 'Another shop already uses % on its invoices. Choose another code', c; end if;
  update public.seller_details set invoice_code = c where user_id = p_seller;
  return c;
end; $$;
revoke execute on function public.admin_set_invoice_code(uuid, text) from public, anon;
grant  execute on function public.admin_set_invoice_code(uuid, text) to authenticated;

-- 3. Existing shops and orders
do $$
declare r record;
begin
  for r in select user_id, shop_name from public.seller_details where invoice_code is null order by created_at, user_id loop
    update public.seller_details set invoice_code = public.make_invoice_code(r.shop_name, r.user_id) where user_id = r.user_id;
  end loop;
  for r in select id, seller_id, created_at from public.orders where invoice_no is null order by created_at, id loop
    update public.orders set invoice_no = public.next_invoice_no(r.seller_id, r.created_at) where id = r.id;
  end loop;
end $$;

select (select count(*) from public.seller_details where invoice_code is null) as shops_without_code,
       (select count(*) from public.orders where invoice_no is null) as orders_without_invoice,
       (select count(*) from pg_trigger where tgname in ('seller_invoice_code', 'order_invoice_no')) as invoice_triggers;
