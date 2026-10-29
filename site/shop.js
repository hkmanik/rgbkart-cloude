// RGBKart shop pages — shared code: connection, header (cart badge, account), product & category cards, wishlist.
const SUPABASE_URL = 'https://qrzlsomuluglbslricaf.supabase.co';
const SUPABASE_KEY = 'sb_publishable_i-6QX7ObGzF4ykfrgkITsw_HnndqdNY';
const db = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
if (window.RGBSync) RGBSync.start(db);   // wishlist & cart in the account (sync.js, 0031)
const $ = id => document.getElementById(id);
function h(tag, props, ...kids) {
  const el = document.createElement(tag);
  for (const [k, v] of Object.entries(props || {})) {
    if (v == null || v === false) continue;
    if (k.startsWith('on')) el[k] = v; else if (k === 'class') el.className = v; else if (k === 'text') el.textContent = v; else el.setAttribute(k, v === true ? '' : v);
  }
  for (const kid of kids.flat()) if (kid != null && kid !== false) el.append(kid);
  return el;
}
const money = n => '৳' + N(Number(n || 0).toLocaleString('en-IN', { maximumFractionDigits: 0 }));
const imgUrl = path => db.storage.from('product-images').getPublicUrl(path).data.publicUrl;
const CARD_FIELDS = 'id, title, title_bn, price, sale_price, sale_starts_at, sale_ends_at, product_type, listing_type, is_featured, price_negotiable, free_delivery, seller_id, category_id, published_at, rating_avg, rating_count, product_images(storage_path, sort_order), product_variations(price, sale_price, is_active)';
const CART_KEY = 'rgbkart-cart', WISH_KEY = 'rgbkart-wishlist';
const store = {
  get(k) { try { return JSON.parse(localStorage.getItem(k) || '[]'); } catch (_) { return []; } },
  set(k, v) { try { localStorage.setItem(k, JSON.stringify(v)); } catch (_) {} },
};

