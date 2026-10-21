<script>
/* ================= admin ================= */
function linkOptions(sel){
 const o=[["home",t("home")],["shop",t("shop_nav")],["deals",t("deals")],["new",t("new_arrivals")],["featured",t("featured")],["used",t("pre_owned")],["register",t("sell_on")]];
 S.categories.forEach(c=>o.push(["cat:"+c.id,(c.parent?"— ":"")+L(c,"name")]));
 S.stores.forEach(s=>o.push(["store:"+s.id,t("shop")+": "+L(s,"name")]));
 return o.map(([v,l])=>`<option value="${esc(v)}" ${sel===v?"selected":""}>${esc(l)}</option>`).join("");
}
const colorOpts=sel=>["green","red","dark","gold"].map(c=>`<option value="${c}" ${sel===c?"selected":""}>${c[0].toUpperCase()+c.slice(1)}</option>`).join("");
function viewAdmin(){
 const u=me(); if(!u) return viewLogin(t("need_login"));
 if(u.role!=="admin") return `<div class="wrap"><div class="card empty" style="margin-top:20px">${t("need_admin")}</div></div>`;
 const tab=R.p.tab||"overview";
 const pend=S.products.filter(p=>p.status==="pending").length, pays=S.payments.filter(p=>p.status==="review").length;
 const tabs=[["overview","grid",t("overview")],["approvals","check",t("approvals"),pend],["payments","wallet",t("verify_payments"),pays],["products","box",t("all_products_a")],["sellers","users",t("sellers")],["orders","receipt",t("orders")],["homepage","home",t("homepage")],["menu","menu",t("menu")],["categories","layers",t("categories")],["brands","award",t("brands")+" & "+t("attributes")],["ads","megaphone",t("ads")],["settings","cog",t("settings")]];
 const who=`<div class="who"><div class="slogo" style="background:var(--red)">A</div><div><b class="small">${t("admin")}</b><div class="tiny muted">RGBKart</div></div></div>`;
 const V={overview:aOverview,approvals:aApprovals,payments:aPayments,products:aProducts,sellers:aSellers,orders:aOrders,homepage:aHomepage,menu:aMenu,categories:aCategories,brands:aBrands,ads:aAds,settings:aSettings};
 return dashShell("admin",tabs,tab,who,(V[tab]||aOverview)());
}
function aOverview(){
 const now=Date.now(); const pend=S.products.filter(p=>p.status==="pending"); const pays=S.payments.filter(p=>p.status==="review");
 const fees=S.payments.filter(p=>p.status==="verified"&&p.at>now-30*DAY).reduce((a,p)=>a+p.amount,0);
 const ords=S.orders.filter(o=>o.created>now-30*DAY&&validOrders(o));
 return `<div class="panelhead"><h1>${t("overview")}</h1></div>
 <div class="kpis">${kpi(N(pend.length),t("pending_listings"),pend.length)}${kpi(N(pays.length),t("payments_to_verify"),pays.length)}${kpi(money(fees),t("featured_income"))}${kpi(N(ords.length),t("marketplace_orders"))}</div>
 <div class="grid2" style="align-items:start"><div class="card pad stack"><div class="panelhead" style="margin:0"><h3>${t("approvals")}</h3><button class="btn sm ghost" data-go="admin:approvals">${t("view_all")} →</button></div>${pend.slice(0,5).map(p=>`<div class="row small" style="flex-wrap:nowrap">${thumb(p)}<span class="grow">${esc(L(p,"title"))}<div class="tiny muted">${esc(L(getStore(p.storeId),"name"))}</div></span>${fsPill(p)}</div>`).join('<div class="hr"></div>')||`<p class="small muted">${t("queue_empty")}</p>`}</div>
 <div class="card pad stack"><div class="panelhead" style="margin:0"><h3>${t("verify_payments")}</h3><button class="btn sm ghost" data-go="admin:payments">${t("view_all")} →</button></div>${pays.slice(0,5).map(p=>`<div class="row between small"><span>${esc(L(getStore(p.storeId),"name"))}<div class="tiny muted">${t("k_"+p.kind)} · ${esc(p.method)} · <span class="num">${esc(p.trx)}</span></div></span><b class="num">${money(p.amount)}</b></div>`).join('<div class="hr"></div>')||`<p class="small muted">${t("queue_empty")}</p>`}</div></div>
 <div class="card pad"><h3 style="margin-bottom:8px">${t("marketplace_orders")}</h3>${barChart(buckets(S.orders,"daily"))}</div>`;
}
function aApprovals(){
 const list=S.products.filter(p=>p.status==="pending").sort((a,b)=>a.created-b.created);
 return `<div class="panelhead"><h1>${t("approvals")}</h1></div>
 ${list.length?list.map(p=>{const s=getStore(p.storeId);const pay=S.payments.find(x=>x.kind==="featured"&&x.refId===p.id&&x.status==="review");
  return `<div class="card pad row" style="align-items:flex-start;flex-wrap:wrap">${`<div style="width:96px;border-radius:8px;overflow:hidden;flex:none">${pimg(p)}</div>`}
   <div class="grow stack" style="gap:6px;min-width:220px"><div class="row">${fsPill(p)}<span class="pill ${p.condition==="used"?"y":"g"}">${p.condition==="used"?t("pre_owned"):t("brand_new")}</span></div>
    <b>${esc(p.title_en)}</b>${p.title_bn?`<span class="small muted" lang="bn">${esc(p.title_bn)}</span>`:""}
    <span class="small">${esc(L(s,"name"))} · ${esc(L(getCat(p.catId),"name"))} · ${priceHTML(p,-1)}</span>
    <span class="tiny muted">${t("submitted")} ${fmtDate(p.created)}</span>
    ${pay?`<div class="note small">${t("k_featured")}: ${esc(pay.method)} · ${t("sender")} <span class="num">${esc(pay.sender)}</span> · ${t("trx_short")} <b class="num">${esc(pay.trx)}</b> · ${money(pay.amount)}</div>`:""}
    <button class="btn sm ghost" style="align-self:flex-start;padding:0" data-go="product:${p.id}">${t("view")} →</button></div>
   <div class="stack" style="gap:6px;min-width:220px">
    ${p.listing==="featured"&&pay?`<button class="btn pri sm" data-act="verifyPay" data-id="${pay.id}">${t("verify_publish")}</button><button class="btn sm" data-act="rejectPay" data-id="${pay.id}">${t("not_received")}</button>`:
      p.listing==="featured"&&p.featured==="awaiting_payment"?`<span class="pill r">${t("waiting_pay")}</span><button class="btn sm" data-act="approve" data-id="${p.id}" data-free="1">${t("publish_free")}</button>`:
      `<button class="btn pri sm" data-act="approve" data-id="${p.id}">${t("approve")}</button>`}
    <div class="row" style="flex-wrap:nowrap;gap:4px"><input class="inp" id="rj_${p.id}" placeholder="${t("reason")}" aria-label="${t("reason")}" style="padding:6px 8px"><button class="btn sm" data-act="rejectListing" data-id="${p.id}" style="color:var(--red)">${t("reject")}</button></div></div></div>`}).join(""):`<div class="card empty">${t("queue_empty")}</div>`}`;
}
function aPayments(){
 const rev=S.payments.filter(p=>p.status==="review").sort((a,b)=>a.at-b.at); const hist=S.payments.filter(p=>p.status!=="review").sort((a,b)=>b.at-a.at);
 const ref=p=>p.kind==="featured"?esc(L(getProd(p.refId),"title")):(()=>{const r=S.adRequests.find(x=>x.id===p.refId)||{};return t("pl_"+r.placement)+" · "+N(r.days||0)+" "+t("days")})();
 const row=(p,act)=>`<tr><td class="small">${fmtDate(p.at)}</td><td>${esc(L(getStore(p.storeId),"name"))}</td><td>${t("k_"+p.kind)}<div class="tiny muted">${ref(p)}</div></td><td>${esc(p.method)}</td><td class="num">${esc(p.sender)}</td><td class="num"><b>${esc(p.trx)}</b></td><td class="num">${money(p.amount)}</td><td>${act?`<div class="row" style="gap:4px;flex-wrap:nowrap"><button class="btn sm pri" data-act="verifyPay" data-id="${p.id}">${t("verify_publish")}</button><button class="btn sm" data-act="rejectPay" data-id="${p.id}">${t("not_received")}</button></div>`:`<span class="pill ${p.status==="verified"?"g":"r"}">${t("p_"+p.status)}</span>`}</td></tr>`;
 const head=`<thead><tr><th>${t("submitted")}</th><th>${t("shop")}</th><th>${t("kind")}</th><th>${t("method")}</th><th>${t("sender")}</th><th>${t("trx_short")}</th><th>${t("amount")}</th><th>${t("actions")}</th></tr></thead>`;
 return `<div class="panelhead"><h1>${t("verify_payments")}</h1></div><p class="small muted">${mfsOn().map(m=>m.id+" "+esc(m.number)).join(" · ")}</p>
 <div class="tblwrap"><table class="tbl">${head}<tbody>${rev.map(p=>row(p,true)).join("")||`<tr><td colspan="8"><div class="empty">${t("queue_empty")}</div></td></tr>`}</tbody></table></div>
 <h3>${t("all")}</h3><div class="tblwrap"><table class="tbl">${head}<tbody>${hist.map(p=>row(p,false)).join("")}</tbody></table></div>`;
}
function aProducts(){
 const f=UI.prodFilter; const list=S.products.filter(p=>f==="all"||(f==="live"&&isLive(p))||(f==="pending"&&p.status==="pending")||(f==="featured"&&isFeat(p))||(f==="rejected"&&p.status==="rejected")).sort((a,b)=>b.created-a.created);
 return `<div class="panelhead"><h1>${t("all_products_a")}</h1></div>
 <div class="tabs" role="group">${[["all","all"],["live","ls_approved"],["pending","ls_pending"],["featured","featured"],["rejected","ls_rejected"]].map(([k,l])=>`<button data-act="prodFilter" data-f="${k}" aria-pressed="${f===k}">${t(l)}</button>`).join("")}</div>
 <div class="tblwrap"><table class="tbl"><thead><tr><th></th><th>${t("products")}</th><th>${t("shop")}</th><th>${t("price")}</th><th>${t("status")}</th><th>${t("listing")}</th><th>${t("actions")}</th></tr></thead><tbody>
 ${list.map(p=>`<tr><td>${thumb(p)}</td><td><b class="small">${esc(L(p,"title"))}</b><div class="tiny muted">${esc(L(getCat(p.catId),"name"))}</div></td><td class="small">${esc(L(getStore(p.storeId),"name"))}</td><td class="num">${priceHTML(p,-1)}</td><td>${lsPill(p)}</td><td>${fsPill(p)}</td>
  <td><div class="row" style="gap:4px;flex-wrap:nowrap"><button class="btn sm" data-go="product:${p.id}">${t("view")}</button>${p.status==="approved"?`<button class="btn sm" data-act="unpublish" data-id="${p.id}">${t("ls_pending")}</button>`:`<button class="btn sm pri" data-act="approve" data-id="${p.id}" ${p.listing==="featured"&&p.featured!=="active"?'data-free="1"':""}>${t("approve")}</button>`}</div></td></tr>`).join("")}</tbody></table></div>`;
}
function aSellers(){
 return `<div class="panelhead"><h1>${t("sellers")}</h1></div><div class="tblwrap"><table class="tbl"><thead><tr><th>${t("shop")}</th><th>${t("owner")}</th><th>${t("district")}</th><th>${t("products")}</th><th>${t("orders")}</th><th>${t("revenue")}</th><th>${t("status")}</th><th></th></tr></thead><tbody>
 ${S.stores.map(s=>{const u=S.users.find(x=>x.id===s.ownerId)||{};const os=S.orders.filter(o=>o.storeId===s.id&&validOrders(o));return `<tr><td><div class="row" style="flex-wrap:nowrap">${logoHTML(s,"slogo sm")}<b class="small">${esc(L(s,"name"))}</b></div></td><td class="small">${esc(u.name)}<div class="tiny muted">${esc(u.email)} · ${esc(s.phone)}</div></td><td class="small">${esc(s.district)}</td><td class="num">${N(S.products.filter(p=>p.storeId===s.id).length)}</td><td class="num">${N(os.length)}</td><td class="num">${money(os.reduce((a,o)=>a+o.total,0))}</td><td>${s.suspended?`<span class="pill r">${t("suspended")}</span>`:`<span class="pill g">${t("active")}</span>`}</td>
  <td><div class="row" style="gap:4px;flex-wrap:nowrap"><button class="btn sm" data-go="store:${s.id}">${t("view")}</button><button class="btn sm" data-act="suspend" data-id="${s.id}">${s.suspended?t("reinstate"):t("suspend")}</button></div></td></tr>`}).join("")}</tbody></table></div>`;
}
function aOrders(){
 const list=[...S.orders].sort((a,b)=>b.created-a.created).slice(0,50);
 return `<div class="panelhead"><h1>${t("orders")}</h1><span class="small muted">${t("ship_by_seller")}</span></div><div class="tblwrap"><table class="tbl"><thead><tr><th>${t("order_no")}</th><th>${t("date")}</th><th>${t("shop")}</th><th>${t("customer_col")}</th><th>${t("ship_method")}</th><th>${t("total")}</th><th>${t("status")}</th></tr></thead><tbody>
 ${list.map(o=>`<tr><td class="num"><b>${esc(o.no)}</b></td><td class="small">${fmtDate(o.created)}</td><td class="small">${esc(L(getStore(o.storeId),"name"))}</td><td class="small">${esc(o.customer.name)}<div class="tiny muted">${esc(o.customer.district)}</div></td><td class="small">${t("ship_"+o.method)}</td><td class="num">${money(o.total)}</td><td>${stPill(o.status)}</td></tr>`).join("")}</tbody></table></div>`;
}
function aHomepage(){
 const h=S.settings.home;
 return `<div class="panelhead"><h1>${t("homepage")}</h1><button class="btn" data-go="home">${t("view")} →</button></div>
 <div class="card pad stack"><div class="panelhead" style="margin:0"><h3>${t("sections")}</h3></div><p class="small muted">${t("sections_s")}</p>
  ${h.sections.map((s,i)=>`<div class="row between"><label class="check"><input type="checkbox" data-change="secOn" data-i="${i}" ${s.on?"checked":""}> ${t("sec_"+s.key)}</label><div class="row" style="gap:6px">${s.max!=null?`<label class="row small">${t("max_items")} <input class="inp" type="number" min="2" max="20" style="width:70px;padding:5px 8px" data-change="secMax" data-i="${i}" value="${s.max}"></label>`:""}<button class="btn sm" data-act="secMove" data-i="${i}" data-d="-1" ${i===0?"disabled":""} aria-label="${t("up")}">↑</button><button class="btn sm" data-act="secMove" data-i="${i}" data-d="1" ${i===h.sections.length-1?"disabled":""} aria-label="${t("down")}">↓</button></div></div>`).join('<div class="hr"></div>')}</div>
 <div class="panelhead" style="margin:0"><h3>${t("slides")}</h3><button class="btn sm pri" data-act="addSlide">+ ${t("add_slide")}</button></div>
 ${h.slides.map((s,i)=>`<div class="card pad stack"><div class="row between"><div class="slide ${esc(s.color)}" style="padding:10px 14px;border-radius:8px;flex:1;min-width:0"><div class="txt"><span class="eyebrow">${esc(L(s,"eyebrow"))}</span><b style="font-family:var(--f-head)">${esc(L(s,"title"))}</b></div></div><div class="row" style="gap:4px"><button class="btn sm" data-act="slideMove" data-i="${i}" data-d="-1" ${i===0?"disabled":""}>↑</button><button class="btn sm" data-act="slideMove" data-i="${i}" data-d="1" ${i===h.slides.length-1?"disabled":""}>↓</button><button class="btn sm ghost" data-act="delSlide" data-i="${i}" style="color:var(--red)">${t("delete")}</button></div></div>
  <div class="grid2">${["eyebrow","title","cta"].map(f=>["en","bn"].map(l=>`<label class="field"><span>${t((f==="cta"?"button":f==="title"?"headline":"eyebrow")+"_"+l)}</span><input id="sl_${s.id}_${f}_${l}" value="${esc(s[f+"_"+l])}" data-change="slideField" data-i="${i}" data-k="${f}_${l}"></label>`).join("")).join("")}</div>
  <div class="grid3"><label class="field"><span>${t("link_to")}</span><select data-change="slideField" data-i="${i}" data-k="link">${linkOptions(s.link)}</select></label><label class="field"><span>${t("colour")}</span><select data-change="slideField" data-i="${i}" data-k="color">${colorOpts(s.color)}</select></label><label class="field"><span>${t("icon")}</span><select data-change="slideField" data-i="${i}" data-k="art">${CAT_ICONS.map(x=>`<option ${s.art===x?"selected":""}>${x}</option>`).join("")}</select></label></div></div>`).join("")}`;
}
function aMenu(){
 const m=S.settings.menu;
 return `<div class="panelhead"><h1>${t("menu")}</h1><button class="btn sm pri" data-act="addMenu">+ ${t("add_item")}</button></div><p class="small muted">${t("menu_s")}</p>
 <div class="tblwrap"><table class="tbl"><thead><tr><th>${t("label_en")}</th><th>${t("label_bn")}</th><th>${t("link_to")}</th><th>${t("highlight")}</th><th></th></tr></thead><tbody>
 ${m.map((x,i)=>`<tr><td><input class="inp" id="mn_${x.id}_en" value="${esc(x.label_en)}" data-change="menuField" data-i="${i}" data-k="label_en" aria-label="${t("label_en")}"></td><td><input class="inp" id="mn_${x.id}_bn" value="${esc(x.label_bn)}" data-change="menuField" data-i="${i}" data-k="label_bn" aria-label="${t("label_bn")}"></td><td><select class="inp" data-change="menuField" data-i="${i}" data-k="link" aria-label="${t("link_to")}">${linkOptions(x.link)}</select></td><td><input type="checkbox" class="check" data-change="menuHot" data-i="${i}" ${x.hot?"checked":""} aria-label="${t("highlight")}"></td>
  <td><div class="row" style="gap:4px;flex-wrap:nowrap"><button class="btn sm" data-act="menuMove" data-i="${i}" data-d="-1" ${i===0?"disabled":""}>↑</button><button class="btn sm" data-act="menuMove" data-i="${i}" data-d="1" ${i===m.length-1?"disabled":""}>↓</button><button class="btn sm ghost" data-act="delMenu" data-i="${i}" style="color:var(--red)">✕</button></div></td></tr>`).join("")}</tbody></table></div>`;
}
function aCategories(){
 const tops=S.categories.filter(c=>!c.parent); const cnt=id=>S.products.filter(p=>p.catId===id||getCat(p.catId)?.parent===id).length;
 return `<div class="panelhead"><h1>${t("categories")}</h1></div>
 <form class="card pad stack" data-form="cat_new"><div class="grid2"><label class="field"><span>${t("name_en")}</span><input id="ca_en" name="name_en" required></label><label class="field"><span>${t("name_bn")}</span><input id="ca_bn" name="name_bn"></label></div>
  <div class="grid3"><label class="field"><span>${t("parent")}</span><select id="ca_par" name="parent"><option value="">${t("top_level")}</option>${tops.map(c=>`<option value="${c.id}">${esc(L(c,"name"))}</option>`).join("")}</select></label><label class="field"><span>${t("icon")}</span><select id="ca_ic" name="icon">${CAT_ICONS.map(x=>`<option>${x}</option>`).join("")}</select></label><div class="field"><span>&nbsp;</span><button class="btn pri">${t("add")}</button></div></div></form>
 <div class="tblwrap"><table class="tbl"><thead><tr><th>${t("name_en")}</th><th>${t("name_bn")}</th><th>${t("products")}</th><th></th></tr></thead><tbody>
 ${tops.map(c=>[c,...S.categories.filter(x=>x.parent===c.id)]).flat().map(c=>`<tr><td><div class="row" style="flex-wrap:nowrap;${c.parent?"padding-left:24px":""}">${c.parent?"":icon(c.icon).replace("<svg ",'<svg style="width:18px;height:18px;color:var(--green)" ')}<input class="inp" id="ct_${c.id}_en" value="${esc(c.name_en)}" data-change="catField" data-id="${c.id}" data-k="name_en" aria-label="${t("name_en")}" style="${c.parent?"":"font-weight:600"}"></div></td><td><input class="inp" id="ct_${c.id}_bn" value="${esc(c.name_bn)}" data-change="catField" data-id="${c.id}" data-k="name_bn" aria-label="${t("name_bn")}"></td><td class="num">${N(cnt(c.id))}</td><td><button class="btn sm ghost" data-act="delCat" data-id="${c.id}" style="color:var(--red)">${t("delete")}</button></td></tr>`).join("")}</tbody></table></div>`;
}
function aBrands(){
 return `<div class="panelhead"><h1>${t("brands")}</h1></div>
 <form class="card pad row" data-form="brand_new"><input class="inp grow" id="br_name" name="name" required placeholder="${t("brand")}" aria-label="${t("brand")}" style="width:auto"><button class="btn pri">${t("add")}</button></form>
 <div class="row" style="gap:6px">${S.brands.map(b=>`<span class="pill" style="font-size:.85rem;padding:5px 6px 5px 12px">${esc(b.name)} <button data-act="delBrand" data-id="${b.id}" style="border:0;background:none;cursor:pointer;color:var(--muted)" aria-label="${t("delete")}">✕</button></span>`).join("")}</div>
 <div class="panelhead" style="margin-top:8px"><h1>${t("attributes")}</h1></div>
 <form class="card pad stack" data-form="attr_new"><div class="grid3"><label class="field"><span>${t("name_en")}</span><input id="at_en" name="name_en" required></label><label class="field"><span>${t("name_bn")}</span><input id="at_bn" name="name_bn"></label><label class="field"><span>${t("values")}</span><input id="at_v" name="values" required placeholder="Small, Medium, Large"></label></div><button class="btn pri" style="align-self:flex-start">${t("add")}</button></form>
 <div class="tblwrap"><table class="tbl"><thead><tr><th>${t("name_en")}</th><th>${t("name_bn")}</th><th>${t("values")}</th><th></th></tr></thead><tbody>
 ${S.attributes.map(a=>`<tr><td><input class="inp" id="atr_${a.id}_en" value="${esc(a.name_en)}" data-change="attrField" data-id="${a.id}" data-k="name_en" aria-label="${t("name_en")}"></td><td><input class="inp" id="atr_${a.id}_bn" value="${esc(a.name_bn)}" data-change="attrField" data-id="${a.id}" data-k="name_bn" aria-label="${t("name_bn")}"></td><td><input class="inp" id="atr_${a.id}_v" value="${esc(a.values)}" data-change="attrField" data-id="${a.id}" data-k="values" aria-label="${t("values")}"></td><td><button class="btn sm ghost" data-act="delAttr" data-id="${a.id}" style="color:var(--red)">${t("delete")}</button></td></tr>`).join("")}</tbody></table></div>`;
}
function aAds(){
 const reqs=[...S.adRequests].sort((a,b)=>b.at-a.at);
 return `<div class="panelhead"><h1>${t("ads")}</h1></div>
 <form class="card pad stack" data-form="ad_new"><h3>${t("new_ad")}</h3>
  <div class="grid3"><label class="field"><span>${t("placement")}</span><select id="ad_pl" name="placement">${["home_top","home_mid","cat_side"].map(k=>`<option value="${k}">${t("pl_"+k)}</option>`).join("")}</select></label><label class="field"><span>${t("link_to")}</span><select id="ad_link" name="link">${linkOptions("deals")}</select></label><label class="field"><span>${t("colour")}</span><select id="ad_col" name="color">${colorOpts("green")}</select></label></div>
  <div class="grid2"><label class="field"><span>${t("headline_en")}</span><input id="ad_ten" name="title_en" required></label><label class="field"><span>${t("headline_bn")}</span><input id="ad_tbn" name="title_bn"></label><label class="field"><span>${t("sub_en")}</span><input id="ad_sen" name="sub_en"></label><label class="field"><span>${t("sub_bn")}</span><input id="ad_sbn" name="sub_bn"></label><label class="field"><span>${t("button_en")}</span><input id="ad_cen" name="cta_en" value="Shop now"></label><label class="field"><span>${t("button_bn")}</span><input id="ad_cbn" name="cta_bn" value="এখনই কিনুন"></label></div>
  <div class="grid3"><label class="field"><span>${t("start")}</span><input id="ad_s" name="start" type="date" value="${today()}"></label><label class="field"><span>${t("end")}</span><input id="ad_e" name="end" type="date" value="${ymd(Date.now()+14*DAY)}"></label><div class="field"><span>&nbsp;</span><button class="btn pri">${t("new_ad")}</button></div></div></form>
 <div class="tblwrap"><table class="tbl"><thead><tr><th>${t("ad")}</th><th>${t("placement")}</th><th>${t("shop")}</th><th>${t("start")} – ${t("end")}</th><th>${t("status")}</th><th></th></tr></thead><tbody>
 ${S.ads.map(a=>`<tr><td style="min-width:220px"><div class="ad ${esc(a.color)}" style="padding:8px 12px"><b class="small">${esc(L(a,"title"))}</b></div></td><td class="small">${t("pl_"+a.placement)}</td><td class="small">${a.storeId?esc(L(getStore(a.storeId),"name")):t("house_ad")}</td><td class="small">${fmtShort(new Date(a.start+"T00:00"))} – ${fmtShort(new Date(a.end+"T00:00"))}</td><td><button class="pill ${a.active&&a.end>=today()?"g":""}" style="border:0;cursor:pointer" data-act="toggleAd" data-id="${a.id}">${a.end<today()?t("rq_ended"):a.active?t("active"):t("inactive")}</button></td><td><button class="btn sm ghost" data-act="delAd" data-id="${a.id}" style="color:var(--red)">${t("delete")}</button></td></tr>`).join("")}</tbody></table></div>
 <h3>${t("seller_bookings")}</h3><div class="tblwrap"><table class="tbl"><thead><tr><th>${t("shop")}</th><th>${t("placement")}</th><th>${t("days")}</th><th>${t("amount")}</th><th>${t("status")}</th></tr></thead><tbody>
 ${reqs.map(r=>`<tr><td class="small">${esc(L(getStore(r.storeId),"name"))}<div class="tiny muted">${esc(L(S.ads.find(a=>a.id===r.adId)||r,"title"))}</div></td><td class="small">${t("pl_"+r.placement)}</td><td class="num">${N(r.days)}</td><td class="num">${money(r.amount)}</td><td>${r.status==="review"?`<button class="btn sm" data-go="admin:payments">${t("rq_review")} →</button>`:`<span class="pill ${r.status==="live"?"g":"r"}">${t("rq_"+r.status)}</span>`}</td></tr>`).join("")}</tbody></table></div>`;
}
function payMethodsAdmin(){
 const L2=S.settings.mfs; const kinds=["mfs","card","cod"];
 return `<div class="card pad stack"><h3>${t("pay_methods")}</h3><p class="small muted">${t("pay_methods_s")}</p>
  <div class="tblwrap"><table class="tbl"><thead><tr><th>${t("logo")}</th><th>${t("method_name")}</th><th>${t("type")}</th><th>${t("account_no")}</th><th>${t("colour")}</th><th>${t("enabled")}</th><th></th></tr></thead><tbody>
  ${L2.map((m,i)=>`<tr style="${m.on?"":"opacity:.55"}"><td><div class="row" style="flex-wrap:nowrap;gap:6px">${payBadge(m)}<label class="btn sm">${t("upload")}<input type="file" accept="image/*" data-change="payLogo" data-i="${i}" hidden></label>${m.logo?`<button class="btn sm ghost" data-act="clearPayLogo" data-i="${i}" aria-label="${t("remove")}">✕</button>`:""}</div></td>
   <td><input class="inp" id="pmn_${i}" value="${esc(m.id)}" data-change="paySet" data-i="${i}" data-f="id" aria-label="${t("method_name")}" style="min-width:130px"></td>
   <td><select class="inp" data-change="paySet" data-i="${i}" data-f="kind" aria-label="${t("type")}" style="min-width:150px">${kinds.map(k=>`<option value="${k}" ${m.kind===k?"selected":""}>${t("k_"+k)}</option>`).join("")}</select></td>
   <td>${m.kind==="mfs"?`<input class="inp num" id="pmu_${i}" value="${esc(m.number)}" data-change="paySet" data-i="${i}" data-f="number" aria-label="${t("account_no")}" style="min-width:140px">`:`<span class="tiny muted">—</span>`}</td>
   <td><input type="color" value="${esc(m.color||"#00802B")}" data-change="paySet" data-i="${i}" data-f="color" aria-label="${t("colour")}" style="width:44px;height:34px;border:1px solid var(--line);border-radius:6px;padding:2px"></td>
   <td><label class="check"><input type="checkbox" data-change="paySet" data-i="${i}" data-f="on" ${m.on?"checked":""}> ${m.on?t("active"):t("inactive")}</label></td>
   <td><button class="btn sm ghost" data-act="delPay" data-i="${i}" style="color:var(--red)">${t("delete")}</button></td></tr>`).join("")}</tbody></table></div>
  <form class="row" data-form="pay_new" style="align-items:flex-end"><label class="field" style="flex:1;min-width:150px"><span>${t("method_name")}</span><input id="pmn_new" name="id" required placeholder="e.g. Upay, Tap, DBBL Nexus"></label>
   <label class="field"><span>${t("type")}</span><select id="pmk_new" name="kind">${kinds.map(k=>`<option value="${k}">${t("k_"+k)}</option>`).join("")}</select></label>
   <label class="field"><span>${t("account_no")}</span><input id="pmu_new" name="number" placeholder="01XXXXXXXXX"></label>
   <label class="field"><span>${t("colour")}</span><input id="pmc_new" name="color" type="color" value="#00802B" style="width:54px;height:40px;padding:3px"></label>
   <button class="btn pri">${t("add_method")}</button></form></div>`;
}
function aSettings(){
 const st=S.settings;
 return `<div class="panelhead"><h1>${t("settings")}</h1></div>
 <div class="grid2" style="align-items:start">
 <div class="card pad stack"><h3>${t("fee_settings")}</h3><div class="grid2"><label class="field"><span>${t("fee_amt")}</span><input id="st_fee" type="number" min="0" value="${st.featuredFee}" data-change="setNum" data-k="featuredFee"></label><label class="field"><span>${t("fee_days")}</span><input id="st_days" type="number" min="1" value="${st.featuredDays}" data-change="setNum" data-k="featuredDays"></label></div></div>
 <div class="card pad stack"><h3>${t("product_rules")}</h3><label class="check"><input type="checkbox" id="st_var" data-change="setVar" ${st.allowVariable?"checked":""}> ${t("allow_variable")}</label><p class="tiny muted">${t("allow_variable_s")}</p></div></div>
 <div class="card pad stack"><h3>${t("ship_settings")}</h3><p class="small muted">${t("ship_settings_s")}</p>
  <div class="tblwrap"><table class="tbl"><thead><tr><th>${t("ship_method")}</th><th>${t("enabled")}</th><th>${t("fee")}</th><th>${t("eta_en")}</th><th>${t("eta_bn")}</th></tr></thead><tbody>
  ${["dhaka","outside","pickup","negotiated"].map(k=>`<tr><td><b class="small">${t("ship_"+k)}</b></td><td><input type="checkbox" data-change="shipSet" data-k="${k}" data-f="on" ${st.ship[k].on?"checked":""} aria-label="${t("enabled")}"></td><td>${k==="negotiated"||k==="pickup"?`<span class="small muted">${k==="pickup"?t("free"):t("to_agree")}</span>`:`<input class="inp num" id="sh_${k}_fee" type="number" min="0" style="width:100px" value="${st.ship[k].fee}" data-change="shipSet" data-k="${k}" data-f="fee" aria-label="${t("fee")}">`}</td><td><input class="inp" id="sh_${k}_een" value="${esc(st.ship[k].eta_en)}" data-change="shipSet" data-k="${k}" data-f="eta_en" aria-label="${t("eta_en")}"></td><td><input class="inp" id="sh_${k}_ebn" value="${esc(st.ship[k].eta_bn)}" data-change="shipSet" data-k="${k}" data-f="eta_bn" aria-label="${t("eta_bn")}"></td></tr>`).join("")}</tbody></table></div></div>
 <div class="grid2" style="align-items:start">
 
 <div class="card pad stack"><h3>${t("ad_pricing")}</h3>${["home_top","home_mid","cat_side"].map(k=>`<label class="row between small">${t("pl_"+k)}<input class="inp num" id="ap_${k}" type="number" min="0" style="width:110px" value="${st.adPrice[k]}" data-change="adPrice" data-k="${k}"></label>`).join("")}</div></div>
 ${payMethodsAdmin()}
 <div class="card pad stack"><h3>${t("site")}</h3><div class="row"><b class="small">${t("site_logo")}</b><label class="btn sm">${t("upload")}<input type="file" accept="image/*" data-change="siteLogo" hidden></label>${st.logo?`<button class="btn sm ghost" data-act="clearLogo">${t("remove")}</button>`:""}</div><p class="tiny muted">${t("logo_s")}</p>
  <div class="grid2"><label class="field"><span>${t("support_phone")}</span><input id="st_sp" value="${esc(st.supportPhone)}" data-change="setStr" data-k="supportPhone"></label><label class="field"><span>${t("support_email")}</span><input id="st_se" value="${esc(st.supportEmail)}" data-change="setStr" data-k="supportEmail"></label></div>
  <button class="btn" style="align-self:flex-start;color:var(--red)" data-act="reset">${t("reset_demo")}</button></div>`;
}

