-- Cash on Delivery limits (plan 3.3).
-- The Master Admin or a Co-admin sets three limits in Admin → Orders → "Cash on Delivery limits":
--   * the biggest order a buyer can place with one shop (৳),
--   * a lower limit for a buyer's first order (nothing delivered to them yet, matched by account or mobile number),
--   * how many orders one buyer can have on the way at one time (all shops together).
-- 0 means "no limit". The database checks every new order, so the limits can't be skipped.
-- Run once in Supabase → SQL Editor, AFTER 0040_security_fixes.sql. Safe to run again.

-- 1. Settings that staff can change (everyone can read them; checkout shows the limits) -------------------------------
create table if not exists public.site_settings (
  key         text primary key check (key ~ '^[a-z_]{2,40}$'),
  value       jsonb not null default '{}'::jsonb,
  updated_at  timestamptz not null default now()
);
alter table public.site_settings enable row level security;
revoke all on public.site_settings from anon, authenticated;
grant select on public.site_settings to anon, authenticated;
grant insert, update on public.site_settings to authenticated;
drop policy if exists "Everyone reads settings" on public.site_settings;
create policy "Everyone reads settings" on public.site_settings for select to anon, authenticated using (true);
drop policy if exists "Admins change settings" on public.site_settings;
create policy "Admins change settings" on public.site_settings for all to authenticated
  using (public.has_staff_role(array['master_admin', 'co_admin']))
  with check (public.has_staff_role(array['master_admin', 'co_admin']));

insert into public.site_settings (key, value)
values ('cod', '{"max_order": 50000, "first_order_max": 20000, "max_open": 5}')
on conflict (key) do nothing;

do $$ begin
  if to_regprocedure('public.log_staff_action()') is not null then
    drop trigger if exists log_staff_action on public.site_settings;
    create trigger log_staff_action after insert or update or delete on public.site_settings for each row execute function public.log_staff_action();
  end if;
end $$;

-- 2. Check every new order ------------------------------------------------------------------------------------------------
create or replace function public.cod_limits_check()
returns trigger language plpgsql security definer set search_path = ''
as $$
declare
  s jsonb; mx numeric; first_mx numeric; max_open int; ph10 text; delivered boolean; open_now int; this_txn int; shop text;
  amt text := '৳' || to_char(new.total, 'FM999,999,999,990');
begin
  if new.status is distinct from 'pending' then return new; end if;   -- only new orders from checkout (not imported/demo data)
  select value into s from public.site_settings where key = 'cod';
  if s is null then return new; end if;
  mx := greatest(coalesce((s->>'max_order')::numeric, 0), 0);
  first_mx := greatest(coalesce((s->>'first_order_max')::numeric, 0), 0);
  max_open := greatest(coalesce((s->>'max_open')::int, 0), 0);
  ph10 := right(regexp_replace(coalesce(new.phone, ''), '\D', '', 'g'), 10);
  select coalesce(shop_name, 'this shop') into shop from public.seller_details where user_id = new.seller_id;

  if mx > 0 and new.total > mx then
    raise exception 'Cash on Delivery is limited to % per shop. Your order from % is %. Please remove some items.',
      '৳' || to_char(mx, 'FM999,999,999,990'), shop, amt;
  end if;

  if first_mx > 0 and new.total > first_mx then
    delivered := exists (select 1 from public.orders o where o.status = 'delivered'
                          and (o.customer_id = new.customer_id or (ph10 <> '' and right(regexp_replace(o.phone, '\D', '', 'g'), 10) = ph10)));
    if not delivered then
      raise exception 'For your first order, Cash on Delivery is limited to % per shop. Your order from % is %. Please order less this time.',
        '৳' || to_char(first_mx, 'FM999,999,999,990'), shop, amt;
    end if;
  end if;

  if max_open > 0 then
    -- orders still on the way (any shop); orders made earlier in this same checkout count too
    select count(*) filter (where o.created_at < now()), count(*) filter (where o.created_at >= now())
      into open_now, this_txn
      from public.orders o
     where o.status not in ('delivered', 'cancelled')
       and (o.customer_id = new.customer_id or (ph10 <> '' and right(regexp_replace(o.phone, '\D', '', 'g'), 10) = ph10));
    if open_now + this_txn + 1 > max_open then
      raise exception 'You can have at most % Cash on Delivery orders on the way at one time (you have % now). Please wait for them to arrive, or order from fewer shops.',
        max_open, open_now;
    end if;
  end if;
  return new;
end; $$;
drop trigger if exists cod_limits_check on public.orders;
create trigger cod_limits_check before insert on public.orders for each row execute function public.cod_limits_check();
revoke execute on function public.cod_limits_check() from public, anon, authenticated;

select (select value from public.site_settings where key = 'cod') as cod_limits,
       (select count(*) from pg_trigger where tgname = 'cod_limits_check') as check_on;
