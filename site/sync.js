// Keeps the wishlist and cart in the customer's account (0031_saved_lists.sql), so they follow a signed-in customer to every device.
// The lists still live in localStorage ('rgbkart-cart', 'rgbkart-wishlist') for the pages; this file copies them to and from the account.
//  - At sign-in on a device: the device's lists are merged into the account (nothing is lost).
//  - Afterwards: every change is saved to the account; the account is the truth when the page opens.
//  - Sign out: the lists are cleared from this device (they stay safe in the account).
// Load it before shop.js; pages call RGBSync.start(db). Guests (no account, or the invisible guest sign-in) are left alone.
(function () {
  const CART = 'rgbkart-cart', WISH = 'rgbkart-wishlist', MARK = 'rgbkart-synced', DIRTY = 'rgbkart-dirty';
  const KEYS = [CART, WISH];
  let db = null, uid = null, timer = null, applying = false, started = false;
  let ls; try { ls = window.localStorage; } catch (_) { ls = null; }
  if (!ls) { window.RGBSync = { start() {} }; return; }
  const origSet = Storage.prototype.setItem, origRemove = Storage.prototype.removeItem;
  const get = k => { try { return ls.getItem(k); } catch (_) { return null; } };
  const put = (k, v) => { try { origSet.call(ls, k, v); } catch (_) {} };
  const del = k => { try { origRemove.call(ls, k); } catch (_) {} };
  const readJSON = k => { try { const v = JSON.parse(get(k) || '[]'); return Array.isArray(v) ? v : []; } catch (_) { return []; } };

  // Any page code that saves the cart or wishlist → mark it and save to the account shortly after
  Storage.prototype.setItem = function (k, v) {
    origSet.call(this, k, v);
    if (this === ls && KEYS.includes(k) && !applying && uid) { put(DIRTY, '1'); schedule(); }
  };
  Storage.prototype.removeItem = function (k) {
    origRemove.call(this, k);
    if (this === ls && KEYS.includes(k) && !applying && uid) { put(DIRTY, '1'); schedule(); }
  };
  // Another tab changed the lists
  window.addEventListener('storage', e => { if (KEYS.includes(e.key)) refreshPage(false); });

  function schedule() { clearTimeout(timer); timer = setTimeout(push, 700); }
  async function push() {
    if (!uid || !db) return;
    const wish = readJSON(WISH).map(Number).filter(Number.isFinite).slice(0, 300);
    const cart = readJSON(CART).slice(0, 100);
    const { error } = await db.from('customer_lists').upsert({ user_id: uid, wishlist: wish, cart }, { onConflict: 'user_id' });
    if (!error) del(DIRTY);
  }

  function same(a, b) { return JSON.stringify(a) === JSON.stringify(b); }
  function refreshPage(reloadLists) {
    try { if (typeof updateBadges === 'function') updateBadges(); } catch (_) {}
    window.dispatchEvent(new Event('rgbkart-lists'));
    // Pages that show the lists themselves are simply reloaded when the lists changed underneath them
    if (reloadLists) {
      const p = location.pathname.split('/').pop();
      if (p === 'cart.html' || p === 'checkout.html' || /[?&]wishlist=1/.test(location.search)) location.reload();
    }
  }

  let pending = null;
  function signedIn(session) {
    if (pending) return pending;
    pending = doSignedIn(session).finally(() => { pending = null; });
    return pending;
  }
  async function doSignedIn(session) {
    const user = session && session.user;
    if (!user || user.is_anonymous) { uid = null; return; }
    if (uid === user.id) return;
    const r = await db.from('customer_lists').select('wishlist, cart').eq('user_id', user.id).maybeSingle();
    if (r.error) return;                                    // 0031 not run yet: keep the device-only behaviour
    uid = user.id;
    const server = r.data || { wishlist: [], cart: [] };
    const sWish = (server.wishlist || []).map(Number), sCart = Array.isArray(server.cart) ? server.cart : [];
    const lWish = readJSON(WISH).map(Number), lCart = readJSON(CART);
    let wish, cart;
    if (get(MARK) === uid && get(DIRTY) !== '1') {          // this device is already in step: the account is the truth
      wish = sWish; cart = sCart;
    } else {                                                // first time here, or unsaved changes: merge (device wins for the same item)
      wish = [...new Set([...lWish, ...sWish])];
      const byKey = new Map();
      sCart.forEach(i => i && i.key && byKey.set(i.key, i));
      lCart.forEach(i => i && i.key && byKey.set(i.key, i));
      cart = [...byKey.values()];
    }
    const changedHere = !same(wish, lWish) || !same(cart, lCart);
    const changedThere = !r.data || !same(wish, sWish) || !same(cart, sCart);
    applying = true; put(WISH, JSON.stringify(wish)); put(CART, JSON.stringify(cart)); applying = false;
    put(MARK, uid);
    if (changedThere) await push(); else del(DIRTY);
    if (changedHere) refreshPage(true);
  }

  function signedOut() {
    clearTimeout(timer);
    if (get(MARK)) { applying = true; del(CART); del(WISH); applying = false; del(MARK); del(DIRTY); refreshPage(false); }
    uid = null;
  }

  async function start(client) {
    if (started || !client) return; started = true; db = client;
    try {
      const { data: { session } } = await db.auth.getSession();
      await signedIn(session);
      db.auth.onAuthStateChange((ev, s) => {
        if (ev === 'SIGNED_OUT') signedOut();
        else if (ev === 'SIGNED_IN' || ev === 'INITIAL_SESSION') setTimeout(() => signedIn(s), 0);
      });
    } catch (_) {}
  }
  // Save before the page closes if a change is still waiting
  window.addEventListener('pagehide', () => { if (timer && uid) { clearTimeout(timer); push(); } });

  window.RGBSync = { start, push };
})();
