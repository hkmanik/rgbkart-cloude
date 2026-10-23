-- Policy and information pages (plan 7.3): About, Contact, Terms, Privacy, Return & refund, Seller rules.
-- Shown at page.html?p=<name>, linked from the footer of every page, in English and Bangla.
-- The texts are DRAFTS: Admin → Pages lets you edit them (and add more pages). Fill in the parts in [square brackets]
-- (support email / phone, address, date) and ideally have a lawyer read Terms and Privacy before launch.
-- Run once in Supabase → SQL Editor, AFTER 0038_seller_verification.sql. Safe to run again: it never overwrites a page you edited.

create table if not exists public.site_pages (
  slug        text primary key check (slug ~ '^[a-z0-9-]{2,40}$'),
  title       text not null check (char_length(title) between 2 and 100),
  title_bn    text check (title_bn is null or char_length(title_bn) <= 100),
  body        text not null default '' check (char_length(body) <= 30000),
  body_bn     text check (body_bn is null or char_length(body_bn) <= 30000),
  in_footer   boolean not null default true,
  sort_order  integer not null default 100,
  is_active   boolean not null default true,
  updated_at  timestamptz not null default now(),
  updated_by  uuid
);
alter table public.site_pages enable row level security;
revoke all on public.site_pages from anon, authenticated;
grant select on public.site_pages to anon, authenticated;
grant insert, update, delete on public.site_pages to authenticated;
drop policy if exists "Everyone reads active pages" on public.site_pages;
create policy "Everyone reads active pages" on public.site_pages for select to anon, authenticated
  using (is_active or public.has_staff_role(array['master_admin', 'co_admin', 'editor']));
drop policy if exists "Master Admin and Co-admins edit pages" on public.site_pages;
create policy "Master Admin and Co-admins edit pages" on public.site_pages for all to authenticated
  using (public.has_staff_role(array['master_admin', 'co_admin'])) with check (public.has_staff_role(array['master_admin', 'co_admin']));

create or replace function public.site_pages_touch()
returns trigger language plpgsql set search_path = ''
as $$ begin new.updated_at := now(); new.updated_by := auth.uid(); return new; end; $$;
drop trigger if exists site_pages_touch on public.site_pages;
create trigger site_pages_touch before insert or update on public.site_pages for each row execute function public.site_pages_touch();
do $$ begin
  if to_regprocedure('public.log_staff_action()') is not null then
    drop trigger if exists log_staff_action on public.site_pages;
    create trigger log_staff_action after insert or update or delete on public.site_pages for each row execute function public.log_staff_action();
  end if;
end $$;

