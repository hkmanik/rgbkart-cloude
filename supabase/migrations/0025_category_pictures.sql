-- Category pictures: a picture for each category card (home page and All categories page).
-- image_url is a web address (https://…) or a picture on our own site (assets/…). The emoji icon is still used in small places.
-- Fills in the 20 drawings made for the main categories (only where no picture is set yet). Change them in Admin → Categories.
-- Run once in Supabase → SQL Editor, AFTER 0024_bulk_prices.sql. Safe to run again.

alter table public.categories add column if not exists image_url text
  check (image_url is null or image_url ~* '^(https://|assets/)[^\s<>"]+$');

update public.categories c set image_url = v.url
from (values
  ('Mobiles & Tablets', 'assets/categories/mobiles-and-tablets.svg'),
  ('Computers & Laptops', 'assets/categories/computers-and-laptops.svg'),
  ('Gaming & RGB Setup', 'assets/categories/gaming-and-rgb-setup.svg'),
  ('TV, Audio & Video', 'assets/categories/tv-audio-and-video.svg'),
  ('Cameras & Drones', 'assets/categories/cameras-and-drones.svg'),
  ('Home Appliances', 'assets/categories/home-appliances.svg'),
  ('Kitchen Appliances', 'assets/categories/kitchen-appliances.svg'),
  ('Men''s Fashion', 'assets/categories/men-s-fashion.svg'),
  ('Women''s Fashion', 'assets/categories/women-s-fashion.svg'),
  ('Kids & Baby', 'assets/categories/kids-and-baby.svg'),
  ('Shoes', 'assets/categories/shoes.svg'),
  ('Watches, Bags & Accessories', 'assets/categories/watches-bags-and-accessories.svg'),
  ('Health & Beauty', 'assets/categories/health-and-beauty.svg'),
  ('Groceries', 'assets/categories/groceries.svg'),
  ('Home & Living', 'assets/categories/home-and-living.svg'),
  ('Sports & Fitness', 'assets/categories/sports-and-fitness.svg'),
  ('Books & Stationery', 'assets/categories/books-and-stationery.svg'),
  ('Toys & Games', 'assets/categories/toys-and-games.svg'),
  ('Automotive & Motorbike', 'assets/categories/automotive-and-motorbike.svg'),
  ('Tools & Hardware', 'assets/categories/tools-and-hardware.svg')
) as v(name, url)
where c.name = v.name and c.parent_id is null and c.image_url is null;

select count(*) filter (where image_url is not null) as categories_with_picture, count(*) filter (where parent_id is null) as main_categories
from public.categories;
