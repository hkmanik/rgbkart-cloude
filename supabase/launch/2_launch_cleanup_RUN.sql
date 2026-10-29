-- STEP 2 of the launch clean-up: run ONCE, on the day you open RGBKart to the public. It CANNOT be undone.
-- Run 1_launch_cleanup_PREVIEW.sql first and check the numbers.
--
-- REMOVED (all test activity):
--   all orders (with their items, returns, reviews and coupon uses); shop invoice numbers start again at 00001
--   chats, product questions, complaints, alerts
--   Featured requests, payments (TrxIDs), ads; products stop being Featured (give it again for free in Admin → Products if you want)
--   guest accounts (no email) and the one-time-seller listings made with them
--   visitor counts and the activity log, so the dashboard starts from zero
--   old demo shops / demo buyers (if any are left) and the empty duplicate "Men's Shoes" category (id 136)
-- KEPT: every account with an email (your shops, customers and team), shops with their logo, banner, delivery and coupons
--   (coupon use counts go back to 0), shop products, categories, attributes, menu, home page sections, pages, rates and settings.
-- To also remove some test SHOPS completely, see the box at the end.

begin;

delete from public.orders where true;                                   -- items, returns, reviews, coupon uses go with them
update public.shop_coupons set used_count = 0 where used_count <> 0;
delete from public.invoice_counters where true;                         -- invoices start again at …-00001

delete from public.messages where true;
delete from public.conversations where true;
delete from public.product_questions where true;
delete from public.reports where true;
delete from public.notifications where true;

delete from public.payments where true;
delete from public.featured_requests where true;
delete from public.ads where true;
update public.products set is_featured = false where is_featured;

delete from auth.users where coalesce(is_anonymous, false);             -- guests and their one-time-seller listings

delete from public.page_visits where true;
delete from public.activity_log where true;

delete from auth.users where id::text like 'd0000000-0000-4000-8000-%' or email like 'demo-buyer-%@rgbkart.test';
delete from public.categories c where c.id = 136 and c.slug = 'men-s-shoes-2' and not exists (select 1 from public.products where category_id = 136);

commit;

select (select count(*) from public.orders) as orders_left, (select count(*) from public.seller_details) as shops_kept,
       (select count(*) from public.products) as products_kept;

-- ┌───────────────────────────────────────────────────────────────────────────────────────────┐
-- │ OPTIONAL: remove whole test shops (the account, shop, products, coupons… everything).        │
-- │ Put their sign-in emails in the list, take away the two dashes at the start of the line,     │
-- │ and run just that line. Never put your own admin email here.                                 │
-- └───────────────────────────────────────────────────────────────────────────────────────────┘
-- delete from auth.users where lower(email) in ('shop-a@example.com', 'shop-b@example.com');
