-- Removes ALL RGBKart demo data added by demo_products.sql: the demo shops, their 100 products
-- (with versions, Featured, orders, reviews and messages about them), the demo buyers from demo_reviews.sql and the demo home page sections.
-- Run in Supabase → SQL Editor. Safe to run again.
begin;
delete from public.home_sections where subtitle like '%· demo';
delete from public.orders where order_no like 'DEMO-%';
delete from auth.users where id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002', 'd0000000-0000-4000-8000-000000000003', 'd0000000-0000-4000-8000-000000000004', 'd0000000-0000-4000-8000-000000000005', 'd0000000-0000-4000-8000-000000000006', 'd0000000-0000-4000-8000-000000000007', 'd0000000-0000-4000-8000-000000000008', 'd0000000-0000-4000-8000-000000000009', 'd0000000-0000-4000-8000-000000000010', 'd0000000-0000-4000-8000-000000000011', 'd0000000-0000-4000-8000-000000000012');
delete from auth.users where email like 'demo-buyer-%@rgbkart.test';
commit;
select (select count(*) from public.products where 'demo' = any(tags)) as demo_products_left;
