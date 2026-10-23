-- Cancellation rules (plan 4.5).
-- * The Master Admin or a Co-admin chooses in Admin → Orders → "Cancellation rules":
--     - until which step a buyer can cancel by themselves (New / Confirmed / Packed; starts at Confirmed),
--     - whether the buyer must give a reason (starts on).
-- * After that step the buyer can ASK the shop to cancel (with a reason). The shop accepts or declines with a note.
--   Both sides get an alert. An accepted request counts as "cancelled by the buyer" in the buyer's history.
-- * Shops and staff must still give a reason (as before). Delivered or cancelled orders can't be cancelled.
-- Run once in Supabase → SQL Editor, AFTER 0041_cod_limits.sql. Safe to run again.

insert into public.site_settings (key, value)
values ('cancel', '{"buyer_until": "confirmed", "need_reason": true}')
on conflict (key) do nothing;

alter table public.orders add column if not exists cancel_request        text check (cancel_request is null or char_length(cancel_request) <= 300);
alter table public.orders add column if not exists cancel_requested_at   timestamptz;
alter table public.orders add column if not exists cancel_request_reply  text check (cancel_request_reply is null or char_length(cancel_request_reply) <= 300);
alter table public.orders add column if not exists cancel_request_status text check (cancel_request_status is null or cancel_request_status in ('open', 'accepted', 'declined'));

-- the rules, with safe defaults
create or replace function public.cancel_rules()
returns jsonb language sql stable security definer set search_path = ''
as $$
  select jsonb_build_object(
    'buyer_until', case when s.value->>'buyer_until' in ('pending', 'confirmed', 'packed') then s.value->>'buyer_until' else 'confirmed' end,
    'need_reason', coalesce((s.value->>'need_reason')::boolean, true))
  from (select (select value from public.site_settings where key = 'cancel') as value) s
$$;
grant execute on function public.cancel_rules() to anon, authenticated;

-- 1. Change an order's step / cancel it (replaces the version from 0020) --------------------------------------------
create or replace function public.update_order(p_order bigint, p_status text, p_note text default null)
returns text language plpgsql security definer set search_path = ''
as $$
declare o record; who text; steps text[] := array['pending', 'confirmed', 'packed', 'shipped', 'delivered']; r jsonb := public.cancel_rules();
        v_note text := nullif(trim(coalesce(p_note, '')), '');
begin
  select * into o from public.orders where id = p_order for update;
  if o.id is null then raise exception 'Order not found'; end if;
  who := case when o.seller_id = auth.uid() then 'seller'
              when public.has_staff_role(array['master_admin', 'co_admin']) then 'admin'
              when o.customer_id = auth.uid() then 'customer' end;
  if who is null then raise exception 'Order not found'; end if;
  if o.status in ('delivered', 'cancelled') then raise exception 'This order is already %', o.status; end if;

  if p_status = 'cancelled' then
    if who = 'customer' then
      if array_position(steps, o.status) > array_position(steps, r->>'buyer_until') then
        raise exception 'The shop has already started on this order. Use "Ask the shop to cancel" instead.';
      end if;
      if (r->>'need_reason')::boolean and (v_note is null or v_note = 'Cancelled by customer') then raise exception 'Please choose why you are cancelling'; end if;
    elsif v_note is null then raise exception 'Give the customer a reason for cancelling';
    end if;
    update public.orders set status = 'cancelled', cancelled_at = now(), cancelled_by = who, cancel_reason = left(v_note, 300), updated_at = now(),
           cancel_request_status = case when cancel_request_status = 'open' then 'declined' else cancel_request_status end
     where id = o.id;
    -- put the stock back
    update public.products p set stock = p.stock + i.qty from public.order_items i
     where i.order_id = o.id and i.variation_id is null and p.id = i.product_id and p.manage_stock;
    update public.product_variations v set stock = v.stock + i.qty from public.order_items i
     where i.order_id = o.id and v.id = i.variation_id;
    return 'cancelled';
  end if;

  if who = 'customer' then raise exception 'Only the shop can change this order'; end if;
  if not (p_status = any (steps)) or array_position(steps, p_status) <= array_position(steps, o.status) then
    raise exception 'Choose a later step for this order';
  end if;
  update public.orders set status = p_status, updated_at = now(),
         tracking_note = coalesce(v_note, tracking_note),
         confirmed_at = case when p_status in ('confirmed', 'packed', 'shipped', 'delivered') then coalesce(confirmed_at, now()) else confirmed_at end,
         packed_at    = case when p_status in ('packed', 'shipped', 'delivered') then coalesce(packed_at, now()) else packed_at end,
         shipped_at   = case when p_status in ('shipped', 'delivered') then coalesce(shipped_at, now()) else shipped_at end,
         delivered_at = case when p_status = 'delivered' then now() else delivered_at end
   where id = o.id;
  return p_status;
end; $$;
revoke execute on function public.update_order(bigint, text, text) from public, anon;
grant  execute on function public.update_order(bigint, text, text) to authenticated;

