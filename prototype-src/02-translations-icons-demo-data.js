<script>
"use strict";
/* ================= i18n ================= */
const DICT = {
 shop_nav:["Shop","শপ"], shop_by_cat:["Shop by Category","ক্যাটাগরি অনুযায়ী কেনাকাটা"], sec_cats:["Shop by Category","ক্যাটাগরি অনুযায়ী কেনাকাটা"], prev:["Previous","আগের"], next:["Next","পরের"], page_of:["Page {a} of {b}","পৃষ্ঠা {a} / {b}"], all_of:["All {c}","সব {c}"], shop_all_s:["Every live listing from every seller","সব বিক্রেতার সব চালু পণ্য"],
 pay_methods:["Payment methods","পেমেন্ট পদ্ধতি"], pay_methods_s:["Shown in the footer and at checkout. Mobile banking accounts also receive featured and ad fees. Upload each provider's official logo from their merchant kit.","ফুটার ও চেকআউটে দেখানো হয়। মোবাইল ব্যাংকিং অ্যাকাউন্টে ফিচার্ড ও বিজ্ঞাপন ফিও আসে। প্রতিটি প্রতিষ্ঠানের মার্চেন্ট কিট থেকে অফিসিয়াল লোগো আপলোড করুন।"],
 k_mfs:["Mobile banking","মোবাইল ব্যাংকিং"], k_card:["Card","কার্ড"], k_cod:["Cash on delivery","ক্যাশ অন ডেলিভারি"], account_no:["Account number","অ্যাকাউন্ট নম্বর"], add_method:["Add method","পদ্ধতি যোগ করুন"], card_pay:["Credit / debit card","ক্রেডিট / ডেবিট কার্ড"], card_pay_s:["On the live site you finish payment on the secure card page (SSLCommerz or similar).","লাইভ সাইটে নিরাপদ কার্ড পেজে (SSLCommerz বা অনুরূপ) পেমেন্ট সম্পন্ন হবে।"], method_name:["Name","নাম"], method_in_use:["Keep at least one way to pay switched on.","অন্তত একটি পেমেন্ট পদ্ধতি চালু রাখুন।"],
 wishlist:["Wishlist","উইশলিস্ট"], wish_empty:["Tap the heart on any product to save it here.","যেকোনো পণ্যের হার্টে চাপ দিয়ে এখানে রাখুন।"], wished:["Saved to wishlist","উইশলিস্টে রাখা হয়েছে"], unwished:["Removed from wishlist","উইশলিস্ট থেকে সরানো হয়েছে"],
 new_badge:["New","নতুন"], sale_badge:["Sale","সেল"], low_stock:["Low stock","স্টক কম"], items_n:["{n} items","{n}টি পণ্য"], cats_sub:["{n} categories · find everything you need","{n}টি ক্যাটাগরি · প্রয়োজনীয় সবকিছু"],
 availability:["Availability","প্রাপ্যতা"], av_stock:["In stock","স্টকে আছে"], av_sale:["On sale","অফারে আছে"], av_new:["New arrivals","নতুন পণ্য"], av_pickup:["Store pickup available","দোকান থেকে সংগ্রহ"], av_feat:["Featured","ফিচার্ড"],
 sort_by:["Sort by","সাজান"], sort_best:["Best selling","সর্বাধিক বিক্রিত"], clear_all:["Clear all filters","সব ফিল্টার মুছুন"],
 tagline:["Red & Green Basket","রেড অ্যান্ড গ্রিন বাস্কেট"],
 strip_msg:["Zero commission marketplace · Every seller ships their own orders","শূন্য কমিশনের মার্কেটপ্লেস · প্রতিটি বিক্রেতা নিজেই পণ্য পাঠান"],
 demo_role:["Demo view","ডেমো ভিউ"], guest:["Guest","অতিথি"], customer:["Customer","ক্রেতা"], seller:["Seller","বিক্রেতা"], admin:["Master admin","মাস্টার অ্যাডমিন"],
 sell_on:["Sell on RGBKart","RGBKart-এ বিক্রি করুন"],
 search_ph:["Search products, brands and shops…","পণ্য, ব্র্যান্ড ও দোকান খুঁজুন…"], all_cats:["All categories","সব ক্যাটাগরি"], search:["Search","খুঁজুন"],
 signin:["Sign in","সাইন ইন"], account:["Account","অ্যাকাউন্ট"], cart:["Cart","কার্ট"], dashboard:["Dashboard","ড্যাশবোর্ড"], signout:["Sign out","সাইন আউট"],
 categories:["Categories","ক্যাটাগরি"],
 usp1:["Verified sellers","যাচাইকৃত বিক্রেতা"], usp1s:["Every listing is approved by admin","প্রতিটি লিস্টিং অ্যাডমিন অনুমোদিত"],
 usp2:["Pay with bKash, Nagad, Rocket","বিকাশ, নগদ, রকেটে পেমেন্ট"], usp2s:["or cash on delivery","অথবা ক্যাশ অন ডেলিভারি"],
 usp3:["Inside & outside Dhaka","ঢাকার ভিতরে ও বাইরে"], usp3s:["Delivery, pickup or negotiated","ডেলিভারি, পিকআপ বা আলোচনা সাপেক্ষে"],
 usp4:["Talk to the seller","বিক্রেতার সাথে কথা বলুন"], usp4s:["Call, email or WhatsApp","কল, ইমেইল বা হোয়াটসঅ্যাপ"],
 featured:["Featured","ফিচার্ড"], top_rated:["Top rated","সেরা রেটিং"], featured_top:["Featured & Top Rated","ফিচার্ড ও সেরা রেটিং"],
 deals:["Deals of the Day","আজকের ডিল"], ends_in:["Ends in","শেষ হবে"], new_arrivals:["New Arrivals","নতুন পণ্য"], view_all:["View all","সব দেখুন"],
 shops:["Shops on RGBKart","RGBKart-এর দোকানসমূহ"], visit_shop:["Visit shop","দোকানে যান"],
 brand_new:["Brand New","একদম নতুন"], pre_owned:["Pre-Owned","ব্যবহৃত"], condition:["Condition","অবস্থা"],
 sponsored:["Sponsored","বিজ্ঞাপন"], ad:["Ad","বিজ্ঞাপন"],
 no_items:["Nothing here yet.","এখানে এখনো কিছু নেই।"],
 results:["{n} products","{n}টি পণ্য"], filters:["Filters","ফিল্টার"], price_range:["Price (৳)","দাম (৳)"], min:["Min","সর্বনিম্ন"], max:["Max","সর্বোচ্চ"], brand:["Brand","ব্র্যান্ড"], any:["Any","যেকোনো"],
 sort:["Sort","সাজান"], sort_new:["Newest","নতুন আগে"], sort_low:["Price: low to high","দাম: কম থেকে বেশি"], sort_high:["Price: high to low","দাম: বেশি থেকে কম"], sort_rating:["Rating","রেটিং"],
 clear:["Clear","মুছুন"], apply:["Apply","প্রয়োগ"], home:["Home","হোম"], subcats:["Subcategories","উপ-ক্যাটাগরি"],
 in_stock:["In stock ({n})","স্টকে আছে ({n})"], out_stock:["Out of stock","স্টকে নেই"], add_cart:["Add to cart","কার্টে যোগ করুন"], buy_now:["Buy now","এখনই কিনুন"], qty:["Quantity","পরিমাণ"],
 added:["Added to cart","কার্টে যোগ হয়েছে"], shipping:["Shipping","শিপিং"], ship_by_seller:["Shipped directly by the seller","বিক্রেতা নিজেই পাঠাবেন"],
 ship_dhaka:["Inside Dhaka","ঢাকার ভিতরে"], ship_outside:["Outside Dhaka","ঢাকার বাইরে"], ship_pickup:["Pickup from shop","দোকান থেকে সংগ্রহ"], ship_negotiated:["Negotiated with seller","বিক্রেতার সাথে আলোচনা সাপেক্ষে"],
 free:["Free","ফ্রি"], to_agree:["To be agreed","আলোচনা সাপেক্ষে"],
 sold_by:["Sold by","বিক্রেতা"], contact_seller:["Contact the seller","বিক্রেতার সাথে যোগাযোগ"], call:["Call","কল করুন"], email:["Email","ইমেইল"], whatsapp:["WhatsApp","হোয়াটসঅ্যাপ"], copy:["Copy","কপি"], copied:["Copied","কপি হয়েছে"],
 description:["Description","বিবরণ"], specs:["Specifications","বৈশিষ্ট্য"], sku:["SKU","এসকেইউ"], category:["Category","ক্যাটাগরি"], more_from:["More from this shop","এই দোকানের আরও পণ্য"],
 gift_offer:["Free gift: {g} on orders over {m} from this shop","উপহার: এই দোকান থেকে {m}-এর বেশি অর্ডারে {g} ফ্রি"],
 reviews:["{n} reviews","{n}টি রিভিউ"], sold:["{n} sold","{n}টি বিক্রি"],
 since:["Selling since {d}","{d} থেকে বিক্রি করছেন"], products:["Products","পণ্য"], about_shop:["About the shop","দোকান সম্পর্কে"], pickup_addr:["Pickup address","পিকআপের ঠিকানা"], hours:["Opening hours","খোলার সময়"], returns:["Return policy","রিটার্ন নীতি"],
 search_shop:["Search this shop","এই দোকানে খুঁজুন"],
 your_cart:["Your cart","আপনার কার্ট"], cart_empty:["Your cart is empty.","আপনার কার্ট খালি।"], continue_shop:["Continue shopping","কেনাকাটা চালিয়ে যান"], remove:["Remove","সরান"],
 order_summary:["Order summary","অর্ডার সারাংশ"], subtotal:["Subtotal","সাবটোটাল"], discount:["Discount","ছাড়"], total:["Total","মোট"], checkout:["Proceed to checkout","চেকআউট করুন"],
 cart_note:["Items from different shops are shipped separately by each seller.","ভিন্ন দোকানের পণ্য প্রতিটি বিক্রেতা আলাদাভাবে পাঠাবেন।"],
 from_shop:["From {s}","{s} থেকে"], coupon:["Coupon code","কুপন কোড"], coupon_ok:["Coupon applied","কুপন প্রয়োগ হয়েছে"], coupon_bad:["This coupon is not valid for this shop or order.","এই কুপনটি এই দোকান বা অর্ডারের জন্য প্রযোজ্য নয়।"],
 coupon_min:["Spend at least {m} to use this coupon.","এই কুপন ব্যবহার করতে কমপক্ষে {m} কিনুন।"],
 gift_inc:["Free gift included: {g}","উপহার অন্তর্ভুক্ত: {g}"],
 delivery_details:["Delivery details","ডেলিভারির তথ্য"], full_name:["Full name","পুরো নাম"], phone:["Mobile number","মোবাইল নম্বর"], address:["Address","ঠিকানা"], district:["District","জেলা"], notes:["Note for seller (optional)","বিক্রেতার জন্য নোট (ঐচ্ছিক)"],
 payment:["Payment","পেমেন্ট"], cod:["Cash on delivery","ক্যাশ অন ডেলিভারি"], mfs_pay:["Mobile banking (send money to seller)","মোবাইল ব্যাংকিং (বিক্রেতাকে সেন্ড মানি)"],
 trx:["Transaction ID (TrxID)","ট্রানজেকশন আইডি (TrxID)"], sender_no:["Sender mobile number","প্রেরকের মোবাইল নম্বর"], place_order:["Place order","অর্ডার করুন"],
 order_placed:["Order placed","অর্ডার সম্পন্ন হয়েছে"], order_placed_s:["Each seller has received their part of your order and will contact you to confirm delivery.","প্রতিটি বিক্রেতা আপনার অর্ডারের অংশ পেয়েছেন এবং ডেলিভারি নিশ্চিত করতে যোগাযোগ করবেন।"],
 my_orders:["My orders","আমার অর্ডার"], order_no:["Order","অর্ডার"], date:["Date","তারিখ"], status:["Status","স্ট্যাটাস"], items:["Items","পণ্য"], amount:["Amount","পরিমাণ"],
 st_pending:["Pending","অপেক্ষমাণ"], st_confirmed:["Confirmed","নিশ্চিত"], st_packed:["Packed","প্যাক করা"], st_shipped:["Shipped","পাঠানো হয়েছে"], st_delivered:["Delivered","ডেলিভারি সম্পন্ন"], st_cancelled:["Cancelled","বাতিল"],
 login_title:["Sign in to RGBKart","RGBKart-এ সাইন ইন করুন"], email_or_phone:["Email or mobile","ইমেইল বা মোবাইল"], password:["Password","পাসওয়ার্ড"], no_account:["New here?","নতুন?"], create_account:["Create an account","অ্যাকাউন্ট খুলুন"],
 demo_accounts:["Demo accounts (one click)","ডেমো অ্যাকাউন্ট (এক ক্লিকে)"], bad_login:["Email/mobile or password is incorrect. Try a demo account below.","ইমেইল/মোবাইল বা পাসওয়ার্ড ভুল। নিচের ডেমো অ্যাকাউন্ট ব্যবহার করুন।"],
 register_title:["Create your account","আপনার অ্যাকাউন্ট খুলুন"], reg_as:["Register as","নিবন্ধন করুন"], reg_cust_s:["Shop from every seller, track orders","সব বিক্রেতার কাছ থেকে কিনুন, অর্ডার ট্র্যাক করুন"], reg_sell_s:["Open your own shop with its own dashboard","নিজস্ব ড্যাশবোর্ডসহ নিজের দোকান খুলুন"],
 shop_name_en:["Shop name (English)","দোকানের নাম (ইংরেজি)"], shop_name_bn:["Shop name (Bangla)","দোকানের নাম (বাংলা)"], have_account:["Already registered?","আগেই নিবন্ধিত?"], register:["Register","নিবন্ধন করুন"],
 email_taken:["That email or mobile is already registered.","এই ইমেইল বা মোবাইল আগেই নিবন্ধিত।"], welcome_seller:["Your shop is ready. Add your logo and banner in Shop setup.","আপনার দোকান প্রস্তুত। দোকান সেটআপে লোগো ও ব্যানার যোগ করুন।"],
 /* seller */
 overview:["Overview","সারসংক্ষেপ"], add_product:["Add product","পণ্য যোগ করুন"], edit_product:["Edit product","পণ্য সম্পাদনা"], orders:["Orders","অর্ডার"], coupons:["Coupons","কুপন"], gifts:["Gift items","উপহার সামগ্রী"], reports:["Reports","রিপোর্ট"], advertising:["Advertising","বিজ্ঞাপন"], shop_setup:["Shop setup","দোকান সেটআপ"], payments:["Fee payments","ফি পেমেন্ট"],
 view_shop:["View my shop","আমার দোকান দেখুন"], today_sales:["Sales today","আজকের বিক্রি"], open_orders:["Orders to process","প্রক্রিয়াধীন অর্ডার"], live_products:["Live products","চালু পণ্য"], awaiting_approval:["Awaiting approval","অনুমোদনের অপেক্ষায়"],
 month_sales:["Sales this month","এই মাসের বিক্রি"], recent_orders:["Recent orders","সাম্প্রতিক অর্ডার"], needs_attention:["Needs your attention","আপনার মনোযোগ প্রয়োজন"],
 listing:["Listing","লিস্টিং"], free_listing:["Free listing","ফ্রি লিস্টিং"], featured_listing:["Featured listing","ফিচার্ড লিস্টিং"], price:["Price","দাম"], stock:["Stock","স্টক"], actions:["Actions","অ্যাকশন"], edit:["Edit","সম্পাদনা"], delete:["Delete","মুছুন"],
 ls_pending:["Pending approval","অনুমোদনের অপেক্ষায়"], ls_approved:["Live","চালু"], ls_rejected:["Rejected","প্রত্যাখ্যাত"],
 fs_awaiting_payment:["Fee unpaid","ফি বাকি"], fs_payment_review:["Payment under review","পেমেন্ট যাচাই চলছে"], fs_active:["Featured until {d}","{d} পর্যন্ত ফিচার্ড"], fs_expired:["Featured expired","ফিচার্ড মেয়াদ শেষ"],
 make_featured:["Make featured","ফিচার্ড করুন"], pay_fee:["Pay fee","ফি দিন"], renew:["Renew","নবায়ন"],
 title_en:["Product title (English)","পণ্যের নাম (ইংরেজি)"], title_bn:["Product title (Bangla)","পণ্যের নাম (বাংলা)"], desc_en:["Description (English)","বিবরণ (ইংরেজি)"], desc_bn:["Description (Bangla)","বিবরণ (বাংলা)"],
 subcategory:["Subcategory","উপ-ক্যাটাগরি"], none:["None","নেই"], product_type:["Product type","পণ্যের ধরন"], simple:["Simple product","সাধারণ পণ্য"], simple_s:["One price, one stock count","একটি দাম, একটি স্টক"], variable:["Variable product","ভেরিয়েবল পণ্য"], variable_s:["Sizes, colours or storage options","সাইজ, রং বা স্টোরেজ অপশন"],
 variable_locked:["Not yet enabled by admin","অ্যাডমিন এখনো চালু করেননি"], variations:["Variations","ভেরিয়েশন"], var_label:["Option (e.g. XL / Red)","অপশন (যেমন XL / লাল)"], add_variation:["Add option","অপশন যোগ করুন"], choose_option:["Choose an option","একটি অপশন বাছুন"],
 regular_price:["Regular price (৳)","নিয়মিত দাম (৳)"], sale_price:["Sale price (৳, optional)","অফার দাম (৳, ঐচ্ছিক)"], deal_day:["Offer as a Deal of the Day","আজকের ডিল হিসেবে দিন"], deal_price:["Deal price (৳)","ডিল দাম (৳)"], deal_date:["Deal date","ডিলের তারিখ"],
 images:["Photos (up to 4)","ছবি (সর্বোচ্চ ৪টি)"], add_photo:["Add photo","ছবি যোগ করুন"], attributes:["Attributes","অ্যাট্রিবিউট"], ship_opts:["Shipping options for this product","এই পণ্যের শিপিং অপশন"],
 listing_type:["Listing type","লিস্টিং ধরন"], free_s:["Published after admin approval","অ্যাডমিন অনুমোদনের পর প্রকাশ"], featured_s:["{f} for {d} days · top of homepage and search","{d} দিনের জন্য {f} · হোমপেজ ও সার্চের শীর্ষে"],
 attach_gift:["Attach a gift item","উপহার সংযুক্ত করুন"], submit_review:["Submit for approval","অনুমোদনের জন্য জমা দিন"], save:["Save","সংরক্ষণ"], cancel:["Cancel","বাতিল"],
 prod_saved:["Product submitted. It goes live once admin approves it.","পণ্য জমা হয়েছে। অ্যাডমিন অনুমোদন করলে চালু হবে।"], prod_updated:["Changes saved and sent for re-approval.","পরিবর্তন সংরক্ষিত এবং পুনরায় অনুমোদনের জন্য পাঠানো হয়েছে।"],
 pay_title:["Pay the featured fee","ফিচার্ড ফি পরিশোধ করুন"], pay_steps:["Send {a} to the RGBKart {m} merchant number below, then enter the transaction ID. Admin checks the payment and publishes your featured listing.","নিচের RGBKart {m} মার্চেন্ট নম্বরে {a} পাঠান, তারপর ট্রানজেকশন আইডি দিন। অ্যাডমিন পেমেন্ট যাচাই করে আপনার ফিচার্ড লিস্টিং প্রকাশ করবেন।"],
 merchant_no:["Merchant number","মার্চেন্ট নম্বর"], method:["Method","মাধ্যম"], submit_payment:["Submit payment","পেমেন্ট জমা দিন"], pay_sent:["Payment submitted for verification","পেমেন্ট যাচাইয়ের জন্য জমা হয়েছে"],
 trx_need:["Enter the transaction ID from your payment SMS.","পেমেন্ট এসএমএস থেকে ট্রানজেকশন আইডি লিখুন।"],
 customer_col:["Customer","ক্রেতা"], update_status:["Update status","স্ট্যাটাস হালনাগাদ"], invoice:["Invoice","ইনভয়েস"], packing:["Packing list","প্যাকিং লিস্ট"], label:["Shipping label","শিপিং লেবেল"],
 doc_note:["Document preview. On the live site this button opens the print dialog.","ডকুমেন্ট প্রিভিউ। লাইভ সাইটে এই বোতাম প্রিন্ট ডায়ালগ খুলবে।"],
 all:["All","সব"], bill_to:["Bill to","বিল প্রাপক"], ship_to:["Ship to","প্রাপক"], from:["From","প্রেরক"], cod_amount:["Collect (COD)","সংগ্রহ (COD)"], paid:["Paid","পরিশোধিত"], packed_by:["Packed by","প্যাক করেছেন"], checked:["Checked","যাচাই"],
 new_coupon:["Create coupon","কুপন তৈরি করুন"], code:["Code","কোড"], type:["Type","ধরন"], pct:["Percent off","শতাংশ ছাড়"], flat:["Flat ৳ off","নির্দিষ্ট ৳ ছাড়"], value:["Value","মান"], min_spend:["Minimum spend (৳)","সর্বনিম্ন কেনাকাটা (৳)"], expires:["Expires","মেয়াদ"], usage_limit:["Usage limit","ব্যবহারের সীমা"], used:["Used","ব্যবহৃত"], active:["Active","সক্রিয়"], inactive:["Off","বন্ধ"],
 coupon_made:["Coupon created","কুপন তৈরি হয়েছে"], new_gift:["Add gift item","উপহার যোগ করুন"], gift_name_en:["Gift name (English)","উপহারের নাম (ইংরেজি)"], gift_name_bn:["Gift name (Bangla)","উপহারের নাম (বাংলা)"], applies_to:["Applies to","প্রযোজ্য"], all_products:["All my products","আমার সব পণ্য"], gift_made:["Gift item added","উপহার যোগ হয়েছে"],
 daily:["Daily","দৈনিক"], weekly:["Weekly","সাপ্তাহিক"], yearly:["Yearly","বার্ষিক"], revenue:["Revenue","আয়"], orders_n:["Orders","অর্ডার"], units:["Units","ইউনিট"], avg_order:["Average order","গড় অর্ডার"], period:["Period","সময়কাল"], best_sellers:["Best sellers","সর্বাধিক বিক্রিত"],
 rep_daily_s:["Last 14 days","শেষ ১৪ দিন"], rep_weekly_s:["Last 12 weeks","শেষ ১২ সপ্তাহ"], rep_yearly_s:["Month by month, last 12 months","মাস অনুযায়ী, শেষ ১২ মাস"],
 ads_intro:["Seller advertising is a separate paid service. It is not the same as a Featured listing: an ad promotes your shop or a product in a banner slot for the days you book.","বিক্রেতার বিজ্ঞাপন একটি আলাদা পেইড সেবা। এটি ফিচার্ড লিস্টিং নয়: বুক করা দিনগুলোতে ব্যানার স্লটে আপনার দোকান বা পণ্যের প্রচার হয়।"],
 book_ad:["Book an ad","বিজ্ঞাপন বুক করুন"], placement:["Placement","স্থান"], pl_home_top:["Homepage banner strip","হোমপেজ ব্যানার স্ট্রিপ"], pl_home_mid:["Homepage mid-page banner","হোমপেজ মাঝের ব্যানার"], pl_cat_side:["Category page sidebar","ক্যাটাগরি পেজ সাইডবার"],
 days:["Days","দিন"], per_day:["{a} per day","প্রতিদিন {a}"], headline_en:["Headline (English)","শিরোনাম (ইংরেজি)"], headline_bn:["Headline (Bangla)","শিরোনাম (বাংলা)"], sub_en:["Sub-line (English)","উপশিরোনাম (ইংরেজি)"], sub_bn:["Sub-line (Bangla)","উপশিরোনাম (বাংলা)"],
 link_to:["Links to","লিংক"], my_shop:["My shop page","আমার দোকান পেজ"], colour:["Colour","রং"], ad_requests:["My ad bookings","আমার বিজ্ঞাপন বুকিং"], ad_sent:["Ad booking sent. It goes live once admin verifies the payment.","বিজ্ঞাপন বুকিং পাঠানো হয়েছে। পেমেন্ট যাচাই হলে চালু হবে।"],
 rq_review:["Payment under review","পেমেন্ট যাচাই চলছে"], rq_live:["Live","চালু"], rq_rejected:["Rejected","প্রত্যাখ্যাত"], rq_ended:["Ended","শেষ"],
 logo:["Logo","লোগো"], banner:["Banner","ব্যানার"], upload:["Upload","আপলোড"], about_en:["About (English)","পরিচিতি (ইংরেজি)"], about_bn:["About (Bangla)","পরিচিতি (বাংলা)"], wa_no:["WhatsApp number","হোয়াটসঅ্যাপ নম্বর"], shop_email:["Shop email","দোকানের ইমেইল"],
 allow_pickup:["Customers can pick up from my shop","ক্রেতারা আমার দোকান থেকে সংগ্রহ করতে পারবেন"], brand_colour:["Shop colour","দোকানের রং"], saved:["Saved","সংরক্ষিত"], seller_payout:["Mobile banking number for customer payments","ক্রেতার পেমেন্টের জন্য মোবাইল ব্যাংকিং নম্বর"],
 kind:["For","বিষয়"], k_featured:["Featured fee","ফিচার্ড ফি"], k_ad:["Advertising","বিজ্ঞাপন"], p_review:["Under review","যাচাই চলছে"], p_verified:["Verified","যাচাইকৃত"], p_rejected:["Not received","পাওয়া যায়নি"],
 /* admin */
 approvals:["Listing approvals","লিস্টিং অনুমোদন"], verify_payments:["Payment verification","পেমেন্ট যাচাই"], all_products_a:["All products","সব পণ্য"], sellers:["Sellers","বিক্রেতা"], homepage:["Homepage","হোমপেজ"], menu:["Menu","মেনু"], brands:["Brands","ব্র্যান্ড"], ads:["Ads","বিজ্ঞাপন"], settings:["Settings","সেটিংস"],
 approve:["Approve & publish","অনুমোদন ও প্রকাশ"], reject:["Reject","প্রত্যাখ্যান"], reason:["Reason (sent to seller)","কারণ (বিক্রেতাকে পাঠানো হবে)"], publish_free:["Publish as free","ফ্রি হিসেবে প্রকাশ"], verify_publish:["Payment received · publish","পেমেন্ট পেয়েছি · প্রকাশ"], not_received:["Not received","পাওয়া যায়নি"],
 waiting_pay:["Waiting for the seller to pay","বিক্রেতার পেমেন্টের অপেক্ষায়"], queue_empty:["Nothing waiting. New listings appear here.","কিছু অপেক্ষমাণ নেই। নতুন লিস্টিং এখানে দেখাবে।"],
 pending_listings:["Listings to approve","অনুমোদনের অপেক্ষায় লিস্টিং"], payments_to_verify:["Payments to verify","যাচাইয়ের অপেক্ষায় পেমেন্ট"], featured_income:["Featured & ad fees (30 days)","ফিচার্ড ও বিজ্ঞাপন ফি (৩০ দিন)"], marketplace_orders:["Marketplace orders (30 days)","মার্কেটপ্লেস অর্ডার (৩০ দিন)"],
 suspend:["Suspend","স্থগিত"], reinstate:["Reinstate","পুনরায় চালু"], suspended:["Suspended","স্থগিত"], owner:["Owner","মালিক"],
 slides:["Hero slides","হিরো স্লাইড"], add_slide:["Add slide","স্লাইড যোগ করুন"], eyebrow_en:["Eyebrow (English)","ছোট শিরোনাম (ইংরেজি)"], eyebrow_bn:["Eyebrow (Bangla)","ছোট শিরোনাম (বাংলা)"], button_en:["Button (English)","বোতাম (ইংরেজি)"], button_bn:["Button (Bangla)","বোতাম (বাংলা)"],
 sections:["Homepage sections","হোমপেজ সেকশন"], sections_s:["Turn sections on or off and set their order. Each section fills itself from live listings.","সেকশন চালু/বন্ধ করুন ও ক্রম ঠিক করুন। প্রতিটি সেকশন চালু লিস্টিং থেকে নিজে পূর্ণ হয়।"], max_items:["Items shown","দেখানো পণ্য"], up:["Move up","উপরে"], down:["Move down","নিচে"],
 sec_featured:["Featured & Top Rated","ফিচার্ড ও সেরা রেটিং"], sec_deals:["Deals of the Day","আজকের ডিল"], sec_new:["New Arrivals","নতুন পণ্য"], sec_ads:["Mid-page ads","মাঝের বিজ্ঞাপন"], sec_shops:["Shops","দোকান"], sec_usps:["Trust badges","আস্থার ব্যাজ"],
 menu_s:["The bar under the header. Each item opens a category or a homepage collection.","হেডারের নিচের বার। প্রতিটি আইটেম একটি ক্যাটাগরি বা সংগ্রহ খোলে।"], label_en:["Label (English)","লেবেল (ইংরেজি)"], label_bn:["Label (Bangla)","লেবেল (বাংলা)"], add_item:["Add item","আইটেম যোগ করুন"], highlight:["Highlight in red","লাল রঙে হাইলাইট"],
 name_en:["Name (English)","নাম (ইংরেজি)"], name_bn:["Name (Bangla)","নাম (বাংলা)"], parent:["Parent","মূল ক্যাটাগরি"], top_level:["Top level","মূল স্তর"], icon:["Icon","আইকন"], add:["Add","যোগ করুন"], values:["Values (comma separated)","মানসমূহ (কমা দিয়ে)"],
 new_ad:["Create ad","বিজ্ঞাপন তৈরি করুন"], start:["Start","শুরু"], end:["End","শেষ"], seller_bookings:["Seller ad bookings","বিক্রেতার বিজ্ঞাপন বুকিং"], house_ad:["RGBKart","RGBKart"], ad_made:["Ad created","বিজ্ঞাপন তৈরি হয়েছে"],
 fee_settings:["Featured listing fee","ফিচার্ড লিস্টিং ফি"], fee_amt:["Fee (৳)","ফি (৳)"], fee_days:["Duration (days)","মেয়াদ (দিন)"], product_rules:["Product rules","পণ্যের নিয়ম"], allow_variable:["Allow sellers to list variable products","বিক্রেতাদের ভেরিয়েবল পণ্য দিতে দিন"],
 allow_variable_s:["Off by default until you approve variable products for launch.","লঞ্চের জন্য অনুমোদন না দেওয়া পর্যন্ত বন্ধ থাকবে।"], ship_settings:["Shipping charges","শিপিং চার্জ"], ship_settings_s:["Default charges shown to customers. Each seller still ships their own orders.","ক্রেতাদের দেখানো ডিফল্ট চার্জ। প্রতিটি বিক্রেতা নিজের অর্ডার নিজে পাঠান।"],
 fee:["Charge (৳)","চার্জ (৳)"], eta_en:["Delivery time (English)","ডেলিভারি সময় (ইংরেজি)"], eta_bn:["Delivery time (Bangla)","ডেলিভারি সময় (বাংলা)"], enabled:["Enabled","চালু"],
 mfs_accounts:["Mobile banking accounts for fees","ফির জন্য মোবাইল ব্যাংকিং অ্যাকাউন্ট"], ad_pricing:["Ad prices per day (৳)","প্রতিদিনের বিজ্ঞাপন মূল্য (৳)"], site:["Site","সাইট"], site_logo:["Site logo","সাইট লোগো"], logo_s:["Upload your RGBKart logo to replace the placeholder in the header.","হেডারের প্লেসহোল্ডার বদলাতে আপনার RGBKart লোগো আপলোড করুন।"],
 reset_demo:["Reset demo data","ডেমো ডেটা রিসেট"], reset_done:["Demo data reset","ডেমো ডেটা রিসেট হয়েছে"], support_phone:["Support phone","সাপোর্ট ফোন"], support_email:["Support email","সাপোর্ট ইমেইল"],
 need_login:["Sign in to continue","চালিয়ে যেতে সাইন ইন করুন"], need_seller:["This area is for sellers. Use the demo view switch in the top bar.","এই অংশ বিক্রেতাদের জন্য। উপরের ডেমো ভিউ পরিবর্তন করুন।"], need_admin:["This area is for the master admin.","এই অংশ মাস্টার অ্যাডমিনের জন্য।"],
 about_rgb:["RGBKart is a Bangladesh marketplace where independent shops sell brand-new and pre-owned goods. No sales commission: sellers keep what they earn.","RGBKart বাংলাদেশের একটি মার্কেটপ্লেস যেখানে স্বতন্ত্র দোকান নতুন ও ব্যবহৃত পণ্য বিক্রি করে। কোনো বিক্রয় কমিশন নেই: বিক্রেতা পুরো আয় রাখেন।"],
 help:["Help","সহায়তা"], for_sellers:["For sellers","বিক্রেতাদের জন্য"], we_accept:["We accept","আমরা গ্রহণ করি"], how_featured:["How featured listing works","ফিচার্ড লিস্টিং কীভাবে কাজ করে"],
 how_featured_s:["List free, or pay {f} for {d} days of featured placement through bKash, Nagad or Rocket. Admin verifies the payment and publishes.","ফ্রি লিস্ট করুন, অথবা বিকাশ, নগদ বা রকেটে {f} দিয়ে {d} দিনের ফিচার্ড স্থান নিন। অ্যাডমিন পেমেন্ট যাচাই করে প্রকাশ করবেন।"],
 rejected_note:["Rejected: {r}","প্রত্যাখ্যাত: {r}"], pay_rejected:["Admin could not find your payment ({t}). Check the TrxID and submit again.","অ্যাডমিন আপনার পেমেন্ট ({t}) খুঁজে পাননি। TrxID দেখে আবার জমা দিন।"],
 convert_s:["Your free listing stays live while the featured upgrade is reviewed.","ফিচার্ড আপগ্রেড যাচাইয়ের সময় আপনার ফ্রি লিস্টিং চালু থাকবে।"], confirm_delete:["Delete this product? Tap Delete again to confirm.","এই পণ্য মুছবেন? নিশ্চিত করতে আবার মুছুন চাপুন।"],
 deleted:["Deleted","মুছে ফেলা হয়েছে"], status_updated:["Status updated","স্ট্যাটাস হালনাগাদ হয়েছে"], published:["Published","প্রকাশিত"], rejected:["Rejected","প্রত্যাখ্যাত"],
 required:["Please fill in: {f}","অনুগ্রহ করে পূরণ করুন: {f}"], img_big:["That image could not be read. Try a JPG or PNG.","ছবিটি পড়া যায়নি। JPG বা PNG চেষ্টা করুন।"], storage_full:["Browser storage is full; recent photos may not be kept after reload.","ব্রাউজার স্টোরেজ পূর্ণ; রিলোডের পর সাম্প্রতিক ছবি নাও থাকতে পারে।"],
 ship_method:["Shipping method","শিপিং পদ্ধতি"], gift:["Gift","উপহার"], view:["View","দেখুন"], today:["Today","আজ"], week_of:["Week of {d}","{d}-এর সপ্তাহ"], prototype:["Prototype · demo data","প্রোটোটাইপ · ডেমো ডেটা"],
 no_rating:["New","নতুন"], qty_short:["Qty","পরিমাণ"], unit_price:["Unit price","একক দাম"], line_total:["Line total","মোট"], weight:["Weight (kg)","ওজন (কেজি)"], thank_you:["Thank you for shopping with us.","আমাদের সাথে কেনাকাটার জন্য ধন্যবাদ।"],
 trx_short:["TrxID","TrxID"], sender:["Sender","প্রেরক"], submitted:["Submitted","জমা"], shop:["Shop","দোকান"], for_product:["Item","বিষয়"],
};
const t=(k,v)=>{let s=(DICT[k]||[k,k])[S.lang==="bn"?1:0]||DICT[k]?.[0]||k; if(v) for(const x in v) s=s.split("{"+x+"}").join(v[x]); return s;};
const L=(o,f)=>!o?"":(S.lang==="bn"&&o[f+"_bn"])?o[f+"_bn"]:(o[f+"_en"]||o[f+"_bn"]||"");

