-- Removes the demo reviews made by demo_reviews.sql: the DEMO-… orders (their reviews go with them) and the 8 demo buyers.
-- Stars on products and shops go back to what real customers gave. Run in Supabase → SQL Editor. Safe to run again.
begin;
delete from public.orders where order_no like 'DEMO-%';
delete from auth.users where email like 'demo-buyer-%@rgbkart.test';
commit;
select (select count(*) from public.orders where order_no like 'DEMO-%') as demo_orders_left;
