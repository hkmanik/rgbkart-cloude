-- VAT per category and per product (owner, 23 Oct: "different products will have different VAT or no VAT").
-- Which VAT rate a product uses, in this order:
--   1. the product's own rate (set by the Master Admin / a Co-admin in Admin → Products → VAT; 0 = no VAT),
--   2. else the rate of its category, or the nearest category above it that has one (Admin → Categories),
--   3. else the default rate in Admin → Orders → VAT on invoices.
-- Nothing is charged extra: prices include VAT. Each new order line records its rate and VAT amount; the order keeps the total.
-- VAT is only recorded while "Show VAT on new orders" is on. Sellers can't change any VAT rate.
-- Run once in Supabase → SQL Editor, AFTER 0043_vat.sql. Safe to run again.

alter table public.categories  add column if not exists vat_rate numeric(5, 2) check (vat_rate is null or (vat_rate >= 0 and vat_rate <= 50));
alter table public.products    add column if not exists vat_rate numeric(5, 2) check (vat_rate is null or (vat_rate >= 0 and vat_rate <= 50));
alter table public.order_items add column if not exists vat_rate numeric(5, 2);
alter table public.order_items add column if not exists vat_amount numeric(12, 2);

-- Only the Master Admin or a Co-admin may change a category's VAT (editors can still edit the rest of the category).
-- Runs with the caller's rights so it sees who is really making the change.
create or replace function public.category_vat_guard()
returns trigger language plpgsql set search_path = ''
as $$
begin
  if new.vat_rate is distinct from (case when tg_op = 'UPDATE' then old.vat_rate end)
     and not public.has_staff_role(array['master_admin', 'co_admin'])
     and current_user not in ('postgres', 'supabase_admin') then
    raise exception 'Only the Master Admin or a Co-admin can set VAT';
  end if;
  return new;
end; $$;
drop trigger if exists category_vat_guard on public.categories;
create trigger category_vat_guard before insert or update on public.categories for each row execute function public.category_vat_guard();

-- Products: sellers have no right to the vat_rate column; staff set it here
create or replace function public.admin_set_product_vat(p_products bigint[], p_rate numeric)
returns integer language plpgsql security definer set search_path = ''
as $$
declare n integer;
begin
  if not public.has_staff_role(array['master_admin', 'co_admin']) then raise exception 'Only the Master Admin or a Co-admin can set VAT'; end if;
  if p_rate is not null and (p_rate < 0 or p_rate > 50) then raise exception 'VAT rate must be from 0 to 50'; end if;
  update public.products set vat_rate = p_rate where id = any (coalesce(p_products, '{}'));
  get diagnostics n = row_count;
  return n;
end; $$;
revoke execute on function public.admin_set_product_vat(bigint[], numeric) from public, anon;
grant  execute on function public.admin_set_product_vat(bigint[], numeric) to authenticated;

-- The rate a product uses now (null when VAT is switched off)
create or replace function public.product_vat_rate(p_product bigint)
returns numeric language plpgsql stable security definer set search_path = ''
as $$
declare s jsonb; r numeric; cat bigint; guard int := 0;
begin
  select value into s from public.site_settings where key = 'vat';
  if s is null or not coalesce((s->>'on')::boolean, false) then return null; end if;
  select vat_rate, category_id into r, cat from public.products where id = p_product;
  while r is null and cat is not null and guard < 10 loop
    select c.vat_rate, c.parent_id into r, cat from public.categories c where c.id = cat;
    guard := guard + 1;
  end loop;
  return least(greatest(coalesce(r, (s->>'rate')::numeric, 0), 0), 50);
end; $$;
grant execute on function public.product_vat_rate(bigint) to anon, authenticated;

-- each order line: its rate and the VAT inside its price
create or replace function public.order_item_vat()
returns trigger language plpgsql security definer set search_path = ''
as $$
declare r numeric;
begin
  if new.product_id is null then return new; end if;
  r := public.product_vat_rate(new.product_id);
  if r is null then return new; end if;
  new.vat_rate := r;
  new.vat_amount := round(coalesce(new.line_total, 0) * r / (100 + r), 2);
  return new;
end; $$;
drop trigger if exists order_item_vat on public.order_items;
create trigger order_item_vat before insert on public.order_items for each row execute function public.order_item_vat();

-- the order: VAT of its lines (less any shop coupon, shared in proportion); one rate shown only when all lines share it
create or replace function public.order_vat_total()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  update public.orders o
     set vat_amount = round(x.vat * case when o.subtotal > 0 then greatest(o.subtotal - coalesce(o.discount, 0), 0) / o.subtotal else 1 end, 2),
         vat_rate = case when x.rates = 1 then x.one_rate end
    from (select i.order_id, sum(coalesce(i.vat_amount, 0)) as vat, count(distinct i.vat_rate) as rates, max(i.vat_rate) as one_rate
            from public.order_items i
           where i.order_id in (select distinct order_id from new_items) and i.vat_rate is not null
           group by i.order_id) x
   where o.id = x.order_id;
  return null;
end; $$;
drop trigger if exists order_vat_total on public.order_items;
create trigger order_vat_total after insert on public.order_items referencing new table as new_items
  for each statement execute function public.order_vat_total();
revoke execute on function public.order_item_vat(), public.order_vat_total() from public, anon, authenticated;

-- the whole-order VAT from 0043 is replaced by the per-line VAT above
drop trigger if exists order_vat on public.orders;

select (select value from public.site_settings where key = 'vat') as vat_setting,
       (select count(*) from pg_trigger where tgname in ('order_item_vat', 'order_vat_total', 'category_vat_guard')) as vat_ready;
