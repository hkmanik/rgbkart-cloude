-- Pictures managed by RGBKart staff:
--   1. a picture for each category card (home page and All categories page), uploaded in Admin → Categories
--   2. staff can add, remove and re-order the photos of ANY product in Admin → Products (also demo products)
-- Run once in Supabase → SQL Editor, AFTER 0024_bulk_prices.sql. Safe to run again.

-- 1. Category picture: a web address (https://…, e.g. an uploaded picture) or a file on our own site (assets/…). Empty = emoji icon.
alter table public.categories add column if not exists image_url text
  check (image_url is null or image_url ~* '^(https://|assets/)[^\s<>"]+$');

-- 2. Product photos by staff. p_paths is the full new list, in order (the first one is the main photo).
--    New photos must be uploaded into the staff folder admin/…; photos the product already has can be kept.
create or replace function public.admin_set_product_photos(p_product bigint, p_paths text[])
returns integer language plpgsql security definer set search_path = ''
as $$
declare n int := 0; pth text;
begin
  if not public.has_staff_role(array['master_admin', 'co_admin', 'editor']) then raise exception 'Only RGBKart staff can do this'; end if;
  if not exists (select 1 from public.products where id = p_product) then raise exception 'Product not found'; end if;
  if coalesce(array_length(p_paths, 1), 0) > 10 then raise exception 'Up to 10 photos'; end if;
  foreach pth in array coalesce(p_paths, '{}') loop
    if pth !~ '^admin/' and not exists (select 1 from public.product_images where product_id = p_product and storage_path = pth) then
      raise exception 'Upload the photo first';
    end if;
  end loop;
  delete from public.product_images where product_id = p_product and storage_path <> all (coalesce(p_paths, '{}'));
  foreach pth in array coalesce(p_paths, '{}') loop
    n := n + 1;
    update public.product_images set sort_order = n * 10 where product_id = p_product and storage_path = pth;
    if not found then insert into public.product_images (product_id, storage_path, sort_order) values (p_product, pth, n * 10); end if;
  end loop;
  return n;
end; $$;
revoke execute on function public.admin_set_product_photos(bigint, text[]) from public, anon;
grant  execute on function public.admin_set_product_photos(bigint, text[]) to authenticated;

select 'pictures ready' as status;
