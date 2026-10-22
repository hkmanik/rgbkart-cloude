-- More kinds of home page sections: products with options (size, colour…), brand-new only, price negotiable.
-- Run once in Supabase → SQL Editor, AFTER 0022_bangla.sql. Safe to run again.

alter table public.home_sections drop constraint if exists home_sections_section_type_check;
alter table public.home_sections add constraint home_sections_section_type_check
  check (section_type in ('featured', 'deals', 'newest', 'pre_owned', 'free_delivery', 'category', 'variable', 'brand_new', 'negotiable'));

select 'home section types ready' as status;
