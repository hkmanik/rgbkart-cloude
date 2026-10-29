-- Buyer choices, part 2 (owner, 29 Oct 2026).
-- 1. Up to 3 "same price" choices per product (was 2), for example Colour and Keyboard language.
-- 2. products.choice_photos: which photo to show for each choice value, e.g. {"<Black option id>": 0, "<Silver option id>": 2}
--    (the number is the photo's position: 0 = first photo). The product page switches to that photo when the buyer picks it.
-- Run once in Supabase → SQL Editor, AFTER 0063_buyer_choices.sql. Safe to run again.

alter table public.products drop constraint if exists products_buyer_choices;
alter table public.products add constraint products_buyer_choices check (cardinality(buyer_choice_ids) <= 3);
alter table public.products add column if not exists choice_photos jsonb not null default '{}'::jsonb;
alter table public.products drop constraint if exists products_choice_photos;
alter table public.products add constraint products_choice_photos check (jsonb_typeof(choice_photos) = 'object' and pg_column_size(choice_photos) < 4000);
grant insert (choice_photos), update (choice_photos) on public.products to authenticated;

select (select count(*) from information_schema.columns where table_name = 'products' and column_name = 'choice_photos') as choice_photos_ready;
