// "Share" button for products and shops. Links go through share.php so Facebook / WhatsApp show the photo, name and price.
// RGBShare.button({ id } | { shop: slug }, title) → button element. Needs i18n.js (T).
(function () {
  const css = `
    .sh-wrap { position: relative; display: inline-block; }
    .sh-btn { display: inline-flex; align-items: center; gap: 6px; border: 0; background: #F5C400; color: #2a1f00; border-radius: 999px; padding: 7px 16px; font: inherit; font-size: .9rem; font-weight: 700; cursor: pointer; box-shadow: 0 2px 6px rgb(245 196 0 / .45); transition: background .15s, color .15s, transform .1s; }
    .sh-btn:hover { background: #00802B; color: #fff; box-shadow: 0 2px 8px rgb(0 128 43 / .35); }
    .sh-btn:active { transform: translateY(1px); }
    .sh-btn:focus-visible { outline: 2px solid #00802B; outline-offset: 2px; }
    .sh-menu { position: absolute; z-index: 50; top: calc(100% + 6px); left: 0; background: var(--surface); border: 1px solid var(--line); border-radius: 12px; box-shadow: 0 10px 30px rgb(0 0 0 / .15); padding: 6px; display: grid; min-width: 190px; }
    .sh-menu a, .sh-menu button { display: flex; align-items: center; gap: 10px; padding: 9px 12px; border-radius: 8px; color: var(--fg); text-decoration: none; background: none; border: 0; font: inherit; text-align: left; cursor: pointer; }
    .sh-menu a:hover, .sh-menu button:hover { background: var(--bg); }`;
  const st = document.createElement('style'); st.textContent = css; document.head.append(st);
  function el(tag, props, ...kids) {
    const e = document.createElement(tag);
    for (const [k, v] of Object.entries(props || {})) { if (v == null || v === false) continue; if (k.startsWith('on')) e[k] = v; else if (k === 'class') e.className = v; else if (k === 'text') e.textContent = v; else e.setAttribute(k, v); }
    kids.flat().forEach(k => k != null && e.append(k)); return e;
  }
  function link(opt) {
    const base = location.href.replace(/[^/]*([?#].*)?$/, '');
    return base + 'share.php?' + (opt.id ? 'id=' + encodeURIComponent(opt.id) : 's=' + encodeURIComponent(opt.shop));
  }
  function button(opt, title) {
    const url = link(opt);
    const wrap = el('span', { class: 'sh-wrap' });
    const menu = el('div', { class: 'sh-menu', role: 'menu', hidden: true },
      el('a', { role: 'menuitem', href: 'https://wa.me/?text=' + encodeURIComponent(title + ' ' + url), target: '_blank', rel: 'noopener', text: '🟢 WhatsApp' }),
      el('a', { role: 'menuitem', href: 'https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(url), target: '_blank', rel: 'noopener', text: '🔵 Facebook' }),
      el('a', { role: 'menuitem', href: 'fb-messenger://share/?link=' + encodeURIComponent(url), text: '💬 Messenger' }),
      el('button', { type: 'button', role: 'menuitem', text: '🔗 ' + T('Copy link'), onclick: async () => {
        try { await navigator.clipboard.writeText(url); if (typeof toast === 'function') toast(T('Link copied')); } catch (_) { prompt('', url); }
        menu.hidden = true; } }));
    const btn = el('button', { type: 'button', class: 'sh-btn', 'aria-haspopup': 'menu', text: '↗ ' + T('Share'), onclick: async e => {
      e.stopPropagation();
      if (navigator.share && matchMedia('(pointer: coarse)').matches) { try { await navigator.share({ title, url }); return; } catch (_) { return; } }
      menu.hidden = !menu.hidden;
    } });
    document.addEventListener('click', e => { if (!wrap.contains(e.target)) menu.hidden = true; });
    wrap.append(btn, menu);
    return wrap;
  }
  window.RGBShare = { button, link };
})();
