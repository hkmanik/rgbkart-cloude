// RGBKart reviews & ratings on shopper pages (0029_reviews.sql).
// RGBReviews.stars(avg), RGBReviews.line(row) → "★★★★☆ 4.2 (12)", RGBReviews.section(db, { product: id } | { shop: sellerId }) → panel with summary + list.
// Needs i18n.js (T, N, RGBLang). Works with or without shop.js.
(function () {
  const css = `
    .stars { --r: 0; display: inline-block; letter-spacing: 1px; line-height: 1; white-space: nowrap; color: transparent !important;
      background: linear-gradient(90deg, #F5C400 calc(var(--r) / 5 * 100%), #cfd6d1 0); -webkit-background-clip: text; background-clip: text; }
    .rt { display: inline-flex; align-items: center; gap: 5px; font-size: .86rem; color: var(--muted); font-variant-numeric: tabular-nums; text-decoration: none; }
    .rt b { color: var(--fg); font-weight: 700; }
    a.rt:hover span:last-child { text-decoration: underline; }
    .rv-sum { display: grid; grid-template-columns: auto minmax(0, 1fr); gap: 22px; align-items: center; padding-bottom: 12px; border-bottom: 1px solid var(--line); }
    .rv-sum .big { text-align: center; min-width: 110px; }
    .rv-sum .big b { display: block; font: 700 2.6rem/1 Poppins, system-ui, sans-serif; color: var(--fg); }
    .rv-sum .big .stars { font-size: 1.15rem; margin: 6px 0 4px; }
    .rv-sum .big small { color: var(--muted); }
    .rv-bars { display: grid; gap: 5px; font-size: .82rem; color: var(--muted); max-width: 420px; }
    .rv-bars div { display: grid; grid-template-columns: 34px minmax(0, 1fr) 30px; align-items: center; gap: 8px; }
    .rv-bars i { display: block; height: 8px; border-radius: 99px; background: var(--line); overflow: hidden; }
    .rv-bars i span { display: block; height: 100%; background: #F5C400; border-radius: 99px; }
    .rv { padding: 14px 0; border-bottom: 1px solid var(--line); display: grid; gap: 6px; }
    .rv:last-child { border-bottom: 0; }
    .rv-top { display: flex; flex-wrap: wrap; align-items: center; gap: 6px 12px; }
    .rv-top .who { font-weight: 600; color: var(--fg); }
    .rv-top .vb { font-size: .74rem; color: var(--accent); font-weight: 600; }
    .rv-top .d { color: var(--faint); font-size: .8rem; margin-left: auto; }
    .rv .var { color: var(--muted); font-size: .8rem; }
    .rv p { margin: 0; overflow-wrap: anywhere; color: var(--fg); }
    .rv .reply { background: var(--bg); border-left: 3px solid var(--accent); border-radius: 0 8px 8px 0; padding: 8px 12px; font-size: .92rem; }
    .rv .reply b { display: block; font-size: .8rem; color: var(--accent); margin-bottom: 2px; }
    .rv-empty { color: var(--muted); margin: 4px 0 0; }
    .rv-more { margin-top: 8px; border: 1.5px solid var(--accent); color: var(--accent); background: none; border-radius: 999px; padding: 7px 18px; font: inherit; font-weight: 600; cursor: pointer; }
    .rv-more:hover { background: var(--accent); color: var(--accent-fg, #fff); }
    .rv-filter { display: flex; flex-wrap: wrap; gap: 6px; margin: 12px 0 2px; }
    .rv-filter button { border: 1px solid var(--line); background: var(--surface); color: var(--fg); border-radius: 999px; padding: 4px 12px; font: inherit; font-size: .84rem; cursor: pointer; }
    .rv-filter button[aria-pressed="true"] { background: var(--accent); border-color: var(--accent); color: var(--accent-fg, #fff); }
    @media (max-width: 480px) { .rv-sum { grid-template-columns: 1fr; } .rv-sum .big { text-align: left; } }`;
  const st = document.createElement('style'); st.textContent = css; document.head.append(st);

  function el(tag, props, ...kids) {
    const e = document.createElement(tag);
    for (const [k, v] of Object.entries(props || {})) {
      if (v == null || v === false) continue;
      if (k.startsWith('on')) e[k] = v; else if (k === 'class') e.className = v; else if (k === 'text') e.textContent = v; else e.setAttribute(k, v === true ? '' : v);
    }
    for (const kid of kids.flat()) if (kid != null && kid !== false) e.append(kid);
    return e;
  }
  const fix1 = v => N(Number(v || 0).toFixed(1));

  function stars(avg) {
    const r = Math.max(0, Math.min(5, Number(avg) || 0));
    return el('span', { class: 'stars', style: `--r:${r}`, role: 'img', 'aria-label': T('Rated {a} out of 5', { a: r.toFixed(1) }), text: '★★★★★' });
  }
  function line(x, href) {
    if (!x || !x.rating_count) return null;
    return el(href ? 'a' : 'span', { class: 'rt', href }, stars(x.rating_avg), el('b', { text: fix1(x.rating_avg) }),
      el('span', { text: T(x.rating_count === 1 ? '({n} review)' : '({n} reviews)', { n: x.rating_count }) }));
  }

  // Panel content: summary bars + newest reviews, 10 at a time, filter by stars
  function section(db, opt) {
    const box = el('div', { class: 'rv-wrap' });
    const PAGE = 10;
    let all = [], filter = 0, shown = PAGE;
    const base = () => {
      let q = db.from('public_reviews').select('*');
      q = opt.product ? q.eq('product_id', opt.product) : q.eq('seller_id', opt.shop).eq('kind', 'shop');
      return q.order('created_at', { ascending: false }).limit(500);
    };
    function draw() {
      box.innerHTML = '';
      if (!all.length) {
        box.append(el('p', { class: 'rv-empty', text: T(opt.product ? 'No reviews yet. Buyers can rate this product after their order is delivered.' : 'No reviews yet. Buyers can rate the shop after their order is delivered.') }));
        return;
      }
      const avg = all.reduce((a, r) => a + r.rating, 0) / all.length;
      const cnt = [0, 0, 0, 0, 0, 0]; all.forEach(r => cnt[r.rating]++);
      box.append(el('div', { class: 'rv-sum' },
        el('div', { class: 'big' }, el('b', { text: fix1(avg) }), stars(avg), el('small', { text: T(all.length === 1 ? '{n} review' : '{n} reviews', { n: all.length }) })),
        el('div', { class: 'rv-bars' }, [5, 4, 3, 2, 1].map(n => el('div', {}, el('span', { text: N(n) + ' ★' }),
          el('i', {}, el('span', { style: `width:${Math.round(cnt[n] / all.length * 100)}%` })), el('span', { text: N(cnt[n]) }))))));
      if (all.length > 3) box.append(el('div', { class: 'rv-filter' }, [0, 5, 4, 3, 2, 1].map(n => el('button', { type: 'button', 'aria-pressed': String(filter === n),
        text: n ? N(n) + ' ★ (' + N(cnt[n]) + ')' : T('All'), onclick: () => { filter = n; shown = PAGE; draw(); } }))));
      const list = all.filter(r => !filter || r.rating === filter);
      const ul = el('div', { class: 'rv-list' });
      list.slice(0, shown).forEach(r => ul.append(el('article', { class: 'rv' },
        el('div', { class: 'rv-top' }, stars(r.rating), el('span', { class: 'who', text: r.reviewer_name, translate: 'no' }), el('span', { class: 'vb', text: T('✓ Verified buyer') }),
          el('span', { class: 'd', text: RGBLang.date(r.created_at, { day: 'numeric', month: 'short', year: 'numeric' }) })),
        r.variant_label && el('span', { class: 'var', text: r.variant_label, translate: 'no' }),
        r.comment && el('p', { text: r.comment, translate: 'no' }),
        r.reply && el('div', { class: 'reply' }, el('b', { text: T('Reply from the shop') }), el('span', { text: r.reply, translate: 'no' })))));
      if (!list.length) ul.append(el('p', { class: 'rv-empty', text: T('No reviews with these stars.') }));
      box.append(ul);
      if (list.length > shown) box.append(el('button', { type: 'button', class: 'rv-more', text: T('Show more ({n} left)', { n: list.length - shown }), onclick: () => { shown += PAGE; draw(); } }));
    }
    box.append(el('p', { class: 'rv-empty', text: T('Loading…') }));
    base().then(r => { all = r.error ? [] : (r.data || []); if (opt.onload) opt.onload(all); draw(); });
    return box;
  }

  window.RGBReviews = { stars, line, section };
})();
