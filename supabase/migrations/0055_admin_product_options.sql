-- Admin → Add product: products with options (owner, 24 Oct 2026). Shops already add them in Seller Center; now admin can too,
-- for the RGBKart Official shop or any approved seller. admin_create_product(p, p_images) keeps working for simple products;
-- when p has "variations" it makes a product with options:
--   p.variations = [{ "options": { "<attribute id>": <option id>, ... }, "price": 450, "sale_price": null, "stock": 5, "active": true }, ...]
-- Every version uses the same 1–3 attributes (single-choice or colour attributes of the product's category, checked by the
-- existing pvo_check trigger), no two versions have the same options, at most 100 versions. The product's price is the lowest
-- active version price and its stock is the total of the active versions (the same as Seller Center saves).
-- Run once in Supabase → SQL Editor, AFTER 0054_shop_email_default.sql. Safe to run again.

create or replace function public.admin_create_product(p jsonb, p_images text[])
returns bigint language plpgsql security definer set search_path = ''
as $$
declare
  sid uuid; pid bigint; vid bigint; img text; n int := 0; price numeric; sale numeric; cond text;
  vars jsonb := coalesce(p->'variations', '[]'::jsonb); v jsonb; k text; keys text[]; first_keys text[]; okey text;
  vprice numeric; vsale numeric; vstock int; vactive boolean; i int := 0; seen text[] := '{}';
  min_price numeric; total int := 0; is_var boolean;
begin
  if not public.has_staff_role(array['master_admin', 'co_admin', 'editor']) then raise exception 'You don''t have permission to add products'; end if;
  sid := nullif(p->>'seller_id', '')::uuid;
  if sid is null or not exists (select 1 from public.seller_details where user_id = sid and status = 'approved') then
    raise exception 'Choose an approved seller';
  end if;
  if char_length(trim(coalesce(p->>'title', ''))) < 3 then raise exception 'Write the product name'; end if;
  if not exists (select 1 from public.categories where id = (p->>'category_id')::bigint) then raise exception 'Choose a category'; end if;
  cond := coalesce(nullif(p->>'listing_type', ''), 'new');
  if cond not in ('new', 'pre_owned') then raise exception 'Choose New or Pre-owned'; end if;
  if coalesce(array_length(p_images, 1), 0) = 0 then raise exception 'Add at least one photo'; end if;

  if jsonb_typeof(vars) <> 'array' then raise exception 'Versions are not in the right form'; end if;
  is_var := jsonb_array_length(vars) > 0;

  if is_var then
    if jsonb_array_length(vars) > 100 then raise exception 'Up to 100 versions per product'; end if;
    -- check every version first
    for v in select * from jsonb_array_elements(vars) loop
      i := i + 1;
      if jsonb_typeof(v->'options') <> 'object' then raise exception 'Version % has no options', i; end if;
      select array_agg(x order by x::bigint) into keys from jsonb_object_keys(v->'options') x;
      if coalesce(array_length(keys, 1), 0) not between 1 and 3 then raise exception 'Each version needs 1 to 3 options (e.g. size and colour)'; end if;
      if first_keys is null then first_keys := keys;
      elsif keys <> first_keys then raise exception 'All versions must use the same options (e.g. all have a size and a colour)'; end if;
      select string_agg(v->'options'->>x, '-' order by x::bigint) into okey from unnest(keys) x;
      if okey = any(seen) then raise exception 'Two versions have the same options. Each combination only once.'; end if;
      seen := seen || okey;
      vprice := nullif(v->>'price', '')::numeric; vsale := nullif(v->>'sale_price', '')::numeric;
      vstock := coalesce(nullif(v->>'stock', '')::int, 0); vactive := coalesce((v->>'active')::boolean, true);
      if vprice is null or vprice <= 0 then raise exception 'Enter a price for every version'; end if;
      if vsale is not null and (vsale <= 0 or vsale >= vprice) then raise exception 'A version''s sale price must be lower than its price'; end if;
      if vstock < 0 or vstock > 100000 then raise exception 'Check the stock of version %', i; end if;
      if vactive then
        min_price := least(coalesce(min_price, vprice), vprice);
        total := total + vstock;
      end if;
    end loop;
    if min_price is null then raise exception 'Switch on at least one version'; end if;
    price := min_price; sale := null;
  else
    price := nullif(p->>'price', '')::numeric; sale := nullif(p->>'sale_price', '')::numeric;
    if price is null or price <= 0 then raise exception 'Enter a price'; end if;
    if sale is not null and (sale <= 0 or sale >= price) then raise exception 'The sale price must be lower than the price'; end if;
    total := greatest(coalesce(nullif(p->>'stock', '')::int, 1), 0);
  end if;

  insert into public.products (seller_id, category_id, title, description, price, sale_price, stock, manage_stock, listing_type, product_type,
                               price_negotiable, free_delivery, status, reviewed_by, reviewed_at, published_at)
  values (sid, (p->>'category_id')::bigint, trim(p->>'title'), nullif(trim(coalesce(p->>'description', '')), ''), price, sale,
          total, true, cond, case when is_var then 'variable' else 'simple' end,
          coalesce((p->>'price_negotiable')::boolean, false), coalesce((p->>'free_delivery')::boolean, false),
          'approved', auth.uid(), now(), now())
  returning id into pid;

  foreach img in array p_images loop
    if img !~ '^admin/[A-Za-z0-9/_.-]+$' then raise exception 'Photo upload problem. Please try again.'; end if;
    insert into public.product_images (product_id, storage_path, sort_order) values (pid, img, n * 10);
    n := n + 1;
    exit when n >= 8;
  end loop;

  if is_var then
    i := 0;
    for v in select * from jsonb_array_elements(vars) loop
      select string_agg(v->'options'->>x, '-' order by x::bigint) into okey from unnest(first_keys) x;
      insert into public.product_variations (product_id, options_key, price, sale_price, stock, is_active, sort_order)
      values (pid, okey, (v->>'price')::numeric, nullif(v->>'sale_price', '')::numeric, coalesce(nullif(v->>'stock', '')::int, 0),
              coalesce((v->>'active')::boolean, true), i * 10)
      returning id into vid;
      foreach k in array first_keys loop
        insert into public.product_variation_options (variation_id, attribute_id, option_id)
        values (vid, k::bigint, (v->'options'->>k)::bigint);      -- pvo_check: attribute fits the category, option belongs to it
      end loop;
      i := i + 1;
    end loop;
  end if;
  return pid;
end; $$;
revoke execute on function public.admin_create_product(jsonb, text[]) from public, anon;
grant  execute on function public.admin_create_product(jsonb, text[]) to authenticated;

select (select count(*) from pg_proc where proname = 'admin_create_product') as admin_create_product_ready;
