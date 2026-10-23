-- Settings for home page sections (first use: how the "Top shops" row moves).
-- settings is a small list of choices, e.g. {"motion":"continuous","speed":"normal","direction":"left"}.
--   motion: continuous (glides all the time) · step (moves one shop every few seconds) · off (only the arrows)
--   speed: slow · normal · fast        direction: left (right to left) · right (left to right)
-- Run once in Supabase → SQL Editor, AFTER 0026_top_shops.sql. Safe to run again.

alter table public.home_sections add column if not exists settings jsonb not null default '{}'::jsonb;

update public.home_sections set settings = '{"motion":"continuous","speed":"normal","direction":"left"}'::jsonb
where section_type = 'top_shops' and settings = '{}'::jsonb;

select title, settings from public.home_sections where section_type = 'top_shops';
