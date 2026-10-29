-- Checkout fix (found 29 Oct 2026): "Place order" failed with "DELETE requires a WHERE clause".
-- Supabase refuses a DELETE without a condition when it comes from the website, and place_order cleared its
-- temporary list of cart lines with "delete from _lines;". It now says "delete from _lines where true;".
-- The rest of place_order stays exactly as it is on your database (it is copied and only that line is changed).
-- Run once in Supabase → SQL Editor. Safe to run again.

do $$
declare src text;
begin
  select pg_get_functiondef('public.place_order(jsonb, jsonb, jsonb, jsonb)'::regprocedure) into src;
  if position('delete from _lines;' in src) > 0 then
    execute replace(src, 'delete from _lines;', 'delete from _lines where true;');
  end if;
end $$;

select position('delete from _lines where true;' in pg_get_functiondef('public.place_order(jsonb, jsonb, jsonb, jsonb)'::regprocedure)) > 0 as checkout_fixed;
