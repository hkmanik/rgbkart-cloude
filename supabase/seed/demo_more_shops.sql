-- RGBKart DEMO: 9 more demo shops for the home page "Top shops" row (23 Oct).
-- Moves the matching demo products (same products, same photos) from Demo Gadget House / Demo Lifestyle Mart to the new shops.
-- Run in Supabase → SQL Editor after demo_products.sql. Safe to run again. demo_products_remove.sql removes these shops too.
begin;
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change)
values ('00000000-0000-0000-0000-000000000000', 'd0000000-0000-4000-8000-000000000004', 'authenticated', 'authenticated', 'demo-fashion-hub@rgbkart.test', '', now(),
  '{"provider":"email","providers":["email"]}', '{"full_name": "Demo Fashion Hub"}', now() - interval '200 days', now(), '', '', '', '') on conflict (id) do nothing;
insert into public.profiles (id, full_name) values ('d0000000-0000-4000-8000-000000000004', 'Demo Fashion Hub') on conflict (id) do nothing;
update public.profiles set role = 'seller', full_name = 'Demo Fashion Hub', phone = '01700000104', email_alerts = false where id = 'd0000000-0000-4000-8000-000000000004';
insert into public.seller_details (user_id, shop_name, shop_name_bn, shop_description, tagline, business_address, city, area, phone_public, whatsapp, email_public, status, allow_pickup, created_at)
values ('d0000000-0000-4000-8000-000000000004', 'Demo Fashion Hub', 'ডেমো ফ্যাশন হাব', 'This is a demo shop made for testing RGBKart. Its products are not real.', 'Clothing for men and women (demo shop)', 'Dhanmondi 27, Dhaka', 'Dhaka', 'Dhanmondi 27',
  '01700000104', '01700000104', 'demo-fashion-hub@rgbkart.test', 'approved', true, now() - interval '200 days') on conflict (user_id) do nothing;
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change)
values ('00000000-0000-0000-0000-000000000000', 'd0000000-0000-4000-8000-000000000005', 'authenticated', 'authenticated', 'demo-shoe-palace@rgbkart.test', '', now(),
  '{"provider":"email","providers":["email"]}', '{"full_name": "Demo Shoe Palace"}', now() - interval '200 days', now(), '', '', '', '') on conflict (id) do nothing;
insert into public.profiles (id, full_name) values ('d0000000-0000-4000-8000-000000000005', 'Demo Shoe Palace') on conflict (id) do nothing;
update public.profiles set role = 'seller', full_name = 'Demo Shoe Palace', phone = '01700000105', email_alerts = false where id = 'd0000000-0000-4000-8000-000000000005';
insert into public.seller_details (user_id, shop_name, shop_name_bn, shop_description, tagline, business_address, city, area, phone_public, whatsapp, email_public, status, allow_pickup, created_at)
values ('d0000000-0000-4000-8000-000000000005', 'Demo Shoe Palace', 'ডেমো শু প্যালেস', 'This is a demo shop made for testing RGBKart. Its products are not real.', 'Shoes, watches and bags (demo shop)', 'Gulshan 1, Dhaka', 'Dhaka', 'Gulshan 1',
  '01700000105', '01700000105', 'demo-shoe-palace@rgbkart.test', 'approved', false, now() - interval '200 days') on conflict (user_id) do nothing;
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change)
values ('00000000-0000-0000-0000-000000000000', 'd0000000-0000-4000-8000-000000000006', 'authenticated', 'authenticated', 'demo-kids-world@rgbkart.test', '', now(),
  '{"provider":"email","providers":["email"]}', '{"full_name": "Demo Kids World"}', now() - interval '200 days', now(), '', '', '', '') on conflict (id) do nothing;
insert into public.profiles (id, full_name) values ('d0000000-0000-4000-8000-000000000006', 'Demo Kids World') on conflict (id) do nothing;
update public.profiles set role = 'seller', full_name = 'Demo Kids World', phone = '01700000106', email_alerts = false where id = 'd0000000-0000-4000-8000-000000000006';
insert into public.seller_details (user_id, shop_name, shop_name_bn, shop_description, tagline, business_address, city, area, phone_public, whatsapp, email_public, status, allow_pickup, created_at)
values ('d0000000-0000-4000-8000-000000000006', 'Demo Kids World', 'ডেমো কিডস ওয়ার্ল্ড', 'This is a demo shop made for testing RGBKart. Its products are not real.', 'Everything for babies and kids (demo shop)', 'Sonadanga, Khulna', 'Khulna', 'Sonadanga',
  '01700000106', '01700000106', 'demo-kids-world@rgbkart.test', 'approved', false, now() - interval '200 days') on conflict (user_id) do nothing;
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change)
values ('00000000-0000-0000-0000-000000000000', 'd0000000-0000-4000-8000-000000000007', 'authenticated', 'authenticated', 'demo-beauty-care@rgbkart.test', '', now(),
  '{"provider":"email","providers":["email"]}', '{"full_name": "Demo Beauty Care"}', now() - interval '200 days', now(), '', '', '', '') on conflict (id) do nothing;
