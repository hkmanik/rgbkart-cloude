-- Bangla names (plan: bilingual English / Bangla).
-- Adds a Bangla name next to the English one for categories, products, shops and home page sections,
-- and fills in Bangla names for the standard categories. Shoppers who pick "বাংলা" see the Bangla name
-- when there is one, otherwise the English one.
-- Run once in Supabase → SQL Editor, AFTER 0021_alerts.sql. Safe to run again.

-- 1. New columns --------------------------------------------------------------------------------------------
alter table public.categories     add column if not exists name_bn text check (name_bn is null or char_length(name_bn) <= 80);
alter table public.home_sections  add column if not exists title_bn text check (title_bn is null or char_length(title_bn) <= 60);
alter table public.home_sections  add column if not exists subtitle_bn text check (subtitle_bn is null or char_length(subtitle_bn) <= 120);
alter table public.products       add column if not exists title_bn text check (title_bn is null or char_length(title_bn) <= 200);
alter table public.products       add column if not exists description_bn text check (description_bn is null or char_length(description_bn) <= 20000);
alter table public.seller_details add column if not exists shop_name_bn text check (shop_name_bn is null or char_length(shop_name_bn) <= 80);

-- sellers may write the Bangla title / description of their own products and the Bangla name of their shop
grant insert (title_bn, description_bn) on public.products to authenticated;
grant update (title_bn, description_bn) on public.products to authenticated;
grant update (shop_name_bn) on public.seller_details to authenticated;

-- 2. Changing the Bangla title or description of a live product sends it back for review, like the English ones
create or replace function public.products_before_write()
returns trigger language plpgsql security definer set search_path = ''
as $$
declare base text;
begin
  if tg_op = 'INSERT' then
    base := trim(both '-' from regexp_replace(lower(new.title), '[^a-z0-9]+', '-', 'g'));
    new.slug := left(coalesce(nullif(base, ''), 'product'), 80) || '-' || new.id;
    new.created_at := now();
  else
    new.slug := old.slug;
  end if;
  new.updated_at := now();
  new.tags := coalesce((select array_agg(distinct lower(trim(t))) from unnest(new.tags) t where trim(t) <> ''), '{}');
  new.title_bn := nullif(trim(coalesce(new.title_bn, '')), '');
  new.description_bn := nullif(trim(coalesce(new.description_bn, '')), '');

  if tg_op = 'UPDATE' and old.status = 'approved'
     and not public.has_staff_role(array['master_admin', 'co_admin', 'editor'])
     and (new.title is distinct from old.title
          or new.title_bn is distinct from old.title_bn
          or new.description is distinct from old.description
          or new.description_bn is distinct from old.description_bn
          or new.short_description is distinct from old.short_description
          or new.category_id is distinct from old.category_id
          or new.listing_type is distinct from old.listing_type) then
    new.status := 'pending';
  end if;
  return new;
end; $$;

-- Staff can set the Bangla title / description of any product (used by Admin → Add product)
create or replace function public.admin_set_product_bangla(p_product bigint, p_title_bn text, p_description_bn text)
returns void language plpgsql security definer set search_path = ''
as $$
begin
  if not public.has_staff_role(array['master_admin', 'co_admin', 'editor']) then raise exception 'Only RGBKart staff can do this'; end if;
  update public.products set title_bn = p_title_bn, description_bn = p_description_bn where id = p_product;
end; $$;
revoke execute on function public.admin_set_product_bangla(bigint, text, text) from public, anon;
grant  execute on function public.admin_set_product_bangla(bigint, text, text) to authenticated;

-- 3. Shops view gets the Bangla shop name (same as 0020 plus shop_name_bn at the end)
create or replace view public.shops as
  select s.user_id, s.shop_name, s.shop_slug, s.tagline, s.shop_description, s.logo_path, s.banner_path, s.city,
         case when p.role = 'individual' then null else s.phone_public end as phone_public,
         case when p.role = 'individual' then null else s.whatsapp end as whatsapp,
         case when p.role = 'individual' then null else s.email_public end as email_public,
         s.facebook_url, s.instagram_url, s.youtube_url, s.tiktok_url, s.website_url,
         s.vacation_mode, s.vacation_message, s.created_at, s.area,
         s.allow_pickup, case when s.allow_pickup then s.business_address end as pickup_address,
         s.shop_name_bn
  from public.seller_details s
  join public.profiles p on p.id = s.user_id
  where s.status = 'approved';
grant select on public.shops to anon, authenticated;

