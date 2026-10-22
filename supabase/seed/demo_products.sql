-- RGBKart DEMO PRODUCTS, for study and testing. Made by supabase/seed/make_demo_sql.py from demo_spec.py.
-- Adds 3 demo sellers (2 shops + 1 one-time seller), one product for every sub-category (100 in all) with every kind of
-- listing: new / pre-owned / free give-away, free / Featured listing, on sale / flash sale, simple / with options
-- (size, colour, storage…), low stock / out of stock / pre-order / back-order, bulk prices, free delivery,
-- Dhaka-only delivery, no cash-on-delivery, a service, price negotiable. Photos are left out on purpose.
-- Also adds demo sections to the home page.
-- Run in Supabase → SQL Editor AFTER 0023_home_section_types.sql. Safe to run again: it first removes the old demo data.
-- To remove everything later, run demo_products_remove.sql.

begin;

-- helpers (only exist while this script runs)
create or replace function pg_temp.cat(p_name text) returns bigint language sql as $$
  select id from public.categories where name = p_name order by parent_id nulls first limit 1 $$;
create or replace function pg_temp.opt(p_attr text, p_value text) returns bigint language sql as $$
  select o.id from public.attribute_options o join public.attributes a on a.id = o.attribute_id
   where a.name = p_attr and o.value = p_value order by a.id limit 1 $$;
create or replace function pg_temp.attr(p_attr text) returns bigint language sql as $$
  select id from public.attributes where name = p_attr order by id limit 1 $$;
create or replace function pg_temp.ok(p_cat bigint, p_attr text) returns boolean language sql as $$
  select exists (select 1 from public.category_effective_attributes(p_cat) e where e.attribute_id = pg_temp.attr(p_attr)) $$;

-- 1. remove the old demo data (if this was run before) -----------------------------------------------------
delete from public.home_sections where subtitle like '%· demo';
delete from auth.users where id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002', 'd0000000-0000-4000-8000-000000000003');

-- 2. demo sellers ------------------------------------------------------------------------------------------
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change)
values ('00000000-0000-0000-0000-000000000000', 'd0000000-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'demo-gadget-house@rgbkart.test', '', now(),
  '{"provider":"email","providers":["email"]}', '{"full_name": "Demo Gadget House"}', now() - interval '200 days', now(), '', '', '', '');
insert into public.profiles (id, full_name) values ('d0000000-0000-4000-8000-000000000001', 'Demo Gadget House') on conflict (id) do nothing;
update public.profiles set role = 'seller', full_name = 'Demo Gadget House', phone = '01700000101', email_alerts = false where id = 'd0000000-0000-4000-8000-000000000001';
insert into public.seller_details (user_id, shop_name, shop_name_bn, shop_description, tagline, business_address, city, area, phone_public, whatsapp, email_public, status, allow_pickup, created_at)
values ('d0000000-0000-4000-8000-000000000001', 'Demo Gadget House', 'ডেমো গ্যাজেট হাউস', 'This is a demo shop made for testing RGBKart. Its products are not real.', 'Gadgets, computers and appliances with warranty (demo shop)', 'Shop 12, Multiplan Center, Elephant Road, Dhaka', 'Dhaka', 'Elephant Road',
  '01700000101', '01700000101', 'demo-gadget-house@rgbkart.test', 'approved', true, now() - interval '200 days');
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change)
values ('00000000-0000-0000-0000-000000000000', 'd0000000-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'demo-lifestyle-mart@rgbkart.test', '', now(),
  '{"provider":"email","providers":["email"]}', '{"full_name": "Demo Lifestyle Mart"}', now() - interval '200 days', now(), '', '', '', '');
insert into public.profiles (id, full_name) values ('d0000000-0000-4000-8000-000000000002', 'Demo Lifestyle Mart') on conflict (id) do nothing;
update public.profiles set role = 'seller', full_name = 'Demo Lifestyle Mart', phone = '01700000102', email_alerts = false where id = 'd0000000-0000-4000-8000-000000000002';
insert into public.seller_details (user_id, shop_name, shop_name_bn, shop_description, tagline, business_address, city, area, phone_public, whatsapp, email_public, status, allow_pickup, created_at)
values ('d0000000-0000-4000-8000-000000000002', 'Demo Lifestyle Mart', 'ডেমো লাইফস্টাইল মার্ট', 'This is a demo shop made for testing RGBKart. Its products are not real.', 'Fashion, home, grocery and more (demo shop)', 'House 5, Road 2, GEC Circle, Chattogram', 'Chattogram', 'GEC Circle',
  '01700000102', '01700000102', 'demo-lifestyle-mart@rgbkart.test', 'approved', false, now() - interval '200 days');
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change)
values ('00000000-0000-0000-0000-000000000000', 'd0000000-0000-4000-8000-000000000003', 'authenticated', 'authenticated', 'demo-one-time-seller@rgbkart.test', '', now(),
  '{"provider":"email","providers":["email"]}', '{"full_name": "Demo One-time Seller"}', now() - interval '200 days', now(), '', '', '', '');
insert into public.profiles (id, full_name) values ('d0000000-0000-4000-8000-000000000003', 'Demo One-time Seller') on conflict (id) do nothing;
update public.profiles set role = 'individual', full_name = 'Demo One-time Seller', phone = '01700000103', email_alerts = false where id = 'd0000000-0000-4000-8000-000000000003';
insert into public.seller_details (user_id, shop_name, shop_name_bn, shop_description, tagline, business_address, city, area, phone_public, whatsapp, email_public, status, allow_pickup, created_at)
values ('d0000000-0000-4000-8000-000000000003', 'Demo One-time Seller', null, null, null, null, 'Dhaka', 'Mirpur 10',
  '01700000103', '01700000103', 'demo-one-time-seller@rgbkart.test', 'approved', false, now() - interval '200 days');

-- 3. products ------------------------------------------------------------------------------------------------
do $$
declare pid bigint; vid bigint; c bigint; missing text := '';
begin
  perform set_config('rgbkart.staff_grant', 'on', true);
  -- 1. Smartphones: Samsung Galaxy A55 5G  [feat fragile sale variable]
  c := pg_temp.cat('Smartphones');
  if c is null then missing := missing || 'Smartphones' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Samsung Galaxy A55 5G', 'স্যামসাং গ্যালাক্সি A55 5G', '6.6" Super AMOLED 120 Hz display · 50 MP main camera with OIS · 5000 mAh battery, 25 W fast charging', 'Samsung Galaxy A55 5G

• 6.6" Super AMOLED 120 Hz display
• 50 MP main camera with OIS
• 5000 mAh battery, 25 W fast charging

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'অফিসিয়াল ওয়ারেন্টিসহ স্যামসাং গ্যালাক্সি A55 5G, ১২০ হার্টজ অ্যামোলেড ডিসপ্লে ও ৫০ মেগাপিক্সেল ক্যামেরা।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','smartphones','new','sale','featured']::text[], 47999, '40799', null, null, 'DEMO-001', true, 22, 3, 'no', 'in_stock', false, 0.4, 50, 35, 20, 'fragile', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '9 minutes', now() - interval '9 minutes') returning id into pid;
    if pg_temp.ok(c, 'Phone Brand') and pg_temp.opt('Phone Brand', 'Samsung') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Phone Brand'), pg_temp.opt('Phone Brand', 'Samsung')); end if;
    if pg_temp.ok(c, 'Network') and pg_temp.opt('Network', '5G') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Network'), pg_temp.opt('Network', '5G')); end if;
    if pg_temp.ok(c, 'SIM Type') and pg_temp.opt('SIM Type', 'Dual SIM') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('SIM Type'), pg_temp.opt('SIM Type', 'Dual SIM')); end if;
    if pg_temp.ok(c, 'Phone Screen Size') and pg_temp.opt('Phone Screen Size', '6.5–6.7 inch') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Phone Screen Size'), pg_temp.opt('Phone Screen Size', '6.5–6.7 inch')); end if;
    if pg_temp.ok(c, 'RAM') and pg_temp.opt('RAM', '8') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('RAM'), pg_temp.opt('RAM', '8')); end if;
    if pg_temp.ok(c, 'Battery Capacity') and pg_temp.opt('Battery Capacity', '5000–5999 mAh') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Battery Capacity'), pg_temp.opt('Battery Capacity', '5000–5999 mAh')); end if;
    if pg_temp.ok(c, 'Main Camera') and pg_temp.opt('Main Camera', '48–50 MP') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Main Camera'), pg_temp.opt('Main Camera', '48–50 MP')); end if;
    if pg_temp.ok(c, 'Operating System') and pg_temp.opt('Operating System', 'Android') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Operating System'), pg_temp.opt('Operating System', 'Android')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
    if pg_temp.ok(c, 'Warranty Type') and pg_temp.opt('Warranty Type', 'Brand Warranty') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty Type'), pg_temp.opt('Warranty Type', 'Brand Warranty')); end if;
    if pg_temp.opt('Storage', '128 GB') is not null and pg_temp.opt('Colour', 'Black') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Storage'), pg_temp.opt('Storage', '128 GB')), (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'))) t(a, o)), 'DEMO-001-1', 47999, 40799, 5, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Storage'), pg_temp.opt('Storage', '128 GB')), (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'));
    end if;
    if pg_temp.opt('Storage', '128 GB') is not null and pg_temp.opt('Colour', 'Blue') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Storage'), pg_temp.opt('Storage', '128 GB')), (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Blue'))) t(a, o)), 'DEMO-001-2', 47999, null, 8, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Storage'), pg_temp.opt('Storage', '128 GB')), (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Blue'));
    end if;
    if pg_temp.opt('Storage', '256 GB') is not null and pg_temp.opt('Colour', 'Black') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Storage'), pg_temp.opt('Storage', '256 GB')), (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'))) t(a, o)), 'DEMO-001-3', 52999, 45049, 11, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Storage'), pg_temp.opt('Storage', '256 GB')), (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'));
    end if;
    if pg_temp.opt('Storage', '256 GB') is not null and pg_temp.opt('Colour', 'Blue') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Storage'), pg_temp.opt('Storage', '256 GB')), (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Blue'))) t(a, o)), 'DEMO-001-4', 52999, null, 14, true, 30) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Storage'), pg_temp.opt('Storage', '256 GB')), (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Blue'));
    end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000001', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Smartphones' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 2. Feature Phones: Nokia 105 (2023) Dual SIM  [bulk same small]
  c := pg_temp.cat('Feature Phones');
  if c is null then missing := missing || 'Feature Phones' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Nokia 105 (2023) Dual SIM', 'নকিয়া ১০৫ (২০২৩) ডুয়াল সিম', 'Long-lasting 1000 mAh battery · Wireless FM radio and torch · Dual SIM, Bangla keypad', 'Nokia 105 (2023) Dual SIM

• Long-lasting 1000 mAh battery
• Wireless FM radio and torch
• Dual SIM, Bangla keypad

Delivery: Ships today. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'দীর্ঘ ব্যাটারি লাইফের নির্ভরযোগ্য বাটন ফোন, বাংলা কিপ্যাডসহ।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','feature','phones','new']::text[], 1850, null, null, null, 'DEMO-002', true, 29, 3, 'no', 'in_stock', false, 0.1, 12, 8, 4, 'small', 'same_day', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '18 minutes', now() - interval '18 minutes') returning id into pid;
    if pg_temp.ok(c, 'Phone Brand') and pg_temp.opt('Phone Brand', 'Nokia') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Phone Brand'), pg_temp.opt('Phone Brand', 'Nokia')); end if;
    if pg_temp.ok(c, 'SIM Type') and pg_temp.opt('SIM Type', 'Dual SIM') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('SIM Type'), pg_temp.opt('SIM Type', 'Dual SIM')); end if;
    if pg_temp.ok(c, 'Battery Capacity') and pg_temp.opt('Battery Capacity', '1000–2999 mAh') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Battery Capacity'), pg_temp.opt('Battery Capacity', '1000–2999 mAh')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
    insert into public.product_price_tiers (product_id, min_qty, unit_price) values (pid, 3, 1758), (pid, 10, 1665);
  exception when others then missing := missing || 'Feature Phones' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 3. Tablets: Xiaomi Redmi Pad SE 11"  [flash fragile variable]
  c := pg_temp.cat('Tablets');
  if c is null then missing := missing || 'Tablets' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Xiaomi Redmi Pad SE 11"', 'শাওমি রেডমি প্যাড SE ১১"', '11" FHD+ 90 Hz screen · Quad speakers with Dolby Atmos · 8000 mAh battery', 'Xiaomi Redmi Pad SE 11"

• 11" FHD+ 90 Hz screen
• Quad speakers with Dolby Atmos
• 8000 mAh battery

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'পড়াশোনা ও বিনোদনের জন্য বড় স্ক্রিনের ট্যাবলেট, চারটি স্পিকারসহ।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','tablets','new','sale']::text[], 21500, '18279', now() - interval '1 day', now() + interval '2 days', 'DEMO-003', true, 36, 3, 'no', 'in_stock', false, 0.5, 50, 35, 20, 'fragile', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '27 minutes', now() - interval '27 minutes') returning id into pid;
    if pg_temp.ok(c, 'Tablet Screen Size') and pg_temp.opt('Tablet Screen Size', '11–11.9 inch') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Tablet Screen Size'), pg_temp.opt('Tablet Screen Size', '11–11.9 inch')); end if;
    if pg_temp.ok(c, 'Network') and pg_temp.opt('Network', 'Wi-Fi only') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Network'), pg_temp.opt('Network', 'Wi-Fi only')); end if;
    if pg_temp.ok(c, 'Operating System') and pg_temp.opt('Operating System', 'Android') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Operating System'), pg_temp.opt('Operating System', 'Android')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
    if pg_temp.opt('Storage', '64 GB') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Storage'), pg_temp.opt('Storage', '64 GB'))) t(a, o)), 'DEMO-003-1', 21500, 18279, 7, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Storage'), pg_temp.opt('Storage', '64 GB'));
    end if;
    if pg_temp.opt('Storage', '128 GB') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Storage'), pg_temp.opt('Storage', '128 GB'))) t(a, o)), 'DEMO-003-2', 24000, null, 10, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Storage'), pg_temp.opt('Storage', '128 GB'));
    end if;
  exception when others then missing := missing || 'Tablets' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 4. Mobile Accessories: Baseus 20W USB-C Fast Charger  [bulk sale small variable]
  c := pg_temp.cat('Mobile Accessories');
  if c is null then missing := missing || 'Mobile Accessories' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Baseus 20W USB-C Fast Charger', 'বেসাস ২০ ওয়াট USB-C ফাস্ট চার্জার', '20 W Power Delivery fast charging · Works with iPhone and Android · Overheat and short-circuit protection', 'Baseus 20W USB-C Fast Charger

• 20 W Power Delivery fast charging
• Works with iPhone and Android
• Overheat and short-circuit protection

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'আইফোন ও অ্যান্ড্রয়েডের জন্য নিরাপদ ২০ ওয়াট ফাস্ট চার্জার।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','mobile','accessories','new','sale']::text[], 990, '840', null, null, 'DEMO-004', true, 43, 3, 'no', 'in_stock', false, 0.08, 12, 8, 4, 'small', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '36 minutes', now() - interval '36 minutes') returning id into pid;
    if pg_temp.ok(c, 'Mobile Accessory Type') and pg_temp.opt('Mobile Accessory Type', 'Charger / Adapter') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Mobile Accessory Type'), pg_temp.opt('Mobile Accessory Type', 'Charger / Adapter')); end if;
    if pg_temp.ok(c, 'Mobile Accessory Brand') and pg_temp.opt('Mobile Accessory Brand', 'Baseus') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Mobile Accessory Brand'), pg_temp.opt('Mobile Accessory Brand', 'Baseus')); end if;
    if pg_temp.ok(c, 'Charging Speed') and pg_temp.opt('Charging Speed', '20–25 W') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Charging Speed'), pg_temp.opt('Charging Speed', '20–25 W')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '6 Months') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '6 Months')); end if;
    if pg_temp.opt('Colour', 'White') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'White'))) t(a, o)), 'DEMO-004-1', 990, 840, 8, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'White'));
    end if;
    if pg_temp.opt('Colour', 'Black') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'))) t(a, o)), 'DEMO-004-2', 990, null, 11, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'));
    end if;
  exception when others then missing := missing || 'Mobile Accessories' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 5. Power Banks: Anker PowerCore Power Bank  [feat variable]
  c := pg_temp.cat('Power Banks');
  if c is null then missing := missing || 'Power Banks' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Anker PowerCore Power Bank', 'অ্যাঙ্কার পাওয়ারকোর পাওয়ার ব্যাংক', 'Charges a phone 2–4 times · Two USB outputs · Fast recharge by USB-C', 'Anker PowerCore Power Bank

• Charges a phone 2–4 times
• Two USB outputs
• Fast recharge by USB-C

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'ভ্রমণে নিশ্চিন্ত থাকতে নির্ভরযোগ্য অ্যাঙ্কার পাওয়ার ব্যাংক।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','power','banks','new','featured']::text[], 2450, null, null, null, 'DEMO-005', true, 50, 3, 'no', 'in_stock', false, 0.35, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '45 minutes', now() - interval '45 minutes') returning id into pid;
    if pg_temp.ok(c, 'Mobile Accessory Brand') and pg_temp.opt('Mobile Accessory Brand', 'Anker') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Mobile Accessory Brand'), pg_temp.opt('Mobile Accessory Brand', 'Anker')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
    if pg_temp.opt('Power Bank Capacity', '10000 mAh') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Power Bank Capacity'), pg_temp.opt('Power Bank Capacity', '10000 mAh'))) t(a, o)), 'DEMO-005-1', 2450, null, 9, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Power Bank Capacity'), pg_temp.opt('Power Bank Capacity', '10000 mAh'));
    end if;
    if pg_temp.opt('Power Bank Capacity', '20000 mAh') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Power Bank Capacity'), pg_temp.opt('Power Bank Capacity', '20000 mAh'))) t(a, o)), 'DEMO-005-2', 4050, null, 12, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Power Bank Capacity'), pg_temp.opt('Power Bank Capacity', '20000 mAh'));
    end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000001', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Power Banks' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 6. Smartwatches & Fitness Bands: Amazfit Bip 5 Smartwatch  [sale variable]
  c := pg_temp.cat('Smartwatches & Fitness Bands');
  if c is null then missing := missing || 'Smartwatches & Fitness Bands' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Amazfit Bip 5 Smartwatch', 'অ্যামাজফিট বিপ ৫ স্মার্টওয়াচ', '1.91" big display, Bluetooth calling · Heart rate, SpO2 and sleep tracking · Up to 10 days battery', 'Amazfit Bip 5 Smartwatch

• 1.91" big display, Bluetooth calling
• Heart rate, SpO2 and sleep tracking
• Up to 10 days battery

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'কল করা যায় এমন স্মার্টওয়াচ, স্বাস্থ্য ও ঘুমের হিসাব রাখে।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','smartwatches','fitness','bands','new','sale']::text[], 8900, '7559', null, null, 'DEMO-006', true, 17, 3, 'no', 'in_stock', false, 0.1, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '54 minutes', now() - interval '54 minutes') returning id into pid;
    if pg_temp.ok(c, 'Watch Brand') and pg_temp.opt('Watch Brand', 'Amazfit') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Watch Brand'), pg_temp.opt('Watch Brand', 'Amazfit')); end if;
    if pg_temp.ok(c, 'Watch Type') and pg_temp.opt('Watch Type', 'Smartwatch') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Watch Type'), pg_temp.opt('Watch Type', 'Smartwatch')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
    if pg_temp.opt('Colour', 'Black') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'))) t(a, o)), 'DEMO-006-1', 8900, 7559, 10, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'));
    end if;
    if pg_temp.opt('Colour', 'Pink') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Pink'))) t(a, o)), 'DEMO-006-2', 8900, null, 13, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Pink'));
    end if;
  exception when others then missing := missing || 'Smartwatches & Fitness Bands' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 7. Laptops: Lenovo IdeaPad Slim 3 Core i5  [feat fragile nocod ret15 variable]
  c := pg_temp.cat('Laptops');
  if c is null then missing := missing || 'Laptops' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Lenovo IdeaPad Slim 3 Core i5', 'লেনোভো আইডিয়াপ্যাড স্লিম ৩ কোর i5', '15.6" Full HD IPS screen · Intel Core i5 12th gen, 512 GB SSD · Backlit keyboard, Windows 11', 'Lenovo IdeaPad Slim 3 Core i5

• 15.6" Full HD IPS screen
• Intel Core i5 12th gen, 512 GB SSD
• Backlit keyboard, Windows 11

Delivery: Ships in 1–2 days. 15-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'অফিস ও পড়াশোনার জন্য হালকা ও দ্রুতগতির ল্যাপটপ। (এটি ক্যাশ অন ডেলিভারিতে পাওয়া যায় না।)

১৫ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','laptops','new','featured']::text[], 72500, null, null, null, 'DEMO-007', true, 24, 3, 'no', 'in_stock', false, 1.6, 50, 35, 20, 'fragile', '1_2_days', 'all_bangladesh', false, '15_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, false, false, null, null, false, null, 0, 'approved', now() - interval '63 minutes', now() - interval '63 minutes') returning id into pid;
    if pg_temp.ok(c, 'Computer Brand') and pg_temp.opt('Computer Brand', 'Lenovo') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Computer Brand'), pg_temp.opt('Computer Brand', 'Lenovo')); end if;
    if pg_temp.ok(c, 'Processor') and pg_temp.opt('Processor', 'Intel Core i5') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Processor'), pg_temp.opt('Processor', 'Intel Core i5')); end if;
    if pg_temp.ok(c, 'Storage Type') and pg_temp.opt('Storage Type', 'SSD (NVMe)') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Storage Type'), pg_temp.opt('Storage Type', 'SSD (NVMe)')); end if;
    if pg_temp.ok(c, 'Laptop Screen Size') and pg_temp.opt('Laptop Screen Size', '15.6 inch') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Laptop Screen Size'), pg_temp.opt('Laptop Screen Size', '15.6 inch')); end if;
    if pg_temp.ok(c, 'Graphics') and pg_temp.opt('Graphics', 'Integrated graphics') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Graphics'), pg_temp.opt('Graphics', 'Integrated graphics')); end if;
    if pg_temp.ok(c, 'Operating System') and pg_temp.opt('Operating System', 'Windows 11') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Operating System'), pg_temp.opt('Operating System', 'Windows 11')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '2 Years') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '2 Years')); end if;
    if pg_temp.ok(c, 'Warranty Type') and pg_temp.opt('Warranty Type', 'Brand Warranty') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty Type'), pg_temp.opt('Warranty Type', 'Brand Warranty')); end if;
    if pg_temp.opt('RAM', '8') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('RAM'), pg_temp.opt('RAM', '8'))) t(a, o)), 'DEMO-007-1', 72500, null, 11, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('RAM'), pg_temp.opt('RAM', '8'));
    end if;
    if pg_temp.opt('RAM', '16') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('RAM'), pg_temp.opt('RAM', '16'))) t(a, o)), 'DEMO-007-2', 78500, null, 14, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('RAM'), pg_temp.opt('RAM', '16'));
    end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000001', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Laptops' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 8. Desktops & All-in-One: Gaming PC Ryzen 5 + RTX 4060  [d35 heavy single]
  c := pg_temp.cat('Desktops & All-in-One');
  if c is null then missing := missing || 'Desktops & All-in-One' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Gaming PC Ryzen 5 + RTX 4060', 'গেমিং পিসি রাইজেন ৫ + RTX ৪০৬০', 'AMD Ryzen 5 7500F, 16 GB DDR5 · NVIDIA RTX 4060 8 GB graphics · 1 TB NVMe SSD, 650 W power supply', 'Gaming PC Ryzen 5 + RTX 4060

• AMD Ryzen 5 7500F, 16 GB DDR5
• NVIDIA RTX 4060 8 GB graphics
• 1 TB NVMe SSD, 650 W power supply

