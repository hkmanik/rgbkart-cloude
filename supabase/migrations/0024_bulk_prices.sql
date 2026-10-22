-- Bulk prices ("Buy more, pay less") are now used when the order is placed, not only shown on the product page.
-- Same place_order as 0020_orders.sql with one added line (marked "bulk price").
-- Run once in Supabase → SQL Editor, AFTER 0023_home_section_types.sql. Safe to run again.

create or replace function public.place_order(p_items jsonb, p_ship jsonb, p_customer jsonb)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare
  uid uuid := auth.uid(); it jsonb; pr record; va record; vid bigint; unit numeric; qty int; lbl text; img text;
  ph text; nm text; addr text; dist text; sel uuid; m text; sm record; shop record; fee numeric; sub numeric;
  oid bigint; ono text; result jsonb := '[]'::jsonb; sellers uuid[]; nitems int := 0; tday text;
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
  create temp table if not exists _lines (seller_id uuid, product_id bigint, variation_id bigint, title text, label text, img text, unit numeric, qty int, manage boolean, free_del boolean, ships_to text) on commit drop;
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
    insert into _lines values (pr.seller_id, pr.id, vid, pr.title, lbl, img, unit, qty, pr.manage_stock, pr.free_delivery, pr.ships_to);
    nitems := nitems + 1;
  end loop;

  -- one order per shop
  tday := to_char(now() at time zone 'Asia/Dhaka', 'YYMMDD');
  sellers := array(select distinct l.seller_id from _lines l);
  foreach sel in array sellers loop
    select * into shop from public.seller_details where user_id = sel;
    m := coalesce(p_ship->>(sel::text), 'negotiated');
    select * into sm from public.shipping_methods where id = m and is_active;
    if sm.id is null then raise exception 'Choose a delivery option for %', shop.shop_name; end if;
    if m = 'pickup' and not shop.allow_pickup then raise exception '% doesn''t offer store pickup', shop.shop_name; end if;
    if m = 'dhaka' and exists (select 1 from _lines l where l.seller_id = sel and l.ships_to = 'outside_dhaka') then raise exception 'Some items from % don''t deliver inside Dhaka', shop.shop_name; end if;
    if m = 'outside' and exists (select 1 from _lines l where l.seller_id = sel and l.ships_to = 'inside_dhaka') then raise exception 'Some items from % only deliver inside Dhaka', shop.shop_name; end if;
    sub := (select sum(l.unit * l.qty) from _lines l where l.seller_id = sel);
    fee := case when m in ('dhaka', 'outside') and not exists (select 1 from _lines l where l.seller_id = sel and not l.free_del) then 0
                when m in ('dhaka', 'outside') then sm.fee else 0 end;
    loop
      ono := 'RGB-' || tday || '-' || upper(substr(md5(random()::text || clock_timestamp()::text), 1, 5));
      exit when not exists (select 1 from public.orders where order_no = ono);
    end loop;
    insert into public.orders (order_no, customer_id, seller_id, customer_name, phone, email, address, district, area, note, ship_method, ship_fee, subtotal, total)
    values (ono, uid, sel, left(nm, 80), ph, nullif(lower(trim(coalesce(p_customer->>'email', ''))), ''), left(addr, 300), left(dist, 40),
            nullif(left(trim(coalesce(p_customer->>'area', '')), 60), ''), nullif(left(trim(coalesce(p_customer->>'note', '')), 500), ''), m, fee, sub, sub + fee)
    returning id into oid;
    insert into public.order_items (order_id, product_id, variation_id, title, variant_label, image_path, unit_price, qty, line_total)
    select oid, l.product_id, l.variation_id, l.title, l.label, l.img, l.unit, l.qty, l.unit * l.qty from _lines l where l.seller_id = sel;
    result := result || jsonb_build_object('order_no', ono, 'shop', shop.shop_name, 'phone', case when shop.phone_public is not null then shop.phone_public end, 'total', sub + fee, 'ship', sm.name);
  end loop;

  -- remember the address on the customer's profile for next time
  insert into public.profiles (id) values (uid) on conflict (id) do nothing;
  update public.profiles set full_name = coalesce(nullif(full_name, ''), left(nm, 80)), phone = coalesce(nullif(phone, ''), ph) where id = uid;
  return result;
end; $$;

select 'bulk prices are used at checkout' as status;