/* ================= render ================= */
function sliderHTML(){
 const sl=S.settings.home.slides; if(!sl.length) return `<div class="slider" id="slider"></div>`;
 const i=UI.slide%sl.length; const s=sl[i];
 return `<div class="slider" id="slider"><div class="slide ${esc(s.color)}"><div class="txt"><span class="eyebrow">${esc(L(s,"eyebrow"))}</span><h2>${esc(L(s,"title"))}</h2><button class="btn" data-go="${esc(s.link)}">${esc(L(s,"cta"))} →</button></div>
  <svg class="art" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.22)" stroke-width="1.1" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${IC[s.art]||IC.basket}</svg></div>
  <div class="dots">${sl.map((_,k)=>`<button data-act="slide" data-i="${k}" aria-current="${k===i}" aria-label="Slide ${k+1}"></button>`).join("")}</div></div>`;
}
function render(keep){
 let snap=null;
 if(keep){snap={};document.querySelectorAll("#app input,#app select,#app textarea").forEach(el=>{const k=el.id||(el.name&&(el.type==="radio"||el.type==="checkbox")?el.name+"="+el.value:el.name);if(!k||el.type==="file")return;snap[k]=(el.type==="radio"||el.type==="checkbox")?{c:el.checked}:{v:el.value}})}
 document.documentElement.lang=S.lang==="bn"?"bn":"en";
 const V={wishlist:viewWishlist,home:viewHome,catalog:viewCatalog,product:viewProduct,store:viewStore,cart:viewCart,checkout:viewCheckout,done:viewDone,account:viewAccount,login:()=>viewLogin(),register:viewRegister,seller:viewSeller,admin:viewAdmin};
 $("#app").innerHTML=header()+(V[R.v]||viewHome)()+footer();
 if(snap){document.querySelectorAll("#app input,#app select,#app textarea").forEach(el=>{const k=el.id||(el.name&&(el.type==="radio"||el.type==="checkbox")?el.name+"="+el.value:el.name);const s=snap[k];if(!s||el.type==="file")return;if("c" in s){if(!el.dataset.change)el.checked=s.c}else if(el.tagName!=="SELECT"||!el.dataset.change)el.value=s.v})}
 tick();
}
function toast(msg){const el=document.createElement("div");el.className="toast";el.textContent=msg;$("#toast").appendChild(el);setTimeout(()=>el.remove(),2600)}
function openModal(title,body,wide){$("#modal").innerHTML=`<div class="modal-bg" data-act="closeModalBg"><div class="modal ${wide?"wide":""}" role="dialog" aria-modal="true" aria-label="${esc(title)}"><div class="mh"><h3>${esc(title)}</h3><button class="x" data-act="closeModal" aria-label="Close">✕</button></div><div class="mb">${body}</div></div></div>`}
function closeModal(){$("#modal").innerHTML=""}
function tick(){
 const el=document.getElementById("cd"); if(!el) return;
 const end=startOfDay(Date.now())+DAY; let s=Math.max(0,Math.floor((end-Date.now())/1000));
 const h=String(Math.floor(s/3600)).padStart(2,"0"),m=String(Math.floor(s%3600/60)).padStart(2,"0"),sec=String(s%60).padStart(2,"0");
 el.textContent=N(`${h}:${m}:${sec}`);
}
function readImg(file,max=640,png){
 return new Promise((res,rej)=>{const fr=new FileReader();fr.onerror=rej;fr.onload=()=>{const im=new Image();im.onerror=rej;im.onload=()=>{const k=Math.min(1,max/Math.max(im.width,im.height));const c=document.createElement("canvas");c.width=Math.round(im.width*k);c.height=Math.round(im.height*k);c.getContext("2d").drawImage(im,0,0,c.width,c.height);res(png?c.toDataURL("image/png"):c.toDataURL("image/jpeg",.82))};im.src=fr.result};fr.readAsDataURL(file)});
}
function payModal(pid){
 const p=getProd(pid); const st=S.settings; const m=mfsOn();
 openModal(t("pay_title"),`<div class="row" style="flex-wrap:nowrap">${`<div style="width:64px;border-radius:8px;overflow:hidden;flex:none">${pimg(p)}</div>`}<div><b class="small">${esc(L(p,"title"))}</b><div class="tiny muted">${t("featured_s",{f:money(st.featuredFee),d:N(st.featuredDays)})}</div></div></div>
  ${p.status==="approved"?`<div class="note g small">${t("convert_s")}</div>`:""}
  <p class="small">${t("pay_steps",{a:"<b>"+money(st.featuredFee)+"</b>",m:m.map(x=>x.id).join(" / ")})}</p>
  <div class="tblwrap"><table class="tbl" style="min-width:0"><tbody>${m.map(x=>`<tr><td><b>${x.id}</b></td><td class="num">${esc(x.number)}</td><td><button class="btn sm" data-act="copy" data-v="${esc(x.number)}">${t("copy")}</button></td></tr>`).join("")}</tbody></table></div>
  <form class="stack" data-form="payFee" data-id="${p.id}"><div class="grid2"><label class="field"><span>${t("method")}</span><select id="pm_m" name="method">${m.map(x=>`<option>${x.id}</option>`).join("")}</select></label><label class="field"><span>${t("sender_no")}</span><input id="pm_s" name="sender" value="${esc((myStore()||{}).phone||"")}" required></label></div>
   <label class="field"><span>${t("trx")}</span><input id="pm_t" name="trx" required style="text-transform:uppercase" placeholder="8N7A6D5E4F"></label>
   <button class="btn red">${t("submit_payment")} · ${money(st.featuredFee)}</button></form>`);
}

