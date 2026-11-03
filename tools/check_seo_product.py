#!/usr/bin/env python3
"""Checks the product-page SEO rules (3 Nov 2026). Run: python3 tools/check_seo_product.py  (needs node and php).
1. Builds the tags for real products (tools/fixtures/seo_products.json) plus made-up edge cases with
   site/seo-product.js (browser) AND site/product.php (server) and checks both give exactly the same result.
2. Checks each result: unique title and description, description length, clean canonical, robots, Open Graph,
   Product JSON-LD (price, BDT, availability, condition, seller, images, ratings only when real).
3. Puts the tags into the real site/product.html with product.php and checks there is exactly one title,
   description, robots, canonical and JSON-LD, and no leftover 1200×630 size for a product photo.
Exits 1 on any failure."""
import copy, html, json, os, re, subprocess, sys, tempfile
from datetime import datetime

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
SITE = 'https://deshibasket.com'
SB = 'https://qrzlsomuluglbslricaf.supabase.co'
data = json.load(open(os.path.join(ROOT, 'tools', 'fixtures', 'seo_products.json'), encoding='utf-8'))
NOW = datetime.fromisoformat(data['now'].replace('Z', '+00:00')).timestamp()
fails = []
def check(ok, msg):
    if not ok: fails.append(msg)

# ---- cases: real products + edge cases built from them ----
cases = []
for p in data['products']:
    brand = next((v['attribute_options']['value'] for v in p.get('product_attribute_values') or []
                  if 'brand' in (v.get('attributes') or {}).get('name', '').lower()), None)
    cases.append({'name': f"real {p['id']}", 'P': p, 'shop': data['shops'].get(p['seller_id'], ''), 'brand': brand})
byid = {p['id']: p for p in data['products']}
def edge(name, base, brand=None, **chg):
    p = copy.deepcopy(byid[base]); p.update(chg)
    cases.append({'name': name, 'P': p, 'shop': data['shops'][p['seller_id']], 'brand': brand, 'edge': True})
edge('rated', 307, rating_avg=4.36, rating_count=12)
edge('ratings avg but 0 count', 309, rating_avg=4.0, rating_count=0)
edge('pending (not public)', 318, status='pending')
edge('draft (not public)', 318, status='draft')
edge('out of stock, backorders on', 318, stock=0, backorders='notify')
edge('out of stock', 318, stock=0)
edge('stock_status out', 309, stock_status='out_of_stock')
edge('with brand', 307, brand='Xiaomi')
edge('lakh price', 309, price=125000)
edge('long text', 349, short_description='Lorem ' * 120, title='A ' * 3 + 'Very Long Product Title With Many Words For Testing Cuts')
edge('no photos', 352, product_images=[])
edge('script in title', 352, title='Watch </script><script>alert(1)</script> & "quotes"')

# ---- 1. browser builder (node) ----
js = r"""
const S = require(process.argv[1] + '/site/seo-product.js');
const cases = JSON.parse(require('fs').readFileSync(0, 'utf8'));
const SB = 'https://qrzlsomuluglbslricaf.supabase.co';
const img = p => SB + '/storage/v1/object/public/product-images/' + encodeURIComponent(p).replace(/%2F/g, '/');
console.log(JSON.stringify(cases.map(c => S.build(c.P, { site: 'https://deshibasket.com', imgUrl: img, shopName: c.shop, brand: c.brand, now: c.now * 1000 }))));
"""
for c in cases: c['now'] = NOW
node = subprocess.run(['node', '-e', js, ROOT], input=json.dumps(cases), capture_output=True, text=True)
if node.returncode: sys.exit('node failed: ' + node.stderr)
js_out = json.loads(node.stdout)

# ---- 1. server builder (php) ----
php = r"""<?php
define('SEO_NO_RUN', true);
ob_start(); require $argv[1] . '/site/product.php'; ob_end_clean();
$cases = json_decode(file_get_contents('php://stdin'), true);
$out = [];
foreach ($cases as $c) $out[] = seo_build($c['P'], ['site' => 'https://deshibasket.com', 'sb' => $SB, 'shopName' => $c['shop'], 'brand' => $c['brand'], 'now' => (int)$c['now']]);
echo json_encode($out, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
"""
with tempfile.NamedTemporaryFile('w', suffix='.php', delete=False) as f: f.write(php); phpf = f.name
pr = subprocess.run(['php', phpf, ROOT], input=json.dumps(cases), capture_output=True, text=True)
if pr.returncode or not pr.stdout.startswith('['): sys.exit('php failed: ' + pr.stdout[:500] + pr.stderr)
php_out = json.loads(pr.stdout)

