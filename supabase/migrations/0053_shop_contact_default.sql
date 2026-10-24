-- Shop contact starts with the sign-up phone (owner, 24 Oct 2026). Shops show phone/WhatsApp to everyone (contact rules,
-- 22 Oct), but a new shop's phone_public and whatsapp were empty until the seller filled them in Shop settings.
-- Now an empty shop phone / WhatsApp is filled from the account's sign-up phone when the shop is created, and existing
-- shops with an empty phone get it now. Email is NOT copied (the login email may be private); Seller Center offers it
-- in the Email box and the seller decides by saving. Sellers can still change or clear everything in Shop settings.
-- Run once in Supabase → SQL Editor, AFTER 0052_phone_format.sql. Safe to run again.

create or replace function public.shop_contact_default()
returns trigger language plpgsql security definer set search_path = ''
as $$
declare ph text;
begin
  select public.bd_phone(phone) into ph from public.profiles where id = new.user_id;
  if ph ~ '^01[3-9][0-9]{8}$' then
    if coalesce(trim(new.phone_public), '') = '' then new.phone_public := ph; end if;
    if coalesce(trim(new.whatsapp), '') = '' then new.whatsapp := coalesce(nullif(trim(new.phone_public), ''), ph); end if;
  end if;
  return new;
end; $$;
revoke execute on function public.shop_contact_default() from public, anon, authenticated;
drop trigger if exists ab_shop_contact_default on public.seller_details;
create trigger ab_shop_contact_default before insert on public.seller_details for each row execute function public.shop_contact_default();

-- Existing shops with no phone yet
update public.seller_details s
   set phone_public = coalesce(nullif(trim(s.phone_public), ''), public.bd_phone(p.phone)),
       whatsapp     = coalesce(nullif(trim(s.whatsapp), ''), nullif(trim(s.phone_public), ''), public.bd_phone(p.phone))
  from public.profiles p
 where p.id = s.user_id and public.bd_phone(p.phone) ~ '^01[3-9][0-9]{8}$'
   and (coalesce(trim(s.phone_public), '') = '' or coalesce(trim(s.whatsapp), '') = '');

select (select count(*) from public.seller_details where coalesce(trim(phone_public), '') = '') as shops_without_phone,
       (select count(*) from pg_trigger where tgname = 'ab_shop_contact_default') as contact_trigger;
