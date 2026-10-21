# RGBKart · Red & Green Basket

A Bangladesh multi-vendor marketplace in English and Bangla. Zero sales commission; each seller ships their own orders. RGBKart earns only from Featured listing fees and seller advertising.

- Test site: https://rgbkartdemo.hkmanik.com
- Clickable prototype (the approved behaviour): https://rgbkartdemo.hkmanik.com/prototype/

## How the project is put together

| Part | What it is | Cost |
| --- | --- | --- |
| `site/` | The website: plain HTML, CSS and JavaScript, no build step | Free |
| Supabase | Database, sign-in (email, Google, Facebook), photo storage | Free plan during testing |
| GitHub | Stores the code; every change to `main` publishes `site/` to Hostinger | Free |
| Hostinger | Serves the site on rgbkartdemo.hkmanik.com (later rgbkart.com) | Already paid |

## Folders

| Path | Contents |
| --- | --- |
| `site/` | Everything that is published. `site/config.js` holds the Supabase URL and **anon** key. |
| `site/prototype/` | The clickable prototype, published at `/prototype/`. |
| `prototype-src/` | The prototype's source split into five parts. After editing, run `python prototype-src/build.py`. |
| `supabase/migrations/` | Database changes, numbered in order. Run each new file once in Supabase → SQL Editor. |
| `.github/workflows/deploy.yml` | Publishes `site/` to Hostinger by FTP on every push to `main`. |
| `brand/` | Original logo files (not published). |

## One-time setup (Phase 0)

1. **Supabase:** create the project (Singapore region). Copy *Project URL* and the *anon / publishable* key from Project Settings → API into `site/config.js`.
2. **Database check:** open SQL Editor, paste `supabase/migrations/0001_phase0_status.sql`, press Run.
3. **Hostinger FTP:** hPanel → Files → FTP Accounts → create an account whose folder is `public_html/rgbkartdemo`.
4. **GitHub secrets:** repository Settings → Secrets and variables → Actions → New repository secret: `FTP_SERVER`, `FTP_USERNAME`, `FTP_PASSWORD`.
5. Push to `main` (or Actions → Deploy to Hostinger → Run workflow). The home page then shows three green ticks.

## Security rules

- The Supabase **service_role / secret** key is never committed, pasted into `config.js`, or shared. The website only ever uses the anon key.
- Every table has Row Level Security switched on, with explicit policies.
- FTP and other passwords live only in GitHub Secrets.

## Phases

0 Setup · 1 Foundation · 2 Sellers & catalogue · 3 Orders · 4 Admin & extras · 5 Testing & audit · 6 Soft launch · 7 Public launch.
Full plan: "RGBKart Build, Audit & Launch Plan" document.
