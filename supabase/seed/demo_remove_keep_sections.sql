-- Removes ALL RGBKart demo data but KEEPS every home page section (owner's request, 23 Oct 2026).
-- Deleted: the 12 demo shops (d0000000-…) with their 100 demo products, photos records, Featured, ads, payments,
-- coupons, delivery settings, orders, reviews, questions and messages; the 8 demo buyers (demo-buyer-…@rgbkart.test)
-- and their DEMO-… orders and reviews; complaints about demo shops or products.
-- Kept: all home page sections (the "· demo" mark is taken off their subtitles), categories, menu, settings,
-- your own shops, products, accounts and orders. Sections fill again as real products are added.
-- Run in Supabase → SQL Editor. Safe to run again.
begin;

-- 1. keep the home page sections; just drop the "· demo" mark from their subtitles
update public.home_sections
   set subtitle = nullif(trim(regexp_replace(subtitle, '\s*·\s*demo\s*$', '')), '')
 where subtitle ~ '·\s*demo\s*$';

-- 2. complaints about demo shops / products (they would lose their link otherwise)
delete from public.reports
 where seller_id::text like 'd0000000-0000-4000-8000-%'
    or product_id in (select id from public.products where seller_id::text like 'd0000000-0000-4000-8000-%');

-- 3. demo orders, demo shops (their products, orders and the rest go with them) and demo buyers
delete from public.orders where order_no like 'DEMO-%';
delete from auth.users where id::text like 'd0000000-0000-4000-8000-%';
delete from auth.users where email like 'demo-buyer-%@rgbkart.test' or id::text like 'd1000000-0000-4000-8000-%';

-- 4. any product still tagged demo by a demo seller id (safety net)
delete from public.products where 'demo' = any (tags) and seller_id::text like 'd0000000-0000-4000-8000-%';

commit;

select (select count(*) from public.products where 'demo' = any (tags))                    as demo_products_left,
       (select count(*) from public.seller_details where user_id::text like 'd0000000-%')    as demo_shops_left,
       (select count(*) from public.home_sections)                                          as home_sections_kept,
       (select count(*) from public.products where status = 'approved')                      as live_products_now;