insert into public.site_pages (slug, title, title_bn, body, body_bn, sort_order) values
  ($pg$about$pg$, $pg$About RGBKart$pg$, $pg$RGBKart সম্পর্কে$pg$, $pg$RGBKart (Red & Green Basket) is an online marketplace for Bangladesh. Shops and people across all 64 districts list new and used products, and buyers order or contact them directly.

## How RGBKart works
- Sellers list their own products. Our team checks every listing before it goes live.
- Buyers order from the shop and pay the shop in cash when the order arrives (Cash on Delivery). Each shop packs and delivers its own orders.
- RGBKart does not take a commission on sales and never holds buyers' money.
- RGBKart earns only from optional services for sellers: Featured listings and advertising.

## Why buyers can trust RGBKart
- Every listing is checked by our team.
- Shops can be verified: "✓ Verified shop" means we checked their ID or trade licence.
- Ratings and reviews come only from buyers whose order was delivered.
- You can report any product or shop, and our team follows up.

## Contact
See the Contact us page.$pg$, $pg$RGBKart (রেড অ্যান্ড গ্রিন বাস্কেট) বাংলাদেশের একটি অনলাইন মার্কেটপ্লেস। দেশের ৬৪ জেলার দোকান ও মানুষ নতুন ও ব্যবহৃত পণ্য বিক্রির জন্য দেন, আর ক্রেতারা সরাসরি অর্ডার বা যোগাযোগ করেন।

## RGBKart কীভাবে কাজ করে
- বিক্রেতারা নিজেদের পণ্য দেন। প্রতিটি লিস্টিং চালু হওয়ার আগে আমাদের টিম যাচাই করে।
- ক্রেতারা দোকান থেকে অর্ডার করেন এবং পণ্য হাতে পেয়ে দোকানকে নগদ টাকা দেন (ক্যাশ অন ডেলিভারি)। প্রতিটি দোকান নিজের অর্ডার প্যাক ও ডেলিভারি করে।
- RGBKart বিক্রির উপর কোনো কমিশন নেয় না এবং ক্রেতার টাকা কখনো নিজের কাছে রাখে না।
- RGBKart শুধু বিক্রেতাদের ঐচ্ছিক সেবা থেকে আয় করে: ফিচার্ড লিস্টিং ও বিজ্ঞাপন।

## কেন RGBKart-এ ভরসা করবেন
- প্রতিটি লিস্টিং আমাদের টিম যাচাই করে।
- দোকান যাচাই করা যায়: "✓ যাচাইকৃত দোকান" মানে আমরা তাদের পরিচয়পত্র বা ট্রেড লাইসেন্স দেখেছি।
- রেটিং ও রিভিউ শুধু সেই ক্রেতারাই দেন যাঁদের অর্ডার ডেলিভারি হয়েছে।
- যেকোনো পণ্য বা দোকান রিপোর্ট করা যায়, আমাদের টিম ব্যবস্থা নেয়।

## যোগাযোগ
"যোগাযোগ" পৃষ্ঠা দেখুন।$pg$, 10),
  ($pg$contact$pg$, $pg$Contact us$pg$, $pg$যোগাযোগ$pg$, $pg$We are happy to help.

## For an order
Please contact the shop first: its phone and WhatsApp are on the shop page and on My orders. Each shop handles its own delivery, returns and refunds.

## For anything else, or if a shop does not respond
- Email: [support email]
- Phone / WhatsApp: [support number] (Saturday to Thursday, 10 am to 6 pm)
- Address: [business address], Dhaka, Bangladesh

## Report a problem
Use "⚑ Report this product" or "⚑ Report this shop" on the page. Our team checks every report and you get an alert when it is closed.$pg$, $pg$আমরা সাহায্য করতে প্রস্তুত।

## অর্ডার সংক্রান্ত
প্রথমে দোকানের সাথে যোগাযোগ করুন: দোকানের ফোন ও হোয়াটসঅ্যাপ দোকানের পৃষ্ঠা ও "আমার অর্ডার"-এ আছে। প্রতিটি দোকান নিজের ডেলিভারি, ফেরত ও টাকা ফেরত দেখে।

## অন্য যেকোনো বিষয়ে, বা দোকান সাড়া না দিলে
- ইমেইল: [support email]
- ফোন / হোয়াটসঅ্যাপ: [support number] (শনিবার থেকে বৃহস্পতিবার, সকাল ১০টা থেকে সন্ধ্যা ৬টা)
- ঠিকানা: [business address], ঢাকা, বাংলাদেশ

## সমস্যা জানান
পৃষ্ঠার "⚑ পণ্যটি রিপোর্ট করুন" বা "⚑ দোকানটি রিপোর্ট করুন" ব্যবহার করুন। আমাদের টিম প্রতিটি রিপোর্ট দেখে এবং নিষ্পত্তি হলে আপনি নোটিফিকেশন পাবেন।$pg$, 20),
  ($pg$terms$pg$, $pg$Terms of use$pg$, $pg$ব্যবহারের শর্তাবলি$pg$, $pg$Last updated: [date]. By using RGBKart you agree to these terms.

## 1. What RGBKart is
RGBKart is a marketplace. The contract of sale for any product is between the buyer and the seller. RGBKart provides the website, checks listings and helps when there is a problem, but is not the seller of products listed by shops or individuals (except products sold by the "RGBKart Official" shop).

## 2. Accounts
- Give true information and keep your password safe. You are responsible for activity on your account.
- One person or business may open one shop. We may suspend accounts that break these terms or the law.

## 3. Buying
- Prices, stock and delivery fees are set by each shop and checked again when you place the order.
- Payment is Cash on Delivery to the shop. Check the item when it arrives. Never send advance money to someone you have not met.
- Orders can be cancelled by the buyer until the shop packs them.
- Repeatedly refusing parcels or placing fake orders may lead to your account being limited, and shops can see a buyer's past delivery record.

## 4. Selling
- Sellers must follow the Seller rules, describe items honestly and deliver what was ordered.
- Our team may approve, reject or remove any listing.
- Coupons, delivery, returns and refunds are the shop's responsibility.

## 5. Featured listings and advertising
- Fees are shown before you pay and are paid by bKash, Nagad, Upay or Rocket with a transaction ID.
- Featured or an ad starts when our team confirms the payment and ends by itself after the paid period.
- Fees are not refundable once the Featured period or ad has started, unless we removed it by mistake.

## 6. Reviews, questions and reports
Write honestly and politely. Do not share phone numbers in public questions. We may hide content that is false, rude, spam or breaks the law.

## 7. Liability
We do our best to keep RGBKart safe and working, but we cannot promise it will always be available or error-free. To the extent the law allows, RGBKart is not liable for losses from a deal between a buyer and a seller. This does not limit your rights under the Consumer Rights Protection Act 2009 or other laws of Bangladesh.

## 8. Changes and law
We may update these terms; the date above shows the latest version. These terms follow the laws of Bangladesh, including the Digital Commerce Operation Guidelines 2021.$pg$, $pg$সর্বশেষ হালনাগাদ: [date]। RGBKart ব্যবহার করলে আপনি এই শর্তগুলো মেনে নিচ্ছেন।

## ১. RGBKart কী
RGBKart একটি মার্কেটপ্লেস। যেকোনো পণ্যের ক্রয়-বিক্রয় চুক্তি ক্রেতা ও বিক্রেতার মধ্যে। RGBKart ওয়েবসাইট দেয়, লিস্টিং যাচাই করে এবং সমস্যায় সাহায্য করে, কিন্তু দোকান বা ব্যক্তির দেওয়া পণ্যের বিক্রেতা নয় ("RGBKart Official" দোকানের পণ্য ছাড়া)।

## ২. অ্যাকাউন্ট
- সঠিক তথ্য দিন এবং পাসওয়ার্ড গোপন রাখুন। আপনার অ্যাকাউন্টের সব কাজের দায় আপনার।
- একজন ব্যক্তি বা প্রতিষ্ঠান একটি দোকান খুলতে পারবেন। শর্ত বা আইন ভাঙলে আমরা অ্যাকাউন্ট স্থগিত করতে পারি।

## ৩. কেনাকাটা
- দাম, স্টক ও ডেলিভারি চার্জ প্রতিটি দোকান ঠিক করে, অর্ডারের সময় আবার যাচাই হয়।
- পেমেন্ট ক্যাশ অন ডেলিভারি, দোকানকে দেবেন। পণ্য হাতে পেয়ে দেখে নিন। অপরিচিত কাউকে কখনো অগ্রিম টাকা পাঠাবেন না।
- দোকান প্যাক করার আগ পর্যন্ত ক্রেতা অর্ডার বাতিল করতে পারেন।
- বারবার পার্সেল না নেওয়া বা ভুয়া অর্ডার দিলে অ্যাকাউন্ট সীমিত হতে পারে, এবং দোকান ক্রেতার আগের ডেলিভারির রেকর্ড দেখতে পায়।

## ৪. বিক্রি
- বিক্রেতাদের বিক্রেতার নিয়ম মানতে হবে, সঠিক বর্ণনা দিতে হবে এবং অর্ডার করা পণ্যই পাঠাতে হবে।
- আমাদের টিম যেকোনো লিস্টিং অনুমোদন, বাতিল বা সরিয়ে দিতে পারে।
- কুপন, ডেলিভারি, ফেরত ও টাকা ফেরতের দায়িত্ব দোকানের।

## ৫. ফিচার্ড লিস্টিং ও বিজ্ঞাপন
- পেমেন্টের আগে ফি দেখানো হয়; বিকাশ, নগদ, উপায় বা রকেটে ট্রানজ্যাকশন আইডি দিয়ে পেমেন্ট করতে হয়।
- আমাদের টিম পেমেন্ট নিশ্চিত করলে ফিচার্ড বা বিজ্ঞাপন শুরু হয় এবং মেয়াদ শেষে নিজে থেকে বন্ধ হয়।
- ফিচার্ড বা বিজ্ঞাপন শুরু হয়ে গেলে ফি ফেরতযোগ্য নয়, যদি না আমরা ভুল করে সেটি সরিয়ে দিই।

## ৬. রিভিউ, প্রশ্ন ও রিপোর্ট
সৎ ও ভদ্রভাবে লিখুন। প্রকাশ্য প্রশ্নে ফোন নম্বর দেবেন না। মিথ্যা, অভদ্র, স্প্যাম বা আইনবিরোধী লেখা আমরা লুকিয়ে দিতে পারি।

## ৭. দায়
RGBKart নিরাপদ ও সচল রাখতে আমরা সর্বোচ্চ চেষ্টা করি, তবে সবসময় চালু বা ত্রুটিমুক্ত থাকার নিশ্চয়তা দিতে পারি না। আইন যতটুকু অনুমতি দেয়, ক্রেতা ও বিক্রেতার লেনদেনের ক্ষতির জন্য RGBKart দায়ী নয়। এতে ভোক্তা-অধিকার সংরক্ষণ আইন ২০০৯ বা বাংলাদেশের অন্য আইনে আপনার অধিকার কমে না।

## ৮. পরিবর্তন ও আইন
আমরা এই শর্ত হালনাগাদ করতে পারি; উপরের তারিখে সর্বশেষ সংস্করণ দেখা যাবে। এই শর্তাবলি বাংলাদেশের আইন, ডিজিটাল কমার্স পরিচালনা নির্দেশিকা ২০২১ সহ, অনুসরণ করে।$pg$, 30),
  ($pg$privacy$pg$, $pg$Privacy policy$pg$, $pg$গোপনীয়তা নীতি$pg$, $pg$Last updated: [date]. This explains what information RGBKart keeps and why.

## What we keep
- Account: name, email, phone, and the password (stored scrambled, we cannot read it).
- Orders: delivery name, phone, address and district, and what you ordered.
- Shops: shop details you enter, and verification documents if you choose to send them (kept private).
- Messages, questions, reviews and reports you write on RGBKart.
- A random visitor number saved in your browser to count visits. We do not store your IP address for this.
- Your language, cart and saved items are kept in your browser, and in your account when you are signed in.

## Why we use it
- To run your account, deliver orders and show you your order history.
- To give the shop the name, phone and address it needs to deliver your order.
- To send alerts about orders, payments and replies.
- To prevent fraud: for example, shops can see how many orders a buyer received or refused before (counts only).
- To improve RGBKart using total visitor numbers.

## Who can see it
- The shop you order from sees your delivery details for that order.
- RGBKart staff can see what they need to support you and keep the site safe. Staff actions are recorded.
- Public: only your first name and the first letter of your last name, next to a review or question.
- We do not sell your information. Our services are hosted with Supabase (database) and Hostinger (website).

## Your choices
- Change your details in My account, and switch alert emails off.
- Ask us to delete your account: contact us from the Contact us page. Some order records may be kept as required by law.

## Contact
Questions about privacy: see the Contact us page.$pg$, $pg$সর্বশেষ হালনাগাদ: [date]। RGBKart কোন তথ্য রাখে ও কেন, তা এখানে বলা হলো।

## আমরা কী রাখি
- অ্যাকাউন্ট: নাম, ইমেইল, ফোন এবং পাসওয়ার্ড (এলোমেলো করে রাখা হয়, আমরা পড়তে পারি না)।
- অর্ডার: ডেলিভারির নাম, ফোন, ঠিকানা ও জেলা এবং কী অর্ডার করেছেন।
- দোকান: আপনার দেওয়া দোকানের তথ্য, এবং আপনি চাইলে পাঠানো যাচাইয়ের কাগজপত্র (গোপন রাখা হয়)।
- RGBKart-এ আপনার লেখা মেসেজ, প্রশ্ন, রিভিউ ও রিপোর্ট।
- ভিজিট গোনার জন্য আপনার ব্রাউজারে রাখা একটি এলোমেলো ভিজিটর নম্বর। এজন্য আমরা আপনার আইপি ঠিকানা রাখি না।
- আপনার ভাষা, কার্ট ও সংরক্ষিত পণ্য আপনার ব্রাউজারে থাকে, আর সাইন ইন করলে আপনার অ্যাকাউন্টে।

## কেন ব্যবহার করি
- আপনার অ্যাকাউন্ট চালাতে, অর্ডার পৌঁছাতে ও অর্ডারের ইতিহাস দেখাতে।
- অর্ডার পৌঁছাতে দোকানের প্রয়োজনীয় নাম, ফোন ও ঠিকানা দিতে।
- অর্ডার, পেমেন্ট ও উত্তরের নোটিফিকেশন পাঠাতে।
- প্রতারণা ঠেকাতে: যেমন, দোকান দেখতে পায় ক্রেতা আগে কতগুলো অর্ডার নিয়েছেন বা ফেরত দিয়েছেন (শুধু সংখ্যা)।
- মোট ভিজিটর সংখ্যা দেখে RGBKart উন্নত করতে।

## কে দেখতে পায়
- আপনি যে দোকান থেকে অর্ডার করেন, সেই অর্ডারের ডেলিভারির তথ্য দোকান দেখে।
- আপনাকে সাহায্য ও সাইট নিরাপদ রাখতে যতটুকু দরকার, RGBKart টিম ততটুকু দেখে। টিমের কাজ রেকর্ড করা হয়।
- সবার জন্য: রিভিউ বা প্রশ্নের পাশে শুধু আপনার নামের প্রথম অংশ ও পদবির প্রথম অক্ষর।
- আমরা আপনার তথ্য বিক্রি করি না। আমাদের সেবা Supabase (ডাটাবেস) ও Hostinger (ওয়েবসাইট)-এ চলে।

## আপনার পছন্দ
- "আমার অ্যাকাউন্ট"-এ তথ্য বদলান এবং নোটিফিকেশন ইমেইল বন্ধ করুন।
- অ্যাকাউন্ট মুছতে চাইলে "যোগাযোগ" পৃষ্ঠা থেকে জানান। আইন অনুযায়ী কিছু অর্ডারের রেকর্ড রাখা হতে পারে।

## যোগাযোগ
গোপনীয়তা নিয়ে প্রশ্ন থাকলে "যোগাযোগ" পৃষ্ঠা দেখুন।$pg$, 40),
  ($pg$returns$pg$, $pg$Return & refund policy$pg$, $pg$ফেরত ও টাকা ফেরতের নীতি$pg$, $pg$Each shop sets how many days it accepts returns for each product (no returns, 3, 7, 15 or 30 days). You can see it on the product page before you order.

## How to return an item
1. Open My orders. Delivered items show "Return this item" until the return time ends.
2. Choose how many, the reason, refund or exchange, and add photos if the item is damaged or wrong.
3. The shop accepts (and tells you how it will collect the item) or declines with a reason. You get an alert.
4. When the shop receives the item, it gives your refund or exchange directly to you.

## Good to know
- Return the item unused, with its box, tags and accessories, unless it arrived damaged or wrong.
- Some items cannot be returned, for example food, personal care and hygiene items once opened, digital products and items marked "No returns".
- Because you pay the shop in cash on delivery, the refund comes from the shop, not from RGBKart. RGBKart never holds your money.
- Who pays the return delivery: the shop, if the item was damaged, wrong or not as described; otherwise as agreed with the shop.
- If a shop does not answer your return request within 3 days, or you disagree with its decision, report the shop and our team will step in.$pg$, $pg$প্রতিটি দোকান প্রতিটি পণ্যের জন্য কত দিনের মধ্যে ফেরত নেবে তা ঠিক করে (ফেরত নেই, ৩, ৭, ১৫ বা ৩০ দিন)। অর্ডারের আগে পণ্যের পৃষ্ঠায় এটি দেখা যায়।

## কীভাবে পণ্য ফেরত দেবেন
১. "আমার অর্ডার" খুলুন। ডেলিভারি হওয়া পণ্যে ফেরতের সময় শেষ না হওয়া পর্যন্ত "পণ্যটি ফেরত দিন" দেখা যাবে।
২. কয়টি, কারণ, টাকা ফেরত নাকি বদল বেছে নিন, এবং ভাঙা বা ভুল পণ্য হলে ছবি দিন।
৩. দোকান গ্রহণ করবে (এবং কীভাবে পণ্য নেবে জানাবে) অথবা কারণসহ না করবে। আপনি নোটিফিকেশন পাবেন।
৪. দোকান পণ্য হাতে পেলে আপনাকে সরাসরি টাকা ফেরত বা বদলি পণ্য দেবে।

## জেনে রাখুন
- পণ্য অব্যবহৃত অবস্থায় বাক্স, ট্যাগ ও অ্যাকসেসরিজসহ ফেরত দিন, যদি না ভাঙা বা ভুল পণ্য এসে থাকে।
- কিছু পণ্য ফেরত দেওয়া যায় না, যেমন খাবার, খোলা ব্যক্তিগত যত্ন ও স্বাস্থ্যবিধি পণ্য, ডিজিটাল পণ্য এবং "ফেরত নেই" লেখা পণ্য।
- আপনি ক্যাশ অন ডেলিভারিতে দোকানকে টাকা দেন, তাই টাকা ফেরত দেবে দোকান, RGBKart নয়। RGBKart কখনো আপনার টাকা রাখে না।
- ফেরতের ডেলিভারি খরচ: পণ্য ভাঙা, ভুল বা বর্ণনার সাথে না মিললে দোকান দেবে; অন্য ক্ষেত্রে দোকানের সাথে কথা বলে ঠিক হবে।
- দোকান ৩ দিনের মধ্যে আপনার ফেরতের অনুরোধের উত্তর না দিলে, বা সিদ্ধান্তে আপনি একমত না হলে, দোকানটি রিপোর্ট করুন, আমাদের টিম ব্যবস্থা নেবে।$pg$, 50),
  ($pg$seller-rules$pg$, $pg$Seller rules$pg$, $pg$বিক্রেতার নিয়ম$pg$, $pg$These rules apply to every shop and one-time seller on RGBKart.

## Listing
- Use your own clear photos and an honest title, description, condition (new or pre-owned) and price.
- One product per listing. Do not post the same item many times.
- Put your phone number, links or other contact details only in the fields made for them, not in titles, photos, descriptions or answers.

## Not allowed
- Fake or copy products, stolen goods, weapons, drugs and medicines that need a prescription, alcohol and tobacco, adult content, wildlife and animal parts protected by law, and anything illegal in Bangladesh.
- Misleading prices, fake discounts, fake reviews or buying your own products.

## Orders
- Confirm, pack and deliver orders on time and update the order steps so buyers can follow along.
- Deliver exactly what was ordered. Cancel only with a real reason the buyer can see.
- Handle returns within the days you set on each product, and answer return requests within 3 days.

## Fees
- Selling on RGBKart is free: no commission. Optional Featured listings and ads are paid before they start.
- Featured products: the title, product code and quantity cannot be changed while Featured.

## What happens if rules are broken
Our team may reject or remove listings, remove the Verified badge, end Featured without refund, or suspend the shop. Serious cases may be reported to the authorities.$pg$, $pg$এই নিয়ম RGBKart-এর সব দোকান ও এককালীন বিক্রেতার জন্য প্রযোজ্য।

## লিস্টিং
- নিজের তোলা পরিষ্কার ছবি এবং সঠিক শিরোনাম, বর্ণনা, অবস্থা (নতুন বা ব্যবহৃত) ও দাম দিন।
- এক লিস্টিংয়ে একটি পণ্য। একই পণ্য বারবার দেবেন না।
- ফোন নম্বর, লিংক বা অন্য যোগাযোগের তথ্য শুধু নির্দিষ্ট ঘরে দিন; শিরোনাম, ছবি, বর্ণনা বা উত্তরে নয়।

## যা নিষিদ্ধ
- নকল বা কপি পণ্য, চোরাই মাল, অস্ত্র, মাদক ও প্রেসক্রিপশন লাগে এমন ওষুধ, মদ ও তামাক, প্রাপ্তবয়স্কদের কনটেন্ট, আইনে সংরক্ষিত বন্যপ্রাণী ও এর অংশ, এবং বাংলাদেশে বেআইনি যেকোনো কিছু।
- বিভ্রান্তিকর দাম, ভুয়া ছাড়, ভুয়া রিভিউ বা নিজের পণ্য নিজে কেনা।

## অর্ডার
- সময়মতো অর্ডার নিশ্চিত, প্যাক ও ডেলিভারি করুন এবং অর্ডারের ধাপ হালনাগাদ রাখুন যাতে ক্রেতা অনুসরণ করতে পারেন।
- যা অর্ডার হয়েছে ঠিক তা-ই পাঠান। শুধু সত্যিকারের কারণে বাতিল করুন, যা ক্রেতা দেখতে পাবেন।
- প্রতিটি পণ্যে আপনার ঠিক করা দিনের মধ্যে ফেরত নিন, এবং ৩ দিনের মধ্যে ফেরতের অনুরোধের উত্তর দিন।

## ফি
- RGBKart-এ বিক্রি ফ্রি: কোনো কমিশন নেই। ঐচ্ছিক ফিচার্ড লিস্টিং ও বিজ্ঞাপনের টাকা শুরুর আগে দিতে হয়।
- ফিচার্ড পণ্য: ফিচার্ড থাকা অবস্থায় শিরোনাম, পণ্য কোড ও পরিমাণ বদলানো যায় না।

## নিয়ম ভাঙলে
আমাদের টিম লিস্টিং বাতিল বা সরিয়ে দিতে, যাচাইকৃত ব্যাজ তুলে নিতে, ফেরত ছাড়াই ফিচার্ড বন্ধ করতে বা দোকান স্থগিত করতে পারে। গুরুতর ক্ষেত্রে কর্তৃপক্ষকে জানানো হতে পারে।$pg$, 60)
on conflict (slug) do nothing;

select slug, title, in_footer from public.site_pages order by sort_order;
