-- Main menu: links that open SEVERAL categories together (e.g. "Fashion" = Men's + Women's Fashion + Shoes + Watches & Bags),
-- and two new links, Electronics and Fashion, placed after Pre-Owned.
-- Run once in Supabase → SQL Editor, AFTER 0016_main_menu.sql. Safe to run again.

alter table public.menu_items add column if not exists category_ids bigint[];

alter table public.menu_items drop constraint if exists menu_items_link_type_check;
alter table public.menu_items add constraint menu_items_link_type_check check (link_type in
  ('home', 'shop', 'deals', 'featured', 'newest', 'pre_owned', 'free_delivery', 'category', 'categories', 'sell', 'url'));
alter table public.menu_items drop constraint if exists menu_items_group_check;
alter table public.menu_items add constraint menu_items_group_check check (
  link_type <> 'categories' or coalesce(cardinality(category_ids), 0) between 1 and 20);

-- Electronics and Fashion (only added if a link with that name isn't there yet)
insert into public.menu_items (label, label_bn, link_type, category_ids, sort_order)
select v.label, v.label_bn, 'categories',
       array(select c.id from public.categories c join unnest(v.slugs) with ordinality as s(slug, n) on s.slug = c.slug order by s.n),
       v.sort_order
from (values
  ('Electronics', 'ইলেকট্রনিক্স', array['mobiles-and-tablets', 'computers-and-laptops', 'tv-audio-and-video', 'cameras-and-drones', 'gaming-and-rgb-setup', 'home-appliances'], 63),
  ('Fashion',     'ফ্যাশন',       array['men-s-fashion', 'women-s-fashion', 'shoes', 'watches-bags-and-accessories'], 66)
) as v(label, label_bn, slugs, sort_order)
where not exists (select 1 from public.menu_items m where lower(m.label) = lower(v.label))
  and exists (select 1 from public.categories c where c.slug = any (v.slugs));

-- Check
select sort_order, label, link_type, cardinality(category_ids) as categories, is_hot, is_active from public.menu_items order by sort_order, id;