Delivery: Ships in 3–5 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'আমাদের টেকনিশিয়ানের তৈরি রেডি গেমিং পিসি, ১০৮০পি গেমিংয়ের জন্য।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','desktops','all-in-one','new']::text[], 118000, null, null, null, 'DEMO-008', true, 5, 3, 'no', 'in_stock', true, 12, 90, 70, 60, 'heavy', '3_5_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '72 minutes', now() - interval '72 minutes') returning id into pid;
    if pg_temp.ok(c, 'Computer Brand') and pg_temp.opt('Computer Brand', 'Other') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Computer Brand'), pg_temp.opt('Computer Brand', 'Other')); end if;
    if pg_temp.ok(c, 'Processor') and pg_temp.opt('Processor', 'AMD Ryzen 5') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Processor'), pg_temp.opt('Processor', 'AMD Ryzen 5')); end if;
    if pg_temp.ok(c, 'Graphics') and pg_temp.opt('Graphics', 'NVIDIA RTX 4060') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Graphics'), pg_temp.opt('Graphics', 'NVIDIA RTX 4060')); end if;
    if pg_temp.ok(c, 'RAM') and pg_temp.opt('RAM', '16') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('RAM'), pg_temp.opt('RAM', '16')); end if;
    if pg_temp.ok(c, 'Storage') and pg_temp.opt('Storage', '1 TB') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Storage'), pg_temp.opt('Storage', '1 TB')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '3 Years') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '3 Years')); end if;
    if pg_temp.ok(c, 'Warranty Type') and pg_temp.opt('Warranty Type', 'Seller Warranty') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty Type'), pg_temp.opt('Warranty Type', 'Seller Warranty')); end if;
  exception when others then missing := missing || 'Desktops & All-in-One' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 9. Monitors: Xiaomi 27" 2K 165Hz Gaming Monitor  [fragile sale]
  c := pg_temp.cat('Monitors');
  if c is null then missing := missing || 'Monitors' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Xiaomi 27" 2K 165Hz Gaming Monitor', 'শাওমি ২৭" ২কে ১৬৫ হার্টজ গেমিং মনিটর', '27" QHD Fast IPS panel · 165 Hz, 1 ms response · HDR10, height-adjustable stand', 'Xiaomi 27" 2K 165Hz Gaming Monitor

• 27" QHD Fast IPS panel
• 165 Hz, 1 ms response
• HDR10, height-adjustable stand

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'গেমিং ও ডিজাইনের জন্য দ্রুতগতির ২কে মনিটর।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','monitors','new','sale']::text[], 28900, '24559', null, null, 'DEMO-009', true, 38, 3, 'no', 'in_stock', false, 6, 50, 35, 20, 'fragile', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '81 minutes', now() - interval '81 minutes') returning id into pid;
    if pg_temp.ok(c, 'Computer Brand') and pg_temp.opt('Computer Brand', 'Xiaomi') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Computer Brand'), pg_temp.opt('Computer Brand', 'Xiaomi')); end if;
    if pg_temp.ok(c, 'Monitor Size') and pg_temp.opt('Monitor Size', '25–27 inch') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Monitor Size'), pg_temp.opt('Monitor Size', '25–27 inch')); end if;
    if pg_temp.ok(c, 'Display Resolution') and pg_temp.opt('Display Resolution', '2K / QHD (2560×1440)') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Display Resolution'), pg_temp.opt('Display Resolution', '2K / QHD (2560×1440)')); end if;
    if pg_temp.ok(c, 'Refresh Rate') and pg_temp.opt('Refresh Rate', '165 Hz') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Refresh Rate'), pg_temp.opt('Refresh Rate', '165 Hz')); end if;
    if pg_temp.ok(c, 'Panel Type') and pg_temp.opt('Panel Type', 'IPS') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Panel Type'), pg_temp.opt('Panel Type', 'IPS')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '3 Years') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '3 Years')); end if;
  exception when others then missing := missing || 'Monitors' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 10. PC Components: Kingston NV2 1TB NVMe SSD  [low small]
  c := pg_temp.cat('PC Components');
  if c is null then missing := missing || 'PC Components' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Kingston NV2 1TB NVMe SSD', 'কিংস্টন NV2 ১টিবি NVMe এসএসডি', 'Up to 3500 MB/s read speed · M.2 2280 PCIe 4.0 · 3 years warranty', 'Kingston NV2 1TB NVMe SSD

• Up to 3500 MB/s read speed
• M.2 2280 PCIe 4.0
• 3 years warranty

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'পিসি ও ল্যাপটপ দ্রুত করতে ১ টিবি NVMe এসএসডি।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','components','new']::text[], 7200, null, null, null, 'DEMO-010', true, 2, 5, 'no', 'in_stock', false, 0.05, 12, 8, 4, 'small', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '90 minutes', now() - interval '90 minutes') returning id into pid;
    if pg_temp.ok(c, 'PC Component Type') and pg_temp.opt('PC Component Type', 'SSD') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('PC Component Type'), pg_temp.opt('PC Component Type', 'SSD')); end if;
    if pg_temp.ok(c, 'Computer Brand') and pg_temp.opt('Computer Brand', 'Kingston') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Computer Brand'), pg_temp.opt('Computer Brand', 'Kingston')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '3 Years') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '3 Years')); end if;
  exception when others then missing := missing || 'PC Components' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 11. Printers & Scanners: Epson L3250 Ink Tank Wi-Fi Printer  [freedel large]
  c := pg_temp.cat('Printers & Scanners');
  if c is null then missing := missing || 'Printers & Scanners' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Epson L3250 Ink Tank Wi-Fi Printer', 'এপসন L3250 ইঙ্ক ট্যাঙ্ক ওয়াই-ফাই প্রিন্টার', 'Print, scan and copy · Wi-Fi printing from phone · Very low cost per page', 'Epson L3250 Ink Tank Wi-Fi Printer

• Print, scan and copy
• Wi-Fi printing from phone
• Very low cost per page

Delivery: Ships in 1–2 days. 7-day returns. Free delivery.

(Demo product for testing RGBKart. The photos will be added later.)', 'ঘর ও ছোট অফিসের জন্য কম খরচের রঙিন প্রিন্টার।

৭ দিনের মধ্যে ফেরত। ফ্রি ডেলিভারি।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','printers','scanners','new']::text[], 17500, null, null, null, 'DEMO-011', true, 52, 3, 'no', 'in_stock', false, 4.5, 60, 45, 35, 'large', '1_2_days', 'all_bangladesh', true, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '99 minutes', now() - interval '99 minutes') returning id into pid;
    if pg_temp.ok(c, 'Printer Type') and pg_temp.opt('Printer Type', 'Ink Tank') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Printer Type'), pg_temp.opt('Printer Type', 'Ink Tank')); end if;
    if pg_temp.ok(c, 'Computer Brand') and pg_temp.opt('Computer Brand', 'Epson') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Computer Brand'), pg_temp.opt('Computer Brand', 'Epson')); end if;
    if pg_temp.ok(c, 'Connectivity') and pg_temp.opt('Connectivity', 'Wi-Fi') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Connectivity'), pg_temp.opt('Connectivity', 'Wi-Fi')); end if;
    if pg_temp.ok(c, 'Connectivity') and pg_temp.opt('Connectivity', 'Wired (USB)') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Connectivity'), pg_temp.opt('Connectivity', 'Wired (USB)')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
  exception when others then missing := missing || 'Printers & Scanners' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 12. Gaming Keyboards: Redragon K552 Kumara Mechanical Keyboard  [feat sale variable]
  c := pg_temp.cat('Gaming Keyboards');
  if c is null then missing := missing || 'Gaming Keyboards' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Redragon K552 Kumara Mechanical Keyboard', 'রেডড্রাগন K552 কুমারা মেকানিক্যাল কিবোর্ড', 'Mechanical switches, TKL size · Red backlight · Metal top plate', 'Redragon K552 Kumara Mechanical Keyboard

• Mechanical switches, TKL size
• Red backlight
• Metal top plate

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'টেকসই মেকানিক্যাল গেমিং কিবোর্ড, লাল ব্যাকলাইটসহ।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','gaming','keyboards','new','sale','featured']::text[], 3450, '2929', null, null, 'DEMO-012', true, 19, 3, 'no', 'in_stock', false, 0.9, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '108 minutes', now() - interval '108 minutes') returning id into pid;
    if pg_temp.ok(c, 'Gaming Brand') and pg_temp.opt('Gaming Brand', 'Redragon') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Gaming Brand'), pg_temp.opt('Gaming Brand', 'Redragon')); end if;
    if pg_temp.ok(c, 'Keyboard Size') and pg_temp.opt('Keyboard Size', 'TKL (80%)') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Keyboard Size'), pg_temp.opt('Keyboard Size', 'TKL (80%)')); end if;
    if pg_temp.ok(c, 'RGB Lighting') and pg_temp.opt('RGB Lighting', 'Single colour') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('RGB Lighting'), pg_temp.opt('RGB Lighting', 'Single colour')); end if;
    if pg_temp.ok(c, 'Connectivity') and pg_temp.opt('Connectivity', 'Wired (USB)') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Connectivity'), pg_temp.opt('Connectivity', 'Wired (USB)')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
    if pg_temp.opt('Switch Type', 'Mechanical – Red (linear)') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Switch Type'), pg_temp.opt('Switch Type', 'Mechanical – Red (linear)'))) t(a, o)), 'DEMO-012-1', 3450, 2929, 16, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Switch Type'), pg_temp.opt('Switch Type', 'Mechanical – Red (linear)'));
    end if;
    if pg_temp.opt('Switch Type', 'Mechanical – Blue (clicky)') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Switch Type'), pg_temp.opt('Switch Type', 'Mechanical – Blue (clicky)'))) t(a, o)), 'DEMO-012-2', 3450, null, 19, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Switch Type'), pg_temp.opt('Switch Type', 'Mechanical – Blue (clicky)'));
    end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000001', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Gaming Keyboards' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 13. Gaming Mice: Logitech G102 Lightsync Gaming Mouse  [bulk small variable]
  c := pg_temp.cat('Gaming Mice');
  if c is null then missing := missing || 'Gaming Mice' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Logitech G102 Lightsync Gaming Mouse', 'লজিটেক G102 লাইটসিঙ্ক গেমিং মাউস', '8000 DPI sensor · RGB lighting · 6 programmable buttons', 'Logitech G102 Lightsync Gaming Mouse

• 8000 DPI sensor
• RGB lighting
• 6 programmable buttons

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'জনপ্রিয় লজিটেক গেমিং মাউস, আরজিবি লাইটসহ।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','gaming','mice','new']::text[], 1950, null, null, null, 'DEMO-013', true, 26, 3, 'no', 'in_stock', false, 0.1, 12, 8, 4, 'small', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '117 minutes', now() - interval '117 minutes') returning id into pid;
    if pg_temp.ok(c, 'Gaming Brand') and pg_temp.opt('Gaming Brand', 'Logitech') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Gaming Brand'), pg_temp.opt('Gaming Brand', 'Logitech')); end if;
    if pg_temp.ok(c, 'Mouse DPI') and pg_temp.opt('Mouse DPI', '3200–8000 DPI') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Mouse DPI'), pg_temp.opt('Mouse DPI', '3200–8000 DPI')); end if;
    if pg_temp.ok(c, 'RGB Lighting') and pg_temp.opt('RGB Lighting', 'RGB') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('RGB Lighting'), pg_temp.opt('RGB Lighting', 'RGB')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
    if pg_temp.opt('Colour', 'Black') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'))) t(a, o)), 'DEMO-013-1', 1950, null, 17, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'));
    end if;
    if pg_temp.opt('Colour', 'White') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'White'))) t(a, o)), 'DEMO-013-2', 1950, null, 20, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'White'));
    end if;
  exception when others then missing := missing || 'Gaming Mice' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 14. Gaming Headsets: HyperX Cloud Stinger 2 Headset  [backorder oos]
  c := pg_temp.cat('Gaming Headsets');
  if c is null then missing := missing || 'Gaming Headsets' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'HyperX Cloud Stinger 2 Headset', 'হাইপারএক্স ক্লাউড স্টিঙ্গার ২ হেডসেট', '50 mm drivers, DTS spatial audio · Swivel-to-mute microphone · Light and comfortable', 'HyperX Cloud Stinger 2 Headset

• 50 mm drivers, DTS spatial audio
• Swivel-to-mute microphone
• Light and comfortable

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'লম্বা সময় গেম খেলার জন্য আরামদায়ক হেডসেট। (স্টক শেষ, তবে অর্ডার নেওয়া হচ্ছে)

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','gaming','headsets','new']::text[], 4800, null, null, null, 'DEMO-014', true, 0, 3, 'yes', 'in_stock', false, 0.3, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '126 minutes', now() - interval '126 minutes') returning id into pid;
    if pg_temp.ok(c, 'Gaming Brand') and pg_temp.opt('Gaming Brand', 'HyperX') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Gaming Brand'), pg_temp.opt('Gaming Brand', 'HyperX')); end if;
    if pg_temp.ok(c, 'Gaming Platform') and pg_temp.opt('Gaming Platform', 'PC') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Gaming Platform'), pg_temp.opt('Gaming Platform', 'PC')); end if;
    if pg_temp.ok(c, 'Gaming Platform') and pg_temp.opt('Gaming Platform', 'PlayStation 5') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Gaming Platform'), pg_temp.opt('Gaming Platform', 'PlayStation 5')); end if;
    if pg_temp.ok(c, 'Gaming Platform') and pg_temp.opt('Gaming Platform', 'Mobile') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Gaming Platform'), pg_temp.opt('Gaming Platform', 'Mobile')); end if;
    if pg_temp.ok(c, 'Connectivity') and pg_temp.opt('Connectivity', '3.5 mm Jack') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Connectivity'), pg_temp.opt('Connectivity', '3.5 mm Jack')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '2 Years') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '2 Years')); end if;
  exception when others then missing := missing || 'Gaming Headsets' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 15. Consoles & Controllers: Used PlayStation 4 Slim 1TB with 2 controllers  [neg used]
  c := pg_temp.cat('Consoles & Controllers');
  if c is null then missing := missing || 'Consoles & Controllers' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000003', c, 'Used PlayStation 4 Slim 1TB with 2 controllers', 'ব্যবহৃত প্লেস্টেশন ৪ স্লিম ১টিবি, ২টি কন্ট্রোলারসহ', 'Used 2 years, works perfectly · Two original controllers · 3 games included', 'Used PlayStation 4 Slim 1TB with 2 controllers

• Used 2 years, works perfectly
• Two original controllers
• 3 games included

Delivery: Ships in 1–2 days. 7-day returns.
Price is negotiable, message or call the seller.

(Demo product for testing RGBKart. The photos will be added later.)', 'দুই বছর ব্যবহৃত প্লেস্টেশন ৪, পুরোপুরি সচল, দুইটি কন্ট্রোলার ও ৩টি গেমসহ।

৭ দিনের মধ্যে ফেরত। দাম আলোচনা সাপেক্ষে।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','consoles','controllers','used']::text[], 26000, null, null, null, 'DEMO-015', true, 1, 3, 'no', 'in_stock', false, 3, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', null, 'pre_owned', 'simple', true, true, false, null, null, false, null, 0, 'approved', now() - interval '135 minutes', now() - interval '135 minutes') returning id into pid;
    if pg_temp.ok(c, 'Gaming Brand') and pg_temp.opt('Gaming Brand', 'Sony PlayStation') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Gaming Brand'), pg_temp.opt('Gaming Brand', 'Sony PlayStation')); end if;
    if pg_temp.ok(c, 'Condition') and pg_temp.opt('Condition', 'Used – Good') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Condition'), pg_temp.opt('Condition', 'Used – Good')); end if;
  exception when others then missing := missing || 'Consoles & Controllers' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 16. RGB Lights & Fans: ARGB Case Fan 120mm (3-pack)  [flash]
  c := pg_temp.cat('RGB Lights & Fans');
  if c is null then missing := missing || 'RGB Lights & Fans' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'ARGB Case Fan 120mm (3-pack)', 'এআরজিবি কেস ফ্যান ১২০ মিমি (৩টির প্যাক)', 'Addressable RGB, syncs with motherboard · Quiet hydraulic bearing · Includes controller and remote', 'ARGB Case Fan 120mm (3-pack)

• Addressable RGB, syncs with motherboard
• Quiet hydraulic bearing
• Includes controller and remote

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'পিসি কেস সাজাতে রঙিন ও নীরব ফ্যান, রিমোটসহ।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','rgb','lights','fans','new','sale']::text[], 2650, '2249', now() - interval '1 day', now() + interval '2 days', 'DEMO-016', true, 47, 3, 'no', 'in_stock', false, 0.6, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '144 minutes', now() - interval '144 minutes') returning id into pid;
    if pg_temp.ok(c, 'Fan Size') and pg_temp.opt('Fan Size', '120 mm') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fan Size'), pg_temp.opt('Fan Size', '120 mm')); end if;
    if pg_temp.ok(c, 'RGB Lighting') and pg_temp.opt('RGB Lighting', 'ARGB (addressable)') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('RGB Lighting'), pg_temp.opt('RGB Lighting', 'ARGB (addressable)')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '6 Months') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '6 Months')); end if;
  exception when others then missing := missing || 'RGB Lights & Fans' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 17. Televisions: Walton 43" 4K Google TV  [d35 feat fragile]
  c := pg_temp.cat('Televisions');
  if c is null then missing := missing || 'Televisions' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Walton 43" 4K Google TV', 'ওয়ালটন ৪৩" ৪কে গুগল টিভি', '43" 4K UHD with HDR · Google TV with YouTube and Netflix · Voice remote', 'Walton 43" 4K Google TV

• 43" 4K UHD with HDR
• Google TV with YouTube and Netflix
• Voice remote

Delivery: Ships in 3–5 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'দেশীয় ব্র্যান্ডের ৪কে স্মার্ট টিভি, গুগল টিভিসহ।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','televisions','new','featured']::text[], 42900, null, null, null, 'DEMO-017', true, 54, 3, 'no', 'in_stock', false, 9, 50, 35, 20, 'fragile', '3_5_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '153 minutes', now() - interval '153 minutes') returning id into pid;
    if pg_temp.ok(c, 'Appliance Brand') and pg_temp.opt('Appliance Brand', 'Walton') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Appliance Brand'), pg_temp.opt('Appliance Brand', 'Walton')); end if;
    if pg_temp.ok(c, 'TV Screen Size') and pg_temp.opt('TV Screen Size', '40–43 inch') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('TV Screen Size'), pg_temp.opt('TV Screen Size', '40–43 inch')); end if;
    if pg_temp.ok(c, 'Display Resolution') and pg_temp.opt('Display Resolution', '4K UHD (3840×2160)') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Display Resolution'), pg_temp.opt('Display Resolution', '4K UHD (3840×2160)')); end if;
    if pg_temp.ok(c, 'Operating System') and pg_temp.opt('Operating System', 'Google TV') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Operating System'), pg_temp.opt('Operating System', 'Google TV')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '3 Years') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '3 Years')); end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000001', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Televisions' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 18. Headphones & Earbuds: QCY T13 ANC True Wireless Earbuds  [sale small variable]
  c := pg_temp.cat('Headphones & Earbuds');
  if c is null then missing := missing || 'Headphones & Earbuds' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'QCY T13 ANC True Wireless Earbuds', 'কিউসিওয়াই T13 ANC ট্রু ওয়্যারলেস ইয়ারবাডস', 'Active noise cancellation · 30 hours with case · Low-latency game mode', 'QCY T13 ANC True Wireless Earbuds

• Active noise cancellation
• 30 hours with case
• Low-latency game mode

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'নয়েজ ক্যানসেলেশনসহ সাশ্রয়ী ইয়ারবাডস।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','headphones','earbuds','new','sale']::text[], 2200, '1869', null, null, 'DEMO-018', true, 21, 3, 'no', 'in_stock', false, 0.08, 12, 8, 4, 'small', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '162 minutes', now() - interval '162 minutes') returning id into pid;
    if pg_temp.ok(c, 'Audio Brand') and pg_temp.opt('Audio Brand', 'QCY') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Audio Brand'), pg_temp.opt('Audio Brand', 'QCY')); end if;
    if pg_temp.ok(c, 'Headphone Type') and pg_temp.opt('Headphone Type', 'True Wireless (TWS)') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Headphone Type'), pg_temp.opt('Headphone Type', 'True Wireless (TWS)')); end if;
    if pg_temp.ok(c, 'Noise Cancellation') and pg_temp.opt('Noise Cancellation', 'ANC') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Noise Cancellation'), pg_temp.opt('Noise Cancellation', 'ANC')); end if;
    if pg_temp.ok(c, 'Connectivity') and pg_temp.opt('Connectivity', 'Bluetooth') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Connectivity'), pg_temp.opt('Connectivity', 'Bluetooth')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '6 Months') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '6 Months')); end if;
    if pg_temp.opt('Colour', 'Black') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'))) t(a, o)), 'DEMO-018-1', 2200, 1869, 4, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'));
    end if;
    if pg_temp.opt('Colour', 'White') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'White'))) t(a, o)), 'DEMO-018-2', 2200, null, 7, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'White'));
    end if;
  exception when others then missing := missing || 'Headphones & Earbuds' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 19. Bluetooth Speakers: JBL Flip 6 Portable Speaker  [freedel]
  c := pg_temp.cat('Bluetooth Speakers');
  if c is null then missing := missing || 'Bluetooth Speakers' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'JBL Flip 6 Portable Speaker', 'জেবিএল ফ্লিপ ৬ পোর্টেবল স্পিকার', 'Powerful JBL sound · IP67 waterproof and dustproof · 12 hours playtime', 'JBL Flip 6 Portable Speaker

• Powerful JBL sound
• IP67 waterproof and dustproof
• 12 hours playtime

Delivery: Ships in 1–2 days. 7-day returns. Free delivery.

(Demo product for testing RGBKart. The photos will be added later.)', 'পানিরোধী শক্তিশালী পোর্টেবল স্পিকার।

৭ দিনের মধ্যে ফেরত। ফ্রি ডেলিভারি।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','bluetooth','speakers','new']::text[], 13500, null, null, null, 'DEMO-019', true, 28, 3, 'no', 'in_stock', false, 0.55, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', true, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '171 minutes', now() - interval '171 minutes') returning id into pid;
    if pg_temp.ok(c, 'Audio Brand') and pg_temp.opt('Audio Brand', 'JBL') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Audio Brand'), pg_temp.opt('Audio Brand', 'JBL')); end if;
    if pg_temp.ok(c, 'IP Rating') and pg_temp.opt('IP Rating', 'IP67 (dust + water)') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('IP Rating'), pg_temp.opt('IP Rating', 'IP67 (dust + water)')); end if;
    if pg_temp.ok(c, 'Connectivity') and pg_temp.opt('Connectivity', 'Bluetooth') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Connectivity'), pg_temp.opt('Connectivity', 'Bluetooth')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
  exception when others then missing := missing || 'Bluetooth Speakers' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 20. Soundbars & Home Theater: Sony HT-S20R 5.1 Soundbar  [large preorder]
  c := pg_temp.cat('Soundbars & Home Theater');
  if c is null then missing := missing || 'Soundbars & Home Theater' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Sony HT-S20R 5.1 Soundbar', 'সনি HT-S20R ৫.১ সাউন্ডবার', 'Real 5.1 surround with subwoofer · 400 W total power · HDMI ARC and Bluetooth', 'Sony HT-S20R 5.1 Soundbar

• Real 5.1 surround with subwoofer
• 400 W total power
• HDMI ARC and Bluetooth

Delivery: Pre-order: ships when stock arrives. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'ঘরে সিনেমার মতো শব্দ, ৫.১ চ্যানেল সাউন্ডবার। (প্রি-অর্ডার)

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','soundbars','home','theater','new']::text[], 26500, null, null, null, 'DEMO-020', true, 35, 3, 'no', 'in_stock', false, 7, 60, 45, 35, 'large', 'pre_order', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, true, now() + interval '20 days', 30, 'approved', now() - interval '180 minutes', now() - interval '180 minutes') returning id into pid;
    if pg_temp.ok(c, 'Audio Brand') and pg_temp.opt('Audio Brand', 'Sony') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Audio Brand'), pg_temp.opt('Audio Brand', 'Sony')); end if;
    if pg_temp.ok(c, 'Speaker Channels') and pg_temp.opt('Speaker Channels', '5.1') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Speaker Channels'), pg_temp.opt('Speaker Channels', '5.1')); end if;
    if pg_temp.ok(c, 'Connectivity') and pg_temp.opt('Connectivity', 'HDMI') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Connectivity'), pg_temp.opt('Connectivity', 'HDMI')); end if;
    if pg_temp.ok(c, 'Connectivity') and pg_temp.opt('Connectivity', 'Bluetooth') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Connectivity'), pg_temp.opt('Connectivity', 'Bluetooth')); end if;
    if pg_temp.ok(c, 'Connectivity') and pg_temp.opt('Connectivity', 'Optical') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Connectivity'), pg_temp.opt('Connectivity', 'Optical')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
  exception when others then missing := missing || 'Soundbars & Home Theater' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 21. Projectors & Streaming Devices: Xiaomi TV Box S (2nd Gen) 4K  [low]
  c := pg_temp.cat('Projectors & Streaming Devices');
  if c is null then missing := missing || 'Projectors & Streaming Devices' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Xiaomi TV Box S (2nd Gen) 4K', 'শাওমি টিভি বক্স S (২য় জেনারেশন) ৪কে', 'Makes any TV a smart TV · 4K HDR with Google TV · Chromecast built in', 'Xiaomi TV Box S (2nd Gen) 4K

