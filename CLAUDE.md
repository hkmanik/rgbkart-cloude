# RGBKart: notes for Claude

Owner and master administrator: hkmanik@gmail.com. Not a developer: explain steps in plain words, one at a time, and never ask for secret keys or passwords in chat.

## Product rules (from the Completed Work Register and the questionnaire)
- Multi-vendor, bilingual English/Bangla. Zero sales commission. Sellers ship their own orders. RGBKart never holds customers' money; it collects only Featured/Activation fees and seller advertising fees.
- Listing flow: seller submits → editor/admin reviews → for Featured, admin asks for the fee → seller pays by bKash/Nagad/Upay (manual TrxID; merchant API later) → admin verifies → publish. Featured fee and duration are admin-editable in Admin → Featured & ads (currently ৳50 / 30 days, owner's choice on 22 Oct 2026). Admin presses "Payment received: start"; Featured ends by itself after the plan's days.
- Sellers cannot edit title, SKU/barcode/QR or quantity of a Featured product (prevents fee dodging).
- Variable products: only admin may add them until enabled for sellers.
- Shipping methods (Inside Dhaka, Outside Dhaka, Store pickup, Negotiated, special rates for heavy/cars/flammable) are defined by admin; each seller picks methods and sets rates.
- Roles: master admin (owner), up to 2 co-admins, 4–5 editors, sellers, customers; per-activity permissions; admin actions logged.
- VAT on invoices: admin toggles and sets rate. Card payments postponed until after soft launch.
- Customer: Google & Facebook sign-in, wishlist, chat with seller (Messages page), report a seller to admin.
- Contact rules (owner's decision, 22 Oct 2026): shops show phone/WhatsApp to everyone. One-time sellers (sell.html, no account) choose Free or Featured: a FREE listing hides the seller's phone and buyers can only message on RGBKart; a FEATURED listing (after payment) shows call, WhatsApp, email and message. Enforced in the database (`listing_contact()`, `shops` view), not only on the page.
- Brand: Poppins headings, Roboto body, Hind Siliguri for Bangla. Colours from the logo: green #00802B, red #E30613, yellow #F5C400. Header and footer share the green band with a yellow rule. Header logo (owner's request, 22 Oct 2026): the basket cut from the round logo (`site/assets/logo/rgb-basket-96/192.png`) plus the wordmark "Red & Green Basket" in the logo's colours (Red red, & dark, Green green, Basket yellow) and the tagline "Your Online Marketplace", on a white pill inside the green band. Originals in `brand/`.

## Technical rules
- Plain HTML/CSS/JS in `site/`, no build step (the session cannot reach npm). Libraries only from cdn.jsdelivr.net with exact pinned versions.
- Supabase: anon key only in `site/config.js`; RLS on every table; schema changes as numbered SQL files in `supabase/migrations/` that the owner runs in the SQL Editor.
- Deploy: push to `main` → GitHub Action uploads `site/` to Hostinger by FTP.
- `site/prototype/` is the approved clickable prototype; match its behaviour and look. Its source is `prototype-src/`.

## The live app (in `site/`)
- Shop: `index.html` (home: 6×2 categories + admin-managed sections), `categories.html`, `browse.html` (left category sidebar + filters), `product.html`, `cart.html` (saved on the device until checkout is built), `messages.html`.
- Main menu: `menu.js` (self-contained; needs a `<header>` and the page's `db`; call `RGBMenu.mount()`). "All categories" panel + links from the `menu_items` table, edited in Admin → Main menu (`0016_main_menu.sql`).
- Shared shop files: `shop.css` (brand tokens, header, product/category cards) and `shop.js` (Supabase client, header with cart/wishlist/messages badges, card builders). Bump `?v=N` on both when they change.
- Selling: `sell.html` (one-time sellers, invisible anonymous sign-in, max 5 listings), `seller.html` (Seller Center for shops), `login.html` (customer/seller sign-up and sign-in).
- Admin: `admin.html` (staff roles, sellers, catalog, products review, Home page sections, Featured plans and requests).
- Pages currently put the Supabase URL and publishable key at the top of their script (safe to publish), not `config.js`.
- Database: `supabase/migrations/0002`–`0015` were run in order on the live project (22 Oct 2026); `0016_main_menu.sql` and `0017_menu_groups.sql` were added after that (check with the owner whether they have been run). Every file is safe to run again. New changes go in the next number.
- Testing locally: in the folder with the files, open a terminal and run `python -m http.server 5500`, then open `localhost:5500/index.html?v=N`.
- Project plan spreadsheet: `docs/RGBKart_Project_Plan.xlsx`.