insert into public.profiles (id, full_name) values ('d0000000-0000-4000-8000-000000000007', 'Demo Beauty Care') on conflict (id) do nothing;
update public.profiles set role = 'seller', full_name = 'Demo Beauty Care', phone = '01700000107', email_alerts = false where id = 'd0000000-0000-4000-8000-000000000007';
insert into public.seller_details (user_id, shop_name, shop_name_bn, shop_description, tagline, business_address, city, area, phone_public, whatsapp, email_public, status, allow_pickup, created_at)
values ('d0000000-0000-4000-8000-000000000007', 'Demo Beauty Care', 'ডেমো বিউটি কেয়ার', 'This is a demo shop made for testing RGBKart. Its products are not real.', 'Original skin, hair and beauty products (demo shop)', 'Zindabazar, Sylhet', 'Sylhet', 'Zindabazar',
  '01700000107', '01700000107', 'demo-beauty-care@rgbkart.test', 'approved', false, now() - interval '200 days') on conflict (user_id) do nothing;
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change)
values ('00000000-0000-0000-0000-000000000000', 'd0000000-0000-4000-8000-000000000008', 'authenticated', 'authenticated', 'demo-fresh-bazar@rgbkart.test', '', now(),
  '{"provider":"email","providers":["email"]}', '{"full_name": "Demo Fresh Bazar"}', now() - interval '200 days', now(), '', '', '', '') on conflict (id) do nothing;
insert into public.profiles (id, full_name) values ('d0000000-0000-4000-8000-000000000008', 'Demo Fresh Bazar') on conflict (id) do nothing;
update public.profiles set role = 'seller', full_name = 'Demo Fresh Bazar', phone = '01700000108', email_alerts = false where id = 'd0000000-0000-4000-8000-000000000008';
insert into public.seller_details (user_id, shop_name, shop_name_bn, shop_description, tagline, business_address, city, area, phone_public, whatsapp, email_public, status, allow_pickup, created_at)
values ('d0000000-0000-4000-8000-000000000008', 'Demo Fresh Bazar', 'ডেমো ফ্রেশ বাজার', 'This is a demo shop made for testing RGBKart. Its products are not real.', 'Daily groceries delivered in Dhaka (demo shop)', 'Mirpur 10, Dhaka', 'Dhaka', 'Mirpur 10',
  '01700000108', '01700000108', 'demo-fresh-bazar@rgbkart.test', 'approved', true, now() - interval '200 days') on conflict (user_id) do nothing;
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change)
values ('00000000-0000-0000-0000-000000000000', 'd0000000-0000-4000-8000-000000000009', 'authenticated', 'authenticated', 'demo-home-decor@rgbkart.test', '', now(),
  '{"provider":"email","providers":["email"]}', '{"full_name": "Demo Home Decor"}', now() - interval '200 days', now(), '', '', '', '') on conflict (id) do nothing;
insert into public.profiles (id, full_name) values ('d0000000-0000-4000-8000-000000000009', 'Demo Home Decor') on conflict (id) do nothing;
update public.profiles set role = 'seller', full_name = 'Demo Home Decor', phone = '01700000109', email_alerts = false where id = 'd0000000-0000-4000-8000-000000000009';
insert into public.seller_details (user_id, shop_name, shop_name_bn, shop_description, tagline, business_address, city, area, phone_public, whatsapp, email_public, status, allow_pickup, created_at)
values ('d0000000-0000-4000-8000-000000000009', 'Demo Home Decor', 'ডেমো হোম ডেকর', 'This is a demo shop made for testing RGBKart. Its products are not real.', 'Home, kitchen and decor (demo shop)', 'Shaheb Bazar, Rajshahi', 'Rajshahi', 'Shaheb Bazar',
  '01700000109', '01700000109', 'demo-home-decor@rgbkart.test', 'approved', false, now() - interval '200 days') on conflict (user_id) do nothing;
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change)
values ('00000000-0000-0000-0000-000000000000', 'd0000000-0000-4000-8000-000000000010', 'authenticated', 'authenticated', 'demo-sports-zone@rgbkart.test', '', now(),
  '{"provider":"email","providers":["email"]}', '{"full_name": "Demo Sports Zone"}', now() - interval '200 days', now(), '', '', '', '') on conflict (id) do nothing;
