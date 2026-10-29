-- Home page sections per device (owner, 29 Oct 2026): a section can be shown on computers but hidden on phones or tablets.
-- Phone = screen up to 640 px wide, tablet = 641–1024 px, computer = wider. Set in Admin → Home page → Edit → "Show on".
-- Run once in Supabase → SQL Editor. Safe to run again.

alter table public.home_sections add column if not exists on_desktop boolean not null default true;
alter table public.home_sections add column if not exists on_tablet  boolean not null default true;
alter table public.home_sections add column if not exists on_mobile  boolean not null default true;

select count(*) as sections, count(*) filter (where on_desktop and on_tablet and on_mobile) as on_all_devices from public.home_sections;
