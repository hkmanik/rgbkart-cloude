// RGBKart order printing: invoice, packing list and shipping label, for one order or many at once.
// Used by Seller Center (and can be used by Admin). Printer setup is kept on this computer (localStorage 'rgbkart-print').
//   RGBPrint.open(kind, orders, shop)   kind = 'invoice' | 'packing' | 'label'
//   RGBPrint.settings() / RGBPrint.save(obj) / RGBPrint.SIZES
// orders: rows from the orders table with order_items; shop: the seller's seller_details row (name, phone, address, logo_path).
(function () {
  const KEY = 'rgbkart-print';
  const SIZES = {
    doc: { a4: ['A4 (210 × 297 mm)', '210mm 297mm'], a5: ['A5 (148 × 210 mm)', '148mm 210mm'], letter: ['Letter (8.5 × 11 in)', '8.5in 11in'], thermal80: ['Receipt printer 80 mm', '80mm auto'] },
    label: { l4x6: ['Label 4 × 6 in (100 × 150 mm)', '100mm 150mm'], l100: ['Label 100 × 100 mm', '100mm 100mm'], l3x5: ['Label 3 × 5 in (75 × 125 mm)', '75mm 125mm'],
             a4x2: ['A4 sheet, 2 labels', '210mm 297mm'], a4x4: ['A4 sheet, 4 labels', '210mm 297mm'] },
  };
  const DEFAULTS = { docSize: 'a4', labelSize: 'l4x6', copies: 1, showLogo: true, barcode: true, packPrices: false, footer: 'Thank you for shopping with us! Please check the item when it arrives.', autoPrint: true };
  function settings() { try { return { ...DEFAULTS, ...JSON.parse(localStorage.getItem(KEY) || '{}') }; } catch (_) { return { ...DEFAULTS }; } }
  function save(s) { try { localStorage.setItem(KEY, JSON.stringify({ ...settings(), ...s })); } catch (_) {} }

  const esc = t => String(t ?? '').replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
  const tk = n => '৳' + Number(n || 0).toLocaleString('en-IN', { maximumFractionDigits: 2 });
  const day = t => new Date(t).toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' });
  const SHIP = { dhaka: 'Inside Dhaka', outside: 'Outside Dhaka', pickup: 'Store pickup', negotiated: 'Agreed with customer' };
  const addr = o => [o.address, o.area, o.district].filter(Boolean).join(', ');

  function head(o, shop, title, s, logoUrl) {
    return `<div class="hd"><div class="from">${s.showLogo && logoUrl ? `<img class="logo" src="${esc(logoUrl)}" alt="">` : ''}<div><div class="shop">${esc(shop.shop_name || 'RGBKart seller')}</div>
      <div class="sm">${esc([shop.business_address, shop.area, shop.city].filter(Boolean).join(', '))}</div><div class="sm">${esc([shop.phone_public, shop.email_public].filter(Boolean).join(' · '))}</div>
      <div class="sm muted">Sold on RGBKart · Red &amp; Green Basket</div></div></div>
      <div class="meta"><div class="ttl">${title}</div><div><b>${esc(o.order_no)}</b></div><div class="sm">${day(o.created_at)}</div>${s.barcode ? `<svg class="bc" data-code="${esc(o.order_no)}"></svg>` : ''}</div></div>`;
  }
  function invoice(o, shop, s, logoUrl) {
    const rows = (o.order_items || []).map((i, k) => `<tr><td class="c">${k + 1}</td><td>${esc(i.title)}${i.variant_label ? `<div class="sm">${esc(i.variant_label)}</div>` : ''}</td><td class="n">${i.qty}</td><td class="n">${tk(i.unit_price)}</td><td class="n">${tk(i.line_total)}</td></tr>`).join('');
    return `<section class="pg">${head(o, shop, 'INVOICE', s, logoUrl)}
      <div class="two"><div class="box"><div class="lb">Bill / deliver to</div><b>${esc(o.customer_name)}</b><div>${esc(o.phone)}</div><div>${esc(addr(o))}</div>${o.email ? `<div class="sm">${esc(o.email)}</div>` : ''}</div>
      <div class="box"><div class="lb">Payment</div><b>Cash on Delivery</b><div>Delivery: ${esc(SHIP[o.ship_method] || o.ship_method)}</div>${o.tracking_note ? `<div class="sm">${esc(o.tracking_note)}</div>` : ''}</div></div>
      <table><thead><tr><th class="c">#</th><th>Item</th><th class="n">Qty</th><th class="n">Price</th><th class="n">Amount</th></tr></thead><tbody>${rows}</tbody>
      <tfoot><tr><td colspan="4">Subtotal</td><td class="n">${tk(o.subtotal)}</td></tr><tr><td colspan="4">Delivery charge</td><td class="n">${o.ship_method === 'negotiated' ? 'As agreed' : tk(o.ship_fee)}</td></tr>${Number(o.discount) > 0 ? `<tr><td colspan="4">Coupon ${esc(o.coupon_code || '')}</td><td class="n">−${tk(o.discount)}</td></tr>` : ''}
      <tr class="tot"><td colspan="4">Total to collect (cash)</td><td class="n">${tk(o.total)}</td></tr>${Number(o.vat_amount) > 0 ? `<tr><td colspan="4" class="sm">Includes VAT ${Number(o.vat_rate)}%</td><td class="n sm">${tk(o.vat_amount)}</td></tr>` : ''}</tfoot></table>
      ${o.note ? `<p class="sm"><b>Customer note:</b> ${esc(o.note)}</p>` : ''}
      ${s.footer ? `<p class="foot">${esc(s.footer)}</p>` : ''}<div class="sign"><span>Received by (customer)</span><span>For ${esc(shop.shop_name || 'the shop')}</span></div></section>`;
  }
  function packing(o, shop, s, logoUrl) {
    const rows = (o.order_items || []).map((i, k) => `<tr><td class="c">${k + 1}</td><td>${esc(i.title)}${i.variant_label ? `<div class="sm">${esc(i.variant_label)}</div>` : ''}</td><td class="n big">${i.qty}</td>${s.packPrices ? `<td class="n">${tk(i.line_total)}</td>` : ''}<td class="c chk">☐</td></tr>`).join('');
    const count = (o.order_items || []).reduce((a, i) => a + i.qty, 0);
    return `<section class="pg">${head(o, shop, 'PACKING LIST', s, logoUrl)}
      <div class="box"><div class="lb">Deliver to</div><b>${esc(o.customer_name)}</b> · ${esc(o.phone)}<div>${esc(addr(o))}</div>${o.note ? `<div class="sm"><b>Note:</b> ${esc(o.note)}</div>` : ''}</div>
      <table><thead><tr><th class="c">#</th><th>Item</th><th class="n">Qty</th>${s.packPrices ? '<th class="n">Amount</th>' : ''}<th class="c">Packed</th></tr></thead><tbody>${rows}</tbody></table>
      <p><b>${count}</b> piece${count === 1 ? '' : 's'} in total · Delivery: ${esc(SHIP[o.ship_method] || o.ship_method)}</p>
      <div class="sign"><span>Packed by</span><span>Checked by</span><span>Date</span></div></section>`;
  }
  function label(o, shop, s) {
    const count = (o.order_items || []).reduce((a, i) => a + i.qty, 0);
    return `<div class="lbl"><div class="lrow"><div class="sm"><b>FROM</b> ${esc([shop.shop_name, shop.phone_public].filter(Boolean).join(' · '))}<br>${esc([shop.area, shop.city].filter(Boolean).join(', '))}</div><div class="brand">RGBKart</div></div>
      <div class="to"><div class="lb">DELIVER TO</div><div class="nm">${esc(o.customer_name)}</div><div class="ph">${esc(o.phone)}</div><div class="ad">${esc([o.address, o.area].filter(Boolean).join(', '))}</div><div class="dist">${esc(o.district)}</div></div>
      <div class="lrow cod"><div><div class="lb">CASH ON DELIVERY</div><div class="amt">${tk(o.total)}</div></div><div class="sm r">${esc(SHIP[o.ship_method] || o.ship_method)}<br>${count} piece${count === 1 ? '' : 's'}<br>${day(o.created_at)}</div></div>
      ${s.barcode ? `<svg class="bc big" data-code="${esc(o.order_no)}"></svg>` : ''}<div class="ono">${esc(o.order_no)}</div>${o.note ? `<div class="sm nt">Note: ${esc(o.note)}</div>` : ''}</div>`;
  }

  function open(kind, orders, shop, logoUrl) {
    const s = settings();
    const list = (orders || []).filter(Boolean);
    if (!list.length) return false;
    const copies = Math.max(1, Math.min(5, Number(s.copies) || 1));
    const many = []; list.forEach(o => { for (let c = 0; c < copies; c++) many.push(o); });
    const isLabel = kind === 'label';
    const size = isLabel ? (SIZES.label[s.labelSize] || SIZES.label.l4x6) : (SIZES.doc[s.docSize] || SIZES.doc.a4);
    const perSheet = isLabel ? ({ a4x2: 2, a4x4: 4 }[s.labelSize] || 1) : 1;
    const thermal = !isLabel && s.docSize === 'thermal80';
    let body = '';
    if (isLabel) {
      for (let k = 0; k < many.length; k += perSheet) body += `<section class="sheet n${perSheet}">${many.slice(k, k + perSheet).map(o => label(o, shop, s)).join('')}</section>`;
    } else body = many.map(o => (kind === 'invoice' ? invoice : packing)(o, shop, s, logoUrl)).join('');
    const title = (isLabel ? 'Shipping labels' : kind === 'invoice' ? 'Invoices' : 'Packing lists') + (list.length === 1 ? ' ' + list[0].order_no : ` (${list.length} orders)`);
    const css = `@page { size: ${size[1]}; margin: ${isLabel || thermal ? '4mm' : '12mm'}; }
      * { box-sizing: border-box; } body { margin: 0; font: ${thermal ? '11px' : '13px'}/1.4 Arial, Helvetica, sans-serif; color: #000; background: #fff; }
      .bar { position: sticky; top: 0; background: #00802B; color: #fff; padding: 10px 14px; display: flex; gap: 10px; align-items: center; font: 600 14px Arial; z-index: 2; }
      .bar button { font: 700 14px Arial; padding: 8px 16px; border-radius: 8px; border: 0; background: #F5C400; color: #2a1a00; cursor: pointer; }
      @media print { .bar { display: none; } }
      .pg { page-break-after: always; break-after: page; padding: ${thermal ? '0' : '0 2px'}; max-width: ${thermal ? '72mm' : 'none'}; }
      .pg:last-child { page-break-after: auto; break-after: auto; }
      .hd { display: flex; justify-content: space-between; gap: 14px; ${thermal ? 'flex-direction: column;' : ''} border-bottom: 2px solid #000; padding-bottom: 8px; margin-bottom: 10px; }
      .from { display: flex; gap: 10px; align-items: flex-start; } .logo { width: 54px; height: 54px; object-fit: contain; }
      .shop { font-size: 1.25em; font-weight: 700; } .sm { font-size: .88em; } .muted { color: #555; } .meta { text-align: ${thermal ? 'left' : 'right'}; }
      .ttl { font-size: 1.4em; font-weight: 800; letter-spacing: .06em; } .bc { height: 38px; max-width: 100%; }
      .two { display: grid; grid-template-columns: ${thermal ? '1fr' : '1fr 1fr'}; gap: 10px; } .box { border: 1px solid #000; border-radius: 4px; padding: 8px 10px; margin-bottom: 10px; }
      .lb { font-size: .75em; font-weight: 700; letter-spacing: .08em; text-transform: uppercase; color: #333; margin-bottom: 2px; }
      table { width: 100%; border-collapse: collapse; margin: 6px 0 10px; } th, td { border-bottom: 1px solid #999; padding: 6px 4px; text-align: left; vertical-align: top; }
      th { border-bottom: 2px solid #000; font-size: .85em; text-transform: uppercase; } .n { text-align: right; white-space: nowrap; } .c { text-align: center; width: 28px; }
      .big { font-size: 1.2em; font-weight: 700; } .chk { font-size: 1.3em; } tfoot td { border: 0; padding: 3px 4px; } .tot td { font-weight: 800; font-size: 1.15em; border-top: 2px solid #000; padding-top: 6px; }
      .foot { border-top: 1px dashed #777; padding-top: 6px; font-size: .9em; } .sign { display: flex; justify-content: space-between; gap: 20px; margin-top: 34px; }
      .sign span { flex: 1; border-top: 1px solid #000; padding-top: 4px; font-size: .85em; text-align: center; }
      .sheet { page-break-after: always; break-after: page; display: grid; height: ${perSheet > 1 ? '273mm' : 'auto'}; gap: 4mm; grid-template-columns: ${perSheet === 4 ? '1fr 1fr' : '1fr'}; grid-template-rows: ${perSheet > 1 ? `repeat(${perSheet === 4 ? 2 : 2}, 1fr)` : 'auto'}; }
      .sheet:last-child { page-break-after: auto; break-after: auto; }
      .lbl { border: 2px solid #000; border-radius: 4px; padding: 3mm; display: flex; flex-direction: column; gap: 2mm; overflow: hidden; min-height: ${perSheet > 1 ? '0' : '140mm'}; }
      .sheet.n1 .lbl { height: ${s.labelSize === 'l100' ? '90mm' : s.labelSize === 'l3x5' ? '115mm' : '140mm'}; min-height: 0; }
      .lrow { display: flex; justify-content: space-between; gap: 6px; align-items: flex-start; } .brand { font-weight: 800; color: #00802B; } .r { text-align: right; }
      .to { border-top: 2px solid #000; border-bottom: 2px solid #000; padding: 2mm 0; flex: 1; } .nm { font-size: 1.5em; font-weight: 800; } .ph { font-size: 1.35em; font-weight: 700; }
      .ad { font-size: 1.1em; } .dist { font-size: 1.6em; font-weight: 800; text-transform: uppercase; margin-top: 1mm; }
      .cod .amt { font-size: 1.9em; font-weight: 800; } .bc.big { height: 52px; width: 100%; } .ono { text-align: center; font: 700 1.1em monospace; letter-spacing: .08em; } .nt { border-top: 1px dashed #000; padding-top: 1mm; }`;
    const auto = s.autoPrint;
    const html = `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>${esc(title)}</title><style>${css}</style>
      ${s.barcode ? '<script src="https://cdn.jsdelivr.net/npm/jsbarcode@3.11.6/dist/JsBarcode.all.min.js"><\/script>' : ''}</head><body>
      <div class="bar">${esc(title)} · ${esc(size[0])}${copies > 1 ? ` · ${copies} copies each` : ''}<span style="flex:1"></span><button onclick="print()">🖨 Print</button></div>${body}
      <script>
        function go() {
          try { if (window.JsBarcode) document.querySelectorAll('svg.bc').forEach(function (e) { JsBarcode(e, e.dataset.code, { format: 'CODE128', displayValue: false, margin: 0, height: e.classList.contains('big') ? 52 : 38, width: e.classList.contains('big') ? 2 : 1.4 }); }); } catch (x) {}
          ${auto ? "setTimeout(function () { window.print(); }, 350);" : ''}
        }
        if (document.readyState === 'complete') go(); else window.addEventListener('load', go);
      <\/script></body></html>`;
    const w = window.open('', '_blank');
    if (!w) return null;
    w.document.open(); w.document.write(html); w.document.close(); w.focus();
    return true;
  }

  window.RGBPrint = { open, settings, save, SIZES, DEFAULTS };
})();
