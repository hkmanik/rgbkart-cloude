-- Shoes: options are Colour, Shoe Size and Shoe Material (owner, 25 Oct 2026).
-- 1. "Shoe Size" (single choice) with EU 35–47 (existing values are kept, missing ones added).
-- 2. New "Shoe Material" (single choice) with materials shoes are made of (the general "Material" list is furniture/kitchen).
-- 3. On the Shoes category (all shoe sub-categories inherit it): Colour, Shoe Size, Shoe Material.
-- 4. Fabric and Pattern are taken off Shoes and its sub-categories. Fashion Brand stays as a product detail.
-- Options are put in order by 0056 (EU 35, EU 36 …). Products already saved keep their details.
-- Run once in Supabase → SQL Editor, AFTER 0056_option_order.sql. Safe to run again.

insert into public.attributes (name, input_type, is_filterable) values ('Shoe Size', 'select', true) on conflict (name) do nothing;
insert into public.attributes (name, input_type, is_filterable) values ('Shoe Material', 'select', true) on conflict (name) do nothing;

insert into public.attribute_options (attribute_id, value)
select a.id, v from public.attributes a, unnest(array['EU 35','EU 36','EU 37','EU 38','EU 39','EU 40','EU 41','EU 42','EU 43','EU 44','EU 45','EU 46','EU 47']) v
 where a.name = 'Shoe Size'
on conflict (attribute_id, value) do nothing;

insert into public.attribute_options (attribute_id, value)
select a.id, v from public.attributes a, unnest(array['Genuine Leather','Synthetic Leather (PU)','Suede','Canvas','Mesh / Knit','Rubber','EVA / Foam','Fabric','Jute','Plastic / PVC']) v
 where a.name = 'Shoe Material'
on conflict (attribute_id, value) do nothing;

-- Shoes tree (the main category and everything under it)
with recursive tree as (
  select id from public.categories where slug = 'shoes'
  union all select c.id from public.categories c join tree on c.parent_id = tree.id
)
delete from public.category_attributes ca
 using public.attributes a
 where a.id = ca.attribute_id and a.name in ('Fabric', 'Pattern') and ca.category_id in (select id from tree);

insert into public.category_attributes (category_id, attribute_id, is_required, sort_order)
select c.id, a.id, v.req, v.ord
  from public.categories c
  join (values ('Colour', true, 10), ('Shoe Size', false, 20), ('Shoe Material', false, 30)) v(name, req, ord) on true
  join public.attributes a on a.name = v.name
 where c.slug = 'shoes'
on conflict (category_id, attribute_id) do nothing;

select string_agg(a.name, ', ' order by ca.sort_order) as shoes_attributes,
       (select count(*) from public.attribute_options o join public.attributes x on x.id = o.attribute_id where x.name = 'Shoe Size') as shoe_sizes
  from public.category_attributes ca join public.attributes a on a.id = ca.attribute_id
  join public.categories c on c.id = ca.category_id where c.slug = 'shoes';