• Makes any TV a smart TV
• 4K HDR with Google TV
• Chromecast built in

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'যেকোনো টিভিকে স্মার্ট টিভি বানায়।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','projectors','streaming','devices','new']::text[], 7400, null, null, null, 'DEMO-021', true, 2, 5, 'no', 'in_stock', false, 0.3, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '189 minutes', now() - interval '189 minutes') returning id into pid;
    if pg_temp.ok(c, 'Operating System') and pg_temp.opt('Operating System', 'Google TV') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Operating System'), pg_temp.opt('Operating System', 'Google TV')); end if;
    if pg_temp.ok(c, 'Connectivity') and pg_temp.opt('Connectivity', 'HDMI') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Connectivity'), pg_temp.opt('Connectivity', 'HDMI')); end if;
    if pg_temp.ok(c, 'Connectivity') and pg_temp.opt('Connectivity', 'Wi-Fi') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Connectivity'), pg_temp.opt('Connectivity', 'Wi-Fi')); end if;
    if pg_temp.ok(c, 'Connectivity') and pg_temp.opt('Connectivity', 'Bluetooth') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Connectivity'), pg_temp.opt('Connectivity', 'Bluetooth')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
  exception when others then missing := missing || 'Projectors & Streaming Devices' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 22. Digital Cameras: Used Canon EOS 200D with 18-55 lens  [feat neg used]
  c := pg_temp.cat('Digital Cameras');
  if c is null then missing := missing || 'Digital Cameras' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000003', c, 'Used Canon EOS 200D with 18-55 lens', 'ব্যবহৃত ক্যানন EOS 200D, ১৮-৫৫ লেন্সসহ', 'Around 8,000 shutter count · Kit lens 18-55 mm · Bag, charger and 32 GB card included', 'Used Canon EOS 200D with 18-55 lens

• Around 8,000 shutter count
• Kit lens 18-55 mm
• Bag, charger and 32 GB card included

Delivery: Ships in 1–2 days. 7-day returns.
Price is negotiable, message or call the seller.

(Demo product for testing RGBKart. The photos will be added later.)', 'খুব যত্নে ব্যবহৃত ক্যানন ডিএসএলআর, লেন্স, ব্যাগ ও মেমোরি কার্ডসহ।

৭ দিনের মধ্যে ফেরত। দাম আলোচনা সাপেক্ষে।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','digital','cameras','used','featured']::text[], 42000, null, null, null, 'DEMO-022', true, 1, 3, 'no', 'in_stock', false, 1, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', null, 'pre_owned', 'simple', true, true, false, null, null, false, null, 0, 'approved', now() - interval '198 minutes', now() - interval '198 minutes') returning id into pid;
    if pg_temp.ok(c, 'Camera Brand') and pg_temp.opt('Camera Brand', 'Canon') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Camera Brand'), pg_temp.opt('Camera Brand', 'Canon')); end if;
    if pg_temp.ok(c, 'Camera Type') and pg_temp.opt('Camera Type', 'DSLR') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Camera Type'), pg_temp.opt('Camera Type', 'DSLR')); end if;
    if pg_temp.ok(c, 'Megapixels') and pg_temp.opt('Megapixels', '24–33 MP') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Megapixels'), pg_temp.opt('Megapixels', '24–33 MP')); end if;
    if pg_temp.ok(c, 'Condition') and pg_temp.opt('Condition', 'Used – Like New') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Condition'), pg_temp.opt('Condition', 'Used – Like New')); end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000003', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Digital Cameras' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 23. Action Cameras: GoPro HERO12 Black  [nocod]
  c := pg_temp.cat('Action Cameras');
  if c is null then missing := missing || 'Action Cameras' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'GoPro HERO12 Black', 'গোপ্রো হিরো১২ ব্ল্যাক', '5.3K video, HDR photos · Waterproof to 10 m · HyperSmooth stabilisation', 'GoPro HERO12 Black

• 5.3K video, HDR photos
• Waterproof to 10 m
• HyperSmooth stabilisation

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'অ্যাডভেঞ্চার ও ভ্লগিংয়ের জন্য গোপ্রো অ্যাকশন ক্যামেরা।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','action','cameras','new']::text[], 52000, null, null, null, 'DEMO-023', true, 16, 3, 'no', 'in_stock', false, 0.2, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, false, false, null, null, false, null, 0, 'approved', now() - interval '207 minutes', now() - interval '207 minutes') returning id into pid;
    if pg_temp.ok(c, 'Camera Brand') and pg_temp.opt('Camera Brand', 'GoPro') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Camera Brand'), pg_temp.opt('Camera Brand', 'GoPro')); end if;
    if pg_temp.ok(c, 'Video Resolution') and pg_temp.opt('Video Resolution', '5K–6K') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Video Resolution'), pg_temp.opt('Video Resolution', '5K–6K')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
  exception when others then missing := missing || 'Action Cameras' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 24. Camera Lenses: Canon EF 50mm f/1.8 STM Lens  [sale used]
  c := pg_temp.cat('Camera Lenses');
  if c is null then missing := missing || 'Camera Lenses' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Canon EF 50mm f/1.8 STM Lens', 'ক্যানন EF ৫০ মিমি f/1.8 STM লেন্স', 'Sharp portrait lens · Quiet STM focus motor · Used, no scratches', 'Canon EF 50mm f/1.8 STM Lens

• Sharp portrait lens
• Quiet STM focus motor
• Used, no scratches

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'পোর্ট্রেটের জন্য জনপ্রিয় ৫০ মিমি লেন্স, ব্যবহৃত কিন্তু দাগহীন।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','camera','lenses','used','sale']::text[], 14500, '12319', null, null, 'DEMO-024', true, 23, 3, 'no', 'in_stock', false, 0.2, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Check the item when it arrives. Call the shop if anything is wrong.', 'pre_owned', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '216 minutes', now() - interval '216 minutes') returning id into pid;
    if pg_temp.ok(c, 'Camera Brand') and pg_temp.opt('Camera Brand', 'Canon') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Camera Brand'), pg_temp.opt('Camera Brand', 'Canon')); end if;
    if pg_temp.ok(c, 'Lens Mount') and pg_temp.opt('Lens Mount', 'Canon EF / EF-S') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Lens Mount'), pg_temp.opt('Lens Mount', 'Canon EF / EF-S')); end if;
    if pg_temp.ok(c, 'Lens Type') and pg_temp.opt('Lens Type', 'Prime') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Lens Type'), pg_temp.opt('Lens Type', 'Prime')); end if;
    if pg_temp.ok(c, 'Condition') and pg_temp.opt('Condition', 'Used – Like New') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Condition'), pg_temp.opt('Condition', 'Used – Like New')); end if;
  exception when others then missing := missing || 'Camera Lenses' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 25. Drones: DJI Mini 3 Drone  [feat1 fragile single]
  c := pg_temp.cat('Drones');
  if c is null then missing := missing || 'Drones' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'DJI Mini 3 Drone', 'ডিজেআই মিনি ৩ ড্রোন', 'Under 249 g, 4K HDR video · 38 minutes flight time · True vertical shooting', 'DJI Mini 3 Drone

• Under 249 g, 4K HDR video
• 38 minutes flight time
• True vertical shooting

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'ছোট ও হালকা ৪কে ড্রোন, দীর্ঘ সময় উড়তে পারে।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','drones','new','featured']::text[], 68000, null, null, null, 'DEMO-025', true, 5, 3, 'no', 'in_stock', true, 0.4, 50, 35, 20, 'fragile', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '225 minutes', now() - interval '225 minutes') returning id into pid;
    if pg_temp.ok(c, 'Camera Brand') and pg_temp.opt('Camera Brand', 'DJI') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Camera Brand'), pg_temp.opt('Camera Brand', 'DJI')); end if;
    if pg_temp.ok(c, 'Flight Time') and pg_temp.opt('Flight Time', 'Over 35 minutes') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Flight Time'), pg_temp.opt('Flight Time', 'Over 35 minutes')); end if;
    if pg_temp.ok(c, 'Video Resolution') and pg_temp.opt('Video Resolution', '4K') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Video Resolution'), pg_temp.opt('Video Resolution', '4K')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '6 Months') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '6 Months')); end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000001', 'home_and_category', 30, 0, 'active', now() - interval '29 days', now() + interval '1 day', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Drones' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 26. Security Cameras (CCTV): Imou Ranger 2 Wi-Fi Indoor Camera  [bulk]
  c := pg_temp.cat('Security Cameras (CCTV)');
  if c is null then missing := missing || 'Security Cameras (CCTV)' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Imou Ranger 2 Wi-Fi Indoor Camera', 'ইমু রেঞ্জার ২ ওয়াই-ফাই ইনডোর ক্যামেরা', '360° pan and tilt · Night vision, two-way talk · Watch live on your phone', 'Imou Ranger 2 Wi-Fi Indoor Camera

• 360° pan and tilt
• Night vision, two-way talk
• Watch live on your phone

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'বাসা ও দোকানের নিরাপত্তায় ৩৬০ ডিগ্রি ওয়াই-ফাই ক্যামেরা।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','security','cameras','(cctv)','new']::text[], 3100, null, null, null, 'DEMO-026', true, 37, 3, 'no', 'in_stock', false, 0.3, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '234 minutes', now() - interval '234 minutes') returning id into pid;
    if pg_temp.ok(c, 'Camera Brand') and pg_temp.opt('Camera Brand', 'Imou') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Camera Brand'), pg_temp.opt('Camera Brand', 'Imou')); end if;
    if pg_temp.ok(c, 'Security Camera Type') and pg_temp.opt('Security Camera Type', 'Wi-Fi Camera') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Security Camera Type'), pg_temp.opt('Security Camera Type', 'Wi-Fi Camera')); end if;
    if pg_temp.ok(c, 'Video Resolution') and pg_temp.opt('Video Resolution', 'Full HD 1080p') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Video Resolution'), pg_temp.opt('Video Resolution', 'Full HD 1080p')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
    insert into public.product_price_tiers (product_id, min_qty, unit_price) values (pid, 3, 2945), (pid, 10, 2790);
  exception when others then missing := missing || 'Security Cameras (CCTV)' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 27. Air Conditioners: Gree 1.5 Ton Inverter Split AC  [d35 dhaka feat heavy]
  c := pg_temp.cat('Air Conditioners');
  if c is null then missing := missing || 'Air Conditioners' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Gree 1.5 Ton Inverter Split AC', 'গ্রি ১.৫ টন ইনভার্টার স্প্লিট এসি', 'Saves up to 60% electricity · Fast cooling, auto clean · Free installation inside Dhaka', 'Gree 1.5 Ton Inverter Split AC

• Saves up to 60% electricity
• Fast cooling, auto clean
• Free installation inside Dhaka

Delivery: Ships in 3–5 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'বিদ্যুৎ সাশ্রয়ী ইনভার্টার এসি, ঢাকার ভিতরে ফ্রি ইনস্টলেশন।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','air','conditioners','new','featured']::text[], 78000, null, null, null, 'DEMO-027', true, 44, 3, 'no', 'in_stock', false, 45, 90, 70, 60, 'heavy', '3_5_days', 'inside_dhaka', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '243 minutes', now() - interval '243 minutes') returning id into pid;
    if pg_temp.ok(c, 'Appliance Brand') and pg_temp.opt('Appliance Brand', 'Gree') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Appliance Brand'), pg_temp.opt('Appliance Brand', 'Gree')); end if;
    if pg_temp.ok(c, 'AC Capacity') and pg_temp.opt('AC Capacity', '1.5 Ton') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('AC Capacity'), pg_temp.opt('AC Capacity', '1.5 Ton')); end if;
    if pg_temp.ok(c, 'AC Type') and pg_temp.opt('AC Type', 'Split') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('AC Type'), pg_temp.opt('AC Type', 'Split')); end if;
    if pg_temp.ok(c, 'Inverter Type') and pg_temp.opt('Inverter Type', 'Inverter') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Inverter Type'), pg_temp.opt('Inverter Type', 'Inverter')); end if;
    if pg_temp.ok(c, 'Energy Rating') and pg_temp.opt('Energy Rating', '5 Star') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Energy Rating'), pg_temp.opt('Energy Rating', '5 Star')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '5 Years') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '5 Years')); end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000001', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Air Conditioners' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 28. Refrigerators & Freezers: Walton 253 L Frost-free Refrigerator  [d35 heavy sale variable]
  c := pg_temp.cat('Refrigerators & Freezers');
  if c is null then missing := missing || 'Refrigerators & Freezers' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Walton 253 L Frost-free Refrigerator', 'ওয়ালটন ২৫৩ লিটার ফ্রস্ট-ফ্রি ফ্রিজ', '253 litres, no ice build-up · Inverter compressor · Glass shelves', 'Walton 253 L Frost-free Refrigerator

• 253 litres, no ice build-up
• Inverter compressor
• Glass shelves

Delivery: Ships in 3–5 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'মাঝারি পরিবারের জন্য ফ্রস্ট-ফ্রি রেফ্রিজারেটর।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','refrigerators','freezers','new','sale']::text[], 52900, '44959', null, null, 'DEMO-028', true, 51, 3, 'no', 'in_stock', false, 55, 90, 70, 60, 'heavy', '3_5_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '252 minutes', now() - interval '252 minutes') returning id into pid;
    if pg_temp.ok(c, 'Appliance Brand') and pg_temp.opt('Appliance Brand', 'Walton') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Appliance Brand'), pg_temp.opt('Appliance Brand', 'Walton')); end if;
    if pg_temp.ok(c, 'Refrigerator Capacity') and pg_temp.opt('Refrigerator Capacity', '200–299 L') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Refrigerator Capacity'), pg_temp.opt('Refrigerator Capacity', '200–299 L')); end if;
    if pg_temp.ok(c, 'Refrigerator Type') and pg_temp.opt('Refrigerator Type', 'Double Door (top freezer)') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Refrigerator Type'), pg_temp.opt('Refrigerator Type', 'Double Door (top freezer)')); end if;
    if pg_temp.ok(c, 'Inverter Type') and pg_temp.opt('Inverter Type', 'Inverter') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Inverter Type'), pg_temp.opt('Inverter Type', 'Inverter')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '10 Years') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '10 Years')); end if;
    if pg_temp.opt('Colour', 'Silver') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Silver'))) t(a, o)), 'DEMO-028-1', 52900, 44959, 14, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Silver'));
    end if;
    if pg_temp.opt('Colour', 'Maroon') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Maroon'))) t(a, o)), 'DEMO-028-2', 52900, null, 17, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Maroon'));
    end if;
  exception when others then missing := missing || 'Refrigerators & Freezers' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 29. Washing Machines: LG 8 kg Front Load Washing Machine  [d610 heavy ret0]
  c := pg_temp.cat('Washing Machines');
  if c is null then missing := missing || 'Washing Machines' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'LG 8 kg Front Load Washing Machine', 'এলজি ৮ কেজি ফ্রন্ট লোড ওয়াশিং মেশিন', 'Steam wash removes allergens · Inverter direct drive motor · 14 wash programmes', 'LG 8 kg Front Load Washing Machine

• Steam wash removes allergens
• Inverter direct drive motor
• 14 wash programmes

Delivery: Ships in 6–10 days. No returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'স্টিম ওয়াশসহ ফ্রন্ট লোড ওয়াশিং মেশিন।

ফেরত নেওয়া হয় না।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','washing','machines','new']::text[], 64500, null, null, null, 'DEMO-029', true, 18, 3, 'no', 'in_stock', false, 62, 90, 70, 60, 'heavy', '6_10_days', 'all_bangladesh', false, 'no_returns', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '261 minutes', now() - interval '261 minutes') returning id into pid;
    if pg_temp.ok(c, 'Appliance Brand') and pg_temp.opt('Appliance Brand', 'LG') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Appliance Brand'), pg_temp.opt('Appliance Brand', 'LG')); end if;
    if pg_temp.ok(c, 'Washing Capacity') and pg_temp.opt('Washing Capacity', '8 kg') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Washing Capacity'), pg_temp.opt('Washing Capacity', '8 kg')); end if;
    if pg_temp.ok(c, 'Washing Machine Type') and pg_temp.opt('Washing Machine Type', 'Front Load') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Washing Machine Type'), pg_temp.opt('Washing Machine Type', 'Front Load')); end if;
    if pg_temp.ok(c, 'Inverter Type') and pg_temp.opt('Inverter Type', 'Inverter') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Inverter Type'), pg_temp.opt('Inverter Type', 'Inverter')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '2 Years') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '2 Years')); end if;
  exception when others then missing := missing || 'Washing Machines' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 30. Fans & Air Coolers: Vision 16" Rechargeable Table Fan  [flash]
  c := pg_temp.cat('Fans & Air Coolers');
  if c is null then missing := missing || 'Fans & Air Coolers' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Vision 16" Rechargeable Table Fan', 'ভিশন ১৬" রিচার্জেবল টেবিল ফ্যান', 'Runs 6–8 hours on battery · LED light · Works during load-shedding', 'Vision 16" Rechargeable Table Fan

• Runs 6–8 hours on battery
• LED light
• Works during load-shedding

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'লোডশেডিংয়ে ভরসা, ব্যাটারিতে চলা টেবিল ফ্যান।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','fans','air','coolers','new','sale']::text[], 4950, '4209', now() - interval '1 day', now() + interval '2 days', 'DEMO-030', true, 25, 3, 'no', 'in_stock', false, 3.5, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '270 minutes', now() - interval '270 minutes') returning id into pid;
    if pg_temp.ok(c, 'Appliance Brand') and pg_temp.opt('Appliance Brand', 'Vision') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Appliance Brand'), pg_temp.opt('Appliance Brand', 'Vision')); end if;
    if pg_temp.ok(c, 'Fan Type') and pg_temp.opt('Fan Type', 'Rechargeable Fan') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fan Type'), pg_temp.opt('Fan Type', 'Rechargeable Fan')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
  exception when others then missing := missing || 'Fans & Air Coolers' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 31. Irons & Garment Steamers: Philips Steam Iron 2000W  [sale]
  c := pg_temp.cat('Irons & Garment Steamers');
  if c is null then missing := missing || 'Irons & Garment Steamers' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Philips Steam Iron 2000W', 'ফিলিপস স্টিম আয়রন ২০০০ ওয়াট', '2000 W heats up fast · Non-stick soleplate · Vertical steam', 'Philips Steam Iron 2000W

• 2000 W heats up fast
• Non-stick soleplate
• Vertical steam

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'দ্রুত গরম হয় এমন স্টিম আয়রন।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','irons','garment','steamers','new','sale']::text[], 3950, '3359', null, null, 'DEMO-031', true, 32, 3, 'no', 'in_stock', false, 1.3, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '279 minutes', now() - interval '279 minutes') returning id into pid;
    if pg_temp.ok(c, 'Appliance Brand') and pg_temp.opt('Appliance Brand', 'Philips') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Appliance Brand'), pg_temp.opt('Appliance Brand', 'Philips')); end if;
    if pg_temp.ok(c, 'Iron Type') and pg_temp.opt('Iron Type', 'Steam Iron') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Iron Type'), pg_temp.opt('Iron Type', 'Steam Iron')); end if;
    if pg_temp.ok(c, 'Power Consumption') and pg_temp.opt('Power Consumption', '2000 W and above') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Power Consumption'), pg_temp.opt('Power Consumption', '2000 W and above')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '2 Years') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '2 Years')); end if;
  exception when others then missing := missing || 'Irons & Garment Steamers' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 32. Blenders & Juicers: Miyako 3-in-1 Blender 750W  [feat]
  c := pg_temp.cat('Blenders & Juicers');
  if c is null then missing := missing || 'Blenders & Juicers' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Miyako 3-in-1 Blender 750W', 'মিয়াকো ৩-ইন-১ ব্লেন্ডার ৭৫০ ওয়াট', 'Blend, grind and mix · 3 stainless steel jars · Strong 750 W motor', 'Miyako 3-in-1 Blender 750W

• Blend, grind and mix
• 3 stainless steel jars
• Strong 750 W motor

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'মসলা বাটা থেকে জুস, সব কাজে ৩টি জারসহ ব্লেন্ডার।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','blenders','juicers','new','featured']::text[], 4300, null, null, null, 'DEMO-032', true, 39, 3, 'no', 'in_stock', false, 3, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '288 minutes', now() - interval '288 minutes') returning id into pid;
    if pg_temp.ok(c, 'Appliance Brand') and pg_temp.opt('Appliance Brand', 'Miyako') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Appliance Brand'), pg_temp.opt('Appliance Brand', 'Miyako')); end if;
    if pg_temp.ok(c, 'Number of Jars') and pg_temp.opt('Number of Jars', '3') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Number of Jars'), pg_temp.opt('Number of Jars', '3')); end if;
    if pg_temp.ok(c, 'Power Consumption') and pg_temp.opt('Power Consumption', '501–999 W') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Power Consumption'), pg_temp.opt('Power Consumption', '501–999 W')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000002', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Blenders & Juicers' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 33. Rice & Multi Cookers: Miyako 1.8 L Rice Cooker  [bulk freedel]
  c := pg_temp.cat('Rice & Multi Cookers');
  if c is null then missing := missing || 'Rice & Multi Cookers' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Miyako 1.8 L Rice Cooker', 'মিয়াকো ১.৮ লিটার রাইস কুকার', 'Cooks rice for 6–8 people · Keeps warm automatically · Steamer tray included', 'Miyako 1.8 L Rice Cooker

• Cooks rice for 6–8 people
• Keeps warm automatically
• Steamer tray included

Delivery: Ships in 1–2 days. 7-day returns. Free delivery.

(Demo product for testing RGBKart. The photos will be added later.)', 'পরিবারের জন্য স্বয়ংক্রিয় রাইস কুকার।

৭ দিনের মধ্যে ফেরত। ফ্রি ডেলিভারি।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','rice','multi','cookers','new']::text[], 2650, null, null, null, 'DEMO-033', true, 46, 3, 'no', 'in_stock', false, 2.5, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', true, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '297 minutes', now() - interval '297 minutes') returning id into pid;
    if pg_temp.ok(c, 'Appliance Brand') and pg_temp.opt('Appliance Brand', 'Miyako') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Appliance Brand'), pg_temp.opt('Appliance Brand', 'Miyako')); end if;
    if pg_temp.ok(c, 'Kitchen Capacity') and pg_temp.opt('Kitchen Capacity', '1–1.9 L') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Kitchen Capacity'), pg_temp.opt('Kitchen Capacity', '1–1.9 L')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
    insert into public.product_price_tiers (product_id, min_qty, unit_price) values (pid, 3, 2518), (pid, 10, 2385);
  exception when others then missing := missing || 'Rice & Multi Cookers' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 34. Microwaves, Ovens & Air Fryers: Xiaomi Smart Air Fryer 4.5L  [sale]
  c := pg_temp.cat('Microwaves, Ovens & Air Fryers');
  if c is null then missing := missing || 'Microwaves, Ovens & Air Fryers' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Xiaomi Smart Air Fryer 4.5L', 'শাওমি স্মার্ট এয়ার ফ্রায়ার ৪.৫ লিটার', 'Fry with little or no oil · App control, 100+ recipes · Non-stick basket', 'Xiaomi Smart Air Fryer 4.5L

