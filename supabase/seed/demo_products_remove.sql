-- Removes ALL RGBKart demo data added by demo_products.sql: the 3 demo sellers, their 100 products
-- (with versions, Featured, orders and messages about them) and the demo home page sections.
-- Run in Supabase → SQL Editor. Safe to run again.
begin;
delete from public.home_sections where subtitle like '%· demo';
delete from auth.users where id in ('d0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000002', 'd0000000-0000-4000-8000-000000000003', 'd0000000-0000-4000-8000-000000000004', 'd0000000-0000-4000-8000-000000000005', 'd0000000-0000-4000-8000-000000000006', 'd0000000-0000-4000-8000-000000000007', 'd0000000-0000-4000-8000-000000000008', 'd0000000-0000-4000-8000-000000000009', 'd0000000-0000-4000-8000-000000000010', 'd0000000-0000-4000-8000-000000000011', 'd0000000-0000-4000-8000-000000000012');
commit;
select (select count(*) from public.products where 'demo' = any(tags)) as demo_products_left;
