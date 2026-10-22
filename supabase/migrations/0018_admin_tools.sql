-- Admin tools (plan 5.4–5.8, 4.x): admin adds products, free Featured, Featured rate list,
-- advertisement rates and ads, visitor counting and reports.
-- Run once in Supabase → SQL Editor, AFTER 0017_menu_groups.sql. Safe to run again.

-- 1. RGBKart Official shop ---------------------------------------------------------------------
-- The Master Admin's own account holds the "RGBKart Official" shop, so admin can sell RGBKart's own products.

alter table public.seller_details add column if not exists is_official boolean not null default false;

create or replace function public.admin_setup_official_shop(p_name text, p_phone text, p_whatsapp text, p_city text, p_area text default null)
returns uuid language plpgsql security definer set search_path = ''
as $$
declare uid uuid := auth.uid(); ph text; wa text;
begin
  if not public.has_staff_role(array['master_admin']) then raise exception 'Only the Master Admin can set up the RGBKart Official shop'; end if;
  ph := nullif(regexp_replace(coalesce(p_phone, ''), '[^0-9+]', '', 'g'), '');
  wa := nullif(regexp_replace(coalesce(p_whatsapp, ''), '[^0-9+]', '', 'g'), '');
  if char_length(trim(coalesce(p_name, ''))) < 2 then raise exception 'Enter the shop name'; end if;
  if ph is null or ph !~ '^(\+?880)?01[3-9][0-9]{8}$' then raise exception 'Enter a valid mobile number, like 01711000000'; end if;
  if wa is not null and wa !~ '^(\+?880)?01[3-9][0-9]{8}$' then raise exception 'Enter a valid WhatsApp number, like 01711000000'; end if;
  if coalesce(trim(p_city), '') = '' then raise exception 'Choose the district'; end if;
  if exists (select 1 from public.seller_details where is_official and user_id <> uid) then
    raise exception 'The RGBKart Official shop already belongs to another admin account';
  end if;
  insert into public.profiles (id) values (uid) on conflict (id) do nothing;
  insert into public.seller_details (user_id, shop_name, city, area, phone_public, whatsapp, status, is_official)
  values (uid, trim(p_name), trim(p_city), nullif(trim(coalesce(p_area, '')), ''), ph, wa, 'approved', true)
  on conflict (user_id) do update
    set shop_name = excluded.shop_name, city = excluded.city, area = excluded.area,
        phone_public = excluded.phone_public, whatsapp = excluded.whatsapp, status = 'approved', is_official = true;
  return uid;
end; $$;
revoke execute on function public.admin_setup_official_shop(text, text, text, text, text) from public, anon;
grant  execute on function public.admin_setup_official_shop(text, text, text, text, text) to authenticated;

-- 2. Admin adds a product (for any approved seller, or the Official shop). Goes live straight away. --------

-- Staff may upload photos into the "admin/" folder of the product-images bucket.
drop policy if exists "Staff upload admin photos" on storage.objects;
create policy "Staff upload admin photos" on storage.objects for insert to authenticated
  with check (bucket_id = 'product-images' and (storage.foldername(name))[1] = 'admin'
              and public.has_staff_role(array['master_admin', 'co_admin', 'editor']));

