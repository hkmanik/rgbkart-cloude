#!/usr/bin/env python3
"""Run by the deploy workflow before uploading site/.
1. Puts the real web address into the pages (replaces %%SITE%% in .html, robots.txt and the manifest).
2. Writes site/sitemap.xml with the home page, categories, live products, shops and information pages,
   read from Supabase with the public (publishable) key, so Google can find every page.
Set the repository variable SITE_URL when the real domain is ready (default: the demo subdomain)."""
import json, os, re, sys, urllib.request
from datetime import datetime, timezone
from xml.sax.saxutils import escape

SITE = (os.environ.get('SITE_URL') or 'https://rgbkart.com').rstrip('/')
SB = 'https://qrzlsomuluglbslricaf.supabase.co'
KEY = 'sb_publishable_i-6QX7ObGzF4ykfrgkITsw_HnndqdNY'
ROOT = os.path.join(os.path.dirname(__file__), '..', 'site')

# 1. web address
for name in os.listdir(ROOT):
    if name.endswith(('.html', '.txt', '.webmanifest', '.php')):
        p = os.path.join(ROOT, name)
        s = open(p, encoding='utf-8').read()
        if '%%SITE%%' in s:
            open(p, 'w', encoding='utf-8').write(s.replace('%%SITE%%', SITE))

# 2. sitemap
def fetch(path):
    rows, start = [], 0
    while True:
        req = urllib.request.Request(f'{SB}/rest/v1/{path}', headers={'apikey': KEY, 'Authorization': f'Bearer {KEY}', 'Range': f'{start}-{start + 999}'})
        try:
            with urllib.request.urlopen(req, timeout=30) as r:
                part = json.load(r)
        except Exception as e:
            print('sitemap: could not read', path.split('?')[0], e, file=sys.stderr)
            return rows
        rows += part
        if len(part) < 1000 or start > 100000:
            return rows
        start += 1000

def day(v):
    return (v or '')[:10] or datetime.now(timezone.utc).strftime('%Y-%m-%d')

urls = [(f'{SITE}/', None, '1.0'), (f'{SITE}/categories.html', None, '0.8'), (f'{SITE}/browse.html', None, '0.8')]
for c in fetch('categories?select=slug&is_active=eq.true&order=sort_order'):
    urls.append((f"{SITE}/browse.html?c={c['slug']}", None, '0.7'))
for p in fetch('products?select=id,updated_at&status=eq.approved&order=id'):
    urls.append((f"{SITE}/product.html?id={p['id']}", day(p.get('updated_at')), '0.6'))
for s in fetch('shops?select=user_id,shop_slug'):
    urls.append((f"{SITE}/store.html?s={s.get('shop_slug') or s['user_id']}", None, '0.5'))
for pg in fetch('site_pages?select=slug,updated_at&is_active=eq.true'):
    urls.append((f"{SITE}/page.html?p={pg['slug']}", day(pg.get('updated_at')), '0.3'))

out = ['<?xml version="1.0" encoding="UTF-8"?>', '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">']
for loc, mod, pri in urls:
    out.append(f'  <url><loc>{escape(loc)}</loc>' + (f'<lastmod>{mod}</lastmod>' if mod else '') + f'<priority>{pri}</priority></url>')
out.append('</urlset>')
open(os.path.join(ROOT, 'sitemap.xml'), 'w', encoding='utf-8').write('\n'.join(out) + '\n')
print(f'sitemap.xml: {len(urls)} addresses for {SITE}')
