// RGBKart shop pages — shared code: connection, header (cart badge, account), product & category cards, wishlist.
const SUPABASE_URL = 'https://qrzlsomuluglbslricaf.supabase.co';
const SUPABASE_KEY = 'sb_publishable_i-6QX7ObGzF4ykfrgkITsw_HnndqdNY';
const db = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
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
const money = n => '৳' + Number(n || 0).toLocaleString('en-IN', { maximumFractionDigits: 0 });
const imgUrl = path => db.storage.from('product-images').getPublicUrl(path).data.publicUrl;
const CARD_FIELDS = 'id, title, price, sale_price, sale_starts_at, sale_ends_at, product_type, listing_type, is_featured, price_negotiable, free_delivery, seller_id, category_id, published_at, product_images(storage_path, sort_order), product_variations(price, sale_price, is_active)';
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
let hasSession = false;
function headerHTML() {
  return `<header class="top"><div class="wrap top-in">
    <a class="brand" href="index.html" aria-label="Red &amp; Green Basket, RGBKart home"><img src="assets/logo/rgb-basket-96.png" srcset="assets/logo/rgb-basket-96.png 1x, assets/logo/rgb-basket-192.png 2x" alt="" width="44" height="44"><span class="wm"><b><span class="nw"><span class="r">Red</span> <span class="a">&amp;</span> <span class="g">Green</span></span> <span class="y">Basket</span></b><small>Your Online Marketplace</small></span></a>
    <form class="search" action="browse.html" role="search"><input name="q" type="search" placeholder="Search phones, fashion, groceries…" aria-label="Search products" autocomplete="off"><button type="submit">Search</button></form>
    <nav class="nav" aria-label="Account">
      <a class="sell hide-sm" href="sell.html">+ Sell</a>
      <a class="icon-link" href="messages.html" id="msgLink" aria-label="Messages" hidden>${CHAT_SVG}<span class="badge" id="msgCount" hidden></span></a>
      <a class="icon-link" href="browse.html?wishlist=1" id="wishLink" aria-label="Saved items">${HEART_SVG}<span class="badge" id="wishCount" hidden></span></a>
      <a class="icon-link acct" href="login.html" id="acctLink">${USER_SVG}<span class="lbl-acct" id="acctLbl">Sign in</span></a>
      <a class="icon-link" href="cart.html" id="cartLink" aria-label="Cart">${CART_SVG}<span class="lbl-sm">Cart</span><span class="badge" id="cartCount" hidden></span></a>
    </nav></div><div class="rgb" aria-hidden="true"><i></i><i></i><i></i></div></header>`;
}
function footerHTML() {
  return `<footer><div class="wrap"><div><b>RGBKart</b><div>Buy and sell across all 64 districts.</div></div>
    <div><a href="categories.html">All categories</a><a href="browse.html">All products</a><a href="sell.html">Sell an item</a><a href="login.html">Open a shop</a></div></div></footer>
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
}
async function initShell() {
  document.body.insertAdjacentHTML('afterbegin', headerHTML());
  document.body.insertAdjacentHTML('beforeend', footerHTML());
  updateBadges();
  const q = new URLSearchParams(location.search).get('q'); if (q) document.querySelector('.search input').value = q;
  try {
    const { data: { session } } = await db.auth.getSession();
    if (session && !session.user.is_anonymous) $('acctLbl').textContent = 'My account';
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
    price = now.length ? (new Set(now).size > 1 ? 'from ' : '') + money(Math.min(...now)) : money(p.price);
    const best = vs.filter(v => v.sale_price).map(v => Math.round((1 - v.sale_price / v.price) * 100));
    if (best.length) off = Math.max(...best);
  } else if (saleActive(p)) { price = money(p.sale_price); was = money(p.price); off = Math.round((1 - p.sale_price / p.price) * 100); }
  else price = money(p.price);
  const saved = store.get(WISH_KEY).includes(p.id);
  const heart = h('button', { type: 'button', class: 'heart', 'aria-pressed': String(saved), 'aria-label': (saved ? 'Remove from saved: ' : 'Save: ') + p.title });
  heart.innerHTML = HEART_SVG;
  heart.onclick = e => { e.preventDefault(); e.stopPropagation(); const on = toggleWish(p.id); heart.setAttribute('aria-pressed', String(on)); heart.setAttribute('aria-label', (on ? 'Remove from saved: ' : 'Save: ') + p.title); toast(on ? 'Saved ♥' : 'Removed from saved'); };
  return h('a', { class: 'card', href: `product.html?id=${p.id}` },
    h('div', { class: 'img' }, im ? h('img', { src: imgUrl(im.storage_path), alt: '', loading: 'lazy' }) : 'No photo',
      h('div', { class: 'labels' },
        p.is_featured && h('span', { class: 'lab feat', text: '★ Featured' }),
        p.listing_type === 'pre_owned' ? h('span', { class: 'lab used', text: 'Pre-owned' }) : h('span', { class: 'lab new', text: 'New' }),
        off && h('span', { class: 'lab sale', text: `Sale -${off}%` })),
      heart),
    h('div', { class: 'body' },
      h('div', { class: 't', text: p.title }),
      h('div', { class: 'p' }, price, was && h('s', { text: was })),
      h('div', { class: 'm', text: [s && [s.area, s.city].filter(Boolean).join(', '), p.price_negotiable ? 'Negotiable' : p.free_delivery ? 'Free delivery' : null].filter(Boolean).join(' · ') || ' ' })));
}
async function shopsFor(list) {
  const ids = [...new Set(list.map(p => p.seller_id))];
  if (!ids.length) return new Map();
  const r = await db.from('shops').select('user_id, shop_name, city, area').in('user_id', ids);
  return new Map((r.data || []).map(s => [s.user_id, s]));
}
function skeletons(box, n) { box.innerHTML = ''; for (let i = 0; i < n; i++) box.append(h('div', { class: 'skel' })); }

// ---------- category card ----------
function catHue(c, i) { return ((c.sort_order ?? i * 10) * 3.7 + i * 47) % 360; }
function categoryCard(c, i, extra) {
  const img = h('div', { class: 'cimg', 'aria-hidden': 'true' });
  if (/^https?:\/\//.test(c.icon || '')) img.append(h('img', { src: c.icon, alt: '', loading: 'lazy' }));
  else img.append(h('span', { text: c.icon || '🛍️' }));
  const el = h('a', { class: 'ccard', href: `browse.html?c=${encodeURIComponent(c.slug)}`, style: `--hue:${Math.round(catHue(c, i))}` }, img, h('div', { class: 'cname', text: c.name }));
  if (extra) el.append(extra);
  return el;
}

let toastTimer;
function toast(t) {
  let el = $('toast'); if (!el) { el = h('div', { class: 'toast', id: 'toast', role: 'status' }); document.body.append(el); }
  el.textContent = t; el.hidden = false; clearTimeout(toastTimer); toastTimer = setTimeout(() => el.hidden = true, 2200);
}
