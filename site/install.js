// "Install the RGBKart app" (owner, 30 Oct 2026). Loaded by shop.js on every shop page.
// • Registers sw.js (needed to install; it only shows offline.html when there is no internet, nothing is cached).
// • Android / computer Chrome & Edge: when the browser says the site can be installed, a small card offers "Install".
// • iPhone / iPad Safari (no install button exists there): the card explains Share → "Add to Home Screen".
// Shown from the 2nd page a visitor opens, never inside the installed app; ✕ hides it for 30 days.
(function () {
  if ('serviceWorker' in navigator) navigator.serviceWorker.register('sw.js').catch(() => {});
  const T = s => (window.T ? window.T(s) : s);
  const KEY = 'rgbkart-install-closed', VIEWS = 'rgbkart-views';
  const standalone = () => matchMedia('(display-mode: standalone)').matches || navigator.standalone === true;
  if (standalone()) return;
  let views = 0;
  try {
    const t = Number(localStorage.getItem(KEY) || 0);
    if (t && Date.now() - t < 30 * 864e5) return;
    views = Number(sessionStorage.getItem(VIEWS) || 0) + 1; sessionStorage.setItem(VIEWS, String(views));
  } catch (_) {}
  const ua = navigator.userAgent;
  const ios = /iPhone|iPad|iPod/.test(ua) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);
  const iosSafari = ios && /Safari/.test(ua) && !/CriOS|FxiOS|EdgiOS|FBAN|FBAV|Instagram/.test(ua);
  let deferred = null, card = null;

  function css() {
    if (document.getElementById('instCss')) return;
    const s = document.createElement('style'); s.id = 'instCss';
    s.textContent = `
    .inst { position: fixed; z-index: 70; left: 12px; right: 12px; bottom: max(12px, env(safe-area-inset-bottom, 0px)); max-width: 420px; display: flex; gap: 12px; align-items: center;
      background: #fff; color: #14211C; border-radius: 16px; padding: 12px 12px 12px 14px; box-shadow: 0 10px 30px rgb(0 0 0 / .25); border-top: 4px solid #F5C400; animation: instUp .3s ease-out; font-family: inherit; }
    .inst img { width: 44px; height: 44px; border-radius: 12px; flex: none; }
    .inst .t { flex: 1; min-width: 0; line-height: 1.3; } .inst .t b { display: block; font-size: .98rem; } .inst .t span { font-size: .84rem; color: #4A5A52; }
    .inst .go { border: 0; border-radius: 999px; background: #00802B; color: #fff; font: 700 .9rem/1 inherit; padding: 10px 16px; cursor: pointer; flex: none; }
    .inst .go:hover { background: #006622; }
    .inst .x { border: 0; background: #EEF2EF; color: #14211C; width: 32px; height: 32px; border-radius: 50%; cursor: pointer; flex: none; font-size: .95rem; }
    @keyframes instUp { from { opacity: 0; transform: translateY(20px); } }
    @media (prefers-reduced-motion: reduce) { .inst { animation: none; } }
    @media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) .inst { background: #141E1A; color: #E6EEEA; } :root:not([data-theme="light"]) .inst .t span { color: #9CACA4; } :root:not([data-theme="light"]) .inst .x { background: #22302A; color: #E6EEEA; } }`;
    document.head.append(s);
  }
  function close(remember) {
    if (card) { card.remove(); card = null; }
    if (remember) try { localStorage.setItem(KEY, String(Date.now())); } catch (_) {}
  }
  function show(kind) {
    if (card || views < 2) return;
    css();
    card = document.createElement('div');
    card.className = 'inst'; card.setAttribute('role', 'dialog'); card.setAttribute('aria-label', T('Install the RGBKart app'));
    const img = document.createElement('img'); img.src = 'assets/logo/rgb-basket-192.png'; img.alt = '';
    const t = document.createElement('div'); t.className = 't';
    const b = document.createElement('b'); b.textContent = T('Install the RGBKart app');
    const sp = document.createElement('span');
    sp.textContent = kind === 'ios' ? T('Tap Share ⬆ below, then “Add to Home Screen”.') : T('Free and quick: opens like an app, no Play Store needed.');
    t.append(b, sp);
    const x = document.createElement('button'); x.type = 'button'; x.className = 'x'; x.textContent = '✕'; x.setAttribute('aria-label', T('Close')); x.onclick = () => close(true);
    card.append(img, t);
    if (kind !== 'ios') {
      const go = document.createElement('button'); go.type = 'button'; go.className = 'go'; go.textContent = T('Install');
      go.onclick = async () => {
        if (!deferred) return close(false);
        deferred.prompt();
        try { const r = await deferred.userChoice; close(r && r.outcome === 'dismissed'); } catch (_) { close(false); }
        deferred = null;
      };
      card.append(go);
    }
    card.append(x);
    document.body.append(card);
  }
  window.addEventListener('beforeinstallprompt', e => { e.preventDefault(); deferred = e; setTimeout(() => show('prompt'), 6000); });
  window.addEventListener('appinstalled', () => { close(true); });
  if (iosSafari) setTimeout(() => show('ios'), 6000);
})();
