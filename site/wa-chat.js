// Floating WhatsApp chat button (shop page and product page), 25 Oct 2026.
//   waBubble(number, message, shopName) → round green button bottom-right that opens WhatsApp with a ready message;
//   waBubble(null) removes it. Only call it with numbers the buyer may see (shops; one-time sellers only when Featured).
(function () {
  const css = `
  .wa-fab { position: fixed; z-index: 45; right: max(18px, env(safe-area-inset-right, 0px)); bottom: max(18px, env(safe-area-inset-bottom, 0px));
    display: inline-flex; align-items: center; gap: 8px; background: #25D366; color: #fff; text-decoration: none; font: 700 1rem/1 Roboto, Arial, sans-serif;
    padding: 12px 18px 12px 14px; border-radius: 999px; box-shadow: 0 8px 22px rgb(0 0 0 / .25); transition: transform .15s, box-shadow .15s, background-color .15s; }
  .wa-fab svg { width: 28px; height: 28px; flex: none; }
  .wa-fab:hover { transform: translateY(-2px) scale(1.03); box-shadow: 0 12px 26px rgb(0 0 0 / .3); background: #1EBE5A; color: #fff; }
  .wa-fab:focus-visible { outline: 3px solid #0B6B2A; outline-offset: 3px; }
  .wa-fab::after { content: ''; position: absolute; inset: 0; border-radius: inherit; box-shadow: 0 0 0 0 rgb(37 211 102 / .55); animation: waPulse 2.4s ease-out 1.2s 3; pointer-events: none; }
  @keyframes waPulse { to { box-shadow: 0 0 0 14px rgb(37 211 102 / 0); } }
  @media (prefers-reduced-motion: reduce) { .wa-fab::after { animation: none; } .wa-fab { transition: none; } }
  @media (max-width: 760px) {
    .wa-fab { padding: 14px; } .wa-fab span { display: none; } .wa-fab svg { width: 30px; height: 30px; }
    body.has-wa .fab { display: none !important; }
    body.has-mbar .wa-fab { bottom: calc(max(12px, env(safe-area-inset-bottom, 0px)) + 72px); }
  }`;
  const ICON = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 11.5a8.5 8.5 0 0 1-12.6 7.4L3 20.5l1.6-4.3A8.5 8.5 0 1 1 20 11.5z"/><path d="M9 8.6c0 3.2 2.6 6.4 6 6.4l1.2-1.4-1.9-1-1 .8a4 4 0 0 1-2.1-2.1l.8-1-1-1.9z" fill="currentColor" stroke-width="1.2"/></svg>';
  const tr = (t, v) => (window.T ? window.T(t, v) : t.replace(/\{(\w+)\}/g, (_, k) => (v && v[k]) || ''));
  let styled = false;
  window.waBubble = function (num, text, name) {
    const old = document.querySelector('.wa-fab'); if (old) old.remove();
    const d = String(num || '').replace(/\D/g, '');
    if (d.length < 10) { document.body.classList.remove('has-wa'); return; }
    if (!styled) { const st = document.createElement('style'); st.textContent = css; document.head.append(st); styled = true; }
    const intl = d.startsWith('880') ? d : d.startsWith('0') ? '88' + d : '880' + d;
    const a = document.createElement('a');
    a.className = 'wa-fab'; a.target = '_blank'; a.rel = 'noopener';
    a.href = `https://wa.me/${intl}?text=${encodeURIComponent(text || '')}`;
    a.setAttribute('aria-label', name ? tr('Chat on WhatsApp with {s}', { s: name }) : tr('Chat on WhatsApp'));
    a.title = tr('Chat on WhatsApp');
    a.innerHTML = ICON;
    const sp = document.createElement('span'); sp.textContent = tr('WhatsApp'); a.append(sp);
    document.body.append(a); document.body.classList.add('has-wa');
  };
})();
