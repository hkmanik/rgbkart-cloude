-- One phone format (found 24 Oct 2026). The database checks accept 01XXXXXXXXX but not the usual +8801XXXXXXXXX,
-- so numbers saved as +880… (e.g. from Google sign-up) were refused later at checkout and in the address book.
-- Pages now send 01… (site/phone.js); this makes the database store 01… too and converts numbers already saved.
-- Only Bangladesh mobile numbers are changed (+8801…, 8801…, 1XXXXXXXXX → 01…); anything else is left as typed.
-- Run once in Supabase → SQL Editor, AFTER 0051_signup_address.sql. Safe to run again.

create or replace function public.bd_phone(p text)
returns text language sql immutable set search_path = ''
as $$
  select case
    when p is null then null
    when regexp_replace(p, '\D', '', 'g') ~ '^8801[3-9][0-9]{8}$' then '0' || right(regexp_replace(p, '\D', '', 'g'), 10)
    when regexp_replace(p, '\D', '', 'g') ~ '^01[3-9][0-9]{8}$'   then regexp_replace(p, '\D', '', 'g')
    when regexp_replace(p, '\D', '', 'g') ~ '^1[3-9][0-9]{8}$'    then '0' || regexp_replace(p, '\D', '', 'g')
    else p end
$$;
grant execute on function public.bd_phone(text) to anon, authenticated;

create or replace function public.tidy_phones()
returns trigger language plpgsql set search_path = ''
as $$
begin
  if tg_table_name = 'profiles' then new.phone := public.bd_phone(new.phone);
  elsif tg_table_name = 'seller_details' then new.phone_public := public.bd_phone(new.phone_public); new.whatsapp := public.bd_phone(new.whatsapp);
  elsif tg_table_name = 'customer_addresses' then new.phone := public.bd_phone(new.phone);
  end if;
  return new;
end; $$;
revoke execute on function public.tidy_phones() from public, anon, authenticated;
drop trigger if exists aa_tidy_phones on public.profiles;
create trigger aa_tidy_phones before insert or update of phone on public.profiles for each row execute function public.tidy_phones();
drop trigger if exists aa_tidy_phones on public.seller_details;
create trigger aa_tidy_phones before insert or update of phone_public, whatsapp on public.seller_details for each row execute function public.tidy_phones();
drop trigger if exists zz_tidy_phones on public.customer_addresses;
create trigger zz_tidy_phones before insert or update of phone on public.customer_addresses for each row execute function public.tidy_phones();

-- Numbers already saved
update public.profiles       set phone = public.bd_phone(phone) where phone is distinct from public.bd_phone(phone);
update public.seller_details set phone_public = public.bd_phone(phone_public), whatsapp = public.bd_phone(whatsapp)
 where phone_public is distinct from public.bd_phone(phone_public) or whatsapp is distinct from public.bd_phone(whatsapp);

select (select count(*) from public.profiles where phone ~ '^\+?880') as profiles_still_880,
       (select count(*) from public.profiles where phone is not null and phone !~ '^01[3-9][0-9]{8}$') as profiles_not_mobile_format,
       (select count(*) from public.seller_details where phone_public is not null and phone_public !~ '^01[3-9][0-9]{8}$') as shops_phone_to_check,
       (select count(*) from pg_trigger where tgname in ('aa_tidy_phones', 'zz_tidy_phones')) as phone_triggers;
