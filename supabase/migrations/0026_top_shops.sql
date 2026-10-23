-- "Top shops" on the home page: a sliding row of shops with logo, banner and name.
-- Ranked by: most Featured products right now, then most live products, then newest activity.
-- Adds the section type 'top_shops' and puts one "Top shops" section right below the categories (first section).
-- Run once in Supabase → SQL Editor, AFTER 0025_category_pictures.sql. Safe to run again.

create or replace function public.top_shops(p_limit integer default 12)
returns table (user_id uuid, shop_name text, shop_name_bn text, shop_slug text, tagline text, logo_path text, banner_path text,
               city text, area text, featured_count integer, product_count integer)
language sql stable security definer set search_path = ''
as $$
  select s.user_id, s.shop_name, s.shop_name_bn, s.shop_slug, s.tagline, s.logo_path, s.banner_path, s.city, s.area,
         count(*) filter (where p.is_featured)::int, count(*)::int
  from public.seller_details s
  join public.profiles pr on pr.id = s.user_id and pr.role = 'seller'      -- shops only, not one-time sellers
  join public.products p on p.seller_id = s.user_id and p.status = 'approved'
  where s.status = 'approved' and not coalesce(s.vacation_mode, false)
  group by s.user_id
  order by count(*) filter (where p.is_featured) desc, count(*) desc, max(p.published_at) desc nulls last
  limit greatest(1, least(coalesce(p_limit, 12), 48))
$$;
grant execute on function public.top_shops(integer) to anon, authenticated;

alter table public.home_sections drop constraint if exists home_sections_section_type_check;
alter table public.home_sections add constraint home_sections_section_type_check
  check (section_type in ('featured', 'deals', 'newest', 'pre_owned', 'free_delivery', 'category', 'variable', 'brand_new', 'negotiable', 'top_shops'));

insert into public.home_sections (title, title_bn, subtitle, subtitle_bn, section_type, item_count, sort_order, is_active)
select 'Top Shops', 'সেরা দোকান', 'Shops with the most Featured products', 'সবচেয়ে বেশি ফিচার্ড পণ্যের দোকান', 'top_shops', 12,
       coalesce((select min(sort_order) from public.home_sections), 10) - 5, true
where not exists (select 1 from public.home_sections where section_type = 'top_shops');

select (select count(*) from public.top_shops(12)) as shops_found;