• Fry with little or no oil
• App control, 100+ recipes
• Non-stick basket

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'কম তেলে ভাজাভুজি, অ্যাপ থেকে নিয়ন্ত্রণ।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','microwaves','ovens','air','new','sale']::text[], 9800, '8329', null, null, 'DEMO-034', true, 53, 3, 'no', 'in_stock', false, 4, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '306 minutes', now() - interval '306 minutes') returning id into pid;
    if pg_temp.ok(c, 'Appliance Brand') and pg_temp.opt('Appliance Brand', 'Xiaomi') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Appliance Brand'), pg_temp.opt('Appliance Brand', 'Xiaomi')); end if;
    if pg_temp.ok(c, 'Oven Type') and pg_temp.opt('Oven Type', 'Air Fryer') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Oven Type'), pg_temp.opt('Oven Type', 'Air Fryer')); end if;
    if pg_temp.ok(c, 'Kitchen Capacity') and pg_temp.opt('Kitchen Capacity', '3–4.9 L') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Kitchen Capacity'), pg_temp.opt('Kitchen Capacity', '3–4.9 L')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
  exception when others then missing := missing || 'Microwaves, Ovens & Air Fryers' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 35. Kettles & Coffee Makers: Kiam Electric Kettle 1.8L  [low small]
  c := pg_temp.cat('Kettles & Coffee Makers');
  if c is null then missing := missing || 'Kettles & Coffee Makers' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Kiam Electric Kettle 1.8L', 'কিয়াম ইলেকট্রিক কেটলি ১.৮ লিটার', 'Boils water in 5 minutes · Auto shut-off · Stainless steel body', 'Kiam Electric Kettle 1.8L

• Boils water in 5 minutes
• Auto shut-off
• Stainless steel body

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'দ্রুত পানি ফোটানোর ইলেকট্রিক কেটলি।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','kettles','coffee','makers','new']::text[], 1450, null, null, null, 'DEMO-035', true, 2, 5, 'no', 'in_stock', false, 1, 12, 8, 4, 'small', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '315 minutes', now() - interval '315 minutes') returning id into pid;
    if pg_temp.ok(c, 'Appliance Brand') and pg_temp.opt('Appliance Brand', 'Kiam') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Appliance Brand'), pg_temp.opt('Appliance Brand', 'Kiam')); end if;
    if pg_temp.ok(c, 'Kitchen Capacity') and pg_temp.opt('Kitchen Capacity', '1–1.9 L') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Kitchen Capacity'), pg_temp.opt('Kitchen Capacity', '1–1.9 L')); end if;
    if pg_temp.ok(c, 'Material') and pg_temp.opt('Material', 'Stainless Steel') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Material'), pg_temp.opt('Material', 'Stainless Steel')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '6 Months') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '6 Months')); end if;
  exception when others then missing := missing || 'Kettles & Coffee Makers' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 36. Gas Stoves & Cooktops: RFL Double Burner Glass Gas Stove (LPG)  [d35 fragile]
  c := pg_temp.cat('Gas Stoves & Cooktops');
  if c is null then missing := missing || 'Gas Stoves & Cooktops' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'RFL Double Burner Glass Gas Stove (LPG)', 'আরএফএল ডাবল বার্নার গ্লাস গ্যাস চুলা (এলপিজি)', 'Tempered glass top · Brass burners · Auto ignition', 'RFL Double Burner Glass Gas Stove (LPG)

• Tempered glass top
• Brass burners
• Auto ignition

Delivery: Ships in 3–5 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'টেম্পার্ড গ্লাসের দুই চুলার এলপিজি গ্যাস স্টোভ।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','gas','stoves','cooktops','new']::text[], 6200, null, null, null, 'DEMO-036', true, 27, 3, 'no', 'in_stock', false, 7, 50, 35, 20, 'fragile', '3_5_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '324 minutes', now() - interval '324 minutes') returning id into pid;
    if pg_temp.ok(c, 'Appliance Brand') and pg_temp.opt('Appliance Brand', 'RFL') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Appliance Brand'), pg_temp.opt('Appliance Brand', 'RFL')); end if;
    if pg_temp.ok(c, 'Burner Count') and pg_temp.opt('Burner Count', 'Double') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Burner Count'), pg_temp.opt('Burner Count', 'Double')); end if;
    if pg_temp.ok(c, 'Gas Type') and pg_temp.opt('Gas Type', 'LPG (cylinder)') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Gas Type'), pg_temp.opt('Gas Type', 'LPG (cylinder)')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
  exception when others then missing := missing || 'Gas Stoves & Cooktops' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 37. T-Shirts & Polos: Cotton Polo Shirt  [feat sale variable]
  c := pg_temp.cat('T-Shirts & Polos');
  if c is null then missing := missing || 'T-Shirts & Polos' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Cotton Polo Shirt', 'সুতির পোলো শার্ট', '100% combed cotton pique · Regular fit · Breathable for summer', 'Cotton Polo Shirt

• 100% combed cotton pique
• Regular fit
• Breathable for summer

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'গরমে আরামদায়ক ১০০% সুতির পোলো শার্ট।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','t-shirts','polos','new','sale','featured']::text[], 850, '720', null, null, 'DEMO-037', true, 34, 3, 'no', 'in_stock', false, 0.25, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '333 minutes', now() - interval '333 minutes') returning id into pid;
    if pg_temp.ok(c, 'Fashion Brand') and pg_temp.opt('Fashion Brand', 'Local / Unbranded') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fashion Brand'), pg_temp.opt('Fashion Brand', 'Local / Unbranded')); end if;
    if pg_temp.ok(c, 'Fabric') and pg_temp.opt('Fabric', '100% Cotton') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fabric'), pg_temp.opt('Fabric', '100% Cotton')); end if;
    if pg_temp.ok(c, 'Fit') and pg_temp.opt('Fit', 'Regular Fit') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fit'), pg_temp.opt('Fit', 'Regular Fit')); end if;
    if pg_temp.ok(c, 'Sleeve Length') and pg_temp.opt('Sleeve Length', 'Short Sleeve') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Sleeve Length'), pg_temp.opt('Sleeve Length', 'Short Sleeve')); end if;
    if pg_temp.opt('Clothing Size', 'M') is not null and pg_temp.opt('Colour', 'Black') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'M')), (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'))) t(a, o)), 'DEMO-037-1', 850, 720, 5, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'M')), (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'));
    end if;
    if pg_temp.opt('Clothing Size', 'M') is not null and pg_temp.opt('Colour', 'Navy') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'M')), (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Navy'))) t(a, o)), 'DEMO-037-2', 850, null, 8, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'M')), (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Navy'));
    end if;
    if pg_temp.opt('Clothing Size', 'M') is not null and pg_temp.opt('Colour', 'White') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'M')), (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'White'))) t(a, o)), 'DEMO-037-3', 850, 720, 11, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'M')), (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'White'));
    end if;
    if pg_temp.opt('Clothing Size', 'L') is not null and pg_temp.opt('Colour', 'Black') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'L')), (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'))) t(a, o)), 'DEMO-037-4', 850, null, 14, true, 30) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'L')), (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'));
    end if;
    if pg_temp.opt('Clothing Size', 'L') is not null and pg_temp.opt('Colour', 'Navy') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'L')), (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Navy'))) t(a, o)), 'DEMO-037-5', 850, 720, 17, true, 40) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'L')), (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Navy'));
    end if;
    if pg_temp.opt('Clothing Size', 'L') is not null and pg_temp.opt('Colour', 'White') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'L')), (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'White'))) t(a, o)), 'DEMO-037-6', 850, null, 20, true, 50) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'L')), (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'White'));
    end if;
    if pg_temp.opt('Clothing Size', 'XL') is not null and pg_temp.opt('Colour', 'Black') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'XL')), (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'))) t(a, o)), 'DEMO-037-7', 900, 760, 5, true, 60) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'XL')), (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'));
    end if;
    if pg_temp.opt('Clothing Size', 'XL') is not null and pg_temp.opt('Colour', 'Navy') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'XL')), (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Navy'))) t(a, o)), 'DEMO-037-8', 900, null, 8, true, 70) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'XL')), (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Navy'));
    end if;
    if pg_temp.opt('Clothing Size', 'XL') is not null and pg_temp.opt('Colour', 'White') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'XL')), (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'White'))) t(a, o)), 'DEMO-037-9', 900, 760, 11, true, 80) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'XL')), (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'White'));
    end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000002', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'T-Shirts & Polos' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 38. Shirts: Formal Oxford Shirt  [bulk variable]
  c := pg_temp.cat('Shirts');
  if c is null then missing := missing || 'Shirts' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Formal Oxford Shirt', 'ফরমাল অক্সফোর্ড শার্ট', 'Easy-iron oxford cotton · Slim fit · Office and formal wear', 'Formal Oxford Shirt

• Easy-iron oxford cotton
• Slim fit
• Office and formal wear

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'অফিসের জন্য সহজে ইস্ত্রি করা যায় এমন অক্সফোর্ড শার্ট।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','shirts','new']::text[], 1650, null, null, null, 'DEMO-038', true, 41, 3, 'no', 'in_stock', false, 0.3, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '342 minutes', now() - interval '342 minutes') returning id into pid;
    if pg_temp.ok(c, 'Fashion Brand') and pg_temp.opt('Fashion Brand', 'Richman') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fashion Brand'), pg_temp.opt('Fashion Brand', 'Richman')); end if;
    if pg_temp.ok(c, 'Fabric') and pg_temp.opt('Fabric', 'Cotton Blend') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fabric'), pg_temp.opt('Fabric', 'Cotton Blend')); end if;
    if pg_temp.ok(c, 'Fit') and pg_temp.opt('Fit', 'Slim Fit') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fit'), pg_temp.opt('Fit', 'Slim Fit')); end if;
    if pg_temp.ok(c, 'Sleeve Length') and pg_temp.opt('Sleeve Length', 'Full Sleeve') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Sleeve Length'), pg_temp.opt('Sleeve Length', 'Full Sleeve')); end if;
    if pg_temp.ok(c, 'Occasion') and pg_temp.opt('Occasion', 'Office') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Occasion'), pg_temp.opt('Occasion', 'Office')); end if;
    if pg_temp.ok(c, 'Occasion') and pg_temp.opt('Occasion', 'Formal') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Occasion'), pg_temp.opt('Occasion', 'Formal')); end if;
    if pg_temp.opt('Clothing Size', 'M') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'M'))) t(a, o)), 'DEMO-038-1', 1650, null, 6, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'M'));
    end if;
    if pg_temp.opt('Clothing Size', 'L') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'L'))) t(a, o)), 'DEMO-038-2', 1650, null, 9, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'L'));
    end if;
    if pg_temp.opt('Clothing Size', 'XL') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'XL'))) t(a, o)), 'DEMO-038-3', 1650, null, 12, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'XL'));
    end if;
  exception when others then missing := missing || 'Shirts' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 39. Pants & Jeans: Slim Fit Stretch Denim Jeans  [flash variable]
  c := pg_temp.cat('Pants & Jeans');
  if c is null then missing := missing || 'Pants & Jeans' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Slim Fit Stretch Denim Jeans', 'স্লিম ফিট স্ট্রেচ ডেনিম জিন্স', 'Stretch denim for comfort · Slim fit, dark blue wash · 5 pockets', 'Slim Fit Stretch Denim Jeans

• Stretch denim for comfort
• Slim fit, dark blue wash
• 5 pockets

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'আরামদায়ক স্ট্রেচ ডেনিম, স্লিম ফিট জিন্স।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','pants','jeans','new','sale']::text[], 1890, '1609', now() - interval '1 day', now() + interval '2 days', 'DEMO-039', true, 48, 3, 'no', 'in_stock', false, 0.6, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '351 minutes', now() - interval '351 minutes') returning id into pid;
    if pg_temp.ok(c, 'Fashion Brand') and pg_temp.opt('Fashion Brand', 'Local / Unbranded') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fashion Brand'), pg_temp.opt('Fashion Brand', 'Local / Unbranded')); end if;
    if pg_temp.ok(c, 'Fabric') and pg_temp.opt('Fabric', 'Denim') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fabric'), pg_temp.opt('Fabric', 'Denim')); end if;
    if pg_temp.ok(c, 'Fit') and pg_temp.opt('Fit', 'Slim Fit') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fit'), pg_temp.opt('Fit', 'Slim Fit')); end if;
    if pg_temp.opt('Waist Size', '30') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Waist Size'), pg_temp.opt('Waist Size', '30'))) t(a, o)), 'DEMO-039-1', 1890, 1609, 7, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Waist Size'), pg_temp.opt('Waist Size', '30'));
    end if;
    if pg_temp.opt('Waist Size', '32') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Waist Size'), pg_temp.opt('Waist Size', '32'))) t(a, o)), 'DEMO-039-2', 1890, null, 10, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Waist Size'), pg_temp.opt('Waist Size', '32'));
    end if;
    if pg_temp.opt('Waist Size', '34') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Waist Size'), pg_temp.opt('Waist Size', '34'))) t(a, o)), 'DEMO-039-3', 1890, 1609, 13, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Waist Size'), pg_temp.opt('Waist Size', '34'));
    end if;
    if pg_temp.opt('Waist Size', '36') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Waist Size'), pg_temp.opt('Waist Size', '36'))) t(a, o)), 'DEMO-039-4', 1890, null, 16, true, 30) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Waist Size'), pg_temp.opt('Waist Size', '36'));
    end if;
  exception when others then missing := missing || 'Pants & Jeans' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 40. Panjabi & Ethnic Wear: Embroidered Cotton Panjabi  [feat freedel variable]
  c := pg_temp.cat('Panjabi & Ethnic Wear');
  if c is null then missing := missing || 'Panjabi & Ethnic Wear' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Embroidered Cotton Panjabi', 'এমব্রয়ডারি করা সুতির পাঞ্জাবি', 'Fine embroidery on the collar · Soft cotton · Perfect for Eid and Puja', 'Embroidered Cotton Panjabi

• Fine embroidery on the collar
• Soft cotton
• Perfect for Eid and Puja

Delivery: Ships in 1–2 days. 7-day returns. Free delivery.

(Demo product for testing RGBKart. The photos will be added later.)', 'ঈদ ও পূজার জন্য সূক্ষ্ম কাজের সুতির পাঞ্জাবি।

৭ দিনের মধ্যে ফেরত। ফ্রি ডেলিভারি।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','panjabi','ethnic','wear','new','featured']::text[], 2450, null, null, null, 'DEMO-040', true, 15, 3, 'no', 'in_stock', false, 0.4, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', true, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '360 minutes', now() - interval '360 minutes') returning id into pid;
    if pg_temp.ok(c, 'Fashion Brand') and pg_temp.opt('Fashion Brand', 'Local / Unbranded') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fashion Brand'), pg_temp.opt('Fashion Brand', 'Local / Unbranded')); end if;
    if pg_temp.ok(c, 'Fabric') and pg_temp.opt('Fabric', 'Cotton') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fabric'), pg_temp.opt('Fabric', 'Cotton')); end if;
    if pg_temp.ok(c, 'Pattern') and pg_temp.opt('Pattern', 'Embroidered') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Pattern'), pg_temp.opt('Pattern', 'Embroidered')); end if;
    if pg_temp.ok(c, 'Occasion') and pg_temp.opt('Occasion', 'Eid / Festive') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Occasion'), pg_temp.opt('Occasion', 'Eid / Festive')); end if;
    if pg_temp.ok(c, 'Occasion') and pg_temp.opt('Occasion', 'Wedding') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Occasion'), pg_temp.opt('Occasion', 'Wedding')); end if;
    if pg_temp.ok(c, 'Occasion') and pg_temp.opt('Occasion', 'Puja') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Occasion'), pg_temp.opt('Occasion', 'Puja')); end if;
    if pg_temp.opt('Clothing Size', 'M') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'M'))) t(a, o)), 'DEMO-040-1', 2450, null, 8, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'M'));
    end if;
    if pg_temp.opt('Clothing Size', 'L') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'L'))) t(a, o)), 'DEMO-040-2', 2450, null, 11, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'L'));
    end if;
    if pg_temp.opt('Clothing Size', 'XL') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'XL'))) t(a, o)), 'DEMO-040-3', 2450, null, 14, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'XL'));
    end if;
    if pg_temp.opt('Clothing Size', 'XXL') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'XXL'))) t(a, o)), 'DEMO-040-4', 2600, null, 17, true, 30) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'XXL'));
    end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000002', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Panjabi & Ethnic Wear' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 41. Winter Wear: Fleece Hoodie  [sale variable]
  c := pg_temp.cat('Winter Wear');
  if c is null then missing := missing || 'Winter Wear' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Fleece Hoodie', 'ফ্লিস হুডি', 'Warm brushed fleece inside · Kangaroo pocket · Unisex fit', 'Fleece Hoodie

• Warm brushed fleece inside
• Kangaroo pocket
• Unisex fit

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'শীতের জন্য গরম ফ্লিস হুডি।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','winter','wear','new','sale']::text[], 1350, '1149', null, null, 'DEMO-041', true, 22, 3, 'no', 'in_stock', false, 0.5, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '369 minutes', now() - interval '369 minutes') returning id into pid;
    if pg_temp.ok(c, 'Fabric') and pg_temp.opt('Fabric', 'Fleece') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fabric'), pg_temp.opt('Fabric', 'Fleece')); end if;
    if pg_temp.ok(c, 'Occasion') and pg_temp.opt('Occasion', 'Winter') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Occasion'), pg_temp.opt('Occasion', 'Winter')); end if;
    if pg_temp.opt('Clothing Size', 'M') is not null and pg_temp.opt('Colour', 'Grey') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'M')), (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Grey'))) t(a, o)), 'DEMO-041-1', 1350, 1149, 9, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'M')), (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Grey'));
    end if;
    if pg_temp.opt('Clothing Size', 'M') is not null and pg_temp.opt('Colour', 'Maroon') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'M')), (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Maroon'))) t(a, o)), 'DEMO-041-2', 1350, null, 12, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'M')), (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Maroon'));
    end if;
    if pg_temp.opt('Clothing Size', 'L') is not null and pg_temp.opt('Colour', 'Grey') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'L')), (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Grey'))) t(a, o)), 'DEMO-041-3', 1350, 1149, 15, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'L')), (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Grey'));
    end if;
    if pg_temp.opt('Clothing Size', 'L') is not null and pg_temp.opt('Colour', 'Maroon') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'L')), (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Maroon'))) t(a, o)), 'DEMO-041-4', 1350, null, 18, true, 30) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'L')), (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Maroon'));
    end if;
    if pg_temp.opt('Clothing Size', 'XL') is not null and pg_temp.opt('Colour', 'Grey') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'XL')), (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Grey'))) t(a, o)), 'DEMO-041-5', 1350, 1149, 21, true, 40) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'XL')), (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Grey'));
    end if;
    if pg_temp.opt('Clothing Size', 'XL') is not null and pg_temp.opt('Colour', 'Maroon') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'XL')), (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Maroon'))) t(a, o)), 'DEMO-041-6', 1350, null, 6, true, 50) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'XL')), (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Maroon'));
    end if;
  exception when others then missing := missing || 'Winter Wear' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 42. Wallets & Belts: Genuine Leather Wallet  [small]
  c := pg_temp.cat('Wallets & Belts');
  if c is null then missing := missing || 'Wallets & Belts' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Genuine Leather Wallet', 'আসল চামড়ার মানিব্যাগ', 'Real cow leather · 8 card slots, coin pocket · Gift box included', 'Genuine Leather Wallet

• Real cow leather
• 8 card slots, coin pocket
• Gift box included

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'উপহার দেওয়ার মতো আসল চামড়ার মানিব্যাগ।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','wallets','belts','new']::text[], 990, null, null, null, 'DEMO-042', true, 29, 3, 'no', 'in_stock', false, 0.1, 12, 8, 4, 'small', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '378 minutes', now() - interval '378 minutes') returning id into pid;
    if pg_temp.ok(c, 'Material') and pg_temp.opt('Material', 'Leather') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Material'), pg_temp.opt('Material', 'Leather')); end if;
    if pg_temp.ok(c, 'Gender') and pg_temp.opt('Gender', 'Men') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Gender'), pg_temp.opt('Gender', 'Men')); end if;
    if pg_temp.ok(c, 'Colour') and pg_temp.opt('Colour', 'Brown') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Brown')); end if;
  exception when others then missing := missing || 'Wallets & Belts' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 43. Sarees: Tangail Cotton Saree  [feat variable]
  c := pg_temp.cat('Sarees');
  if c is null then missing := missing || 'Sarees' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Tangail Cotton Saree', 'টাঙ্গাইলের সুতি শাড়ি', 'Handwoven in Tangail · Soft cotton, comfortable all day · With blouse piece', 'Tangail Cotton Saree

• Handwoven in Tangail
• Soft cotton, comfortable all day
• With blouse piece

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'টাঙ্গাইলের তাঁতিদের হাতে বোনা আরামদায়ক সুতি শাড়ি, ব্লাউজ পিসসহ।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','sarees','new','featured']::text[], 2200, null, null, null, 'DEMO-043', true, 36, 3, 'no', 'in_stock', false, 0.6, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '387 minutes', now() - interval '387 minutes') returning id into pid;
    if pg_temp.ok(c, 'Saree Type') and pg_temp.opt('Saree Type', 'Tangail') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Saree Type'), pg_temp.opt('Saree Type', 'Tangail')); end if;
    if pg_temp.ok(c, 'Fabric') and pg_temp.opt('Fabric', 'Cotton') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fabric'), pg_temp.opt('Fabric', 'Cotton')); end if;
    if pg_temp.ok(c, 'Blouse Piece Included') then insert into public.product_attribute_values (product_id, attribute_id, bool_value) values (pid, pg_temp.attr('Blouse Piece Included'), true); end if;
    if pg_temp.ok(c, 'Occasion') and pg_temp.opt('Occasion', 'Daily Wear') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Occasion'), pg_temp.opt('Occasion', 'Daily Wear')); end if;
    if pg_temp.ok(c, 'Occasion') and pg_temp.opt('Occasion', 'Pohela Boishakh') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Occasion'), pg_temp.opt('Occasion', 'Pohela Boishakh')); end if;
    if pg_temp.opt('Colour', 'Red') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Red'))) t(a, o)), 'DEMO-043-1', 2200, null, 11, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Red'));
    end if;
    if pg_temp.opt('Colour', 'Green') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Green'))) t(a, o)), 'DEMO-043-2', 2200, null, 14, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Green'));
    end if;
    if pg_temp.opt('Colour', 'Maroon') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Maroon'))) t(a, o)), 'DEMO-043-3', 2200, null, 17, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Maroon'));
    end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000002', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Sarees' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 44. Salwar Kameez & Three-Piece: Printed Lawn Three-Piece  [bulk sale variable]
  c := pg_temp.cat('Salwar Kameez & Three-Piece');
  if c is null then missing := missing || 'Salwar Kameez & Three-Piece' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Printed Lawn Three-Piece', 'প্রিন্টেড লন থ্রি-পিস', 'Soft lawn cotton · Printed dupatta · Stitched, ready to wear', 'Printed Lawn Three-Piece

• Soft lawn cotton
• Printed dupatta
• Stitched, ready to wear

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'রেডি-টু-ওয়্যার প্রিন্টেড লন থ্রি-পিস।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','salwar','kameez','three-piece','new','sale']::text[], 1950, '1659', null, null, 'DEMO-044', true, 43, 3, 'no', 'in_stock', false, 0.5, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '396 minutes', now() - interval '396 minutes') returning id into pid;
    if pg_temp.ok(c, 'Fabric') and pg_temp.opt('Fabric', 'Cotton') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fabric'), pg_temp.opt('Fabric', 'Cotton')); end if;
    if pg_temp.ok(c, 'Stitch Type') and pg_temp.opt('Stitch Type', 'Stitched (ready-made)') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Stitch Type'), pg_temp.opt('Stitch Type', 'Stitched (ready-made)')); end if;
    if pg_temp.ok(c, 'Pattern') and pg_temp.opt('Pattern', 'Printed') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Pattern'), pg_temp.opt('Pattern', 'Printed')); end if;
    if pg_temp.opt('Clothing Size', 'M') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'M'))) t(a, o)), 'DEMO-044-1', 1950, 1659, 12, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'M'));
    end if;
    if pg_temp.opt('Clothing Size', 'L') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'L'))) t(a, o)), 'DEMO-044-2', 1950, null, 15, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'L'));
    end if;
    if pg_temp.opt('Clothing Size', 'XL') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'XL'))) t(a, o)), 'DEMO-044-3', 1950, 1659, 18, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'XL'));
    end if;
  exception when others then missing := missing || 'Salwar Kameez & Three-Piece' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 45. Kurtis & Tops: Block Print Kurti  [freedel variable]
  c := pg_temp.cat('Kurtis & Tops');
  if c is null then missing := missing || 'Kurtis & Tops' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Block Print Kurti', 'ব্লক প্রিন্ট কুর্তি', 'Hand block print · Breathable cotton · 3/4 sleeve', 'Block Print Kurti

