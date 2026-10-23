-- Admin → Users: every account in one list (RGBKart staff, shops, one-time sellers, customers, guests) with Block and Delete.
-- * Master Admin and Co-admins see the list and can Block / Unblock (Co-admins can't block staff).
-- * Block: the person can't sign in any more (signed out everywhere); a shop or one-time seller is also hidden, with its live
--   products taken down. Unblock puts everything back. Nothing is deleted, so orders, payments and reviews stay.
-- * Delete permanently: Master Admin only. Removes the account and EVERYTHING linked to it (their products, orders, payments,
--   reviews, messages). Not possible for yourself or for team members (remove them from Team first).
-- Run once in Supabase → SQL Editor, AFTER 0046_change_master_admin.sql. Safe to run again.

alter table public.profiles add column if not exists blocked_at timestamptz;
alter table public.profiles add column if not exists blocked_reason text check (blocked_reason is null or char_length(blocked_reason) <= 300);
alter table public.profiles add column if not exists blocked_shop_status text;          -- shop status before blocking, put back on unblock
alter table public.products add column if not exists blocked_hidden boolean not null default false;   -- taken down because the seller was blocked

-- 1. The list -------------------------------------------------------------------------------------------------------------
create or replace function public.admin_users(p_kind text default 'all', p_search text default null, p_limit integer default 100, p_offset integer default 0)
returns table (id uuid, kind text, email text, full_name text, phone text, created_at timestamptz, last_sign_in_at timestamptz,
               staff_role text, shop_name text, seller_status text, city text, products integer, buyer_orders integer, shop_orders integer,
               payments integer, blocked_at timestamptz, blocked_reason text, total bigint)
language plpgsql stable security definer set search_path = ''
as $$
declare q text := nullif(lower(trim(coalesce(p_search, ''))), '');
begin
  if not public.has_staff_role(array['master_admin', 'co_admin']) then raise exception 'Only the Master Admin or a Co-admin can see all users'; end if;
  return query
  with base as (
    select u.id, u.email::text as email, u.created_at,
           (to_jsonb(u) ->> 'last_sign_in_at')::timestamptz as last_in,
           coalesce((to_jsonb(u) ->> 'is_anonymous')::boolean, false) as anon,
           p.full_name, p.phone, p.role, p.blocked_at, p.blocked_reason,
           st.staff_role, sd.shop_name, sd.status as seller_status, sd.city,
           case when st.user_id is not null then 'staff'
                when p.role = 'seller' then 'shop'
                when p.role = 'individual' then 'one_time'
                when coalesce((to_jsonb(u) ->> 'is_anonymous')::boolean, false) or u.email is null or u.email = '' then 'guest'
                else 'customer' end as kind
      from auth.users u
      left join public.profiles p on p.id = u.id
      left join public.staff st on st.user_id = u.id
      left join public.seller_details sd on sd.user_id = u.id
  ), picked as (
    select b.* from base b
     where (coalesce(p_kind, 'all') = 'all' and b.kind <> 'guest' or b.kind = p_kind or (p_kind = 'blocked' and b.blocked_at is not null))
       and (q is null or lower(concat_ws(' ', b.email, b.full_name, b.phone, b.shop_name)) like '%' || q || '%')
  )
  select pk.id, pk.kind, pk.email, pk.full_name, pk.phone, pk.created_at, pk.last_in, pk.staff_role, pk.shop_name, pk.seller_status, pk.city,
         (select count(*)::int from public.products x where x.seller_id = pk.id),
         (select count(*)::int from public.orders x where x.customer_id = pk.id),
         (select count(*)::int from public.orders x where x.seller_id = pk.id),
         (select count(*)::int from public.payments x where x.seller_id = pk.id and x.status = 'verified'),
         pk.blocked_at, pk.blocked_reason, count(*) over ()
    from picked pk
   order by pk.created_at desc
   limit greatest(1, least(coalesce(p_limit, 100), 500)) offset greatest(coalesce(p_offset, 0), 0);
end; $$;
revoke execute on function public.admin_users(text, text, integer, integer) from public, anon;
grant  execute on function public.admin_users(text, text, integer, integer) to authenticated;

-- 2. Block / unblock -----------------------------------------------------------------------------------------------------
create or replace function public.admin_block_user(p_user uuid, p_block boolean, p_reason text default null)
returns void language plpgsql security definer set search_path = ''
as $$
declare pr record; target_staff text; r text := left(nullif(trim(coalesce(p_reason, '')), ''), 300);
begin
  if not public.has_staff_role(array['master_admin', 'co_admin']) then raise exception 'Only the Master Admin or a Co-admin can block accounts'; end if;
  if p_user = auth.uid() then raise exception 'You can''t block your own account'; end if;
  select staff_role into target_staff from public.staff where user_id = p_user;
  if target_staff = 'master_admin' then raise exception 'The Master Admin can''t be blocked'; end if;
  if target_staff is not null and not public.has_staff_role(array['master_admin']) then raise exception 'Only the Master Admin can block team members'; end if;
  insert into public.profiles (id) values (p_user) on conflict (id) do nothing;
  select * into pr from public.profiles where id = p_user;

  if p_block then
    if pr.blocked_at is not null then return; end if;
    if r is null then raise exception 'Write a short reason (for the team''s records)'; end if;
    update public.profiles set blocked_at = now(), blocked_reason = r,
           blocked_shop_status = (select status from public.seller_details where user_id = p_user) where id = p_user;
    update public.seller_details set status = 'rejected' where user_id = p_user and status <> 'rejected';
    update public.products set status = 'rejected', blocked_hidden = true, review_note = 'Taken down: the seller account is blocked by RGBKart'
     where seller_id = p_user and status = 'approved';
    -- no more sign-in, and signed out everywhere (these auth columns/tables exist on Supabase)
    if exists (select 1 from information_schema.columns where table_schema = 'auth' and table_name = 'users' and column_name = 'banned_until') then
      execute 'update auth.users set banned_until = now() + interval ''100 years'' where id = $1' using p_user;
    end if;
    if to_regclass('auth.sessions') is not null then execute 'delete from auth.sessions where user_id = $1' using p_user; end if;
    if to_regclass('auth.refresh_tokens') is not null then execute 'delete from auth.refresh_tokens where user_id::text = $1::text' using p_user; end if;
  else
    if pr.blocked_at is null then return; end if;
    update public.seller_details set status = coalesce(pr.blocked_shop_status, status) where user_id = p_user;
    update public.products set status = 'approved', blocked_hidden = false, review_note = null where seller_id = p_user and blocked_hidden;
    update public.profiles set blocked_at = null, blocked_reason = null, blocked_shop_status = null where id = p_user;
    if exists (select 1 from information_schema.columns where table_schema = 'auth' and table_name = 'users' and column_name = 'banned_until') then
      execute 'update auth.users set banned_until = null where id = $1' using p_user;
    end if;
  end if;
end; $$;
revoke execute on function public.admin_block_user(uuid, boolean, text) from public, anon;
grant  execute on function public.admin_block_user(uuid, boolean, text) to authenticated;

-- 3. Delete permanently (Master Admin only; type the email, or DELETE for accounts without one) ----------------------------
create or replace function public.admin_delete_user(p_user uuid, p_confirm text)
returns void language plpgsql security definer set search_path = ''
as $$
declare em text;
begin
  if not public.has_staff_role(array['master_admin']) then raise exception 'Only the Master Admin can delete accounts'; end if;
  if p_user = auth.uid() then raise exception 'You can''t delete your own account'; end if;
  if exists (select 1 from public.staff where user_id = p_user) then raise exception 'This person is on the RGBKart team. Remove them in Team first, then delete.'; end if;
  select lower(email) into em from auth.users where id = p_user;
  if not found then raise exception 'Account not found (maybe already deleted)'; end if;
  if lower(trim(coalesce(p_confirm, ''))) <> coalesce(nullif(em, ''), 'delete') then
    raise exception 'To confirm, type the account''s email exactly (or DELETE for an account without email)';
  end if;
  delete from public.reports where seller_id = p_user;            -- complaints about this shop would lose their link
  delete from auth.users where id = p_user;                       -- profile, shop, products, orders, payments, reviews, messages go with it
end; $$;
revoke execute on function public.admin_delete_user(uuid, text) from public, anon;
grant  execute on function public.admin_delete_user(uuid, text) to authenticated;

select to_regprocedure('public.admin_users(text,text,integer,integer)') is not null as users_page_ready,
       (select count(*) from auth.users) as accounts;
