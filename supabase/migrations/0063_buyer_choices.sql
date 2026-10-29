-- Buyer's choices that don't change the price (owner, 29 Oct 2026). Example: a laptop sold in 3 colours at the same price.
-- The shop ticks the colours it sells; the buyer must pick one on the product page; the choice is written on the order
-- ("Colour: Black") so the shop knows what to send. No extra versions are made, so prices and stock stay simple.
-- 1. products.buyer_choice_ids: up to 2 details (single-choice or colour) the buyer picks. Their values are the product's
--    details rows (product_attribute_values), so for these details a product may have several values.
-- 2. pav_check: several values allowed for a buyer-choice detail.
-- 3. place_order: each cart line sends choices {attribute id: option id}; checked against the product, added to the
--    order line's label. Copied from your live place_order and changed only there (like 0061).
-- Run once in Supabase → SQL Editor, AFTER 0062_social_links.sql. Safe to run again.

alter table public.products add column if not exists buyer_choice_ids bigint[] not null default '{}';
alter table public.products drop constraint if exists products_buyer_choices;
alter table public.products add constraint products_buyer_choices check (cardinality(buyer_choice_ids) <= 2);
grant insert (buyer_choice_ids), update (buyer_choice_ids) on public.products to authenticated;

create or replace function public.pav_check()
returns trigger language plpgsql set search_path = ''
as $$
declare cat bigint; t text; choices bigint[];
begin
  select category_id, buyer_choice_ids into cat, choices from public.products where id = new.product_id;
  if not exists (select 1 from public.category_effective_attributes(cat) e where e.attribute_id = new.attribute_id) then
    raise exception 'This attribute doesn''t apply to the product''s category';
  end if;
  select input_type into t from public.attributes where id = new.attribute_id;
  if t = 'boolean' and new.bool_value is null then raise exception 'Choose Yes or No'; end if;
  if t <> 'boolean' and new.option_id is null then raise exception 'Choose an option from the list'; end if;
  if new.option_id is not null and not exists (
       select 1 from public.attribute_options o where o.id = new.option_id and o.attribute_id = new.attribute_id) then
    raise exception 'That option doesn''t belong to this attribute';
  end if;
  if t in ('select', 'color') and not (new.attribute_id = any(coalesce(choices, '{}'))) and exists (
       select 1 from public.product_attribute_values v
       where v.product_id = new.product_id and v.attribute_id = new.attribute_id and v.id <> coalesce(new.id, -1)) then
    raise exception 'Only one option can be chosen for this attribute';
  end if;
  return new;
end; $$;

do $$
declare src text; addon text;
begin
  select pg_get_functiondef('public.place_order(jsonb, jsonb, jsonb, jsonb)'::regprocedure) into src;
  if position('buyer choices (0063)' in src) = 0 then
    addon := $a$    -- buyer choices (0063): details the buyer picks that don't change the price, e.g. Colour
    declare ca bigint; co bigint; cl text;
    begin
      foreach ca in array coalesce(pr.buyer_choice_ids, '{}'::bigint[]) loop
        co := nullif(it->'choices'->>(ca::text), '')::bigint;
        cl := null;
        select a.name || ': ' || o.value into cl
          from public.product_attribute_values v join public.attribute_options o on o.id = v.option_id join public.attributes a on a.id = v.attribute_id
         where v.product_id = pr.id and v.attribute_id = ca and v.option_id = co;
        if cl is null then raise exception 'Choose % for "%"', (select name from public.attributes where id = ca), pr.title; end if;
        lbl := concat_ws(' / ', lbl, cl);
      end loop;
    end;
$a$;
    src := replace(src, '    if unit is null or unit <= 0 then raise exception', addon || '    if unit is null or unit <= 0 then raise exception');
    execute src;
  end if;
end $$;

select (select count(*) from information_schema.columns where table_name = 'products' and column_name = 'buyer_choice_ids') as buyer_choices_column,
       position('buyer choices (0063)' in pg_get_functiondef('public.place_order(jsonb, jsonb, jsonb, jsonb)'::regprocedure)) > 0 as checkout_reads_choices;
