-- Delivery charges set by each shop (product rule: admin defines the methods, each seller picks methods and sets rates).
-- * Admin → Orders → Delivery methods: the normal methods (Inside Dhaka, Outside Dhaka, Store pickup, Agree with the seller)
--   plus special ones for Heavy, Vehicle, Flammable and Fragile items. Each has a suggested fee and a MAXIMUM fee shops can charge.
--   Admin can add more methods.
-- * Seller Center → Delivery: the shop ticks the methods it offers and sets its own fee (empty = RGBKart's suggested fee),
--   and can give free delivery above an amount. Shops that haven't set this up keep today's normal methods and fees.
-- * Products marked Heavy / Vehicle / Flammable / Fragile can only be sent with a matching special method (or pickup / agree with seller).
-- * place_order works out every fee again on the server. Orders remember the method's name (orders.ship_name).
-- Run once in Supabase → SQL Editor, AFTER 0044_vat_per_product.sql. Safe to run again.

-- 1. Delivery methods: any id, an area, a product type for special methods, and a maximum fee ---------------------------
alter table public.shipping_methods drop constraint if exists shipping_methods_id_check;
alter table public.shipping_methods drop constraint if exists shipping_methods_id_format;
alter table public.shipping_methods add constraint shipping_methods_id_format check (id ~ '^[a-z][a-z0-9_]{1,29}$');
alter table public.shipping_methods add column if not exists name_bn   text;
alter table public.shipping_methods add column if not exists area      text not null default 'any';
alter table public.shipping_methods add column if not exists for_class text;
alter table public.shipping_methods add column if not exists max_fee   numeric(10, 2);
alter table public.shipping_methods drop constraint if exists shipping_methods_extra_check;
alter table public.shipping_methods add constraint shipping_methods_extra_check check (
  area in ('dhaka', 'outside', 'any') and (for_class is null or for_class in ('heavy', 'vehicle', 'flammable', 'fragile'))
  and (max_fee is null or max_fee >= fee));
update public.shipping_methods set area = 'dhaka'   where id = 'dhaka'   and area = 'any';
update public.shipping_methods set area = 'outside' where id = 'outside' and area = 'any';
update public.shipping_methods set max_fee = greatest(fee, 200) where id = 'dhaka'   and max_fee is null;
update public.shipping_methods set max_fee = greatest(fee, 300) where id = 'outside' and max_fee is null;
update public.shipping_methods set name_bn = 'ঢাকার ভিতরে' where id = 'dhaka' and name_bn is null;
update public.shipping_methods set name_bn = 'ঢাকার বাইরে' where id = 'outside' and name_bn is null;
update public.shipping_methods set name_bn = 'দোকান থেকে সংগ্রহ' where id = 'pickup' and name_bn is null;
update public.shipping_methods set name_bn = 'বিক্রেতার সাথে আলোচনা' where id = 'negotiated' and name_bn is null;
insert into public.shipping_methods (id, name, name_bn, fee, max_fee, eta, area, for_class, sort_order) values
  ('heavy_dhaka',     'Heavy item · Inside Dhaka',        'ভারী পণ্য · ঢাকার ভিতরে',     300,  1500, '1–3 days',  'dhaka',   'heavy',     50),
  ('heavy_outside',   'Heavy item · Outside Dhaka',       'ভারী পণ্য · ঢাকার বাইরে',     600,  3000, '3–7 days',  'outside', 'heavy',     51),
  ('fragile_dhaka',   'Fragile item · Inside Dhaka',      'ভঙ্গুর পণ্য · ঢাকার ভিতরে',   150,   600, '1–2 days',  'dhaka',   'fragile',   60),
  ('fragile_outside', 'Fragile item · Outside Dhaka',     'ভঙ্গুর পণ্য · ঢাকার বাইরে',   250,  1000, '3–5 days',  'outside', 'fragile',   61),
  ('flammable',       'Flammable goods (special courier)', 'দাহ্য পণ্য (বিশেষ কুরিয়ার)', 400,  2000, '2–5 days',  'any',     'flammable', 70),
  ('vehicle',         'Vehicle transport',                'যানবাহন পরিবহন',              3000, 15000, '2–7 days',  'any',     'vehicle',   80)
on conflict (id) do nothing;

grant update (name, name_bn, fee, max_fee, eta, is_active, sort_order, area, for_class, updated_at) on public.shipping_methods to authenticated;
grant insert (id, name, name_bn, fee, max_fee, eta, is_active, sort_order, area, for_class) on public.shipping_methods to authenticated;
drop policy if exists "Admins add delivery methods" on public.shipping_methods;
create policy "Admins add delivery methods" on public.shipping_methods for insert to authenticated
  with check (public.has_staff_role(array['master_admin', 'co_admin']));

-- 2. Products: two more delivery types -----------------------------------------------------------------------------------
do $$
declare d text;
begin
  select pg_get_constraintdef(oid) into d from pg_constraint where conrelid = 'public.products'::regclass and conname = 'products_rules';
  if d is not null and d not like '%''vehicle''%' then
    d := replace(d, '''fragile''::text])', '''fragile''::text, ''vehicle''::text, ''flammable''::text])');
    execute 'alter table public.products drop constraint products_rules';
    execute 'alter table public.products add constraint products_rules ' || d;
  end if;
