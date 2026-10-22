// RGBKart "send-alerts": emails new alerts from the notifications outbox through Resend.
// Paste this whole file into Supabase → Edge Functions → Deploy a new function → "send-alerts".
// Supabase Cron calls it every 5 minutes. It needs three secrets (Edge Functions → Secrets):
//   RESEND_API_KEY  your Resend API key (starts with re_)
//   ALERT_FROM      e.g.  RGBKart <alerts@hkmanik.com>
//   SITE_URL        e.g.  https://rgbkartdemo.hkmanik.com
// SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are provided by Supabase automatically.

const SB = Deno.env.get("SUPABASE_URL")!;
const KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const RESEND = Deno.env.get("RESEND_API_KEY") ?? "";
const FROM = Deno.env.get("ALERT_FROM") ?? "RGBKart <onboarding@resend.dev>";
const SITE = (Deno.env.get("SITE_URL") ?? "https://rgbkartdemo.hkmanik.com").replace(/\/+$/, "");

type Alert = { id: number; email: string; kind: string; title: string; body: string | null; link: string | null };

async function rpc(name: string, args: Record<string, unknown> = {}) {
  const r = await fetch(`${SB}/rest/v1/rpc/${name}`, {
    method: "POST",
    headers: { apikey: KEY, Authorization: `Bearer ${KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify(args),
  });
  if (!r.ok) throw new Error(`${name}: ${r.status} ${await r.text()}`);
  const t = await r.text();
  return t ? JSON.parse(t) : null;
}

const esc = (s: string) => s.replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]!));

const BUTTON: Record<string, string> = {
  order_new: "Open my orders", order_cancelled: "Open my orders", message: "Read and reply",
  payment_ok: "Open Seller Center", payment_rejected: "Pay again", listing_approved: "See my listing",
  listing_rejected: "Fix my listing", featured_ending: "Renew Featured", ad_ending: "Book a new ad",
  shop_approved: "Open Seller Center",
};

function html(a: Alert) {
  const link = `${SITE}/${(a.link || "alerts.html").replace(/^\/+/, "")}`;
  const btn = BUTTON[a.kind] || (a.kind.startsWith("order_") ? "Track my order" : "Open RGBKart");
  return `<!doctype html><html><body style="margin:0;background:#f4f6f4;font-family:Roboto,Arial,sans-serif;color:#1d241f">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f4f6f4;padding:20px 10px"><tr><td align="center">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:560px;background:#ffffff;border-radius:14px;overflow:hidden;border:1px solid #e3e8e4">
<tr><td style="background:#00802B;border-bottom:4px solid #F5C400;padding:16px 22px">
<img src="${SITE}/assets/logo/rgb-basket-96.png" width="36" height="36" alt="" style="vertical-align:middle;background:#fff;border-radius:50%;padding:3px">
<span style="vertical-align:middle;margin-left:8px;font:700 19px Poppins,Arial,sans-serif;color:#ffffff">Red &amp; Green Basket</span></td></tr>
<tr><td style="padding:24px 22px 8px"><h1 style="margin:0 0 12px;font:600 20px Poppins,Arial,sans-serif;color:#1d241f">${esc(a.title)}</h1>
<p style="margin:0 0 20px;font-size:15px;line-height:1.55;color:#3a453d">${esc(a.body || "")}</p>
<a href="${link}" style="display:inline-block;background:#E30613;color:#ffffff;text-decoration:none;font-weight:700;font-size:15px;padding:12px 22px;border-radius:10px">${btn}</a></td></tr>
<tr><td style="padding:22px;font-size:12px;line-height:1.5;color:#6b766e">You got this email because of your activity on RGBKart.
<a href="${SITE}/alerts.html" style="color:#00802B">Turn alert emails off</a>.</td></tr>
</table></td></tr></table></body></html>`;
}

async function send(a: Alert) {
  const r = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND}`, "Content-Type": "application/json", "Idempotency-Key": `rgbkart-alert-${a.id}` },
    body: JSON.stringify({
      from: FROM, to: [a.email], subject: a.title, html: html(a),
      text: `${a.title}\n\n${a.body || ""}\n\n${SITE}/${(a.link || "alerts.html").replace(/^\/+/, "")}\n\nTurn alert emails off: ${SITE}/alerts.html`,
    }),
  });
  if (!r.ok) throw new Error(`Resend ${r.status}: ${(await r.text()).slice(0, 250)}`);
}

Deno.serve(async () => {
  if (!RESEND) return Response.json({ error: "RESEND_API_KEY secret is missing" }, { status: 500 });
  let reminders = 0, sent = 0, failed = 0;
  try {
    reminders = await rpc("queue_reminders");
    const batch: Alert[] = await rpc("take_pending_alerts", { p_limit: 40 });
    for (const a of batch) {
      try { await send(a); await rpc("alert_sent", { p_id: a.id, p_ok: true }); sent++; }
      catch (e) { await rpc("alert_sent", { p_id: a.id, p_ok: false, p_error: String((e as Error).message) }); failed++; }
      await new Promise((r) => setTimeout(r, 550)); // stay under Resend's 2 emails per second
    }
  } catch (e) {
    return Response.json({ error: String((e as Error).message), reminders, sent, failed }, { status: 500 });
  }
  return Response.json({ reminders, sent, failed });
});
