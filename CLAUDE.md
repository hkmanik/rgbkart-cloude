# RGBKart: notes for Claude

Owner and master administrator: hkmanik@gmail.com. Not a developer: explain steps in plain words, one at a time, and never ask for secret keys or passwords in chat.

## Product rules (from the Completed Work Register and the questionnaire)
- Multi-vendor, bilingual English/Bangla. Zero sales commission. Sellers ship their own orders. RGBKart never holds customers' money; it collects only Featured/Activation fees and seller advertising fees.
- Listing flow: seller submits → editor/admin reviews → for Featured, admin asks for the fee → seller pays by bKash/Nagad/Upay (manual TrxID; merchant API later) → admin verifies → publish. Featured rates are a list of durations admin edits in Admin → Featured & ads (starting 7 days ৳20, 15 days ৳35, 30 days ৳50). Sellers pay with TrxID; admin verifies in Admin → Payments, which starts Featured; it ends by itself after the plan's days. Admin can also give Featured free.
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
- Shop: `index.html` (home: 6×2 categories + admin-managed sections), `categories.html`, `browse.html` (left category sidebar + filters), `product.html`, `cart.html` (grouped by shop, delivery choice), `checkout.html` (Cash on Delivery), `orders.html` (customer tracking), `messages.html`. Shared: `cartlib.js` (live prices/stock/delivery per shop), `order.css`.
- Main menu: `menu.js` (self-contained; needs a `<header>` and the page's `db`; call `RGBMenu.mount()`). "All categories" panel + links from the `menu_items` table, edited in Admin → Main menu (`0016_main_menu.sql`).
- Shared shop files: `shop.css` (brand tokens, header, product/category cards) and `shop.js` (Supabase client, header with cart/wishlist/messages badges, card builders). Bump `?v=N` on both when they change.
- Selling: `sell.html` (one-time sellers, invisible anonymous sign-in, max 5 listings), `seller.html` (Seller Center for shops), `login.html` (customer/seller sign-up and sign-in).
- Admin: `admin.html` (staff roles, sellers, catalog, products review + Add product + Make Featured (free), Home page sections, Main menu, Featured rates and requests, Advertisement rates and ads, Reports).
- Admin tools (`0018_admin_tools.sql`): RGBKart Official shop = the Master Admin's own seller_details row (`is_official`); `admin_create_product` (goes live at once, photos in `admin/` folder); `admin_feature_free` (complimentary Featured, ৳0 in reports); `ad_rates` (per-day price for home_top / home_mid / cat_side) and `ads` (shoppers read only the `live_ads` view); `page_visits` + `track_visit` (random device id, no IP); `admin_report(from, to)` for Master Admin / Co-admins.
- Payments (`0019_payments.sql`): `payment_methods` (bKash/Nagad/Upay/Rocket numbers, edited in Admin → Payments); `payments` (seller sends TrxID via `submit_payment`; a TrxID is usable once, case/space-insensitive, except re-sending your own rejected one for the same item); `admin_verify_payment` starts Featured / the ad; `seller_book_ad` (Seller Center → Advertise, price = rate × days). Shared pay form: `site/pay.js` (`RGBPay.form`).
- Orders (`0020_orders.sql`): `shipping_methods` (Inside Dhaka / Outside Dhaka / Store pickup / Agree with seller; fees in Admin → Orders); `seller_details.allow_pickup`; `orders` + `order_items`; `place_order(items, ship, customer)` works out prices, stock and fees on the server and makes one order per shop (COD only, RGBKart never holds money); `update_order` (seller/admin: pending → confirmed → packed → shipped → delivered, cancel with reason; customer cancels while pending/confirmed; stock goes back); `admin_order_report`. Guests order with an anonymous sign-in. Seller Center → Orders; Admin → Orders.
- Pages currently put the Supabase URL and publishable key at the top of their script (safe to publish), not `config.js`.
- Database: `supabase/migrations/0002`–`0020` have all been run in order on the live project (owner confirmed 22 Oct 2026). Every file is safe to run again. New changes go in the next number.
- Testing locally: in the folder with the files, open a terminal and run `python -m http.server 5500`, then open `localhost:5500/index.html?v=N`.
- Project plan spreadsheet: `docs/RGBKart_Project_Plan.xlsx`.