create or replace function public.admin_create_product(p jsonb, p_images text[])
returns bigint language plpgsql security definer set search_path = ''
as $$
declare sid uuid; pid bigint; img text; n int := 0; price numeric; sale numeric; cond text;
begin
  if not public.has_staff_role(array['master_admin', 'co_admin', 'editor']) then raise exception 'You don''t have permission to add products'; end if;
  sid := nullif(p->>'seller_id', '')::uuid;
  if sid is null or not exists (select 1 from public.seller_details where user_id = sid and status = 'approved') then
    raise exception 'Choose an approved seller';
  end if;
  if char_length(trim(coalesce(p->>'title', ''))) < 3 then raise exception 'Write the product name'; end if;
  if not exists (select 1 from public.categories where id = (p->>'category_id')::bigint) then raise exception 'Choose a category'; end if;
  price := nullif(p->>'price', '')::numeric; sale := nullif(p->>'sale_price', '')::numeric;
  if price is null or price <= 0 then raise exception 'Enter a price'; end if;
  if sale is not null and (sale <= 0 or sale >= price) then raise exception 'The sale price must be lower than the price'; end if;
  cond := coalesce(nullif(p->>'listing_type', ''), 'new');
  if cond not in ('new', 'pre_owned') then raise exception 'Choose New or Pre-owned'; end if;
  if coalesce(array_length(p_images, 1), 0) = 0 then raise exception 'Add at least one photo'; end if;

  insert into public.products (seller_id, category_id, title, description, price, sale_price, stock, manage_stock, listing_type, product_type,
                               price_negotiable, free_delivery, status, reviewed_by, reviewed_at, published_at)
  values (sid, (p->>'category_id')::bigint, trim(p->>'title'), nullif(trim(coalesce(p->>'description', '')), ''), price, sale,
          greatest(coalesce(nullif(p->>'stock', '')::int, 1), 0), true, cond, 'simple',
          coalesce((p->>'price_negotiable')::boolean, false), coalesce((p->>'free_delivery')::boolean, false),
          'approved', auth.uid(), now(), now())
  returning id into pid;

  foreach img in array p_images loop
    if img !~ '^admin/[A-Za-z0-9/_.-]+$' then raise exception 'Photo upload problem. Please try again.'; end if;
    insert into public.product_images (product_id, storage_path, sort_order) values (pid, img, n * 10);
    n := n + 1;
    exit when n >= 8;
  end loop;
  return pid;
end; $$;
revoke execute on function public.admin_create_product(jsonb, text[]) from public, anon;
grant  execute on function public.admin_create_product(jsonb, text[]) to authenticated;

-- 3. Free (complimentary) Featured, given by admin without payment ------------------------------

alter table public.featured_requests
  add column if not exists is_complimentary boolean not null default false,
  add column if not exists granted_by uuid references auth.users (id) on delete set null,
  add column if not exists note text;

-- Requests from sellers still take price/days from a plan; admin grants skip that.
create or replace function public.featured_requests_from_plan()
returns trigger language plpgsql security definer set search_path = ''
as $$
declare pl record;
begin
  if current_setting('rgbkart.staff_grant', true) = 'on' then return new; end if;
  if new.plan_id is null then raise exception 'Choose a Featured plan'; end if;
  select * into pl from public.featured_plans where id = new.plan_id and is_active;
  if pl.id is null then raise exception 'That Featured plan is no longer available'; end if;
  new.price := pl.price; new.days := pl.days; new.placement := pl.placement;
  new.status := 'awaiting_payment'; new.starts_at := null; new.ends_at := null;
  new.is_complimentary := false; new.granted_by := null;
  return new;
end; $$;

create or replace function public.admin_feature_free(p_product bigint, p_days integer, p_note text default null)
returns timestamptz language plpgsql security definer set search_path = ''
as $$
declare pr record; r record; until timestamptz;
begin
  if not public.has_staff_role(array['master_admin', 'co_admin']) then raise exception 'Only the Master Admin or a Co-admin can do this'; end if;
  if p_days is null or p_days < 1 or p_days > 365 then raise exception 'Choose between 1 and 365 days'; end if;
  select id, seller_id, status into pr from public.products where id = p_product;
  if pr.id is null then raise exception 'Product not found'; end if;
  if pr.status <> 'approved' then raise exception 'Approve the product first, then make it Featured'; end if;

  select * into r from public.featured_requests
   where product_id = pr.id and status in ('awaiting_payment', 'payment_submitted', 'active') for update;
  if r.id is not null and r.status = 'active' and r.ends_at > now() then
    -- already featured: add the days on top
    update public.featured_requests set ends_at = ends_at + make_interval(days => p_days), days = days + p_days,
           note = concat_ws(' · ', note, nullif(trim(coalesce(p_note, '')), ''), format('+%s days free from admin', p_days))
     where id = r.id returning ends_at into until;
  elsif r.id is not null then
    -- waiting for payment: start it now for free
    update public.featured_requests
       set status = 'active', starts_at = now(), ends_at = now() + make_interval(days => p_days), days = p_days, price = 0,
           is_complimentary = true, granted_by = auth.uid(), note = nullif(trim(coalesce(p_note, '')), '')
     where id = r.id returning ends_at into until;
  else
    perform set_config('rgbkart.staff_grant', 'on', true);
    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, granted_by, note)
    values (pr.id, pr.seller_id, 'home_and_category', p_days, 0, 'active', now(), now() + make_interval(days => p_days), true, auth.uid(),
            nullif(trim(coalesce(p_note, '')), ''))
    returning ends_at into until;
    perform set_config('rgbkart.staff_grant', 'off', true);
  end if;
  update public.products set is_featured = true where id = pr.id;
  return until;