// ---------- header ----------
const CART_SVG = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="20" r="1.5"/><circle cx="18" cy="20" r="1.5"/><path d="M2.5 3h2.6l2.4 11.2a1.5 1.5 0 0 0 1.5 1.2h8.7a1.5 1.5 0 0 0 1.5-1.1L21 7H6"/></svg>';
const HEART_SVG = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1-1.1a5.5 5.5 0 0 0-7.8 7.8l1 1.1L12 21l7.8-7.5 1-1.1a5.5 5.5 0 0 0 0-7.8z"/></svg>';
const USER_SVG = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/></svg>';
const CHAT_SVG = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 12a8 8 0 0 1-11.6 7.1L4 20.5l1.4-4.9A8 8 0 1 1 21 12z"/></svg>';
const BELL_SVG = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.9 1.9 0 0 0 3.4 0"/></svg>';
let hasSession = false;
function headerHTML() {
  return `<header class="top"><div class="wrap top-in">
    <a class="brand" href="index.html" aria-label="Red &amp; Green Basket, RGBKart home"><img src="assets/logo/rgb-basket-96.png" srcset="assets/logo/rgb-basket-96.png 1x, assets/logo/rgb-basket-192.png 2x" alt="" width="44" height="44"><span class="wm"><b translate="no"><span class="nw"><span class="r">Red</span> <span class="a">&amp;</span> <span class="g">Green</span></span> <span class="y">Basket</span></b><small>Your Online Marketplace</small></span></a>
    <form class="search" action="browse.html" role="search"><input name="q" type="search" placeholder="Search products, shops, categories…" aria-label="Search products, shops and categories" autocomplete="off"><button type="submit">Search</button></form>
    <nav class="nav" aria-label="Account">
      <a class="sell hide-sm" href="sell.html">+ Sell</a>
      <a class="icon-link" href="messages.html" id="msgLink" aria-label="Messages" hidden>${CHAT_SVG}<span class="badge" id="msgCount" hidden></span></a>
      <a class="icon-link" href="alerts.html" id="bellLink" aria-label="Alerts" hidden>${BELL_SVG}<span class="badge" id="bellCount"></span></a>
      <a class="icon-link" href="browse.html?wishlist=1" id="wishLink" aria-label="Saved items">${HEART_SVG}<span class="badge" id="wishCount" hidden></span></a>
      <a class="open-shop" href="login.html?as=seller" id="openShop" aria-label="Open a shop"><span aria-hidden="true">🏪</span> <span class="lbl-full">Open a shop</span><span class="lbl-short">Open shop</span><span class="lbl-tiny">Shop</span></a>
      <a class="icon-link acct" href="login.html?as=customer" id="acctLink">${USER_SVG}<span class="lbl-acct" id="acctLbl">Buy · Sign in</span></a>
      <a class="icon-link" href="cart.html" id="cartLink" aria-label="Cart">${CART_SVG}<span class="lbl-sm">Cart</span><span class="badge" id="cartCount" hidden></span></a>
    </nav></div><div class="rgb" aria-hidden="true"><i></i><i></i><i></i></div></header>`;
}
function footerHTML() {
  return `<footer><div class="wrap"><div><b>RGBKart</b><div>Buy and sell across all 64 districts.</div></div>
    <div><span data-lang-switch="on-dark"></span><a href="categories.html">All categories</a><a href="browse.html">All products</a><a href="orders.html">My orders</a><a href="alerts.html">Alerts</a><a href="sell.html">Sell an item</a><a href="login.html">Open a shop</a></div></div></footer>
    <a class="fab" href="sell.html">+ Sell</a>`;
}
function updateBadges() {
  const n = store.get(CART_KEY).reduce((s, i) => s + i.qty, 0);
  const c = $('cartCount'); if (c) { c.hidden = !n; c.textContent = n > 99 ? '99+' : n; }
  const w = store.get(WISH_KEY).length;
  const wc = $('wishCount'); if (wc) { wc.hidden = !w; wc.textContent = w; }
  const cl = $('cartLink'); if (cl) cl.setAttribute('aria-label', n ? `Cart, ${n} item${n === 1 ? '' : 's'}` : 'Cart');
  if (hasSession && $('msgCount')) db.rpc('my_unread_count').then(r => {
    const m = r.error ? 0 : r.data, el = $('msgCount');
    el.hidden = !m; el.textContent = m > 99 ? '99+' : m;
    $('msgLink').setAttribute('aria-label', m ? `Messages, ${m} new` : 'Messages');
  });
  // the bell shows only while there are new alerts
  if (hasSession && $('bellLink')) db.rpc('my_alert_count').then(r => {
    const a = r.error ? 0 : r.data, el = $('bellLink');
    el.hidden = !a; $('bellCount').textContent = a > 99 ? '99+' : a;
    el.setAttribute('aria-label', `Alerts, ${a} new`);
  });
}
// Policy / info pages in the footer (0039_site_pages.sql, edited in Admin → Pages)
function footerPages() {
  const ft = document.querySelector('footer .wrap'); if (!ft) return;
  db.from('site_pages').select('slug, title, title_bn').eq('in_footer', true).eq('is_active', true).order('sort_order').then(r => {
    if (r.error || !r.data || !r.data.length) return;
    const row = h('nav', { class: 'foot-pages', 'aria-label': T('Information') }, r.data.map(p => h('a', { href: 'page.html?p=' + encodeURIComponent(p.slug), text: L(p, 'title') })));
    ft.after(row);
  }, () => {});
}
async function initShell() {
  document.body.insertAdjacentHTML('afterbegin', headerHTML());
  document.body.insertAdjacentHTML('beforeend', footerHTML());
  footerPages();
  if (window.RGBLang) RGBLang.mountSwitches();
  if (window.RGBMenu) RGBMenu.mount();
  trackVisit();
  updateBadges();
  const q = new URLSearchParams(location.search).get('q'); if (q) document.querySelector('.search input').value = q;
  try {
    const { data: { session } } = await db.auth.getSession();
    if (session && !session.user.is_anonymous) { $('acctLbl').textContent = T('My account'); $('acctLink').href = 'account.html'; if ($('openShop')) $('openShop').hidden = true; }
    if (session) { hasSession = true; $('msgLink').hidden = false; updateBadges(); }
  } catch (_) {}
}
window.addEventListener('storage', updateBadges);