/* ================= utils ================= */
const $=s=>document.querySelector(s);
const esc=s=>String(s??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
const uid=p=>p+Math.random().toString(36).slice(2,8);
const DAY=864e5;
const BN="০১২৩৪৫৬৭৮৯";
const N=v=>S.lang==="bn"?String(v).replace(/\d/g,d=>BN[d]):String(v);
const money=v=>"৳"+N(Math.round(v).toLocaleString("en-IN"));
const fmtDate=ts=>new Date(ts).toLocaleDateString(S.lang==="bn"?"bn-BD":"en-GB",{day:"numeric",month:"short",year:"numeric"});
const fmtShort=ts=>new Date(ts).toLocaleDateString(S.lang==="bn"?"bn-BD":"en-GB",{day:"numeric",month:"short"});
const ymd=ts=>{const d=new Date(ts);return d.getFullYear()+"-"+String(d.getMonth()+1).padStart(2,"0")+"-"+String(d.getDate()).padStart(2,"0")};
const startOfDay=ts=>{const d=new Date(ts);d.setHours(0,0,0,0);return d.getTime()};
const today=()=>ymd(Date.now());
function rng(seed){let s=seed>>>0;return()=>{s=(s*1664525+1013904223)>>>0;return s/4294967296}}

/* ================= icons ================= */
const IC={
 phone:'<rect x="7" y="2.5" width="10" height="19" rx="2.2"/><path d="M11 18.5h2"/>',
 tv:'<rect x="2.5" y="4.5" width="19" height="12.5" rx="1.8"/><path d="M8 21h8M12 17v4"/>',
 shirt:'<path d="M8 3 3.5 6l2 4 2-1V21h9V9l2 1 2-4L16 3c-.6 1.6-2.1 2.6-4 2.6S8.6 4.6 8 3z"/>',
 pot:'<path d="M4 10h16v6a4 4 0 0 1-4 4H8a4 4 0 0 1-4-4z"/><path d="M2 10h20M9 6.5c0-1 .7-1.5 1.5-2M13 6.5c0-1 .7-1.5 1.5-2"/>',
 book:'<path d="M4 4.5A1.5 1.5 0 0 1 5.5 3H20v15H5.5A1.5 1.5 0 0 0 4 19.5z"/><path d="M4 19.5A1.5 1.5 0 0 0 5.5 21H20M8 7h8"/>',
 basket:'<path d="M3 9h18l-2 11H5z"/><path d="M8 9l4-6 4 6M9 13v4M12 13v4M15 13v4"/>',
 bottle:'<path d="M10 2h4v3l1.5 2.5V20a2 2 0 0 1-2 2h-3a2 2 0 0 1-2-2V7.5L10 5z"/><path d="M8.5 12h7"/>',
 ball:'<circle cx="12" cy="12" r="9"/><path d="m12 7 4 3-1.5 4.5h-5L8 10z"/><path d="M12 3v4M21 10l-5 0M3 10h5M7 20l2.5-5.5M17 20l-2.5-5.5"/>',
 laptop:'<rect x="4" y="5" width="16" height="11" rx="1.5"/><path d="M2 19h20"/>',
 fan:'<circle cx="12" cy="12" r="2"/><path d="M12 10c0-4 1-7 4-7 2 0 2 3 0 5M14 12c4 0 7 1 7 4 0 2-3 2-5 0M12 14c0 4-1 7-4 7-2 0-2-3 0-5M10 12c-4 0-7-1-7-4 0-2 3-2 5 0"/>',
 search:'<circle cx="11" cy="11" r="7"/><path d="m20 20-4-4"/>',
 cart:'<path d="M3 4h2l2.4 11.2a1.5 1.5 0 0 0 1.5 1.2h8.6a1.5 1.5 0 0 0 1.5-1.1L21 8H6"/><circle cx="9.5" cy="20" r="1.3"/><circle cx="17" cy="20" r="1.3"/>',
 user:'<circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/>',
 shield:'<path d="M12 3 4 6v6c0 4.5 3.4 8.3 8 9 4.6-.7 8-4.5 8-9V6z"/><path d="m8.5 12 2.5 2.5 4.5-5"/>',
 wallet:'<rect x="3" y="6" width="18" height="14" rx="2"/><path d="M3 10h18M16 15h2M7 6l9-3 1 3"/>',
 truck:'<path d="M2 6h11v10H2zM13 9h4l4 4v3h-8"/><circle cx="6" cy="18" r="2"/><circle cx="17" cy="18" r="2"/>',
 chat:'<path d="M4 5h16v11H9l-5 4z"/>',
 call:'<path d="M5 3h4l2 5-2.5 1.5a11 11 0 0 0 6 6L16 13l5 2v4a2 2 0 0 1-2 2A17 17 0 0 1 3 5a2 2 0 0 1 2-2z"/>',
 mail:'<rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3 7 9 6 9-6"/>',
 wa:'<path d="M4 20l1.3-4A8 8 0 1 1 8 18.8z"/><path d="M9 9c0 3 3 6 6 6l1-1.5-2-1-1 1c-1-.5-2-1.5-2.5-2.5l1-1-1-2z"/>',
 grid:'<rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/>',
 box:'<path d="M3 7.5 12 3l9 4.5v9L12 21l-9-4.5z"/><path d="m3 7.5 9 4.5 9-4.5M12 12v9"/>',
 plus:'<path d="M12 5v14M5 12h14"/>',
 receipt:'<path d="M6 3h12v18l-3-2-3 2-3-2-3 2z"/><path d="M9 8h6M9 12h6"/>',
 tag:'<path d="M3 12V4h8l10 10-8 8z"/><circle cx="7.5" cy="8.5" r="1.5"/>',
 gift:'<rect x="3" y="8" width="18" height="5" rx="1"/><path d="M5 13v8h14v-8M12 8v13M12 8c-2-4-6-4-6-1.5S10 8 12 8zm0 0c2-4 6-4 6-1.5S14 8 12 8z"/>',
 chart:'<path d="M4 20V4M4 20h16"/><rect x="7" y="11" width="3" height="6"/><rect x="12" y="7" width="3" height="10"/><rect x="17" y="13" width="3" height="4"/>',
 megaphone:'<path d="M3 10v4h4l8 5V5L7 10z"/><path d="M18 9a4 4 0 0 1 0 6"/>',
 store:'<path d="M3 9 5 4h14l2 5"/><path d="M3 9a3 3 0 0 0 6 0 3 3 0 0 0 6 0 3 3 0 0 0 6 0M5 12v9h14v-9M10 21v-5h4v5"/>',
 check:'<path d="m5 12 5 5 9-10"/>',
 cash:'<rect x="2.5" y="6" width="19" height="12" rx="2"/><circle cx="12" cy="12" r="3"/>',
 home:'<path d="M3 11 12 4l9 7"/><path d="M5 10v10h14V10"/>',
 menu:'<path d="M4 6h16M4 12h16M4 18h16"/>',
 layers:'<path d="m12 3 9 5-9 5-9-5z"/><path d="m3 13 9 5 9-5"/>',
 star:'<path d="m12 3 2.8 5.8 6.2.9-4.5 4.4 1 6.3L12 17.5 6.5 20.4l1-6.3L3 9.7l6.2-.9z"/>',
 sliders:'<path d="M4 6h10M18 6h2M4 12h4M12 12h8M4 18h12M20 18h0"/><circle cx="16" cy="6" r="2"/><circle cx="10" cy="12" r="2"/><circle cx="18" cy="18" r="2"/>',
 users:'<circle cx="9" cy="8" r="3.5"/><path d="M2.5 20a6.5 6.5 0 0 1 13 0M16 4.5a3.5 3.5 0 0 1 0 7M18 14a6 6 0 0 1 3.5 6"/>',
 cog:'<circle cx="12" cy="12" r="3"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3M4.9 4.9 7 7M17 17l2.1 2.1M4.9 19.1 7 17M17 7l2.1-2.1"/>',
 award:'<circle cx="12" cy="9" r="6"/><path d="m8.5 14-1.5 7 5-3 5 3-1.5-7"/>',
};
const icon=(n,cls="")=>`<svg class="${cls}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${IC[n]||IC.box}</svg>`;
const CAT_ICONS=["phone","tv","laptop","fan","shirt","pot","book","basket","bottle","ball","gift","store","box"];

/* ================= seed ================= */
function seed(){
 const now=Date.now();
 const cats=[
  ["mob","Mobiles & Gadgets","মোবাইল ও গ্যাজেট","phone",[["smart","Smartphones","স্মার্টফোন"],["audio","Audio","অডিও"],["acc","Accessories","এক্সেসরিজ"]]],
  ["ele","Electronics","ইলেকট্রনিক্স","tv",[["tv","TV","টিভি"],["lap","Laptops","ল্যাপটপ"],["fan","Fans","ফ্যান"]]],
  ["fas","Fashion","ফ্যাশন","shirt",[["women","Women","নারী"],["men","Men","পুরুষ"],["craft","Handicrafts","হস্তশিল্প"]]],
  ["hom","Home & Kitchen","ঘর ও রান্নাঘর","pot",[["cook","Cookware","রান্নার সরঞ্জাম"],["appl","Appliances","অ্যাপ্লায়েন্স"],["stor","Storage","স্টোরেজ"]]],
  ["boo","Books","বই","book",[["lit","Literature","সাহিত্য"],["acad","Academic","একাডেমিক"],["kids","Kids","শিশুতোষ"]]],
  ["gro","Groceries","মুদি","basket",[["rice","Rice & Oil","চাল ও তেল"],["fruit","Fruits","ফল"],["honey","Honey","মধু"]]],
  ["bea","Beauty & Health","সৌন্দর্য ও স্বাস্থ্য","bottle",[["skin","Skin Care","ত্বকের যত্ন"]]],
  ["spo","Sports","খেলাধুলা","ball",[["cric","Cricket","ক্রিকেট"],["foot","Football","ফুটবল"]]],
 ];
 const categories=[];
 cats.forEach(([id,en,bn,ic,subs])=>{categories.push({id,name_en:en,name_bn:bn,parent:null,icon:ic});subs.forEach(([sid,sen,sbn])=>categories.push({id:id+"-"+sid,name_en:sen,name_bn:sbn,parent:id,icon:ic}))});
 const brands=["Samsung","Xiaomi","Apple","Realme","Walton","Vision","Miyako","RFL","Dell","Local / Handmade","Generic"].map((n,i)=>({id:"b"+i,name:n}));
 const B=n=>brands.find(b=>b.name===n).id;
 const attributes=[
  {id:"a1",name_en:"Colour",name_bn:"রং",values:"Black, White, Blue, Red, Green, Maroon"},
  {id:"a2",name_en:"Size",name_bn:"সাইজ",values:"S, M, L, XL, XXL"},
  {id:"a3",name_en:"Storage",name_bn:"স্টোরেজ",values:"64GB, 128GB, 256GB, 512GB"},
  {id:"a4",name_en:"Material",name_bn:"উপাদান",values:"Cotton, Silk, Leather, Steel, Clay"},
 ];
 const users=[
  {id:"u_admin",name:"Master Admin",email:"hkmanik@gmail.com",phone:"01919244000",pass:"admin123",role:"admin"},
  {id:"u_c1",name:"Nusrat Jahan",email:"nusrat@example.com",phone:"01711223344",pass:"demo123",role:"customer",address:"House 12, Road 5, Dhanmondi",district:"Dhaka"},
 ];
 const stores=[
  ["s1","Dhaka Gadget House","ঢাকা গ্যাজেট হাউস","#006A4E","Level 4, Multiplan Center, Elephant Road","Dhaka","01811000111","Phones, power banks, earbuds and smart TVs with official and brand warranty. Same-day delivery inside Dhaka.","অফিসিয়াল ও ব্র্যান্ড ওয়ারেন্টিসহ ফোন, পাওয়ার ব্যাংক, ইয়ারবাড ও স্মার্ট টিভি। ঢাকার ভিতরে একই দিনে ডেলিভারি।","Tanvir Hasan",410],
  ["s2","Nakshi Ghor","নকশি ঘর","#B5132A","Shop 22, Mirpur-10 Shopping Complex","Dhaka","01911000222","Handloom sarees, panjabis and nakshi kantha made by artisans from Tangail and Jamalpur.","টাঙ্গাইল ও জামালপুরের কারিগরদের তৈরি তাঁতের শাড়ি, পাঞ্জাবি ও নকশি কাঁথা।","Sharmin Sultana",620],
  ["s3","Chattogram Kitchen Mart","চট্টগ্রাম কিচেন মার্ট","#8A5A00","Reazuddin Bazar, Chattogram","Chattogram","01611000333","Cookware, rice cookers and home storage at wholesale-friendly prices. We ship across Bangladesh.","পাইকারি দামে রান্নার সরঞ্জাম, রাইস কুকার ও স্টোরেজ। সারা বাংলাদেশে পাঠাই।","Kamrul Islam",300],
  ["s4","Boi Bazar","বই বাজার","#1F4E8C","Nilkhet Book Market, Dhaka","Dhaka","01511000444","New and used books: literature, admission guides and children's books.","নতুন ও পুরনো বই: সাহিত্য, ভর্তি গাইড ও শিশুদের বই।","Arif Hossain",520],
  ["s5","Second Chance Mobiles","সেকেন্ড চান্স মোবাইলস","#5B3A8C","Jamuna Future Park, Level 3","Dhaka","01311000555","Checked pre-owned phones and laptops with battery health shown on every listing and a 7-day check warranty.","প্রতিটি লিস্টিংয়ে ব্যাটারি হেলথসহ যাচাইকৃত ব্যবহৃত ফোন ও ল্যাপটপ, ৭ দিনের চেক ওয়ারেন্টি।","Sabbir Ahmed",190],
  ["s6","Krishi Fresh","কৃষি ফ্রেশ","#3D7A2A","Shaheb Bazar, Rajshahi","Rajshahi","01411000666","Direct from farmers: Rajshahi mangoes, Sundarbans honey, ghani-pressed mustard oil and rice.","সরাসরি কৃষকের কাছ থেকে: রাজশাহীর আম, সুন্দরবনের মধু, ঘানি ভাঙা সরিষার তেল ও চাল।","Mithila Rahman",240],
 ].map(([id,en,bn,color,addr,dist,ph,aen,abn,owner,age])=>{
  const uidd="u_"+id; users.push({id:uidd,name:owner,email:id+"@rgbkart.com",phone:ph,pass:"demo123",role:"seller",storeId:id});
  return {id,ownerId:uidd,name_en:en,name_bn:bn,color,address:addr,district:dist,phone:ph,email:en.toLowerCase().replace(/[^a-z]+/g,"")+"@gmail.com",whatsapp:ph,about_en:aen,about_bn:abn,logo:null,banner:null,pickup:true,hours_en:"Sat–Thu, 10am–8pm",hours_bn:"শনি–বৃহস্পতি, সকাল ১০টা–রাত ৮টা",returns_en:"Returns within 7 days if the item is not as described.",returns_bn:"বর্ণনার সাথে না মিললে ৭ দিনের মধ্যে ফেরত।",mfs:"bKash "+ph,created:now-age*DAY,suspended:false};
 });
 users[2].email="seller@rgbkart.com";
 const allShip={dhaka:true,outside:true,pickup:true,negotiated:false};
 const P=[
  // id, store, cat, brand, cond, price, sale, title_en, title_bn, desc_en, desc_bn, featured, deal, rating, reviews, sold, ageDays, stock, ship override
  ["p1","s1","mob-smart","Samsung","new",21999,0,"Samsung Galaxy A15 (6/128GB)","স্যামসাং গ্যালাক্সি A15 (৬/১২৮ জিবি)","Official Samsung Bangladesh unit with 1-year warranty. 6.5\" Super AMOLED, 5000mAh battery, 25W charging.","১ বছরের ওয়ারেন্টিসহ অফিসিয়াল স্যামসাং বাংলাদেশ ইউনিট। ৬.৫\" সুপার অ্যামোলেড, ৫০০০ এমএএইচ ব্যাটারি, ২৫ ওয়াট চার্জিং।",1,0,4.7,128,340,40,18],
  ["p2","s1","mob-smart","Xiaomi","new",27499,25999,"Xiaomi Redmi Note 13 (8/256GB)","শাওমি রেডমি নোট ১৩ (৮/২৫৬ জিবি)","Official warranty. 120Hz AMOLED display, 108MP camera, 33W fast charging.","অফিসিয়াল ওয়ারেন্টি। ১২০ হার্টজ অ্যামোলেড ডিসপ্লে, ১০৮ মেগাপিক্সেল ক্যামেরা, ৩৩ ওয়াট ফাস্ট চার্জিং।",0,24999,4.6,94,210,12,25],
  ["p3","s1","mob-audio","Realme","new",2299,1999,"Realme Buds T110 Wireless Earbuds","রিয়েলমি বাডস T110 ওয়্যারলেস ইয়ারবাড","AI noise cancellation for calls, 38 hours total playback, IPX5 water resistance.","কলের জন্য এআই নয়েজ ক্যান্সেলেশন, মোট ৩৮ ঘণ্টা প্লেব্যাক, IPX5 পানি প্রতিরোধী।",0,0,4.4,61,180,5,60],
  ["p4","s1","mob-acc","Generic","new",1850,0,"20000mAh Power Bank, 22.5W Fast Charge","২০০০০ এমএএইচ পাওয়ার ব্যাংক, ২২.৫ ওয়াট ফাস্ট চার্জ","Charges a phone 4–5 times. Two USB-A ports and one USB-C. Load-shedding essential.","একটি ফোন ৪–৫ বার চার্জ করে। দুটি USB-A ও একটি USB-C পোর্ট। লোডশেডিংয়ে অপরিহার্য।",0,1590,4.5,203,690,60,80],
  ["p5","s1","ele-tv","Walton","new",18900,17500,"Walton 32\" Smart LED TV","ওয়ালটন ৩২ ইঞ্চি স্মার্ট এলইডি টিভি","Android TV with YouTube and Netflix, 2 HDMI ports, 2-year panel warranty.","ইউটিউব ও নেটফ্লিক্সসহ অ্যান্ড্রয়েড টিভি, ২টি HDMI পোর্ট, ২ বছরের প্যানেল ওয়ারেন্টি।",0,0,4.3,37,72,3,9],
  ["p6","s5","mob-smart","Apple","used",38500,0,"Pre-Owned iPhone 12, 128GB (Battery 87%)","ব্যবহৃত আইফোন ১২, ১২৮ জিবি (ব্যাটারি ৮৭%)","Factory unlocked, Face ID working, minor scratches on frame. Comes with box and cable. 7-day check warranty.","ফ্যাক্টরি আনলকড, ফেস আইডি সচল, ফ্রেমে সামান্য দাগ। বক্স ও ক্যাবলসহ। ৭ দিনের চেক ওয়ারেন্টি।",1,0,4.8,22,31,8,2],
  ["p7","s5","mob-smart","Samsung","used",32000,29900,"Pre-Owned Samsung Galaxy S21 5G, 8/128GB","ব্যবহৃত স্যামসাং গ্যালাক্সি S21 5G, ৮/১২৮ জিবি","Display is flawless, battery 84%. Original charger included.","ডিসপ্লে নিখুঁত, ব্যাটারি ৮৪%। আসল চার্জারসহ।",0,0,4.5,15,19,20,3],
  ["p8","s5","ele-lap","Dell","used",29500,0,"Pre-Owned Dell Latitude 7490 (i5 8th Gen, 16GB, 256GB SSD)","ব্যবহৃত ডেল ল্যাটিচিউড ৭৪৯০ (i5 ৮ম জেন, ১৬ জিবি, ২৫৬ জিবি এসএসডি)","Business laptop in very good condition. 14\" FHD, backlit keyboard, 3–4 hours battery.","খুব ভালো অবস্থার বিজনেস ল্যাপটপ। ১৪\" FHD, ব্যাকলিট কিবোর্ড, ৩–৪ ঘণ্টা ব্যাটারি।",0,27900,4.6,11,14,2,4],
  ["p9","s2","fas-women","Local / Handmade","new",6800,0,"Handloom Dhakai Jamdani Saree","হ্যান্ডলুম ঢাকাই জামদানি শাড়ি","Woven in Rupganj over 3 weeks. Half-silk with traditional motif, 6 yards with blouse piece.","রূপগঞ্জে ৩ সপ্তাহ ধরে বোনা। ঐতিহ্যবাহী নকশার হাফ সিল্ক, ব্লাউজ পিসসহ ৬ গজ।",1,0,4.9,48,96,30,7],
  ["p10","s2","fas-men","Local / Handmade","new",1450,0,"Men's Cotton Panjabi, Embroidered Collar","ছেলেদের সুতি পাঞ্জাবি, এমব্রয়ডারি কলার","Soft breathable cotton for Eid and everyday wear. Sizes M to XXL.","ঈদ ও প্রতিদিনের জন্য নরম আরামদায়ক সুতি। সাইজ M থেকে XXL।",0,1190,4.4,77,260,15,40],
  ["p11","s2","fas-craft","Local / Handmade","new",950,0,"Nakshi Kantha Cushion Covers (Set of 2)","নকশি কাঁথা কুশন কভার (২টির সেট)","Hand-stitched by artisans in Jamalpur. 16×16 inches, zip closure.","জামালপুরের কারিগরদের হাতে সেলাই। ১৬×১৬ ইঞ্চি, চেইন লাগানো।",0,0,4.7,29,88,4,30],
  ["p12","s2","fas-women","Local / Handmade","new",2350,1990,"Women's Lawn Three-Piece, Unstitched","মেয়েদের লন থ্রি-পিস, আনস্টিচড","Printed lawn kameez, dupatta and salwar fabric. Colour-fast.","প্রিন্টেড লন কামিজ, ওড়না ও সালোয়ারের কাপড়। রং ওঠে না।",0,0,4.2,33,120,1,25],
  ["p13","s3","hom-appl","Miyako","new",2650,0,"Miyako Rice Cooker 1.8L","মিয়াকো রাইস কুকার ১.৮ লিটার","Cooks rice for 5–6 people. Keep-warm mode, aluminium inner pot, 1-year warranty.","৫–৬ জনের ভাত রান্না করে। কিপ-ওয়ার্ম মোড, অ্যালুমিনিয়াম পাত্র, ১ বছরের ওয়ারেন্টি।",1,0,4.6,84,300,25,22],
  ["p14","s3","hom-cook","Generic","new",1250,0,"Non-Stick Frying Pan 26cm","নন-স্টিক ফ্রাইং প্যান ২৬ সেমি","Granite coating, works on gas and induction.","গ্রানাইট কোটিং, গ্যাস ও ইন্ডাকশন দুটোতেই চলে।",0,990,4.3,52,175,18,50],
  ["p15","s3","hom-stor","RFL","new",680,0,"RFL Food Storage Container Set (5 pcs)","আরএফএল খাবার সংরক্ষণ কন্টেইনার সেট (৫ পিস)","Airtight lids, food-grade plastic, fridge safe.","বায়ুরোধী ঢাকনা, খাদ্য-মানের প্লাস্টিক, ফ্রিজে রাখা যায়।",0,0,4.1,40,210,9,100],
  ["p16","s3","hom-cook","Local / Handmade","new",450,0,"Clay Water Pitcher (Matir Kolshi)","মাটির কলসি","Keeps water naturally cool. Handmade by potters in Bogura.","পানি প্রাকৃতিকভাবে ঠান্ডা রাখে। বগুড়ার কুমারদের হাতে তৈরি।",0,0,4.5,18,40,2,15],
  ["p17","s3","ele-fan","Vision","used",1900,0,"Pre-Owned Vision Ceiling Fan 56\"","ব্যবহৃত ভিশন সিলিং ফ্যান ৫৬\"","Used for one summer, runs quietly at all speeds. Regulator included.","এক গ্রীষ্ম ব্যবহৃত, সব স্পিডে নিঃশব্দে চলে। রেগুলেটরসহ।",0,0,4.0,6,9,6,3],
  ["p18","s4","boo-lit","Local / Handmade","new",250,0,"Gitanjali by Rabindranath Tagore","গীতাঞ্জলি - রবীন্দ্রনাথ ঠাকুর","Hardcover Bangla edition with the original 157 poems.","মূল ১৫৭টি কবিতাসহ হার্ডকভার বাংলা সংস্করণ।",0,0,4.9,140,520,50,70],
  ["p19","s4","boo-acad","Local / Handmade","new",420,0,"HSC Physics 1st Paper Guide (2026 edition)","এইচএসসি পদার্থবিজ্ঞান ১ম পত্র গাইড (২০২৬ সংস্করণ)","Board questions with solutions and MCQ practice for the new syllabus.","নতুন সিলেবাসের জন্য বোর্ড প্রশ্নের সমাধান ও এমসিকিউ অনুশীলন।",0,0,4.4,66,300,7,45],
  ["p20","s4","boo-acad","Local / Handmade","used",900,0,"Used Engineering Admission Book Set (6 books)","ব্যবহৃত ইঞ্জিনিয়ারিং ভর্তি বই সেট (৬টি বই)","Physics, chemistry and maths. Some pencil notes, all pages intact.","পদার্থ, রসায়ন ও গণিত। কিছু পেন্সিলের নোট আছে, সব পৃষ্ঠা অক্ষত।",0,0,4.6,12,26,3,5],
  ["p21","s4","boo-kids","Local / Handmade","new",180,0,"Children's Bangla Rhymes (Chhora) Picture Book","শিশুদের ছড়ার ছবির বই","40 classic chhora with full-colour illustrations.","পূর্ণ রঙিন ছবিসহ ৪০টি ক্লাসিক ছড়া।",0,150,4.8,58,410,22,90],
  ["p22","s6","gro-honey","Local / Handmade","new",750,0,"Sundarbans Raw Khalisha Honey 500g","সুন্দরবনের খাঁটি খলিশা মধু ৫০০ গ্রাম","Collected by mawals in the Sundarbans. Unheated and unfiltered.","সুন্দরবনের মৌয়ালদের সংগৃহীত। তাপ ও ফিল্টার ছাড়া।",1,0,4.8,97,450,35,60],
  ["p23","s6","gro-rice","Local / Handmade","new",420,0,"Miniket Rice 5kg","মিনিকেট চাল ৫ কেজি","Fresh season rice from Kushtia mills.","কুষ্টিয়ার মিলের নতুন মৌসুমের চাল।",0,0,4.2,44,380,10,200],
  ["p24","s6","gro-rice","Local / Handmade","new",340,0,"Ghani-Pressed Mustard Oil 1L","ঘানি ভাঙা সরিষার তেল ১ লিটার","Cold-pressed in a wooden ghani. Strong aroma, no additives.","কাঠের ঘানিতে ভাঙা। কড়া ঘ্রাণ, কোনো মিশ্রণ নেই।",0,299,4.7,71,520,14,120],
  ["p25","s6","gro-fruit","Local / Handmade","new",900,0,"Rajshahi Himsagar Mango 5kg","রাজশাহীর হিমসাগর আম ৫ কেজি","Formalin-free, picked to order and shipped in a ventilated box.","ফরমালিনমুক্ত, অর্ডার অনুযায়ী পাড়া এবং বাতাস চলাচলের বক্সে পাঠানো।",0,0,4.9,120,800,1,40],
  ["p26","s2","bea-skin","Generic","new",290,0,"Herbal Neem & Turmeric Face Wash 100ml","হারবাল নিম ও হলুদ ফেস ওয়াশ ১০০ মিলি","Gentle daily cleanser for oily skin.","তৈলাক্ত ত্বকের জন্য মৃদু দৈনিক ক্লিনজার।",0,0,4.1,25,95,11,60],
  ["p27","s1","spo-cric","Generic","new",2200,0,"Kashmir Willow Cricket Bat, Full Size","কাশ্মীর উইলো ক্রিকেট ব্যাট, ফুল সাইজ","Pre-knocked, cane handle with grip. Includes cover.","প্রি-নকড, গ্রিপসহ কেন হ্যান্ডেল। কভারসহ।",1,0,4.5,30,64,16,20],
  ["p28","s1","spo-foot","Generic","new",850,0,"Football Size 5, Hand-Stitched","ফুটবল সাইজ ৫, হাতে সেলাই","Match-grade PU leather.","ম্যাচ-মানের পিইউ লেদার।",0,0,4.3,19,70,7,35],
  ["p33","s1","mob-smart","Realme","new",17999,0,"Realme C67 (8/128GB)","রিয়েলমি C67 (৮/১২৮ জিবি)","Official warranty. 108MP camera, 33W SUPERVOOC charging, 5000mAh battery.","অফিসিয়াল ওয়ারেন্টি। ১০৮ মেগাপিক্সেল ক্যামেরা, ৩৩ ওয়াট সুপারভুক চার্জিং, ৫০০০ এমএএইচ ব্যাটারি।",1,16999,4.5,58,140,6,20],
  ["p34","s1","mob-audio","Xiaomi","new",3499,0,"Xiaomi Redmi Buds 5 (ANC)","শাওমি রেডমি বাডস ৫ (এএনসি)","46dB active noise cancellation, 40 hours with case.","৪৬ ডেসিবেল অ্যাক্টিভ নয়েজ ক্যান্সেলেশন, কেসসহ ৪০ ঘণ্টা।",0,2990,4.4,41,120,9,35],
  ["p35","s5","ele-lap","Apple","used",62000,0,"Pre-Owned MacBook Air M1 (8/256GB)","ব্যবহৃত ম্যাকবুক এয়ার M1 (৮/২৫৬ জিবি)","Battery cycle count 212, no dents. Charger included. 7-day check warranty.","ব্যাটারি সাইকেল ২১২, কোনো দাগ নেই। চার্জারসহ। ৭ দিনের চেক ওয়ারেন্টি।",1,0,4.8,9,11,4,2],
  ["p36","s1","ele-tv","Walton","new",32500,0,"Walton 43\" 4K Google TV","ওয়ালটন ৪৩ ইঞ্চি ৪কে গুগল টিভি","4K HDR, Google TV with voice remote, 3 HDMI ports.","৪কে এইচডিআর, ভয়েস রিমোটসহ গুগল টিভি, ৩টি এইচডিএমআই পোর্ট।",1,0,4.5,26,48,13,8],
  ["p37","s3","ele-fan","Vision","new",3950,3650,"Vision Rechargeable Table Fan 16\"","ভিশন রিচার্জেবল টেবিল ফ্যান ১৬\"","Runs up to 6 hours on battery during load-shedding. LED light built in.","লোডশেডিংয়ে ব্যাটারিতে ৬ ঘণ্টা পর্যন্ত চলে। এলইডি লাইটসহ।",0,3399,4.3,64,230,8,30],
  ["p38","s2","fas-women","Local / Handmade","new",4200,0,"Tangail Taant Cotton Saree","টাঙ্গাইল তাঁতের সুতি শাড়ি","Soft handloom cotton woven in Pathrail, Tangail.","টাঙ্গাইলের পাথরাইলে বোনা নরম তাঁতের সুতি।",1,0,4.7,36,90,10,12],
  ["p39","s2","fas-men","Local / Handmade","new",2650,0,"Men's Silk Blend Panjabi","ছেলেদের সিল্ক ব্লেন্ড পাঞ্জাবি","Festive panjabi with hand-finished buttons. Sizes M to XXL.","হাতে লাগানো বোতামসহ উৎসবের পাঞ্জাবি। সাইজ M থেকে XXL।",0,2290,4.4,22,70,5,25],
  ["p40","s2","fas-craft","Local / Handmade","new",1800,0,"Hand-Embroidered Nakshi Kantha Throw","হাতে সেলাই নকশি কাঁথা","Layered cotton kantha, 50×70 inches.","স্তরে স্তরে সুতি কাঁথা, ৫০×৭০ ইঞ্চি।",0,0,4.8,17,40,12,10],
  ["p41","s3","hom-cook","Generic","new",2400,0,"Stainless Steel Pressure Cooker 5L","স্টেইনলেস স্টিল প্রেসার কুকার ৫ লিটার","Induction base, safety valve, 2-year warranty.","ইন্ডাকশন বেস, সেফটি ভাল্ভ, ২ বছরের ওয়ারেন্টি।",0,2090,4.5,49,160,11,30],
  ["p42","s3","hom-appl","Miyako","new",1650,0,"Miyako Electric Kettle 1.8L","মিয়াকো ইলেকট্রিক কেটলি ১.৮ লিটার","Boils in 5 minutes, auto shut-off.","৫ মিনিটে পানি ফোটে, অটো বন্ধ।",1,0,4.4,38,210,7,40],
  ["p43","s4","boo-lit","Local / Handmade","new",450,0,"Himu Samagra, Vol. 1 (Humayun Ahmed)","হিমু সমগ্র, খণ্ড ১ (হুমায়ূন আহমেদ)","Five Himu novels in one hardcover volume.","এক হার্ডকভার খণ্ডে হিমুর পাঁচটি উপন্যাস।",0,0,4.9,88,310,13,50],
  ["p44","s4","boo-kids","Local / Handmade","new",320,0,"Thakurmar Jhuli (Illustrated)","ঠাকুরমার ঝুলি (সচিত্র)","The classic Bangla folk tales with colour illustrations.","রঙিন ছবিসহ ক্লাসিক বাংলা রূপকথা।",0,260,4.8,44,260,9,60],
  ["p45","s6","gro-fruit","Local / Handmade","new",650,0,"Dinajpur Lychee (100 pcs)","দিনাজপুরের লিচু (১০০টি)","Bombai variety, picked the day before shipping.","বোম্বাই জাত, পাঠানোর আগের দিন পাড়া।",1,0,4.7,52,190,3,40],
  ["p46","s6","gro-honey","Local / Handmade","new",520,0,"Mustard Flower Honey 500g","সরিষা ফুলের মধু ৫০০ গ্রাম","Winter harvest from Sirajganj mustard fields.","সিরাজগঞ্জের সরিষা ক্ষেতের শীতকালীন মধু।",0,0,4.5,31,150,12,50],
  ["p47","s2","bea-skin","Generic","new",450,0,"Cold-Pressed Coconut Oil 200ml","কোল্ড-প্রেসড নারকেল তেল ২০০ মিলি","For hair and skin. Glass bottle.","চুল ও ত্বকের জন্য। কাচের বোতল।",0,390,4.3,27,120,6,70],
  ["p48","s1","spo-cric","Generic","new",1450,0,"Cricket Batting Gloves (Pair)","ক্রিকেট ব্যাটিং গ্লাভস (জোড়া)","Youth and men's sizes, cotton inner.","কিশোর ও বড়দের সাইজ, ভিতরে সুতি।",0,0,4.2,14,45,10,24],
 ];
 const products=P.map((r,i)=>{
  const [id,storeId,cat,brand,cond,price,sale,te,tb,de,db,feat,deal,rating,reviews,sold,age,stock]=r;
  return {id,storeId,catId:cat,brandId:B(brand),condition:cond,type:"simple",price,sale:sale||0,title_en:te,title_bn:tb,desc_en:de,desc_bn:db,
   deal:deal?{price:deal,date:today()}:null,rating,reviews,sold,stock,sku:"RGB-"+(1000+i),weight:1,images:[],tone:i%6,
   ship:{...allShip,negotiated:cond==="used"},listing:feat?"featured":"free",featured:feat?"active":null,featuredUntil:feat?now+(10+i%15)*DAY:null,
   status:"approved",created:now-age*DAY-i*3600e3,approvedAt:now-age*DAY-i*3600e3+7200e3,giftId:null,attrs:{},variations:[]};
 });
 // pending queue
 const pend=[
  ["p29","s1","mob-acc","Generic","new",650,"65W GaN USB-C Charger","৬৫ ওয়াট GaN ইউএসবি-সি চার্জার","free",null],
  ["p30","s2","fas-men","Local / Handmade","new",3200,"Khadi Cotton Fatua (Comilla)","খাদি সুতি ফতুয়া (কুমিল্লা)","featured","payment_review"],
  ["p31","s5","mob-smart","Xiaomi","used",14500,"Pre-Owned Redmi Note 12, 6/128GB","ব্যবহৃত রেডমি নোট ১২, ৬/১২৮ জিবি","featured","awaiting_payment"],
  ["p32","s4","boo-lit","Local / Handmade","used",1200,"Humayun Ahmed Novel Collection (10 books, used)","হুমায়ূন আহমেদ উপন্যাস সংগ্রহ (১০টি বই, ব্যবহৃত)","free",null],
 ];
 pend.forEach(([id,storeId,cat,brand,cond,price,te,tb,listing,fs],i)=>products.push({id,storeId,catId:cat,brandId:B(brand),condition:cond,type:"simple",price,sale:0,title_en:te,title_bn:tb,
  desc_en:"Submitted by the seller and waiting for admin review.",desc_bn:"বিক্রেতা জমা দিয়েছেন, অ্যাডমিন পর্যালোচনার অপেক্ষায়।",deal:null,rating:0,reviews:0,sold:0,stock:10,sku:"RGB-"+(1100+i),weight:.5,images:[],tone:(i+2)%6,
  ship:{...allShip},listing,featured:fs,featuredUntil:null,status:"pending",created:now-(i+1)*5*3600e3,approvedAt:null,giftId:null,attrs:{},variations:[]}));
 // free→featured upgrade in review (p3 stays live)
 products.find(p=>p.id==="p3").featured="payment_review";
 const payments=[
  {id:"pay1",kind:"featured",refId:"p30",storeId:"s2",method:"bKash",sender:"01911000222",trx:"BKA7Q2M9XZ",amount:20,at:now-3*3600e3,status:"review"},
  {id:"pay2",kind:"featured",refId:"p3",storeId:"s1",method:"Nagad",sender:"01811000111",trx:"NG74KD20LP",amount:20,at:now-1.5*3600e3,status:"review"},
  {id:"pay0",kind:"featured",refId:"p1",storeId:"s1",method:"bKash",sender:"01811000111",trx:"BK9921XPQA",amount:20,at:now-20*DAY,status:"verified"},
 ];
 const coupons=[
  {id:"c1",storeId:"s1",code:"GADGET10",type:"pct",value:10,min:2000,expires:ymd(now+20*DAY),limit:100,used:23,active:true},
  {id:"c2",storeId:"s2",code:"EID200",type:"flat",value:200,min:1500,expires:ymd(now+12*DAY),limit:50,used:8,active:true},
  {id:"c3",storeId:"s6",code:"MANGO50",type:"flat",value:50,min:800,expires:ymd(now+30*DAY),limit:200,used:61,active:true},
 ];
 const gifts=[
  {id:"g1",storeId:"s1",name_en:"Tempered glass screen protector",name_bn:"টেম্পারড গ্লাস স্ক্রিন প্রটেক্টর",min:15000,scope:"all",stock:40,active:true},
  {id:"g2",storeId:"s2",name_en:"Hand-stitched jute tote bag",name_bn:"হাতে সেলাই করা পাটের ব্যাগ",min:3000,scope:"all",stock:25,active:true},
  {id:"g3",storeId:"s6",name_en:"250g Kalijira rice sample",name_bn:"২৫০ গ্রাম কালিজিরা চালের নমুনা",min:1000,scope:"all",stock:60,active:true},
 ];
 // orders history
 const r=rng(42);
 const names=[["Rahim Uddin","Dhaka","Mirpur-2, Dhaka"],["Fatema Akter","Chattogram","GEC Circle, Chattogram"],["Tanjila Islam","Sylhet","Zindabazar, Sylhet"],["Nusrat Jahan","Dhaka","Road 5, Dhanmondi"],["Imran Hossain","Khulna","Sonadanga, Khulna"],["Jannatul Ferdous","Gazipur","Tongi, Gazipur"],["Mahmudul Hasan","Rajshahi","Uposhohor, Rajshahi"],["Sumaiya Rahman","Dhaka","Uttara Sector 7"],["Rakib Chowdhury","Cumilla","Kandirpar, Cumilla"],["Shirin Begum","Barishal","Sadar Road, Barishal"],["Ariful Haque","Mymensingh","Ganginarpar, Mymensingh"],["Tasnim Ara","Rangpur","Jahaj Company More, Rangpur"]];
 const orders=[]; let no=10240;
 const live=products.filter(p=>p.status==="approved");
 for(let d=400; d>=0; d--){
  const n=Math.floor(r()*(d<30?4.2:2.6));
  for(let k=0;k<n;k++){
   const s=stores[Math.floor(r()*stores.length)]; const sp=live.filter(p=>p.storeId===s.id && (now-p.created)/DAY>d-5); if(!sp.length) continue;
   const cnt=1+(r()<.3?1:0); const items=[];
   for(let j=0;j<cnt;j++){const p=sp[Math.floor(r()*sp.length)]; if(items.find(x=>x.pid===p.id)) continue; items.push({pid:p.id,title_en:p.title_en,title_bn:p.title_bn,qty:1+(r()<.2?1:0),price:p.sale||p.price});}
   const c=names[Math.floor(r()*names.length)]; const inD=c[1]==="Dhaka"; const method=r()<.12&&s.pickup?"pickup":inD?"dhaka":"outside";
   const fee=method==="pickup"?0:inD?70:130; const sub=items.reduce((a,x)=>a+x.qty*x.price,0);
   const ts=startOfDay(now-d*DAY)+Math.floor(r()*13+9)*3600e3; if(ts>now) continue;
   let st="delivered"; if(d<1) st=r()<.6?"pending":"confirmed"; else if(d<3) st=["confirmed","packed","shipped"][Math.floor(r()*3)]; else if(d<6) st=r()<.7?"shipped":"delivered"; if(d>6&&r()<.05) st="cancelled";
   orders.push({id:"o"+no,no:"RGB-"+no,storeId:s.id,customerId:c[0]==="Nusrat Jahan"?"u_c1":null,customer:{name:c[0],phone:"01"+(700000000+Math.floor(r()*299999999)),email:"",address:c[2],district:c[1]},
    items,method,fee,discount:0,coupon:null,gift:null,pay:r()<.7?"cod":"bKash",trx:"",subtotal:sub,total:sub+fee,status:st,created:ts,note:""});
   no++;
  }
 }
 const ads=[
  {id:"ad1",placement:"home_top",title_en:"Free delivery inside Dhaka this weekend",title_bn:"এই সপ্তাহান্তে ঢাকার ভিতরে ফ্রি ডেলিভারি",sub_en:"On orders over ৳1,500 from participating shops",sub_bn:"অংশগ্রহণকারী দোকান থেকে ৳১,৫০০-এর বেশি অর্ডারে",cta_en:"Shop now",cta_bn:"এখনই কিনুন",link:"new",color:"red",start:ymd(now-2*DAY),end:ymd(now+5*DAY),active:true,storeId:null},
  {id:"ad2",placement:"home_mid",title_en:"Nakshi Ghor: Eid handloom collection",title_bn:"নকশি ঘর: ঈদ তাঁত সংগ্রহ",sub_en:"Jamdani, panjabi and kantha from Tangail artisans",sub_bn:"টাঙ্গাইলের কারিগরদের জামদানি, পাঞ্জাবি ও কাঁথা",cta_en:"Visit shop",cta_bn:"দোকানে যান",link:"store:s2",color:"dark",start:ymd(now-5*DAY),end:ymd(now+9*DAY),active:true,storeId:"s2"},
  {id:"ad3",placement:"home_mid",title_en:"Mango season is here",title_bn:"আমের মৌসুম শুরু",sub_en:"Formalin-free Himsagar from Rajshahi, picked to order",sub_bn:"রাজশাহীর ফরমালিনমুক্ত হিমসাগর, অর্ডার অনুযায়ী পাড়া",cta_en:"Order mangoes",cta_bn:"আম অর্ডার করুন",link:"product:p25",color:"gold",start:ymd(now-1*DAY),end:ymd(now+14*DAY),active:true,storeId:"s6"},
  {id:"ad4",placement:"cat_side",title_en:"Pre-owned, checked, warrantied",title_bn:"ব্যবহৃত, যাচাইকৃত, ওয়ারেন্টিসহ",sub_en:"Second Chance Mobiles",sub_bn:"সেকেন্ড চান্স মোবাইলস",cta_en:"See phones",cta_bn:"ফোন দেখুন",link:"store:s5",color:"green",start:ymd(now-3*DAY),end:ymd(now+11*DAY),active:true,storeId:"s5"},
 ];
 const adRequests=[
  {id:"ar1",storeId:"s2",placement:"home_mid",days:14,amount:1400,adId:"ad2",payId:"pay3",status:"live",at:now-5*DAY},
  {id:"ar2",storeId:"s1",placement:"home_top",days:7,amount:1050,adId:null,payId:"pay4",status:"review",at:now-6*3600e3,title_en:"Power banks from ৳1,590",title_bn:"৳১,৫৯০ থেকে পাওয়ার ব্যাংক",sub_en:"Dhaka Gadget House · load-shedding ready",sub_bn:"ঢাকা গ্যাজেট হাউস · লোডশেডিংয়ের প্রস্তুতি",link:"product:p4",color:"green"},
 ];
 payments.push({id:"pay3",kind:"ad",refId:"ar1",storeId:"s2",method:"bKash",sender:"01911000222",trx:"BK55AD0021",amount:1400,at:now-5*DAY,status:"verified"});
 payments.push({id:"pay4",kind:"ad",refId:"ar2",storeId:"s1",method:"Rocket",sender:"01811000111",trx:"RK33019920",amount:1050,at:now-6*3600e3,status:"review"});
 return {
  v:4,lang:S?.lang||"en",userId:null,cart:[],
  settings:{featuredFee:20,featuredDays:30,allowVariable:false,
   ship:{dhaka:{on:true,fee:70,eta_en:"1–2 days",eta_bn:"১–২ দিন"},outside:{on:true,fee:130,eta_en:"3–5 days",eta_bn:"৩–৫ দিন"},pickup:{on:true,fee:0,eta_en:"Same day",eta_bn:"একই দিন"},negotiated:{on:true,fee:0,eta_en:"Agreed with seller",eta_bn:"বিক্রেতার সাথে আলোচনা"}},
   mfs:[{id:"bKash",kind:"mfs",number:"01919-244000",on:true,color:"#E2136E",logo:null},{id:"Nagad",kind:"mfs",number:"01919-244000",on:true,color:"#F26A21",logo:null},{id:"Rocket",kind:"mfs",number:"01700-1122550",on:true,color:"#8C3494",logo:null},{id:"Upay",kind:"mfs",number:"01919-244000",on:true,color:"#0B4EA2",logo:null},{id:"Visa",kind:"card",number:"",on:true,color:"#1A1F71",logo:null},{id:"Mastercard",kind:"card",number:"",on:true,color:"#EB001B",logo:null},{id:"American Express",kind:"card",number:"",on:false,color:"#2E77BC",logo:null},{id:"Cash on delivery",kind:"cod",number:"",on:true,color:"#00802B",logo:null}],
   adPrice:{home_top:150,home_mid:100,cat_side:60},logo:null,supportPhone:"09612-000000",supportEmail:"help@rgbkart.com",
   home:{slides:[
    {id:"sl1",eyebrow_en:"Zero commission marketplace",eyebrow_bn:"শূন্য কমিশনের মার্কেটপ্লেস",title_en:"Shop from Bangladesh's independent sellers",title_bn:"বাংলাদেশের স্বতন্ত্র বিক্রেতাদের কাছ থেকে কিনুন",cta_en:"Explore deals",cta_bn:"ডিল দেখুন",link:"deals",color:"green",art:"basket"},
    {id:"sl2",eyebrow_en:"Brand new & pre-owned",eyebrow_bn:"নতুন ও ব্যবহৃত",title_en:"Checked phones with battery health on every listing",title_bn:"প্রতিটি লিস্টিংয়ে ব্যাটারি হেলথসহ যাচাইকৃত ফোন",cta_en:"Browse phones",cta_bn:"ফোন দেখুন",link:"cat:mob",color:"red",art:"phone"},
    {id:"sl3",eyebrow_en:"For sellers",eyebrow_bn:"বিক্রেতাদের জন্য",title_en:"Open your shop free. Feature a listing for ৳20.",title_bn:"বিনামূল্যে দোকান খুলুন। ৳২০-তে লিস্টিং ফিচার করুন।",cta_en:"Start selling",cta_bn:"বিক্রি শুরু করুন",link:"register",color:"dark",art:"store"},
   ],sections:[{key:"cats",on:true},{key:"featured",on:true,max:12},{key:"deals",on:true,max:12},{key:"ads",on:true},{key:"new",on:true,max:12},{key:"usps",on:true},{key:"shops",on:true}]},
   menu:[{id:"mh",label_en:"Home",label_bn:"হোম",link:"home"},{id:"m0",label_en:"Shop",label_bn:"শপ",link:"shop"},{id:"m1",label_en:"Deals of the Day",label_bn:"আজকের ডিল",link:"deals",hot:true},{id:"m2",label_en:"Featured",label_bn:"ফিচার্ড",link:"featured"},{id:"m3",label_en:"New Arrivals",label_bn:"নতুন পণ্য",link:"new"},{id:"m4",label_en:"Pre-Owned",label_bn:"ব্যবহৃত",link:"used"},{id:"m5",label_en:"Mobiles",label_bn:"মোবাইল",link:"cat:mob"},{id:"m6",label_en:"Fashion",label_bn:"ফ্যাশন",link:"cat:fas"},{id:"m7",label_en:"Groceries",label_bn:"মুদি",link:"cat:gro"}],
  },
  categories,brands,attributes,users,stores,products,payments,coupons,gifts,orders,ads,adRequests,
 };
}
</script>