def norm(x):   # PHP json has [] for empty lists the same as JS; normalise number types only
    return json.loads(json.dumps(x, sort_keys=True))
for c, a, b in zip(cases, js_out, php_out):
    check(norm(a) == norm(b), f"{c['name']}: browser and server differ\n  js : {json.dumps(a, ensure_ascii=False)}\n  php: {json.dumps(b, ensure_ascii=False)}")

# ---- 2. rules ----
AV = {'https://schema.org/' + x for x in ('InStock', 'OutOfStock', 'PreOrder', 'BackOrder')}
for c, s in zip(cases, js_out):
    P, n, ld = c['P'], c['name'], s['ld']
    public = P['status'] == 'approved'
    check(s['title'] == re.sub(r'\s+', ' ', P['title']).strip() + ' | DeshiBasket', f'{n}: title {s["title"]!r}')
    check(40 <= len(s['description']) <= 160, f'{n}: description length {len(s["description"])}')
    check(re.sub(r'\s+', ' ', P['title']).strip().split(' ')[0] in s['description'], f'{n}: description lacks the product name')
    check('Product details, price, delivery' not in s['description'], f'{n}: generic description')
    check('..' not in s['description'], f'{n}: double full stop')
    check(s['canonical'] == f"{SITE}/product.html?id={P['id']}", f'{n}: canonical {s["canonical"]}')
    check(s['robots'] == ('index, follow, max-image-preview:large' if public else 'noindex, nofollow'), f'{n}: robots {s["robots"]}')
    check(s['og']['og:url'] == s['canonical'] and s['og']['og:title'] == s['title'] and s['og']['og:description'] == s['description'], f'{n}: og tags')
    check(s['og']['og:type'] == 'product' and s['og']['product:price:currency'] == 'BDT', f'{n}: og type/currency')
    imgs = P.get('product_images') or []
    check((s['image'] is None) == (not imgs), f'{n}: og:image presence')
    if imgs:
        first = sorted(imgs, key=lambda i: i['sort_order'])[0]['storage_path']
        check(s['image'].startswith(SB + '/storage/v1/object/public/product-images/') and s['image'].endswith(first.split('/')[-1]), f'{n}: og:image is not the first photo')
        check(ld.get('image', [None])[0] == s['image'], f'{n}: JSON-LD image[0] differs from og:image')
    # JSON-LD
    check(ld['@context'] == 'https://schema.org' and ld['@type'] == 'Product' and ld['name'], f'{n}: JSON-LD type/name')
    o = ld['offers']
    check(o['priceCurrency'] == 'BDT', f'{n}: currency')
    check(o['availability'] in AV, f'{n}: availability {o["availability"]}')
    check(o['url'] == s['canonical'], f'{n}: offer url')
    check(ld['itemCondition'] == o['itemCondition'] == ('https://schema.org/UsedCondition' if P['listing_type'] == 'pre_owned' else 'https://schema.org/NewCondition'), f'{n}: condition')
    check(o.get('seller', {}).get('name') == c['shop'], f'{n}: seller')
    # prices must equal what the page shows (product.html update())
    vs = [v for v in P.get('product_variations') or [] if v['is_active']]
    if P['product_type'] == 'variable' and vs: shown = [float(v['sale_price'] or v['price']) for v in vs]
    else:
        sale = P['sale_price'] and (not P['sale_starts_at'] or datetime.fromisoformat(P['sale_starts_at']).timestamp() <= NOW) and (not P['sale_ends_at'] or datetime.fromisoformat(P['sale_ends_at']).timestamp() >= NOW)
        shown = [float(P['sale_price'] if sale else P['price'])]
    if min(shown) == max(shown):
        check(o['@type'] == 'Offer' and float(o['price']) == shown[0], f'{n}: price {o.get("price")} vs shown {shown[0]}')
    else:
        check(o['@type'] == 'AggregateOffer' and float(o['lowPrice']) == min(shown) and float(o['highPrice']) == max(shown), f'{n}: price range')
    for k in ('price', 'lowPrice', 'highPrice'):
        if k in o: check(re.fullmatch(r'\d+\.\d\d', o[k]) is not None, f'{n}: {k} format {o[k]}')
    # ratings: only real ones
    if P.get('rating_count') and P.get('rating_avg'):
        r = ld.get('aggregateRating') or {}
        check(r.get('reviewCount') == P['rating_count'] and abs(float(r.get('ratingValue', 0)) - float(P['rating_avg'])) < 0.06, f'{n}: rating')
    else:
        check('aggregateRating' not in ld, f'{n}: rating published without reviews')
    if P.get('sku'): check(ld.get('sku') == P['sku'], f'{n}: sku')
    else: check('sku' not in ld, f'{n}: empty sku published')
    check(('brand' in ld) == bool(c['brand']), f'{n}: brand')

