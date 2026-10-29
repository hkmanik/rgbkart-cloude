-- 0069 Supabase Advisor fixes (audit Part B, 30 Oct 2026). Changes nothing people can see; safe to run more than once.
--
-- 1. Faster row rules (Performance Advisor "Auth RLS Initialization Plan", 45 warnings):
--    rules that check auth.uid() now ask it once per query instead of once per row.
-- 2. Fewer functions callable from outside (Security Advisor "security definer function executable"):
--    • trigger functions run by themselves when data changes; nobody needs to call them directly
--    • admin and "my ..." functions are not needed by visitors who are not signed in

-- 1 ----------------------------------------------------------------------------------------------
do $$
declare
  p record; q text; c text; sql text; n int := 0;
  fix constant text := '(?<!select )auth\.(uid|jwt|role)\(\)';
begin
  for p in select schemaname, tablename, policyname, qual, with_check from pg_policies where schemaname in ('public', 'storage') loop
    q := p.qual; c := p.with_check;
    if coalesce(q, '') !~* fix and coalesce(c, '') !~* fix then continue; end if;
    q := regexp_replace(q, fix, '(select auth.\1())', 'gi');
    c := regexp_replace(c, fix, '(select auth.\1())', 'gi');
    sql := format('alter policy %I on %I.%I', p.policyname, p.schemaname, p.tablename);
    if q is not null then sql := sql || ' using (' || q || ')'; end if;
    if c is not null then sql := sql || ' with check (' || c || ')'; end if;
    execute sql; n := n + 1;
  end loop;
  raise notice 'Row rules made faster: %', n;
end $$;

-- 2 ----------------------------------------------------------------------------------------------
do $$
declare f record;
begin
  for f in select p.oid::regprocedure as sig from pg_proc p join pg_namespace s on s.oid = p.pronamespace
            where s.nspname = 'public' and p.prorettype = 'trigger'::regtype loop
    execute format('revoke execute on function %s from public, anon, authenticated', f.sig);
  end loop;
end $$;

revoke execute on function public.admin_alert_stats() from public, anon;
revoke execute on function public.my_alert_count()    from public, anon;
revoke execute on function public.my_unread_count()   from public, anon;
grant  execute on function public.admin_alert_stats() to authenticated;
grant  execute on function public.my_alert_count()    to authenticated;
grant  execute on function public.my_unread_count()   to authenticated;

-- Check: should be 0
select count(*) as slow_rules_left from pg_policies
 where schemaname in ('public', 'storage') and (coalesce(qual, '') ~* '(?<!select )auth\.uid\(\)' or coalesce(with_check, '') ~* '(?<!select )auth\.uid\(\)');