/* ================= actions ================= */
const ACT={
 lang:d=>{S.lang=d.l;save();render();},
 slide:d=>{UI.slide=+d.i;const el=$("#slider");if(el)el.outerHTML=sliderHTML();},
 page:d=>{R.p.page=+d.n;render();const el=document.getElementById("results");if(el)el.scrollIntoView({block:"start"});window.scrollBy(0,-130)},
 homeTab:d=>{UI.homeTab=d.t;render();},
 pdpImg:d=>{UI.pdpImg=+d.i;render();},
 qty:d=>{UI.qty=Math.max(1,Math.min(99,UI.qty+ +d.d));render();},
 addCart:(d,el,quiet)=>{const p=getProd(d.id);if(p.type==="variable"&&p.variations?.length&&UI.pdpVar<0){toast(t("choose_option"));return false}
  const vi=p.type==="variable"?UI.pdpVar:-1; const ex=S.cart.find(c=>c.pid===d.id&&(c.vi??-1)===vi); if(ex) ex.qty+=UI.qty; else S.cart.push({pid:d.id,qty:UI.qty,vi}); save(); if(!quiet){toast(t("added"));render();} return true},
 buyNow:d=>{if(ACT.addCart(d,null,true)!==false) go("cart")},
 cartQty:d=>{const c=S.cart[+d.i];c.qty=Math.max(1,c.qty+ +d.d);save();render(true)},
 cartRemove:d=>{S.cart.splice(+d.i,1);save();render(true)},
 copy:d=>{const done=()=>toast(t("copied")+": "+d.v);try{navigator.clipboard.writeText(d.v).then(done,()=>toast(d.v))}catch(e){toast(d.v)}},
 clearFilters:()=>{R.p={cat:R.p.cat,coll:R.p.coll,q:R.p.q};render()},
 toggleFilters:()=>{UI.filtersOpen=!UI.filtersOpen;render(true)},
 wish:d=>{S.wish=S.wish||[];const i=S.wish.indexOf(d.id);if(i<0){S.wish.push(d.id);toast(t("wished"))}else{S.wish.splice(i,1);toast(t("unwished"))}save();render(true)},
 cardAdd:d=>{const p=getProd(d.id);if(p.type==="variable"&&p.variations?.length){go("product:"+p.id);return}const ex=S.cart.find(c=>c.pid===p.id&&(c.vi??-1)===-1);if(ex)ex.qty++;else S.cart.push({pid:p.id,qty:1,vi:-1});save();toast(t("added"));render(true)},
 logout:()=>{S.userId=null;save();go("home")},
 demoLogin:d=>{S.userId={customer:"u_c1",seller:"u_s1",admin:"u_admin"}[d.r];save();go(d.r==="seller"?"seller:overview":d.r==="admin"?"admin:overview":"home")},
 howFeatured:()=>openModal(t("how_featured"),`<p>${t("how_featured_s",{f:money(S.settings.featuredFee),d:N(S.settings.featuredDays)})}</p><div class="steps">${[t("add_product"),t("featured_listing"),t("pay_fee"),t("verify_payments"),t("published")].map((s,i)=>`<span class="${i<4?"done":"on"}">${N(i+1)}. ${s}</span>`).join("")}</div><div class="note small">${t("ads_intro")}</div>`),
 reset:()=>{const l=S.lang;S=seed();S.lang=l;save();UI.editFor=null;closeModal();go("home");toast(t("reset_done"))},
 closeModal:()=>closeModal(),
 closeModalBg:(d,el,ev)=>{if(ev.target===el)closeModal()},
 prodFilter:d=>{UI.prodFilter=d.f;render()},
 ordFilter:d=>{UI.ordFilter=d.f;render()},
 repTab:d=>{UI.repTab=d.t;render()},
 payFee:d=>payModal(d.id),
 makeFeatured:d=>{const p=getProd(d.id);p.featured="awaiting_payment";if(p.status!=="approved")p.listing="featured";p.payNote=null;save();render();payModal(d.id)},
 delProduct:d=>{if(UI.confirmDel!==d.id){UI.confirmDel=d.id;toast(t("confirm_delete"));render();return}S.products=S.products.filter(p=>p.id!==d.id);S.cart=S.cart.filter(c=>c.pid!==d.id);UI.confirmDel=null;save();render();toast(t("deleted"))},
 delImg:d=>{UI.editImgs.splice(+d.i,1);render(true)},
 addVar:()=>{UI.editVars.push({label:"",price:"",stock:""});render(true)},
 delVar:d=>{UI.editVars.splice(+d.i,1);render(true)},
 doc:d=>{const o=S.orders.find(x=>x.id===d.id);openModal(t(d.k==="label"?"label":d.k)+" · "+o.no,`<p class="tiny muted">${t("doc_note")}</p>${docHTML(d.k,o)}`,true)},
 toggleCoupon:d=>{const c=S.coupons.find(x=>x.id===d.id);c.active=!c.active;save();render()},
 delCoupon:d=>{S.coupons=S.coupons.filter(x=>x.id!==d.id);save();render()},
 toggleGift:d=>{const g=S.gifts.find(x=>x.id===d.id);g.active=!g.active;save();render()},
 delGift:d=>{S.gifts=S.gifts.filter(x=>x.id!==d.id);save();render()},
 approve:d=>{const p=getProd(d.id);p.status="approved";p.approvedAt=Date.now();p.rejectReason=null;if(d.free){p.listing="free";if(p.featured!=="active")p.featured=null}save();render();toast(t("published"))},
 rejectListing:d=>{const p=getProd(d.id);const r=(document.getElementById("rj_"+d.id)||{}).value||"";p.status="rejected";p.rejectReason=r.trim()||"—";save();render();toast(t("rejected"))},
 unpublish:d=>{const p=getProd(d.id);p.status="pending";save();render()},
 verifyPay:d=>{const pay=S.payments.find(x=>x.id===d.id);pay.status="verified";
  if(pay.kind==="featured"){const p=getProd(pay.refId);if(p){p.featured="active";p.listing="featured";p.featuredUntil=Date.now()+S.settings.featuredDays*DAY;p.payNote=null;if(p.status==="pending"){p.status="approved";p.approvedAt=Date.now()}}}
  else{const r=S.adRequests.find(x=>x.id===pay.refId);if(r){r.status="live";const ad={id:uid("ad"),placement:r.placement,title_en:r.title_en,title_bn:r.title_bn,sub_en:r.sub_en,sub_bn:r.sub_bn,cta_en:"View",cta_bn:"দেখুন",link:r.link,color:r.color||"green",start:today(),end:ymd(Date.now()+(r.days-1)*DAY),active:true,storeId:r.storeId};S.ads.push(ad);r.adId=ad.id}}
  save();render();toast(t("published"))},
 rejectPay:d=>{const pay=S.payments.find(x=>x.id===d.id);pay.status="rejected";
  if(pay.kind==="featured"){const p=getProd(pay.refId);if(p){p.featured="awaiting_payment";p.payNote=pay.trx}}else{const r=S.adRequests.find(x=>x.id===pay.refId);if(r)r.status="rejected"}
  save();render();toast(t("rejected"))},
 suspend:d=>{const s=getStore(d.id);s.suspended=!s.suspended;save();render()},
 secMove:d=>{const a=S.settings.home.sections,i=+d.i,j=i+ +d.d;[a[i],a[j]]=[a[j],a[i]];save();render()},
 addSlide:()=>{S.settings.home.slides.push({id:uid("sl"),eyebrow_en:"New",eyebrow_bn:"নতুন",title_en:"New slide headline",title_bn:"নতুন স্লাইডের শিরোনাম",cta_en:"Shop now",cta_bn:"এখনই কিনুন",link:"deals",color:"green",art:"basket"});save();render()},
 delSlide:d=>{S.settings.home.slides.splice(+d.i,1);UI.slide=0;save();render()},
 slideMove:d=>{const a=S.settings.home.slides,i=+d.i,j=i+ +d.d;[a[i],a[j]]=[a[j],a[i]];save();render()},
 addMenu:()=>{S.settings.menu.push({id:uid("m"),label_en:"New item",label_bn:"নতুন আইটেম",link:"new"});save();render()},
 delMenu:d=>{S.settings.menu.splice(+d.i,1);save();render()},
 menuMove:d=>{const a=S.settings.menu,i=+d.i,j=i+ +d.d;[a[i],a[j]]=[a[j],a[i]];save();render()},
 delCat:d=>{const used=S.products.some(p=>p.catId===d.id||getCat(p.catId)?.parent===d.id);if(used){toast(S.lang==="bn"?"এই ক্যাটাগরিতে পণ্য আছে, আগে সেগুলো সরান।":"This category has products. Move them first.");return}S.categories=S.categories.filter(c=>c.id!==d.id&&c.parent!==d.id);save();render()},
 delBrand:d=>{S.brands=S.brands.filter(b=>b.id!==d.id);save();render()},
 delAttr:d=>{S.attributes=S.attributes.filter(a=>a.id!==d.id);save();render()},
 toggleAd:d=>{const a=S.ads.find(x=>x.id===d.id);a.active=!a.active;save();render()},
 delAd:d=>{S.ads=S.ads.filter(x=>x.id!==d.id);save();render()},
 clearPayLogo:d=>{S.settings.mfs[+d.i].logo=null;save();render(true)},
 delPay:d=>{const m=S.settings.mfs;if(m[+d.i].on&&m.filter(x=>x.on).length<=1){toast(t("method_in_use"));return}m.splice(+d.i,1);save();render();toast(t("deleted"))},
 clearLogo:()=>{S.settings.logo=null;save();render()},
};
const CHG={
 demoRole:el=>{const r=el.value;if(r==="guest"){S.userId=null;save();go("home");return}ACT.demoLogin({r})},
 sort:el=>{R.p.sort=el.value;R.p.page=1;render()},
 flt:el=>{const k=el.dataset.k;if(k==="sort"||k==="min"||k==="max")R.p[k]=el.value;else{const a=[...(R.p[k]||[])];const i=a.indexOf(el.value);if(el.checked&&i<0)a.push(el.value);if(!el.checked&&i>=0)a.splice(i,1);R.p[k]=a}R.p.page=1;render()},
 pdpVar:el=>{UI.pdpVar=+el.value;render()},
 ship:el=>{UI.ship[el.dataset.s]=el.value;render(true)},
 pay:el=>{UI.pay=el.value;render(true)},
 regRole:el=>{R.p.role=el.value;render(true)},
 editType:el=>{UI.editType=el.value;if(el.value==="variable"&&!UI.editVars.length)UI.editVars.push({label:"",price:"",stock:""});render(true)},
 addImg:async el=>{for(const f of [...el.files].slice(0,4-UI.editImgs.length)){try{UI.editImgs.push(await readImg(f))}catch(e){toast(t("img_big"))}}render(true)},
 storeImg:async el=>{const f=el.files[0];if(!f)return;try{const s=myStore();s[el.dataset.k]=await readImg(f,el.dataset.k==="banner"?1400:400);save();render(true);toast(t("saved"))}catch(e){toast(t("img_big"))}},
 siteLogo:async el=>{const f=el.files[0];if(!f)return;try{S.settings.logo=await readImg(f,400);save();render();toast(t("saved"))}catch(e){toast(t("img_big"))}},
 orderStatus:el=>{const o=S.orders.find(x=>x.id===el.dataset.id);o.status=el.value;save();toast(t("status_updated"))},
 secOn:el=>{S.settings.home.sections[+el.dataset.i].on=el.checked;save();toast(t("saved"))},
 secMax:el=>{S.settings.home.sections[+el.dataset.i].max=Math.max(2,+el.value||10);save();toast(t("saved"))},
 slideField:el=>{S.settings.home.slides[+el.dataset.i][el.dataset.k]=el.value;save();render(true);toast(t("saved"))},
 menuField:el=>{S.settings.menu[+el.dataset.i][el.dataset.k]=el.value;save();render(true);toast(t("saved"))},
 menuHot:el=>{S.settings.menu[+el.dataset.i].hot=el.checked;save();render(true)},
 catField:el=>{const c=getCat(el.dataset.id);c[el.dataset.k]=el.value;save();toast(t("saved"))},
 attrField:el=>{const a=S.attributes.find(x=>x.id===el.dataset.id);a[el.dataset.k]=el.value;save();toast(t("saved"))},
 setNum:el=>{S.settings[el.dataset.k]=Math.max(0,+el.value||0);save();toast(t("saved"))},
 setStr:el=>{S.settings[el.dataset.k]=el.value;save();toast(t("saved"))},
 setVar:el=>{S.settings.allowVariable=el.checked;save();toast(t("saved"))},
 shipSet:el=>{const s=S.settings.ship[el.dataset.k];const f=el.dataset.f;s[f]=f==="on"?el.checked:f==="fee"?Math.max(0,+el.value||0):el.value;save();toast(t("saved"))},
 mfsSet:el=>{const m=S.settings.mfs[+el.dataset.i];if(el.dataset.f==="on")m.on=el.checked;else m.number=el.value;save();toast(t("saved"))},
 adPrice:el=>{S.settings.adPrice[el.dataset.k]=Math.max(0,+el.value||0);save();toast(t("saved"))},
 mfsPick:()=>{},
 paySet:el=>{const m=S.settings.mfs[+el.dataset.i];const f=el.dataset.f;if(f==="on"){if(!el.checked&&S.settings.mfs.filter(x=>x.on).length<=1){el.checked=true;toast(t("method_in_use"));return}m.on=el.checked}else m[f]=el.value.trim?el.value.trim():el.value;save();render(true);toast(t("saved"))},
 payLogo:async el=>{const f=el.files[0];if(!f)return;try{S.settings.mfs[+el.dataset.i].logo=await readImg(f,240,true);save();render(true);toast(t("saved"))}catch(e){toast(t("img_big"))}},
};
const req=(fd,fields)=>{const miss=fields.filter(([k])=>!String(fd.get(k)||"").trim()).map(([,l])=>l);if(miss.length){toast(t("required",{f:miss.join(", ")}));return false}return true};
const FORMS={
 search:fd=>{const q=String(fd.get("q")||"").trim();R={v:"catalog",p:{q,cat:fd.get("cat")||""}};render();window.scrollTo(0,0)},
 filters:fd=>{R.p={...R.p,cond:fd.get("cond")||"",min:fd.get("min")||"",max:fd.get("max")||"",brand:fd.get("brand")||"",page:1};render()},
 storeSearch:fd=>{R.p.q=String(fd.get("q")||"");render()},
 coupon:(fd,f)=>{UI.coupons[f.dataset.s]=String(fd.get("code")||"").trim();render(true)},
 login:fd=>{const id=String(fd.get("id")).trim().toLowerCase(),pw=String(fd.get("pw"));const u=S.users.find(x=>(x.email.toLowerCase()===id||x.phone===id)&&x.pass===pw);
  if(!u){$("#loginErr").innerHTML=`<div class="note r small">${t("bad_login")}</div>`;return}S.userId=u.id;save();go(u.role==="seller"?"seller:overview":u.role==="admin"?"admin:overview":"home")},
 register:fd=>{const email=String(fd.get("email")).trim().toLowerCase(),phone=String(fd.get("phone")).trim();
  if(S.users.some(u=>u.email.toLowerCase()===email||u.phone===phone)){$("#regErr").innerHTML=`<div class="note r small">${t("email_taken")}</div>`;return}
  const u={id:uid("u"),name:String(fd.get("name")).trim(),email,phone,pass:String(fd.get("pw")),role:fd.get("role")};
  if(u.role==="seller"){const s={id:uid("s"),ownerId:u.id,name_en:String(fd.get("shop_en")).trim(),name_bn:String(fd.get("shop_bn")||"").trim(),color:"#006A4E",address:"",district:String(fd.get("district")||"Dhaka"),phone,email,whatsapp:phone,about_en:"",about_bn:"",logo:null,banner:null,pickup:false,hours_en:"",hours_bn:"",returns_en:"",returns_bn:"",mfs:"",created:Date.now(),suspended:false};S.stores.push(s);u.storeId=s.id}
  S.users.push(u);S.userId=u.id;save();if(u.role==="seller"){go("seller:setup");toast(t("welcome_seller"))}else go("home")},
 checkout:fd=>{
  if(mfsOn().some(m=>m.id===UI.pay)&&!String(fd.get("trx")||"").trim()){toast(t("trx_need"));return}
  const G=cartGroups(); const u=me(); UI.lastOrders=[]; let no=Math.max(...S.orders.map(o=>+o.no.split("-")[1]))+1;
  G.forEach(g=>{const id="o"+no;const coupon=g.disc?S.coupons.find(c=>c.storeId===g.sid&&c.code.toUpperCase()===g.code.toUpperCase()):null;if(coupon)coupon.used++;if(g.gift)g.gift.stock--;
   g.items.forEach(x=>{if(x.p.type==="variable"&&x.vi>=0)x.p.variations[x.vi].stock=Math.max(0,x.p.variations[x.vi].stock-x.qty);else x.p.stock=Math.max(0,x.p.stock-x.qty);x.p.sold+=x.qty});
   S.orders.push({id,no:"RGB-"+no,storeId:g.sid,customerId:u?.id||null,customer:{name:fd.get("name"),phone:fd.get("phone"),email:fd.get("email"),address:fd.get("address"),district:fd.get("district")},
    items:g.items.map(x=>({pid:x.p.id,title_en:x.p.title_en+(x.vi>=0&&x.p.variations?.[x.vi]?" ("+x.p.variations[x.vi].label+")":""),title_bn:(x.p.title_bn||x.p.title_en)+(x.vi>=0&&x.p.variations?.[x.vi]?" ("+x.p.variations[x.vi].label+")":""),qty:x.qty,price:x.unit})),
    method:g.sel,fee:g.fee,discount:g.disc,coupon:coupon?coupon.code:null,gift:g.gift?{name_en:g.gift.name_en,name_bn:g.gift.name_bn}:null,pay:UI.pay,trx:String(fd.get("trx")||"").toUpperCase(),subtotal:g.sub,total:g.total,status:"pending",created:Date.now(),note:fd.get("note")||""});
   UI.lastOrders.push(id);no++});
  S.cart=[];UI.coupons={};save();go("done")},
 product:(fd,f)=>{
  const editing=f.dataset.id?getProd(f.dataset.id):null; const s=myStore(); const type=UI.editType==="variable"&&S.settings.allowVariable?"variable":"simple";
  if(!req(fd,[["title_en",t("title_en")]]))return;
  if(type==="simple"&&!req(fd,[["price",t("regular_price")],["stock",t("stock")]]))return;
  const vars=UI.editVars.filter(v=>String(v.label).trim()&&+v.price>0).map(v=>({label:String(v.label).trim(),price:+v.price,stock:+v.stock||0}));
  if(type==="variable"&&!vars.length){toast(t("required",{f:t("variations")}));return}
  const p=editing||{id:uid("p"),storeId:s.id,rating:0,reviews:0,sold:0,created:Date.now(),approvedAt:null,tone:Math.floor(Math.random()*6),featured:null,featuredUntil:null,listing:"free"};
  Object.assign(p,{title_en:String(fd.get("title_en")).trim(),title_bn:String(fd.get("title_bn")||"").trim(),desc_en:String(fd.get("desc_en")||""),desc_bn:String(fd.get("desc_bn")||""),catId:fd.get("catId"),brandId:fd.get("brandId"),condition:fd.get("condition"),type,
   price:type==="variable"?Math.min(...vars.map(v=>v.price)):+fd.get("price"),sale:type==="simple"?(+fd.get("sale")||0):0,stock:type==="simple"?(+fd.get("stock")||0):0,variations:type==="variable"?vars:[],
   deal:type==="simple"&&fd.get("deal")&&+fd.get("deal_price")>0?{price:+fd.get("deal_price"),date:fd.get("deal_date")||today()}:null,sku:String(fd.get("sku")||p.sku||""),images:[...UI.editImgs],
   ship:{dhaka:!!fd.get("ship_dhaka"),outside:!!fd.get("ship_outside"),pickup:!!fd.get("ship_pickup"),negotiated:!!fd.get("ship_negotiated")},giftId:fd.get("giftId")||null,
   attrs:Object.fromEntries(S.attributes.map(a=>[a.id,fd.get("attr_"+a.id)||""])),status:"pending",rejectReason:null});
  const wantFeat=fd.get("listing")==="featured";
  if(wantFeat){p.listing="featured";p.featured="awaiting_payment";}
  if(!editing) S.products.push(p);
  UI.editFor=null; save(); go("seller:products"); toast(editing?t("prod_updated"):t("prod_saved"));
  if(wantFeat) payModal(p.id);
 },
 payFee:(fd,f)=>{const p=getProd(f.dataset.id);const trx=String(fd.get("trx")||"").trim().toUpperCase();if(!trx){toast(t("trx_need"));return}
  S.payments.push({id:uid("pay"),kind:"featured",refId:p.id,storeId:p.storeId,method:fd.get("method"),sender:String(fd.get("sender")),trx,amount:S.settings.featuredFee,at:Date.now(),status:"review"});
  p.featured="payment_review";p.payNote=null;save();closeModal();render();toast(t("pay_sent"))},
 coupon_new:fd=>{const s=myStore();const code=String(fd.get("code")).trim().toUpperCase();if(!code)return;S.coupons.push({id:uid("c"),storeId:s.id,code,type:fd.get("type"),value:+fd.get("value"),min:+fd.get("min")||0,expires:fd.get("expires"),limit:+fd.get("limit")||100,used:0,active:true});save();render();toast(t("coupon_made"))},
 gift_new:fd=>{const s=myStore();S.gifts.push({id:uid("g"),storeId:s.id,name_en:String(fd.get("name_en")).trim(),name_bn:String(fd.get("name_bn")||"").trim(),min:+fd.get("min")||0,scope:fd.get("scope"),stock:+fd.get("stock")||1,active:true});save();render();toast(t("gift_made"))},
 ad_book:fd=>{const s=myStore();const pl=fd.get("placement");const days=Math.max(1,+fd.get("days")||1);const amt=S.settings.adPrice[pl]*days;const trx=String(fd.get("trx")||"").trim().toUpperCase();if(!trx){toast(t("trx_need"));return}
  const r={id:uid("ar"),storeId:s.id,placement:pl,days,amount:amt,adId:null,status:"review",at:Date.now(),title_en:fd.get("title_en"),title_bn:fd.get("title_bn"),sub_en:fd.get("sub_en"),sub_bn:fd.get("sub_bn"),link:fd.get("link"),color:fd.get("color")};
  const pay={id:uid("pay"),kind:"ad",refId:r.id,storeId:s.id,method:fd.get("method"),sender:String(fd.get("sender")||s.phone),trx,amount:amt,at:Date.now(),status:"review"};r.payId=pay.id;
  S.adRequests.push(r);S.payments.push(pay);save();render();toast(t("ad_sent"))},
 setup:fd=>{const s=myStore();["name_en","name_bn","color","about_en","about_bn","phone","whatsapp","email","address","district","mfs","hours_en","hours_bn","returns_en","returns_bn"].forEach(k=>s[k]=String(fd.get(k)??""));s.pickup=!!fd.get("pickup");save();render();toast(t("saved"))},
 cat_new:fd=>{const par=fd.get("parent")||null;const base=String(fd.get("name_en")).toLowerCase().replace(/[^a-z]+/g,"").slice(0,6)||"cat";S.categories.push({id:(par?par+"-":"")+base+Math.random().toString(36).slice(2,4),name_en:String(fd.get("name_en")).trim(),name_bn:String(fd.get("name_bn")||"").trim(),parent:par,icon:fd.get("icon")});save();render();toast(t("saved"))},
 brand_new:fd=>{S.brands.push({id:uid("b"),name:String(fd.get("name")).trim()});save();render()},
 attr_new:fd=>{S.attributes.push({id:uid("a"),name_en:String(fd.get("name_en")).trim(),name_bn:String(fd.get("name_bn")||"").trim(),values:String(fd.get("values"))});save();render()},
 pay_new:fd=>{const id=String(fd.get("id")).trim();if(!id)return;S.settings.mfs.push({id,kind:fd.get("kind"),number:String(fd.get("number")||"").trim(),on:true,color:fd.get("color")||"#00802B",logo:null});save();render();toast(t("saved"))},
 ad_new:fd=>{S.ads.push({id:uid("ad"),placement:fd.get("placement"),title_en:fd.get("title_en"),title_bn:fd.get("title_bn"),sub_en:fd.get("sub_en"),sub_bn:fd.get("sub_bn"),cta_en:fd.get("cta_en"),cta_bn:fd.get("cta_bn"),link:fd.get("link"),color:fd.get("color"),start:fd.get("start"),end:fd.get("end"),active:true,storeId:null});save();render();toast(t("ad_made"))},
};

