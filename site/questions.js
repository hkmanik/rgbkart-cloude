// Product questions & answers on product.html (0032_product_questions.sql).
// RGBQuestions.section(db, product) → element: answered questions for everyone, an "Ask" form for shoppers (guests get the
// invisible guest sign-in), the shopper's own waiting questions, and for the product's seller an answer box under each question.
// Needs i18n.js (T, N, RGBLang).
(function () {
  const css = `
    .qa { display: grid; gap: 14px; }
    .qa-ask { display: grid; gap: 8px; }
    .qa-ask textarea, .qa-ans textarea { font: inherit; padding: 10px 12px; border: 1px solid var(--line); border-radius: 10px; background: var(--bg); color: var(--fg); resize: vertical; min-height: 64px; width: 100%; box-sizing: border-box; }
    .qa-row { display: flex; flex-wrap: wrap; gap: 8px 12px; align-items: center; justify-content: space-between; }
    .qa-note { color: var(--muted); font-size: .84rem; margin: 0; }
    .qa-btn { border: 0; border-radius: 999px; padding: 9px 20px; font: inherit; font-weight: 700; cursor: pointer; background: var(--accent); color: var(--accent-fg, #fff); }
    .qa-btn:disabled { opacity: .6; }
    .qa-btn.line { background: none; border: 1.5px solid var(--accent); color: var(--accent); }
    .qa-err { color: #B3000C; font-size: .9rem; margin: 0; }
    .qa-list { display: grid; }
    .qa-item { padding: 12px 0; border-top: 1px solid var(--line); display: grid; gap: 6px; }
    .qa-item:first-child { border-top: 0; }
    .qa-q, .qa-a { display: grid; grid-template-columns: 26px minmax(0, 1fr); gap: 8px; align-items: start; }
    .qa-q b.tag, .qa-a b.tag { display: grid; place-items: center; width: 24px; height: 24px; border-radius: 6px; font-size: .8rem; }
    .qa-q b.tag { background: #FFF4CC; color: #7A5A00; }
    .qa-a b.tag { background: var(--accent-soft); color: var(--accent); }
    .qa-q p, .qa-a p { margin: 0; overflow-wrap: anywhere; }
    .qa-q p { font-weight: 600; color: var(--fg); }
    .qa-meta { display: block; color: var(--faint); font-size: .78rem; margin-top: 2px; font-weight: 400; }
    .qa-wait { color: var(--warn, #8a5a00); font-size: .85rem; }
    .qa-sub { margin: 4px 0 0; font: 600 .95rem var(--display, inherit); }
    .qa-ans { display: grid; gap: 8px; margin-left: 34px; }
    .qa-empty { color: var(--muted); margin: 0; }
    .qa-more { justify-self: start; }`;
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
  const bn = () => document.documentElement.lang === 'bn';
  const day = t => RGBLang.date(t, { day: 'numeric', month: 'short', year: 'numeric' });

  function section(db, P, onReady) {
    const box = el('div', { class: 'qa' });
    let me = null, mine = [], answered = [], sellerAll = [], shown = 5;
    const isSeller = () => me && me.id === P.seller_id;

    async function load() {
      const { data: { session } } = await db.auth.getSession();
      me = session ? session.user : null;
      const pub = await db.from('public_questions').select('*').eq('product_id', P.id).order('answered_at', { ascending: false }).limit(200);
      if (pub.error) { box.innerHTML = ''; return; }                // 0032 not run yet: show nothing
      answered = pub.data || [];
      if (onReady) { onReady(); onReady = null; }
      mine = []; sellerAll = [];
      if (me) {
        const r = await db.from('product_questions').select('*').eq('product_id', P.id).order('created_at', { ascending: false }).limit(300);
        const rows = r.data || [];
        if (isSeller()) sellerAll = rows.filter(q => !q.is_hidden);
        else mine = rows.filter(q => q.asker_id === me.id && !q.answer && !q.is_hidden);
      }
      draw();
    }

    function item(q, opts) {
      const it = el('div', { class: 'qa-item' },
        el('div', { class: 'qa-q' }, el('b', { class: 'tag', translate: 'no', text: bn() ? 'প্র' : 'Q' }),
          el('p', {}, el('span', { text: q.question, translate: 'no' }), el('span', { class: 'qa-meta', text: `${q.asker_name === 'Guest' ? T('Guest') : q.asker_name} · ${day(q.created_at)}` }))),
        q.answer ? el('div', { class: 'qa-a' }, el('b', { class: 'tag', translate: 'no', text: bn() ? 'উ' : 'A' }),
          el('p', {}, el('span', { text: q.answer, translate: 'no' }), el('span', { class: 'qa-meta', text: T('Seller') + ' · ' + day(q.answered_at) })))
          : opts && opts.waiting ? el('span', { class: 'qa-wait', text: T('Waiting for the seller to answer') }) : null);
      if (opts && opts.answerBox) it.append(answerBox(q));
      return it;
    }

    function answerBox(q) {
      const ta = el('textarea', { maxlength: 1000, placeholder: T('Write your answer. Everyone can see it.'), 'aria-label': T('Your answer') });
      ta.value = q.answer || '';
      const err = el('p', { class: 'qa-err', role: 'alert', hidden: true });
      const btn = el('button', { type: 'button', class: 'qa-btn', text: T(q.answer ? 'Save answer' : 'Send answer') });
      const wrap = el('div', { class: 'qa-ans', hidden: !!q.answer }, ta, err, el('div', { class: 'qa-row' }, btn));
      btn.onclick = async () => {
        err.hidden = true;
        if (!ta.value.trim()) { err.textContent = T('Please write your answer'); err.hidden = false; return; }
        btn.disabled = true;
        const { error } = await db.rpc('answer_question', { p_question: q.id, p_answer: ta.value.trim() });
        btn.disabled = false;
        if (error) { err.textContent = T(error.message); err.hidden = false; return; }
        load();
      };
      if (!q.answer) return wrap;
      const edit = el('button', { type: 'button', class: 'qa-btn line', style: 'justify-self:start;margin-left:34px;padding:5px 14px;font-size:.85rem', text: T('Edit answer'), onclick: () => { wrap.hidden = false; edit.remove(); ta.focus(); } });
      return el('div', { style: 'display:grid;gap:8px' }, edit, wrap);
    }

    function askForm() {
      const ta = el('textarea', { maxlength: 500, placeholder: T('Ask the seller about this product: size, colour, warranty, delivery…'), 'aria-label': T('Your question') });
      const err = el('p', { class: 'qa-err', role: 'alert', hidden: true });
      const btn = el('button', { type: 'button', class: 'qa-btn', text: T('Ask question') });
      btn.onclick = async () => {
        err.hidden = true;
        const q = ta.value.trim();
        if (q.length < 3) { err.textContent = T('Please write your question'); err.hidden = false; ta.focus(); return; }
        btn.disabled = true;
        try {
          const { data: { session } } = await db.auth.getSession();
          if (!session) { const a = await db.auth.signInAnonymously(); if (a.error) throw a.error; }
          const { error } = await db.rpc('ask_question', { p_product: P.id, p_question: q });
          if (error) throw error;
          ta.value = '';
          if (typeof toast === 'function') toast(T('Question sent. You will get an alert when the seller answers.'));
          await load();
        } catch (e) { err.textContent = T(e.message || 'Something went wrong. Please try again.'); err.hidden = false; }
        btn.disabled = false;
      };
      return el('div', { class: 'qa-ask' }, ta, err,
        el('div', { class: 'qa-row' }, el('p', { class: 'qa-note', text: T('Answers are shown to everyone. Please do not write your phone number here.') }), btn));
    }

    function draw() {
      box.innerHTML = '';
      if (isSeller()) {
        const waiting = sellerAll.filter(q => !q.answer), done = sellerAll.filter(q => q.answer);
        box.append(el('p', { class: 'qa-note', text: T('This is your product. Answer buyers\' questions here; answers are shown to everyone.') }));
        if (waiting.length) box.append(el('h3', { class: 'qa-sub', text: T('Waiting for your answer ({n})', { n: waiting.length }) }), el('div', { class: 'qa-list' }, waiting.map(q => item(q, { answerBox: true }))));
        if (done.length) box.append(el('h3', { class: 'qa-sub', text: T('Answered') }), el('div', { class: 'qa-list' }, done.map(q => item(q, { answerBox: true }))));
        if (!sellerAll.length) box.append(el('p', { class: 'qa-empty', text: T('No questions yet.') }));
        return;
      }
      box.append(askForm());
      if (mine.length) box.append(el('h3', { class: 'qa-sub', text: T('Your questions') }), el('div', { class: 'qa-list' }, mine.map(q => item(q, { waiting: true }))));
      if (!answered.length) { box.append(el('p', { class: 'qa-empty', text: T('No questions yet. Be the first to ask.') })); return; }
      const list = el('div', { class: 'qa-list' }, answered.slice(0, shown).map(q => item(q)));
      box.append(list);
      if (answered.length > shown) box.append(el('button', { type: 'button', class: 'qa-btn line qa-more', text: T('Show more ({n} left)', { n: answered.length - shown }), onclick: () => { shown += 10; draw(); } }));
    }

    load();
    return box;
  }
  window.RGBQuestions = { section };
})();
