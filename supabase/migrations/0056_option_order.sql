-- Attribute options in A–Z order (owner, 25 Oct 2026), except clothing sizes, which keep size order.
-- Order used everywhere options are listed (product editors, filters, product page) via attribute_options.sort_order:
--   1. clothing sizes XXS, XS, S, M, L, XL, XXL/2XL, XXXL/3XL, 4XL, 5XL (in that order)
--   2. values starting with a number, by the number (4, 8, 16, 32 GB; 1000–2999 mAh before 5000 mAh; 6.5 inch before 11 inch),
--      reading months/years and GB/TB correctly (6 Months, 1 Year, 2 Years; 512 GB, 1 TB)
--   3. everything else A–Z (case ignored)
-- All attributes are put in this order now, and an attribute is put in order again whenever an option is added to it.
-- Run once in Supabase → SQL Editor, AFTER 0055_admin_product_options.sql. Safe to run again.

create or replace function public.option_size_rank(v text)
returns int language sql immutable set search_path = ''
as $$
  select case upper(regexp_replace(coalesce(v, ''), '\s', '', 'g'))
    when 'XXS' then 1 when 'XS' then 2 when 'S' then 3 when 'M' then 4 when 'L' then 5 when 'XL' then 6
    when 'XXL' then 7 when '2XL' then 7 when 'XXXL' then 8 when '3XL' then 8 when '4XL' then 9 when '5XL' then 10
    else null end
$$;

create or replace function public.reorder_attribute_options(p_attr bigint)
returns void language plpgsql security definer set search_path = ''
as $$
begin
  perform set_config('rgbkart.reordering', 'on', true);
  update public.attribute_options o set sort_order = x.rn * 10
    from (select id, row_number() over (order by
            public.option_size_rank(value) is null, public.option_size_rank(value),
            substring(value from '^\s*([0-9]+(?:\.[0-9]+)?)') is null,
            nullif(substring(value from '^\s*([0-9]+(?:\.[0-9]+)?)'), '')::numeric
              * case when value ~* '^\s*[0-9.]+\s*(years?|yrs?)\M' then 12            -- 6 Months before 1 Year before 2 Years
                     when value ~* '^\s*[0-9.]+\s*weeks?\M' then 0.25
                     when value ~* '^\s*[0-9.]+\s*days?\M' then 0.033
                     when value ~* '^\s*[0-9.]+\s*TB\M' then 1024                  -- 512 GB before 1 TB
                     when value ~* '^\s*[0-9.]+\s*MB\M' then 0.001
                     else 1 end,
            lower(value), id) as rn
          from public.attribute_options where attribute_id = p_attr) x
   where o.id = x.id and o.sort_order is distinct from x.rn * 10;
  perform set_config('rgbkart.reordering', 'off', true);
end; $$;
revoke execute on function public.reorder_attribute_options(bigint) from public, anon, authenticated;

create or replace function public.attribute_options_keep_order()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  if current_setting('rgbkart.reordering', true) = 'on' then return null; end if;
  perform public.reorder_attribute_options(new.attribute_id);
  return null;
end; $$;
revoke execute on function public.attribute_options_keep_order() from public, anon, authenticated;
drop trigger if exists attribute_options_keep_order on public.attribute_options;
create trigger attribute_options_keep_order after insert or update of value on public.attribute_options
  for each row execute function public.attribute_options_keep_order();

-- Put every attribute in order now
do $$ declare a record; begin
  for a in select id from public.attributes loop perform public.reorder_attribute_options(a.id); end loop;
end $$;

select (select count(*) from public.attributes) as attributes_sorted,
       (select string_agg(value, ', ' order by sort_order) from public.attribute_options o join public.attributes a on a.id = o.attribute_id where a.name = 'RAM') as ram_order;
