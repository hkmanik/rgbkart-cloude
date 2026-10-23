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
      db.from('products').select('id, title, title_bn, price, sale_price, sale_starts_at, sale_ends_at, status, seller_id, product_type, manage_stock, stock, backorders, stock_status, free_delivery, ships_to, shipping_class, contact_only, cod_allowed, is_downloadable, sold_individually, product_images(storage_path, sort_order), product_price_tiers(min_qty, unit_price), product_variations(id, price, sale_price, stock, is_active)').in('id', ids),
      db.from('shipping_methods').select('*').eq('is_active', true).order('sort_order'),
    ]);
    const prods = new Map((p.data || []).map(x => [x.id, x]));
    const methods = m.error ? [] : m.data;
    const sellerIds = [...new Set((p.data || []).map(x => x.seller_id))];
    const [s, ss, sd] = sellerIds.length ? await Promise.all([
      db.from('shops').select('*').in('user_id', sellerIds),
      db.from('seller_shipping').select('*').in('seller_id', sellerIds),     // each shop's methods and fees (0045)
      db.from('seller_delivery').select('*').in('seller_id', sellerIds),
    ]) : [{ data: [] }, { data: [] }, { data: [] }];
    const shops = new Map((s.data || []).map(x => [x.user_id, x]));
    const shopShip = new Map(); (ss.error ? [] : ss.data || []).forEach(r => { if (!shopShip.has(r.seller_id)) shopShip.set(r.seller_id, new Map()); shopShip.get(r.seller_id).set(r.method_id, r); });
    const freeOver = new Map((sd.error ? [] : sd.data || []).filter(r => r.free_over).map(r => [r.seller_id, Number(r.free_over)]));

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
      // same rules as place_order (0045): special items need a matching special method; shops choose methods and fees
      const cls = CartLib.SPECIAL.find(c => its.some(i => i.pr.shipping_class === c)) || null;
      const rows = shopShip.get(sid) || new Map(), hasSetup = rows.size > 0;
      const subtotal = its.reduce((a, i) => a + i.unit * i.qty, 0);
      const options = methods.filter(mm => {
        if (mm.id === 'negotiated') return true;
        if (mm.id === 'pickup') return !!shop.allow_pickup;
        if ((mm.for_class || null) !== cls) return false;
        if (hasSetup) { const r = rows.get(mm.id); if (!r || !r.is_on) return false; } else if (mm.for_class) return false;
        const area = CartLib.areaOf(mm);
        if (area === 'dhaka' && its.some(i => i.pr.ships_to === 'outside_dhaka')) return false;
        if (area === 'outside' && its.some(i => i.pr.ships_to === 'inside_dhaka')) return false;
        return true;
      }).sort((a, b) => (['pickup', 'negotiated'].indexOf(a.id) + 1 ? 1 : 0) - (['pickup', 'negotiated'].indexOf(b.id) + 1 ? 1 : 0));   // real delivery first, pickup / agree last
      const allFree = its.every(i => i.pr.free_delivery), over = freeOver.get(sid) || null;
      const feeOf = mm => {
        if (mm.id === 'pickup' || mm.id === 'negotiated') return 0;
        if (!cls && allFree) return 0;
        if (!cls && over && subtotal >= over) return 0;
        const r = rows.get(mm.id), base = Number(r && r.fee != null ? r.fee : mm.fee);
        return mm.max_fee != null ? Math.min(base, Number(mm.max_fee)) : base;
      };
      let method = options.find(o => o.id === choice[sid]) || options[0] || null;
      const fee = method ? feeOf(method) : 0;
      groups.push({ seller: sid, shop, items: its, subtotal, options, method, fee, feeOf, allFree, cls, freeOver: cls ? null : over, total: subtotal + fee, discount: 0, coupon: null });
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
  SPECIAL: ['vehicle', 'flammable', 'heavy', 'fragile'],
  areaOf(mm) { return mm.area || (mm.id === 'dhaka' ? 'dhaka' : mm.id === 'outside' ? 'outside' : 'any'); },
  // Pick a sensible default delivery for a district (Dhaka → an Inside Dhaka method, others → an Outside Dhaka one)
  defaultFor(group, district) {
    if (!district) return null;
    const want = district === 'Dhaka' ? 'dhaka' : 'outside';
    const real = group.options.filter(o => o.id !== 'pickup' && o.id !== 'negotiated');
    return real.find(o => CartLib.areaOf(o) === want) || real.find(o => CartLib.areaOf(o) === 'any') || null;
  },
  isArea(mm) { return mm && mm.id !== 'pickup' && mm.id !== 'negotiated'; },
};
const DISTRICTS_BD = ['Dhaka', 'Faridpur', 'Gazipur', 'Gopalganj', 'Kishoreganj', 'Madaripur', 'Manikganj', 'Munshiganj', 'Narayanganj', 'Narsingdi', 'Rajbari', 'Shariatpur', 'Tangail',
  'Chattogram', 'Bandarban', 'Brahmanbaria', 'Chandpur', "Cox's Bazar", 'Cumilla', 'Feni', 'Khagrachhari', 'Lakshmipur', 'Noakhali', 'Rangamati',
  'Rajshahi', 'Bogura', 'Chapai Nawabganj', 'Joypurhat', 'Naogaon', 'Natore', 'Pabna', 'Sirajganj', 'Khulna', 'Bagerhat', 'Chuadanga', 'Jashore', 'Jhenaidah', 'Kushtia', 'Magura', 'Meherpur', 'Narail', 'Satkhira',
  'Barishal', 'Barguna', 'Bhola', 'Jhalokathi', 'Patuakhali', 'Pirojpur', 'Sylhet', 'Habiganj', 'Moulvibazar', 'Sunamganj',
  'Rangpur', 'Dinajpur', 'Gaibandha', 'Kurigram', 'Lalmonirhat', 'Nilphamari', 'Panchagarh', 'Thakurgaon', 'Mymensingh', 'Jamalpur', 'Netrokona', 'Sherpur'];
