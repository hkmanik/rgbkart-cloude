// RGBKart cart helpers: read the device cart, refresh prices / stock from the database, group by shop, work out delivery.
// Needs shop.js (db, store, CART_KEY, saleActive). The database checks everything again when the order is placed.
const SHIP_KEY = 'rgbkart-ship', COUPON_KEY = 'rgbkart-coupons';
const CartLib = {
  read() { return store.get(CART_KEY); },
  write(c) { store.set(CART_KEY, c); updateBadges(); },
  shipChoice() { try { return JSON.parse(localStorage.getItem(SHIP_KEY) || '{}'); } catch (_) { return {}; } },
  coupons() { try { return JSON.parse(localStorage.getItem(COUPON_KEY) || '{}'); } catch (_) { return {}; } },
  setCoupon(sellerId, code) { const c = CartLib.coupons(); if (code) c[sellerId] = code; else delete c[sellerId]; try { localStorage.setItem(COUPON_KEY, JSON.stringify(c)); } catch (_) {} },
  setShip(sellerId, m) { const s = CartLib.shipChoice(); s[sellerId] = m; try { localStorage.setItem(SHIP_KEY, JSON.stringify(s)); } catch (_) {} },

  // Returns { groups: [{ seller, shop, items, subtotal, options, method, fee, total }], methods, problems }
  async load() {
    const cart = CartLib.read();
    if (!cart.length) return { groups: [], methods: [], cart };
    const ids = [...new Set(cart.map(i => i.product_id))];
    const [p, m] = await Promise.all([
      db.from('products').select('id, title, title_bn, price, sale_price, sale_starts_at, sale_ends_at, status, seller_id, product_type, manage_stock, stock, backorders, stock_status, free_delivery, ships_to, contact_only, cod_allowed, is_downloadable, sold_individually, product_images(storage_path, sort_order), product_price_tiers(min_qty, unit_price), product_variations(id, price, sale_price, stock, is_active)').in('id', ids),
      db.from('shipping_methods').select('*').eq('is_active', true).order('sort_order'),
    ]);
    const prods = new Map((p.data || []).map(x => [x.id, x]));
    const methods = m.error ? [] : m.data;
    const sellerIds = [...new Set((p.data || []).map(x => x.seller_id))];
    const s = sellerIds.length ? await db.from('shops').select('*').in('user_id', sellerIds) : { data: [] };
    const shops = new Map((s.data || []).map(x => [x.user_id, x]));

    const items = cart.map((c, idx) => {
      const pr = prods.get(c.product_id);
      const it = { ...c, idx, pr, problem: null, max: 99 };
      if (pr && window.L) it.title = L(pr, 'title');
      if (!pr || pr.status !== 'approved') { it.problem = 'No longer available'; return it; }
      if (pr.contact_only) { it.problem = 'Contact the seller to buy this'; return it; }
      if (pr.is_downloadable) { it.problem = 'Digital products can\'t be ordered yet'; return it; }
      if (pr.cod_allowed === false) { it.problem = 'Not available with Cash on Delivery'; return it; }
      const shop = shops.get(pr.seller_id);
      if (shop && shop.vacation_mode) { it.problem = 'Shop is on holiday'; return it; }
      if (pr.product_type === 'variable') {
        const v = (pr.product_variations || []).find(x => x.id === c.variation_id && x.is_active);
        if (!v) { it.problem = 'This option is no longer available'; return it; }
        it.unit = Number(v.sale_price || v.price);
        if (pr.backorders === 'no') it.max = Math.min(99, v.stock);
      } else {
        it.unit = Number(saleActive(pr) ? pr.sale_price : pr.price);
        // bulk price for the quantity in the cart (the database uses the same rule)
        const tier = (pr.product_price_tiers || []).filter(t => t.min_qty <= c.qty).map(t => Number(t.unit_price));
        if (tier.length) it.unit = Math.min(it.unit, ...tier);
        if (pr.manage_stock && pr.backorders === 'no') it.max = Math.min(99, pr.stock);
        if (!pr.manage_stock && pr.stock_status === 'out_of_stock') it.max = 0;
      }
      if (pr.sold_individually) it.max = Math.min(it.max, 1);
      if (it.max <= 0) { it.problem = 'Out of stock'; return it; }
      if (c.qty > it.max) { it.qty = it.max; it.note = window.T ? T('Only {n} available', { n: it.max }) : `Only ${it.max} available`; }
      if (!c.image) { const im = [...(pr.product_images || [])].sort((a, b) => a.sort_order - b.sort_order)[0]; if (im) it.image = imgUrl(im.storage_path); }
      return it;
    });

    const choice = CartLib.shipChoice();
    const groups = [];
    for (const sid of [...new Set(items.filter(i => !i.problem).map(i => i.pr.seller_id))]) {
      const its = items.filter(i => !i.problem && i.pr.seller_id === sid);
      const shop = shops.get(sid) || { shop_name: 'Seller' };
      const options = methods.filter(mm =>
        (mm.id === 'dhaka' && its.every(i => i.pr.ships_to !== 'outside_dhaka')) ||
        (mm.id === 'outside' && its.every(i => i.pr.ships_to !== 'inside_dhaka')) ||
        (mm.id === 'pickup' && shop.allow_pickup) || mm.id === 'negotiated');
      const allFree = its.every(i => i.pr.free_delivery);
      const feeOf = mm => (mm.id === 'dhaka' || mm.id === 'outside') ? (allFree ? 0 : Number(mm.fee)) : 0;
      let method = options.find(o => o.id === choice[sid]) || options[0] || null;
      const subtotal = its.reduce((a, i) => a + i.unit * i.qty, 0);
      const fee = method ? feeOf(method) : 0;
      groups.push({ seller: sid, shop, items: its, subtotal, options, method, fee, feeOf, allFree, total: subtotal + fee, discount: 0, coupon: null });
    }
    // shop coupons (0033): check each saved code against the shop's items total; place_order checks again
    const codes = CartLib.coupons();
    await Promise.all(groups.filter(g => codes[g.seller]).map(async g => {
      const r = await db.rpc('check_coupon', { p_seller: g.seller, p_code: codes[g.seller], p_subtotal: g.subtotal });
      if (r.error) g.coupon = { code: codes[g.seller], error: r.error.message };
      else { g.coupon = r.data; g.discount = Number(r.data.discount) || 0; g.total = g.subtotal + g.fee - g.discount; }
    }));
    return { groups, methods, items, problems: items.filter(i => i.problem) };
  },
  // Pick a sensible default delivery for a district (Dhaka → Inside Dhaka, others → Outside Dhaka)
  defaultFor(group, district) {
    if (!district) return null;
    const want = district === 'Dhaka' ? 'dhaka' : 'outside';
    return group.options.find(o => o.id === want) || null;
  },
};
const DISTRICTS_BD = ['Dhaka', 'Faridpur', 'Gazipur', 'Gopalganj', 'Kishoreganj', 'Madaripur', 'Manikganj', 'Munshiganj', 'Narayanganj', 'Narsingdi', 'Rajbari', 'Shariatpur', 'Tangail',
  'Chattogram', 'Bandarban', 'Brahmanbaria', 'Chandpur', "Cox's Bazar", 'Cumilla', 'Feni', 'Khagrachhari', 'Lakshmipur', 'Noakhali', 'Rangamati',
  'Rajshahi', 'Bogura', 'Chapai Nawabganj', 'Joypurhat', 'Naogaon', 'Natore', 'Pabna', 'Sirajganj', 'Khulna', 'Bagerhat', 'Chuadanga', 'Jashore', 'Jhenaidah', 'Kushtia', 'Magura', 'Meherpur', 'Narail', 'Satkhira',
  'Barishal', 'Barguna', 'Bhola', 'Jhalokathi', 'Patuakhali', 'Pirojpur', 'Sylhet', 'Habiganj', 'Moulvibazar', 'Sunamganj',
  'Rangpur', 'Dinajpur', 'Gaibandha', 'Kurigram', 'Lalmonirhat', 'Nilphamari', 'Panchagarh', 'Thakurgaon', 'Mymensingh', 'Jamalpur', 'Netrokona', 'Sherpur'];
