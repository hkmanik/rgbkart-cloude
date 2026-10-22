# Builds demo_products.sql from demo_spec.py.  Run:  python3 make_demo_sql.py
import json, os
from demo_spec import PRODUCTS, SELLERS

HERE = os.path.dirname(os.path.abspath(__file__))
q = lambda s: 'null' if s is None else "'" + str(s).replace("'", "''") + "'"
DELIV = {'same': 'same_day', 'd35': '3_5_days', 'd610': '6_10_days'}
RET = {'ret0': 'no_returns', 'ret3': '3_days', 'ret15': '15_days', 'ret30': '30_days'}
RET_EN = {'no_returns': 'No returns', '3_days': '3-day returns', '7_days': '7-day returns', '15_days': '15-day returns', '30_days': '30-day returns'}
RET_BN = {'no_returns': 'ফেরত নেওয়া হয় না', '3_days': '৩ দিনের মধ্যে ফেরত', '7_days': '৭ দিনের মধ্যে ফেরত', '15_days': '১৫ দিনের মধ্যে ফেরত', '30_days': '৩০ দিনের মধ্যে ফেরত'}
DIMS = {'small': (12, 8, 4), 'standard': (30, 22, 10), 'large': (60, 45, 35), 'heavy': (90, 70, 60), 'fragile': (50, 35, 20)}

def off(x):          # 15% off, rounded to a friendly price
    v = x * 0.85
    return int(round(v / 10) * 10 - (1 if x >= 1000 else 0)) if x >= 100 else int(round(v))

# Details each sub-category accepts (read from the test copy of the database, which has the same catalog as the live one)
import subprocess
ALLOWED = {}
try:
    rows = subprocess.run(["/usr/lib/postgresql/16/bin/psql", "-h", "/tmp/pgtest", "-p", "5499", "-U", "postgres", "-qAt", "-F", "|", "-c",
        "select c.name, a.name from categories c cross join lateral category_effective_attributes(c.id) e join attributes a on a.id = e.attribute_id where c.parent_id is not null"],
        capture_output=True, text=True, check=True).stdout
    for line in rows.strip().split('\n'):
        c, a = line.split('|'); ALLOWED.setdefault(c, set()).add(a)
except Exception as e:
    print('could not read the test database, keeping all details:', e)

out = []
w = out.append
w("""-- RGBKart DEMO PRODUCTS, for study and testing. Made by supabase/seed/make_demo_sql.py from demo_spec.py.
-- Adds 3 demo sellers (2 shops + 1 one-time seller), one product for every sub-category (100 in all) with every kind of
-- listing: new / pre-owned / free give-away, free / Featured listing, on sale / flash sale, simple / with options
-- (size, colour, storage…), low stock / out of stock / pre-order / back-order, bulk prices, free delivery,
-- Dhaka-only delivery, no cash-on-delivery, a service, price negotiable. Photos are left out on purpose.
-- Also adds demo sections to the home page.
-- Run in Supabase → SQL Editor AFTER 0023_home_section_types.sql. Safe to run again: it first removes the old demo data.
-- To remove everything later, run demo_products_remove.sql.

begin;

-- helpers (only exist while this script runs)
create or replace function pg_temp.cat(p_name text) returns bigint language sql as $$
  select id from public.categories where name = p_name order by parent_id nulls first limit 1 $$;
create or replace function pg_temp.opt(p_attr text, p_value text) returns bigint language sql as $$
  select o.id from public.attribute_options o join public.attributes a on a.id = o.attribute_id
   where a.name = p_attr and o.value = p_value order by a.id limit 1 $$;
create or replace function pg_temp.attr(p_attr text) returns bigint language sql as $$
  select id from public.attributes where name = p_attr order by id limit 1 $$;
create or replace function pg_temp.ok(p_cat bigint, p_attr text) returns boolean language sql as $$
  select exists (select 1 from public.category_effective_attributes(p_cat) e where e.attribute_id = pg_temp.attr(p_attr)) $$;

-- 1. remove the old demo data (if this was run before) -----------------------------------------------------
delete from public.home_sections where subtitle like '%· demo';
delete from auth.users where id in (""" + ', '.join(q(s['id']) for s in SELLERS.values()) + """);

-- 2. demo sellers ------------------------------------------------------------------------------------------
""")
for k, s in SELLERS.items():
    meta = json.dumps({'full_name': s['name']})
    w(f"""insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change)
values ('00000000-0000-0000-0000-000000000000', {q(s['id'])}, 'authenticated', 'authenticated', {q(s['email'])}, '', now(),
  '{{"provider":"email","providers":["email"]}}', {q(meta)}, now() - interval '200 days', now(), '', '', '', '');
insert into public.profiles (id, full_name) values ({q(s['id'])}, {q(s['name'])}) on conflict (id) do nothing;
update public.profiles set role = {q(s['role'])}, full_name = {q(s['name'])}, phone = {q(s['phone'])}, email_alerts = false where id = {q(s['id'])};
insert into public.seller_details (user_id, shop_name, shop_name_bn, shop_description, tagline, business_address, city, area, phone_public, whatsapp, email_public, status, allow_pickup, created_at)
values ({q(s['id'])}, {q(s['name'])}, {q(s['name_bn'])}, {q(s['about'])}, {q(s['tagline'])}, {q(s['address'])}, {q(s['city'])}, {q(s['area'])},
  {q(s['phone'])}, {q(s['whatsapp'])}, {q(s['mail'])}, 'approved', {str(s['pickup']).lower()}, now() - interval '200 days');
""")

