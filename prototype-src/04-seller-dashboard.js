<script>
/* ================= dashboard shell ================= */
function dashShell(kind,tabs,cur,who,body){
 return `<div class="wrap"><div class="dash"><nav class="card side-nav" aria-label="${kind}">${who}
  ${tabs.map(([k,ic,lbl,badge])=>`<button data-go="${kind}:${k}" aria-current="${cur===k?"page":"false"}">${icon(ic)}<span>${lbl}</span>${badge?`<span class="badge num">${N(badge)}</span>`:""}</button>`).join("")}</nav>
  <main class="stack" style="gap:16px;min-width:0">${body}</main></div></div>`;
}
const lsPill=p=>`<span class="pill ${p.status==="approved"?"g":p.status==="rejected"?"r":"y"}">${t("ls_"+p.status)}</span>`;
function fsPill(p){
 if(!p.featured) return `<span class="pill">${t("free_listing")}</span>`;
 if(p.featured==="active"&&p.featuredUntil>Date.now()) return `<span class="pill solid-r">${t("fs_active",{d:fmtShort(p.featuredUntil)})}</span>`;
 if(p.featured==="active") return `<span class="pill">${t("fs_expired")}</span>`;
 return `<span class="pill ${p.featured==="awaiting_payment"?"r":"y"}">${t("fs_"+p.featured)}</span>`;
}
const thumb=p=>`<div class="thumb">${pimg(p)}</div>`;
const kpi=(v,l,alert)=>`<div class="card kpi ${alert?"alert":""}"><span class="v">${v}</span><span class="l">${l}</span></div>`;
const validOrders=o=>o.status!=="cancelled";

