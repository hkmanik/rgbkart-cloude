-- Demo reviews for testing (plan 6.1). Run AFTER 0029_reviews.sql and after demo_products.sql.
-- Makes 8 demo buyers (no password, cannot sign in), delivered demo orders (numbers DEMO-0001…) for most demo products,
-- and a product review + shop review for each order, some with a reply from the shop. Stars on cards, product and shop pages update by themselves.
-- Safe to run again (it first removes the old demo orders). Remove everything with demo_reviews_remove.sql
-- (demo_products_remove.sql also removes it, because deleting the demo shops deletes their orders).

begin;

-- 1. Demo buyers
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change)
select '00000000-0000-0000-0000-000000000000', b.id::uuid, 'authenticated', 'authenticated', b.email, '', now(),
  '{"provider":"email","providers":["email"]}', jsonb_build_object('full_name', b.nm), now() - interval '300 days', now(), '', '', '', ''
from (values
  ('d1000000-0000-4000-8000-000000000001', 'demo-buyer-1@rgbkart.test', 'Karim Ahmed'),
  ('d1000000-0000-4000-8000-000000000002', 'demo-buyer-2@rgbkart.test', 'Nusrat Jahan'),
  ('d1000000-0000-4000-8000-000000000003', 'demo-buyer-3@rgbkart.test', 'Rafiq Hasan'),
  ('d1000000-0000-4000-8000-000000000004', 'demo-buyer-4@rgbkart.test', 'Sadia Islam'),
  ('d1000000-0000-4000-8000-000000000005', 'demo-buyer-5@rgbkart.test', 'Tanvir Rahman'),
  ('d1000000-0000-4000-8000-000000000006', 'demo-buyer-6@rgbkart.test', 'Farhana Akter'),
  ('d1000000-0000-4000-8000-000000000007', 'demo-buyer-7@rgbkart.test', 'Mehedi Hasan'),
  ('d1000000-0000-4000-8000-000000000008', 'demo-buyer-8@rgbkart.test', 'Ayesha Siddiqua')) as b(id, email, nm)
on conflict (id) do nothing;
insert into public.profiles (id, full_name)
select id, raw_user_meta_data->>'full_name' from auth.users where email like 'demo-buyer-%@rgbkart.test'
on conflict (id) do nothing;
update public.profiles p set full_name = u.raw_user_meta_data->>'full_name', email_alerts = false
from auth.users u where u.id = p.id and u.email like 'demo-buyer-%@rgbkart.test';

-- 2. Start clean
delete from public.orders where order_no like 'DEMO-%';

-- 3. Orders + reviews
do $$
declare
  p record; i int := 0; n int := 0; k int; j int; seed int;
  buyers uuid[] := array['d1000000-0000-4000-8000-000000000001', 'd1000000-0000-4000-8000-000000000002', 'd1000000-0000-4000-8000-000000000003',
                         'd1000000-0000-4000-8000-000000000004', 'd1000000-0000-4000-8000-000000000005', 'd1000000-0000-4000-8000-000000000006',
                         'd1000000-0000-4000-8000-000000000007', 'd1000000-0000-4000-8000-000000000008']::uuid[];
  names text[] := array['Karim Ahmed', 'Nusrat Jahan', 'Rafiq Hasan', 'Sadia Islam', 'Tanvir Rahman', 'Farhana Akter', 'Mehedi Hasan', 'Ayesha Siddiqua'];
  short text[] := array['Karim A.', 'Nusrat J.', 'Rafiq H.', 'Sadia I.', 'Tanvir R.', 'Farhana A.', 'Mehedi H.', 'Ayesha S.'];
  places text[] := array['Mirpur 10', 'Dhanmondi 27', 'Uttara Sector 7', 'Agrabad', 'Zindabazar', 'Banani', 'Mohammadpur', 'Gulshan 2'];
  dists text[] := array['Dhaka', 'Dhaka', 'Dhaka', 'Chattogram', 'Sylhet', 'Dhaka', 'Dhaka', 'Dhaka'];
  good text[] := array['Excellent product, exactly as shown in the pictures. Highly recommended!', 'খুব ভালো পণ্য, ছবির সাথে হুবহু মিল আছে। ধন্যবাদ!',
                       'Very good quality for this price. Will buy again.', 'Original product, well packed. Very happy.',
                       'অসাধারণ! দাম অনুযায়ী মান খুবই ভালো।', 'Works perfectly. Delivery was fast too.', null];
  mid text[]  := array['Good product but delivery took a few days longer than promised.', 'মোটামুটি ভালো, তবে প্যাকেজিং আরও ভালো হতে পারত।',
                       'Okay for the price. Colour is a little different from the photo.', null];
  bad text[]  := array['Not as described. Size was smaller than I expected.', 'পণ্যের মান ভালো না, ছবির সাথে মিল নেই।', 'Item arrived late and the box was damaged.'];
  shopc text[] := array['Polite seller, called before delivery.', 'দ্রুত ডেলিভারি, ব্যবহার খুব ভালো।', 'Well packed and on time.', 'Seller answered all my questions on WhatsApp.', null, null];
  replies text[] := array['Thank you for shopping with us! 😊', 'ধন্যবাদ! আবার আসবেন।', 'Sorry for the trouble. Please call us and we will fix it.', 'Thanks for the kind words!'];
  r int; sr int; pr numeric; days int; oid bigint; cm text; rid bigint;