-- 4. Bangla names for the standard categories (only fills empty ones; admin can change them in Admin → Categories)
update public.categories c set name_bn = v.bn
from (values
  ('Mobiles & Tablets', 'মোবাইল ও ট্যাবলেট'), ('Computers & Laptops', 'কম্পিউটার ও ল্যাপটপ'), ('Gaming & RGB Setup', 'গেমিং ও RGB সেটআপ'),
  ('TV, Audio & Video', 'টিভি, অডিও ও ভিডিও'), ('Cameras & Drones', 'ক্যামেরা ও ড্রোন'), ('Home Appliances', 'গৃহস্থালি যন্ত্রপাতি'),
  ('Kitchen Appliances', 'রান্নাঘরের যন্ত্রপাতি'), ('Men''s Fashion', 'ছেলেদের ফ্যাশন'), ('Women''s Fashion', 'মেয়েদের ফ্যাশন'),
  ('Kids & Baby', 'শিশু ও বাচ্চাদের পণ্য'), ('Shoes', 'জুতা'), ('Watches, Bags & Accessories', 'ঘড়ি, ব্যাগ ও এক্সেসরিজ'),
  ('Health & Beauty', 'স্বাস্থ্য ও সৌন্দর্য'), ('Groceries', 'মুদি বাজার'), ('Home & Living', 'ঘর ও গৃহসজ্জা'),
  ('Sports & Fitness', 'খেলাধুলা ও ফিটনেস'), ('Books & Stationery', 'বই ও স্টেশনারি'), ('Toys & Games', 'খেলনা ও গেমস'),
  ('Automotive & Motorbike', 'গাড়ি ও মোটরবাইক'), ('Tools & Hardware', 'টুলস ও হার্ডওয়্যার'),
  ('Men', 'ছেলেদের'), ('Women', 'মেয়েদের'),
  ('Academic & Admission', 'একাডেমিক ও ভর্তি'), ('Action Cameras', 'অ্যাকশন ক্যামেরা'), ('Air Conditioners', 'এয়ার কন্ডিশনার (এসি)'),
  ('Baby Bath & Skin Care', 'শিশুর গোসল ও ত্বকের যত্ন'), ('Baby Feeding', 'শিশুর খাবার ও ফিডিং'), ('Badminton & Racket Sports', 'ব্যাডমিন্টন ও র‍্যাকেট খেলা'),
  ('Bags & Backpacks', 'ব্যাগ ও ব্যাকপ্যাক'), ('Bedding & Bath', 'বিছানা ও বাথরুম'), ('Blenders & Juicers', 'ব্লেন্ডার ও জুসার'),
  ('Bluetooth Speakers', 'ব্লুটুথ স্পিকার'), ('Board Games & Puzzles', 'বোর্ড গেম ও পাজল'), ('Camera Lenses', 'ক্যামেরা লেন্স'),
  ('Car Accessories', 'গাড়ির এক্সেসরিজ'), ('Car Electronics', 'গাড়ির ইলেকট্রনিক্স'), ('Children''s Books', 'শিশুদের বই'),
  ('Consoles & Controllers', 'কনসোল ও কন্ট্রোলার'), ('Cooking Oil & Spices', 'তেল ও মসলা'), ('Cookware & Dining', 'রান্নার বাসন ও ডাইনিং'),
  ('Cricket', 'ক্রিকেট'), ('Cycling', 'সাইক্লিং'), ('Dairy & Breakfast', 'দুধ, ডিম ও নাস্তা'),
  ('Desktops & All-in-One', 'ডেস্কটপ ও অল-ইন-ওয়ান'), ('Diapers & Wipes', 'ডায়াপার ও ওয়াইপস'), ('Digital Cameras', 'ডিজিটাল ক্যামেরা'),
  ('Dolls & Soft Toys', 'পুতুল ও সফট টয়'), ('Drones', 'ড্রোন'), ('Educational & STEM Toys', 'শিক্ষামূলক ও STEM খেলনা'),
  ('Electrical & Wiring', 'ইলেকট্রিক্যাল ও ওয়্যারিং'), ('Fans & Air Coolers', 'ফ্যান ও এয়ার কুলার'), ('Feature Phones', 'বাটন ফোন'),
  ('Fiction & Literature', 'গল্প, উপন্যাস ও সাহিত্য'), ('Football', 'ফুটবল'), ('Fragrances', 'পারফিউম ও আতর'),
  ('Furniture', 'আসবাবপত্র'), ('Gaming Headsets', 'গেমিং হেডসেট'), ('Gaming Keyboards', 'গেমিং কিবোর্ড'),
  ('Gaming Mice', 'গেমিং মাউস'), ('Gas Stoves & Cooktops', 'গ্যাস চুলা ও কুকটপ'), ('Gym & Fitness Equipment', 'জিম ও ফিটনেস সরঞ্জাম'),
  ('Hair Care', 'চুলের যত্ন'), ('Hand Tools', 'হ্যান্ড টুলস'), ('Headphones & Earbuds', 'হেডফোন ও ইয়ারবাডস'),
  ('Helmets & Riding Gear', 'হেলমেট ও রাইডিং গিয়ার'), ('Hijab & Abaya', 'হিজাব ও আবায়া'), ('Home Décor', 'ঘর সাজানো'),
  ('Household Cleaning', 'ঘর পরিষ্কারের পণ্য'), ('Irons & Garment Steamers', 'ইস্ত্রি ও গার্মেন্ট স্টিমার'), ('Islamic Books', 'ইসলামিক বই'),
  ('Jewellery & Sunglasses', 'গহনা ও সানগ্লাস'), ('Kettles & Coffee Makers', 'কেটলি ও কফি মেকার'), ('Kids Clothing', 'বাচ্চাদের পোশাক'),
  ('Kids'' Shoes', 'বাচ্চাদের জুতা'), ('Kurtis & Tops', 'কুর্তি ও টপস'), ('Laptops', 'ল্যাপটপ'),
  ('Lighting', 'লাইট ও বাতি'), ('Locks & Safety', 'তালা ও নিরাপত্তা'), ('Makeup', 'মেকআপ'),
  ('Men''s Shoes', 'ছেলেদের জুতা'), ('Microwaves, Ovens & Air Fryers', 'মাইক্রোওয়েভ, ওভেন ও এয়ার ফ্রায়ার'), ('Mobile Accessories', 'মোবাইল এক্সেসরিজ'),
  ('Monitors', 'মনিটর'), ('Motorbike Parts & Accessories', 'মোটরবাইকের পার্টস ও এক্সেসরিজ'), ('Oils & Car Care', 'ইঞ্জিন অয়েল ও গাড়ির যত্ন'),
  ('Outdoor & Ride-On Toys', 'আউটডোর ও রাইড-অন খেলনা'), ('PC Components', 'পিসি কম্পোনেন্টস'), ('Panjabi & Ethnic Wear', 'পাঞ্জাবি ও দেশি পোশাক'),
  ('Pants & Jeans', 'প্যান্ট ও জিন্স'), ('Personal Care & Hygiene', 'ব্যক্তিগত যত্ন ও পরিচ্ছন্নতা'), ('Plumbing & Sanitary', 'প্লাম্বিং ও স্যানিটারি'),
  ('Power Banks', 'পাওয়ার ব্যাংক'), ('Power Tools', 'পাওয়ার টুলস'), ('Printers & Scanners', 'প্রিন্টার ও স্ক্যানার'),
  ('Projectors & Streaming Devices', 'প্রজেক্টর ও স্ট্রিমিং ডিভাইস'), ('RGB Lights & Fans', 'RGB লাইট ও ফ্যান'), ('Refrigerators & Freezers', 'ফ্রিজ ও ফ্রিজার'),
  ('Remote Control Toys', 'রিমোট কন্ট্রোল খেলনা'), ('Rice & Multi Cookers', 'রাইস ও মাল্টি কুকার'), ('Rice, Dal & Flour', 'চাল, ডাল ও আটা'),
  ('Salwar Kameez & Three-Piece', 'সালোয়ার কামিজ ও থ্রি-পিস'), ('Sandals & Slippers', 'স্যান্ডেল ও স্লিপার'), ('Sarees', 'শাড়ি'),
  ('Security Cameras (CCTV)', 'সিকিউরিটি ক্যামেরা (সিসিটিভি)'), ('Shirts', 'শার্ট'), ('Skin Care', 'ত্বকের যত্ন'),
  ('Smartphones', 'স্মার্টফোন'), ('Smartwatches & Fitness Bands', 'স্মার্টওয়াচ ও ফিটনেস ব্যান্ড'), ('Snacks & Beverages', 'স্ন্যাকস ও পানীয়'),
  ('Soundbars & Home Theater', 'সাউন্ডবার ও হোম থিয়েটার'), ('Sports & Running Shoes', 'স্পোর্টস ও রানিং জুতা'), ('Stationery & Office Supplies', 'স্টেশনারি ও অফিস সামগ্রী'),
  ('Strollers & Baby Gear', 'স্ট্রলার ও শিশুর সরঞ্জাম'), ('T-Shirts & Polos', 'টি-শার্ট ও পোলো'), ('Tablets', 'ট্যাবলেট'),
  ('Televisions', 'টেলিভিশন'), ('Wallets & Belts', 'মানিব্যাগ ও বেল্ট'), ('Washing Machines', 'ওয়াশিং মেশিন'),
  ('Watches', 'ঘড়ি'), ('Western Wear', 'ওয়েস্টার্ন পোশাক'), ('Winter Wear', 'শীতের পোশাক'), ('Women''s Shoes', 'মেয়েদের জুতা')
) as v(en, bn)
where c.name = v.en and c.name_bn is null;

-- 5. Bangla titles for the standard home page sections (only fills empty ones)
update public.home_sections h set title_bn = case h.section_type
    when 'featured' then 'ফিচার্ড পণ্য' when 'deals' then 'আজকের ডিল' when 'newest' then 'নতুন পণ্য'
    when 'pre_owned' then 'ব্যবহৃত পণ্য' when 'free_delivery' then 'ফ্রি ডেলিভারি' end
where h.title_bn is null and h.section_type <> 'category';
update public.home_sections h set title_bn = c.name_bn
from public.categories c where h.section_type = 'category' and c.id = h.category_id and h.title_bn is null and c.name_bn is not null and h.title = c.name;

-- 6. Check ------------------------------------------------------------------------------------------------------
select (select count(*) from public.categories where name_bn is not null) as categories_in_bangla,
       (select count(*) from public.categories) as categories_total;