/* ================= seller ================= */
function viewSeller(){
 const u=me(); if(!u) return viewLogin(t("need_login"));
 if(u.role!=="seller") return `<div class="wrap"><div class="card empty" style="margin-top:20px">${t("need_seller")}</div></div>`;
 const s=myStore(); const tab=R.p.tab||"overview";
 const prods=S.products.filter(p=>p.storeId===s.id);
 const ords=S.orders.filter(o=>o.storeId===s.id);
 const open=ords.filter(o=>["pending","confirmed","packed"].includes(o.status)).length;
 const unpaid=prods.filter(p=>p.featured==="awaiting_payment").length;
 const tabs=[["overview","grid",t("overview")],["products","box",t("products"),unpaid],["add","plus",t("add_product")],["orders","receipt",t("orders"),open],["coupons","tag",t("coupons")],["gifts","gift",t("gifts")],["reports","chart",t("reports")],["ads","megaphone",t("advertising")],["payments","wallet",t("payments")],["setup","store",t("shop_setup")]];
 const who=`<div class="who">${logoHTML(s)}<div style="min-width:0"><b class="small" style="display:block;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${esc(L(s,"name"))}</b><button class="btn ghost sm" style="padding:0" data-go="store:${s.id}">${t("view_shop")} →</button></div></div>`;
 const views={overview:sOverview,products:sProducts,add:sAddProduct,orders:sOrders,coupons:sCoupons,gifts:sGifts,reports:sReports,ads:sAds,payments:sPayments,setup:sSetup};
 return dashShell("seller",tabs,tab,who,(views[tab]||sOverview)(s,prods,ords));
}
function sOverview(s,prods,ords){
 const t0=startOfDay(Date.now()); const m0=new Date();m0.setDate(1);m0.setHours(0,0,0,0);
 const todayRev=ords.filter(o=>o.created>=t0&&validOrders(o)).reduce((a,o)=>a+o.total,0);
 const monthRev=ords.filter(o=>o.created>=m0.getTime()&&validOrders(o)).reduce((a,o)=>a+o.total,0);
 const open=ords.filter(o=>["pending","confirmed","packed"].includes(o.status));
 const live=prods.filter(isLive).length, pend=prods.filter(p=>p.status==="pending").length;
 const att=[];
 prods.filter(p=>p.featured==="awaiting_payment").forEach(p=>att.push(`<div class="row between"><span class="small">${esc(L(p,"title"))} · ${fsPill(p)}${p.payNote?`<div class="tiny" style="color:var(--red)">${t("pay_rejected",{t:esc(p.payNote)})}</div>`:""}</span><button class="btn sm red" data-act="payFee" data-id="${p.id}">${t("pay_fee")}</button></div>`));
 prods.filter(p=>p.status==="rejected").forEach(p=>att.push(`<div class="row between"><span class="small">${esc(L(p,"title"))} · ${lsPill(p)}<div class="tiny muted">${t("rejected_note",{r:esc(p.rejectReason||"—")})}</div></span><button class="btn sm" data-go="seller:add" data-id="${p.id}">${t("edit")}</button></div>`));
 open.filter(o=>o.status==="pending").slice(0,3).forEach(o=>att.push(`<div class="row between"><span class="small num">${esc(o.no)} · ${esc(o.customer.name)} · ${money(o.total)}</span><button class="btn sm" data-go="seller:orders">${t("orders")}</button></div>`));
 const recent=[...ords].sort((a,b)=>b.created-a.created).slice(0,6);
 return `<div class="panelhead"><h1>${t("overview")}</h1><button class="btn pri" data-go="seller:add">${icon("plus","").replace('class=""','style="width:16px;height:16px"')} ${t("add_product")}</button></div>
 <div class="kpis">${kpi(money(todayRev),t("today_sales"))}${kpi(money(monthRev),t("month_sales"))}${kpi(N(open.length),t("open_orders"),open.length>0)}${kpi(N(live)+(pend?` <span class="small muted">+${N(pend)}</span>`:""),t("live_products")+(pend?" · "+t("awaiting_approval"):""))}</div>
 ${att.length?`<div class="card pad stack"><h3>${t("needs_attention")}</h3>${att.join('<div class="hr"></div>')}</div>`:""}
 <div class="card pad"><div class="panelhead"><h3>${t("reports")} · ${t("daily")}</h3><button class="btn sm ghost" data-go="seller:reports">${t("view_all")} →</button></div>${barChart(buckets(ords,"daily"))}</div>
 <div><div class="panelhead"><h3>${t("recent_orders")}</h3><button class="btn sm ghost" data-go="seller:orders">${t("view_all")} →</button></div>${orderTable(recent,false)}</div>`;
}
function sProducts(s,prods){
 const f=UI.prodFilter;
 const list=prods.filter(p=>f==="all"||(f==="live"&&isLive(p))||(f==="pending"&&p.status==="pending")||(f==="featured"&&p.featured)||(f==="rejected"&&p.status==="rejected")).sort((a,b)=>b.created-a.created);
 return `<div class="panelhead"><h1>${t("products")}</h1><button class="btn pri" data-go="seller:add">${t("add_product")}</button></div>
 <div class="tabs" role="group">${[["all","all"],["live","ls_approved"],["pending","ls_pending"],["featured","featured"],["rejected","ls_rejected"]].map(([k,l])=>`<button data-act="prodFilter" data-f="${k}" aria-pressed="${f===k}">${t(l)}</button>`).join("")}</div>
 <div class="tblwrap"><table class="tbl"><thead><tr><th></th><th>${t("products")}</th><th>${t("price")}</th><th>${t("stock")}</th><th>${t("status")}</th><th>${t("listing")}</th><th>${t("actions")}</th></tr></thead><tbody>
 ${list.map(p=>`<tr><td>${thumb(p)}</td><td style="min-width:200px"><b class="small">${esc(L(p,"title"))}</b><div class="tiny muted">${p.condition==="used"?t("pre_owned"):t("brand_new")} · ${esc(L(getCat(p.catId),"name"))}${dealToday(p)?" · "+t("deals"):""}</div>${p.status==="rejected"?`<div class="tiny" style="color:var(--red)">${t("rejected_note",{r:esc(p.rejectReason||"—")})}</div>`:""}${p.payNote&&p.featured==="awaiting_payment"?`<div class="tiny" style="color:var(--red)">${t("pay_rejected",{t:esc(p.payNote)})}</div>`:""}</td>
  <td class="num">${priceHTML(p,-1)}</td><td class="num">${N(p.type==="variable"?p.variations.reduce((a,v)=>a+ +v.stock,0):p.stock)}</td><td>${lsPill(p)}</td><td>${fsPill(p)}</td>
  <td><div class="row" style="gap:4px;flex-wrap:nowrap">
   ${p.featured==="awaiting_payment"?`<button class="btn sm red" data-act="payFee" data-id="${p.id}">${t("pay_fee")}</button>`:""}
   ${(!p.featured||(p.featured==="active"&&p.featuredUntil<Date.now()))&&p.status!=="rejected"?`<button class="btn sm" data-act="makeFeatured" data-id="${p.id}">${p.featured?t("renew"):t("make_featured")}</button>`:""}
   <button class="btn sm" data-go="seller:add" data-id="${p.id}">${t("edit")}</button>
   <button class="btn sm ghost" data-act="delProduct" data-id="${p.id}" style="color:var(--red)">${UI.confirmDel===p.id?t("delete")+"?":t("delete")}</button></div></td></tr>`).join("")||`<tr><td colspan="7"><div class="empty">${t("no_items")}</div></td></tr>`}
 </tbody></table></div>`;
}
function sAddProduct(s,prods){
 const p=R.p.id?getProd(R.p.id):null; const key=p?p.id:"new";
 if(UI.editFor!==key){UI.editFor=key;UI.editImgs=p?[...p.images]:[];UI.editVars=p?JSON.parse(JSON.stringify(p.variations||[])):[];UI.editType=p?p.type:"simple";}
 const st=S.settings; const tops=S.categories.filter(c=>!c.parent);
 const v=(f,d="")=>esc(p?p[f]??d:d);
 const allowVar=st.allowVariable;
 const gifts=S.gifts.filter(g=>g.storeId===s.id&&g.active);
 return `<div class="panelhead"><h1>${p?t("edit_product"):t("add_product")}</h1>${p?`<div class="row">${lsPill(p)}${fsPill(p)}</div>`:""}</div>
 <form class="stack" data-form="product" data-id="${p?p.id:""}">
 <div class="card pad stack">
  <div class="grid2"><label class="field"><span>${t("title_en")} *</span><input id="pf_ten" name="title_en" required value="${v("title_en")}"></label><label class="field"><span>${t("title_bn")}</span><input id="pf_tbn" name="title_bn" value="${v("title_bn")}" lang="bn"></label></div>
  <div class="grid2"><label class="field"><span>${t("desc_en")}</span><textarea id="pf_den" name="desc_en">${v("desc_en")}</textarea></label><label class="field"><span>${t("desc_bn")}</span><textarea id="pf_dbn" name="desc_bn" lang="bn">${v("desc_bn")}</textarea></label></div>
  <div class="grid3"><label class="field"><span>${t("category")} *</span><select id="pf_cat" name="catId" required>${tops.map(c=>`<optgroup label="${esc(L(c,"name"))}">${S.categories.filter(x=>x.parent===c.id).map(x=>`<option value="${x.id}" ${p&&p.catId===x.id?"selected":""}>${esc(L(x,"name"))}</option>`).join("")||`<option value="${c.id}">${esc(L(c,"name"))}</option>`}</optgroup>`).join("")}</select></label>
   <label class="field"><span>${t("brand")}</span><select id="pf_brand" name="brandId">${S.brands.map(b=>`<option value="${b.id}" ${p&&p.brandId===b.id?"selected":""}>${esc(b.name)}</option>`).join("")}</select></label>
   <label class="field"><span>${t("condition")}</span><select id="pf_cond" name="condition"><option value="new" ${p?.condition==="new"?"selected":""}>${t("brand_new")}</option><option value="used" ${p?.condition==="used"?"selected":""}>${t("pre_owned")}</option></select></label></div>
 </div>
 <div class="card pad stack"><b class="small">${t("product_type")}</b>
  <div class="radiocards"><label><input type="radio" name="type" value="simple" ${UI.editType==="simple"?"checked":""} data-change="editType"><span><b>${t("simple")}</b><div class="tiny muted">${t("simple_s")}</div></span></label>
   <label class="${allowVar?"":"dis"}"><input type="radio" name="type" value="variable" ${UI.editType==="variable"?"checked":""} ${allowVar?"":"disabled"} data-change="editType"><span><b>${t("variable")}</b><div class="tiny muted">${allowVar?t("variable_s"):t("variable_locked")}</div></span></label></div>
  ${UI.editType==="variable"&&allowVar?`<div class="stack" style="gap:6px"><b class="small">${t("variations")}</b>${UI.editVars.map((x,i)=>`<div class="grid3"><input class="inp" data-var="${i}" data-k="label" value="${esc(x.label)}" placeholder="${t("var_label")}" aria-label="${t("var_label")}"><input class="inp" type="number" min="0" data-var="${i}" data-k="price" value="${esc(x.price)}" placeholder="${t("price")}" aria-label="${t("price")}"><div class="row" style="flex-wrap:nowrap"><input class="inp" type="number" min="0" data-var="${i}" data-k="stock" value="${esc(x.stock)}" placeholder="${t("stock")}" aria-label="${t("stock")}"><button type="button" class="btn sm ghost" data-act="delVar" data-i="${i}">✕</button></div></div>`).join("")}<button type="button" class="btn sm" data-act="addVar" style="align-self:flex-start">+ ${t("add_variation")}</button></div>`:
  `<div class="grid3"><label class="field"><span>${t("regular_price")} *</span><input id="pf_price" name="price" type="number" min="1" required value="${v("price")}"></label><label class="field"><span>${t("sale_price")}</span><input id="pf_sale" name="sale" type="number" min="0" value="${p&&p.sale?p.sale:""}"></label><label class="field"><span>${t("stock")} *</span><input id="pf_stock" name="stock" type="number" min="0" required value="${v("stock","10")}"></label></div>
  <label class="check"><input type="checkbox" name="deal" id="pf_deal" ${p&&p.deal?"checked":""}> ${t("deal_day")}</label>
  <div class="grid3"><label class="field"><span>${t("deal_price")}</span><input id="pf_dprice" name="deal_price" type="number" min="0" value="${p&&p.deal?p.deal.price:""}"></label><label class="field"><span>${t("deal_date")}</span><input id="pf_ddate" name="deal_date" type="date" value="${p&&p.deal?p.deal.date:today()}"></label><label class="field"><span>${t("sku")}</span><input id="pf_sku" name="sku" value="${v("sku","RGB-"+Math.floor(Math.random()*9000+1000))}"></label></div>`}
 </div>
 <div class="card pad stack"><b class="small">${t("images")}</b>
  <div class="upl">${UI.editImgs.map((src,i)=>`<div class="ph"><img src="${src}" alt=""><button type="button" data-act="delImg" data-i="${i}" aria-label="${t("remove")}">✕</button></div>`).join("")}${UI.editImgs.length<4?`<label>${t("add_photo")}<input type="file" accept="image/*" data-change="addImg" multiple></label>`:""}</div>
  <b class="small">${t("attributes")}</b><div class="grid2">${S.attributes.map(a=>`<label class="field"><span>${esc(L(a,"name"))}</span><select name="attr_${a.id}" id="pf_attr_${a.id}"><option value="">${t("none")}</option>${a.values.split(",").map(x=>x.trim()).filter(Boolean).map(x=>`<option ${p&&p.attrs?.[a.id]===x?"selected":""}>${esc(x)}</option>`).join("")}</select></label>`).join("")}</div>
 </div>
 <div class="card pad stack"><b class="small">${t("ship_opts")}</b><div class="row" style="gap:16px">${["dhaka","outside","pickup","negotiated"].filter(k=>st.ship[k].on).map(k=>`<label class="check"><input type="checkbox" name="ship_${k}" ${!p||p.ship[k]?"checked":""}> ${t("ship_"+k)} <span class="tiny muted num">${k==="negotiated"?"":st.ship[k].fee?money(st.ship[k].fee):t("free")}</span></label>`).join("")}</div>
  ${gifts.length?`<label class="field"><span>${t("attach_gift")}</span><select name="giftId" id="pf_gift"><option value="">${t("none")}</option>${gifts.map(g=>`<option value="${g.id}" ${p&&p.giftId===g.id?"selected":""}>${esc(L(g,"name"))}</option>`).join("")}</select></label>`:""}
 </div>
 ${!p||!p.featured?`<div class="card pad stack"><b class="small">${t("listing_type")}</b><div class="radiocards">
  <label><input type="radio" name="listing" value="free" checked><span><b>${t("free_listing")}</b><div class="tiny muted">${t("free_s")}</div></span></label>
  <label><input type="radio" name="listing" value="featured"><span><b>${t("featured_listing")} · ${money(st.featuredFee)}</b><div class="tiny muted">${t("featured_s",{f:money(st.featuredFee),d:N(st.featuredDays)})}</div></span></label></div></div>`:""}
 <div class="row"><button class="btn pri">${p?t("save"):t("submit_review")}</button><button type="button" class="btn" data-go="seller:products">${t("cancel")}</button></div>
 </form>`;
}
function orderTable(list,full){
 if(!list.length) return `<div class="card empty">${t("no_items")}</div>`;
 return `<div class="tblwrap"><table class="tbl"><thead><tr><th>${t("order_no")}</th><th>${t("date")}</th><th>${t("customer_col")}</th><th>${t("items")}</th><th>${t("ship_method")}</th><th>${t("total")}</th><th>${t("status")}</th>${full?`<th>${t("actions")}</th>`:""}</tr></thead><tbody>
 ${list.map(o=>`<tr><td class="num"><b>${esc(o.no)}</b><div class="tiny muted">${o.pay==="cod"?t("cod"):esc(o.pay)}${o.trx?" · "+esc(o.trx):""}</div></td><td class="small">${fmtDate(o.created)}</td><td class="small">${esc(o.customer.name)}<div class="tiny muted num">${esc(o.customer.phone)} · ${esc(o.customer.district)}</div></td>
  <td class="small">${o.items.map(i=>N(i.qty)+" × "+esc(L(i,"title"))).join("<br>")}${o.gift?`<div class="tiny" style="color:var(--green)">+ ${esc(L(o.gift,"name"))}</div>`:""}</td><td class="small">${t("ship_"+o.method)}</td><td class="num">${money(o.total)}</td>
  <td>${full?`<select class="inp" style="width:auto;padding:5px 8px" data-change="orderStatus" data-id="${o.id}" aria-label="${t("update_status")}">${["pending","confirmed","packed","shipped","delivered","cancelled"].map(s=>`<option value="${s}" ${o.status===s?"selected":""}>${t("st_"+s)}</option>`).join("")}</select>`:stPill(o.status)}</td>
  ${full?`<td><div class="row" style="gap:4px;flex-wrap:nowrap"><button class="btn sm" data-act="doc" data-k="invoice" data-id="${o.id}">${t("invoice")}</button><button class="btn sm" data-act="doc" data-k="packing" data-id="${o.id}">${t("packing")}</button><button class="btn sm" data-act="doc" data-k="label" data-id="${o.id}">${t("label")}</button></div></td>`:""}</tr>`).join("")}</tbody></table></div>`;
}
function sOrders(s,prods,ords){
 const f=UI.ordFilter; const list=ords.filter(o=>f==="all"||o.status===f).sort((a,b)=>b.created-a.created).slice(0,60);
 return `<div class="panelhead"><h1>${t("orders")}</h1></div>
 <div class="tabs" role="group">${["all","pending","confirmed","packed","shipped","delivered","cancelled"].map(k=>`<button data-act="ordFilter" data-f="${k}" aria-pressed="${f===k}">${k==="all"?t("all"):t("st_"+k)} <span class="tiny num">${N(k==="all"?ords.length:ords.filter(o=>o.status===k).length)}</span></button>`).join("")}</div>
 ${orderTable(list,true)}`;
}
function sCoupons(s){
 const list=S.coupons.filter(c=>c.storeId===s.id);
 return `<div class="panelhead"><h1>${t("coupons")}</h1></div>
 <form class="card pad stack" data-form="coupon_new"><h3>${t("new_coupon")}</h3>
  <div class="grid3"><label class="field"><span>${t("code")}</span><input id="cp_code" name="code" required style="text-transform:uppercase" placeholder="EID15"></label><label class="field"><span>${t("type")}</span><select id="cp_type" name="type"><option value="pct">${t("pct")}</option><option value="flat">${t("flat")}</option></select></label><label class="field"><span>${t("value")}</span><input id="cp_val" name="value" type="number" min="1" required></label></div>
  <div class="grid3"><label class="field"><span>${t("min_spend")}</span><input id="cp_min" name="min" type="number" min="0" value="0"></label><label class="field"><span>${t("expires")}</span><input id="cp_exp" name="expires" type="date" required value="${ymd(Date.now()+30*DAY)}"></label><label class="field"><span>${t("usage_limit")}</span><input id="cp_lim" name="limit" type="number" min="1" value="100"></label></div>
  <button class="btn pri" style="align-self:flex-start">${t("new_coupon")}</button></form>
 <div class="tblwrap"><table class="tbl"><thead><tr><th>${t("code")}</th><th>${t("value")}</th><th>${t("min_spend")}</th><th>${t("expires")}</th><th>${t("used")}</th><th>${t("status")}</th><th></th></tr></thead><tbody>
 ${list.map(c=>`<tr><td><b class="num">${esc(c.code)}</b></td><td class="num">${c.type==="pct"?N(c.value)+"%":money(c.value)}</td><td class="num">${money(c.min)}</td><td>${fmtDate(new Date(c.expires+"T00:00"))}</td><td class="num">${N(c.used)} / ${N(c.limit)}</td><td><button class="pill ${c.active?"g":""}" style="border:0;cursor:pointer" data-act="toggleCoupon" data-id="${c.id}">${c.active?t("active"):t("inactive")}</button></td><td><button class="btn sm ghost" data-act="delCoupon" data-id="${c.id}">${t("delete")}</button></td></tr>`).join("")||`<tr><td colspan="7"><div class="empty">${t("no_items")}</div></td></tr>`}</tbody></table></div>`;
}
function sGifts(s,prods){
 const list=S.gifts.filter(g=>g.storeId===s.id);
 return `<div class="panelhead"><h1>${t("gifts")}</h1></div>
 <form class="card pad stack" data-form="gift_new"><h3>${t("new_gift")}</h3>
  <div class="grid2"><label class="field"><span>${t("gift_name_en")}</span><input id="gf_en" name="name_en" required></label><label class="field"><span>${t("gift_name_bn")}</span><input id="gf_bn" name="name_bn"></label></div>
  <div class="grid3"><label class="field"><span>${t("min_spend")}</span><input id="gf_min" name="min" type="number" min="0" value="1000"></label><label class="field"><span>${t("applies_to")}</span><select id="gf_scope" name="scope"><option value="all">${t("all_products")}</option>${prods.filter(isLive).map(p=>`<option value="${p.id}">${esc(L(p,"title"))}</option>`).join("")}</select></label><label class="field"><span>${t("stock")}</span><input id="gf_stock" name="stock" type="number" min="1" value="20"></label></div>
  <button class="btn pri" style="align-self:flex-start">${t("new_gift")}</button></form>
 <div class="tblwrap"><table class="tbl"><thead><tr><th>${t("gift")}</th><th>${t("min_spend")}</th><th>${t("applies_to")}</th><th>${t("stock")}</th><th>${t("status")}</th><th></th></tr></thead><tbody>
 ${list.map(g=>`<tr><td><b class="small">${esc(L(g,"name"))}</b></td><td class="num">${money(g.min)}</td><td class="small">${g.scope==="all"?t("all_products"):esc(L(getProd(g.scope),"title"))}</td><td class="num">${N(g.stock)}</td><td><button class="pill ${g.active?"g":""}" style="border:0;cursor:pointer" data-act="toggleGift" data-id="${g.id}">${g.active?t("active"):t("inactive")}</button></td><td><button class="btn sm ghost" data-act="delGift" data-id="${g.id}">${t("delete")}</button></td></tr>`).join("")||`<tr><td colspan="6"><div class="empty">${t("no_items")}</div></td></tr>`}</tbody></table></div>`;
}
function buckets(ords,mode){
 const out=[]; const now=Date.now(); const v=ords.filter(validOrders);
 const sum=(a,b)=>{const os=v.filter(o=>o.created>=a&&o.created<b);return {rev:os.reduce((x,o)=>x+o.total,0),n:os.length,units:os.reduce((x,o)=>x+o.items.reduce((y,i)=>y+i.qty,0),0)}};
 if(mode==="daily"){for(let i=13;i>=0;i--){const a=startOfDay(now-i*DAY);out.push({label:fmtShort(a),...sum(a,a+DAY)})}}
 else if(mode==="weekly"){const d0=startOfDay(now);const dow=(new Date(d0).getDay()+1)%7;/* week starts Saturday */const ws=d0-dow*DAY;for(let i=11;i>=0;i--){const a=ws-i*7*DAY;out.push({label:fmtShort(a),...sum(a,a+7*DAY)})}}
 else {const d=new Date();d.setDate(1);d.setHours(0,0,0,0);for(let i=11;i>=0;i--){const a=new Date(d.getFullYear(),d.getMonth()-i,1).getTime();const b=new Date(d.getFullYear(),d.getMonth()-i+1,1).getTime();out.push({label:new Date(a).toLocaleDateString(S.lang==="bn"?"bn-BD":"en-GB",{month:"short",year:"2-digit"}),...sum(a,b)})}}
 return out;
}
function barChart(b){
 const W=640,H=200,pl=48,pb=26,pt=12; const max=Math.max(1,...b.map(x=>x.rev)); const nice=Math.pow(10,Math.floor(Math.log10(max)));const top=Math.ceil(max/nice)*nice;
 const bw=(W-pl-8)/b.length; const y=v=>pt+(H-pt-pb)*(1-v/top);
 const ticks=[0,.5,1].map(f=>top*f);
 return `<div class="chart"><svg viewBox="0 0 ${W} ${H}" role="img" aria-label="${t("revenue")}">
  ${ticks.map(v=>`<line x1="${pl}" x2="${W-4}" y1="${y(v)}" y2="${y(v)}" stroke="var(--line)" stroke-width="1"/><text x="${pl-6}" y="${y(v)+3}" text-anchor="end">${v>=1000?N(Math.round(v/1000))+"k":N(Math.round(v))}</text>`).join("")}
  ${b.map((x,i)=>`<rect x="${pl+i*bw+bw*.18}" y="${y(x.rev)}" width="${bw*.64}" height="${Math.max(0,H-pb-y(x.rev))}" rx="3" fill="${i===b.length-1?"var(--red)":"var(--green)"}"><title>${x.label}: ${money(x.rev)} · ${N(x.n)}</title></rect>${(b.length<=14||i%2===0)?`<text x="${pl+i*bw+bw/2}" y="${H-8}" text-anchor="middle">${x.label}</text>`:""}`).join("")}
 </svg></div>`;
}
function sReports(s,prods,ords){
 const m=UI.repTab; const b=buckets(ords,m); const tot=b.reduce((a,x)=>({rev:a.rev+x.rev,n:a.n+x.n,units:a.units+x.units}),{rev:0,n:0,units:0});
 const since=m==="daily"?startOfDay(Date.now()-13*DAY):m==="weekly"?Date.now()-84*DAY:Date.now()-365*DAY;
 const best={}; ords.filter(o=>validOrders(o)&&o.created>=since).forEach(o=>o.items.forEach(i=>{best[i.pid]=best[i.pid]||{q:0,r:0,i};best[i.pid].q+=i.qty;best[i.pid].r+=i.qty*i.price}));
 const top=Object.values(best).sort((a,b)=>b.r-a.r).slice(0,5);
 return `<div class="panelhead"><h1>${t("reports")}</h1><div class="tabs" role="group">${["daily","weekly","yearly"].map(k=>`<button data-act="repTab" data-t="${k}" aria-pressed="${m===k}">${t(k)}</button>`).join("")}</div></div>
 <p class="small muted">${t("rep_"+m+"_s")}</p>
 <div class="kpis">${kpi(money(tot.rev),t("revenue"))}${kpi(N(tot.n),t("orders_n"))}${kpi(N(tot.units),t("units"))}${kpi(money(tot.n?tot.rev/tot.n:0),t("avg_order"))}</div>
 <div class="card pad">${barChart(b)}</div>
 <div class="grid2" style="align-items:start"><div class="tblwrap"><table class="tbl" style="min-width:0"><thead><tr><th>${t("period")}</th><th>${t("orders_n")}</th><th>${t("units")}</th><th>${t("revenue")}</th></tr></thead><tbody>${[...b].reverse().map(x=>`<tr><td>${x.label}</td><td class="num">${N(x.n)}</td><td class="num">${N(x.units)}</td><td class="num">${money(x.rev)}</td></tr>`).join("")}</tbody></table></div>
 <div class="card pad stack"><h3>${t("best_sellers")}</h3>${top.map(x=>`<div class="row between small"><span class="grow" style="min-width:0">${esc(L(x.i,"title"))}</span><span class="num muted">${N(x.q)}×</span><b class="num">${money(x.r)}</b></div>`).join('<div class="hr"></div>')||t("no_items")}</div></div>`;
}
function sAds(s,prods){
 const st=S.settings; const reqs=S.adRequests.filter(r=>r.storeId===s.id).sort((a,b)=>b.at-a.at);
 return `<div class="panelhead"><h1>${t("advertising")}</h1></div><div class="note">${t("ads_intro")}</div>
 <form class="card pad stack" data-form="ad_book"><h3>${t("book_ad")}</h3>
  <div class="grid3"><label class="field"><span>${t("placement")}</span><select id="ab_pl" name="placement">${["home_top","home_mid","cat_side"].map(k=>`<option value="${k}">${t("pl_"+k)} · ${t("per_day",{a:money(st.adPrice[k])})}</option>`).join("")}</select></label><label class="field"><span>${t("days")}</span><input id="ab_days" name="days" type="number" min="1" max="60" value="7"></label>
   <label class="field"><span>${t("link_to")}</span><select id="ab_link" name="link"><option value="store:${s.id}">${t("my_shop")}</option>${prods.filter(isLive).map(p=>`<option value="product:${p.id}">${esc(L(p,"title"))}</option>`).join("")}</select></label></div>
  <div class="grid2"><label class="field"><span>${t("headline_en")}</span><input id="ab_ten" name="title_en" required maxlength="60"></label><label class="field"><span>${t("headline_bn")}</span><input id="ab_tbn" name="title_bn" maxlength="60"></label></div>
  <div class="grid2"><label class="field"><span>${t("sub_en")}</span><input id="ab_sen" name="sub_en" maxlength="80"></label><label class="field"><span>${t("sub_bn")}</span><input id="ab_sbn" name="sub_bn" maxlength="80"></label></div>
  <div class="grid3"><label class="field"><span>${t("colour")}</span><select id="ab_col" name="color"><option value="green">Green</option><option value="red">Red</option><option value="dark">Dark</option><option value="gold">Gold</option></select></label>${mfsFields("ab")}</div>
  <button class="btn red" style="align-self:flex-start">${t("submit_payment")}</button></form>
 <h3>${t("ad_requests")}</h3>
 <div class="tblwrap"><table class="tbl"><thead><tr><th>${t("placement")}</th><th>${t("days")}</th><th>${t("amount")}</th><th>${t("submitted")}</th><th>${t("status")}</th></tr></thead><tbody>
 ${reqs.map(r=>{const ad=S.ads.find(a=>a.id===r.adId);const ended=ad&&ad.end<today();return `<tr><td>${t("pl_"+r.placement)}<div class="tiny muted">${esc(L(ad||r,"title"))}</div></td><td class="num">${N(r.days)}</td><td class="num">${money(r.amount)}</td><td class="small">${fmtDate(r.at)}</td><td><span class="pill ${r.status==="live"&&!ended?"g":r.status==="rejected"?"r":"y"}">${ended?t("rq_ended"):t("rq_"+r.status)}</span>${ad&&!ended?`<div class="tiny muted">${fmtShort(new Date(ad.start+"T00:00"))} – ${fmtShort(new Date(ad.end+"T00:00"))}</div>`:""}</td></tr>`}).join("")||`<tr><td colspan="5"><div class="empty">${t("no_items")}</div></td></tr>`}</tbody></table></div>`;
}
function mfsFields(pfx){
 const m=mfsOn();
 return `<label class="field"><span>${t("method")}</span><select id="${pfx}_m" name="method" data-change="mfsPick">${m.map(x=>`<option value="${x.id}">${x.id} · ${esc(x.number)}</option>`).join("")}</select></label><label class="field"><span>${t("trx")}</span><input id="${pfx}_trx" name="trx" required style="text-transform:uppercase" placeholder="8N7A6D5E4F"></label><input type="hidden" name="sender" value="${esc((myStore()||{}).phone||"")}">`;
}
function sPayments(s){
 const list=S.payments.filter(p=>p.storeId===s.id).sort((a,b)=>b.at-a.at);
 return `<div class="panelhead"><h1>${t("payments")}</h1></div><div class="note g small">${t("how_featured_s",{f:money(S.settings.featuredFee),d:N(S.settings.featuredDays)})}</div>
 <div class="tblwrap"><table class="tbl"><thead><tr><th>${t("submitted")}</th><th>${t("kind")}</th><th>${t("for_product")}</th><th>${t("method")}</th><th>${t("trx_short")}</th><th>${t("amount")}</th><th>${t("status")}</th></tr></thead><tbody>
 ${list.map(p=>`<tr><td class="small">${fmtDate(p.at)}</td><td>${t("k_"+p.kind)}</td><td class="small">${p.kind==="featured"?esc(L(getProd(p.refId),"title")):t("pl_"+(S.adRequests.find(r=>r.id===p.refId)||{}).placement)}</td><td>${esc(p.method)}</td><td class="num">${esc(p.trx)}</td><td class="num">${money(p.amount)}</td><td><span class="pill ${p.status==="verified"?"g":p.status==="rejected"?"r":"y"}">${t("p_"+p.status)}</span></td></tr>`).join("")||`<tr><td colspan="7"><div class="empty">${t("no_items")}</div></td></tr>`}</tbody></table></div>`;
}
function sSetup(s){
 return `<div class="panelhead"><h1>${t("shop_setup")}</h1><button class="btn" data-go="store:${s.id}">${t("view_shop")} →</button></div>
 <form class="stack" data-form="setup">
 <div class="card pad stack"><div class="grid2"><div class="stack" style="gap:6px"><b class="small">${t("logo")}</b><div class="row">${logoHTML(s)}<label class="btn sm">${t("upload")}<input type="file" accept="image/*" data-change="storeImg" data-k="logo" hidden></label></div></div>
  <div class="stack" style="gap:6px"><b class="small">${t("banner")}</b><div class="row"><div style="width:160px;height:52px;border-radius:8px;overflow:hidden;background:${esc(s.color)}">${s.banner?`<img src="${s.banner}" alt="" style="width:100%;height:100%;object-fit:cover">`:""}</div><label class="btn sm">${t("upload")}<input type="file" accept="image/*" data-change="storeImg" data-k="banner" hidden></label></div></div></div>
  <div class="grid3"><label class="field"><span>${t("shop_name_en")}</span><input id="su_nen" name="name_en" required value="${esc(s.name_en)}"></label><label class="field"><span>${t("shop_name_bn")}</span><input id="su_nbn" name="name_bn" value="${esc(s.name_bn)}"></label><label class="field"><span>${t("brand_colour")}</span><input id="su_col" name="color" type="color" value="${esc(s.color)}" style="height:42px;padding:4px"></label></div>
  <div class="grid2"><label class="field"><span>${t("about_en")}</span><textarea id="su_aen" name="about_en">${esc(s.about_en)}</textarea></label><label class="field"><span>${t("about_bn")}</span><textarea id="su_abn" name="about_bn">${esc(s.about_bn)}</textarea></label></div></div>
 <div class="card pad stack"><h3>${t("contact_seller")}</h3>
  <div class="grid3"><label class="field"><span>${t("phone")}</span><input id="su_ph" name="phone" value="${esc(s.phone)}"></label><label class="field"><span>${t("wa_no")}</span><input id="su_wa" name="whatsapp" value="${esc(s.whatsapp)}"></label><label class="field"><span>${t("shop_email")}</span><input id="su_em" name="email" type="email" value="${esc(s.email)}"></label></div>
  <div class="grid2"><label class="field"><span>${t("address")}</span><input id="su_ad" name="address" value="${esc(s.address)}"></label><label class="field"><span>${t("district")}</span><input id="su_di" name="district" value="${esc(s.district)}"></label></div>
  <label class="check"><input type="checkbox" name="pickup" ${s.pickup?"checked":""}> ${t("allow_pickup")}</label>
  <label class="field"><span>${t("seller_payout")}</span><input id="su_mfs" name="mfs" value="${esc(s.mfs||"")}" placeholder="bKash 01XXXXXXXXX"></label></div>
 <div class="card pad stack"><div class="grid2"><label class="field"><span>${t("hours")} (EN)</span><input id="su_hen" name="hours_en" value="${esc(s.hours_en)}"></label><label class="field"><span>${t("hours")} (বাংলা)</span><input id="su_hbn" name="hours_bn" value="${esc(s.hours_bn)}"></label></div>
  <div class="grid2"><label class="field"><span>${t("returns")} (EN)</span><textarea id="su_ren" name="returns_en">${esc(s.returns_en)}</textarea></label><label class="field"><span>${t("returns")} (বাংলা)</span><textarea id="su_rbn" name="returns_bn">${esc(s.returns_bn)}</textarea></label></div></div>
 <button class="btn pri" style="align-self:flex-start">${t("save")}</button></form>`;
}

