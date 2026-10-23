-- Switch on alert EMAILS (plan 7.8). Run this LAST, after the "send-alerts" Edge Function is deployed with its secrets.
-- 1. Only recent alerts are emailed: everything still waiting from before today is marked "skipped" (still shown on the
--    Alerts page, just not emailed), and from now on alerts older than 2 days are never emailed. Test addresses are skipped.
-- 2. Supabase Cron calls the send-alerts function every 5 minutes.
-- Run once in Supabase → SQL Editor, AFTER 0047_admin_users.sql. Safe to run again.

-- 1. Old alerts are not emailed --------------------------------------------------------------------------------------------
update public.notifications set email_status = 'skipped', email_error = 'Older than the email start (not sent)'
 where email_status = 'pending' and created_at < now() - interval '1 day';
update public.notifications set email_status = 'skipped', email_error = 'Test address'
 where email_status = 'pending' and email ilike '%@rgbkart.test';

create or replace function public.take_pending_alerts(p_limit integer default 40)
returns setof public.notifications language plpgsql security definer set search_path = ''
as $$
begin
  -- anything that waited more than 2 days is no longer useful as an email
  update public.notifications set email_status = 'skipped', email_error = coalesce(email_error, 'Too old to email')
   where email_status = 'pending' and created_at < now() - interval '2 days';
  update public.notifications set email_status = 'skipped', email_error = 'Test address'
   where email_status = 'pending' and email ilike '%@rgbkart.test';
  return query
  update public.notifications set attempts = attempts + 1
   where id in (select id from public.notifications where email_status = 'pending' and attempts < 5 and email is not null
                order by created_at limit greatest(1, least(coalesce(p_limit, 40), 100)) for update skip locked)
  returning *;
end; $$;
revoke execute on function public.take_pending_alerts(integer) from public, anon, authenticated;
grant  execute on function public.take_pending_alerts(integer) to service_role;

-- 2. Every 5 minutes, call the send-alerts function ----------------------------------------------------------------------
create extension if not exists pg_cron;
create extension if not exists pg_net;

do $$
begin
  if exists (select 1 from cron.job where jobname = 'rgbkart-send-alerts') then
    perform cron.unschedule('rgbkart-send-alerts');
  end if;
  perform cron.schedule('rgbkart-send-alerts', '*/5 * * * *',
    $job$ select net.http_post(
            url := 'https://qrzlsomuluglbslricaf.supabase.co/functions/v1/send-alerts',
            headers := '{"Content-Type": "application/json"}'::jsonb,
            body := '{}'::jsonb,
            timeout_milliseconds := 60000) $job$);
end $$;

select (select count(*) from cron.job where jobname = 'rgbkart-send-alerts') as email_job_on,
       (select count(*) from public.notifications where email_status = 'pending') as waiting_to_email;
