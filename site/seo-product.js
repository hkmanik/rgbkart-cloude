// Product page SEO (3 Nov 2026): title, description, canonical, robots, Open Graph / Twitter and Product JSON-LD.
// The same rules run on the server in product.php (Facebook, WhatsApp and other link previews do not run JavaScript),
// so keep the two files in step. RGBSeo.build(P, opt) returns the values; RGBSeo.apply(seo) writes them into <head>,
// updating existing tags (never adding a second canonical, robots or JSON-LD). RGBSeo.noindex() for missing products.
// P = products row with product_images and product_variations; opt = { site, imgUrl(path), shopName, brand, now }.
(function (root) {
  const BRAND = 'DeshiBasket';
  const clean = s => String(s == null ? '' : s).replace(/\s+/g, ' ').trim();
  // Lakh grouping like the visible price (toLocaleString('en-IN')): 24,999 · 1,25,000
  function taka(n) {
    const v = Math.round(Number(n || 0) * 100) / 100;
    let [i, f] = String(Math.abs(v)).split('.');
    const last3 = i.slice(-3), rest = i.slice(0, -3);
    i = (rest ? rest.replace(/\B(?=(\d{2})+(?!\d))/g, ',') + ',' : '') + last3;
    return '৳' + (v < 0 ? '-' : '') + i + (f ? '.' + f : '');
  }
  // Cut at a word, add … ; never longer than max characters
  function cut(s, max) {
    s = clean(s);
    if (s.length <= max) return s;
    let t = s.slice(0, max - 1);
    const sp = t.lastIndexOf(' ');
    if (sp > max * 0.6) t = t.slice(0, sp);
    return t.replace(/[\s,;:.\-–·]+$/, '') + '…';
  }
  const ended = s => /[.!?…]$/.test(s);
  function saleOn(p, now) {
    if (!p.sale_price) return false;
    if (p.sale_starts_at && new Date(p.sale_starts_at).getTime() > now) return false;
    if (p.sale_ends_at && new Date(p.sale_ends_at).getTime() < now) return false;
    return true;
  }
  // Prices exactly as the page shows them (product.html update()): variations use sale_price || price
  function prices(P, now) {
    const vs = (P.product_variations || []).filter(v => v.is_active);
    if (P.product_type === 'variable' && vs.length) return vs.map(v => Number(v.sale_price || v.price));
    return [Number(saleOn(P, now) ? P.sale_price : P.price)];
  }
  // Availability with the same rules as the stock line on the page
  function availability(P) {
    const S = 'https://schema.org/';
    if (P.is_preorder) return S + 'PreOrder';
    if (P.is_service || P.is_downloadable || P.is_gift_card) return S + 'InStock';
    const back = P.backorders && P.backorders !== 'no';
    const vs = (P.product_variations || []).filter(v => v.is_active);
    let n;
    if (P.product_type === 'variable' && vs.length) n = vs.reduce((a, v) => a + Math.max(0, Number(v.stock) || 0), 0);
    else if (P.manage_stock) n = Number(P.stock) || 0;
    else return P.stock_status === 'out_of_stock' ? S + (back ? 'BackOrder' : 'OutOfStock') : P.stock_status === 'on_backorder' ? S + 'BackOrder' : S + 'InStock';
    return n > 0 ? S + 'InStock' : S + (back ? 'BackOrder' : 'OutOfStock');
  }
  const isPublic = P => !!P && P.status === 'approved';

  function build(P, opt) {
    opt = opt || {};
    const now = opt.now != null ? opt.now : Date.now();
    const site = String(opt.site || '').replace(/\/+$/, '');
    const title = clean(P.title);
    const canonical = `${site}/product.html?id=${encodeURIComponent(P.id)}`;
    const imgs = [...(P.product_images || [])].sort((a, b) => a.sort_order - b.sort_order).map(i => opt.imgUrl(i.storage_path));
    const ps = prices(P, now), low = Math.min(...ps), high = Math.max(...ps);
    const used = P.listing_type === 'pre_owned';
    const shop = clean(opt.shopName);

    // Description: "Name from ৳80 at Shop (pre-owned). Seller's words. How to buy." ≤ 160 characters
    let words = clean(P.short_description);
    if (!words || words === clean(P.title_bn) || words === title) words = clean(P.description);
    if (words.toLowerCase().startsWith(title.toLowerCase())) words = clean(words.slice(title.length).replace(/^[\s:–\-·,]+/, ''));
    const priceTxt = (low !== high ? 'from ' : '') + taka(low) + (P.price_negotiable ? ' (negotiable)' : '');
    const head = `${title} ${priceTxt}${shop ? ' at ' + shop : ''}${used ? ' (pre-owned)' : ''}.`;
    const tail = P.contact_only ? `Contact the seller on ${BRAND}.` : `Cash on Delivery on ${BRAND}.`;
    let description = head;
    const room = 160 - head.length - tail.length - 2;
    if (words && room >= 25) { const w = cut(words, room); description += ' ' + w + (ended(w) ? '' : '.'); }
    description = cut(description + ' ' + tail, 160);

    const pageTitle = `${title} | ${BRAND}`;
    const robots = isPublic(P) ? 'index, follow, max-image-preview:large' : 'noindex, nofollow';
    const cond = used ? 'https://schema.org/UsedCondition' : 'https://schema.org/NewCondition';
    const avail = availability(P);
    const seller = shop ? { '@type': 'Organization', name: shop } : undefined;
    const fix = n => Number(n).toFixed(2);
    let offers;
    if (low !== high) offers = { '@type': 'AggregateOffer', priceCurrency: 'BDT', lowPrice: fix(low), highPrice: fix(high), offerCount: ps.length, availability: avail, itemCondition: cond, url: canonical, seller };
    else {
      offers = { '@type': 'Offer', priceCurrency: 'BDT', price: fix(low), availability: avail, itemCondition: cond, url: canonical, seller };
      if (P.product_type !== 'variable' && saleOn(P, now) && P.sale_ends_at) offers.priceValidUntil = String(P.sale_ends_at).slice(0, 10);
    }
    const ld = { '@context': 'https://schema.org', '@type': 'Product', name: title, url: canonical,
      description: cut(P.description || P.short_description || '', 1000) || undefined,
      sku: clean(P.sku) || undefined, image: imgs.slice(0, 10), itemCondition: cond,
      brand: opt.brand ? { '@type': 'Brand', name: clean(opt.brand) } : undefined, offers };
    if (!ld.image.length) delete ld.image;
    // Only real reviews from delivered orders (0029_reviews.sql); the page shows the same stars
    if (Number(P.rating_count) > 0 && Number(P.rating_avg) > 0)
      ld.aggregateRating = { '@type': 'AggregateRating', ratingValue: Number(P.rating_avg).toFixed(1), reviewCount: Number(P.rating_count), bestRating: '5', worstRating: '1' };

    return {
      title: pageTitle, description, canonical, robots, image: imgs[0] || null, imageAlt: title,
      og: { 'og:type': 'product', 'og:title': pageTitle, 'og:description': description, 'og:url': canonical,
        'product:price:amount': fix(low), 'product:price:currency': 'BDT', 'product:condition': used ? 'used' : 'new',
        'product:availability': avail.endsWith('InStock') ? 'in stock' : avail.endsWith('PreOrder') ? 'preorder' : avail.endsWith('BackOrder') ? 'available for order' : 'out of stock' },
      twitter: { 'twitter:card': 'summary_large_image', 'twitter:title': pageTitle, 'twitter:description': description },
      ld: JSON.parse(JSON.stringify(ld)),   // drops undefined keys
    };
  }

  // ---- writing into <head> (browser only) ----
  function meta(attr, key, val) {
    const all = document.head.querySelectorAll(`meta[${attr}="${key}"]`);
    all.forEach((m, i) => { if (i) m.remove(); });
    let m = all[0];
    if (val == null) { if (m) m.remove(); return; }
    if (!m) { m = document.createElement('meta'); m.setAttribute(attr, key); document.head.append(m); }
    m.setAttribute('content', val);
  }
  function link(rel, href) {
    const all = document.head.querySelectorAll(`link[rel="${rel}"]`);
    all.forEach((l, i) => { if (i) l.remove(); });
    let l = all[0];
    if (!l) { l = document.createElement('link'); l.rel = rel; document.head.append(l); }
    l.href = href;
  }
  function apply(s, opt) {
    opt = opt || {};
    if (!opt.keepTitle) document.title = s.title;
    meta('name', 'description', s.description);
    meta('name', 'robots', s.robots);
    link('canonical', s.canonical);
    for (const [k, v] of Object.entries(s.og)) meta('property', k, v);
    for (const [k, v] of Object.entries(s.twitter)) meta('name', k, v);
    if (s.image) {
      meta('property', 'og:image', s.image); meta('property', 'og:image:alt', s.imageAlt);
      meta('property', 'og:image:width', null); meta('property', 'og:image:height', null);   // the 1200×630 size belongs to the default picture
      meta('name', 'twitter:image', s.image);
    }
    document.head.querySelectorAll('script[type="application/ld+json"]').forEach(x => { if (x.id !== 'product-jsonld') x.remove(); });
    let sc = document.getElementById('product-jsonld');
    if (!sc) { sc = document.createElement('script'); sc.type = 'application/ld+json'; sc.id = 'product-jsonld'; document.head.append(sc); }
    sc.textContent = JSON.stringify(s.ld);
  }
  // Missing, private, draft, pending, rejected or hidden products must not be indexed
  function noindex() {
    meta('name', 'robots', 'noindex, nofollow');
    const sc = document.getElementById('product-jsonld'); if (sc) sc.remove();
    document.head.querySelectorAll('link[rel="canonical"]').forEach(l => l.remove());
  }

  root.RGBSeo = { build, apply, noindex, taka, cut, availability, prices, isPublic };
  if (typeof module !== 'undefined') module.exports = root.RGBSeo;
})(typeof window !== 'undefined' ? window : globalThis);