/* ================= events ================= */
document.addEventListener("click",ev=>{
 const a=ev.target.closest("[data-act],[data-go]"); if(!a) return;
 if(a.dataset.act){ const fn=ACT[a.dataset.act]; if(fn) fn(a.dataset,a,ev); return; }
 ev.preventDefault();closeModal();if(a.closest(".ddpanel"))UI.ddHold=true;const d=a.dataset;go(d.go,d.id?{id:d.id}:d.role?{role:d.role}:undefined);
});
document.addEventListener("change",ev=>{
 const el=ev.target;
 if(el.dataset.var!=null){UI.editVars[+el.dataset.var][el.dataset.k]=el.value;return}
 const fn=CHG[el.dataset.change]; if(fn) fn(el);
});
document.addEventListener("submit",ev=>{const f=ev.target.closest("form[data-form]");if(!f)return;ev.preventDefault();const fn=FORMS[f.dataset.form];if(fn)fn(new FormData(f),f)});
document.addEventListener("mouseover",ev=>{if(UI.ddHold&&!ev.target.closest(".dd")){UI.ddHold=false;document.querySelector(".dd")?.classList.remove("hold")}});
document.addEventListener("keydown",ev=>{if(ev.key==="Escape")closeModal();if(ev.key==="Enter"&&ev.target.matches&&ev.target.matches("div[data-go]"))ev.target.click()});
setInterval(tick,1000);
setInterval(()=>{const el=$("#slider");if(!el||el.matches(":hover")||document.hidden)return;UI.slide=(UI.slide+1)%Math.max(1,S.settings.home.slides.length);el.outerHTML=sliderHTML()},6500);

// deals stay "today" in the demo so the homepage always has a live Deals section
S.products.forEach(p=>{if(p.deal&&/^p\d+$/.test(p.id)&&p.deal.date<today())p.deal.date=today()});
const h=(location.hash||"").slice(1); if(["seller","admin","cart","login","register"].includes(h)){if(h==="seller")S.userId="u_s1";if(h==="admin")S.userId="u_admin";R={v:h,p:{}}}
render();
</script>
