// Sign out when the browser is closed (owner, 24 Oct 2026).
// A browser-session cookie (no expiry date) marks "this browser is still open". When the browser is closed and opened
// again the cookie is gone, so before any page code starts we remove a real account's saved sign-in and the personal
// lists kept on this computer (cart, wishlist, saved checkout details). Tabs open at the same time share the cookie and
// stay signed in together. The invisible guest sign-in (guest orders, one-time sellers) is kept, so guests can still
// follow their orders and manage their listings. Load this BEFORE supabase-js on every page.
(function () {
  var MARK = 'rgbkart_open';
  var PERSONAL = ['rgbkart-cart', 'rgbkart-wishlist', 'rgbkart-synced', 'rgbkart-dirty', 'rgbkart-coupons', 'rgbkart-ship', 'rgbkart-address', 'rgbkart-name'];
  try {
    if (document.cookie.split('; ').indexOf(MARK + '=1') !== -1) return;          // browser still open: nothing to do
    document.cookie = MARK + '=1; path=/; SameSite=Lax' + (location.protocol === 'https:' ? '; Secure' : '');
    if (document.cookie.split('; ').indexOf(MARK + '=1') === -1) return;          // cookies blocked: don't sign people out on every page
    var ls = window.localStorage, signedOut = false;
    for (var i = ls.length - 1; i >= 0; i--) {
      var k = ls.key(i);
      if (!k || !/^sb-.+-auth-token$/.test(k)) continue;
      var anon = false;
      try { var s = JSON.parse(ls.getItem(k) || 'null'); anon = !!(s && s.user && s.user.is_anonymous); } catch (_) {}
      if (!anon) { ls.removeItem(k); signedOut = true; }
    }
    if (signedOut) PERSONAL.forEach(function (k) { ls.removeItem(k); });
  } catch (_) {}
})();
