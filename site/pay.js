// RGBKart pay form: seller pays a Featured or ad fee by bKash / Nagad / Upay / Rocket and sends the TrxID.
// Needs the page's Supabase client `db`. Usage: RGBPay.form({ kind: 'featured' | 'ad', ref: id, amount, title, onDone })
(function () {
  const CSS = `
  .rpay { border: 1.5px solid #F5C400; background: #FFFBEA; border-radius: 12px; padding: 14px; display: grid; gap: 12px; color: #14211C; margin-top: 8px; }
  .rpay h4 { margin: 0; font: 700 1rem/1.3 var(--display, system-ui); }
  .rpay .rp-amt { color: #B8000C; }
  .rpay .rp-methods { display: flex; flex-wrap: wrap; gap: 8px; }
  .rpay .rp-m { border: 1.5px solid #D9E2DC; background: #fff; color: #14211C; border-radius: 10px; padding: 8px 14px; font: 700 .92rem var(--body, system-ui); cursor: pointer; display: inline-flex; align-items: center; gap: 8px; }
  .rpay .rp-m i { width: 12px; height: 12px; border-radius: 50%; display: inline-block; }
  .rpay .rp-m[aria-pressed="true"] { border-color: #00802B; box-shadow: inset 0 0 0 1px #00802B; background: #E5F4EA; }
  .rpay .rp-to { background: #fff; border: 1px dashed #A87400; border-radius: 10px; padding: 10px 12px; display: grid; gap: 4px; font-size: .92rem; }
  .rpay .rp-no { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; font: 700 1.25rem/1.2 var(--body, system-ui); letter-spacing: .03em; font-variant-numeric: tabular-nums; }
  .rpay .rp-copy { font: 600 .8rem var(--body, system-ui); border: 1px solid #D9E2DC; background: #fff; border-radius: 8px; padding: 4px 10px; cursor: pointer; color: #00802B; }
  .rpay .rp-steps { margin: 0; padding-left: 20px; font-size: .88rem; display: grid; gap: 3px; color: #3d4a45; }
  .rpay label { display: grid; gap: 5px; font-size: .82rem; font-weight: 600; color: #5A6A62; text-transform: none; letter-spacing: 0; }
  .rpay input { font: inherit; font-size: 16px; color: #14211C; background: #fff; border: 1px solid #D9E2DC; border-radius: 10px; padding: 10px 12px; width: 100%; min-width: 0; }
  .rpay input:focus-visible, .rpay button:focus-visible { outline: 2px solid #00802B; outline-offset: 1px; }
  .rpay .rp-two { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
  @media (max-width: 520px) { .rpay .rp-two { grid-template-columns: 1fr; } }
  .rpay .rp-send { border: 0; border-radius: 10px; padding: 12px 16px; background: #00802B; color: #fff; font: 700 1rem var(--body, system-ui); cursor: pointer; }
  .rpay .rp-send:hover:not(:disabled) { background: #E30613; }
  .rpay .rp-send:disabled { opacity: .6; cursor: wait; }
  .rpay .rp-err { color: #B3392F; font-size: .9rem; margin: 0; }
  .rpay .rp-ok { color: #1F7A5A; font-weight: 600; margin: 0; }
  .rpay .rp-note { font-size: .8rem; color: #5A6A62; margin: 0; }`;
  const TYPE = { personal: 'Personal number: use “Send Money”', merchant: 'Merchant number: use “Payment”', agent: 'Agent number' };
  let methods = null;

  function el(tag, props, ...kids) {
    const e = document.createElement(tag);
    for (const [k, v] of Object.entries(props || {})) {
      if (v == null || v === false) continue;
      if (k.startsWith('on')) e[k] = v; else if (k === 'class') e.className = v; else if (k === 'text') e.textContent = v; else e.setAttribute(k, v === true ? '' : v);
    }
    for (const kid of kids.flat()) if (kid != null && kid !== false) e.append(kid);
    return e;
  }
  const money = n => '৳' + Number(n || 0).toLocaleString('en-IN', { maximumFractionDigits: 2 });

  async function load() {
    if (methods) return methods;
    if (!document.getElementById('rpayCss')) document.head.append(el('style', { id: 'rpayCss', text: CSS }));
    const r = await db.from('payment_methods').select('id, name, account_no, account_type, instructions, color').eq('is_active', true).order('sort_order');
    methods = r.error ? [] : r.data;
    return methods;
  }

  function form({ kind, ref, amount, title, onDone }) {
    const box = el('div', { class: 'rpay' }, el('p', { class: 'rp-note', text: 'Loading payment options…' }));
    load().then(list => {
      box.innerHTML = '';
      box.append(el('h4', {}, 'Pay ', el('span', { class: 'rp-amt', text: money(amount) }), title ? ` for “${title}”` : ''));
      if (!list.length) { box.append(el('p', { class: 'rp-note', text: 'Payment numbers aren\'t set up yet. Our team will contact you about payment.' })); return; }
      let pick = list[0];
      const choose = el('div', { class: 'rp-methods', role: 'group', 'aria-label': 'Pay with' });
      const to = el('div', { class: 'rp-to', 'aria-live': 'polite' });
      const sender = el('input', { type: 'tel', inputmode: 'tel', maxlength: '16', placeholder: '01XXXXXXXXX', autocomplete: 'tel' });
      const trx = el('input', { type: 'text', maxlength: '24', placeholder: 'e.g. 9FR4KD2LQ1', autocomplete: 'off', autocapitalize: 'characters', spellcheck: 'false' });
      const err = el('p', { class: 'rp-err', role: 'alert', hidden: true });
      const send = el('button', { type: 'button', class: 'rp-send', text: `I have paid ${money(amount)}` });
      const senderLbl = el('span', {});
      const drawTo = () => {
        choose.querySelectorAll('.rp-m').forEach(b => b.setAttribute('aria-pressed', String(b.dataset.id === pick.id)));
        to.innerHTML = '';
        const copy = el('button', { type: 'button', class: 'rp-copy', text: 'Copy', onclick: async () => { try { await navigator.clipboard.writeText(pick.account_no); copy.textContent = 'Copied ✓'; setTimeout(() => copy.textContent = 'Copy', 1500); } catch (_) {} } });
        to.append(el('span', { text: `Send ${money(amount)} by ${pick.name} to:` }), el('div', { class: 'rp-no' }, pick.account_no, copy),
          el('ol', { class: 'rp-steps' }, el('li', { text: TYPE[pick.account_type] || '' }), el('li', { text: `Amount: ${money(amount)}` }),
            el('li', { text: `Reference: ${kind === 'ad' ? 'AD' : 'F'}${ref}` }), pick.instructions && el('li', { text: pick.instructions }),
            el('li', { text: 'Then enter your number and the TrxID from the confirmation message below.' })));
        senderLbl.textContent = `Your ${pick.name} number (you paid from)`;
      };
      list.forEach(m => choose.append(el('button', { type: 'button', class: 'rp-m', 'data-id': m.id, onclick: () => { pick = m; drawTo(); } }, el('i', { style: `background:${m.color}` }), m.name)));
      send.onclick = async () => {
        err.hidden = true;
        const s = sender.value.replace(/[^0-9+]/g, ''), t = trx.value.replace(/[^A-Za-z0-9]/g, '').toUpperCase();
        if (!/^(\+?880)?01[3-9][0-9]{8}$/.test(s)) { err.textContent = 'Enter the mobile number you paid from, like 01711000000.'; err.hidden = false; return sender.focus(); }
        if (!/^[A-Z0-9]{6,20}$/.test(t)) { err.textContent = 'Enter the Transaction ID (TrxID) from your payment message. It has 6 to 20 letters and numbers.'; err.hidden = false; return trx.focus(); }
        send.disabled = true; send.textContent = 'Sending…';
        const r = await db.rpc('submit_payment', { p_kind: kind, p_ref: ref, p_method: pick.id, p_sender: s, p_trx: t });
        send.disabled = false; send.textContent = `I have paid ${money(amount)}`;
        if (r.error) {
          const m = r.error.message || '';
          err.textContent = /Failed to fetch/i.test(m) ? 'No internet connection. Try again.' : /Could not find the function/i.test(m) ? 'Payments aren\'t switched on yet. Please try again later.' : m;
          err.hidden = false; return;
        }
        box.innerHTML = '';
        box.append(el('p', { class: 'rp-ok', text: `✓ Payment sent (${pick.name}, TrxID ${t}). Our team will check it soon, usually within a few hours.` }));
        if (onDone) onDone();
      };
      box.append(el('span', { class: 'rp-note', text: 'Pay with' }), choose, to,
        el('div', { class: 'rp-two' }, el('label', {}, senderLbl, sender), el('label', {}, 'Transaction ID (TrxID)', trx)),
        err, send, el('p', { class: 'rp-note', text: 'Each TrxID can be used only once. Featured or your ad starts as soon as we confirm the payment.' }));
      drawTo();
    });
    return box;
  }

  window.RGBPay = { form, load };
})();
