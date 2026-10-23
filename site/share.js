// "Share" button for products and shops. Links go through share.php so Facebook / WhatsApp show the photo, name and price.
// RGBShare.button({ id } | { shop: slug }, title) → button element. Needs i18n.js (T).
(function () {
  const css = `
    .sh-wrap { position: relative; display: inline-block; }
    .sh-btn { display: inline-flex; align-items: center; gap: 6px; border: 1.5px solid var(--line); background: var(--surface); color: var(--fg); border-radius: 999px; padding: 6px 14px; font: inherit; font-size: .88rem; font-weight: 600; cursor: pointer; }
    .sh-btn:hover { border-color: var(--accent); color: var(--accent); }
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
