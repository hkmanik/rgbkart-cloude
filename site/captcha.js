// Bot protection with Cloudflare Turnstile (owner, 29 Oct 2026).
// Supabase "Attack Protection → captcha" asks for a token on email sign-in, sign-up, password reset and guest
// (anonymous) sign-in. RGBCaptcha.token() gets one. Most people never see anything; if Cloudflare is unsure it shows
// a small "I am human" box at the bottom of the page.
// SITE_KEY is the PUBLIC Turnstile site key (safe to be in the page). Empty = bot check off (token() returns undefined).
// Order: put the site key here and deploy FIRST, then switch captcha on in Supabase with the SECRET key.
(function () {
  const SITE_KEY = '';
  let loading = null, widget = null, box = null;

  function load() {
    if (window.turnstile) return Promise.resolve();
    if (loading) return loading;
    loading = new Promise((resolve, reject) => {
      const s = document.createElement('script');
      s.src = 'https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit';
      s.async = true;
      s.onload = () => resolve();
      s.onerror = () => { loading = null; reject(new Error('The bot check could not load. Check your internet and try again.')); };
      document.head.append(s);
    });
    return loading;
  }

  async function token() {
    if (!SITE_KEY) return undefined;
    await load();
    if (!box) {
      box = document.createElement('div');
      box.id = 'rgbCaptcha';
      box.style.cssText = 'position:fixed;left:50%;bottom:16px;transform:translateX(-50%);z-index:95';
      document.body.append(box);
    }
    return new Promise((resolve, reject) => {
      let done = false;
      const finish = (fn, v) => { if (done) return; done = true; clearTimeout(timer); fn(v); };
      const timer = setTimeout(() => finish(reject, new Error('The bot check took too long. Please try again.')), 60000);
      try { if (widget != null) window.turnstile.remove(widget); } catch (_) {}
      widget = window.turnstile.render(box, {
        sitekey: SITE_KEY,
        appearance: 'interaction-only',
        callback: t => finish(resolve, t),
        'error-callback': () => finish(reject, new Error('The bot check failed. Please reload the page and try again.')),
        'expired-callback': () => {},
      });
    });
  }

  window.RGBCaptcha = { on: !!SITE_KEY, token };
})();
