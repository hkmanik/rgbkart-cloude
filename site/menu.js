// RGBKart main menu: "All categories" button with a category panel, then the admin-managed links (Admin → Main menu).
// Works on any page that has a <header> and a Supabase client named `db`. Call RGBMenu.mount() once the header exists.
(function () {
  const L = window.L || ((r, f) => r ? r[f] : ''), T = window.T || ((s, v) => s.replace(/\{(\w+)\}/g, (_, k) => v[k]));
  const CSS = `
  /* header + menu stay at the top while scrolling */
  .rgb-sticky { position: sticky; top: 0; z-index: 30; }
  html { scroll-padding-top: calc(var(--head-h, 0px) + 8px); }
  .rgb-sticky .top { position: relative; top: auto; }
  .mmenu { background: var(--surface, #fff); border-bottom: 1px solid var(--line, #D9E2DC); position: relative; z-index: 25; }
  .mmenu .mrow { display: flex; gap: 6px; align-items: center; padding-block: 6px; max-width: 1280px; margin: 0 auto;
    padding-left: max(16px, env(safe-area-inset-left, 0px)); padding-right: max(16px, env(safe-area-inset-right, 0px)); }
  .mmenu .mall { flex: none; display: inline-flex; align-items: center; gap: 8px; border: 0; border-radius: 8px; padding: 8px 14px; cursor: pointer;
    background: #00802B; color: #fff; font: 600 .92rem var(--body, system-ui); transition: background-color .15s; }
  .mmenu .mall:hover, .mmenu .mall[aria-expanded="true"] { background: #E30613; }
  .mmenu .mall svg { width: 18px; height: 18px; }
  .mmenu .mlinks { display: flex; gap: 2px; overflow-x: auto; scrollbar-width: none; min-width: 0; flex: 1; -webkit-overflow-scrolling: touch; }
  .mmenu .mlinks::-webkit-scrollbar { display: none; }
  .mmenu .mlinks a { flex: none; padding: 8px 12px; border-radius: 8px; text-decoration: none; white-space: nowrap; font: 500 .92rem var(--body, system-ui);
    color: var(--fg, #14211C); transition: background-color .15s, color .15s; }
  .mmenu .mlinks a:hover { background: var(--accent-soft, #E5F4EA); color: var(--accent, #00802B); }
  .mmenu .mlinks a.hot { color: #E30613; font-weight: 600; }
  .mmenu .mlinks a.hot:hover { background: #FDE7E8; }
  .mmenu .mlinks a.feat { background: #FFF4CC; color: #7a5200; font-weight: 700; box-shadow: inset 0 0 0 1.5px #F5C400; }
  .mmenu .mlinks a.feat::before { content: "★ "; color: #d4a000; }
  .mmenu .mlinks a.feat:hover, .mmenu .mlinks a.feat[aria-current="page"] { background: #F5C400; color: #2a1a00; box-shadow: inset 0 0 0 1.5px #d4a000; }
  .mmenu .mlinks a[aria-current="page"] { background: var(--accent-soft, #E5F4EA); color: var(--accent, #00802B); font-weight: 700; box-shadow: inset 0 -2px 0 var(--accent, #00802B); }
  .mmenu .mpanel { position: absolute; left: 0; right: 0; top: 100%; background: var(--surface, #fff); border-bottom: 3px solid #00802B;
    box-shadow: 0 18px 30px rgb(8 40 18 / .18); max-height: min(70vh, 640px); overflow: auto; }
  .mmenu .mpanel-in { max-width: 1280px; margin: 0 auto; padding: 16px max(16px, env(safe-area-inset-left, 0px)) 20px;
    display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 14px 24px; }
  @media (max-width: 1000px) { .mmenu .mpanel-in { grid-template-columns: repeat(3, minmax(0, 1fr)); } }
  @media (max-width: 760px) { .mmenu .mpanel-in { grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px 14px; } }
  .mmenu .mgroup { min-width: 0; }
  .mmenu .mhead { display: flex; align-items: center; gap: 8px; font: 600 .95rem var(--display, system-ui); color: #00802B; text-decoration: none;
    padding: 6px 8px; border-radius: 8px; border-bottom: 1px solid var(--line, #D9E2DC); }
  .mmenu .mhead:hover { background: var(--accent-soft, #E5F4EA); }
  .mmenu .mhead span:first-child { font-size: 1.15rem; }
  .mmenu .msub { display: block; padding: 4px 8px; border-radius: 6px; color: var(--fg, #14211C); text-decoration: none; font-size: .88rem; overflow-wrap: anywhere; }
  .mmenu .msub:hover { background: var(--accent-soft, #E5F4EA); color: var(--accent, #00802B); }
  .mmenu .mmore { color: var(--accent, #00802B); font-weight: 600; }
  .mmenu .mfoot { grid-column: 1 / -1; text-align: center; padding-top: 4px; }
  .mmenu .mfoot a { font-weight: 700; color: #00802B; }
  @media (prefers-color-scheme: dark) {
    .mmenu .mhead { color: #49CC73; }
    .mmenu .mlinks a.hot { color: #FF6B72; }
    .mmenu .mlinks a.hot:hover { background: #3A1A1C; }
  }
  @media (max-width: 560px) { .mmenu .mall .mlbl { display: none; } .mmenu .mall { padding: 8px 10px; } }
  @media (prefers-reduced-motion: reduce) { .mmenu * { transition: none !important; } }`;

  // Used when the menu_items table hasn't been set up yet (same as the starting menu)
  const DEFAULT = [
    { label: 'Home', link_type: 'home' }, { label: 'Shop', link_type: 'shop' }, { label: 'Featured', link_type: 'featured' },
    { label: 'Deals of the Day', link_type: 'deals', is_hot: true }, { label: 'New Arrivals', link_type: 'newest' }, { label: 'Pre-Owned', link_type: 'pre_owned' },
  ];
  const GRID = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M4 6h16M4 12h16M4 18h16"/></svg>';

  function hrefFor(it, cats) {
    switch (it.link_type) {
      case 'home': return 'index.html';
      case 'shop': return 'browse.html';
      case 'deals': return 'browse.html?deals=1';
      case 'featured': return 'browse.html?featured=1';
      case 'newest': return 'browse.html?sort=newest';
      case 'pre_owned': return 'browse.html?condition=pre_owned';
      case 'free_delivery': return 'browse.html?free=1';
      case 'sell': return 'sell.html';
      case 'categories': {
        const slugs = (it.category_ids || []).map(id => (cats.find(x => x.id === id) || {}).slug).filter(Boolean);
        if (!slugs.length) return null;
        if (slugs.length === 1) return 'browse.html?c=' + encodeURIComponent(slugs[0]);
        return 'browse.html?' + new URLSearchParams({ c: slugs.join(','), t: L(it, 'label') }).toString();
      }
      case 'category': { const c = cats.find(x => x.id === it.category_id); return c ? 'browse.html?c=' + encodeURIComponent(c.slug) : null; }
      case 'url': return /^(https:\/\/|[a-z0-9_-]+\.html)/i.test(it.url || '') ? it.url : null;
    }
    return null;
  }
  // Which menu link matches the page we're on
  function isCurrent(href) {
    const here = new URL(location.href), to = new URL(href, location.href);
    const page = p => (p.split('/').pop() || 'index.html');
    if (to.origin !== here.origin || page(to.pathname) !== page(here.pathname)) return false;
    const a = new URLSearchParams(here.search), b = new URLSearchParams(to.search);
    ['v', 'q', 'page'].forEach(k => a.delete(k));
    return a.toString() === b.toString();
  }

  function el(tag, props, ...kids) {
    const e = document.createElement(tag);
    for (const [k, v] of Object.entries(props || {})) {
      if (v == null || v === false) continue;
      if (k.startsWith('on')) e[k] = v; else if (k === 'class') e.className = v; else if (k === 'text') e.textContent = v; else if (k === 'html') e.innerHTML = v; else e.setAttribute(k, v === true ? '' : v);
    }
    for (const kid of kids.flat()) if (kid != null && kid !== false) e.append(kid);
    return e;
  }

  async function mount() {
    if (document.getElementById('mainMenu')) return;
    const header = document.querySelector('header'); if (!header) return;
    if (!document.getElementById('mmenuCss')) document.head.append(el('style', { id: 'mmenuCss', text: CSS }));

    const btn = el('button', { type: 'button', class: 'mall', 'aria-expanded': 'false', 'aria-controls': 'mPanel', html: GRID + '<span class="mlbl">All categories</span>' });
    btn.setAttribute('aria-label', 'All categories');
    const links = el('div', { class: 'mlinks' });
    const panel = el('div', { class: 'mpanel', id: 'mPanel', hidden: true });
    const nav = el('nav', { class: 'mmenu', id: 'mainMenu', 'aria-label': 'Main menu' }, el('div', { class: 'mrow' }, btn, links, window.RGBLang ? RGBLang.switcher() : null), panel);
    header.after(nav);
    // keep the header and this menu fixed at the top; pages read --head-h to place their own sticky boxes below it
    const wrap = el('div', { class: 'rgb-sticky' }); header.before(wrap); wrap.append(header, nav);
    const setH = () => document.documentElement.style.setProperty('--head-h', wrap.offsetHeight + 'px');
    setH(); if (window.ResizeObserver) new ResizeObserver(setH).observe(wrap);

    const open = on => { panel.hidden = !on; btn.setAttribute('aria-expanded', String(on)); };
    btn.onclick = () => open(panel.hidden);
    document.addEventListener('click', e => { if (!panel.hidden && !nav.contains(e.target)) open(false); });
    document.addEventListener('keydown', e => { if (e.key === 'Escape' && !panel.hidden) { open(false); btn.focus(); } });

    let items = DEFAULT, cats = [];
    try {
      const [m, c] = await Promise.all([
        db.from('menu_items').select('*').eq('is_active', true).order('sort_order').order('id'),
        db.from('categories').select('*').eq('is_active', true).order('sort_order').order('name'),
      ]);
      if (!m.error && m.data) items = m.data;
      cats = c.data || [];
    } catch (_) {}

    links.innerHTML = '';
    for (const it of items) {
      const href = hrefFor(it, cats); if (!href) continue;
      const ext = /^https:\/\//i.test(href);
      links.append(el('a', { href, class: it.link_type === 'featured' ? 'feat' : it.is_hot ? 'hot' : null, 'aria-current': !ext && isCurrent(href) ? 'page' : null, target: ext ? '_blank' : null, rel: ext ? 'noopener' : null, text: L(it, 'label') }));
    }
    const cur = links.querySelector('[aria-current="page"]'); if (cur) cur.scrollIntoView({ block: 'nearest', inline: 'center' });

    // category panel
    const inner = el('div', { class: 'mpanel-in' });
    const kids = id => cats.filter(x => (x.parent_id ?? null) === id);
    for (const top of kids(null)) {
      const subs = kids(top.id);
      const icon = top.icon && !/^https?:/.test(top.icon) ? top.icon : '🛍️';
      const pic = top.image_url ? el('img', { src: top.image_url, alt: '', loading: 'lazy', style: 'width:30px;height:30px;border-radius:8px;object-fit:cover;flex:none', onerror: e => e.target.replaceWith(el('span', { text: icon, 'aria-hidden': 'true' })) }) : el('span', { text: icon, 'aria-hidden': 'true' });
      inner.append(el('div', { class: 'mgroup' },
        el('a', { class: 'mhead', href: 'browse.html?c=' + encodeURIComponent(top.slug) }, pic, el('span', { text: L(top, 'name') })),
        subs.slice(0, 6).map(s => el('a', { class: 'msub', href: 'browse.html?c=' + encodeURIComponent(s.slug), text: L(s, 'name') })),
        subs.length > 6 && el('a', { class: 'msub mmore', href: 'browse.html?c=' + encodeURIComponent(top.slug), text: T('All {n} →', { n: subs.length }) })));
    }
    if (!cats.length) inner.append(el('p', { text: 'Categories are loading. Try again in a moment.' }));
    inner.append(el('div', { class: 'mfoot' }, el('a', { href: 'categories.html', text: 'See all categories →' })));
    panel.append(inner);
  }

  window.RGBMenu = { mount };
})();