w("""
-- 3. products ------------------------------------------------------------------------------------------------
do $$
declare pid bigint; vid bigint; c bigint; missing text := '';
begin
  perform set_config('rgbkart.staff_grant', 'on', true);
""")
for i, p in enumerate(PRODUCTS, 1):
    f = p['flags']; s = SELLERS[p['seller']]
    giveaway = 'giveaway' in f
    listing = 'free' if giveaway else ('pre_owned' if 'used' in f else 'new')
    variable = bool(p['var']) and p['seller'] != 'I'
    price = 0 if giveaway else p['price']
    cls = next((x for x in ('small', 'large', 'heavy', 'fragile') if x in f), 'standard')
    deliv = 'pre_order' if 'preorder' in f else next((DELIV[x] for x in DELIV if x in f), '1_2_days')
    ret = next((RET[x] for x in RET if x in f), '7_days')
    ships = 'inside_dhaka' if 'dhaka' in f else 'outside_dhaka' if 'outside' in f else 'all_bangladesh'
    sale = None; sale_from = sale_to = 'null'
    if not giveaway and ('sale' in f or 'flash' in f):   # for products with options the versions carry the sale price too
        sale = off(price)
        if 'flash' in f: sale_from, sale_to = "now() - interval '1 day'", "now() + interval '2 days'"
    stock, low, backorders, manage = 15 + (i * 7) % 40, 3, 'no', True
    if 'low' in f: stock, low = 2, 5
    if 'oos' in f: stock = 0
    if 'backorder' in f: stock, backorders = 0, 'yes'
    if 'svc' in f: manage, stock = False, 0
    if 'single' in f: stock = min(stock, 5)
    if p['seller'] == 'I' or giveaway: stock = 1
    sku = f'DEMO-{i:03d}'
    d = DIMS[cls]
    feats = p['feats']
    deliv_en = {'same_day': 'Ships today', '1_2_days': 'Ships in 1–2 days', '3_5_days': 'Ships in 3–5 days', '6_10_days': 'Ships in 6–10 days', 'pre_order': 'Pre-order: ships when stock arrives'}[deliv]
    desc = (f"{p['title']}\n\n" + '\n'.join('• ' + x for x in feats) +
            f"\n\nDelivery: {deliv_en}. {RET_EN[ret]}." + (" Free delivery." if 'freedel' in f else '') +
            ("\nPrice is negotiable, message or call the seller." if 'neg' in f else '') +
            "\n\n(Demo product for testing RGBKart. The photos will be added later.)")
    desc_bn = (p['bn_line'] + "\n\n" + f"{RET_BN[ret]}।" + (" ফ্রি ডেলিভারি।" if 'freedel' in f else '') +
               (" দাম আলোচনা সাপেক্ষে।" if 'neg' in f else '') + "\n\n(RGBKart পরীক্ষার জন্য ডেমো পণ্য। ছবি পরে যোগ করা হবে।)")
    tags = ['demo'] + [t for t in p['sub'].lower().replace('&', ' ').replace(',', ' ').replace("'", '').split() if len(t) > 2][:3] + \
           [x for x in ['used' if 'used' in f else 'new', 'sale' if (sale or 'sale' in f or 'flash' in f) else None, 'featured' if ('feat' in f or 'feat1' in f) else None] if x]
    note = None if p['seller'] == 'I' else ('Thank you for your order! Keep the box and invoice for warranty.' if listing == 'new' else 'Check the item when it arrives. Call the shop if anything is wrong.')
    row = {
        'seller_id': q(s['id']), 'category_id': 'c', 'title': q(p['title']), 'title_bn': q(p['bn']),
        'short_description': q(' · '.join(feats)), 'description': q(desc), 'description_bn': q(desc_bn),
        'tags': "array[" + ','.join(q(t) for t in dict.fromkeys(tags)) + "]::text[]",
        'price': str(price), 'sale_price': q(sale) if sale else 'null', 'sale_starts_at': sale_from, 'sale_ends_at': sale_to,
        'sku': q(sku), 'manage_stock': str(manage).lower(), 'stock': str(stock), 'low_stock_threshold': str(low), 'backorders': q(backorders),
        'stock_status': q('out_of_stock' if (stock == 0 and backorders == 'no' and manage and not variable) else 'in_stock'),
        'sold_individually': str('single' in f).lower(), 'weight_kg': str(p['kg']),
        'length_cm': str(d[0]), 'width_cm': str(d[1]), 'height_cm': str(d[2]), 'shipping_class': q(cls),
        'delivery_time': q(deliv), 'ships_to': q(ships), 'free_delivery': str('freedel' in f).lower(), 'return_policy': q(ret),
        'purchase_note': q(note), 'listing_type': q(listing), 'product_type': q('variable' if variable else 'simple'),
        'price_negotiable': str('neg' in f).lower(), 'cod_allowed': str('nocod' not in f).lower(),
        'is_service': str('svc' in f).lower(), 'service_mode': q('at_customer') if 'svc' in f else 'null', 'service_duration': q('2_hours') if 'svc' in f else 'null',
        'is_preorder': str('preorder' in f).lower(), 'preorder_date': "now() + interval '20 days'" if 'preorder' in f else 'null',
        'preorder_advance_percent': '30' if 'preorder' in f else '0',
        'status': q('approved'), 'published_at': f"now() - interval '{i * 9} minutes'", 'created_at': f"now() - interval '{i * 9} minutes'",
    }
    w(f"""  -- {i}. {p['sub']}: {p['title']}  [{' '.join(sorted(f))}{' variable' if variable else ''}]
  c := pg_temp.cat({q(p['sub'])});
  if c is null then missing := missing || {q(p['sub'])} || ', ';
  else begin
    insert into public.products ({', '.join(row)}) values ({', '.join(row.values())}) returning id into pid;
""")
    # details that don't vary
    var_attrs = set(p['var']) if variable else set()
    for a, v in p['attrs'].items():
        if a in var_attrs: continue
        if ALLOWED and a not in ALLOWED.get(p['sub'], set()): continue
        if isinstance(v, bool):
            w(f"    if pg_temp.ok(c, {q(a)}) then insert into public.product_attribute_values (product_id, attribute_id, bool_value) values (pid, pg_temp.attr({q(a)}), {str(v).lower()}); end if;\n")
        else:
            for x in (v if isinstance(v, list) else [v]):
                w(f"    if pg_temp.ok(c, {q(a)}) and pg_temp.opt({q(a)}, {q(x)}) is not null then insert into public.product_attribute_values (product_id, attribute_id, option_id) values (pid, pg_temp.attr({q(a)}), pg_temp.opt({q(a)}, {q(x)})); end if;\n")
    # versions
    if variable:
        import itertools
        names = list(p['var'])
        combos = list(itertools.product(*[p['var'][n] for n in names]))
        for k, combo in enumerate(combos):
            vp = price + sum(p['vprice'].get(x, 0) for x in combo)
            vs = off(vp) if ('sale' in f or 'flash' in f) and k % 2 == 0 else None
            vstock = 0 if 'oos' in f else (2 if 'low' in f and k == 0 else 4 + (i + k * 3) % 18)
            opts = ' and '.join(f"pg_temp.opt({q(n)}, {q(x)}) is not null" for n, x in zip(names, combo))
            key = f"(select string_agg(o::text, '-' order by a) from (values " + ', '.join(f"(pg_temp.attr({q(n)}), pg_temp.opt({q(n)}, {q(x)}))" for n, x in zip(names, combo)) + ") t(a, o))"
            w(f"""    if {opts} then
      insert into public.product_variations (product_id, options_key, sku, price, sale_price, stock, is_active, sort_order)
      values (pid, {key}, {q(sku + '-' + str(k + 1))}, {vp}, {vs if vs else 'null'}, {vstock}, true, {k * 10}) returning id into vid;
      insert into public.product_variation_options (variation_id, attribute_id, option_id) values """ +
              ', '.join(f"(vid, pg_temp.attr({q(n)}), pg_temp.opt({q(n)}, {q(x)}))" for n, x in zip(names, combo)) + ";\n    end if;\n")
    # bulk prices (simple products)
    if 'bulk' in f and not variable and price > 0:
        base = sale or price
        w(f"    insert into public.product_price_tiers (product_id, min_qty, unit_price) values (pid, 3, {round(base * 0.95)}), (pid, 10, {round(base * 0.9)});\n")
    # Featured
    if 'feat' in f or 'feat1' in f:
        ends = "now() + interval '1 day'" if 'feat1' in f else "now() + interval '30 days'"
        starts = "now() - interval '29 days'" if 'feat1' in f else 'now()'
        w(f"""    insert into public.featured_requests (product_id, seller_id, placement, days, price, status, starts_at, ends_at, is_complimentary, note)
    values (pid, {q(s['id'])}, 'home_and_category', 30, 0, 'active', {starts}, {ends}, true, 'Demo data');
    update public.products set is_featured = true where id = pid;
""")
    w(f"  exception when others then missing := missing || {q(p['sub'])} || ' (' || sqlerrm || '), ';\n  end; end if;\n\n")

