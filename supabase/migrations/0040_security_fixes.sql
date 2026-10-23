-- Security review fixes (plan 7.4). Run once in Supabase → SQL Editor, AFTER 0039_site_pages.sql. Safe to run again.
--
-- 1. IMPORTANT: the public lists of reviews and questions (public_reviews, public_questions) could be CHANGED or DELETED by
--    anyone, because Supabase gives every new table/view full rights to visitors by default and those two views can be
--    written through. Visitors can now only read them. Same for the shops and live_ads lists.
-- 2. "Featured products: sellers cannot change the title, product code (SKU/barcode) or quantity" is now enforced by the
--    database (it was not checked before). Staff can still change them; orders still reduce stock as normal.
-- 3. Return photos: only customers who have a delivered order can upload them (stops strangers filling the storage).
-- 4. Tidy-up: visitors lose the unused TRUNCATE right on all tables; new tables/views no longer get full rights by default
--    (every migration grants exactly what is needed); options of product variations can only be added by approved sellers.

-- 1. Read-only public views --------------------------------------------------------------------------------------------
do $$
declare v text;
begin
  foreach v in array array['public_reviews', 'public_questions', 'shops', 'live_ads'] loop
    if to_regclass('public.' || v) is not null then
      execute format('revoke all on public.%I from anon, authenticated', v);
      execute format('grant select on public.%I to anon, authenticated', v);
    end if;
  end loop;
end $$;

-- 4a. No TRUNCATE for visitors on any table
do $$
declare t record;
begin
  for t in select c.relname from pg_class c join pg_namespace n on n.oid = c.relnamespace
           where n.nspname = 'public' and c.relkind in ('r', 'v', 'm', 'p') loop
    execute format('revoke truncate on public.%I from anon, authenticated', t.relname);
  end loop;
end $$;

-- 4b. New tables and views start with no rights for visitors (each migration grants what it needs)
alter default privileges in schema public revoke all on tables from anon, authenticated;
alter default privileges for role postgres in schema public revoke all on tables from anon, authenticated;

-- 2. Featured lock ----------------------------------------------------------------------------------------------------------
-- Runs with the rights of whoever made the change (not "security definer"), so it can tell a seller editing directly
-- (role authenticated) from the database's own functions such as place_order (role postgres).
create or replace function public.featured_lock()
returns trigger language plpgsql set search_path = ''
as $$
declare locked boolean;
begin
  if public.has_staff_role(array['master_admin', 'co_admin', 'editor']) or current_user in ('postgres', 'supabase_admin') then return new; end if;
  if tg_table_name = 'products' then
    locked := coalesce(old.is_featured, false) or public.featured_now(old.id);
    if locked and (new.title is distinct from old.title or new.title_bn is distinct from old.title_bn
                   or new.sku is distinct from old.sku or new.stock is distinct from old.stock) then
      raise exception 'This product is Featured: its title, product code and quantity cannot be changed until Featured ends';
    end if;
  else  -- product_variations
    locked := exists (select 1 from public.products p where p.id = old.product_id and (coalesce(p.is_featured, false) or public.featured_now(p.id)));
    if locked and (new.stock is distinct from old.stock or new.sku is distinct from old.sku) then
      raise exception 'This product is Featured: option codes and quantities cannot be changed until Featured ends';
    end if;
  end if;
  return new;
end; $$;
drop trigger if exists featured_lock on public.products;
create trigger featured_lock before update on public.products for each row execute function public.featured_lock();
do $$ begin
  if exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'product_variations' and column_name = 'sku') then
    drop trigger if exists featured_lock on public.product_variations;
    create trigger featured_lock before update on public.product_variations for each row execute function public.featured_lock();
  end if;
end $$;

-- 2b. Same fix for the Verified badge guard from 0038 (it must also see who is really making the change)
create or replace function public.verified_guard()
returns trigger language plpgsql set search_path = ''
as $$
begin
  if public.has_staff_role(array['master_admin', 'co_admin', 'editor']) or current_user in ('postgres', 'supabase_admin') then return new; end if;
  if tg_op = 'INSERT' then new.is_verified := false; new.verified_at := null;
  else new.is_verified := old.is_verified; new.verified_at := old.verified_at; end if;
  return new;
end; $$;

-- 3. Return photos only from customers with a delivered order ----------------------------------------------------------
drop policy if exists "Customers upload return photos" on storage.objects;
create policy "Customers upload return photos" on storage.objects for insert to authenticated
  with check (bucket_id = 'return-photos' and (storage.foldername(name))[1] = auth.uid()::text
              and exists (select 1 from public.orders o where o.customer_id = auth.uid() and o.status = 'delivered'));

-- 4c. Variation options: only approved sellers may add them (same as the other product parts)
drop policy if exists "Seller edits own" on public.product_variation_options;
create policy "Seller edits own" on public.product_variation_options for all to authenticated
  using (exists (select 1 from public.product_variations v join public.products p on p.id = v.product_id
                 where v.id = product_variation_options.variation_id and p.seller_id = auth.uid()))
  with check (exists (select 1 from public.product_variations v join public.products p on p.id = v.product_id
                      where v.id = product_variation_options.variation_id and p.seller_id = auth.uid()) and public.is_approved_seller());

-- Check: should show 0 rows in "views_visitors_can_write" and the lock in place
select (select count(*) from information_schema.role_table_grants
         where table_schema = 'public' and table_name in ('public_reviews', 'public_questions', 'shops', 'live_ads')
           and grantee in ('anon', 'authenticated') and privilege_type <> 'SELECT') as views_visitors_can_write,
       (select count(*) from pg_trigger where tgname = 'featured_lock') as featured_lock_triggers;