begin
  for p in select pr0.id, pr0.seller_id, pr0.title,
                  coalesce((select min(coalesce(v.sale_price, v.price)) from public.product_variations v where v.product_id = pr0.id and v.is_active), pr0.sale_price, pr0.price, 500) as price
           from public.products pr0
           where 'demo' = any(pr0.tags) and pr0.status = 'approved' and not coalesce(pr0.contact_only, false)
           order by pr0.id loop
    i := i + 1;
    k := (i * 7) % 5;                      -- 0–4 reviews for this product (about 4 in 5 products get some)
    for j in 1 .. k loop
      n := n + 1;
      seed := (i * 31 + j * 17) % 100;
      r := case when seed < 55 then 5 when seed < 80 then 4 when seed < 90 then 3 when seed < 96 then 2 else 1 end;
      sr := least(5, greatest(1, r + case when seed % 3 = 0 then 1 when seed % 7 = 0 then -1 else 0 end));
      days := 5 + (seed * 3 + j * 11) % 80;
      pr := coalesce(p.price, 500);
      insert into public.orders (order_no, customer_id, seller_id, status, customer_name, phone, address, district, area, ship_method, ship_fee, subtotal, total,
                                 created_at, updated_at, confirmed_at, packed_at, shipped_at, delivered_at)
      values ('DEMO-' || lpad(n::text, 4, '0'), buyers[1 + (i + j) % 8], p.seller_id, 'delivered', names[1 + (i + j) % 8], '0171100' || lpad((1000 + n)::text, 4, '0'),
              'House ' || (1 + n % 40) || ', Road ' || (1 + n % 12) || ', ' || places[1 + (i + j) % 8], dists[1 + (i + j) % 8], places[1 + (i + j) % 8],
              case when dists[1 + (i + j) % 8] = 'Dhaka' then 'dhaka' else 'outside' end, case when dists[1 + (i + j) % 8] = 'Dhaka' then 60 else 120 end,
              pr, pr + case when dists[1 + (i + j) % 8] = 'Dhaka' then 60 else 120 end,
              now() - make_interval(days => days + 4), now() - make_interval(days => days), now() - make_interval(days => days + 3),
              now() - make_interval(days => days + 2), now() - make_interval(days => days + 1), now() - make_interval(days => days))
      returning id into oid;
      insert into public.order_items (order_id, product_id, title, unit_price, qty, line_total) values (oid, p.id, p.title, pr, 1, pr);

      cm := case when r >= 4 then good[1 + seed % array_length(good, 1)] when r = 3 then mid[1 + seed % array_length(mid, 1)] else bad[1 + seed % array_length(bad, 1)] end;
      insert into public.reviews (order_id, product_id, seller_id, user_id, rating, comment, reviewer_name, created_at, updated_at)
      values (oid, p.id, p.seller_id, buyers[1 + (i + j) % 8], r, cm, short[1 + (i + j) % 8], now() - make_interval(days => days - 1), now() - make_interval(days => days - 1))
      returning id into rid;
      if seed % 3 = 1 or r <= 2 then
        update public.reviews set reply = case when r <= 2 then replies[3] else replies[1 + seed % 4] end, replied_at = now() - make_interval(days => greatest(0, days - 2)) where id = rid;
      end if;
      insert into public.reviews (order_id, product_id, seller_id, user_id, rating, comment, reviewer_name, created_at, updated_at)
      values (oid, null, p.seller_id, buyers[1 + (i + j) % 8], sr, shopc[1 + seed % array_length(shopc, 1)], short[1 + (i + j) % 8],
              now() - make_interval(days => days - 1), now() - make_interval(days => days - 1));
    end loop;
  end loop;
end $$;

-- 4. No alerts for demo orders and reviews
delete from public.notifications n using public.orders o
 where o.order_no like 'DEMO-%' and (n.ref = 'order:' || o.id or n.ref in (select 'review:' || r.id from public.reviews r where r.order_id = o.id));

commit;

select (select count(*) from public.orders where order_no like 'DEMO-%') as demo_orders,
       (select count(*) from public.reviews r join public.orders o on o.id = r.order_id where o.order_no like 'DEMO-%') as demo_reviews,
       (select count(*) from public.products where rating_count > 0) as rated_products,
       (select count(*) from public.seller_details where rating_count > 0) as rated_shops;