insert into public.profiles (id, full_name) values ('d0000000-0000-4000-8000-000000000010', 'Demo Sports Zone') on conflict (id) do nothing;
update public.profiles set role = 'seller', full_name = 'Demo Sports Zone', phone = '01700000110', email_alerts = false where id = 'd0000000-0000-4000-8000-000000000010';
insert into public.seller_details (user_id, shop_name, shop_name_bn, shop_description, tagline, business_address, city, area, phone_public, whatsapp, email_public, status, allow_pickup, created_at)
values ('d0000000-0000-4000-8000-000000000010', 'Demo Sports Zone', 'ডেমো স্পোর্টস জোন', 'This is a demo shop made for testing RGBKart. Its products are not real.', 'Cricket, football, fitness (demo shop)', 'Agrabad, Chattogram', 'Chattogram', 'Agrabad',
  '01700000110', '01700000110', 'demo-sports-zone@rgbkart.test', 'approved', false, now() - interval '200 days') on conflict (user_id) do nothing;
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change)
values ('00000000-0000-0000-0000-000000000000', 'd0000000-0000-4000-8000-000000000011', 'authenticated', 'authenticated', 'demo-book-corner@rgbkart.test', '', now(),
  '{"provider":"email","providers":["email"]}', '{"full_name": "Demo Book Corner"}', now() - interval '200 days', now(), '', '', '', '') on conflict (id) do nothing;
insert into public.profiles (id, full_name) values ('d0000000-0000-4000-8000-000000000011', 'Demo Book Corner') on conflict (id) do nothing;
update public.profiles set role = 'seller', full_name = 'Demo Book Corner', phone = '01700000111', email_alerts = false where id = 'd0000000-0000-4000-8000-000000000011';
insert into public.seller_details (user_id, shop_name, shop_name_bn, shop_description, tagline, business_address, city, area, phone_public, whatsapp, email_public, status, allow_pickup, created_at)
values ('d0000000-0000-4000-8000-000000000011', 'Demo Book Corner', 'ডেমো বুক কর্নার', 'This is a demo shop made for testing RGBKart. Its products are not real.', 'Books and stationery (demo shop)', 'Nilkhet, Dhaka', 'Dhaka', 'Nilkhet',
  '01700000111', '01700000111', 'demo-book-corner@rgbkart.test', 'approved', true, now() - interval '200 days') on conflict (user_id) do nothing;
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change)
values ('00000000-0000-0000-0000-000000000000', 'd0000000-0000-4000-8000-000000000012', 'authenticated', 'authenticated', 'demo-auto-tools@rgbkart.test', '', now(),
  '{"provider":"email","providers":["email"]}', '{"full_name": "Demo Auto & Tools"}', now() - interval '200 days', now(), '', '', '', '') on conflict (id) do nothing;
insert into public.profiles (id, full_name) values ('d0000000-0000-4000-8000-000000000012', 'Demo Auto & Tools') on conflict (id) do nothing;
update public.profiles set role = 'seller', full_name = 'Demo Auto & Tools', phone = '01700000112', email_alerts = false where id = 'd0000000-0000-4000-8000-000000000012';
insert into public.seller_details (user_id, shop_name, shop_name_bn, shop_description, tagline, business_address, city, area, phone_public, whatsapp, email_public, status, allow_pickup, created_at)
values ('d0000000-0000-4000-8000-000000000012', 'Demo Auto & Tools', 'ডেমো অটো অ্যান্ড টুলস', 'This is a demo shop made for testing RGBKart. Its products are not real.', 'Car, bike and tool supplies (demo shop)', 'Tongi, Gazipur', 'Gazipur', 'Tongi',
  '01700000112', '01700000112', 'demo-auto-tools@rgbkart.test', 'approved', false, now() - interval '200 days') on conflict (user_id) do nothing;