/* ================= documents ================= */
function docHTML(kind,o){
 const s=getStore(o.storeId); const c=o.customer;
 const head=`<div class="row between" style="align-items:flex-start"><div class="row">${logoHTML(s)}<div><h2>${esc(L(s,"name"))}</h2><div class="small">${esc(s.address)}, ${esc(s.district)}<br>${esc(s.phone)} · ${esc(s.email)}</div></div></div><div style="text-align:right"><h2>${kind==="invoice"?t("invoice"):t("packing")}</h2><div class="num"><b>${esc(o.no)}</b><br>${fmtDate(o.created)}</div></div></div>`;
 const to=`<div style="margin-top:14px"><div class="tiny" style="text-transform:uppercase;letter-spacing:.06em">${kind==="invoice"?t("bill_to"):t("ship_to")}</div><b>${esc(c.name)}</b><div class="small">${esc(c.address)}, ${esc(c.district)} · ${esc(c.phone)}</div><div class="small">${t("ship_method")}: ${t("ship_"+o.method)}</div></div>`;
 if(kind==="invoice") return `<div class="doc">${head}${to}<table><thead><tr><th>${t("items")}</th><th class="r">${t("qty_short")}</th><th class="r">${t("unit_price")}</th><th class="r">${t("line_total")}</th></tr></thead><tbody>
  ${o.items.map(i=>`<tr><td>${esc(L(i,"title"))}</td><td class="r num">${N(i.qty)}</td><td class="r num">${money(i.price)}</td><td class="r num">${money(i.price*i.qty)}</td></tr>`).join("")}
  ${o.gift?`<tr><td>${t("gift")}: ${esc(L(o.gift,"name"))}</td><td class="r num">${N(1)}</td><td class="r num">${money(0)}</td><td class="r num">${money(0)}</td></tr>`:""}</tbody></table>
  <table style="width:auto;margin-left:auto"><tbody><tr><td>${t("subtotal")}</td><td class="r num">${money(o.subtotal)}</td></tr>${o.discount?`<tr><td>${t("discount")} ${o.coupon?"("+esc(o.coupon)+")":""}</td><td class="r num">−${money(o.discount)}</td></tr>`:""}<tr><td>${t("shipping")}</td><td class="r num">${money(o.fee)}</td></tr><tr><td><b>${t("total")}</b></td><td class="r num"><b>${money(o.total)}</b></td></tr></tbody></table>
  <div class="small" style="margin-top:10px">${t("payment")}: ${o.pay==="cod"?t("cod"):esc(o.pay)+" · "+t("paid")+(o.trx?" · "+esc(o.trx):"")}</div><p class="small" style="margin-top:14px;text-align:center">${t("thank_you")}</p></div>`;
 if(kind==="packing") return `<div class="doc">${head}${to}<table><thead><tr><th style="width:30px">✓</th><th>${t("items")}</th><th>${t("sku")}</th><th class="r">${t("qty_short")}</th></tr></thead><tbody>
  ${o.items.map(i=>`<tr><td>☐</td><td>${esc(L(i,"title"))}</td><td class="num">${esc((getProd(i.pid)||{}).sku||"")}</td><td class="r num">${N(i.qty)}</td></tr>`).join("")}${o.gift?`<tr><td>☐</td><td>${t("gift")}: ${esc(L(o.gift,"name"))}</td><td></td><td class="r num">${N(1)}</td></tr>`:""}</tbody></table>
  ${o.note?`<div class="small" style="margin-top:10px"><b>${t("notes")}:</b> ${esc(o.note)}</div>`:""}<div class="row between small" style="margin-top:28px"><span>${t("packed_by")}: ____________</span><span>${t("checked")}: ____________</span></div></div>`;
 // label
 const r=rng([...o.no].reduce((a,ch)=>a+ch.charCodeAt(0)*31,7)); const bars=Array.from({length:84},()=>`<i style="width:${1+Math.floor(r()*3)}px;margin-right:${1+Math.floor(r()*2)}px"></i>`).join("");
 const cod=o.pay==="cod"?o.total:0;
 return `<div class="label"><div class="lb row between"><b class="big">RGBKart</b><span class="big">${t("ship_"+o.method)}</span></div>
  <div class="lb"><div class="tiny" style="text-transform:uppercase">${t("from")}</div><b>${esc(L(s,"name"))}</b><div class="small">${esc(s.address)}, ${esc(s.district)} · ${esc(s.phone)}</div></div>
  <div class="lb"><div class="tiny" style="text-transform:uppercase">${t("ship_to")}</div><div class="big">${esc(c.name)}</div><div>${esc(c.address)}</div><div class="big">${esc(c.district).toUpperCase()}</div><div class="big num">${esc(c.phone)}</div></div>
  <div class="lb row between"><div><div class="tiny">${t("order_no")}</div><b class="num">${esc(o.no)}</b></div><div><div class="tiny">${t("items")}</div><b class="num">${N(o.items.reduce((a,i)=>a+i.qty,0))}</b></div><div style="text-align:right"><div class="tiny">${t("cod_amount")}</div><b class="big num">${cod?money(cod):t("paid")}</b></div></div>
  <div class="lb"><div class="barcode">${bars}</div><div class="tiny num" style="text-align:center;letter-spacing:.3em">${esc(o.no)}</div></div></div>`;
}
</script>
