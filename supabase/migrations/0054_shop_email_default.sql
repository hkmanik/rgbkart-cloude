-- Shop email starts with the sign-up email too (owner, 24 Oct 2026). 0053 filled the shop phone and WhatsApp from sign-up;
-- now an empty shop email is filled from the account's sign-up (login) email when the shop is created, and existing
-- shops with an empty email get it now. (Business address and district already come from the sign-up form.)
-- Not for one-time sellers (their contact follows the Free / Featured listing rules) or guest accounts without an email.
-- Sellers can change or clear it in Seller Center → Shop settings.
-- Run once in Supabase → SQL Editor, AFTER 0053_shop_contact_default.sql. Safe to run again.

create or replace function public.shop_contact_default()
returns trigger language plpgsql security definer set search_path = ''
as $$
declare ph text; em text; role text;
begin
  select public.bd_phone(p.phone), p.role, u.email into ph, role, em
    from public.profiles p join auth.users u on u.id = p.id where p.id = new.user_id;
  if ph ~ '^01[3-9][0-9]{8}$' then
    if coalesce(trim(new.phone_public), '') = '' then new.phone_public := ph; end if;
    if coalesce(trim(new.whatsapp), '') = '' then new.whatsapp := coalesce(nullif(trim(new.phone_public), ''), ph); end if;
  end if;
  if coalesce(role, 'seller') = 'seller' and coalesce(trim(new.email_public), '') = '' and em like '%@%' then
    new.email_public := lower(em);
  end if;
  return new;
end; $$;
revoke execute on function public.shop_contact_default() from public, anon, authenticated;
drop trigger if exists ab_shop_contact_default on public.seller_details;
create trigger ab_shop_contact_default before insert on public.seller_details for each row execute function public.shop_contact_default();

-- Existing shops with no email yet
update public.seller_details s
   set email_public = lower(u.email)
  from public.profiles p join auth.users u on u.id = p.id
 where p.id = s.user_id and p.role = 'seller' and coalesce(trim(s.email_public), '') = '' and u.email like '%@%';

select (select count(*) from public.seller_details s join public.profiles p on p.id = s.user_id
         where p.role = 'seller' and coalesce(trim(s.email_public), '') = '') as shops_without_email,
       (select count(*) from public.seller_details where coalesce(trim(phone_public), '') = '') as shops_without_phone;
