-- Sellers must agree to follow the laws of the Government of Bangladesh and RGBKart's rules (owner, 23 Oct 2026).
-- 1. Shop sign-up: the "I agree" tick is saved with the shop (seller_details.rules_accepted_at).
-- 2. Every product sent for review (shops and one-time sellers) needs the tick: products.rules_accepted_at.
--    The database refuses "Send for review" without it, so it can't be skipped. The time is always the server's time.
--    Products already live or waiting are not affected. RGBKart staff are not asked.
-- Run once in Supabase → SQL Editor, AFTER 0048_alert_emails_on.sql. Safe to run again.

alter table public.seller_details add column if not exists rules_accepted_at timestamptz;
alter table public.products       add column if not exists rules_accepted_at timestamptz;
grant insert (rules_accepted_at), update (rules_accepted_at) on public.products to authenticated;

-- 1. Shop sign-up (email): the tick travels in the sign-up details as rules_accepted = yes
create or replace function public.seller_rules_from_signup()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  if new.rules_accepted_at is null and exists (
       select 1 from auth.users u where u.id = new.user_id and u.raw_user_meta_data ->> 'rules_accepted' = 'yes') then
    new.rules_accepted_at := now();
  end if;
  return new;
end; $$;
drop trigger if exists seller_rules_from_signup on public.seller_details;
create trigger seller_rules_from_signup before insert on public.seller_details for each row execute function public.seller_rules_from_signup();
revoke execute on function public.seller_rules_from_signup() from public, anon, authenticated;

-- Google / Facebook sign-up (and existing shops): the page calls this after the tick
create or replace function public.accept_seller_rules()
returns timestamptz language plpgsql security definer set search_path = ''
as $$
declare t timestamptz;
begin
  if auth.uid() is null then raise exception 'Please sign in'; end if;
  update public.seller_details set rules_accepted_at = coalesce(rules_accepted_at, now()) where user_id = auth.uid() returning rules_accepted_at into t;
  return t;
end; $$;
revoke execute on function public.accept_seller_rules() from public, anon;
grant  execute on function public.accept_seller_rules() to authenticated;

-- 2. Products: stamp the tick with the server time; no "Send for review" without it
create or replace function public.product_rules_check()
returns trigger language plpgsql security definer set search_path = ''
as $$
declare staff boolean := exists (select 1 from public.staff where user_id = auth.uid());
begin
  if tg_op = 'INSERT' then
    if new.rules_accepted_at is not null then new.rules_accepted_at := now(); end if;
  elsif new.rules_accepted_at is distinct from old.rules_accepted_at then
    new.rules_accepted_at := case when new.rules_accepted_at is null then old.rules_accepted_at else now() end;
  end if;
  if new.status = 'pending' and (tg_op = 'INSERT' or old.status in ('draft', 'rejected', 'archived'))
     and auth.uid() is not null and not staff and new.rules_accepted_at is null then
    raise exception 'Tick the box to agree to follow the laws of Bangladesh and RGBKart''s rules, then send it again';
  end if;
  return new;
end; $$;
drop trigger if exists product_rules_check on public.products;
create trigger product_rules_check before insert or update on public.products for each row execute function public.product_rules_check();
revoke execute on function public.product_rules_check() from public, anon, authenticated;

select (select count(*) from pg_trigger where tgname in ('seller_rules_from_signup', 'product_rules_check')) as rules_ready;
