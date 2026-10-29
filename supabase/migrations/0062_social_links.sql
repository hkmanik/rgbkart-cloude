-- Social media links in the footer (owner, 29 Oct 2026). Stored in site_settings key 'social'.
-- Edited in Admin → Pages & policies → Social media links (Master Admin and Co-admins).
-- An icon is clickable only when it has a link; the others show faded until a link is added.
-- Run once in Supabase → SQL Editor. Safe to run again (an existing list is not changed).

insert into public.site_settings (key, value)
values ('social', jsonb_build_object(
  'facebook',  'https://www.facebook.com/profile.php?id=61595909253406',
  'instagram', '', 'youtube', '', 'tiktok', '', 'x', '', 'pinterest', ''))
on conflict (key) do nothing;

select value as social_links from public.site_settings where key = 'social';
