-- Quick selling (plan 1.5 / 1.7): one-time sellers without registration, simpler product form.
-- Run once in Supabase → SQL Editor, AFTER product_options.sql. Safe to run again.
--
-- ALSO REQUIRED (one click): Supabase → Authentication → Sign In / Providers → turn ON "Allow anonymous sign-ins".
-- One-time sellers get an invisible "anonymous" login in their browser, so they never register,
-- but the database can still tell which listings are theirs.
--
-- What changes:
--   • New account type 'individual' (a one-time seller). Up to 5 active listings each.
--   • Their listings are contact-only: buyers call / WhatsApp them. Every listing is reviewed by admin first.
--   • Product details (attribute dropdowns) are no longer required to send a product for review.
--   • "Price is negotiable" option.

-- 1. Account type ------------------------------------------------------------------

alter table public.profiles drop constraint if exists profiles_role_check;
alter table public.profiles add constraint profiles_role_check check (role in ('customer', 'seller', 'individual'));

-- Approved shops AND one-time sellers may add products (each product is still reviewed).
create or replace function public.is_approved_seller()
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    join public.seller_details s on s.user_id = p.id
    where p.id = auth.uid() and p.role in ('seller', 'individual') and s.status = 'approved')
$$;

-- 2. Product columns ----------------------------------------------------------------

alter table public.products
  add column if not exists contact_only      boolean not null default false,   -- buyers contact the seller directly
  add column if not exists price_negotiable  boolean not null default false;

grant insert (price_negotiable) on public.products to authenticated;
grant update (price_negotiable) on public.products to authenticated;

-- 3. Start selling without registering ---------------------------------------------

create or replace function public.start_individual_selling(p_name text, p_phone text, p_whatsapp text, p_district text, p_area text)
returns void language plpgsql security definer set search_path = ''
as $$
declare uid uuid := auth.uid(); r text; ph text; wa text;
begin
  if uid is null then raise exception 'Please reload the page and try again'; end if;
  select role into r from public.profiles where id = uid;
  if r in ('customer', 'seller') then
    raise exception 'You are signed in to a % account. Sign out first to sell as a one-time seller, or use Seller Center.', r;
  end if;
  ph := regexp_replace(coalesce(p_phone, ''), '[^0-9+]', '', 'g');
  wa := nullif(regexp_replace(coalesce(p_whatsapp, ''), '[^0-9+]', '', 'g'), '');
  if char_length(trim(coalesce(p_name, ''))) < 2 then raise exception 'Enter your name'; end if;
  if ph !~ '^(\+?880)?01[3-9][0-9]{8}$' then raise exception 'Enter a valid Bangladeshi mobile number, like 01711000000'; end if;
  if wa is not null and wa !~ '^(\+?880)?01[3-9][0-9]{8}$' then raise exception 'Enter a valid WhatsApp number, like 01711000000'; end if;
  if coalesce(trim(p_district), '') = '' then raise exception 'Choose your district'; end if;


  insert into public.profiles (id) values (uid) on conflict (id) do nothing;
  update public.profiles set role = 'individual', full_name = trim(p_name), phone = ph where id = uid;

  insert into public.seller_details (user_id, shop_name, business_address, city, phone_public, whatsapp, status)
  values (uid, trim(p_name), nullif(trim(coalesce(p_area, '')), ''), trim(p_district), ph, wa, 'approved')
  on conflict (user_id) do update
    set shop_name = excluded.shop_name, business_address = excluded.business_address, city = excluded.city,
        phone_public = excluded.phone_public, whatsapp = excluded.whatsapp;
end; $$;

revoke execute on function public.start_individual_selling(text, text, text, text, text) from public, anon;
grant  execute on function public.start_individual_selling(text, text, text, text, text) to authenticated;

-- 4. Rules for one-time sellers' products -------------------------------------------

create or replace function public.products_individual_rules()
returns trigger language plpgsql security definer set search_path = ''
as $$
declare n int;
begin
  if exists (select 1 from public.profiles where id = new.seller_id and role = 'individual') then
    new.contact_only := true;
    new.product_type := 'simple';
    new.is_downloadable := false;
    new.is_gift_card := false;
    new.is_featured := false;
    if tg_op = 'INSERT' then
      select count(*) into n from public.products
       where seller_id = new.seller_id and status not in ('rejected', 'archived');
      if n >= 5 then
        raise exception 'One-time sellers can have up to 5 listings at a time. Mark one as sold, or open a shop for more.';
      end if;
    end if;
  end if;
  return new;
end; $$;

drop trigger if exists products_individual_rules on public.products;
create trigger products_individual_rules before insert or update on public.products
  for each row execute function public.products_individual_rules();

-- 5. Send for review: product details are now optional -----------------------------

create or replace function public.submit_product(p_product bigint)
returns text language plpgsql security definer set search_path = ''
as $$
declare p record;
begin
  select * into p from public.products where id = p_product and seller_id = auth.uid();
  if p.id is null then raise exception 'Product not found'; end if;
  if not public.is_approved_seller() then raise exception 'Your shop must be approved before you can list products'; end if;
  if p.status not in ('draft', 'rejected', 'archived') then raise exception 'This product is already %', p.status; end if;
  if not exists (select 1 from public.product_images where product_id = p.id) then
    raise exception 'Add a main image';
  end if;
  if p.is_downloadable and not exists (select 1 from public.product_downloads where product_id = p.id) then
    raise exception 'Upload the file buyers will download';
  end if;
  if p.is_service and p.service_mode is null then raise exception 'Choose where the service happens'; end if;
  if p.is_preorder and p.preorder_date < current_date then raise exception 'The pre-order date has passed. Choose a new date'; end if;
  if p.product_type = 'variable' then
    if not exists (select 1 from public.product_variations where product_id = p.id and is_active) then
      raise exception 'Add at least one variation, or switch to a simple product';
    end if;
    if exists (select 1 from public.product_variations where product_id = p.id and is_active and price <= 0) then
      raise exception 'Every active variation needs a price';
    end if;
  end if;
  if exists (select 1 from public.product_price_tiers t where t.product_id = p.id and t.unit_price >= p.price) then
    raise exception 'Wholesale prices must be lower than the regular price';
  end if;

  update public.products set status = 'pending', review_note = null where id = p.id;
  return 'pending';
end; $$;

-- 6. Check ----------------------------------------------------------------------------
select exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'products' and column_name = 'contact_only') as contact_listings_ready,
       to_regprocedure('public.start_individual_selling(text,text,text,text,text)') is not null as one_time_selling_ready;
