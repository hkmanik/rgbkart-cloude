-- Shop settings (plan 1.8): logo, banner, shop web address, contact, social links, vacation mode, payout details.
-- Run once in Supabase → SQL Editor, AFTER products_v2.sql. Safe to run again.

-- 1. New shop fields --------------------------------------------------------

alter table public.seller_details
  add column if not exists shop_slug         text,
  add column if not exists tagline           text,
  add column if not exists logo_path         text,
  add column if not exists banner_path       text,
  add column if not exists phone_public      text,
  add column if not exists whatsapp          text,
  add column if not exists email_public      text,
  add column if not exists facebook_url      text,
  add column if not exists instagram_url     text,
  add column if not exists youtube_url       text,
  add column if not exists tiktok_url        text,
  add column if not exists website_url       text,
  add column if not exists vacation_mode     boolean not null default false,
  add column if not exists vacation_message  text,
  add column if not exists updated_at        timestamptz not null default now();

create unique index if not exists seller_details_slug_key on public.seller_details (shop_slug);

alter table public.seller_details drop constraint if exists seller_details_settings_rules;
alter table public.seller_details add constraint seller_details_settings_rules check (
      (shop_slug is null or shop_slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$' and char_length(shop_slug) between 3 and 60)
  and (tagline is null or char_length(tagline) <= 120)
  and (vacation_message is null or char_length(vacation_message) <= 300)
  and (phone_public is null or phone_public ~ '^\+?[0-9 -]{6,20}$')
  and (whatsapp is null or whatsapp ~ '^\+?[0-9 -]{6,20}$')
  and (email_public is null or email_public ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$')
  and (facebook_url is null or facebook_url ~* '^https?://')
  and (instagram_url is null or instagram_url ~* '^https?://')
  and (youtube_url is null or youtube_url ~* '^https?://')
  and (tiktok_url is null or tiktok_url ~* '^https?://')
  and (website_url is null or website_url ~* '^https?://')
);

-- Give every shop a web address from its name (rgbkart.com/shop/<address>) if it has none.
create or replace function public.seller_details_before_write()
returns trigger language plpgsql set search_path = ''
as $$
declare base text; candidate text; n int := 1;
begin
  new.updated_at := now();
  if new.shop_slug is null or new.shop_slug = '' then
    base := left(trim(both '-' from regexp_replace(lower(new.shop_name), '[^a-z0-9]+', '-', 'g')), 50);
    if char_length(base) < 3 then base := 'shop'; end if;
    candidate := base;
    while exists (select 1 from public.seller_details where shop_slug = candidate and user_id <> new.user_id) loop
      n := n + 1; candidate := base || '-' || n;
    end loop;
    new.shop_slug := candidate;
  end if;
  return new;
end; $$;

drop trigger if exists seller_details_before_write on public.seller_details;
create trigger seller_details_before_write before insert or update on public.seller_details
  for each row execute function public.seller_details_before_write();

update public.seller_details set shop_slug = null where shop_slug is null;   -- fills addresses for existing shops

grant update (shop_name, shop_description, business_address, city, trade_license,
              shop_slug, tagline, logo_path, banner_path, phone_public, whatsapp, email_public,
              facebook_url, instagram_url, youtube_url, tiktok_url, website_url, vacation_mode, vacation_message)
  on public.seller_details to authenticated;

-- 2. Payout details (private: only the seller and Master Admin / Co-admin) -----

create table if not exists public.seller_payout_details (
  user_id         uuid primary key references public.profiles (id) on delete cascade,
  method          text not null check (method in ('bkash', 'nagad', 'rocket', 'bank')),
  account_name    text not null check (char_length(trim(account_name)) between 2 and 100),
  account_number  text not null check (account_number ~ '^[0-9 -]{6,30}$'),
  account_type    text check (account_type in ('personal', 'agent', 'merchant', 'savings', 'current')),
  bank_name       text,
  branch_name     text,
  routing_number  text check (routing_number is null or routing_number ~ '^[0-9]{9}$'),
  updated_at      timestamptz not null default now(),
  check (method <> 'bank' or (bank_name is not null and branch_name is not null))
);
alter table public.seller_payout_details enable row level security;
revoke all on public.seller_payout_details from anon, authenticated;
grant select, insert, update, delete on public.seller_payout_details to authenticated;

drop policy if exists "Seller manages own payout details" on public.seller_payout_details;
create policy "Seller manages own payout details" on public.seller_payout_details for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid() and exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'seller'));
drop policy if exists "Admins read payout details" on public.seller_payout_details;
create policy "Admins read payout details" on public.seller_payout_details for select to authenticated
  using (public.has_staff_role(array['master_admin', 'co_admin']));

-- 3. Public shop info (what shoppers see; no licence or payout details) -------

create or replace view public.shops as
  select s.user_id, s.shop_name, s.shop_slug, s.tagline, s.shop_description, s.logo_path, s.banner_path, s.city,
         s.phone_public, s.whatsapp, s.email_public, s.facebook_url, s.instagram_url, s.youtube_url, s.tiktok_url, s.website_url,
         s.vacation_mode, s.vacation_message, s.created_at
  from public.seller_details s
  where s.status = 'approved';
grant select on public.shops to anon, authenticated;

-- 4. Logo and banner storage ---------------------------------------------------
-- Public bucket. Any seller can upload into their own folder (<their user id>/...). Max 3 MB; JPG, PNG or WebP.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('shop-assets', 'shop-assets', true, 3145728, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set public = true, file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

create or replace function public.is_seller()
returns boolean language sql stable security definer set search_path = ''
as $$ select exists (select 1 from public.profiles where id = auth.uid() and role = 'seller') $$;
grant execute on function public.is_seller() to authenticated;

drop policy if exists "Shop images are public" on storage.objects;
create policy "Shop images are public" on storage.objects for select to anon, authenticated
  using (bucket_id = 'shop-assets');
drop policy if exists "Sellers upload shop images" on storage.objects;
create policy "Sellers upload shop images" on storage.objects for insert to authenticated
  with check (bucket_id = 'shop-assets' and (storage.foldername(name))[1] = auth.uid()::text and public.is_seller());
drop policy if exists "Sellers change shop images" on storage.objects;
create policy "Sellers change shop images" on storage.objects for update to authenticated
  using (bucket_id = 'shop-assets' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "Sellers delete shop images" on storage.objects;
create policy "Sellers delete shop images" on storage.objects for delete to authenticated
  using (bucket_id = 'shop-assets' and ((storage.foldername(name))[1] = auth.uid()::text or public.has_staff_role(array['master_admin', 'co_admin'])));

-- 5. Check --------------------------------------------------------------------
select (select count(*) from public.seller_details where shop_slug is not null) as shops_with_web_address,
       (select public from storage.buckets where id = 'shop-assets') as shop_image_bucket_public;
