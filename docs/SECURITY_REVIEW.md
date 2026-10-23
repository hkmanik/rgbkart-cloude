# RGBKart security review — 23 Oct 2026 (plan 7.4)

Checked on a full copy of the database (migrations 0002–0039) plus the site code.

## Fixed in `0040_security_fixes.sql`
| # | Finding | Risk | Fix |
|---|---------|------|-----|
| 1 | `public_reviews` and `public_questions` views could be **edited or deleted by anyone** (Supabase gives new tables/views full rights to `anon`/`authenticated`; simple views are writable and run as the owner, so RLS did not apply). | High | Views are read-only for visitors; `shops`, `live_ads` too. Default privileges no longer grant visitors anything on new tables/views. |
| 2 | Product rule "sellers cannot change title, SKU/barcode or quantity of a Featured product" was **not enforced** anywhere. | Medium (fee dodging) | `featured_lock` trigger on products and product_variations (staff and database functions such as `place_order` are allowed); Seller Center shows the fields locked. |
| 3 | `verified_guard` (0038) was `security definer`, so it could not tell a seller from the system. Sellers had no column right on `is_verified`, so no real exposure. | Low | Rewritten to run with the caller's rights. |
| 4 | Any signed-in user (also invisible guests) could upload files to `return-photos`. | Low (storage abuse) | Only customers with a delivered order can upload. |
| 5 | Visitors had the TRUNCATE right on several tables (not reachable through the API). | Low | Revoked everywhere. |
| 6 | Variation options could be inserted by a shop that is no longer approved. | Low | Same "approved seller" rule as other product parts. |

## Checked and fine
- Row Level Security is on for every table; read rules limit orders, messages, addresses, payments, reviews, reports, returns, documents to the people involved and staff.
- Sellers can only edit their own products/shop, and only safe columns (not status, Featured, verified, ratings, seller).
- Staff-only functions all check the staff role inside; service-only functions (`take_pending_alerts`, `alert_sent`) are not callable by visitors.
- Prices, stock, delivery fees and coupons are recalculated by the database at order time; the page cannot change them.
- Private files (return photos, seller documents, downloads) are in private buckets; only owner, the shop concerned and staff can open them (signed links, 1 hour).
- Pages build text with `textContent` (no script injection from names, reviews, questions); invoice print and `share.php` escape everything; ad links are limited to `https://` or site pages; the sign-in `next=` link only allows site pages.
- Only the publishable key is in the site; no secret keys in the code.

## To do in the Supabase dashboard (owner, before launch)
1. Authentication → Sign In / Providers → Email: keep **Confirm email** on; minimum password length 8.
2. Authentication → Attack Protection: turn on **CAPTCHA (Cloudflare Turnstile)** before launch (stops robots creating guest accounts); Claude adds the small code change when you have the Turnstile keys.
3. Advisors → **Security Advisor**: run it and send a screenshot; warnings are reviewed together.
4. Backups (plan 7.7): the free plan has no daily backups; choose Pro or a scheduled export before launch.
