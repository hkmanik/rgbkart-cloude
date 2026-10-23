// RGBKart "Report" button and form (0030_reports_fraud.sql).
// RGBReport.link(db, { product: id } | { shop: sellerId }) → a small link that opens the report form.
// Guests are signed in invisibly (like Messages) so the report can be sent. Needs i18n.js (T).
(function () {
  const css = `
    .rp-link { background: none; border: 0; padding: 4px 0; font: inherit; font-size: .85rem; color: var(--muted); cursor: pointer; text-decoration: underline; text-underline-offset: 2px; }
    .rp-link:hover { color: #E30613; }
    .rp-back { position: fixed; inset: 0; background: rgb(0 0 0 / .45); z-index: 1000; display: grid; place-items: center; padding: 16px; }
    .rp-box { background: var(--surface, #fff); color: var(--fg, #14211C); border-radius: 16px; width: min(480px, 100%); max-height: calc(100vh - 32px); overflow: auto;
      padding: 20px; display: grid; gap: 12px; box-shadow: 0 20px 50px rgb(0 0 0 / .3); }
    .rp-box h2 { margin: 0; font: 600 1.15rem Poppins, "Hind Siliguri", system-ui, sans-serif; }
    .rp-box p { margin: 0; color: var(--muted, #5A6A62); font-size: .9rem; }
    .rp-reasons { display: grid; gap: 6px; }
    .rp-reasons label { display: flex; gap: 10px; align-items: flex-start; border: 1px solid var(--line, #D9E2DC); border-radius: 10px; padding: 9px 12px; cursor: pointer; }
    .rp-reasons label:has(input:checked) { border-color: #E30613; background: #FDE7E8; }
    .rp-reasons input { margin-top: 3px; accent-color: #E30613; }
    .rp-box textarea, .rp-box input[type=text] { font: inherit; padding: 9px 11px; border: 1px solid var(--line, #D9E2DC); border-radius: 9px; background: var(--bg, #F4F7F5); color: inherit; width: 100%; box-sizing: border-box; }
    .rp-box textarea { resize: vertical; min-height: 70px; }
    .rp-err { color: #B3000C; font-size: .9rem; }
    .rp-btns { display: flex; gap: 8px; justify-content: flex-end; flex-wrap: wrap; }
    .rp-btns button { font: inherit; font-weight: 600; border-radius: 999px; padding: 9px 18px; cursor: pointer; border: 1.5px solid var(--line, #D9E2DC); background: var(--surface, #fff); color: inherit; }
    .rp-btns .send { background: #E30613; border-color: #E30613; color: #fff; }
    .rp-btns .send:disabled { opacity: .6; }
    .rp-done { text-align: center; display: grid; gap: 10px; justify-items: center; padding: 10px 0; }
    .rp-done b { font-size: 1.1rem; }
    @media (prefers-color-scheme: dark) { .rp-reasons label:has(input:checked) { background: #3d201d; } }`;
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
  const REASONS = [
    ['fake', 'Fake or copy product'], ['scam', 'Scam or fraud (asks for advance money, fake payment…)'], ['no_delivery', 'Ordered but never delivered'],
    ['wrong_info', 'Wrong price, photos or information'], ['prohibited', 'Item not allowed for sale'], ['offensive', 'Rude or offensive'],
    ['spam', 'Spam or repeated listing'], ['other', 'Something else'],
  ];

  function open(db, opt) {
    const prev = document.activeElement;
    const close = () => { back.remove(); document.removeEventListener('keydown', onKey); prev && prev.focus && prev.focus(); };
    const onKey = e => { if (e.key === 'Escape') close(); };
    const reasons = el('div', { class: 'rp-reasons', role: 'radiogroup', 'aria-label': T('Reason') },
      REASONS.filter(([k]) => opt.product || k !== 'wrong_info').map(([k, t]) => el('label', {}, el('input', { type: 'radio', name: 'rp-reason', value: k }), el('span', { text: T(t) }))));
    const details = el('textarea', { maxlength: 1000, placeholder: T('What happened? Order number, dates, what the seller said… (helps us check faster)'), 'aria-label': T('Details') });
    const contact = el('input', { type: 'text', maxlength: 80, placeholder: T('Your phone or email (optional, if we need to ask you)'), 'aria-label': T('Your phone or email') });
    const err = el('p', { class: 'rp-err', role: 'alert', hidden: true });
    const send = el('button', { type: 'button', class: 'send', text: T('Send report') });
    const box = el('div', { class: 'rp-box', role: 'dialog', 'aria-modal': 'true', 'aria-labelledby': 'rpTitle' },
      el('h2', { id: 'rpTitle', text: T(opt.product ? 'Report this product' : 'Report this shop') }),
      el('p', { text: T('Tell RGBKart staff what is wrong. The seller will not see your name.') }),
      reasons, details, contact, err,
      el('div', { class: 'rp-btns' }, el('button', { type: 'button', text: T('Cancel'), onclick: close }), send));
    reasons.onchange = () => { err.hidden = true; };
    const back = el('div', { class: 'rp-back', onclick: e => { if (e.target === back) close(); } }, box);
    send.onclick = async () => {
      err.hidden = true;
      const r = box.querySelector('input[name=rp-reason]:checked');
      if (!r) { err.textContent = T('Please choose a reason.'); err.hidden = false; return; }
      if (r.value === 'other' && !details.value.trim()) { err.textContent = T('Please tell us what is wrong'); err.hidden = false; details.focus(); return; }
      send.disabled = true;
      try {
        const { data: { session } } = await db.auth.getSession();
        if (!session) { const a = await db.auth.signInAnonymously(); if (a.error) throw a.error; }
        const { error } = await db.rpc('submit_report', { p_product: opt.product || null, p_seller: opt.product ? null : opt.shop, p_reason: r.value, p_details: details.value.trim() || null, p_contact: contact.value.trim() || null });
        if (error) throw error;
        box.innerHTML = '';
        box.append(el('div', { class: 'rp-done' }, el('span', { style: 'font-size:2rem', text: '✓' }), el('b', { text: T('Thank you. Our team will check it.') }),
          el('p', { text: T('If you placed an order, you can also call the shop or cancel it from My orders.') }),
          el('div', { class: 'rp-btns' }, el('button', { type: 'button', text: T('Close'), onclick: close }))));
        box.querySelector('button').focus();
      } catch (e) {
        send.disabled = false; err.textContent = T(e.message || 'Something went wrong. Please try again.'); err.hidden = false;
      }
    };
    document.body.append(back); document.addEventListener('keydown', onKey);
    box.querySelector('input').focus();
  }

  function link(db, opt) {
    return el('button', { type: 'button', class: 'rp-link', text: T(opt.product ? '⚑ Report this product' : '⚑ Report this shop'), onclick: () => open(db, opt) });
  }
  window.RGBReport = { link, open };
})();
