// RGBKart "courier": shops book their orders with Steadfast, Pathao or RedX from Seller Center (0072_couriers.sql).
// Paste this whole file into Supabase → Edge Functions → Deploy a new function → name it "courier".
// Keep "Verify JWT" ON (the default): only signed-in users can call it, and it checks that the order is the caller's.
// It needs no extra secrets: each shop connects its own courier account in Seller Center → Delivery → Courier accounts.
// SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are provided by Supabase automatically.
//
// Actions (POST JSON { action, ... }):
//   connect { courier, creds }               check the shop's keys with the courier, then save them (server only)
//   set_store { store_id }                   Pathao: which pickup store to use
//   areas { courier, level?, parent?, district? }   Pathao city/zone/area lists, RedX delivery areas
//   book { order_id, courier, weight_kg, note, pathao?: {city_id, zone_id, area_id}, redx?: {area_id, area_name} }
//   track { order_id }                       ask the courier for the latest status

const SB = Deno.env.get("SUPABASE_URL")!;
const KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const STEADFAST = "https://portal.packzy.com/api/v1";
const PATHAO = "https://api-hermes.pathao.com";
const REDX = "https://openapi.redx.com.bd/v1.0.0-beta";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const reply = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { ...CORS, "Content-Type": "application/json" } });
class Oops extends Error {}

// ---------- database (service role) ----------
async function db(path: string, init: RequestInit = {}) {
  const r = await fetch(`${SB}/rest/v1/${path}`, {
    ...init,
    headers: { apikey: KEY, Authorization: `Bearer ${KEY}`, "Content-Type": "application/json", Prefer: "return=representation", ...(init.headers || {}) },
  });
  const t = await r.text();
  if (!r.ok) throw new Error(`database ${r.status}: ${t.slice(0, 200)}`);
  return t ? JSON.parse(t) : null;
}
async function account(seller: string, courier: string) {
  const rows = await db(`courier_accounts?seller_id=eq.${seller}&courier=eq.${courier}&select=*`);
  if (!rows.length) throw new Oops(`Connect your ${NAME[courier]} account first (Seller Center → Delivery → Courier accounts).`);
  return rows[0];
}
const NAME: Record<string, string> = { steadfast: "Steadfast", pathao: "Pathao", redx: "RedX" };

// ---------- talking to couriers ----------
async function call(url: string, init: RequestInit, who: string) {
  let r: Response;
  try { r = await fetch(url, init); } catch (_) { throw new Oops(`${who} could not be reached. Try again in a minute.`); }
  const t = await r.text();
  let j: any = null;
  try { j = JSON.parse(t); } catch { /* not JSON */ }
  if (!r.ok || (j && typeof j.status === "number" && j.status >= 400)) {
    const msg = j && (j.message || j.error || (j.errors && JSON.stringify(j.errors)) || j.detail);
    throw new Oops(`${who}: ${String(msg || t || r.status).slice(0, 300)}`);
  }
  return j ?? {};
}
const sf = (a: any, path: string, init: RequestInit = {}) =>
  call(`${STEADFAST}${path}`, { ...init, headers: { "Api-Key": a.creds.api_key, "Secret-Key": a.creds.secret_key, "Content-Type": "application/json" } }, "Steadfast");
const rx = (token: string, path: string, init: RequestInit = {}) =>
  call(`${REDX}${path}`, { ...init, headers: { "API-ACCESS-TOKEN": `Bearer ${token}`, "Content-Type": "application/json" } }, "RedX");

async function pathaoLogin(creds: any, refresh?: string) {
  const body = refresh
    ? { client_id: creds.client_id, client_secret: creds.client_secret, refresh_token: refresh, grant_type: "refresh_token" }
    : { client_id: creds.client_id, client_secret: creds.client_secret, username: creds.username, password: creds.password, grant_type: "password" };
  const j = await call(`${PATHAO}/aladdin/api/v1/issue-token`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) }, "Pathao");
  if (!j.access_token) throw new Oops("Pathao did not accept these details. Check Client ID, Client Secret, email and password.");
  return { access_token: j.access_token, refresh_token: j.refresh_token, expires_at: Date.now() + (Number(j.expires_in) || 3600) * 1000 - 600000 };
}
async function pathaoToken(a: any) {
  const t = a.token;
  if (t && t.access_token && t.expires_at > Date.now()) return t.access_token;
  let nt;
  try { nt = await pathaoLogin(a.creds, t && t.refresh_token); } catch (_) { nt = await pathaoLogin(a.creds); }
  await db(`courier_accounts?seller_id=eq.${a.seller_id}&courier=eq.pathao`, { method: "PATCH", body: JSON.stringify({ token: nt }) });
  return nt.access_token;
}
const pa = async (a: any, path: string, init: RequestInit = {}) =>
  call(`${PATHAO}${path}`, { ...init, headers: { Authorization: `Bearer ${await pathaoToken(a)}`, "Content-Type": "application/json", Accept: "application/json" } }, "Pathao");
const list = (j: any) => (j && j.data && (Array.isArray(j.data) ? j.data : j.data.data)) || [];