• Hand block print
• Breathable cotton
• 3/4 sleeve

Delivery: Ships in 1–2 days. 7-day returns. Free delivery.

(Demo product for testing RGBKart. The photos will be added later.)', 'হাতে ব্লক প্রিন্ট করা সুতির কুর্তি।

৭ দিনের মধ্যে ফেরত। ফ্রি ডেলিভারি।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','kurtis','tops','new']::text[], 1150, null, null, null, 'DEMO-045', true, 50, 3, 'no', 'in_stock', false, 0.3, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', true, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '405 minutes', now() - interval '405 minutes') returning id into pid;
    if pg_temp.ok(c, 'Fabric') and pg_temp.opt('Fabric', 'Cotton') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fabric'), pg_temp.opt('Fabric', 'Cotton')); end if;
    if pg_temp.ok(c, 'Pattern') and pg_temp.opt('Pattern', 'Block Print') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Pattern'), pg_temp.opt('Pattern', 'Block Print')); end if;
    if pg_temp.ok(c, 'Sleeve Length') and pg_temp.opt('Sleeve Length', '3/4 Sleeve') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Sleeve Length'), pg_temp.opt('Sleeve Length', '3/4 Sleeve')); end if;
    if pg_temp.opt('Clothing Size', 'S') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'S'))) t(a, o)), 'DEMO-045-1', 1150, null, 13, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'S'));
    end if;
    if pg_temp.opt('Clothing Size', 'M') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'M'))) t(a, o)), 'DEMO-045-2', 1150, null, 16, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'M'));
    end if;
    if pg_temp.opt('Clothing Size', 'L') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'L'))) t(a, o)), 'DEMO-045-3', 1150, null, 19, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'L'));
    end if;
  exception when others then missing := missing || 'Kurtis & Tops' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 46. Hijab & Abaya: Premium Georgette Abaya  [flash variable]
  c := pg_temp.cat('Hijab & Abaya');
  if c is null then missing := missing || 'Hijab & Abaya' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Premium Georgette Abaya', 'প্রিমিয়াম জর্জেট আবায়া', 'Flowy georgette · Matching hijab included · Free size', 'Premium Georgette Abaya

• Flowy georgette
• Matching hijab included
• Free size

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'হিজাবসহ মানসম্মত জর্জেট আবায়া।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','hijab','abaya','new','sale']::text[], 2800, '2379', now() - interval '1 day', now() + interval '2 days', 'DEMO-046', true, 17, 3, 'no', 'in_stock', false, 0.6, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '414 minutes', now() - interval '414 minutes') returning id into pid;
    if pg_temp.ok(c, 'Fabric') and pg_temp.opt('Fabric', 'Georgette') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fabric'), pg_temp.opt('Fabric', 'Georgette')); end if;
    if pg_temp.ok(c, 'Clothing Size') and pg_temp.opt('Clothing Size', 'Free Size') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'Free Size')); end if;
    if pg_temp.opt('Colour', 'Black') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'))) t(a, o)), 'DEMO-046-1', 2800, 2379, 14, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'));
    end if;
    if pg_temp.opt('Colour', 'Navy') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Navy'))) t(a, o)), 'DEMO-046-2', 2800, null, 17, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Navy'));
    end if;
    if pg_temp.opt('Colour', 'Beige') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Beige'))) t(a, o)), 'DEMO-046-3', 2800, 2379, 20, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Beige'));
    end if;
  exception when others then missing := missing || 'Hijab & Abaya' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 47. Western Wear: Floral Midi Dress  [neg used]
  c := pg_temp.cat('Western Wear');
  if c is null then missing := missing || 'Western Wear' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Floral Midi Dress', 'ফ্লোরাল মিডি ড্রেস', 'Worn twice, like new · Floral chiffon · Size M', 'Floral Midi Dress

• Worn twice, like new
• Floral chiffon
• Size M

Delivery: Ships in 1–2 days. 7-day returns.
Price is negotiable, message or call the seller.

(Demo product for testing RGBKart. The photos will be added later.)', 'মাত্র দুইবার পরা, নতুনের মতো ফ্লোরাল মিডি ড্রেস।

৭ দিনের মধ্যে ফেরত। দাম আলোচনা সাপেক্ষে।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','western','wear','used']::text[], 1750, null, null, null, 'DEMO-047', true, 24, 3, 'no', 'in_stock', false, 0.3, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Check the item when it arrives. Call the shop if anything is wrong.', 'pre_owned', 'simple', true, true, false, null, null, false, null, 0, 'approved', now() - interval '423 minutes', now() - interval '423 minutes') returning id into pid;
    if pg_temp.ok(c, 'Fabric') and pg_temp.opt('Fabric', 'Chiffon') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fabric'), pg_temp.opt('Fabric', 'Chiffon')); end if;
    if pg_temp.ok(c, 'Pattern') and pg_temp.opt('Pattern', 'Floral') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Pattern'), pg_temp.opt('Pattern', 'Floral')); end if;
    if pg_temp.ok(c, 'Clothing Size') and pg_temp.opt('Clothing Size', 'M') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Clothing Size'), pg_temp.opt('Clothing Size', 'M')); end if;
  exception when others then missing := missing || 'Western Wear' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 48. Jewellery & Sunglasses: Polarized Aviator Sunglasses  [sale small]
  c := pg_temp.cat('Jewellery & Sunglasses');
  if c is null then missing := missing || 'Jewellery & Sunglasses' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Polarized Aviator Sunglasses', 'পোলারাইজড এভিয়েটর সানগ্লাস', 'Polarized UV400 lenses · Metal frame · Hard case included', 'Polarized Aviator Sunglasses

• Polarized UV400 lenses
• Metal frame
• Hard case included

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'রোদ থেকে চোখ বাঁচাতে পোলারাইজড সানগ্লাস।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','jewellery','sunglasses','new','sale']::text[], 1250, '1059', null, null, 'DEMO-048', true, 31, 3, 'no', 'in_stock', false, 0.1, 12, 8, 4, 'small', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '432 minutes', now() - interval '432 minutes') returning id into pid;
    if pg_temp.ok(c, 'Sunglass Lens') and pg_temp.opt('Sunglass Lens', 'Polarized') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Sunglass Lens'), pg_temp.opt('Sunglass Lens', 'Polarized')); end if;
    if pg_temp.ok(c, 'Gender') and pg_temp.opt('Gender', 'Unisex') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Gender'), pg_temp.opt('Gender', 'Unisex')); end if;
  exception when others then missing := missing || 'Jewellery & Sunglasses' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 49. Kids Clothing: Kids Cotton Pajama Set (2 pcs)  [bulk freedel variable]
  c := pg_temp.cat('Kids Clothing');
  if c is null then missing := missing || 'Kids Clothing' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Kids Cotton Pajama Set (2 pcs)', 'বাচ্চাদের সুতির পায়জামা সেট (২ পিস)', 'Soft cotton for sensitive skin · Cute cartoon print · Top and pajama', 'Kids Cotton Pajama Set (2 pcs)

• Soft cotton for sensitive skin
• Cute cartoon print
• Top and pajama

Delivery: Ships in 1–2 days. 7-day returns. Free delivery.

(Demo product for testing RGBKart. The photos will be added later.)', 'বাচ্চার নরম ত্বকের জন্য সুতির পায়জামা সেট।

৭ দিনের মধ্যে ফেরত। ফ্রি ডেলিভারি।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','kids','clothing','new']::text[], 750, null, null, null, 'DEMO-049', true, 38, 3, 'no', 'in_stock', false, 0.3, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', true, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '441 minutes', now() - interval '441 minutes') returning id into pid;
    if pg_temp.ok(c, 'Fabric') and pg_temp.opt('Fabric', '100% Cotton') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fabric'), pg_temp.opt('Fabric', '100% Cotton')); end if;
    if pg_temp.ok(c, 'Gender') and pg_temp.opt('Gender', 'Unisex') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Gender'), pg_temp.opt('Gender', 'Unisex')); end if;
    if pg_temp.opt('Kids Age Group', '2–3 years') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Kids Age Group'), pg_temp.opt('Kids Age Group', '2–3 years'))) t(a, o)), 'DEMO-049-1', 750, null, 17, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Kids Age Group'), pg_temp.opt('Kids Age Group', '2–3 years'));
    end if;
    if pg_temp.opt('Kids Age Group', '3–4 years') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Kids Age Group'), pg_temp.opt('Kids Age Group', '3–4 years'))) t(a, o)), 'DEMO-049-2', 750, null, 20, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Kids Age Group'), pg_temp.opt('Kids Age Group', '3–4 years'));
    end if;
    if pg_temp.opt('Kids Age Group', '4–5 years') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Kids Age Group'), pg_temp.opt('Kids Age Group', '4–5 years'))) t(a, o)), 'DEMO-049-3', 750, null, 5, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Kids Age Group'), pg_temp.opt('Kids Age Group', '4–5 years'));
    end if;
  exception when others then missing := missing || 'Kids Clothing' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 50. Diapers & Wipes: Huggies Dry Pants Diaper  [bulk feat variable]
  c := pg_temp.cat('Diapers & Wipes');
  if c is null then missing := missing || 'Diapers & Wipes' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Huggies Dry Pants Diaper', 'হাগিস ড্রাই প্যান্টস ডায়াপার', 'Up to 12 hours dryness · Easy pull-up pants · Soft waistband', 'Huggies Dry Pants Diaper

• Up to 12 hours dryness
• Easy pull-up pants
• Soft waistband

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'দীর্ঘ সময় শুকনো রাখে এমন প্যান্ট ডায়াপার।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','diapers','wipes','new','featured']::text[], 1650, null, null, null, 'DEMO-050', true, 45, 3, 'no', 'in_stock', false, 1.2, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '450 minutes', now() - interval '450 minutes') returning id into pid;
    if pg_temp.ok(c, 'Baby Brand') and pg_temp.opt('Baby Brand', 'Huggies') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Baby Brand'), pg_temp.opt('Baby Brand', 'Huggies')); end if;
    if pg_temp.ok(c, 'Pack Quantity') and pg_temp.opt('Pack Quantity', 'Pack of 50') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Pack Quantity'), pg_temp.opt('Pack Quantity', 'Pack of 50')); end if;
    if pg_temp.opt('Diaper Size', 'Pants – M') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Diaper Size'), pg_temp.opt('Diaper Size', 'Pants – M'))) t(a, o)), 'DEMO-050-1', 1650, null, 18, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Diaper Size'), pg_temp.opt('Diaper Size', 'Pants – M'));
    end if;
    if pg_temp.opt('Diaper Size', 'Pants – L') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Diaper Size'), pg_temp.opt('Diaper Size', 'Pants – L'))) t(a, o)), 'DEMO-050-2', 1650, null, 21, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Diaper Size'), pg_temp.opt('Diaper Size', 'Pants – L'));
    end if;
    if pg_temp.opt('Diaper Size', 'Pants – XL') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Diaper Size'), pg_temp.opt('Diaper Size', 'Pants – XL'))) t(a, o)), 'DEMO-050-3', 1750, null, 6, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Diaper Size'), pg_temp.opt('Diaper Size', 'Pants – XL'));
    end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000002', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Diapers & Wipes' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 51. Baby Feeding: Philips Avent Feeding Bottle 260ml  [low]
  c := pg_temp.cat('Baby Feeding');
  if c is null then missing := missing || 'Baby Feeding' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Philips Avent Feeding Bottle 260ml', 'ফিলিপস অ্যাভেন্ট ফিডিং বোতল ২৬০ মিলি', 'Anti-colic valve · BPA-free · Natural-feel nipple', 'Philips Avent Feeding Bottle 260ml

• Anti-colic valve
• BPA-free
• Natural-feel nipple

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'কোলিক কমাতে সাহায্য করে এমন নিরাপদ ফিডিং বোতল।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','baby','feeding','new']::text[], 1450, null, null, null, 'DEMO-051', true, 2, 5, 'no', 'in_stock', false, 0.2, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '459 minutes', now() - interval '459 minutes') returning id into pid;
    if pg_temp.ok(c, 'Baby Brand') and pg_temp.opt('Baby Brand', 'Philips Avent') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Baby Brand'), pg_temp.opt('Baby Brand', 'Philips Avent')); end if;
    if pg_temp.ok(c, 'Material') and pg_temp.opt('Material', 'Plastic') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Material'), pg_temp.opt('Material', 'Plastic')); end if;
  exception when others then missing := missing || 'Baby Feeding' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 52. Baby Bath & Skin Care: Johnson's Baby Bath Gift Set  [sale]
  c := pg_temp.cat('Baby Bath & Skin Care');
  if c is null then missing := missing || 'Baby Bath & Skin Care' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Johnson''s Baby Bath Gift Set', 'জনসনস বেবি বাথ গিফট সেট', 'Shampoo, soap, lotion, oil and powder · Gentle for newborn skin · Gift box', 'Johnson''s Baby Bath Gift Set

• Shampoo, soap, lotion, oil and powder
• Gentle for newborn skin
• Gift box

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'নবজাতকের যত্নে ৫টি পণ্যের গিফট সেট।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','baby','bath','skin','new','sale']::text[], 1890, '1609', null, null, 'DEMO-052', true, 19, 3, 'no', 'in_stock', false, 0.9, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '468 minutes', now() - interval '468 minutes') returning id into pid;
    if pg_temp.ok(c, 'Baby Brand') and pg_temp.opt('Baby Brand', 'Johnson''s') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Baby Brand'), pg_temp.opt('Baby Brand', 'Johnson''s')); end if;
  exception when others then missing := missing || 'Baby Bath & Skin Care' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 53. Strollers & Baby Gear: Foldable Baby Stroller  [large neg used]
  c := pg_temp.cat('Strollers & Baby Gear');
  if c is null then missing := missing || 'Strollers & Baby Gear' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Foldable Baby Stroller', 'ফোল্ডেবল বেবি স্ট্রলার', 'Used 6 months, very clean · Folds with one hand · Sun canopy and basket', 'Foldable Baby Stroller

• Used 6 months, very clean
• Folds with one hand
• Sun canopy and basket

Delivery: Ships in 1–2 days. 7-day returns.
Price is negotiable, message or call the seller.

(Demo product for testing RGBKart. The photos will be added later.)', 'মাত্র ৬ মাস ব্যবহৃত, পরিষ্কার ফোল্ডেবল স্ট্রলার।

৭ দিনের মধ্যে ফেরত। দাম আলোচনা সাপেক্ষে।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','strollers','baby','gear','used']::text[], 8900, null, null, null, 'DEMO-053', true, 26, 3, 'no', 'in_stock', false, 7, 60, 45, 35, 'large', '1_2_days', 'all_bangladesh', false, '7_days', 'Check the item when it arrives. Call the shop if anything is wrong.', 'pre_owned', 'simple', true, true, false, null, null, false, null, 0, 'approved', now() - interval '477 minutes', now() - interval '477 minutes') returning id into pid;
    if pg_temp.ok(c, 'Baby Brand') and pg_temp.opt('Baby Brand', 'Chicco') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Baby Brand'), pg_temp.opt('Baby Brand', 'Chicco')); end if;
  exception when others then missing := missing || 'Strollers & Baby Gear' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 54. Men's Shoes: Leather Formal Oxford Shoes  [feat variable]
  c := pg_temp.cat('Men''s Shoes');
  if c is null then missing := missing || 'Men''s Shoes' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Leather Formal Oxford Shoes', 'চামড়ার ফরমাল অক্সফোর্ড জুতা', 'Genuine leather upper · Cushioned insole · Rubber sole', 'Leather Formal Oxford Shoes

• Genuine leather upper
• Cushioned insole
• Rubber sole

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'অফিসের জন্য আসল চামড়ার ফরমাল জুতা।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','mens','shoes','new','featured']::text[], 3450, null, null, null, 'DEMO-054', true, 33, 3, 'no', 'in_stock', false, 1, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '486 minutes', now() - interval '486 minutes') returning id into pid;
    if pg_temp.ok(c, 'Fashion Brand') and pg_temp.opt('Fashion Brand', 'Apex') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fashion Brand'), pg_temp.opt('Fashion Brand', 'Apex')); end if;
    if pg_temp.ok(c, 'Shoe Type') and pg_temp.opt('Shoe Type', 'Formal / Oxford') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Shoe Type'), pg_temp.opt('Shoe Type', 'Formal / Oxford')); end if;
    if pg_temp.ok(c, 'Closure') and pg_temp.opt('Closure', 'Lace-up') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Closure'), pg_temp.opt('Closure', 'Lace-up')); end if;
    if pg_temp.ok(c, 'Sole Material') and pg_temp.opt('Sole Material', 'Rubber') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Sole Material'), pg_temp.opt('Sole Material', 'Rubber')); end if;
    if pg_temp.opt('Shoe Size', 'EU 40') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 40'))) t(a, o)), 'DEMO-054-1', 3450, null, 4, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 40'));
    end if;
    if pg_temp.opt('Shoe Size', 'EU 41') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 41'))) t(a, o)), 'DEMO-054-2', 3450, null, 7, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 41'));
    end if;
    if pg_temp.opt('Shoe Size', 'EU 42') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 42'))) t(a, o)), 'DEMO-054-3', 3450, null, 10, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 42'));
    end if;
    if pg_temp.opt('Shoe Size', 'EU 43') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 43'))) t(a, o)), 'DEMO-054-4', 3450, null, 13, true, 30) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 43'));
    end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000002', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Men''s Shoes' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 55. Women's Shoes: Comfort Block Heel Sandal  [sale variable]
  c := pg_temp.cat('Women''s Shoes');
  if c is null then missing := missing || 'Women''s Shoes' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Comfort Block Heel Sandal', 'কমফোর্ট ব্লক হিল স্যান্ডেল', '2" block heel · Soft padded footbed · Ankle strap', 'Comfort Block Heel Sandal

• 2" block heel
• Soft padded footbed
• Ankle strap

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'সারাদিন পরার মতো আরামদায়ক ব্লক হিল।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','womens','shoes','new','sale']::text[], 1650, '1399', null, null, 'DEMO-055', true, 40, 3, 'no', 'in_stock', false, 0.6, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '495 minutes', now() - interval '495 minutes') returning id into pid;
    if pg_temp.ok(c, 'Fashion Brand') and pg_temp.opt('Fashion Brand', 'Bata') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fashion Brand'), pg_temp.opt('Fashion Brand', 'Bata')); end if;
    if pg_temp.ok(c, 'Shoe Type') and pg_temp.opt('Shoe Type', 'Heels') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Shoe Type'), pg_temp.opt('Shoe Type', 'Heels')); end if;
    if pg_temp.ok(c, 'Closure') and pg_temp.opt('Closure', 'Buckle') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Closure'), pg_temp.opt('Closure', 'Buckle')); end if;
    if pg_temp.opt('Shoe Size', 'EU 36') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 36'))) t(a, o)), 'DEMO-055-1', 1650, 1399, 5, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 36'));
    end if;
    if pg_temp.opt('Shoe Size', 'EU 37') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 37'))) t(a, o)), 'DEMO-055-2', 1650, null, 8, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 37'));
    end if;
    if pg_temp.opt('Shoe Size', 'EU 38') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 38'))) t(a, o)), 'DEMO-055-3', 1650, 1399, 11, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 38'));
    end if;
    if pg_temp.opt('Shoe Size', 'EU 39') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 39'))) t(a, o)), 'DEMO-055-4', 1650, null, 14, true, 30) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 39'));
    end if;
  exception when others then missing := missing || 'Women''s Shoes' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 56. Sports & Running Shoes: Lightweight Running Shoes  [flash freedel variable]
  c := pg_temp.cat('Sports & Running Shoes');
  if c is null then missing := missing || 'Sports & Running Shoes' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Lightweight Running Shoes', 'হালকা রানিং জুতা', 'Breathable mesh upper · EVA cushioning · Grippy rubber outsole', 'Lightweight Running Shoes

• Breathable mesh upper
• EVA cushioning
• Grippy rubber outsole

Delivery: Ships in 1–2 days. 7-day returns. Free delivery.

(Demo product for testing RGBKart. The photos will be added later.)', 'দৌড় ও জিমের জন্য হালকা রানিং জুতা।

৭ দিনের মধ্যে ফেরত। ফ্রি ডেলিভারি।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','sports','running','shoes','new','sale']::text[], 2950, '2509', now() - interval '1 day', now() + interval '2 days', 'DEMO-056', true, 47, 3, 'no', 'in_stock', false, 0.7, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', true, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '504 minutes', now() - interval '504 minutes') returning id into pid;
    if pg_temp.ok(c, 'Sole Material') and pg_temp.opt('Sole Material', 'EVA') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Sole Material'), pg_temp.opt('Sole Material', 'EVA')); end if;
    if pg_temp.ok(c, 'Closure') and pg_temp.opt('Closure', 'Lace-up') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Closure'), pg_temp.opt('Closure', 'Lace-up')); end if;
    if pg_temp.ok(c, 'Gender') and pg_temp.opt('Gender', 'Unisex') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Gender'), pg_temp.opt('Gender', 'Unisex')); end if;
    if pg_temp.opt('Shoe Size', 'EU 40') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 40'))) t(a, o)), 'DEMO-056-1', 2950, 2509, 6, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 40'));
    end if;
    if pg_temp.opt('Shoe Size', 'EU 41') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 41'))) t(a, o)), 'DEMO-056-2', 2950, null, 9, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 41'));
    end if;
    if pg_temp.opt('Shoe Size', 'EU 42') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 42'))) t(a, o)), 'DEMO-056-3', 2950, 2509, 12, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 42'));
    end if;
    if pg_temp.opt('Shoe Size', 'EU 43') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 43'))) t(a, o)), 'DEMO-056-4', 2950, null, 15, true, 30) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 43'));
    end if;
    if pg_temp.opt('Shoe Size', 'EU 44') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 44'))) t(a, o)), 'DEMO-056-5', 2950, 2509, 18, true, 40) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 44'));
    end if;
  exception when others then missing := missing || 'Sports & Running Shoes' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 57. Sandals & Slippers: Comfort Slide Slippers  [bulk small variable]
  c := pg_temp.cat('Sandals & Slippers');
  if c is null then missing := missing || 'Sandals & Slippers' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Comfort Slide Slippers', 'আরামদায়ক স্লাইড স্লিপার', 'Soft EVA, very light · Anti-slip sole · Waterproof', 'Comfort Slide Slippers

• Soft EVA, very light
• Anti-slip sole
• Waterproof

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'ঘরে বাইরে পরার হালকা ও পানিরোধী স্লিপার।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','sandals','slippers','new']::text[], 450, null, null, null, 'DEMO-057', true, 54, 3, 'no', 'in_stock', false, 0.3, 12, 8, 4, 'small', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '513 minutes', now() - interval '513 minutes') returning id into pid;
    if pg_temp.ok(c, 'Shoe Type') and pg_temp.opt('Shoe Type', 'Slippers & Flip-flops') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Shoe Type'), pg_temp.opt('Shoe Type', 'Slippers & Flip-flops')); end if;
    if pg_temp.ok(c, 'Sole Material') and pg_temp.opt('Sole Material', 'EVA') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Sole Material'), pg_temp.opt('Sole Material', 'EVA')); end if;
    if pg_temp.ok(c, 'Gender') and pg_temp.opt('Gender', 'Unisex') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Gender'), pg_temp.opt('Gender', 'Unisex')); end if;
    if pg_temp.opt('Shoe Size', 'EU 39') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 39'))) t(a, o)), 'DEMO-057-1', 450, null, 7, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 39'));
    end if;
    if pg_temp.opt('Shoe Size', 'EU 40') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 40'))) t(a, o)), 'DEMO-057-2', 450, null, 10, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 40'));
    end if;
    if pg_temp.opt('Shoe Size', 'EU 41') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 41'))) t(a, o)), 'DEMO-057-3', 450, null, 13, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 41'));
    end if;
    if pg_temp.opt('Shoe Size', 'EU 42') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 42'))) t(a, o)), 'DEMO-057-4', 450, null, 16, true, 30) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 42'));
    end if;
  exception when others then missing := missing || 'Sandals & Slippers' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 58. Kids' Shoes: Kids Light-up Sneakers  [low variable]
  c := pg_temp.cat('Kids'' Shoes');
  if c is null then missing := missing || 'Kids'' Shoes' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Kids Light-up Sneakers', 'বাচ্চাদের লাইট-আপ স্নিকার্স', 'LED lights flash when walking · Velcro strap, easy to wear · Soft sole', 'Kids Light-up Sneakers

