-- Main menu: "Featured" right after "Shop" (owner, 29 Oct 2026). It is also shown highlighted in gold with a star (menu.js).
-- "Deals of the Day" stays red as now. Other links keep their order. You can still move links in Admin → Main menu.
-- Run once in Supabase → SQL Editor. Safe to run again.

with ordered as (
  select id, row_number() over (order by
           case when link_type = 'featured' then
                  coalesce((select m2.sort_order from public.menu_items m2 where m2.link_type = 'shop' order by m2.sort_order limit 1), sort_order)
                else sort_order end,
           case when link_type = 'shop' then 0 when link_type = 'featured' then 1 else 2 end,
           id) as rn
    from public.menu_items
)
update public.menu_items m set sort_order = o.rn * 10, updated_at = now()
  from ordered o where o.id = m.id and m.sort_order is distinct from o.rn * 10;

select string_agg(label, ' · ' order by sort_order) as menu_order from public.menu_items where is_active;
