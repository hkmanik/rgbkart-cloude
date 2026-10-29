-- STEP 1 of the launch clean-up: only COUNTS what step 2 would remove. Changes nothing. Run any time.
-- Run in Supabase → SQL Editor and look at the numbers.
select 'Orders (with their items, returns, reviews, coupon uses)' as what, count(*) as how_many from public.orders
union all select 'Chats (conversations)', count(*) from public.conversations
union all select 'Product questions', count(*) from public.product_questions
union all select 'Complaints / reports', count(*) from public.reports
union all select 'Alerts (bell notifications)', count(*) from public.notifications
union all select 'Featured requests', count(*) from public.featured_requests
union all select 'Payments (TrxIDs)', count(*) from public.payments
union all select 'Ads', count(*) from public.ads
union all select 'Products shown as Featured now', count(*) from public.products where is_featured
union all select 'Guest accounts (no email: guest orders, one-time sellers)', count(*) from auth.users where coalesce(is_anonymous, false)
union all select '  of which one-time-seller listings', count(*) from public.products p join auth.users u on u.id = p.seller_id where coalesce(u.is_anonymous, false)
union all select 'Visitor counts and activity log rows', (select count(*) from public.page_visits) + (select count(*) from public.activity_log)
union all select 'Old demo shops / demo buyers', count(*) from auth.users where id::text like 'd0000000-0000-4000-8000-%' or email like 'demo-buyer-%@rgbkart.test'
union all select 'Duplicate "Men''s Shoes" category (id 136, empty)', count(*) from public.categories c where c.id = 136 and c.slug = 'men-s-shoes-2' and not exists (select 1 from public.products where category_id = 136)
union all select '--- KEPT: accounts with an email (shops, customers, team)', count(*) from auth.users where not coalesce(is_anonymous, false)
union all select '--- KEPT: shops', count(*) from public.seller_details
union all select '--- KEPT: products of shops', count(*) from public.products p join auth.users u on u.id = p.seller_id where not coalesce(u.is_anonymous, false);