// ---------- product card ----------
function saleActive(p) {
  if (!p.sale_price) return false;
  const now = Date.now();
  return !(p.sale_starts_at && new Date(p.sale_starts_at) > now) && !(p.sale_ends_at && new Date(p.sale_ends_at) < now);
}
function toggleWish(id) {
  const w = store.get(WISH_KEY); const i = w.indexOf(id);
  if (i >= 0) w.splice(i, 1); else w.unshift(id);
  store.set(WISH_KEY, w); updateBadges();
  return i < 0;
}
function card(p, shops) {
  const im = [...(p.product_images || [])].sort((a, b) => a.sort_order - b.sort_order)[0];
  const s = shops && shops.get(p.seller_id);
  let price, was = null, off = null;
  if (p.product_type === 'variable') {
    const vs = (p.product_variations || []).filter(v => v.is_active);
    const now = vs.map(v => v.sale_price || v.price);
    price = now.length ? (new Set(now).size > 1 ? T('from {p}', { p: money(Math.min(...now)) }) : money(Math.min(...now))) : money(p.price);
    // the cheapest version on sale → show its normal price crossed out
    const cheap = vs.slice().sort((a, b) => (a.sale_price || a.price) - (b.sale_price || b.price))[0];
    if (cheap && cheap.sale_price && Number(cheap.sale_price) < Number(cheap.price)) was = money(cheap.price);
    const best = vs.filter(v => v.sale_price).map(v => Math.round((1 - v.sale_price / v.price) * 100));
    if (best.length) off = Math.max(...best);
  } else if (saleActive(p)) { price = money(p.sale_price); was = money(p.price); off = Math.round((1 - p.sale_price / p.price) * 100); }
  else price = money(p.price);
  const saved = store.get(WISH_KEY).includes(p.id);
  const title = L(p, 'title');
  const heart = h('button', { type: 'button', class: 'heart', 'aria-pressed': String(saved), 'aria-label': T(saved ? 'Remove from saved: {t}' : 'Save: {t}', { t: title }) });
  heart.innerHTML = HEART_SVG;
  heart.onclick = e => { e.preventDefault(); e.stopPropagation(); const on = toggleWish(p.id); heart.setAttribute('aria-pressed', String(on)); heart.setAttribute('aria-label', T(on ? 'Remove from saved: {t}' : 'Save: {t}', { t: title })); toast(on ? 'Saved ♥' : 'Removed from saved'); };
  return h('a', { class: 'card', href: `product.html?id=${p.id}` },
    h('div', { class: 'img' }, im ? h('img', { src: imgUrl(im.storage_path), alt: '', loading: 'lazy' }) : 'No photo',
      h('div', { class: 'labels' },
        p.is_featured && h('span', { class: 'lab feat', text: '★ Featured' }),
        p.listing_type === 'pre_owned' ? h('span', { class: 'lab used', text: 'Pre-owned' }) : h('span', { class: 'lab new', text: 'New' }),
        off && h('span', { class: 'lab sale', text: T('Sale -{n}%', { n: off }) })),
      heart),
    h('div', { class: 'body' },
      h('div', { class: 't', text: title, translate: 'no' }),
      h('div', { class: 'p' }, price, was && h('s', { text: was })),
      ratingLine(p),
      h('div', { class: 'm', text: [s && [s.area, s.city && RGBLang.tr(s.city)].filter(Boolean).join(', '), p.price_negotiable ? T('Negotiable') : p.free_delivery ? T('Free delivery') : null].filter(Boolean).join(' · ') || ' ' })));
}
// ---------- stars (reviews & ratings, 0029) ----------
function starsEl(avg) {
  const r = Math.max(0, Math.min(5, Number(avg) || 0));
  return h('span', { class: 'stars', style: `--r:${r}`, role: 'img', 'aria-label': T('Rated {a} out of 5', { a: r.toFixed(1) }), text: '★★★★★' });
}
function ratingLine(x, cls) {
  if (!x || !x.rating_count) return null;
  return h('span', { class: 'rt' + (cls ? ' ' + cls : '') }, starsEl(x.rating_avg), h('b', { text: N(Number(x.rating_avg).toFixed(1)) }), h('span', { text: `(${N(x.rating_count)})` }));
}
// Clickable 1–5 stars; returns the element, with .value and an onchange callback
function starInput(value, onchange) {
  const el = h('span', { class: 'star-in', role: 'radiogroup', 'aria-label': T('Your rating') });
  const names = ['', 'Poor', 'Fair', 'Good', 'Very good', 'Excellent'];
  el.value = value || 0;
  const btns = [1, 2, 3, 4, 5].map(n => h('button', { type: 'button', role: 'radio', 'aria-label': T('{n} stars', { n }) + ' · ' + T(names[n]), title: T(names[n]), text: '★',
    onclick: () => { el.value = n; paint(); onchange && onchange(n); } }));
  function paint() { btns.forEach((b, i) => { b.classList.toggle('on', i < el.value); b.setAttribute('aria-checked', String(i + 1 === el.value)); }); }
  el.append(...btns); paint();
  return el;
}
async function shopsFor(list) {
  const ids = [...new Set(list.map(p => p.seller_id))];
  if (!ids.length) return new Map();
  const r = await db.from('shops').select('user_id, shop_name, shop_name_bn, city, area').in('user_id', ids);
  return new Map((r.data || []).map(s => [s.user_id, s]));
}
function skeletons(box, n) { box.innerHTML = ''; for (let i = 0; i < n; i++) box.append(h('div', { class: 'skel' })); }

