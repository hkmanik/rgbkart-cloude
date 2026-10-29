-- "Send me offers and news by email" (owner, 29 Oct 2026). Customers and sellers choose when they register; off unless ticked.
-- 1. profiles.email_offers (+ the time it was last changed).
-- 2. Email sign-up: the tick travels in the sign-up details as email_offers = yes and is saved when the profile is made.
-- 3. set_email_offers(on): Google/Facebook sign-up and the switch in My account / Shop settings.
-- Order, payment and account emails are always sent; this is only for promotional emails.
-- Run once in Supabase → SQL Editor. Safe to run again.

alter table public.profiles add column if not exists email_offers boolean not null default false;
alter table public.profiles add column if not exists email_offers_at timestamptz;

create or replace function public.email_offers_from_signup()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  if not new.email_offers and exists (
       select 1 from auth.users u where u.id = new.id and u.raw_user_meta_data ->> 'email_offers' = 'yes') then
    new.email_offers := true; new.email_offers_at := now();
  end if;
  return new;
end; $$;
drop trigger if exists email_offers_from_signup on public.profiles;
create trigger email_offers_from_signup before insert on public.profiles for each row execute function public.email_offers_from_signup();
revoke execute on function public.email_offers_from_signup() from public, anon, authenticated;

create or replace function public.set_email_offers(p_on boolean)
returns boolean language plpgsql security definer set search_path = ''
as $$
begin
  if auth.uid() is null then raise exception 'Please sign in'; end if;
  update public.profiles set email_offers = coalesce(p_on, false), email_offers_at = now()
   where id = auth.uid() and email_offers is distinct from coalesce(p_on, false);
  return coalesce(p_on, false);
end; $$;
revoke execute on function public.set_email_offers(boolean) from public, anon;
grant  execute on function public.set_email_offers(boolean) to authenticated;

-- People who already signed up with the tick (none before today) – and a count for admin
update public.profiles p set email_offers = true, email_offers_at = coalesce(p.email_offers_at, now())
  from auth.users u where u.id = p.id and u.raw_user_meta_data ->> 'email_offers' = 'yes' and not p.email_offers;

select (select count(*) from public.profiles where email_offers) as want_offer_emails,
       (select count(*) from pg_trigger where tgname = 'email_offers_from_signup') as signup_tick_ready;
