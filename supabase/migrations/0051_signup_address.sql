-- Saved addresses for new customers (found 24 Oct 2026). 0028 copied the sign-up address into the address book only once,
-- for customers who existed then. Customers who signed up later (email or Google/Facebook) started with an empty
-- "Saved addresses" list. From now on the sign-up address is copied in as "Home" (default) when a customer has none yet,
-- and customers who signed up since 0028 get theirs now.
-- Run once in Supabase → SQL Editor, AFTER 0050_invoice_numbers.sql. Safe to run again.

create or replace function public.copy_signup_address(p_user uuid)
returns void language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.customer_addresses (user_id, label, full_name, phone, address, district, is_default)
  select c.user_id, 'Home', coalesce(nullif(trim(p.full_name), ''), 'Customer'),
         (select case when d ~ '^8801[3-9][0-9]{8}$' then '0' || right(d, 10) when d ~ '^01[3-9][0-9]{8}$' then d end
            from (select regexp_replace(coalesce(p.phone, ''), '\D', '', 'g') as d) x),   -- +880 1XXXXXXXXX → 01XXXXXXXXX
         left(trim(c.address), 300), coalesce(nullif(trim(c.city), ''), 'Dhaka'), true
    from public.customer_details c join public.profiles p on p.id = c.user_id
   where c.user_id = p_user
     and char_length(trim(coalesce(c.address, ''))) >= 5 and char_length(coalesce(nullif(trim(c.city), ''), 'Dhaka')) <= 40
     and char_length(coalesce(nullif(trim(p.full_name), ''), 'Customer')) between 2 and 80
     and not exists (select 1 from public.customer_addresses a where a.user_id = c.user_id);
end; $$;
revoke execute on function public.copy_signup_address(uuid) from public, anon, authenticated;

create or replace function public.customer_details_address()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  begin
    perform public.copy_signup_address(new.user_id);
  exception when others then null;   -- never block a sign-up because of the address book
  end;
  return null;
end; $$;
drop trigger if exists customer_details_address on public.customer_details;
create trigger customer_details_address after insert or update of address, city on public.customer_details
  for each row execute function public.customer_details_address();
revoke execute on function public.customer_details_address() from public, anon, authenticated;

-- Customers who signed up since 0028
do $$ declare r record; begin
  for r in select user_id from public.customer_details loop perform public.copy_signup_address(r.user_id); end loop;
end $$;

select (select count(*) from public.customer_details c where char_length(trim(coalesce(c.address, ''))) >= 5
          and not exists (select 1 from public.customer_addresses a where a.user_id = c.user_id)) as customers_still_without_address,
       (select count(*) from pg_trigger where tgname = 'customer_details_address') as address_trigger;
