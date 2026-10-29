-- 0067 Audit fix (29 Oct 2026): only Master admin and Co-admin can create, change, publish or delete ads.
-- Before this, Editors could too, which meant an Editor could mark an ad as "paid" and publish it without payment.
-- Editors can still SEE ads (to help answer questions). Shops keep their own rules from 0019.
-- Safe to run more than once.

drop policy if exists "Staff manage ads" on public.ads;
drop policy if exists "Staff read ads" on public.ads;
drop policy if exists "Admins manage ads" on public.ads;

create policy "Staff read ads" on public.ads for select to authenticated
  using (public.has_staff_role(array['master_admin', 'co_admin', 'editor']));

create policy "Admins manage ads" on public.ads for all to authenticated
  using (public.has_staff_role(array['master_admin', 'co_admin']))
  with check (public.has_staff_role(array['master_admin', 'co_admin']));