• LED lights flash when walking
• Velcro strap, easy to wear
• Soft sole

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'হাঁটলে আলো জ্বলে, বাচ্চাদের প্রিয় স্নিকার্স।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','kids','shoes','new']::text[], 1250, null, null, null, 'DEMO-058', true, 2, 5, 'no', 'in_stock', false, 0.5, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '522 minutes', now() - interval '522 minutes') returning id into pid;
    if pg_temp.ok(c, 'Shoe Type') and pg_temp.opt('Shoe Type', 'Sneakers') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Shoe Type'), pg_temp.opt('Shoe Type', 'Sneakers')); end if;
    if pg_temp.ok(c, 'Closure') and pg_temp.opt('Closure', 'Velcro') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Closure'), pg_temp.opt('Closure', 'Velcro')); end if;
    if pg_temp.ok(c, 'Gender') and pg_temp.opt('Gender', 'Unisex') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Gender'), pg_temp.opt('Gender', 'Unisex')); end if;
    if pg_temp.opt('Shoe Size', 'EU 26') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 26'))) t(a, o)), 'DEMO-058-1', 1250, null, 2, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 26'));
    end if;
    if pg_temp.opt('Shoe Size', 'EU 27') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 27'))) t(a, o)), 'DEMO-058-2', 1250, null, 11, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 27'));
    end if;
    if pg_temp.opt('Shoe Size', 'EU 28') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 28'))) t(a, o)), 'DEMO-058-3', 1250, null, 14, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 28'));
    end if;
    if pg_temp.opt('Shoe Size', 'EU 29') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 29'))) t(a, o)), 'DEMO-058-4', 1250, null, 17, true, 30) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Shoe Size'), pg_temp.opt('Shoe Size', 'EU 29'));
    end if;
  exception when others then missing := missing || 'Kids'' Shoes' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 59. Watches: Casio Analog Steel Watch MTP-1302  [feat sale]
  c := pg_temp.cat('Watches');
  if c is null then missing := missing || 'Watches' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Casio Analog Steel Watch MTP-1302', 'ক্যাসিও অ্যানালগ স্টিল ঘড়ি MTP-1302', 'Original Casio · Stainless steel strap · Water resistant 50 m', 'Casio Analog Steel Watch MTP-1302

• Original Casio
• Stainless steel strap
• Water resistant 50 m

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'অরিজিনাল ক্যাসিও স্টিল ঘড়ি।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','watches','new','sale','featured']::text[], 4200, '3569', null, null, 'DEMO-059', true, 28, 3, 'no', 'in_stock', false, 0.15, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '531 minutes', now() - interval '531 minutes') returning id into pid;
    if pg_temp.ok(c, 'Watch Brand') and pg_temp.opt('Watch Brand', 'Casio') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Watch Brand'), pg_temp.opt('Watch Brand', 'Casio')); end if;
    if pg_temp.ok(c, 'Watch Type') and pg_temp.opt('Watch Type', 'Analog') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Watch Type'), pg_temp.opt('Watch Type', 'Analog')); end if;
    if pg_temp.ok(c, 'Strap Material') and pg_temp.opt('Strap Material', 'Stainless Steel') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Strap Material'), pg_temp.opt('Strap Material', 'Stainless Steel')); end if;
    if pg_temp.ok(c, 'Water Resistance') and pg_temp.opt('Water Resistance', '50 m / 5 ATM') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Water Resistance'), pg_temp.opt('Water Resistance', '50 m / 5 ATM')); end if;
    if pg_temp.ok(c, 'Gender') and pg_temp.opt('Gender', 'Men') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Gender'), pg_temp.opt('Gender', 'Men')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000002', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Watches' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 60. Bags & Backpacks: Water-resistant Laptop Backpack  [freedel variable]
  c := pg_temp.cat('Bags & Backpacks');
  if c is null then missing := missing || 'Bags & Backpacks' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Water-resistant Laptop Backpack', 'পানিরোধী ল্যাপটপ ব্যাকপ্যাক', 'Fits up to 15.6" laptop · USB charging port · Water-resistant fabric', 'Water-resistant Laptop Backpack

• Fits up to 15.6" laptop
• USB charging port
• Water-resistant fabric

Delivery: Ships in 1–2 days. 7-day returns. Free delivery.

(Demo product for testing RGBKart. The photos will be added later.)', 'অফিস ও ভার্সিটির জন্য পানিরোধী ল্যাপটপ ব্যাগ।

৭ দিনের মধ্যে ফেরত। ফ্রি ডেলিভারি।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','bags','backpacks','new']::text[], 1890, null, null, null, 'DEMO-060', true, 35, 3, 'no', 'in_stock', false, 0.8, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', true, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '540 minutes', now() - interval '540 minutes') returning id into pid;
    if pg_temp.ok(c, 'Bag Type') and pg_temp.opt('Bag Type', 'Laptop Bag') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Bag Type'), pg_temp.opt('Bag Type', 'Laptop Bag')); end if;
    if pg_temp.ok(c, 'Material') and pg_temp.opt('Material', 'Fabric') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Material'), pg_temp.opt('Material', 'Fabric')); end if;
    if pg_temp.ok(c, 'Gender') and pg_temp.opt('Gender', 'Unisex') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Gender'), pg_temp.opt('Gender', 'Unisex')); end if;
    if pg_temp.opt('Colour', 'Black') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'))) t(a, o)), 'DEMO-060-1', 1890, null, 10, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Black'));
    end if;
    if pg_temp.opt('Colour', 'Grey') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Grey'))) t(a, o)), 'DEMO-060-2', 1890, null, 13, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Grey'));
    end if;
    if pg_temp.opt('Colour', 'Navy') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Navy'))) t(a, o)), 'DEMO-060-3', 1890, null, 16, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Navy'));
    end if;
  exception when others then missing := missing || 'Bags & Backpacks' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 61. Skin Care: CeraVe Hydrating Facial Cleanser 236ml  [feat]
  c := pg_temp.cat('Skin Care');
  if c is null then missing := missing || 'Skin Care' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'CeraVe Hydrating Facial Cleanser 236ml', 'সেরাভি হাইড্রেটিং ফেসিয়াল ক্লিনজার ২৩৬ মিলি', 'With ceramides and hyaluronic acid · For normal to dry skin · Fragrance-free', 'CeraVe Hydrating Facial Cleanser 236ml

• With ceramides and hyaluronic acid
• For normal to dry skin
• Fragrance-free

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'ত্বক শুষ্ক না করে পরিষ্কার করে এমন ক্লিনজার।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','skin','care','new','featured']::text[], 1850, null, null, null, 'DEMO-061', true, 42, 3, 'no', 'in_stock', false, 0.3, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '549 minutes', now() - interval '549 minutes') returning id into pid;
    if pg_temp.ok(c, 'Beauty Brand') and pg_temp.opt('Beauty Brand', 'CeraVe') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Beauty Brand'), pg_temp.opt('Beauty Brand', 'CeraVe')); end if;
    if pg_temp.ok(c, 'Skin Type') and pg_temp.opt('Skin Type', 'Dry') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Skin Type'), pg_temp.opt('Skin Type', 'Dry')); end if;
    if pg_temp.ok(c, 'Formulation') and pg_temp.opt('Formulation', 'Foam / Cleanser') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Formulation'), pg_temp.opt('Formulation', 'Foam / Cleanser')); end if;
    if pg_temp.ok(c, 'Country of Origin') and pg_temp.opt('Country of Origin', 'USA') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Country of Origin'), pg_temp.opt('Country of Origin', 'USA')); end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000002', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Skin Care' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 62. Hair Care: Parachute Advansed Coconut Hair Oil  [bulk small variable]
  c := pg_temp.cat('Hair Care');
  if c is null then missing := missing || 'Hair Care' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Parachute Advansed Coconut Hair Oil', 'প্যারাস্যুট অ্যাডভান্সড নারকেল তেল', 'Pure coconut oil · Strong, healthy hair · Non-sticky', 'Parachute Advansed Coconut Hair Oil

• Pure coconut oil
• Strong, healthy hair
• Non-sticky

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'চুলের যত্নে খাঁটি নারকেল তেল।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','hair','care','new']::text[], 260, null, null, null, 'DEMO-062', true, 49, 3, 'no', 'in_stock', false, 0.25, 12, 8, 4, 'small', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '558 minutes', now() - interval '558 minutes') returning id into pid;
    if pg_temp.ok(c, 'Beauty Brand') and pg_temp.opt('Beauty Brand', 'Parachute') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Beauty Brand'), pg_temp.opt('Beauty Brand', 'Parachute')); end if;
    if pg_temp.ok(c, 'Hair Type') and pg_temp.opt('Hair Type', 'All hair types') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Hair Type'), pg_temp.opt('Hair Type', 'All hair types')); end if;
    if pg_temp.ok(c, 'Formulation') and pg_temp.opt('Formulation', 'Oil') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Formulation'), pg_temp.opt('Formulation', 'Oil')); end if;
    if pg_temp.opt('Pack Size', '200 g / ml') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '200 g / ml'))) t(a, o)), 'DEMO-062-1', 260, null, 12, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '200 g / ml'));
    end if;
    if pg_temp.opt('Pack Size', '400 g / ml') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '400 g / ml'))) t(a, o)), 'DEMO-062-2', 480, null, 15, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '400 g / ml'));
    end if;
  exception when others then missing := missing || 'Hair Care' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 63. Makeup: Maybelline SuperStay Matte Lipstick  [sale small variable]
  c := pg_temp.cat('Makeup');
  if c is null then missing := missing || 'Makeup' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Maybelline SuperStay Matte Lipstick', 'মেবেলিন সুপারস্টে ম্যাট লিপস্টিক', 'Lasts up to 16 hours · Matte finish · Transfer-proof', 'Maybelline SuperStay Matte Lipstick

• Lasts up to 16 hours
• Matte finish
• Transfer-proof

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'দীর্ঘস্থায়ী ম্যাট লিপস্টিক।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','makeup','new','sale']::text[], 1150, '979', null, null, 'DEMO-063', true, 16, 3, 'no', 'in_stock', false, 0.05, 12, 8, 4, 'small', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '567 minutes', now() - interval '567 minutes') returning id into pid;
    if pg_temp.ok(c, 'Beauty Brand') and pg_temp.opt('Beauty Brand', 'Maybelline') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Beauty Brand'), pg_temp.opt('Beauty Brand', 'Maybelline')); end if;
    if pg_temp.ok(c, 'Formulation') and pg_temp.opt('Formulation', 'Liquid') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Formulation'), pg_temp.opt('Formulation', 'Liquid')); end if;
    if pg_temp.opt('Colour', 'Red') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Red'))) t(a, o)), 'DEMO-063-1', 1150, 979, 13, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Red'));
    end if;
    if pg_temp.opt('Colour', 'Maroon') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Maroon'))) t(a, o)), 'DEMO-063-2', 1150, null, 16, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Maroon'));
    end if;
    if pg_temp.opt('Colour', 'Pink') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Pink'))) t(a, o)), 'DEMO-063-3', 1150, 979, 19, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Pink'));
    end if;
  exception when others then missing := missing || 'Makeup' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 64. Fragrances: Fogg Body Spray  [bulk flash variable]
  c := pg_temp.cat('Fragrances');
  if c is null then missing := missing || 'Fragrances' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Fogg Body Spray', 'ফগ বডি স্প্রে', 'Long-lasting fragrance · No gas, all perfume · For men', 'Fogg Body Spray

• Long-lasting fragrance
• No gas, all perfume
• For men

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'দীর্ঘস্থায়ী সুগন্ধি বডি স্প্রে।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','fragrances','new','sale']::text[], 450, '380', now() - interval '1 day', now() + interval '2 days', 'DEMO-064', true, 23, 3, 'no', 'in_stock', false, 0.2, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '576 minutes', now() - interval '576 minutes') returning id into pid;
    if pg_temp.ok(c, 'Beauty Brand') and pg_temp.opt('Beauty Brand', 'Fogg') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Beauty Brand'), pg_temp.opt('Beauty Brand', 'Fogg')); end if;
    if pg_temp.ok(c, 'Fragrance Type') and pg_temp.opt('Fragrance Type', 'Body Spray / Mist') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fragrance Type'), pg_temp.opt('Fragrance Type', 'Body Spray / Mist')); end if;
    if pg_temp.ok(c, 'Gender') and pg_temp.opt('Gender', 'Men') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Gender'), pg_temp.opt('Gender', 'Men')); end if;
    if pg_temp.opt('Pack Size', '100 g / ml') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '100 g / ml'))) t(a, o)), 'DEMO-064-1', 450, 380, 14, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '100 g / ml'));
    end if;
    if pg_temp.opt('Pack Size', '150 g / ml') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '150 g / ml'))) t(a, o)), 'DEMO-064-2', 570, null, 17, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '150 g / ml'));
    end if;
  exception when others then missing := missing || 'Fragrances' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 65. Personal Care & Hygiene: Dettol Antiseptic Liquid 500ml  [bulk]
  c := pg_temp.cat('Personal Care & Hygiene');
  if c is null then missing := missing || 'Personal Care & Hygiene' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Dettol Antiseptic Liquid 500ml', 'ডেটল অ্যান্টিসেপটিক লিকুইড ৫০০ মিলি', 'Kills 99.9% germs · For first aid and bathing · 500 ml bottle', 'Dettol Antiseptic Liquid 500ml

• Kills 99.9% germs
• For first aid and bathing
• 500 ml bottle

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'জীবাণুনাশক ডেটল লিকুইড।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','personal','care','hygiene','new']::text[], 320, null, null, null, 'DEMO-065', true, 30, 3, 'no', 'in_stock', false, 0.6, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '585 minutes', now() - interval '585 minutes') returning id into pid;
    if pg_temp.ok(c, 'Pack Size') and pg_temp.opt('Pack Size', '500 g / ml') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '500 g / ml')); end if;
    insert into public.product_price_tiers (product_id, min_qty, unit_price) values (pid, 3, 304), (pid, 10, 288);
  exception when others then missing := missing || 'Personal Care & Hygiene' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 66. Rice, Dal & Flour: Chinigura Aromatic Rice  [bulk dhaka same variable]
  c := pg_temp.cat('Rice, Dal & Flour');
  if c is null then missing := missing || 'Rice, Dal & Flour' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Chinigura Aromatic Rice', 'চিনিগুঁড়া সুগন্ধি চাল', 'Premium aromatic rice · For polao and biryani · Cleaned and sorted', 'Chinigura Aromatic Rice

• Premium aromatic rice
• For polao and biryani
• Cleaned and sorted

Delivery: Ships today. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'পোলাও ও বিরিয়ানির জন্য সুগন্ধি চিনিগুঁড়া চাল। (শুধু ঢাকার ভিতরে)

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','rice','dal','flour','new']::text[], 690, null, null, null, 'DEMO-066', true, 37, 3, 'no', 'in_stock', false, 5, 30, 22, 10, 'standard', 'same_day', 'inside_dhaka', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '594 minutes', now() - interval '594 minutes') returning id into pid;
    if pg_temp.ok(c, 'Grocery Brand') and pg_temp.opt('Grocery Brand', 'Pran') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Grocery Brand'), pg_temp.opt('Grocery Brand', 'Pran')); end if;
    if pg_temp.ok(c, 'Dietary') and pg_temp.opt('Dietary', 'Halal') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Dietary'), pg_temp.opt('Dietary', 'Halal')); end if;
    if pg_temp.ok(c, 'Country of Origin') and pg_temp.opt('Country of Origin', 'Bangladesh') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Country of Origin'), pg_temp.opt('Country of Origin', 'Bangladesh')); end if;
    if pg_temp.opt('Pack Size', '2 kg / 2 L') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '2 kg / 2 L'))) t(a, o)), 'DEMO-066-1', 690, null, 16, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '2 kg / 2 L'));
    end if;
    if pg_temp.opt('Pack Size', '5 kg / 5 L') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '5 kg / 5 L'))) t(a, o)), 'DEMO-066-2', 1590, null, 19, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '5 kg / 5 L'));
    end if;
  exception when others then missing := missing || 'Rice, Dal & Flour' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 67. Cooking Oil & Spices: Teer Soybean Oil  [bulk dhaka variable]
  c := pg_temp.cat('Cooking Oil & Spices');
  if c is null then missing := missing || 'Cooking Oil & Spices' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Teer Soybean Oil', 'তীর সয়াবিন তেল', 'Fortified with vitamin A · Pure soybean oil · Sealed bottle', 'Teer Soybean Oil

• Fortified with vitamin A
• Pure soybean oil
• Sealed bottle

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'ভিটামিন এ সমৃদ্ধ সয়াবিন তেল।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','cooking','oil','spices','new']::text[], 395, null, null, null, 'DEMO-067', true, 44, 3, 'no', 'in_stock', false, 2, 30, 22, 10, 'standard', '1_2_days', 'inside_dhaka', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '603 minutes', now() - interval '603 minutes') returning id into pid;
    if pg_temp.ok(c, 'Grocery Brand') and pg_temp.opt('Grocery Brand', 'Teer') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Grocery Brand'), pg_temp.opt('Grocery Brand', 'Teer')); end if;
    if pg_temp.ok(c, 'Dietary') and pg_temp.opt('Dietary', 'Halal') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Dietary'), pg_temp.opt('Dietary', 'Halal')); end if;
    if pg_temp.opt('Pack Size', '1 kg / 1 L') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '1 kg / 1 L'))) t(a, o)), 'DEMO-067-1', 395, null, 17, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '1 kg / 1 L'));
    end if;
    if pg_temp.opt('Pack Size', '2 kg / 2 L') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '2 kg / 2 L'))) t(a, o)), 'DEMO-067-2', 785, null, 20, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '2 kg / 2 L'));
    end if;
    if pg_temp.opt('Pack Size', '5 kg / 5 L') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '5 kg / 5 L'))) t(a, o)), 'DEMO-067-3', 1885, null, 5, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '5 kg / 5 L'));
    end if;
  exception when others then missing := missing || 'Cooking Oil & Spices' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 68. Snacks & Beverages: Pran Potato Crackers (Pack of 12)  [bulk dhaka sale]
  c := pg_temp.cat('Snacks & Beverages');
  if c is null then missing := missing || 'Snacks & Beverages' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Pran Potato Crackers (Pack of 12)', 'প্রাণ পটেটো ক্র্যাকার্স (১২টির প্যাক)', 'Crispy and tasty · 12 small packs · Great for tiffin', 'Pran Potato Crackers (Pack of 12)

• Crispy and tasty
• 12 small packs
• Great for tiffin

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'টিফিনের জন্য মুচমুচে পটেটো ক্র্যাকার্স।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','snacks','beverages','new','sale']::text[], 240, '200', null, null, 'DEMO-068', true, 51, 3, 'no', 'in_stock', false, 0.4, 30, 22, 10, 'standard', '1_2_days', 'inside_dhaka', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '612 minutes', now() - interval '612 minutes') returning id into pid;
    if pg_temp.ok(c, 'Grocery Brand') and pg_temp.opt('Grocery Brand', 'Pran') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Grocery Brand'), pg_temp.opt('Grocery Brand', 'Pran')); end if;
    if pg_temp.ok(c, 'Pack Quantity') and pg_temp.opt('Pack Quantity', 'Pack of 12') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Pack Quantity'), pg_temp.opt('Pack Quantity', 'Pack of 12')); end if;
    insert into public.product_price_tiers (product_id, min_qty, unit_price) values (pid, 3, 190), (pid, 10, 180);
  exception when others then missing := missing || 'Snacks & Beverages' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 69. Dairy & Breakfast: Aarong Dairy Full Cream Milk Powder 1kg  [dhaka feat]
  c := pg_temp.cat('Dairy & Breakfast');
  if c is null then missing := missing || 'Dairy & Breakfast' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Aarong Dairy Full Cream Milk Powder 1kg', 'আড়ং ডেইরি ফুল ক্রিম মিল্ক পাউডার ১ কেজি', 'Rich and creamy · For tea and family · Resealable pack', 'Aarong Dairy Full Cream Milk Powder 1kg

• Rich and creamy
• For tea and family
• Resealable pack

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'চা ও পরিবারের জন্য ফুল ক্রিম গুঁড়া দুধ।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','dairy','breakfast','new','featured']::text[], 920, null, null, null, 'DEMO-069', true, 18, 3, 'no', 'in_stock', false, 1.1, 30, 22, 10, 'standard', '1_2_days', 'inside_dhaka', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '621 minutes', now() - interval '621 minutes') returning id into pid;
    if pg_temp.ok(c, 'Grocery Brand') and pg_temp.opt('Grocery Brand', 'Aarong Dairy') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Grocery Brand'), pg_temp.opt('Grocery Brand', 'Aarong Dairy')); end if;
    if pg_temp.ok(c, 'Pack Size') and pg_temp.opt('Pack Size', '1 kg / 1 L') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '1 kg / 1 L')); end if;
    if pg_temp.ok(c, 'Dietary') and pg_temp.opt('Dietary', 'Halal') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Dietary'), pg_temp.opt('Dietary', 'Halal')); end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000002', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Dairy & Breakfast' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 70. Household Cleaning: Vim Dishwashing Liquid 500ml  [bulk freedel]
  c := pg_temp.cat('Household Cleaning');
  if c is null then missing := missing || 'Household Cleaning' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Vim Dishwashing Liquid 500ml', 'ভিম ডিশওয়াশিং লিকুইড ৫০০ মিলি', 'Removes grease fast · Lemon fresh · Gentle on hands', 'Vim Dishwashing Liquid 500ml

• Removes grease fast
• Lemon fresh
• Gentle on hands

Delivery: Ships in 1–2 days. 7-day returns. Free delivery.

(Demo product for testing RGBKart. The photos will be added later.)', 'থালাবাসন ঝকঝকে করতে লেবুর গন্ধের ভিম লিকুইড।

৭ দিনের মধ্যে ফেরত। ফ্রি ডেলিভারি।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','household','cleaning','new']::text[], 175, null, null, null, 'DEMO-070', true, 25, 3, 'no', 'in_stock', false, 0.55, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', true, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '630 minutes', now() - interval '630 minutes') returning id into pid;
    if pg_temp.ok(c, 'Pack Size') and pg_temp.opt('Pack Size', '500 g / ml') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Pack Size'), pg_temp.opt('Pack Size', '500 g / ml')); end if;
    insert into public.product_price_tiers (product_id, min_qty, unit_price) values (pid, 3, 166), (pid, 10, 158);
  exception when others then missing := missing || 'Household Cleaning' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 71. Furniture: Used 3-seater Wooden Sofa  [used]
  c := pg_temp.cat('Furniture');
  if c is null then missing := missing || 'Furniture' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000003', c, 'Used 3-seater Wooden Sofa', 'ব্যবহৃত ৩ সিটের কাঠের সোফা', 'Segun wood frame · Used 3 years, new cushion covers · Pick up from Mirpur', 'Used 3-seater Wooden Sofa

• Segun wood frame
• Used 3 years, new cushion covers
• Pick up from Mirpur

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'সেগুন কাঠের ৩ সিটের সোফা, ৩ বছর ব্যবহৃত, কুশন কভার নতুন।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','furniture','used']::text[], 18000, null, null, null, 'DEMO-071', true, 1, 3, 'no', 'in_stock', false, 40, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', null, 'pre_owned', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '639 minutes', now() - interval '639 minutes') returning id into pid;
    if pg_temp.ok(c, 'Material') and pg_temp.opt('Material', 'Solid Wood (Segun/Teak)') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Material'), pg_temp.opt('Material', 'Solid Wood (Segun/Teak)')); end if;
    if pg_temp.ok(c, 'Seating Capacity') and pg_temp.opt('Seating Capacity', '3 seater') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Seating Capacity'), pg_temp.opt('Seating Capacity', '3 seater')); end if;
  exception when others then missing := missing || 'Furniture' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 72. Bedding & Bath: Cotton Bed Sheet Set (Double)  [freedel sale variable]
  c := pg_temp.cat('Bedding & Bath');
  if c is null then missing := missing || 'Bedding & Bath' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Cotton Bed Sheet Set (Double)', 'সুতির বেডশিট সেট (ডাবল)', '1 bed sheet + 2 pillow covers · Soft 100% cotton · Colour-fast', 'Cotton Bed Sheet Set (Double)

