-- Shops can add a missing brand themselves (owner, 29 Oct 2026). Brand lists (Fashion Brand, Phone Brand…) can never hold
-- every brand, so in Seller Center → Add product a shop can type a brand that isn't in the list. It is added to that list
-- for everyone (kept in A–Z order by 0056) and chosen for the product. Admin sees who added it in Admin → Attributes and can
-- rename or delete it there. Limits: only brand lists, approved shops, 2–40 letters, at most 10 new brands per shop per day;
-- the same name in other capitals/spaces reuses the existing brand.
-- Run once in Supabase → SQL Editor. Safe to run again.

alter table public.attribute_options add column if not exists added_by uuid references auth.users (id) on delete set null;
alter table public.attribute_options add column if not exists added_at timestamptz;

create or replace function public.seller_add_brand(p_attribute bigint, p_name text)
returns bigint language plpgsql security definer set search_path = ''
as $$
declare uid uuid := auth.uid(); nm text; aname text; oid bigint;
begin
  if uid is null or not public.is_approved_seller() then raise exception 'Only approved shops can add brands'; end if;
  select name into aname from public.attributes where id = p_attribute;
  if aname is null or aname !~* '\mbrand\M' then raise exception 'New values can only be added to brand lists'; end if;
  nm := regexp_replace(trim(coalesce(p_name, '')), '\s+', ' ', 'g');
  if char_length(nm) < 2 or char_length(nm) > 40 then raise exception 'Write the brand name (2 to 40 letters)'; end if;
  if nm !~ '^[[:alnum:]][[:alnum:] &''.+/-]*$' then raise exception 'Use letters, numbers, spaces and & . + - / only'; end if;
  select id into oid from public.attribute_options where attribute_id = p_attribute and lower(replace(value, ' ', '')) = lower(replace(nm, ' ', '')) limit 1;
  if oid is not null then return oid; end if;
  if (select count(*) from public.attribute_options where added_by = uid and added_at > now() - interval '1 day') >= 10 then
    raise exception 'You have added 10 brands today. Please try again tomorrow, or ask RGBKart to add it.';
  end if;
  insert into public.attribute_options (attribute_id, value, added_by, added_at) values (p_attribute, nm, uid, now()) returning id into oid;
  return oid;
end; $$;
revoke execute on function public.seller_add_brand(bigint, text) from public, anon;
grant  execute on function public.seller_add_brand(bigint, text) to authenticated;

select to_regprocedure('public.seller_add_brand(bigint, text)') is not null as add_brand_ready;