end $$;

-- 3. What each shop offers ----------------------------------------------------------------------------------------------
create table if not exists public.seller_shipping (
  seller_id  uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  method_id  text not null references public.shipping_methods (id) on delete cascade,
  is_on      boolean not null default true,
  fee        numeric(10, 2) check (fee is null or fee >= 0),      -- empty = RGBKart's suggested fee
  updated_at timestamptz not null default now(),
  primary key (seller_id, method_id)
);
create table if not exists public.seller_delivery (
  seller_id  uuid primary key default auth.uid() references public.profiles (id) on delete cascade,
  free_over  numeric(12, 2) check (free_over is null or free_over > 0),   -- free delivery when the shop's items cost this much or more
  updated_at timestamptz not null default now()
);
alter table public.seller_shipping enable row level security;
alter table public.seller_delivery enable row level security;
revoke all on public.seller_shipping, public.seller_delivery from anon, authenticated;
grant select on public.seller_shipping, public.seller_delivery to anon, authenticated;
grant insert, update, delete on public.seller_shipping, public.seller_delivery to authenticated;
drop policy if exists "Everyone reads shop delivery" on public.seller_shipping;
create policy "Everyone reads shop delivery" on public.seller_shipping for select to anon, authenticated using (true);
drop policy if exists "Shop edits own delivery" on public.seller_shipping;
create policy "Shop edits own delivery" on public.seller_shipping for all to authenticated
  using (seller_id = auth.uid()) with check (seller_id = auth.uid() and public.is_seller());
drop policy if exists "Everyone reads shop free delivery" on public.seller_delivery;
create policy "Everyone reads shop free delivery" on public.seller_delivery for select to anon, authenticated using (true);
drop policy if exists "Shop edits own free delivery" on public.seller_delivery;
create policy "Shop edits own free delivery" on public.seller_delivery for all to authenticated
  using (seller_id = auth.uid()) with check (seller_id = auth.uid() and public.is_seller());

-- a shop's fee can't be above RGBKart's maximum for that method
create or replace function public.seller_shipping_check()
returns trigger language plpgsql security definer set search_path = ''
as $$
declare mx numeric; nm text;
begin
  select max_fee, name into mx, nm from public.shipping_methods where id = new.method_id;
  if new.method_id in ('pickup', 'negotiated') then new.fee := null; end if;
  if new.fee is not null and mx is not null and new.fee > mx then
    raise exception 'The most you can charge for % is ৳%', nm, to_char(mx, 'FM999,999,990');
  end if;
  new.updated_at := now();
  return new;
