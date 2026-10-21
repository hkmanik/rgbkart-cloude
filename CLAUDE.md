# RGBKart: notes for Claude

Owner and master administrator: hkmanik@gmail.com. Not a developer: explain steps in plain words, one at a time, and never ask for secret keys or passwords in chat.

## Product rules (from the Completed Work Register and the questionnaire)
- Multi-vendor, bilingual English/Bangla. Zero sales commission. Sellers ship their own orders. RGBKart never holds customers' money; it collects only Featured/Activation fees and seller advertising fees.
- Listing flow: seller submits → editor/admin reviews → for Featured, admin asks for the fee → seller pays by bKash/Nagad/Upay (manual TrxID; merchant API later) → admin verifies → publish. Featured fee and duration are admin-editable (default ৳20 / 30 days).
- Sellers cannot edit title, SKU/barcode/QR or quantity of a Featured product (prevents fee dodging).
- Variable products: only admin may add them until enabled for sellers.
- Shipping methods (Inside Dhaka, Outside Dhaka, Store pickup, Negotiated, special rates for heavy/cars/flammable) are defined by admin; each seller picks methods and sets rates.
- Roles: master admin (owner), up to 2 co-admins, 4–5 editors, sellers, customers; per-activity permissions; admin actions logged.
- VAT on invoices: admin toggles and sets rate. Card payments postponed until after soft launch.
- Customer: Google & Facebook sign-in, wishlist, chat with seller, report a seller to admin. Seller phone numbers visible to everyone.
- Brand: Poppins headings, Roboto body, Hind Siliguri for Bangla. Colours from the logo: green #00802B, red #E30613, yellow #F5C400. Header and footer share the green band with a yellow rule.

## Technical rules
- Plain HTML/CSS/JS in `site/`, no build step (the session cannot reach npm). Libraries only from cdn.jsdelivr.net with exact pinned versions.
- Supabase: anon key only in `site/config.js`; RLS on every table; schema changes as numbered SQL files in `supabase/migrations/` that the owner runs in the SQL Editor.
- Deploy: push to `main` → GitHub Action uploads `site/` to Hostinger by FTP.
- `site/prototype/` is the approved clickable prototype; match its behaviour and look. Its source is `prototype-src/`.