-- 2. Buyer asks the shop to cancel (after the step they can cancel by themselves) ------------------------------------
create or replace function public.request_cancel(p_order bigint, p_reason text)
returns void language plpgsql security definer set search_path = ''
as $$
declare o record; steps text[] := array['pending', 'confirmed', 'packed', 'shipped', 'delivered']; reason text := left(nullif(trim(coalesce(p_reason, '')), ''), 300);
begin
  select * into o from public.orders where id = p_order and customer_id = auth.uid() for update;
  if o.id is null then raise exception 'Order not found'; end if;
  if o.status in ('delivered', 'cancelled') then raise exception 'This order is already %', o.status; end if;
  if reason is null then raise exception 'Please choose why you want to cancel'; end if;
  if o.cancel_request_status = 'open' then raise exception 'You already asked the shop to cancel this order'; end if;
  if o.cancel_request_status = 'declined' and o.cancel_requested_at > now() - interval '1 day' then raise exception 'The shop answered your request. Please call the shop.'; end if;
  if array_position(steps, o.status) <= array_position(steps, public.cancel_rules()->>'buyer_until') then
    raise exception 'You can cancel this order yourself';
  end if;
  update public.orders set cancel_request = reason, cancel_requested_at = now(), cancel_request_status = 'open', cancel_request_reply = null, updated_at = now()
   where id = o.id;
  perform public.notify(o.seller_id, 'cancel_request', format('Buyer asks to cancel order %s', o.order_no),
    format('%s: %s. Accept or decline in Seller Center → Orders.', o.customer_name, reason), 'seller.html#orders', 'order:' || o.id);
end; $$;
revoke execute on function public.request_cancel(bigint, text) from public, anon;
grant  execute on function public.request_cancel(bigint, text) to authenticated;

-- 3. Shop (or Master/Co-admin) answers the request --------------------------------------------------------------------
create or replace function public.answer_cancel_request(p_order bigint, p_accept boolean, p_note text default null)
returns void language plpgsql security definer set search_path = ''
as $$
declare o record; shop text; v_note text := left(nullif(trim(coalesce(p_note, '')), ''), 300);
begin
  select * into o from public.orders where id = p_order for update;
  if o.id is null or not (o.seller_id = auth.uid() or public.has_staff_role(array['master_admin', 'co_admin'])) then raise exception 'Order not found'; end if;
  if coalesce(o.cancel_request_status, '') <> 'open' then raise exception 'There is no open cancel request on this order'; end if;
  if o.status in ('delivered', 'cancelled') then raise exception 'This order is already %', o.status; end if;
  select shop_name into shop from public.seller_details where user_id = o.seller_id;
  if p_accept then
    update public.orders set status = 'cancelled', cancelled_at = now(), cancelled_by = 'customer', cancel_reason = o.cancel_request,
           cancel_request_status = 'accepted', cancel_request_reply = v_note, updated_at = now()
     where id = o.id;
    update public.products p set stock = p.stock + i.qty from public.order_items i
     where i.order_id = o.id and i.variation_id is null and p.id = i.product_id and p.manage_stock;
    update public.product_variations v set stock = v.stock + i.qty from public.order_items i
     where i.order_id = o.id and v.id = i.variation_id;
    perform public.notify(o.customer_id, 'cancel_ok', format('Order %s is cancelled as you asked', o.order_no),
      format('%s accepted your request%s.', coalesce(shop, 'The shop'), coalesce(': ' || v_note, '')), 'orders.html', 'order:' || o.id, o.email);
  else
    if v_note is null then raise exception 'Tell the buyer why the order can''t be cancelled'; end if;
    update public.orders set cancel_request_status = 'declined', cancel_request_reply = v_note, updated_at = now() where id = o.id;
    perform public.notify(o.customer_id, 'cancel_no', format('Order %s: the shop could not cancel it', o.order_no),
      format('%s: %s', coalesce(shop, 'The shop'), v_note), 'orders.html', 'order:' || o.id, o.email);
  end if;
end; $$;
revoke execute on function public.answer_cancel_request(bigint, boolean, text) from public, anon;
grant  execute on function public.answer_cancel_request(bigint, boolean, text) to authenticated;

-- 4. Order alerts: no "cancelled by the customer" alert to the shop when the shop itself accepted the request ----------
create or replace function public.alerts_orders()
returns trigger language plpgsql security definer set search_path = ''
as $$
declare shop text; items text; st text;
begin
  select shop_name into shop from public.seller_details where user_id = new.seller_id;
  select string_agg(qty || ' × ' || title, ', ') into items from public.order_items where order_id = new.id;
  if tg_op = 'INSERT' then
    return new;   -- order_items are added after the order row; the "placed" alerts are sent by alerts_order_items
  end if;
  if new.status is distinct from old.status then
    st := case new.status when 'confirmed' then 'confirmed' when 'packed' then 'packed and ready to send' when 'shipped' then 'on the way'
                          when 'delivered' then 'delivered' when 'cancelled' then 'cancelled' end;
    if st is not null and coalesce(new.cancelled_by, '') <> 'customer' then
      perform public.notify(new.customer_id, 'order_' || new.status, format('Order %s is %s', new.order_no, st),
        case new.status
          when 'shipped' then format('%s has sent your order%s. Please keep %s ready in cash.', shop, coalesce(' (' || new.tracking_note || ')', ''), '৳' || to_char(new.total, 'FM99,99,99,990'))
          when 'cancelled' then format('%s cancelled your order%s.', shop, coalesce(': ' || new.cancel_reason, ''))
          when 'delivered' then format('Thank you for shopping with %s on RGBKart.', shop)
          else format('%s · %s', shop, coalesce(items, '')) end,
        'orders.html', 'order:' || new.id, new.email);
    end if;
    if new.status = 'cancelled' and new.cancelled_by = 'customer' and coalesce(new.cancel_request_status, '') <> 'accepted' then
      perform public.notify(new.seller_id, 'order_cancelled', format('Order %s was cancelled by the customer', new.order_no),
        format('%s · %s%s', new.customer_name, coalesce(items, ''), coalesce('. Reason: ' || new.cancel_reason, '')), 'seller.html#orders', 'order:' || new.id);
    end if;
  end if;
  return new;
end; $$;

select public.cancel_rules() as cancel_rules,
       to_regprocedure('public.request_cancel(bigint,text)') is not null as ask_shop_ready;
