-- More Bangla names (pet and garden sub-categories). Fills only empty Bangla names. Safe to run again.
-- No temporary table this time, so Supabase will not ask about RLS.
update public.categories c set name_bn = b.bn
  from (values
  ('Pet Grooming & Hygiene', 'পোষা প্রাণীর গ্রুমিং ও পরিচ্ছন্নতা'),
  ('Pet Health & Care', 'পোষা প্রাণীর স্বাস্থ্য ও যত্ন'),
  ('Pet Housing & Supplies', 'পোষা প্রাণীর ঘর ও সামগ্রী'),
  ('Plants & Seeds', 'গাছ ও বীজ'),
  ('Soil, Fertilizers & Compost', 'মাটি, সার ও কম্পোস্ট'),
  ('Pet Food & Treats', 'পোষা প্রাণীর খাবার ও ট্রিট'),
  ('Pet Food & Nutrition', 'পোষা প্রাণীর খাবার ও পুষ্টি'),
  ('Pet Toys & Accessories', 'পোষা প্রাণীর খেলনা ও অ্যাকসেসরিজ'),
  ('Pet Accessories & Toys', 'পোষা প্রাণীর অ্যাকসেসরিজ ও খেলনা'),
  ('Live Animals', 'জীবন্ত প্রাণী'),
  ('Live Pets', 'জীবন্ত পোষা প্রাণী'),
  ('Aquarium & Fish Supplies', 'অ্যাকুয়ারিয়াম ও মাছের সামগ্রী'),
  ('Bird Supplies', 'পাখির সামগ্রী'),
  ('Livestock & Poultry', 'গবাদি পশু ও হাঁস-মুরগি'),
  ('Livestock & Poultry Supplies', 'গবাদি পশু ও হাঁস-মুরগির সামগ্রী'),
  ('Garden Tools & Equipment', 'বাগানের যন্ত্রপাতি ও সরঞ্জাম'),
  ('Gardening Tools & Equipment', 'বাগানের যন্ত্রপাতি ও সরঞ্জাম'),
  ('Garden Tools & Accessories', 'বাগানের যন্ত্রপাতি ও অ্যাকসেসরিজ'),
  ('Pots, Planters & Containers', 'টব, প্ল্যান্টার ও পাত্র'),
  ('Pots & Containers', 'টব ও পাত্র'),
  ('Garden Decor', 'বাগান সাজানো'),
  ('Garden Decor & Lighting', 'বাগান সাজানো ও লাইট'),
  ('Watering & Irrigation', 'পানি দেওয়া ও সেচ'),
  ('Irrigation', 'সেচ'),
  ('Pest Control', 'পোকামাকড় দমন'),
  ('Pest & Disease Control', 'পোকামাকড় ও রোগ দমন'),
  ('Indoor & Outdoor Plants', 'ঘরের ও বাইরের গাছ'),
  ('Flowers & Plants', 'ফুল ও গাছ'),
  ('Seeds & Bulbs', 'বীজ ও কন্দ'),
  ('Hydroponics', 'হাইড্রোপনিক্স'),
  ('Outdoor Furniture', 'বাইরের আসবাব'),
  ('Lawn & Garden', 'লন ও বাগান'),
  ('Lawn Care', 'লনের যত্ন'),
  ('Cat Supplies & Food', 'বিড়ালের খাবার ও সামগ্রী'),
  ('Dog Supplies & Food', 'কুকুরের খাবার ও সামগ্রী'),
  ('Pet Medicine', 'পোষা প্রাণীর ওষুধ'),
  ('Pet Clothing', 'পোষা প্রাণীর পোশাক'),
  ('Pet Carriers & Travel', 'পোষা প্রাণী বহনের ব্যাগ'),
  ('Pet Beds & Furniture', 'পোষা প্রাণীর বিছানা ও আসবাব')
  ) as b(en, bn)
 where c.name_bn is null and lower(trim(c.name)) = lower(b.en);

select 'category' as kind, name as still_missing_bangla from public.categories where name_bn is null
union all select 'menu link', label from public.menu_items where label_bn is null
union all select 'home section', title from public.home_sections where title_bn is null
order by 1, 2;
