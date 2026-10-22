-- One-time sellers: Free vs Featured listing + "Message on RGBKart" (plan 1.7, 3.7, 5.4)
-- Run once in Supabase → SQL Editor, AFTER home_sections.sql. Safe to run again.
--
-- What changes:
--   • One-time sellers can choose a Featured listing (price and days come from Admin → Featured & ads).
--   • FREE one-time listings: buyers can only send a message on RGBKart. The seller's phone is NOT shown.
--   • FEATURED one-time listings (after payment is confirmed): buyers can call, WhatsApp, email or message.
--   • Shops are unchanged (buyers can call / WhatsApp the shop), and buyers can message any seller.
--   • Phone numbers of one-time sellers are hidden in the database itself, not just on the page.
--   • Admin → Featured & ads can start (after payment), reject or end a Featured listing.

-- 1. One-time seller email (optional; shown to buyers only on Featured listings) --------------

create or replace function public.set_individual_email(p_email text)
returns void language plpgsql security definer set search_path = ''
as $$
declare e text := nullif(lower(trim(coalesce(p_email, ''))), '');
begin
  if auth.uid() is null then raise exception 'Please reload the page and try again'; end if;
  if e is not null and e !~ '^[^@\s]+@[^@\s]+\.[a-z]{2,}$' then raise exception 'Check the email address'; end if;
  update public.seller_details s set email_public = e
   where s.user_id = auth.uid()
     and exists (select 1 from public.profiles p where p.id = s.user_id and p.role = 'individual');
end; $$;
revoke execute on function public.set_individual_email(text) from public, anon;
grant  execute on function public.set_individual_email(text) to authenticated;

-- 2. Featured is set only by the admin, never by the seller ----------------------------------

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
    if tg_op = 'INSERT' then
      new.is_featured := false;     -- turned on by the admin once payment is confirmed
      select count(*) into n from public.products
       where seller_id = new.seller_id and status not in ('rejected', 'archived');
      if n >= 5 then
        raise exception 'One-time sellers can have up to 5 listings at a time. Mark one as sold, or open a shop for more.';
      end if;
    end if;
  end if;
  return new;
end; $$;

-- 3. Hide one-time sellers' phone, WhatsApp and email from the public shop list -------------

create or replace view public.shops as
  select s.user_id, s.shop_name, s.shop_slug, s.tagline, s.shop_description, s.logo_path, s.banner_path, s.city,
         case when p.role = 'individual' then null else s.phone_public end as phone_public,
         case when p.role = 'individual' then null else s.whatsapp end as whatsapp,
         case when p.role = 'individual' then null else s.email_public end as email_public,
         s.facebook_url, s.instagram_url, s.youtube_url, s.tiktok_url, s.website_url,
         s.vacation_mode, s.vacation_message, s.created_at, s.area
  from public.seller_details s
  join public.profiles p on p.id = s.user_id
  where s.status = 'approved';
grant select on public.shops to anon, authenticated;

-- Is this product featured right now?
create or replace function public.featured_now(p_product bigint)
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.featured_requests f
                 where f.product_id = p_product and f.status = 'active' and f.ends_at > now())
$$;
grant execute on function public.featured_now(bigint) to anon, authenticated;

-- Contact details buyers may see for one listing.
--   shop listing                → phone + WhatsApp (+ email if the shop added one)
--   FEATURED one-time listing   → phone + WhatsApp + email
--   FREE one-time listing       → nothing (message on RGBKart only)
create or replace function public.listing_contact(p_product bigint)
returns table (phone text, whatsapp text, email text, featured boolean)
language plpgsql stable security definer set search_path = ''
as $$
declare pr record; s record; indiv boolean; f boolean;
begin
  select id, seller_id, status into pr from public.products where id = p_product;
  if pr.id is null or (pr.status <> 'approved' and pr.seller_id is distinct from auth.uid()) then return; end if;
  select * into s from public.seller_details where user_id = pr.seller_id and status = 'approved';
  if s.user_id is null then return; end if;
  indiv := exists (select 1 from public.profiles where id = pr.seller_id and role = 'individual');
  f := public.featured_now(pr.id);
  if indiv and not f then
    return query select null::text, null::text, null::text, false;
  else
    return query select s.phone_public, s.whatsapp, s.email_public, f;
  end if;
