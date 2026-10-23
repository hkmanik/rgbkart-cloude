-- Category pictures: a picture for each category card (home page and All categories page).
-- image_url is a web address (https://…) or a picture on our own site (assets/…). Empty = show the emoji icon.
-- Set it in Admin → Categories → "Picture for the category card".
-- Run once in Supabase → SQL Editor, AFTER 0024_bulk_prices.sql. Safe to run again.

alter table public.categories add column if not exists image_url text
  check (image_url is null or image_url ~* '^(https://|assets/)[^\s<>"]+$');

select 'category pictures ready' as status;
