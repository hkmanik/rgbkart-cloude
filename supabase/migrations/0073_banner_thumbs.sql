-- 0073 Small copies of shop banners (30 Oct 2026). Shop cards on the home page show a 640 px copy instead of the full banner.
-- New banners get the copy when the shop saves them (Seller Center → Shop settings). For banners saved earlier, an admin
-- presses Admin → Products → "⚡ Make small photos" once: it makes the copy and points the shop at it.
-- A banner whose file name ends in "-s.webp" / "-s.jpg" has a small copy next to it ("…-s-t.webp").
-- Safe to run more than once.

drop policy if exists "Admins add shop picture copies" on storage.objects;
create policy "Admins add shop picture copies" on storage.objects for insert to authenticated
  with check (bucket_id = 'shop-assets' and public.has_staff_role(array['master_admin', 'co_admin']));

create or replace function public.admin_set_banner(p_seller uuid, p_path text)
returns void language plpgsql security definer set search_path = ''
as $$
begin
  if not public.has_staff_role(array['master_admin', 'co_admin']) then raise exception 'Only Master admin or Co-admins can do this'; end if;
  if p_path !~ ('^' || p_seller::text || '/banner-[0-9]+-s\.(webp|jpg)$') then raise exception 'Not a banner copy path'; end if;
  update public.seller_details set banner_path = p_path where user_id = p_seller;
end; $$;
revoke execute on function public.admin_set_banner(uuid, text) from public, anon;
grant  execute on function public.admin_set_banner(uuid, text) to authenticated;

select count(*) filter (where banner_path is not null) as shops_with_banner,
       count(*) filter (where banner_path ~ '-s\.(webp|jpg)$') as with_small_copy
  from public.seller_details;