end; $$;
revoke execute on function public.admin_feature_free(bigint, integer, text) from public, anon;
grant  execute on function public.admin_feature_free(bigint, integer, text) to authenticated;

-- 4. Featured rate list: several durations (admin can change prices and add more) -----------------

update public.featured_plans set name = 'Featured 30 days' where name = 'Featured' and days = 30
  and not exists (select 1 from public.featured_plans where name = 'Featured 30 days');
insert into public.featured_plans (name, price, days, placement, benefits, sort_order)
select v.name, v.price, v.days, 'home_and_category',
       array['Shown in the Featured section of the RGBKart home page', 'Pinned to the top of its category and search results',
             '"Featured" badge on the product', format('Stays featured for %s days', v.days)], v.days
from (values ('Featured 7 days', 20, 7), ('Featured 15 days', 35, 15)) as v(name, price, days)
where not exists (select 1 from public.featured_plans p where p.days = v.days);
update public.featured_plans set sort_order = days where sort_order = 0 or sort_order is null;

-- 5. Advertisement rates and ads --------------------------------------------------------------------

create table if not exists public.ad_rates (
  placement      text primary key check (placement in ('home_top', 'home_mid', 'cat_side')),
  name           text not null,
  description    text,
  price_per_day  numeric(10, 2) not null check (price_per_day >= 0),
  min_days       integer not null default 1 check (min_days between 1 and 365),
  is_active      boolean not null default true,
  sort_order     integer not null default 0,
  updated_at     timestamptz not null default now()
);
insert into public.ad_rates (placement, name, description, price_per_day, min_days, sort_order) values
  ('home_top', 'Home page banner strip', 'Wide banner near the top of the home page', 150, 1, 10),
  ('home_mid', 'Home page mid-page banner', 'Banner between the product sections of the home page', 100, 1, 20),
  ('cat_side', 'Category page sidebar', 'Box in the left sidebar of category and search pages', 60, 1, 30)
on conflict (placement) do nothing;

alter table public.ad_rates enable row level security;
revoke all on public.ad_rates from anon, authenticated;
grant select on public.ad_rates to anon, authenticated;
grant update (name, description, price_per_day, min_days, is_active, updated_at) on public.ad_rates to authenticated;
drop policy if exists "Anyone reads ad rates" on public.ad_rates;
create policy "Anyone reads ad rates" on public.ad_rates for select to anon, authenticated using (true);
drop policy if exists "Admins change ad rates" on public.ad_rates;
create policy "Admins change ad rates" on public.ad_rates for update to authenticated
  using (public.has_staff_role(array['master_admin', 'co_admin'])) with check (public.has_staff_role(array['master_admin', 'co_admin']));

create table if not exists public.ads (
  id              bigint generated by default as identity primary key,
  placement       text not null references public.ad_rates (placement),
  seller_id       uuid references public.profiles (id) on delete set null,     -- empty = RGBKart's own (house) ad
  title           text not null check (char_length(trim(title)) between 2 and 80),
  subtitle        text check (subtitle is null or char_length(subtitle) <= 140),
  cta             text not null default 'Shop now' check (char_length(cta) between 1 and 24),
  link_url        text not null default 'browse.html' check (link_url ~ '^(https://[^\s]+|[a-z0-9_-]+\.html([?#][^\s]*)?)$'),
  image_path      text check (image_path is null or image_path ~ '^admin/[A-Za-z0-9/_.-]+$'),
  color           text not null default 'green' check (color in ('green', 'red', 'yellow', 'dark')),
  starts_on       date not null default current_date,
  ends_on         date not null,
  price_per_day   numeric(10, 2) not null default 0 check (price_per_day >= 0),
  amount          numeric(12, 2) not null default 0 check (amount >= 0),     -- what the advertiser pays in total
  payment_status  text not null default 'unpaid' check (payment_status in ('unpaid', 'paid', 'complimentary')),
  paid_at         timestamptz,
  is_active       boolean not null default true,
  created_by      uuid references auth.users (id) on delete set null,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  check (ends_on >= starts_on)
);
create index if not exists ads_live on public.ads (placement, starts_on, ends_on) where is_active;

