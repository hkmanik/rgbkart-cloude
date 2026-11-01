-- 0074_rebrand_deshibasket.sql  (owner, 1 Nov 2026)
-- New name: RGBKart / Red & Green Basket  →  DeshiBasket, new address deshibasket.com.
-- Run this on SWITCH DAY, after deshibasket.com shows the site (same day the new pages go live).
-- Changes only words people read: messages and errors inside database functions (alerts, SMS, admin
-- messages), the policy pages, and the name of the official shop. Nothing about orders, money or
-- accounts changes. Safe to run again.

-- 1. Database functions: rewrite every public function whose text mentions the old name or address.
--    pg_get_functiondef keeps owner settings (security definer, search_path); grants stay with
--    CREATE OR REPLACE.
do $$
declare r record; def text;
begin
  for r in
    select p.oid from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.prokind = 'f'
      and p.prosrc ~ '(RGBKart|Red & Green Basket|rgbkart\.com)'
  loop
    def := pg_get_functiondef(r.oid);
    def := replace(def, 'Red & Green Basket (RGBKart)', 'DeshiBasket');
    def := replace(def, 'Red & Green Basket', 'DeshiBasket');
    def := replace(def, 'RGBKart', 'DeshiBasket');
    def := replace(def, 'support@rgbkart.com', 'support@deshibasket.com');
    def := regexp_replace(def, '(https?://)?(www\.)?rgbkart\.com', 'deshibasket.com', 'g');
    execute def;
  end loop;
end $$;

-- 2. Policy and help pages (English and Bangla)
update public.site_pages set
  title    = replace(replace(title,    'Red & Green Basket', 'DeshiBasket'), 'RGBKart', 'DeshiBasket'),
  title_bn = replace(replace(coalesce(title_bn, ''), 'রেড অ্যান্ড গ্রিন বাস্কেট', 'দেশি বাস্কেট'), 'RGBKart', 'DeshiBasket'),
  body     = replace(replace(replace(body, 'Red & Green Basket (RGBKart)', 'DeshiBasket'), 'Red & Green Basket', 'DeshiBasket'), 'RGBKart', 'DeshiBasket'),
  body_bn  = replace(replace(coalesce(body_bn, ''), 'রেড অ্যান্ড গ্রিন বাস্কেট', 'দেশি বাস্কেট'), 'RGBKart', 'DeshiBasket')
where (coalesce(title,'') || coalesce(title_bn,'') || coalesce(body,'') || coalesce(body_bn,''))
      ~ '(RGBKart|Red & Green Basket|rgbkart\.com|রেড অ্যান্ড গ্রিন বাস্কেট)';
-- web and e-mail addresses in the pages (rgbkart@gmail.com, the admin login, is not touched)
update public.site_pages set
  body    = replace(replace(body,    'support@rgbkart.com', 'support@deshibasket.com'), 'rgbkart.com', 'deshibasket.com'),
  body_bn = replace(replace(body_bn, 'support@rgbkart.com', 'support@deshibasket.com'), 'rgbkart.com', 'deshibasket.com')
where coalesce(body,'') || coalesce(body_bn,'') ~ 'rgbkart\.com';

-- 3. The official shop's name
update public.seller_details
   set shop_name = replace(shop_name, 'RGBKart', 'DeshiBasket')
 where is_official and shop_name like '%RGBKart%';

-- Check: both numbers should be 0
select
  (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.prosrc ~ '(RGBKart|Red & Green Basket|rgbkart\.com)') as functions_left,
  (select count(*) from public.site_pages
    where (coalesce(title,'') || coalesce(body,'') || coalesce(body_bn,'')) ~ '(RGBKart|Red & Green Basket|rgbkart\.com)') as pages_left;