end; $$;
drop trigger if exists seller_shipping_check on public.seller_shipping;
create trigger seller_shipping_check before insert or update on public.seller_shipping for each row execute function public.seller_shipping_check();
do $$ begin
  if to_regprocedure('public.log_staff_action()') is not null then
    drop trigger if exists log_staff_action on public.shipping_methods;
    create trigger log_staff_action after insert or update or delete on public.shipping_methods for each row execute function public.log_staff_action();
  end if;
end $$;

-- 4. Orders remember the method's name ------------------------------------------------------------------------------------
alter table public.orders add column if not exists ship_name text;

-- 5. Place an order (replaces the version from 0033; only the delivery part changed) -------------------------------------
create or replace function public.place_order(p_items jsonb, p_ship jsonb, p_customer jsonb, p_coupons jsonb default '{}'::jsonb)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare
  uid uuid := auth.uid(); it jsonb; pr record; va record; vid bigint; unit numeric; qty int; lbl text; img text;
  ph text; nm text; addr text; dist text; sel uuid; m text; sm record; shop record; fee numeric; sub numeric;
  oid bigint; ono text; result jsonb := '[]'::jsonb; sellers uuid[]; nitems int := 0; tday text;
  cc text; cp public.shop_coupons; disc numeric; cls text; ss record; free_over numeric; ship_name text;