alter table public.ads enable row level security;
revoke all on public.ads from anon, authenticated;
grant select, insert, update, delete on public.ads to authenticated;
drop policy if exists "Staff manage ads" on public.ads;
create policy "Staff manage ads" on public.ads for all to authenticated
  using (public.has_staff_role(array['master_admin', 'co_admin', 'editor']))
  with check (public.has_staff_role(array['master_admin', 'co_admin', 'editor']));

-- Record when an ad was paid
create or replace function public.ads_before_write()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  new.updated_at := now();
  if tg_op = 'INSERT' then new.created_by := coalesce(new.created_by, auth.uid()); end if;
  if new.payment_status = 'paid' and (tg_op = 'INSERT' or old.payment_status <> 'paid') then new.paid_at := now(); end if;
  if new.payment_status <> 'paid' then new.paid_at := null; end if;
  return new;
end; $$;
drop trigger if exists ads_before_write on public.ads;
create trigger ads_before_write before insert or update on public.ads for each row execute function public.ads_before_write();

-- What shoppers see: only running ads, and never the price
create or replace view public.live_ads as
  select a.id, a.placement, a.title, a.subtitle, a.cta, a.link_url, a.image_path, a.color, a.ends_on
  from public.ads a join public.ad_rates r on r.placement = a.placement
  where a.is_active and r.is_active
    and (now() at time zone 'Asia/Dhaka')::date between a.starts_on and a.ends_on;
grant select on public.live_ads to anon, authenticated;