const s = (v: unknown, max = 200) => String(v ?? "").trim().slice(0, max);
const need = (v: unknown, what: string) => { if (!s(v)) throw new Oops(`Enter the ${what}.`); return s(v); };

// ---------- actions ----------
async function connect(user: string, b: any) {
  const c = b.courier, k = b.creds || {};
  let creds: any, settings: any = {}, token: any = null, stores: any[] = [];
  if (c === "steadfast") {
    creds = { api_key: need(k.api_key, "API key"), secret_key: need(k.secret_key, "Secret key") };
    await sf({ creds }, "/get_balance");
  } else if (c === "pathao") {
    creds = { client_id: need(k.client_id, "Client ID"), client_secret: need(k.client_secret, "Client Secret"), username: need(k.username, "Pathao login email"), password: need(k.password, "Pathao password") };
    token = await pathaoLogin(creds);
    const j = await call(`${PATHAO}/aladdin/api/v1/stores`, { headers: { Authorization: `Bearer ${token.access_token}`, Accept: "application/json" } }, "Pathao");
    stores = list(j).map((x: any) => ({ id: x.store_id, name: x.store_name }));
    if (!stores.length) throw new Oops("Your Pathao account has no pickup store yet. Add one in the Pathao merchant panel first.");
    settings = { store_id: stores[0].id, store_name: stores[0].name };
  } else if (c === "redx") {
    creds = { token: need(k.token, "API token") };
    await rx(creds.token, "/areas?district_name=Dhaka");
  } else throw new Oops("Unknown courier.");
  await db("courier_accounts?on_conflict=seller_id,courier", {
    method: "POST", headers: { Prefer: "resolution=merge-duplicates,return=minimal" },
    body: JSON.stringify({ seller_id: user, courier: c, creds, token, settings, connected_at: new Date().toISOString() }),
  });
  return { ok: true, stores, store_id: settings.store_id ?? null };
}

async function setStore(user: string, b: any) {
  const a = await account(user, "pathao");
  const j = await pa(a, "/aladdin/api/v1/stores");
  const st = list(j).find((x: any) => String(x.store_id) === String(b.store_id));
  if (!st) throw new Oops("That store was not found in your Pathao account.");
  await db(`courier_accounts?seller_id=eq.${user}&courier=eq.pathao`, { method: "PATCH", body: JSON.stringify({ settings: { store_id: st.store_id, store_name: st.store_name } }) });
  return { ok: true };
}

async function areas(user: string, b: any) {
  if (b.courier === "pathao") {
    const a = await account(user, "pathao");
    if (b.level === "zone") return { items: list(await pa(a, `/aladdin/api/v1/cities/${Number(b.parent)}/zone-list`)).map((x: any) => ({ id: x.zone_id, name: x.zone_name })) };
    if (b.level === "area") return { items: list(await pa(a, `/aladdin/api/v1/zones/${Number(b.parent)}/area-list`)).map((x: any) => ({ id: x.area_id, name: x.area_name })) };
    if (b.level === "store") return { items: list(await pa(a, "/aladdin/api/v1/stores")).map((x: any) => ({ id: x.store_id, name: x.store_name })), current: a.settings?.store_id ?? null };
    return { items: list(await pa(a, "/aladdin/api/v1/city-list")).map((x: any) => ({ id: x.city_id, name: x.city_name })) };
  }
  if (b.courier === "redx") {
    const a = await account(user, "redx");
    const q = s(b.district, 40) ? `?district_name=${encodeURIComponent(s(b.district, 40))}` : "";
    let j = await rx(a.creds.token, `/areas${q}`);
    if (q && !(j.areas || []).length) j = await rx(a.creds.token, "/areas");   // district name not known to RedX: show all areas
    return { items: (j.areas || []).map((x: any) => ({ id: x.id, name: x.name + (x.district_name ? `, ${x.district_name}` : "") })) };
  }
  throw new Oops("This courier needs no area list.");
}

async function myOrder(user: string, id: unknown) {
  const rows = await db(`orders?id=eq.${Number(id)}&select=*,order_items(qty,title)`);
  const o = rows[0];
  if (!o || o.seller_id !== user) throw new Oops("Order not found.");
  return o;
}

