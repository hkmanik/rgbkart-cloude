-- RGBKart · Phase 0
-- Creates one tiny public table so the website can prove it reaches the database.
-- How to run: Supabase dashboard → SQL Editor → New query → paste this file → Run.
-- Safe to run more than once.

create table if not exists public.app_status (
  id         integer primary key,
  phase      text        not null,
  message    text        not null,
  updated_at timestamptz not null default now()
);

-- Row Level Security: on by default for every RGBKart table.
alter table public.app_status enable row level security;

-- Anyone (including visitors who are not signed in) may READ this table. Nobody may write
-- to it from the website; only you, from the dashboard.
drop policy if exists "app_status is readable by everyone" on public.app_status;
create policy "app_status is readable by everyone"
  on public.app_status for select
  to anon, authenticated
  using (true);

insert into public.app_status (id, phase, message)
values (1, 'Phase 0', 'Database connected')
on conflict (id) do update set phase = excluded.phase, message = excluded.message, updated_at = now();