w("""  perform set_config('rgbkart.staff_grant', 'off', true);
  if missing <> '' then raise notice 'These demo products were skipped: %', missing; end if;
end $$;

-- 4. home page sections (shown after your existing ones) ----------------------------------------------------
insert into public.home_sections (title, title_bn, subtitle, subtitle_bn, section_type, category_id, item_count, sort_order, is_active)
select v.title, v.title_bn, v.subtitle || ' · demo', v.subtitle_bn, v.section_type, pg_temp.cat(v.cat), v.n,
       coalesce((select max(sort_order) from public.home_sections), 0) + v.o, true
from (values
  ('Choose Your Size & Colour', 'সাইজ ও রং বেছে নিন', 'Products with options: size, colour, storage, pack size', 'সাইজ, রং, স্টোরেজ বা প্যাক বেছে নেওয়া যায়', 'variable', null, 12, 10),
  ('Brand New', 'একদম নতুন', 'Unused products with warranty', 'ওয়ারেন্টিসহ অব্যবহৃত পণ্য', 'brand_new', null, 12, 20),
  ('Free Delivery Picks', 'ফ্রি ডেলিভারি', 'No delivery charge on these', 'এগুলোর ডেলিভারি চার্জ নেই', 'free_delivery', null, 12, 30),
  ('Price Negotiable', 'দরদাম করা যাবে', 'Talk to the seller about the price', 'দাম নিয়ে বিক্রেতার সাথে কথা বলুন', 'negotiable', null, 6, 40),
  ('Mobiles & Tablets', 'মোবাইল ও ট্যাবলেট', 'Phones, tablets, chargers and power banks', 'ফোন, ট্যাবলেট, চার্জার ও পাওয়ার ব্যাংক', 'category', 'Mobiles & Tablets', 6, 50),
  ('Fashion for Her', 'মেয়েদের ফ্যাশন', 'Sarees, three-piece, kurtis and more', 'শাড়ি, থ্রি-পিস, কুর্তি ও আরও অনেক কিছু', 'category', 'Women''s Fashion', 6, 60),
  ('Daily Groceries', 'নিত্যদিনের বাজার', 'Rice, oil, snacks and cleaning (Dhaka only)', 'চাল, তেল, স্ন্যাকস ও পরিষ্কারের পণ্য (শুধু ঢাকা)', 'category', 'Groceries', 6, 70),
  ('Home Appliances', 'গৃহস্থালি যন্ত্রপাতি', 'AC, fridge, washing machine and fans', 'এসি, ফ্রিজ, ওয়াশিং মেশিন ও ফ্যান', 'category', 'Home Appliances', 6, 80)
) v(title, title_bn, subtitle, subtitle_bn, section_type, cat, n, o)
where v.cat is null or pg_temp.cat(v.cat) is not null;

commit;

-- 5. check ---------------------------------------------------------------------------------------------------
select (select count(*) from public.products where 'demo' = any(tags) and status = 'approved') as demo_products,
       (select count(*) from public.products where 'demo' = any(tags) and product_type = 'variable') as with_options,
       (select count(*) from public.product_variations v join public.products p on p.id = v.product_id where 'demo' = any(p.tags)) as versions,
       (select count(*) from public.products where 'demo' = any(tags) and is_featured) as featured,
       (select count(*) from public.home_sections where subtitle like '%· demo') as demo_sections;
""")
open(os.path.join(HERE, 'demo_products.sql'), 'w').write(''.join(out))

open(os.path.join(HERE, 'demo_products_remove.sql'), 'w').write("""-- Removes ALL RGBKart demo data added by demo_products.sql: the 3 demo sellers, their 100 products
-- (with versions, Featured, orders and messages about them) and the demo home page sections.
-- Run in Supabase → SQL Editor. Safe to run again.
begin;
delete from public.home_sections where subtitle like '%· demo';
delete from auth.users where id in (""" + ', '.join(q(s['id']) for s in SELLERS.values()) + """);
commit;
select (select count(*) from public.products where 'demo' = any(tags)) as demo_products_left;
""")
print('written', len(PRODUCTS), 'products')