• 1 bed sheet + 2 pillow covers
• Soft 100% cotton
• Colour-fast

Delivery: Ships in 1–2 days. 7-day returns. Free delivery.

(Demo product for testing RGBKart. The photos will be added later.)', 'নরম সুতির বেডশিট, দুটি বালিশের কভারসহ।

৭ দিনের মধ্যে ফেরত। ফ্রি ডেলিভারি।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','bedding','bath','new','sale']::text[], 1650, '1399', null, null, 'DEMO-072', true, 39, 3, 'no', 'in_stock', false, 1.2, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', true, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '648 minutes', now() - interval '648 minutes') returning id into pid;
    if pg_temp.ok(c, 'Fabric') and pg_temp.opt('Fabric', '100% Cotton') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Fabric'), pg_temp.opt('Fabric', '100% Cotton')); end if;
    if pg_temp.ok(c, 'Room') and pg_temp.opt('Room', 'Bedroom') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Room'), pg_temp.opt('Room', 'Bedroom')); end if;
    if pg_temp.opt('Bed Size', 'Double (5 × 6.5 ft)') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Bed Size'), pg_temp.opt('Bed Size', 'Double (5 × 6.5 ft)'))) t(a, o)), 'DEMO-072-1', 1650, 1399, 4, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Bed Size'), pg_temp.opt('Bed Size', 'Double (5 × 6.5 ft)'));
    end if;
    if pg_temp.opt('Bed Size', 'King (6 × 7 ft)') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Bed Size'), pg_temp.opt('Bed Size', 'King (6 × 7 ft)'))) t(a, o)), 'DEMO-072-2', 2000, null, 7, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Bed Size'), pg_temp.opt('Bed Size', 'King (6 × 7 ft)'));
    end if;
  exception when others then missing := missing || 'Bedding & Bath' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 73. Cookware & Dining: Non-stick Cookware Set (5 pcs)  [feat]
  c := pg_temp.cat('Cookware & Dining');
  if c is null then missing := missing || 'Cookware & Dining' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Non-stick Cookware Set (5 pcs)', 'নন-স্টিক রান্নার পাত্র সেট (৫ পিস)', 'Frying pan, kadai, saucepan and lids · Induction compatible · PFOA-free coating', 'Non-stick Cookware Set (5 pcs)

• Frying pan, kadai, saucepan and lids
• Induction compatible
• PFOA-free coating

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'ইন্ডাকশনে চলে এমন ৫ পিসের নন-স্টিক সেট।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','cookware','dining','new','featured']::text[], 4650, null, null, null, 'DEMO-073', true, 46, 3, 'no', 'in_stock', false, 4, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '657 minutes', now() - interval '657 minutes') returning id into pid;
    if pg_temp.ok(c, 'Material') and pg_temp.opt('Material', 'Non-stick Coated') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Material'), pg_temp.opt('Material', 'Non-stick Coated')); end if;
    if pg_temp.ok(c, 'Induction Compatible') then insert into public.product_attribute_values (product_id, attribute_id, bool_value) values (pid, pg_temp.attr('Induction Compatible'), true); end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000002', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Cookware & Dining' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 74. Home Décor: Handmade Jute Wall Hanging  [flash]
  c := pg_temp.cat('Home Décor');
  if c is null then missing := missing || 'Home Décor' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Handmade Jute Wall Hanging', 'হাতে তৈরি পাটের ওয়াল হ্যাঙ্গিং', 'Made by rural artisans · Natural jute · 60 × 45 cm', 'Handmade Jute Wall Hanging

• Made by rural artisans
• Natural jute
• 60 × 45 cm

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'গ্রামীণ কারিগরদের হাতে তৈরি পাটের দেয়ালসজ্জা।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','home','décor','new','sale']::text[], 850, '720', now() - interval '1 day', now() + interval '2 days', 'DEMO-074', true, 53, 3, 'no', 'in_stock', false, 0.4, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '666 minutes', now() - interval '666 minutes') returning id into pid;
    if pg_temp.ok(c, 'Material') and pg_temp.opt('Material', 'Jute') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Material'), pg_temp.opt('Material', 'Jute')); end if;
    if pg_temp.ok(c, 'Room') and pg_temp.opt('Room', 'Living Room') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Room'), pg_temp.opt('Room', 'Living Room')); end if;
    if pg_temp.ok(c, 'Room') and pg_temp.opt('Room', 'Bedroom') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Room'), pg_temp.opt('Room', 'Bedroom')); end if;
  exception when others then missing := missing || 'Home Décor' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 75. Lighting: Philips 12W LED Bulb (Pack of 4)  [bulk variable]
  c := pg_temp.cat('Lighting');
  if c is null then missing := missing || 'Lighting' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Philips 12W LED Bulb (Pack of 4)', 'ফিলিপস ১২ ওয়াট এলইডি বাল্ব (৪টির প্যাক)', 'Bright light, low bill · Lasts 15,000 hours · B22 pin type', 'Philips 12W LED Bulb (Pack of 4)

• Bright light, low bill
• Lasts 15,000 hours
• B22 pin type

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'বিদ্যুৎ সাশ্রয়ী উজ্জ্বল এলইডি বাল্ব।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','lighting','new']::text[], 980, null, null, null, 'DEMO-075', true, 20, 3, 'no', 'in_stock', false, 0.4, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '675 minutes', now() - interval '675 minutes') returning id into pid;
    if pg_temp.opt('Light Colour', 'Cool White / Daylight') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Light Colour'), pg_temp.opt('Light Colour', 'Cool White / Daylight'))) t(a, o)), 'DEMO-075-1', 980, null, 7, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Light Colour'), pg_temp.opt('Light Colour', 'Cool White / Daylight'));
    end if;
    if pg_temp.opt('Light Colour', 'Warm White') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Light Colour'), pg_temp.opt('Light Colour', 'Warm White'))) t(a, o)), 'DEMO-075-2', 980, null, 10, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Light Colour'), pg_temp.opt('Light Colour', 'Warm White'));
    end if;
  exception when others then missing := missing || 'Lighting' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 76. Cricket: Kashmir Willow Cricket Bat  [feat variable]
  c := pg_temp.cat('Cricket');
  if c is null then missing := missing || 'Cricket' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Kashmir Willow Cricket Bat', 'কাশ্মীর উইলো ক্রিকেট ব্যাট', 'Kashmir willow, pre-knocked · Cover included · For leather and tennis ball', 'Kashmir Willow Cricket Bat

• Kashmir willow, pre-knocked
• Cover included
• For leather and tennis ball

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'কভারসহ কাশ্মীর উইলো ক্রিকেট ব্যাট।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','cricket','new','featured']::text[], 2450, null, null, null, 'DEMO-076', true, 27, 3, 'no', 'in_stock', false, 1.2, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '684 minutes', now() - interval '684 minutes') returning id into pid;
    if pg_temp.ok(c, 'Sports Brand') and pg_temp.opt('Sports Brand', 'SG') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Sports Brand'), pg_temp.opt('Sports Brand', 'SG')); end if;
    if pg_temp.ok(c, 'Bat Willow') and pg_temp.opt('Bat Willow', 'Kashmir Willow') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Bat Willow'), pg_temp.opt('Bat Willow', 'Kashmir Willow')); end if;
    if pg_temp.opt('Bat Size', 'Size 5') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Bat Size'), pg_temp.opt('Bat Size', 'Size 5'))) t(a, o)), 'DEMO-076-1', 2450, null, 8, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Bat Size'), pg_temp.opt('Bat Size', 'Size 5'));
    end if;
    if pg_temp.opt('Bat Size', 'Size 6') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Bat Size'), pg_temp.opt('Bat Size', 'Size 6'))) t(a, o)), 'DEMO-076-2', 2450, null, 11, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Bat Size'), pg_temp.opt('Bat Size', 'Size 6'));
    end if;
    if pg_temp.opt('Bat Size', 'Short Handle (SH)') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Bat Size'), pg_temp.opt('Bat Size', 'Short Handle (SH)'))) t(a, o)), 'DEMO-076-3', 2850, null, 14, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Bat Size'), pg_temp.opt('Bat Size', 'Short Handle (SH)'));
    end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000002', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Cricket' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 77. Football: Molten Match Football  [sale variable]
  c := pg_temp.cat('Football');
  if c is null then missing := missing || 'Football' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Molten Match Football', 'মোল্টেন ম্যাচ ফুটবল', 'Official size and weight · Durable PU cover · Good for grass and turf', 'Molten Match Football

• Official size and weight
• Durable PU cover
• Good for grass and turf

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'মাঠ ও টার্ফের জন্য টেকসই ম্যাচ ফুটবল।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','football','new','sale']::text[], 2200, '1869', null, null, 'DEMO-077', true, 34, 3, 'no', 'in_stock', false, 0.45, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '693 minutes', now() - interval '693 minutes') returning id into pid;
    if pg_temp.ok(c, 'Sports Brand') and pg_temp.opt('Sports Brand', 'Molten') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Sports Brand'), pg_temp.opt('Sports Brand', 'Molten')); end if;
    if pg_temp.opt('Ball Size', 'Size 4') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Ball Size'), pg_temp.opt('Ball Size', 'Size 4'))) t(a, o)), 'DEMO-077-1', 2200, 1869, 9, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Ball Size'), pg_temp.opt('Ball Size', 'Size 4'));
    end if;
    if pg_temp.opt('Ball Size', 'Size 5') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Ball Size'), pg_temp.opt('Ball Size', 'Size 5'))) t(a, o)), 'DEMO-077-2', 2200, null, 12, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Ball Size'), pg_temp.opt('Ball Size', 'Size 5'));
    end if;
  exception when others then missing := missing || 'Football' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 78. Badminton & Racket Sports: Yonex Nanoray Badminton Racket  [sale]
  c := pg_temp.cat('Badminton & Racket Sports');
  if c is null then missing := missing || 'Badminton & Racket Sports' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Yonex Nanoray Badminton Racket', 'ইয়োনেক্স ন্যানোরে ব্যাডমিন্টন র‍্যাকেট', 'Light graphite frame · Head-light balance for fast play · Full cover', 'Yonex Nanoray Badminton Racket

• Light graphite frame
• Head-light balance for fast play
• Full cover

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'দ্রুত খেলার জন্য হালকা গ্রাফাইট র‍্যাকেট।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','badminton','racket','sports','new','sale']::text[], 3800, '3229', null, null, 'DEMO-078', true, 41, 3, 'no', 'in_stock', false, 0.2, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '702 minutes', now() - interval '702 minutes') returning id into pid;
    if pg_temp.ok(c, 'Sports Brand') and pg_temp.opt('Sports Brand', 'Yonex') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Sports Brand'), pg_temp.opt('Sports Brand', 'Yonex')); end if;
  exception when others then missing := missing || 'Badminton & Racket Sports' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 79. Gym & Fitness Equipment: Adjustable Dumbbell Set 20kg  [d35 heavy]
  c := pg_temp.cat('Gym & Fitness Equipment');
  if c is null then missing := missing || 'Gym & Fitness Equipment' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Adjustable Dumbbell Set 20kg', 'অ্যাডজাস্টেবল ডাম্বেল সেট ২০ কেজি', 'Two handles with plates · Total 20 kg · Case included', 'Adjustable Dumbbell Set 20kg

• Two handles with plates
• Total 20 kg
• Case included

Delivery: Ships in 3–5 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'ঘরে ব্যায়ামের জন্য অ্যাডজাস্টেবল ডাম্বেল সেট।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','gym','fitness','equipment','new']::text[], 4800, null, null, null, 'DEMO-079', true, 48, 3, 'no', 'in_stock', false, 21, 90, 70, 60, 'heavy', '3_5_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '711 minutes', now() - interval '711 minutes') returning id into pid;
    if pg_temp.ok(c, 'Max User Weight') and pg_temp.opt('Max User Weight', 'Up to 100 kg') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Max User Weight'), pg_temp.opt('Max User Weight', 'Up to 100 kg')); end if;
  exception when others then missing := missing || 'Gym & Fitness Equipment' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 80. Cycling: Used Phoenix Mountain Bicycle 26"  [feat1 neg used]
  c := pg_temp.cat('Cycling');
  if c is null then missing := missing || 'Cycling' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000003', c, 'Used Phoenix Mountain Bicycle 26"', 'ব্যবহৃত ফিনিক্স মাউন্টেন সাইকেল ২৬"', '21 gears, front suspension · New tyres · Used 1 year', 'Used Phoenix Mountain Bicycle 26"

• 21 gears, front suspension
• New tyres
• Used 1 year

Delivery: Ships in 1–2 days. 7-day returns.
Price is negotiable, message or call the seller.

(Demo product for testing RGBKart. The photos will be added later.)', 'এক বছর ব্যবহৃত মাউন্টেন সাইকেল, নতুন টায়ার।

৭ দিনের মধ্যে ফেরত। দাম আলোচনা সাপেক্ষে।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','cycling','used','featured']::text[], 9500, null, null, null, 'DEMO-080', true, 1, 3, 'no', 'in_stock', false, 15, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', null, 'pre_owned', 'simple', true, true, false, null, null, false, null, 0, 'approved', now() - interval '720 minutes', now() - interval '720 minutes') returning id into pid;
    if pg_temp.ok(c, 'Sports Brand') and pg_temp.opt('Sports Brand', 'Phoenix') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Sports Brand'), pg_temp.opt('Sports Brand', 'Phoenix')); end if;
    if pg_temp.ok(c, 'Wheel Size') and pg_temp.opt('Wheel Size', '26 inch') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Wheel Size'), pg_temp.opt('Wheel Size', '26 inch')); end if;
    if pg_temp.ok(c, 'Gears') and pg_temp.opt('Gears', '18–21 speed') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Gears'), pg_temp.opt('Gears', '18–21 speed')); end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000003', 'home_and_category', 30, 0, 'active', now() - interval '29 days', now() + interval '1 day', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Cycling' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 81. Fiction & Literature: Humayun Ahmed novels (set of 10, used)  [neg used]
  c := pg_temp.cat('Fiction & Literature');
  if c is null then missing := missing || 'Fiction & Literature' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000003', c, 'Humayun Ahmed novels (set of 10, used)', 'হুমায়ূন আহমেদের উপন্যাস (১০টির সেট, পুরোনো)', '10 popular novels · Good condition, no torn pages · Hardcover', 'Humayun Ahmed novels (set of 10, used)

• 10 popular novels
• Good condition, no torn pages
• Hardcover

Delivery: Ships in 1–2 days. 7-day returns.
Price is negotiable, message or call the seller.

(Demo product for testing RGBKart. The photos will be added later.)', 'হুমায়ূন আহমেদের ১০টি জনপ্রিয় উপন্যাস, ভালো অবস্থায়।

৭ দিনের মধ্যে ফেরত। দাম আলোচনা সাপেক্ষে।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','fiction','literature','used']::text[], 1200, null, null, null, 'DEMO-081', true, 1, 3, 'no', 'in_stock', false, 3, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', null, 'pre_owned', 'simple', true, true, false, null, null, false, null, 0, 'approved', now() - interval '729 minutes', now() - interval '729 minutes') returning id into pid;
    if pg_temp.ok(c, 'Language') and pg_temp.opt('Language', 'Bangla') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Language'), pg_temp.opt('Language', 'Bangla')); end if;
    if pg_temp.ok(c, 'Book Format') and pg_temp.opt('Book Format', 'Hardcover') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Book Format'), pg_temp.opt('Book Format', 'Hardcover')); end if;
    if pg_temp.ok(c, 'Book Genre') and pg_temp.opt('Book Genre', 'Novel / Fiction') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Book Genre'), pg_temp.opt('Book Genre', 'Novel / Fiction')); end if;
  exception when others then missing := missing || 'Fiction & Literature' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 82. Academic & Admission: Free: HSC Science textbooks (old syllabus)  [giveaway used]
  c := pg_temp.cat('Academic & Admission');
  if c is null then missing := missing || 'Academic & Admission' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Free: HSC Science textbooks (old syllabus)', 'ফ্রি: এইচএসসি বিজ্ঞান বই (পুরোনো সিলেবাস)', 'Physics, Chemistry, Biology, Math · Some notes in pencil · Free for a student who needs them', 'Free: HSC Science textbooks (old syllabus)

• Physics, Chemistry, Biology, Math
• Some notes in pencil
• Free for a student who needs them

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'যার দরকার এমন শিক্ষার্থীর জন্য বিনামূল্যে এইচএসসি বিজ্ঞানের বই।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','academic','admission','used']::text[], 0, null, null, null, 'DEMO-082', true, 1, 3, 'no', 'in_stock', false, 4, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Check the item when it arrives. Call the shop if anything is wrong.', 'free', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '738 minutes', now() - interval '738 minutes') returning id into pid;
    if pg_temp.ok(c, 'Language') and pg_temp.opt('Language', 'Bangla') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Language'), pg_temp.opt('Language', 'Bangla')); end if;
    if pg_temp.ok(c, 'Class / Level') and pg_temp.opt('Class / Level', 'Class 11–12 / HSC') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Class / Level'), pg_temp.opt('Class / Level', 'Class 11–12 / HSC')); end if;
    if pg_temp.ok(c, 'Book Format') and pg_temp.opt('Book Format', 'Paperback') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Book Format'), pg_temp.opt('Book Format', 'Paperback')); end if;
  exception when others then missing := missing || 'Academic & Admission' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 83. Children's Books: Thakurmar Jhuli (Illustrated)  [bulk]
  c := pg_temp.cat('Children''s Books');
  if c is null then missing := missing || 'Children''s Books' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Thakurmar Jhuli (Illustrated)', 'ঠাকুরমার ঝুলি (সচিত্র)', 'Classic Bangla folk tales · Colour pictures · Hardcover', 'Thakurmar Jhuli (Illustrated)

• Classic Bangla folk tales
• Colour pictures
• Hardcover

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'রঙিন ছবিসহ চিরায়ত বাংলা রূপকথা।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','childrens','books','new']::text[], 450, null, null, null, 'DEMO-083', true, 36, 3, 'no', 'in_stock', false, 0.6, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '747 minutes', now() - interval '747 minutes') returning id into pid;
    if pg_temp.ok(c, 'Language') and pg_temp.opt('Language', 'Bangla') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Language'), pg_temp.opt('Language', 'Bangla')); end if;
    if pg_temp.ok(c, 'Book Format') and pg_temp.opt('Book Format', 'Hardcover') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Book Format'), pg_temp.opt('Book Format', 'Hardcover')); end if;
    if pg_temp.ok(c, 'Recommended Age') and pg_temp.opt('Recommended Age', '5–7 years') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Recommended Age'), pg_temp.opt('Recommended Age', '5–7 years')); end if;
    insert into public.product_price_tiers (product_id, min_qty, unit_price) values (pid, 3, 428), (pid, 10, 405);
  exception when others then missing := missing || 'Children''s Books' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 84. Islamic Books: Tafsir Ibn Kathir (Bangla, full set)  [feat heavy]
  c := pg_temp.cat('Islamic Books');
  if c is null then missing := missing || 'Islamic Books' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Tafsir Ibn Kathir (Bangla, full set)', 'তাফসীর ইবনে কাসীর (বাংলা, সম্পূর্ণ সেট)', 'Complete 11 volumes · Clear Bangla translation · Hardcover', 'Tafsir Ibn Kathir (Bangla, full set)

• Complete 11 volumes
• Clear Bangla translation
• Hardcover

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'সম্পূর্ণ ১১ খণ্ডের বাংলা তাফসীর ইবনে কাসীর।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','islamic','books','new','featured']::text[], 7500, null, null, null, 'DEMO-084', true, 43, 3, 'no', 'in_stock', false, 9, 90, 70, 60, 'heavy', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '756 minutes', now() - interval '756 minutes') returning id into pid;
    if pg_temp.ok(c, 'Language') and pg_temp.opt('Language', 'Arabic + Bangla') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Language'), pg_temp.opt('Language', 'Arabic + Bangla')); end if;
    if pg_temp.ok(c, 'Book Format') and pg_temp.opt('Book Format', 'Hardcover') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Book Format'), pg_temp.opt('Book Format', 'Hardcover')); end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000002', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Islamic Books' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 85. Stationery & Office Supplies: Matador Ball Pen (Box of 50)  [bulk same small]
  c := pg_temp.cat('Stationery & Office Supplies');
  if c is null then missing := missing || 'Stationery & Office Supplies' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Matador Ball Pen (Box of 50)', 'মাতাদোর বল পেন (৫০টির বাক্স)', 'Smooth writing · Blue ink · Box of 50', 'Matador Ball Pen (Box of 50)

• Smooth writing
• Blue ink
• Box of 50

Delivery: Ships today. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'অফিস ও স্কুলের জন্য বল পেনের বাক্স।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','stationery','office','supplies','new']::text[], 400, null, null, null, 'DEMO-085', true, 50, 3, 'no', 'in_stock', false, 0.4, 12, 8, 4, 'small', 'same_day', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '765 minutes', now() - interval '765 minutes') returning id into pid;
    if pg_temp.ok(c, 'Pack Quantity') and pg_temp.opt('Pack Quantity', 'Pack of 50') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Pack Quantity'), pg_temp.opt('Pack Quantity', 'Pack of 50')); end if;
    insert into public.product_price_tiers (product_id, min_qty, unit_price) values (pid, 3, 380), (pid, 10, 360);
  exception when others then missing := missing || 'Stationery & Office Supplies' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 86. Remote Control Toys: RC Off-road Car 1:16  [sale]
  c := pg_temp.cat('Remote Control Toys');
  if c is null then missing := missing || 'Remote Control Toys' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'RC Off-road Car 1:16', 'রিমোট কন্ট্রোল অফ-রোড গাড়ি ১:১৬', '2.4 GHz remote, 25 km/h · Rechargeable battery · Shock-absorbing wheels', 'RC Off-road Car 1:16

• 2.4 GHz remote, 25 km/h
• Rechargeable battery
• Shock-absorbing wheels

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'দ্রুতগতির রিমোট কন্ট্রোল অফ-রোড গাড়ি।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','remote','control','toys','new','sale']::text[], 2850, '2419', null, null, 'DEMO-086', true, 17, 3, 'no', 'in_stock', false, 1.2, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '774 minutes', now() - interval '774 minutes') returning id into pid;
    if pg_temp.ok(c, 'Recommended Age') and pg_temp.opt('Recommended Age', '8–11 years') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Recommended Age'), pg_temp.opt('Recommended Age', '8–11 years')); end if;
    if pg_temp.ok(c, 'Battery Required') then insert into public.product_attribute_values (product_id, attribute_id, bool_value) values (pid, pg_temp.attr('Battery Required'), true); end if;
  exception when others then missing := missing || 'Remote Control Toys' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 87. Educational & STEM Toys: Magnetic Building Tiles (60 pcs)  [feat freedel]
  c := pg_temp.cat('Educational & STEM Toys');
  if c is null then missing := missing || 'Educational & STEM Toys' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Magnetic Building Tiles (60 pcs)', 'ম্যাগনেটিক বিল্ডিং টাইলস (৬০ পিস)', 'Build 3D shapes · Strong safe magnets · Learning through play', 'Magnetic Building Tiles (60 pcs)

• Build 3D shapes
• Strong safe magnets
• Learning through play

Delivery: Ships in 1–2 days. 7-day returns. Free delivery.

(Demo product for testing RGBKart. The photos will be added later.)', 'খেলতে খেলতে শেখার জন্য চুম্বকের টাইলস।

