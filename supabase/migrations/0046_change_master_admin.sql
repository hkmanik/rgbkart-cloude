-- Make rgbkart@gmail.com the Master Admin (owner's request, 23 Oct 2026).
-- hkmanik@gmail.com stays on the team as a Co-admin (a spare way in if the new account is ever locked out).
-- BEFORE running: create the rgbkart@gmail.com account on the site (login.html → Sign up) and click the link in the
-- confirmation email, so the account exists and is confirmed. If it doesn't exist yet, this stops with a message and changes nothing.
-- The "RGBKart Official" shop stays linked to hkmanik@gmail.com (its products and orders don't move).
-- Run once in Supabase → SQL Editor, AFTER 0045_shop_delivery.sql. Safe to run again.

do $$
declare new_id uuid; old_id uuid;
begin
  select id into new_id from auth.users where lower(email) = 'rgbkart@gmail.com' and email_confirmed_at is not null;
  if new_id is null then
    raise exception 'First sign up on the site with rgbkart@gmail.com and click the link in the confirmation email, then run this again.';
  end if;
  select id into old_id from auth.users where lower(email) = 'hkmanik@gmail.com';

  insert into public.profiles (id) values (new_id) on conflict (id) do nothing;
  insert into public.staff (user_id, email, staff_role) values (new_id, 'rgbkart@gmail.com', 'master_admin')
  on conflict (user_id) do update set staff_role = 'master_admin', email = excluded.email;
  delete from public.staff_invites where email = 'rgbkart@gmail.com';

  -- the old Master Admin becomes a Co-admin (only one Master Admin)
  update public.staff set staff_role = 'co_admin' where staff_role = 'master_admin' and user_id <> new_id;
end $$;

select email, staff_role from public.staff where staff_role in ('master_admin', 'co_admin') order by staff_role desc, email;