async function book(user: string, b: any) {
  const o = await myOrder(user, b.order_id);
  if (["cancelled", "delivered"].includes(o.status)) throw new Oops("This order is already " + o.status + ".");
  if (o.status === "pending") throw new Oops("Confirm the order first, then book the courier.");
  if (o.courier_ref) throw new Oops(`This order is already booked with ${NAME[o.courier] || o.courier} (${o.courier_tracking || o.courier_ref}).`);
  const c = b.courier, a = await account(user, c);
  const cod = Math.max(0, Math.round(Number(o.total) || 0));
  const address = [o.address, o.area, o.district].filter(Boolean).join(", ").slice(0, 250);
  const qty = (o.order_items || []).reduce((n: number, i: any) => n + (Number(i.qty) || 0), 0) || 1;
  const what = (o.order_items || []).map((i: any) => `${i.qty} x ${i.title}`).join(", ").slice(0, 200);
  const kg = Math.min(30, Math.max(0.1, Number(b.weight_kg) || 0.5));
  const note = s(b.note, 200);
  let ref = "", tracking = "", status = "booked";
  if (c === "steadfast") {
    const j = await sf(a, "/create_order", { method: "POST", body: JSON.stringify({
      invoice: o.order_no, recipient_name: s(o.customer_name, 100), recipient_phone: s(o.phone, 11), recipient_address: address, cod_amount: cod, note }) });
    const cs = j.consignment || {};
    ref = String(cs.consignment_id ?? ""); tracking = String(cs.tracking_code ?? ref); status = String(cs.status ?? "in_review");
  } else if (c === "pathao") {
    const p = b.pathao || {};
    if (!p.city_id || !p.zone_id || !p.area_id) throw new Oops("Choose the buyer's city, zone and area for Pathao.");
    if (address.length < 10) throw new Oops("The buyer's address is too short for Pathao (10 letters or more).");
    const j = await pa(a, "/aladdin/api/v1/orders", { method: "POST", body: JSON.stringify({
      store_id: Number(a.settings?.store_id), merchant_order_id: o.order_no, recipient_name: s(o.customer_name, 100), recipient_phone: s(o.phone, 11),
      recipient_address: address, recipient_city: Number(p.city_id), recipient_zone: Number(p.zone_id), recipient_area: Number(p.area_id),
      delivery_type: 48, item_type: 2, special_instruction: note || undefined, item_quantity: qty, item_weight: kg, amount_to_collect: cod, item_description: what }) });
    const d = (j && j.data) || {};
    ref = String(d.consignment_id ?? ""); tracking = ref; status = String(d.order_status ?? "Pending");
  } else if (c === "redx") {
    const r = b.redx || {};
    if (!r.area_id) throw new Oops("Choose the buyer's delivery area for RedX.");
    const j = await rx(a.creds.token, "/parcel", { method: "POST", body: JSON.stringify({
      customer_name: s(o.customer_name, 100), customer_phone: s(o.phone, 11), delivery_area: s(r.area_name, 100), delivery_area_id: Number(r.area_id),
      customer_address: address, merchant_invoice_id: o.order_no, cash_collection_amount: String(cod), parcel_weight: String(Math.round(kg * 1000)),
      instruction: note || undefined, value: String(cod) }) });
    ref = String(j.tracking_id ?? ""); tracking = ref; status = "pickup-pending";
  } else throw new Oops("Unknown courier.");
  if (!ref) throw new Oops(`${NAME[c]} did not return a tracking number. Check your ${NAME[c]} panel before trying again.`);
  const now = new Date().toISOString();
  await db(`orders?id=eq.${o.id}`, { method: "PATCH", body: JSON.stringify({
    courier: c, courier_ref: ref, courier_tracking: tracking, courier_status: status, courier_booked_at: now, courier_checked_at: now,
    tracking_note: o.tracking_note || `${NAME[c]} ${tracking}` }) });
  return { ok: true, courier: c, tracking, status };
}

async function track(user: string, b: any) {
  const o = await myOrder(user, b.order_id);
  if (!o.courier_ref) throw new Oops("This order is not booked with a courier.");
  const a = await account(user, o.courier);
  let status = o.courier_status || "";
  if (o.courier === "steadfast") status = String((await sf(a, `/status_by_cid/${encodeURIComponent(o.courier_ref)}`)).delivery_status ?? status);
  else if (o.courier === "pathao") status = String(((await pa(a, `/aladdin/api/v1/orders/${encodeURIComponent(o.courier_ref)}/info`)).data || {}).order_status ?? status);
  else if (o.courier === "redx") status = String(((await rx(a.creds.token, `/parcel/info/${encodeURIComponent(o.courier_ref)}`)).parcel || {}).status ?? status);
  await db(`orders?id=eq.${o.id}`, { method: "PATCH", body: JSON.stringify({ courier_status: status.slice(0, 60), courier_checked_at: new Date().toISOString() }) });
  return { ok: true, status };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  try {
    const auth = req.headers.get("Authorization") || "";
    const u = await fetch(`${SB}/auth/v1/user`, { headers: { apikey: KEY, Authorization: auth } });
    const user = u.ok ? (await u.json()).id : null;
    if (!user) return reply({ error: "Please sign in again." }, 401);
    const prof = await db(`profiles?id=eq.${user}&select=role`);
    if (!prof.length || prof[0].role !== "seller") return reply({ error: "Only shops can use courier booking." }, 403);
    const b = await req.json().catch(() => ({}));
    const act: Record<string, (u: string, b: any) => Promise<unknown>> = { connect, set_store: setStore, areas, book, track };
    if (!act[b.action]) return reply({ error: "Unknown action." }, 400);
    return reply(await act[b.action](user, b));
  } catch (e) {
    if (e instanceof Oops) return reply({ error: e.message }, 400);
    console.error(e);
    return reply({ error: "Something went wrong. Please try again." }, 500);
  }
});