৭ দিনের মধ্যে ফেরত। ফ্রি ডেলিভারি।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','educational','stem','toys','new','featured']::text[], 2400, null, null, null, 'DEMO-087', true, 24, 3, 'no', 'in_stock', false, 1.5, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', true, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '783 minutes', now() - interval '783 minutes') returning id into pid;
    if pg_temp.ok(c, 'Recommended Age') and pg_temp.opt('Recommended Age', '3–4 years') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Recommended Age'), pg_temp.opt('Recommended Age', '3–4 years')); end if;
    if pg_temp.ok(c, 'Material') and pg_temp.opt('Material', 'ABS Plastic') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Material'), pg_temp.opt('Material', 'ABS Plastic')); end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000002', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Educational & STEM Toys' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 88. Dolls & Soft Toys: Teddy Bear 60cm  [low variable]
  c := pg_temp.cat('Dolls & Soft Toys');
  if c is null then missing := missing || 'Dolls & Soft Toys' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Teddy Bear 60cm', 'টেডি বিয়ার ৬০ সেমি', 'Super soft plush · Safe for kids · Washable', 'Teddy Bear 60cm

• Super soft plush
• Safe for kids
• Washable

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'নরম ও নিরাপদ টেডি বিয়ার।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','dolls','soft','toys','new']::text[], 1100, null, null, null, 'DEMO-088', true, 2, 5, 'no', 'in_stock', false, 0.6, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '792 minutes', now() - interval '792 minutes') returning id into pid;
    if pg_temp.ok(c, 'Recommended Age') and pg_temp.opt('Recommended Age', '1–2 years') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Recommended Age'), pg_temp.opt('Recommended Age', '1–2 years')); end if;
    if pg_temp.opt('Colour', 'Brown') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Brown'))) t(a, o)), 'DEMO-088-1', 1100, null, 2, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Brown'));
    end if;
    if pg_temp.opt('Colour', 'Pink') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Pink'))) t(a, o)), 'DEMO-088-2', 1100, null, 5, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Colour'), pg_temp.opt('Colour', 'Pink'));
    end if;
  exception when others then missing := missing || 'Dolls & Soft Toys' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 89. Board Games & Puzzles: Ludo & Snakes and Ladders (2-in-1)  [bulk small]
  c := pg_temp.cat('Board Games & Puzzles');
  if c is null then missing := missing || 'Board Games & Puzzles' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Ludo & Snakes and Ladders (2-in-1)', 'লুডু ও সাপ-লুডু (২-ইন-১)', 'Folding board · Dice and counters included · Family fun', 'Ludo & Snakes and Ladders (2-in-1)

• Folding board
• Dice and counters included
• Family fun

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'পরিবারের সবার জন্য লুডু ও সাপ-লুডু।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','board','games','puzzles','new']::text[], 220, null, null, null, 'DEMO-089', true, 38, 3, 'no', 'in_stock', false, 0.3, 12, 8, 4, 'small', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '801 minutes', now() - interval '801 minutes') returning id into pid;
    if pg_temp.ok(c, 'Recommended Age') and pg_temp.opt('Recommended Age', '5–7 years') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Recommended Age'), pg_temp.opt('Recommended Age', '5–7 years')); end if;
    insert into public.product_price_tiers (product_id, min_qty, unit_price) values (pid, 3, 209), (pid, 10, 198);
  exception when others then missing := missing || 'Board Games & Puzzles' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 90. Outdoor & Ride-On Toys: Kids Tricycle with Push Handle  [oos]
  c := pg_temp.cat('Outdoor & Ride-On Toys');
  if c is null then missing := missing || 'Outdoor & Ride-On Toys' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000002', c, 'Kids Tricycle with Push Handle', 'পুশ হ্যান্ডেলসহ বাচ্চাদের ট্রাইসাইকেল', 'Parent push handle · Safety belt and canopy · Storage basket', 'Kids Tricycle with Push Handle

• Parent push handle
• Safety belt and canopy
• Storage basket

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'বাবা-মা ঠেলে নিতে পারেন এমন ট্রাইসাইকেল। (এখন স্টক নেই)

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','outdoor','ride-on','toys','new']::text[], 5200, null, null, null, 'DEMO-090', true, 0, 3, 'no', 'out_of_stock', false, 8, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '810 minutes', now() - interval '810 minutes') returning id into pid;
    if pg_temp.ok(c, 'Recommended Age') and pg_temp.opt('Recommended Age', '1–2 years') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Recommended Age'), pg_temp.opt('Recommended Age', '1–2 years')); end if;
  exception when others then missing := missing || 'Outdoor & Ride-On Toys' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 91. Helmets & Riding Gear: Studds Full-face Helmet  [feat variable]
  c := pg_temp.cat('Helmets & Riding Gear');
  if c is null then missing := missing || 'Helmets & Riding Gear' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Studds Full-face Helmet', 'স্টাডস ফুল-ফেস হেলমেট', 'DOT certified · Scratch-resistant visor · Removable washable lining', 'Studds Full-face Helmet

• DOT certified
• Scratch-resistant visor
• Removable washable lining

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'নিরাপদ রাইডের জন্য সার্টিফায়েড ফুল-ফেস হেলমেট।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','helmets','riding','gear','new','featured']::text[], 3600, null, null, null, 'DEMO-091', true, 52, 3, 'no', 'in_stock', false, 1.4, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '819 minutes', now() - interval '819 minutes') returning id into pid;
    if pg_temp.ok(c, 'Helmet Certification') and pg_temp.opt('Helmet Certification', 'DOT') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Helmet Certification'), pg_temp.opt('Helmet Certification', 'DOT')); end if;
    if pg_temp.opt('Helmet Size', 'M (57–58 cm)') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Helmet Size'), pg_temp.opt('Helmet Size', 'M (57–58 cm)'))) t(a, o)), 'DEMO-091-1', 3600, null, 5, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Helmet Size'), pg_temp.opt('Helmet Size', 'M (57–58 cm)'));
    end if;
    if pg_temp.opt('Helmet Size', 'L (59–60 cm)') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Helmet Size'), pg_temp.opt('Helmet Size', 'L (59–60 cm)'))) t(a, o)), 'DEMO-091-2', 3600, null, 8, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Helmet Size'), pg_temp.opt('Helmet Size', 'L (59–60 cm)'));
    end if;
    if pg_temp.opt('Helmet Size', 'XL (61–62 cm)') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Helmet Size'), pg_temp.opt('Helmet Size', 'XL (61–62 cm)'))) t(a, o)), 'DEMO-091-3', 3600, null, 11, true, 20) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Helmet Size'), pg_temp.opt('Helmet Size', 'XL (61–62 cm)'));
    end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000001', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Helmets & Riding Gear' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 92. Motorbike Parts & Accessories: Motorbike Mobile Holder (Waterproof)  [bulk small]
  c := pg_temp.cat('Motorbike Parts & Accessories');
  if c is null then missing := missing || 'Motorbike Parts & Accessories' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Motorbike Mobile Holder (Waterproof)', 'মোটরবাইকের মোবাইল হোল্ডার (পানিরোধী)', 'Fits phones up to 6.8" · Waterproof touch cover · Fits all handlebars', 'Motorbike Mobile Holder (Waterproof)

• Fits phones up to 6.8"
• Waterproof touch cover
• Fits all handlebars

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'রাইডের সময় ম্যাপ দেখতে পানিরোধী মোবাইল হোল্ডার।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','motorbike','parts','accessories','new']::text[], 650, null, null, null, 'DEMO-092', true, 19, 3, 'no', 'in_stock', false, 0.2, 12, 8, 4, 'small', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '828 minutes', now() - interval '828 minutes') returning id into pid;
    if pg_temp.ok(c, 'Vehicle Type') and pg_temp.opt('Vehicle Type', 'Motorbike') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Vehicle Type'), pg_temp.opt('Vehicle Type', 'Motorbike')); end if;
    if pg_temp.ok(c, 'Vehicle Type') and pg_temp.opt('Vehicle Type', 'Scooter') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Vehicle Type'), pg_temp.opt('Vehicle Type', 'Scooter')); end if;
    if pg_temp.ok(c, 'Vehicle Type') and pg_temp.opt('Vehicle Type', 'Bicycle') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Vehicle Type'), pg_temp.opt('Vehicle Type', 'Bicycle')); end if;
    insert into public.product_price_tiers (product_id, min_qty, unit_price) values (pid, 3, 618), (pid, 10, 585);
  exception when others then missing := missing || 'Motorbike Parts & Accessories' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 93. Car Accessories: Car Seat Cover Set (Leatherette)  [d35 outside]
  c := pg_temp.cat('Car Accessories');
  if c is null then missing := missing || 'Car Accessories' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Car Seat Cover Set (Leatherette)', 'কার সিট কভার সেট (লেদারেট)', 'Full set for 5 seats · Easy to clean · Fits most sedans', 'Car Seat Cover Set (Leatherette)

• Full set for 5 seats
• Easy to clean
• Fits most sedans

Delivery: Ships in 3–5 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'সহজে পরিষ্কার করা যায় এমন সিট কভার সেট। (শুধু ঢাকার বাইরে ডেলিভারি)

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','car','accessories','new']::text[], 6500, null, null, null, 'DEMO-093', true, 26, 3, 'no', 'in_stock', false, 4, 30, 22, 10, 'standard', '3_5_days', 'outside_dhaka', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '837 minutes', now() - interval '837 minutes') returning id into pid;
    if pg_temp.ok(c, 'Vehicle Type') and pg_temp.opt('Vehicle Type', 'Car') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Vehicle Type'), pg_temp.opt('Vehicle Type', 'Car')); end if;
    if pg_temp.ok(c, 'Vehicle Brand') and pg_temp.opt('Vehicle Brand', 'Toyota') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Vehicle Brand'), pg_temp.opt('Vehicle Brand', 'Toyota')); end if;
    if pg_temp.ok(c, 'Vehicle Brand') and pg_temp.opt('Vehicle Brand', 'Honda') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Vehicle Brand'), pg_temp.opt('Vehicle Brand', 'Honda')); end if;
    if pg_temp.ok(c, 'Material') and pg_temp.opt('Material', 'Synthetic Leather (PU)') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Material'), pg_temp.opt('Material', 'Synthetic Leather (PU)')); end if;
  exception when others then missing := missing || 'Car Accessories' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 94. Car Electronics: 70mai Dash Cam M300  [sale]
  c := pg_temp.cat('Car Electronics');
  if c is null then missing := missing || 'Car Electronics' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, '70mai Dash Cam M300', '৭০মাই ড্যাশ ক্যাম M300', 'Records the road while you drive · Night vision, Wi-Fi app · Parking monitor', '70mai Dash Cam M300

• Records the road while you drive
• Night vision, Wi-Fi app
• Parking monitor

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'গাড়ি চালানোর সময় রাস্তার ভিডিও রেকর্ড করে।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','car','electronics','new','sale']::text[], 4700, '3999', null, null, 'DEMO-094', true, 33, 3, 'no', 'in_stock', false, 0.2, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '846 minutes', now() - interval '846 minutes') returning id into pid;
    if pg_temp.ok(c, 'Vehicle Type') and pg_temp.opt('Vehicle Type', 'Car') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Vehicle Type'), pg_temp.opt('Vehicle Type', 'Car')); end if;
    if pg_temp.ok(c, 'Vehicle Type') and pg_temp.opt('Vehicle Type', 'SUV / Microbus') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Vehicle Type'), pg_temp.opt('Vehicle Type', 'SUV / Microbus')); end if;
  exception when others then missing := missing || 'Car Electronics' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 95. Oils & Car Care: Motul Engine Oil 1L  [bulk variable]
  c := pg_temp.cat('Oils & Car Care');
  if c is null then missing := missing || 'Oils & Car Care' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Motul Engine Oil 1L', 'মটুল ইঞ্জিন অয়েল ১ লিটার', 'Synthetic technology · For motorbikes · Smooth engine, better mileage', 'Motul Engine Oil 1L

• Synthetic technology
• For motorbikes
• Smooth engine, better mileage

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'মোটরবাইকের ইঞ্জিন মসৃণ রাখতে সিন্থেটিক অয়েল।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','oils','car','care','new']::text[], 980, null, null, null, 'DEMO-095', true, 40, 3, 'no', 'in_stock', false, 1, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'variable', false, true, false, null, null, false, null, 0, 'approved', now() - interval '855 minutes', now() - interval '855 minutes') returning id into pid;
    if pg_temp.ok(c, 'Vehicle Type') and pg_temp.opt('Vehicle Type', 'Motorbike') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Vehicle Type'), pg_temp.opt('Vehicle Type', 'Motorbike')); end if;
    if pg_temp.opt('Engine Oil Grade', '10W-30') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Engine Oil Grade'), pg_temp.opt('Engine Oil Grade', '10W-30'))) t(a, o)), 'DEMO-095-1', 980, null, 9, true, 0) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Engine Oil Grade'), pg_temp.opt('Engine Oil Grade', '10W-30'));
    end if;
    if pg_temp.opt('Engine Oil Grade', '20W-50') is not null then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, (select string_agg(o::text, '-' order by a) from (values (pg_temp.attr('Engine Oil Grade'), pg_temp.opt('Engine Oil Grade', '20W-50'))) t(a, o)), 'DEMO-095-2', 980, null, 12, true, 10) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values (vid, pg_temp.attr('Engine Oil Grade'), pg_temp.opt('Engine Oil Grade', '20W-50'));
    end if;
  exception when others then missing := missing || 'Oils & Car Care' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 96. Power Tools: Bosch GSB 550 Impact Drill  [feat]
  c := pg_temp.cat('Power Tools');
  if c is null then missing := missing || 'Power Tools' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Bosch GSB 550 Impact Drill', 'বশ GSB ৫৫০ ইমপ্যাক্ট ড্রিল', '550 W, drills wall, wood and metal · 100 accessories kit · Carry case', 'Bosch GSB 550 Impact Drill

• 550 W, drills wall, wood and metal
• 100 accessories kit
• Carry case

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'ঘরের যেকোনো কাজে বশ ইমপ্যাক্ট ড্রিল, ১০০ এক্সেসরিজসহ।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','power','tools','new','featured']::text[], 5800, null, null, null, 'DEMO-096', true, 47, 3, 'no', 'in_stock', false, 2, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '864 minutes', now() - interval '864 minutes') returning id into pid;
    if pg_temp.ok(c, 'Tool Brand') and pg_temp.opt('Tool Brand', 'Bosch') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Tool Brand'), pg_temp.opt('Tool Brand', 'Bosch')); end if;
    if pg_temp.ok(c, 'Power Source') and pg_temp.opt('Power Source', 'Corded electric') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Power Source'), pg_temp.opt('Power Source', 'Corded electric')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '6 Months') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '6 Months')); end if;
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, 'd0000000-0000-4000-8000-000000000001', 'home_and_category', 30, 0, 'active', now(), now() + interval '30 days', true, 'Demo data');
    update public.products set is_featured = true where id = pid;
  exception when others then missing := missing || 'Power Tools' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 97. Hand Tools: Stanley Screwdriver Set (10 pcs)  [sale small]
  c := pg_temp.cat('Hand Tools');
  if c is null then missing := missing || 'Hand Tools' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Stanley Screwdriver Set (10 pcs)', 'স্ট্যানলি স্ক্রুড্রাইভার সেট (১০ পিস)', 'Flat and Phillips heads · Magnetic tips · Comfortable grip', 'Stanley Screwdriver Set (10 pcs)

• Flat and Phillips heads
• Magnetic tips
• Comfortable grip

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'চুম্বকযুক্ত মাথার স্ক্রুড্রাইভার সেট।

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','hand','tools','new','sale']::text[], 1250, '1059', null, null, 'DEMO-097', true, 54, 3, 'no', 'in_stock', false, 0.6, 12, 8, 4, 'small', '1_2_days', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '873 minutes', now() - interval '873 minutes') returning id into pid;
    if pg_temp.ok(c, 'Tool Brand') and pg_temp.opt('Tool Brand', 'Stanley') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Tool Brand'), pg_temp.opt('Tool Brand', 'Stanley')); end if;
  exception when others then missing := missing || 'Hand Tools' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 98. Electrical & Wiring: Home Electrical Check-up (Service)  [dhaka svc]
  c := pg_temp.cat('Electrical & Wiring');
  if c is null then missing := missing || 'Electrical & Wiring' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Home Electrical Check-up (Service)', 'বাসার ইলেকট্রিক চেক-আপ (সার্ভিস)', 'Licensed electrician visits your home · Checks wiring, switches and DB box · Small fixes included', 'Home Electrical Check-up (Service)

• Licensed electrician visits your home
• Checks wiring, switches and DB box
• Small fixes included

Delivery: Ships in 1–2 days. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'লাইসেন্সধারী ইলেকট্রিশিয়ান বাসায় এসে ওয়্যারিং চেক করবেন। (ঢাকার ভিতরে সার্ভিস)

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','electrical','wiring','new']::text[], 1500, null, null, null, 'DEMO-098', false, 0, 3, 'no', 'in_stock', false, 0.1, 30, 22, 10, 'standard', '1_2_days', 'inside_dhaka', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, true, 'at_customer', '2_hours', false, null, 0, 'approved', now() - interval '882 minutes', now() - interval '882 minutes') returning id into pid;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '7 Days Replacement') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '7 Days Replacement')); end if;
  exception when others then missing := missing || 'Electrical & Wiring' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 99. Plumbing & Sanitary: Stainless Steel Kitchen Sink Mixer Tap  [freedel]
  c := pg_temp.cat('Plumbing & Sanitary');
  if c is null then missing := missing || 'Plumbing & Sanitary' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Stainless Steel Kitchen Sink Mixer Tap', 'স্টেইনলেস স্টিল কিচেন সিঙ্ক মিক্সার ট্যাপ', 'Hot and cold mixer · 360° swivel spout · Rust-proof steel', 'Stainless Steel Kitchen Sink Mixer Tap

• Hot and cold mixer
• 360° swivel spout
• Rust-proof steel

Delivery: Ships in 1–2 days. 7-day returns. Free delivery.

(Demo product for testing RGBKart. The photos will be added later.)', 'মরিচারোধী স্টেইনলেস স্টিলের মিক্সার ট্যাপ।

৭ দিনের মধ্যে ফেরত। ফ্রি ডেলিভারি।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','plumbing','sanitary','new']::text[], 2900, null, null, null, 'DEMO-099', true, 28, 3, 'no', 'in_stock', false, 1.5, 30, 22, 10, 'standard', '1_2_days', 'all_bangladesh', true, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, false, null, 0, 'approved', now() - interval '891 minutes', now() - interval '891 minutes') returning id into pid;
    if pg_temp.ok(c, 'Material') and pg_temp.opt('Material', 'Stainless Steel') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Material'), pg_temp.opt('Material', 'Stainless Steel')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
  exception when others then missing := missing || 'Plumbing & Sanitary' || ' (' || sqlerrm || '), ';
  end; end if;

  -- 100. Locks & Safety: Digital Fingerprint Door Lock  [preorder]
  c := pg_temp.cat('Locks & Safety');
  if c is null then missing := missing || 'Locks & Safety' || ', ';
  else begin
    insert into public.products (seller_id, category_id, title, title_bn, short_description, description, description_bn, tags, price, sale_price, sale_starts_at, sale_ends_at, sku, manage_stock, stock, low_stock_threshold, backorders, stock_status, sold_individually, weight_kg, length_cm, width_cm, height_cm, shipping_class, delivery_time, ships_to, free_delivery, return_policy, purchase_note, listing_type, product_type, price_negotiable, cod_allowed, is_service, service_mode, service_duration, is_preorder, preorder_date, preorder_advance_percent, status, published_at, created_at) values ('d0000000-0000-4000-8000-000000000001', c, 'Digital Fingerprint Door Lock', 'ডিজিটাল ফিঙ্গারপ্রিন্ট দরজার তালা', 'Fingerprint, PIN, card and key · Low battery alarm · Easy to install', 'Digital Fingerprint Door Lock

• Fingerprint, PIN, card and key
• Low battery alarm
• Easy to install

Delivery: Pre-order: ships when stock arrives. 7-day returns.

(Demo product for testing RGBKart. The photos will be added later.)', 'আঙুলের ছাপ ও পিন দিয়ে খোলা যায় এমন ডিজিটাল তালা। (প্রি-অর্ডার)

৭ দিনের মধ্যে ফেরত।

(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)', array['demo','locks','safety','new']::text[], 13500, null, null, null, 'DEMO-100', true, 35, 3, 'no', 'in_stock', false, 3, 30, 22, 10, 'standard', 'pre_order', 'all_bangladesh', false, '7_days', 'Thank you for your order! Keep the box and invoice for warranty.', 'new', 'simple', false, true, false, null, null, true, now() + interval '20 days', 30, 'approved', now() - interval '900 minutes', now() - interval '900 minutes') returning id into pid;
    if pg_temp.ok(c, 'Material') and pg_temp.opt('Material', 'Aluminium') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Material'), pg_temp.opt('Material', 'Aluminium')); end if;
    if pg_temp.ok(c, 'Warranty') and pg_temp.opt('Warranty', '1 Year') is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr('Warranty'), pg_temp.opt('Warranty', '1 Year')); end if;
  exception when others then missing := missing || 'Locks & Safety' || ' (' || sqlerrm || '), ';
  end; end if;

  perform set_config('rgbkart.staff_grant', 'off', true);
  if missing <> '' then raise notice 'These demo products were skipped: %', missing; end if;
end $$;

-- 4. home page sections (shown after your existing ones) ----------------------------------------------------
insert into public.home_sections (title, title_bn, subtitle, subtitle_bn, section_type, category_id, item_count, sort_order, is_active)
select v.title, v.title_bn, v.subtitle || ' · demo', v.subtitle_bn, v.section_type, pg_temp.cat(v.cat), v.n,
       coalesce((select max(sort_order) from public.home_sections), 0) + v.o, true
from (values
  ('Choose Your Size & Colour', 'সাইজ ও রং বেছে নিন', 'Products with options: size, colour, storage, pack size', 'সাইজ, রং, স্টোরেজ বা প্যাক বেছে নেওয়া যায়', 'variable', null, 12, 10),
  ('Brand New', 'একদম নতুন', 'Unused products with warranty', 'ওয়ারেন্টিসহ অব্যবহৃত পণ্য', 'brand_new', null, 12, 20),
  ('Free Delivery Picks', 'ফ্রি ডেলিভারি', 'No delivery charge on these', 'এগুলোর ডেলিভারি চার্জ নেই', 'free_delivery', null, 12, 30),
  ('Price Negotiable', 'দরদাম করা যাবে', 'Talk to the seller about the price', 'দাম নিয়ে বিক্রেতার সাথে কথা বলুন', 'negotiable', null, 6, 40),
  ('Mobiles & Tablets', 'মোবাইল ও ট্যাবলেট', 'Phones, tablets, chargers and power banks', 'ফোন, ট্যাবলেট, চার্জার ও পাওয়ার ব্যাংক', 'category', 'Mobiles & Tablets', 6, 50),
  ('Fashion for Her', 'মেয়েদের ফ্যাশন', 'Sarees, three-piece, kurtis and more', 'শাড়ি, থ্রি-পিস, কুর্তি ও আরও অনেক কিছু', 'category', 'Women''s Fashion', 6, 60),
  ('Daily Groceries', 'নিত্যদিনের বাজার', 'Rice, oil, snacks and cleaning (Dhaka only)', 'চাল, তেল, স্ন্যাকস ও পরিষ্কারের পণ্য (শুধু ঢাকা)', 'category', 'Groceries', 6, 70),
  ('Home Appliances', 'গৃহস্থালি যন্ত্রপাতি', 'AC, fridge, washing machine and fans', 'এসি, ফ্রিজ, ওয়াশিং মেশিন ও ফ্যান', 'category', 'Home Appliances', 6, 80)
) v(title, title_bn, subtitle, subtitle_bn, section_type, cat, n, o)
where v.cat is null or pg_temp.cat(v.cat) is not null;

commit;

-- 5. check ---------------------------------------------------------------------------------------------------
select (select count(*) from public.products where 'demo' = any(tags) and status = 'approved') as demo_products,
       (select count(*) from public.products where 'demo' = any(tags) and product_type = 'variable') as with_options,
       (select count(*) from public.product_variations v join public.products p on p.id = v.product_id where 'demo' = any(p.tags)) as versions,
       (select count(*) from public.products where 'demo' = any(tags) and is_featured) as featured,
       (select count(*) from public.home_sections where subtitle like '%· demo') as demo_sections;