-- move products
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000004' where 'demo' = any(tags) and title = 'Cotton Polo Shirt' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000004' where 'demo' = any(tags) and title = 'Formal Oxford Shirt' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000004' where 'demo' = any(tags) and title = 'Slim Fit Stretch Denim Jeans' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000004' where 'demo' = any(tags) and title = 'Embroidered Cotton Panjabi' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000004' where 'demo' = any(tags) and title = 'Fleece Hoodie' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000004' where 'demo' = any(tags) and title = 'Genuine Leather Wallet' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000004' where 'demo' = any(tags) and title = 'Tangail Cotton Saree' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000004' where 'demo' = any(tags) and title = 'Printed Lawn Three-Piece' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000004' where 'demo' = any(tags) and title = 'Block Print Kurti' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000004' where 'demo' = any(tags) and title = 'Premium Georgette Abaya' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000004' where 'demo' = any(tags) and title = 'Floral Midi Dress' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000004' where 'demo' = any(tags) and title = 'Polarized Aviator Sunglasses' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000006' where 'demo' = any(tags) and title = 'Kids Cotton Pajama Set (2 pcs)' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000006' where 'demo' = any(tags) and title = 'Huggies Dry Pants Diaper' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000006' where 'demo' = any(tags) and title = 'Philips Avent Feeding Bottle 260ml' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000006' where 'demo' = any(tags) and title = 'Johnson''s Baby Bath Gift Set' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000006' where 'demo' = any(tags) and title = 'Foldable Baby Stroller' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000005' where 'demo' = any(tags) and title = 'Leather Formal Oxford Shoes' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000005' where 'demo' = any(tags) and title = 'Comfort Block Heel Sandal' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000005' where 'demo' = any(tags) and title = 'Lightweight Running Shoes' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000005' where 'demo' = any(tags) and title = 'Comfort Slide Slippers' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000005' where 'demo' = any(tags) and title = 'Kids Light-up Sneakers' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000005' where 'demo' = any(tags) and title = 'Casio Analog Steel Watch MTP-1302' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000005' where 'demo' = any(tags) and title = 'Water-resistant Laptop Backpack' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000007' where 'demo' = any(tags) and title = 'CeraVe Hydrating Facial Cleanser 236ml' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000007' where 'demo' = any(tags) and title = 'Parachute Advansed Coconut Hair Oil' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000007' where 'demo' = any(tags) and title = 'Maybelline SuperStay Matte Lipstick' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000007' where 'demo' = any(tags) and title = 'Fogg Body Spray' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000007' where 'demo' = any(tags) and title = 'Dettol Antiseptic Liquid 500ml' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000008' where 'demo' = any(tags) and title = 'Chinigura Aromatic Rice' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000008' where 'demo' = any(tags) and title = 'Teer Soybean Oil' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000008' where 'demo' = any(tags) and title = 'Pran Potato Crackers (Pack of 12)' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000008' where 'demo' = any(tags) and title = 'Aarong Dairy Full Cream Milk Powder 1kg' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000008' where 'demo' = any(tags) and title = 'Vim Dishwashing Liquid 500ml' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000009' where 'demo' = any(tags) and title = 'Cotton Bed Sheet Set (Double)' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000009' where 'demo' = any(tags) and title = 'Non-stick Cookware Set (5 pcs)' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000009' where 'demo' = any(tags) and title = 'Handmade Jute Wall Hanging' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000009' where 'demo' = any(tags) and title = 'Philips 12W LED Bulb (Pack of 4)' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000010' where 'demo' = any(tags) and title = 'Kashmir Willow Cricket Bat' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000010' where 'demo' = any(tags) and title = 'Molten Match Football' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000010' where 'demo' = any(tags) and title = 'Yonex Nanoray Badminton Racket' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000010' where 'demo' = any(tags) and title = 'Adjustable Dumbbell Set 20kg' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000011' where 'demo' = any(tags) and title = 'Free: HSC Science textbooks (old syllabus)' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000011' where 'demo' = any(tags) and title = 'Thakurmar Jhuli (Illustrated)' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000011' where 'demo' = any(tags) and title = 'Tafsir Ibn Kathir (Bangla, full set)' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000011' where 'demo' = any(tags) and title = 'Matador Ball Pen (Box of 50)' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000006' where 'demo' = any(tags) and title = 'RC Off-road Car 1:16' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000006' where 'demo' = any(tags) and title = 'Magnetic Building Tiles (60 pcs)' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000006' where 'demo' = any(tags) and title = 'Teddy Bear 60cm' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000006' where 'demo' = any(tags) and title = 'Ludo & Snakes and Ladders (2-in-1)' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000006' where 'demo' = any(tags) and title = 'Kids Tricycle with Push Handle' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000012' where 'demo' = any(tags) and title = 'Studds Full-face Helmet' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000012' where 'demo' = any(tags) and title = 'Motorbike Mobile Holder (Waterproof)' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000012' where 'demo' = any(tags) and title = 'Car Seat Cover Set (Leatherette)' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000012' where 'demo' = any(tags) and title = '70mai Dash Cam M300' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000012' where 'demo' = any(tags) and title = 'Motul Engine Oil 1L' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000012' where 'demo' = any(tags) and title = 'Bosch GSB 550 Impact Drill' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000012' where 'demo' = any(tags) and title = 'Stanley Screwdriver Set (10 pcs)' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000012' where 'demo' = any(tags) and title = 'Home Electrical Check-up (Service)' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000012' where 'demo' = any(tags) and title = 'Stainless Steel Kitchen Sink Mixer Tap' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.products set seller_id = 'd0000000-0000-4000-8000-000000000012' where 'demo' = any(tags) and title = 'Digital Fingerprint Door Lock' and seller_id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002');
update public.featured_requests f set seller_id = p.seller_id from public.products p where p.id = f.product_id and 'demo' = any(p.tags) and f.seller_id is distinct from p.seller_id;
commit;
select (select count(*) from public.top_shops(48)) as shops_in_top_shops,
       (select count(*) from public.seller_details where shop_name like 'Demo %') as demo_shops;