real = [s for c, s in zip(cases, js_out) if not c.get('edge')]
check(len({s['title'] for s in real}) == len(real), 'titles are not unique')
check(len({s['description'] for s in real}) == len(real), 'descriptions are not unique')
check(len({s['canonical'] for s in real}) == len(real), 'canonicals are not unique')

# ---- 3. the real page through product.php ----
render = r"""<?php
define('SEO_NO_RUN', true);
ob_start(); require $argv[1] . '/site/product.php'; ob_end_clean();
$c = json_decode(file_get_contents('php://stdin'), true);
$s = seo_build($c['P'], ['site' => 'https://deshibasket.com', 'sb' => $SB, 'shopName' => $c['shop'], 'brand' => $c['brand'], 'now' => (int)$c['now']]);
$html = file_get_contents($argv[1] . '/site/product.html');
echo $c['P']['status'] === 'approved' ? seo_head($html, $s) : seo_noindex_head($html);
"""
with tempfile.NamedTemporaryFile('w', suffix='.php', delete=False) as f: f.write(render); renf = f.name
pages = {}
original = open(os.path.join(ROOT, 'site', 'product.html'), encoding='utf-8').read()
for c, s in zip(cases, js_out):
    out = subprocess.run(['php', renf, ROOT], input=json.dumps(c), capture_output=True, text=True).stdout
    n = c['name']; head, body = out.split('</head>', 1)
    check(body == original.split('</head>', 1)[1], f'{n}: page body changed')
    cnt = lambda pat: len(re.findall(pat, head))
    if c['P']['status'] == 'approved':
        t = re.findall(r'<title>(.*?)</title>', head, re.S)
        check(len(t) == 1 and html.unescape(t[0]) == s['title'] and '<' not in t[0], f'{n}: page title {t}')
        for pat, what in [(r'<meta name="description"', 'description'), (r'<meta name="robots"', 'robots'), (r'<link rel="canonical"', 'canonical'),
                          (r'application/ld\+json', 'JSON-LD'), (r'property="og:title"', 'og:title'), (r'property="og:url"', 'og:url'),
                          (r'property="og:type" content="product"', 'og:type'), (r'name="twitter:card"', 'twitter:card')]:
            check(cnt(pat) == 1, f'{n}: {what} appears {cnt(pat)} times')
        if s['image']: check(cnt(r'og:image:width') == 0 and cnt(r'property="og:image"') == 1, f'{n}: og:image tags')
        m = re.search(r'<script type="application/ld\+json" id="product-jsonld">(.*?)</script>', head, re.S)
        check(m and norm(json.loads(m.group(1))) == norm(s['ld']), f'{n}: JSON-LD in page differs or is not valid JSON')
        check('</script><script>' not in (m.group(1) if m else ''), f'{n}: JSON-LD not escaped')
        pages[c['P']['id']] = out
    else:
        check(cnt(r'<meta name="robots" content="noindex, nofollow">') == 1 and cnt(r'application/ld\+json') == 0, f'{n}: noindex page')
for pid, out in pages.items():
    open(os.path.join(tempfile.gettempdir(), f'seo_page_{pid}.html'), 'w', encoding='utf-8').write(out)

# ---- report ----
for c, s in zip(cases, js_out):
    if not c.get('edge'):
        print(f"{c['P']['id']}  {s['title']}\n     {s['description']}  ({len(s['description'])})\n     {s['canonical']} · {s['robots']} · {s['ld']['offers']['@type']} {s['ld']['offers'].get('price') or s['ld']['offers'].get('lowPrice') + '–' + s['ld']['offers'].get('highPrice')} · {s['ld']['offers']['availability'].split('/')[-1]}")
print(f'\n{len(cases)} cases ({len(real)} real products), browser = server for all: {not any("differ" in f for f in fails)}')
if fails:
    print('\nFAILED:'); [print(' -', f) for f in fails]; sys.exit(1)
print('All checks passed.')
