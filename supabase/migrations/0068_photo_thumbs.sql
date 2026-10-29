-- 0068 Small photo copies (audit Part B, 29 Oct 2026).
-- Product cards show a small 480 px copy of the first photo ("<photo>-t.webp", made in the browser by thumbs.js).
-- has_thumb says the copy exists, so cards never ask for a copy that is missing (PageSpeed showed those as errors).
-- Admins (Master / Co-admin) can make copies for older photos: Admin → Products → "Make small photos".
-- Safe to run more than once.

alter table public.product_images add column if not exists has_thumb boolean not null default false;

-- Admins may save small copies (only files ending "-t.webp") into any shop's photo folder
drop policy if exists "Admins add small photo copies" on storage.objects;
create policy "Admins add small photo copies" on storage.objects for insert to authenticated
  with check (bucket_id = 'product-images' and name like '%-t.webp' and public.has_staff_role(array['master_admin', 'co_admin']));
drop policy if exists "Admins replace small photo copies" on storage.objects;
create policy "Admins replace small photo copies" on storage.objects for update to authenticated
  using (bucket_id = 'product-images' and name like '%-t.webp' and public.has_staff_role(array['master_admin', 'co_admin']));

-- Mark photos whose small copy was saved. A shop can mark only photos in its own folder; staff can mark any.
create or replace function public.mark_thumbs(p_paths text[])
returns integer language plpgsql security definer set search_path = ''
as $$
declare n integer;
begin
  if auth.uid() is null then raise exception 'Please sign in'; end if;
  update public.product_images set has_thumb = true
   where storage_path = any (p_paths) and not has_thumb
     and (split_part(storage_path, '/', 1) = auth.uid()::text
          or public.has_staff_role(array['master_admin', 'co_admin', 'editor']));
  get diagnostics n = row_count;
  return n;
end $$;
revoke execute on function public.mark_thumbs(text[]) from public, anon;
grant execute on function public.mark_thumbs(text[]) to authenticated;

select count(*) as photos, count(*) filter (where has_thumb) as with_small_copy from public.product_images;
