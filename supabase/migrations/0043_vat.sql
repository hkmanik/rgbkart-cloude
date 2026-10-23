-- VAT on invoices (product rule: admin switches VAT on/off and sets the rate).
-- Prices on RGBKart already include VAT. When VAT is on, each NEW order records the rate and how much of its total is VAT
-- (total × rate ÷ (100 + rate)); invoices and My orders show "Includes VAT". Old orders are not changed.
-- Set it in Admin → Orders → "VAT on invoices" (Master Admin or Co-admin). Starts OFF.
-- Run once in Supabase → SQL Editor, AFTER 0042_cancel_rules.sql. Safe to run again.

insert into public.site_settings (key, value)
values ('vat', '{"on": false, "rate": 5}')
on conflict (key) do nothing;

alter table public.orders add column if not exists vat_rate   numeric(5, 2) check (vat_rate is null or (vat_rate >= 0 and vat_rate <= 50));
alter table public.orders add column if not exists vat_amount numeric(12, 2) check (vat_amount is null or vat_amount >= 0);

create or replace function public.order_vat()
returns trigger language plpgsql security definer set search_path = ''
as $$
declare s jsonb; r numeric;
begin
  select value into s from public.site_settings where key = 'vat';
  if s is null or not coalesce((s->>'on')::boolean, false) then new.vat_rate := null; new.vat_amount := null; return new; end if;
  r := least(greatest(coalesce((s->>'rate')::numeric, 0), 0), 50);
  if r = 0 then return new; end if;
  new.vat_rate := r;
  new.vat_amount := round(coalesce(new.total, 0) * r / (100 + r), 2);
  return new;
end; $$;
drop trigger if exists order_vat on public.orders;
create trigger order_vat before insert on public.orders for each row execute function public.order_vat();
revoke execute on function public.order_vat() from public, anon, authenticated;

select (select value from public.site_settings where key = 'vat') as vat_setting,
       (select count(*) from pg_trigger where tgname = 'order_vat') as vat_ready;