end; $$;
grant execute on function public.listing_contact(bigint) to anon, authenticated;

-- 4. Admin: start / reject / end a Featured listing ---------------------------------------------

create or replace function public.set_featured_status(p_request bigint, p_status text)
returns text language plpgsql security definer set search_path = ''
as $$
declare r record;
begin
  if not public.has_staff_role(array['master_admin', 'co_admin']) then raise exception 'Only the Master Admin or a Co-admin can do this'; end if;
  select * into r from public.featured_requests where id = p_request for update;
  if r.id is null then raise exception 'Request not found'; end if;
  if p_status = 'active' then
    if r.status not in ('awaiting_payment', 'payment_submitted') then raise exception 'This request is already %', r.status; end if;
    if not exists (select 1 from public.products where id = r.product_id and status = 'approved') then
      raise exception 'Approve the product first (Products page), then start Featured';
    end if;
    update public.featured_requests set status = 'active', starts_at = now(), ends_at = now() + make_interval(days => r.days) where id = r.id;
    update public.products set is_featured = true where id = r.product_id;
  elsif p_status in ('rejected', 'cancelled', 'expired') then
    update public.featured_requests set status = p_status,
           ends_at = case when r.status = 'active' then least(coalesce(r.ends_at, now()), now()) else r.ends_at end
     where id = r.id;
    if not public.featured_now(r.product_id) then update public.products set is_featured = false where id = r.product_id; end if;
  else
    raise exception 'Unknown status %', p_status;
  end if;
  return p_status;
end; $$;
revoke execute on function public.set_featured_status(bigint, text) from public, anon;
grant  execute on function public.set_featured_status(bigint, text) to authenticated;

-- Ends Featured listings whose days are over. Called by the home page and admin panel; harmless to call often.
create or replace function public.expire_featured()
returns integer language plpgsql security definer set search_path = ''
as $$
declare n integer;
begin
  with done as (
    update public.featured_requests set status = 'expired'
     where status = 'active' and ends_at <= now() returning product_id)
  update public.products p set is_featured = false
   where p.id in (select product_id from done) and not public.featured_now(p.id);
  get diagnostics n = row_count;
  return n;
end; $$;
grant execute on function public.expire_featured() to anon, authenticated;

-- 5. Messages on RGBKart ------------------------------------------------------------------------
-- A buyer (signed in, or with an invisible guest login) writes to the seller about one product.
-- Only the buyer and the seller can read the conversation.

create table if not exists public.conversations (
  id               bigint generated by default as identity primary key,
  product_id       bigint references public.products (id) on delete set null,
  product_title    text not null,
  buyer_id         uuid not null references auth.users (id) on delete cascade,
  seller_id        uuid not null references auth.users (id) on delete cascade,
  buyer_name       text not null check (char_length(buyer_name) between 2 and 60),
  last_message     text,
  last_sender_id   uuid,
  last_message_at  timestamptz not null default now(),
  buyer_read_at    timestamptz not null default now(),
  seller_read_at   timestamptz,
  created_at       timestamptz not null default now(),
  unique (product_id, buyer_id)
);
create index if not exists conversations_buyer on public.conversations (buyer_id, last_message_at desc);
create index if not exists conversations_seller on public.conversations (seller_id, last_message_at desc);

create table if not exists public.messages (
  id               bigint generated by default as identity primary key,
  conversation_id  bigint not null references public.conversations (id) on delete cascade,
  sender_id        uuid not null references auth.users (id) on delete cascade,
  body             text not null check (char_length(trim(body)) between 1 and 1000),
  created_at       timestamptz not null default now()
);
create index if not exists messages_conv on public.messages (conversation_id, created_at);
create index if not exists messages_sender on public.messages (sender_id, created_at desc);

alter table public.conversations enable row level security;
alter table public.messages enable row level security;
revoke all on public.conversations, public.messages from anon, authenticated;
grant select on public.conversations, public.messages to authenticated;   -- writing only through the functions below

drop policy if exists "Participants read conversations" on public.conversations;
create policy "Participants read conversations" on public.conversations for select to authenticated
  using (auth.uid() in (buyer_id, seller_id));