begin
  if uid is null then raise exception 'Please reload the page and try again'; end if;
  nm := trim(coalesce(p_customer->>'name', '')); addr := trim(coalesce(p_customer->>'address', '')); dist := trim(coalesce(p_customer->>'district', ''));
  ph := regexp_replace(coalesce(p_customer->>'phone', ''), '[^0-9+]', '', 'g');
  if char_length(nm) < 2 then raise exception 'Enter your name'; end if;
  if ph !~ '^(\+?880)?01[3-9][0-9]{8}$' then raise exception 'Enter a valid mobile number, like 01711000000'; end if;
  if char_length(addr) < 5 then raise exception 'Enter your full delivery address (house, road, area)'; end if;
  if dist = '' then raise exception 'Choose your district'; end if;
  if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then raise exception 'Your cart is empty'; end if;
  if jsonb_array_length(p_items) > 30 then raise exception 'Too many items in one order (30 at most)'; end if;
  if (select count(*) from public.orders where customer_id = uid and created_at > now() - interval '1 day') >= 20 then
    raise exception 'You have placed many orders today. Please contact us if you need more.';
  end if;

  -- work out each line, grouped by shop
  create temp table if not exists _lines (seller_id uuid, product_id bigint, variation_id bigint, title text, label text, img text, unit numeric, qty int, manage boolean, free_del boolean, ships_to text, ship_class text) on commit drop;
  alter table _lines add column if not exists ship_class text;
  delete from _lines;
  for it in select * from jsonb_array_elements(p_items) loop
    qty := coalesce((it->>'qty')::int, 0);
    if qty < 1 or qty > 99 then raise exception 'Choose a quantity from 1 to 99'; end if;
    select p.*, sd.vacation_mode into pr from public.products p join public.seller_details sd on sd.user_id = p.seller_id and sd.status = 'approved'
     where p.id = (it->>'product_id')::bigint for update of p;
    if pr.id is null or pr.status <> 'approved' then raise exception 'An item in your cart is no longer available. Please remove it.'; end if;
    if pr.contact_only then raise exception '"%" can''t be ordered online. Contact the seller instead.', pr.title; end if;
    if pr.is_downloadable then raise exception '"%" is a digital product and can''t be ordered yet.', pr.title; end if;
    if not pr.cod_allowed then raise exception '"%" can''t be paid by Cash on Delivery.', pr.title; end if;
    if pr.vacation_mode then raise exception 'The shop selling "%" is on holiday and not taking orders.', pr.title; end if;
    if pr.seller_id = uid then raise exception 'You can''t order your own product'; end if;
    if pr.sold_individually then qty := 1; end if;
    lbl := null; vid := null; img := (select storage_path from public.product_images where product_id = pr.id order by sort_order limit 1);
    if pr.product_type = 'variable' then
      select v.* into va from public.product_variations v where v.id = (it->>'variation_id')::bigint and v.product_id = pr.id and v.is_active for update;
      if va.id is null then raise exception 'Choose an option for "%"', pr.title; end if;
      unit := coalesce(va.sale_price, va.price); vid := va.id;
      if va.stock < qty and pr.backorders = 'no' then raise exception 'Only % left of "%"', va.stock, pr.title; end if;
      select string_agg(o.value || coalesce(' ' || a.unit, ''), ' / ' order by a.name) into lbl
        from public.product_variation_options vo join public.attribute_options o on o.id = vo.option_id join public.attributes a on a.id = vo.attribute_id
       where vo.variation_id = va.id;
      if va.image_id is not null then img := coalesce((select storage_path from public.product_images where id = va.image_id), img); end if;
      update public.product_variations set stock = greatest(stock - qty, 0) where id = va.id;
    else
      unit := case when pr.sale_price is not null and (pr.sale_starts_at is null or pr.sale_starts_at <= now())
                         and (pr.sale_ends_at is null or pr.sale_ends_at >= now()) then pr.sale_price else pr.price end;
      -- bulk price: the lowest price for the quantity bought (set by the seller under Bulk prices)
      unit := least(unit, coalesce((select min(t.unit_price) from public.product_price_tiers t where t.product_id = pr.id and t.min_qty <= qty), unit));
      if pr.manage_stock and pr.stock < qty and pr.backorders = 'no' then
        if pr.stock = 0 then raise exception '"%" is out of stock', pr.title; end if;
        raise exception 'Only % left of "%"', pr.stock, pr.title;
      end if;
      if not pr.manage_stock and pr.stock_status = 'out_of_stock' then raise exception '"%" is out of stock', pr.title; end if;
      if pr.manage_stock then update public.products set stock = greatest(stock - qty, 0) where id = pr.id; end if;
    end if;
    if unit is null or unit <= 0 then raise exception '"%" has no price yet', pr.title; end if;
    insert into _lines (seller_id, product_id, variation_id, title, label, img, unit, qty, manage, free_del, ships_to, ship_class)
      values (pr.seller_id, pr.id, vid, pr.title, lbl, img, unit, qty, pr.manage_stock, pr.free_delivery, pr.ships_to, pr.shipping_class);
    nitems := nitems + 1;
  end loop;

  -- one order per shop
  tday := to_char(now() at time zone 'Asia/Dhaka', 'YYMMDD');
  sellers := array(select distinct l.seller_id from _lines l);
  foreach sel in array sellers loop
    select * into shop from public.seller_details where user_id = sel;
    m := coalesce(p_ship->>(sel::text), 'negotiated');
    sub := (select sum(l.unit * l.qty) from _lines l where l.seller_id = sel);
    -- delivery set by the shop (0045): special items (vehicle > flammable > heavy > fragile) need a matching special method
    cls := (select l.ship_class from _lines l where l.seller_id = sel and l.ship_class in ('vehicle', 'flammable', 'heavy', 'fragile')
             order by array_position(array['vehicle', 'flammable', 'heavy', 'fragile'], l.ship_class) limit 1);
    select * into sm from public.shipping_methods where id = m and is_active;
    if sm.id is null then raise exception 'Choose a delivery option for %', shop.shop_name; end if;
    select * into ss from public.seller_shipping where seller_id = sel and method_id = m;
    if m = 'pickup' then
      if not shop.allow_pickup then raise exception '% doesn''t offer store pickup', shop.shop_name; end if;
    elsif m <> 'negotiated' then
      if sm.for_class is distinct from cls then raise exception 'Choose a delivery option that suits the items from %', shop.shop_name; end if;
      if exists (select 1 from public.seller_shipping x where x.seller_id = sel) then
        if not coalesce(ss.is_on, false) then raise exception '% doesn''t offer %', shop.shop_name, sm.name; end if;
      elsif sm.for_class is not null then raise exception '% doesn''t offer %', shop.shop_name, sm.name;
      end if;
      if sm.area = 'dhaka' and exists (select 1 from _lines l where l.seller_id = sel and l.ships_to = 'outside_dhaka') then raise exception 'Some items from % don''t deliver inside Dhaka', shop.shop_name; end if;
      if sm.area = 'outside' and exists (select 1 from _lines l where l.seller_id = sel and l.ships_to = 'inside_dhaka') then raise exception 'Some items from % only deliver inside Dhaka', shop.shop_name; end if;
    end if;
    select d.free_over into free_over from public.seller_delivery d where d.seller_id = sel;
    fee := case when m in ('pickup', 'negotiated') then 0
                when cls is null and not exists (select 1 from _lines l where l.seller_id = sel and not l.free_del) then 0
                when cls is null and free_over is not null and sub >= free_over then 0
                else least(coalesce(ss.fee, sm.fee), coalesce(sm.max_fee, coalesce(ss.fee, sm.fee))) end;
    ship_name := sm.name;
    -- shop coupon (0033): checked again here, whatever the cart page showed
    disc := 0; cp := null;
    cc := upper(regexp_replace(coalesce(p_coupons->>(sel::text), ''), '\s', '', 'g'));
    if cc <> '' then
      select * into cp from public.shop_coupons c where c.seller_id = sel and c.code = cc for update;
      disc := public.coupon_discount(cp, sub, uid, ph);   -- raises a clear message if the code can't be used
    end if;
    loop
      ono := 'RGB-' || tday || '-' || upper(substr(md5(random()::text || clock_timestamp()::text), 1, 5));
      exit when not exists (select 1 from public.orders where order_no = ono);
    end loop;
    insert into public.orders (order_no, customer_id, seller_id, customer_name, phone, email, address, district, area, note, ship_method, ship_name, ship_fee, subtotal, total, discount, coupon_code)
    values (ono, uid, sel, left(nm, 80), ph, nullif(lower(trim(coalesce(p_customer->>'email', ''))), ''), left(addr, 300), left(dist, 40),
            nullif(left(trim(coalesce(p_customer->>'area', '')), 60), ''), nullif(left(trim(coalesce(p_customer->>'note', '')), 500), ''), m, ship_name, fee, sub, sub + fee - disc,
            disc, case when disc > 0 then cp.code end)
    returning id into oid;
    if disc > 0 then
      insert into public.coupon_uses (coupon_id, order_id, customer_id, phone, amount) values (cp.id, oid, uid, ph, disc);
      update public.shop_coupons set used_count = used_count + 1 where id = cp.id;
    end if;
    insert into public.order_items (order_id, product_id, variation_id, title, variant_label, image_path, unit_price, qty, line_total)
    select oid, l.product_id, l.variation_id, l.title, l.label, l.img, l.unit, l.qty, l.unit * l.qty from _lines l where l.seller_id = sel;
    result := result || jsonb_build_object('order_no', ono, 'shop', shop.shop_name, 'phone', case when shop.phone_public is not null then shop.phone_public end, 'total', sub + fee - disc, 'discount', disc, 'ship', sm.name);
  end loop;

  -- remember the address on the customer's profile for next time
  insert into public.profiles (id) values (uid) on conflict (id) do nothing;
  update public.profiles set full_name = coalesce(nullif(full_name, ''), left(nm, 80)), phone = coalesce(nullif(phone, ''), ph) where id = uid;
  return result;
end; $$;

revoke execute on function public.place_order(jsonb, jsonb, jsonb, jsonb) from public, anon;
grant  execute on function public.place_order(jsonb, jsonb, jsonb, jsonb) to authenticated;

select (select count(*) from public.shipping_methods) as delivery_methods,
       to_regclass('public.seller_shipping') is not null as shop_delivery_ready;
