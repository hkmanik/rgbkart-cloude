-- More ad spaces and ready-made banner pictures (owner, 29 Oct 2026).
-- Ads are now mainly a ready-made picture (designed outside RGBKart) plus the page it opens. Each space shows the picture size to use.
-- New spaces:
--   popup_main   Home page pop-up: one big picture in the middle of the home page, once per visit, with a ✕ close button
--   popup_side   Small pop-ups: up to 3 small pictures in the bottom-right corner of shop pages, each with ✕
--   cat_top      Category & search page banner, above the products
--   product_side Product page banner, under the Buy box
-- Starting prices are only a suggestion: change them any time in Admin → Payments → Rates (price per day, minimum days, on/off).
-- Run once in Supabase → SQL Editor. Safe to run again.

alter table public.ad_rates drop constraint if exists ad_rates_placement_check;
alter table public.ad_rates add constraint ad_rates_placement_check check (placement ~ '^[a-z_]{3,30}$');
alter table public.ad_rates add column if not exists size_hint text;
alter table public.ad_rates add column if not exists kind text not null default 'banner';
alter table public.ad_rates drop constraint if exists ad_rates_kind_check;
alter table public.ad_rates add constraint ad_rates_kind_check check (kind in ('banner', 'popup'));

insert into public.ad_rates (placement, name, description, price_per_day, min_days, sort_order, size_hint, kind, is_active) values
  ('popup_main',   'Home page pop-up (big, centre)', 'Opens in the middle of the home page once per visit. Visitors close it with ✕.', 200, 1, 5,  '600 × 600 px (square)', 'popup', true),
  ('popup_side',   'Small pop-up (bottom-right)',    'Small picture in the bottom-right corner of shop pages. Up to 3 at a time, each with ✕.', 80, 1, 6, '300 × 250 px', 'popup', true),
  ('cat_top',      'Category & search page banner',  'Wide banner above the products on category and search pages', 80, 1, 25, '1200 × 200 px', 'banner', true),
  ('product_side', 'Product page banner',            'Banner under the Buy box on every product page', 60, 1, 35, '600 × 300 px', 'banner', true)
on conflict (placement) do nothing;
update public.ad_rates set size_hint = '1200 × 300 px' where placement = 'home_top' and size_hint is null;
update public.ad_rates set size_hint = '1200 × 200 px' where placement = 'home_mid' and size_hint is null;
update public.ad_rates set size_hint = '300 × 600 px'  where placement = 'cat_side' and size_hint is null;

select string_agg(placement || ' (' || coalesce(size_hint, '') || ')', ', ' order by sort_order) as ad_spaces from public.ad_rates;