drop policy if exists "Participants read messages" on public.messages;
create policy "Participants read messages" on public.messages for select to authenticated
  using (exists (select 1 from public.conversations c where c.id = conversation_id and auth.uid() in (c.buyer_id, c.seller_id)));

-- Send a message. New conversation: pass p_product (+ p_name). Reply: pass p_conversation.
create or replace function public.send_message(p_body text, p_product bigint default null, p_conversation bigint default null, p_name text default null)
returns bigint language plpgsql security definer set search_path = ''
as $$
declare uid uuid := auth.uid(); b text := trim(coalesce(p_body, '')); c record; pr record; nm text; cid bigint;
begin
  if uid is null then raise exception 'Please reload the page and try again'; end if;
  if char_length(b) < 1 then raise exception 'Write a message'; end if;
  if char_length(b) > 1000 then raise exception 'Keep the message under 1000 characters'; end if;
  -- simple spam limits
  if (select count(*) from public.messages where sender_id = uid and created_at > now() - interval '10 minutes') >= 20 then
    raise exception 'You are sending messages too fast. Please wait a few minutes.';
  end if;

  if p_conversation is not null then
    select * into c from public.conversations where id = p_conversation and uid in (buyer_id, seller_id);
    if c.id is null then raise exception 'Conversation not found'; end if;
    cid := c.id;
  else
    select id, seller_id, title, status into pr from public.products where id = p_product;
    if pr.id is null or pr.status <> 'approved' then raise exception 'This product is not available'; end if;
    if pr.seller_id = uid then raise exception 'This is your own listing'; end if;
    select id into cid from public.conversations where product_id = pr.id and buyer_id = uid;
    if cid is null then
      if (select count(*) from public.conversations where buyer_id = uid and created_at > now() - interval '1 day') >= 15 then
        raise exception 'You have contacted many sellers today. Please try again tomorrow.';
      end if;
      nm := trim(coalesce(p_name, ''));
      if char_length(nm) < 2 then
        select coalesce(nullif(trim(full_name), ''), '') into nm from public.profiles where id = uid;
      end if;
      if char_length(coalesce(nm, '')) < 2 then raise exception 'Enter your name'; end if;
      insert into public.conversations (product_id, product_title, buyer_id, seller_id, buyer_name)
      values (pr.id, pr.title, uid, pr.seller_id, left(nm, 60)) returning id into cid;
    end if;
  end if;

  insert into public.messages (conversation_id, sender_id, body) values (cid, uid, b);
  update public.conversations
     set last_message = left(b, 140), last_sender_id = uid, last_message_at = now(),
         buyer_read_at  = case when buyer_id  = uid then now() else buyer_read_at end,
         seller_read_at = case when seller_id = uid then now() else seller_read_at end
   where id = cid;
  return cid;
end; $$;
revoke execute on function public.send_message(text, bigint, bigint, text) from public, anon;
grant  execute on function public.send_message(text, bigint, bigint, text) to authenticated;

create or replace function public.mark_conversation_read(p_conversation bigint)
returns void language sql security definer set search_path = ''
as $$
  update public.conversations
     set buyer_read_at  = case when buyer_id  = auth.uid() then now() else buyer_read_at end,
         seller_read_at = case when seller_id = auth.uid() then now() else seller_read_at end
   where id = p_conversation and auth.uid() in (buyer_id, seller_id);
$$;
revoke execute on function public.mark_conversation_read(bigint) from public, anon;
grant  execute on function public.mark_conversation_read(bigint) to authenticated;

-- How many conversations have new messages for me
create or replace function public.my_unread_count()
returns integer language sql stable security definer set search_path = ''
as $$
  select count(*)::int from public.conversations
   where last_sender_id is distinct from auth.uid()
     and ((buyer_id = auth.uid() and last_message_at > buyer_read_at)
       or (seller_id = auth.uid() and (seller_read_at is null or last_message_at > seller_read_at)))
$$;
grant execute on function public.my_unread_count() to authenticated;

-- 6. Check ----------------------------------------------------------------------------------------
select to_regclass('public.conversations') is not null as messages_ready,
       to_regprocedure('public.listing_contact(bigint)') is not null as contact_rules_ready,
       (select count(*) from public.featured_plans where is_active) as featured_plans;