// ---------- category card ----------
function catHue(c, i) { return ((c.sort_order ?? i * 10) * 3.7 + i * 47) % 360; }
function categoryCard(c, i, extra) {
  const img = h('div', { class: 'cimg', 'aria-hidden': 'true' });
  const pic = c.image_url || (/^https?:\/\//.test(c.icon || '') ? c.icon : null);   // picture from Admin → Categories, else the emoji
  if (pic) img.append(h('img', { src: pic, alt: '', loading: 'lazy', onerror: e => e.target.replaceWith(h('span', { text: c.icon && !/^https?:/.test(c.icon) ? c.icon : '🛍️' })) }));
  else img.append(h('span', { text: c.icon || '🛍️' }));
  const el = h('a', { class: 'ccard', href: `browse.html?c=${encodeURIComponent(c.slug)}`, style: `--hue:${Math.round(catHue(c, i))}` }, img, h('div', { class: 'cname', text: L(c, 'name') }));
  if (extra) el.append(extra);
  return el;
}

// ---------- visitor counting (ads are in ads.js) ----------
function trackVisit() {
  try {
    let id = localStorage.getItem('rgbkart-visitor');
    if (!id) { id = Array.from(crypto.getRandomValues(new Uint8Array(12)), b => b.toString(36).padStart(2, '0')).join('').slice(0, 20); localStorage.setItem('rgbkart-visitor', id); }
    const path = (location.pathname.split('/').pop() || 'index.html');
    db.rpc('track_visit', { p_visitor: id, p_path: path }).then(() => {}, () => {});
  } catch (_) {}
}

let toastTimer;
function toast(t) {
  let el = $('toast'); if (!el) { el = h('div', { class: 'toast', id: 'toast', role: 'status' }); document.body.append(el); }
  el.textContent = t; el.hidden = false; clearTimeout(toastTimer); toastTimer = setTimeout(() => el.hidden = true, 2200);
}