-- 6. Visitor counting (no names, no IP addresses: a random id kept on the visitor's device) ----------

create table if not exists public.page_visits (
  day         date not null default ((now() at time zone 'Asia/Dhaka')::date),
  visitor     text not null,
  path        text not null,
  created_at  timestamptz not null default now(),
  primary key (day, visitor, path)
);
alter table public.page_visits enable row level security;
revoke all on public.page_visits from anon, authenticated;

create or replace function public.track_visit(p_visitor text, p_path text)
returns void language plpgsql security definer set search_path = ''
as $$
declare pth text := left(regexp_replace(coalesce(p_path, ''), '[^A-Za-z0-9_./-]', '', 'g'), 80);
begin
  if p_visitor !~ '^[a-z0-9]{12,40}$' or pth = '' then return; end if;
  insert into public.page_visits (visitor, path) values (p_visitor, pth) on conflict do nothing;
end; $$;
revoke execute on function public.track_visit(text, text) from public;
grant  execute on function public.track_visit(text, text) to anon, authenticated;

-- 7. Reports for a period (Dhaka dates, both days included) ---------------------------------------------

create or replace function public.admin_report(p_from date, p_to date)
returns jsonb language plpgsql stable security definer set search_path = ''
as $$
declare f timestamptz; t timestamptz; res jsonb; series jsonb;
begin
  if not public.has_staff_role(array['master_admin', 'co_admin']) then raise exception 'Only the Master Admin or a Co-admin can see reports'; end if;
  if p_from is null or p_to is null or p_to < p_from then raise exception 'Choose a start and end date'; end if;
  if p_to - p_from > 3660 then raise exception 'Choose a period of 10 years or less'; end if;
  f := p_from::timestamp at time zone 'Asia/Dhaka';
  t := (p_to + 1)::timestamp at time zone 'Asia/Dhaka';

  select jsonb_build_object(
    'visitors',          (select count(distinct visitor) from public.page_visits where day between p_from and p_to),
    'page_views',        (select count(*) from public.page_visits where day between p_from and p_to),
    'new_customers',     (select count(*) from public.profiles where role = 'customer' and created_at >= f and created_at < t),
    'new_shops',         (select count(*) from public.seller_details s join public.profiles p on p.id = s.user_id where p.role = 'seller' and s.created_at >= f and s.created_at < t),
    'new_one_time',      (select count(*) from public.seller_details s join public.profiles p on p.id = s.user_id where p.role = 'individual' and s.created_at >= f and s.created_at < t),
    'new_listings',      (select count(*) from public.products where created_at >= f and created_at < t and status <> 'draft'),
    'approved_listings', (select count(*) from public.products where published_at >= f and published_at < t),
    'featured_paid',     (select count(*) from public.featured_requests where starts_at >= f and starts_at < t and not is_complimentary and status in ('active', 'expired')),
    'featured_free',     (select count(*) from public.featured_requests where starts_at >= f and starts_at < t and is_complimentary),
    'featured_income',   (select coalesce(sum(price), 0) from public.featured_requests where starts_at >= f and starts_at < t and not is_complimentary and status in ('active', 'expired')),
    'featured_waiting',  (select count(*) from public.featured_requests where status in ('awaiting_payment', 'payment_submitted')),
    'ads_started',       (select count(*) from public.ads where starts_on between p_from and p_to),
    'ad_income',         (select coalesce(sum(amount), 0) from public.ads where payment_status = 'paid' and paid_at >= f and paid_at < t),
    'ads_unpaid',        (select coalesce(sum(amount), 0) from public.ads where payment_status = 'unpaid' and is_active),
    'messages',          (select count(*) from public.messages where created_at >= f and created_at < t),
    'total_customers',   (select count(*) from public.profiles where role = 'customer'),
    'total_shops',       (select count(*) from public.seller_details s join public.profiles p on p.id = s.user_id where p.role = 'seller' and s.status = 'approved'),
    'total_one_time',    (select count(*) from public.profiles where role = 'individual'),
    'live_products',     (select count(*) from public.products where status = 'approved'),
    'featured_now',      (select count(*) from public.featured_requests where status = 'active' and ends_at > now())
  ) into res;

  -- one row per day (or per month when the period is longer than ~4 months)
  with b as (
    select g::date as d, case when p_to - p_from > 124 then (g + interval '1 month')::date - 1 else g::date end as e
    from generate_series(p_from::timestamp, p_to::timestamp, case when p_to - p_from > 124 then interval '1 month' else interval '1 day' end) g
  )
  select jsonb_agg(jsonb_build_object(
      'from', b.d, 'to', least(b.e, p_to),
      'visitors', (select count(distinct visitor) from public.page_visits v where v.day between b.d and least(b.e, p_to)),
      'signups',  (select count(*) from public.profiles p where p.role in ('customer', 'seller', 'individual')
                     and p.created_at >= (b.d::timestamp at time zone 'Asia/Dhaka') and p.created_at < ((least(b.e, p_to) + 1)::timestamp at time zone 'Asia/Dhaka')),
      'listings', (select count(*) from public.products x where x.status <> 'draft'
                     and x.created_at >= (b.d::timestamp at time zone 'Asia/Dhaka') and x.created_at < ((least(b.e, p_to) + 1)::timestamp at time zone 'Asia/Dhaka')),
      'income',   (select coalesce(sum(r.price), 0) from public.featured_requests r where not r.is_complimentary and r.status in ('active', 'expired')
                     and r.starts_at >= (b.d::timestamp at time zone 'Asia/Dhaka') and r.starts_at < ((least(b.e, p_to) + 1)::timestamp at time zone 'Asia/Dhaka'))
                + (select coalesce(sum(a.amount), 0) from public.ads a where a.payment_status = 'paid'
                     and a.paid_at >= (b.d::timestamp at time zone 'Asia/Dhaka') and a.paid_at < ((least(b.e, p_to) + 1)::timestamp at time zone 'Asia/Dhaka'))
    ) order by b.d) into series
  from b;

  return res || jsonb_build_object('series', coalesce(series, '[]'::jsonb), 'by_month', p_to - p_from > 124);
end; $$;
revoke execute on function public.admin_report(date, date) from public, anon;
grant  execute on function public.admin_report(date, date) to authenticated;

-- 8. Check ------------------------------------------------------------------------------------------
select (select count(*) from public.featured_plans where is_active) as featured_rates,
       (select count(*) from public.ad_rates) as ad_placements,
       to_regclass('public.page_visits') is not null as visitor_counting_ready,
       to_regprocedure('public.admin_report(date,date)') is not null as reports_ready;
