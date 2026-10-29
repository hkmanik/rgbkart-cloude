// Ads on shop pages (owner, 29 Oct 2026). Ads are made in Admin → Payment requests → Advertisements (or booked by shops);
// the spaces, picture sizes and prices are in Admin → Payments → Rates (0060_ad_spaces.sql).
//   RGBAds.slot(placement, holder)  banner in a page spot: home_top, home_mid, cat_top, cat_side, product_side
//   Pop-ups start by themselves on pages that load this file:
//     popup_main  one big picture in the middle of the home page, once per visit, ✕ / Esc / tap outside to close
//     popup_side  up to 3 small pictures in the bottom-right corner (1 on phones), each with ✕; closed ones stay closed this visit
// An ad with a picture shows only the picture (a ready-made banner). Without a picture, banners show the headline and button.
// Needs the page's `db` (Supabase). Load after the page's own script setup; it waits for `db` to exist.
(function () {
  const CSS = `
  .adimg { position: relative; display: block; border-radius: 14px; overflow: hidden; line-height: 0; transition: transform .18s, box-shadow .18s; background: #eef2ef; }
  .adimg:hover { transform: translateY(-2px); box-shadow: 0 10px 24px rgb(0 0 0 / .15); }
  .adimg img { width: 100%; height: auto; display: block; }
  .adimg .adtag { position: absolute; top: 6px; right: 8px; line-height: 1.4; font: 700 .6rem system-ui, sans-serif; letter-spacing: .06em; text-transform: uppercase; background: rgb(0 0 0 / .45); color: #fff; padding: 1px 6px; border-radius: 4px; }
  .adimg.product_side { margin-top: 12px; }
  .adpop-scrim { position: fixed; inset: 0; background: rgb(0 0 0 / .55); z-index: 90; display: grid; place-items: center; padding: 16px; animation: adFade .2s ease-out; }
  .adpop { position: relative; width: min(600px, 100%); max-height: calc(100vh - 32px); }
  .adpop .adimg { border-radius: 16px; box-shadow: 0 20px 50px rgb(0 0 0 / .35); }
  .adpop .adimg img { max-height: calc(100vh - 32px); object-fit: contain; background: #fff; }
  .adx { position: absolute; top: -12px; right: -12px; width: 36px; height: 36px; border-radius: 50%; border: 2px solid #fff; background: #14211C; color: #fff; font: 700 1rem/1 system-ui, sans-serif; cursor: pointer; display: grid; place-items: center; z-index: 2; box-shadow: 0 2px 8px rgb(0 0 0 / .3); }
  .adx:hover { background: #E30613; }
  .adside { position: fixed; right: 14px; bottom: 90px; z-index: 60; display: grid; gap: 12px; width: 210px; }
  .adside .adone { position: relative; animation: adSlide .3s ease-out; }
  .adside .adimg { border-radius: 12px; box-shadow: 0 8px 24px rgb(0 0 0 / .25); }
  .adside .adx { width: 28px; height: 28px; top: -10px; right: -10px; font-size: .85rem; }
  @media (max-height: 820px) { .adside .adone:nth-child(3) { display: none; } }
  @media (max-width: 640px) { .adside { width: 150px; right: 12px; bottom: 84px; } .adside .adone ~ .adone { display: none; } }
  @keyframes adFade { from { opacity: 0; } } @keyframes adSlide { from { opacity: 0; transform: translateY(16px); } }
  @media (prefers-reduced-motion: reduce) { .adpop-scrim, .adside .adone { animation: none; } .adimg { transition: none; } }`;
  const getDb = () => (typeof db !== 'undefined' ? db : null);
  const pub = p => getDb().storage.from('product-images').getPublicUrl(p).data.publicUrl;
  const store = window.sessionStorage;
  const seen = k => { try { return JSON.parse(store.getItem(k) || '[]'); } catch (_) { return []; } };
  const remember = (k, id) => { try { const s = seen(k); if (!s.includes(id)) store.setItem(k, JSON.stringify([...s, id].slice(-50))); } catch (_) {} };

  function el(tag, props, ...kids) {
    const e = document.createElement(tag);
    for (const [k, v] of Object.entries(props || {})) {
      if (v == null || v === false) continue;
      if (k.startsWith('on')) e[k] = v; else if (k === 'class') e.className = v; else if (k === 'text') e.textContent = v; else e.setAttribute(k, v === true ? '' : v);
    }
    for (const kid of kids.flat()) if (kid != null && kid !== false) e.append(kid);
    return e;
  }
  function css() { if (!document.getElementById('adsCss')) document.head.append(el('style', { id: 'adsCss', text: CSS })); }
  async function list(placement) {
    const d = getDb(); if (!d) return [];
    try { const r = await d.from('live_ads').select('*').eq('placement', placement); return r.error ? [] : (r.data || []); } catch (_) { return []; }
  }
  const pick = arr => arr[Math.floor(Math.random() * arr.length)];
  // Show a pop-up only after its picture has loaded: a box that grows while its picture loads makes the page "jump" (PageSpeed CLS)
  const ready = node => Promise.all([...node.querySelectorAll('img')].map(i => i.decode ? i.decode().catch(() => {}) : null));
  function linkAttrs(ad) {
    const ext = /^https:\/\//i.test(ad.link_url);
    return { href: ad.link_url, target: ext ? '_blank' : null, rel: ext ? 'noopener sponsored' : 'sponsored' };
  }
  function picture(ad, placement) {
    return el('a', { class: 'adimg ' + placement, ...linkAttrs(ad), 'aria-label': ad.title },
      el('img', { src: pub(ad.image_path), alt: ad.title || '', loading: placement.startsWith('popup') ? null : 'lazy', width: placement === 'popup_side' ? 300 : null, height: placement === 'popup_side' ? 250 : null }), el('span', { class: 'adtag', text: 'Ad' }));
  }
  function textBanner(ad, placement) {   // older ads made without a picture (styles in shop.css)
    return el('a', { class: `adb ${ad.color} ${placement}`, ...linkAttrs(ad) },
      el('div', { class: 'adb-t' }, el('b', { text: ad.title }), ad.subtitle && el('span', { text: ad.subtitle })),
      el('span', { class: 'adb-cta', text: ad.cta }), el('small', { class: 'adb-tag', text: 'Ad' }));
  }

  async function slot(placement, holder) {
    if (!holder) return;
    css();
    const ads = await list(placement);
    const withPic = ads.filter(a => a.image_path);
    const usable = placement === 'product_side' ? withPic : ads;   // the product page has no text-banner styles
    if (!usable.length) { holder.hidden = true; return; }
    const ad = pick(withPic.length ? withPic : usable);
    holder.innerHTML = ''; holder.append(ad.image_path ? picture(ad, placement) : textBanner(ad, placement)); holder.hidden = false;
  }

  async function mainPopup() {
    const page = location.pathname.split('/').pop() || 'index.html';
    if (page !== 'index.html') return;
    try { if (store.getItem('rgbkart-popup-seen')) return; } catch (_) {}
    const ads = (await list('popup_main')).filter(a => a.image_path);
    if (!ads.length) return;
    const ad = pick(ads);
    const close = () => { scrim.remove(); document.removeEventListener('keydown', onKey); };
    const onKey = e => { if (e.key === 'Escape') close(); };
    const x = el('button', { type: 'button', class: 'adx', 'aria-label': 'Close ad', text: '✕', onclick: close });
    const pic = picture(ad, 'popup_main'); await ready(pic);
    const scrim = el('div', { class: 'adpop-scrim', role: 'dialog', 'aria-modal': 'true', 'aria-label': 'Advertisement', onclick: e => { if (e.target === scrim) close(); } },
      el('div', { class: 'adpop' }, x, pic));
    document.body.append(scrim); document.addEventListener('keydown', onKey); x.focus();
    try { store.setItem('rgbkart-popup-seen', '1'); } catch (_) {}
  }
  async function sidePopups() {
    const closed = seen('rgbkart-ad-closed');
    const ads = (await list('popup_side')).filter(a => a.image_path && !closed.includes(a.id)).sort(() => Math.random() - .5).slice(0, 3);
    if (!ads.length) return;
    const box = el('div', { class: 'adside', role: 'complementary', 'aria-label': 'Advertisements' });
    ads.forEach(ad => {
      const one = el('div', { class: 'adone' });
      one.append(el('button', { type: 'button', class: 'adx', 'aria-label': 'Close ad', text: '✕', onclick: () => { remember('rgbkart-ad-closed', ad.id); one.remove(); if (!box.children.length) box.remove(); } }), picture(ad, 'popup_side'));
      box.append(one);
    });
    await ready(box);
    document.body.append(box);
  }
  function startPopups() {
    let tries = 0;
    const go = () => {
      if (!getDb()) { if (++tries < 20) setTimeout(go, 300); return; }
      css(); mainPopup(); setTimeout(sidePopups, 2500);
    };
    setTimeout(go, 1500);
  }
  window.RGBAds = { slot };
  window.adSlot = slot;   // older page code
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', startPopups); else startPopups();
})();
