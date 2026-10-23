// RGBKart English / Bangla.
// Load this BEFORE other page scripts, at the end of <body>. Choice is kept in localStorage ('rgbkart-lang'); ?lang=bn or ?lang=en also sets it.
// In Bangla mode it translates the page's English texts on its own (text, placeholder, aria-label, title, alt), including text added later,
// using the dictionary below. Anything inside translate="no" is left alone (product titles, shop names, people's messages).
// Helpers for page code: T('Text {n}', {n}) for texts with values, L(row, 'name') for name / name_bn, N(123) for digits, RGBLang.date(...).
(function () {
  const KEY = 'rgbkart-lang';
  let lang = 'en';
  try {
    const q = new URLSearchParams(location.search).get('lang');
    if (q === 'bn' || q === 'en') localStorage.setItem(KEY, q);
    lang = localStorage.getItem(KEY) === 'bn' ? 'bn' : 'en';
  } catch (_) {}
  const BN = '০১২৩৪৫৬৭৮৯';
  const N = v => lang === 'bn' ? String(v ?? '').replace(/\d/g, d => BN[d]) : String(v ?? '');

  // ---------------- exact texts ----------------
  const D = {
    // header, menu, footer
    'Search phones, fashion, groceries…': 'ফোন, ফ্যাশন, মুদি বাজার খুঁজুন…', 'Search products': 'পণ্য খুঁজুন', 'Search': 'খুঁজুন', 'Search RGBKart': 'RGBKart-এ খুঁজুন',
    '+ Sell': '+ বিক্রি করুন', 'Sell': 'বিক্রি', 'Messages': 'মেসেজ', 'Alerts': 'নোটিফিকেশন', 'Saved items': 'সংরক্ষিত পণ্য', 'Sign in': 'সাইন ইন', 'My account': 'আমার অ্যাকাউন্ট',
    'Cart': 'কার্ট', 'Account': 'অ্যাকাউন্ট', 'All categories': 'সব ক্যাটাগরি', 'Main menu': 'প্রধান মেনু', 'Home': 'হোম', 'Shop': 'শপ',
    'Deals of the Day': 'আজকের ডিল', 'Featured': 'ফিচার্ড', 'New Arrivals': 'নতুন পণ্য', 'Pre-Owned': 'ব্যবহৃত পণ্য', 'Free delivery': 'ফ্রি ডেলিভারি',
    'Electronics': 'ইলেকট্রনিক্স', 'Fashion': 'ফ্যাশন', 'Sell on RGBKart': 'RGBKart-এ বিক্রি করুন',
    'See all categories →': 'সব ক্যাটাগরি দেখুন →', 'Categories are loading. Try again in a moment.': 'ক্যাটাগরি লোড হচ্ছে। একটু পরে আবার চেষ্টা করুন।',
    'Buy and sell across all 64 districts.': '৬৪ জেলা জুড়ে কেনাবেচা করুন।', 'All products': 'সব পণ্য', 'My orders': 'আমার অর্ডার', 'Sell an item': 'একটি পণ্য বিক্রি করুন',
    'Open a shop': 'দোকান খুলুন', 'Language': 'ভাষা', 'Ad': 'বিজ্ঞাপন', 'Sponsored': 'বিজ্ঞাপন',
    // cards and labels
    '★ Featured': '★ ফিচার্ড', 'Pre-owned': 'ব্যবহৃত', 'New': 'নতুন', 'Used': 'ব্যবহৃত', 'Negotiable': 'দরদাম করা যাবে', 'No photo': 'ছবি নেই',
    'Saved ♥': 'সংরক্ষিত ♥', 'Removed from saved': 'সংরক্ষিত তালিকা থেকে সরানো হয়েছে', 'View all': 'সব দেখুন', 'See all →': 'সব দেখুন →', 'Browse →': 'দেখুন →', 'Show more': 'আরও দেখুন',
    // home
    'Buy and sell anything, anywhere in Bangladesh': 'বাংলাদেশের যেকোনো জায়গায়, যেকোনো কিছু কেনাবেচা করুন',
    'New and pre-owned products from trusted shops and people near you. Every listing is checked by our team.': 'বিশ্বস্ত দোকান ও আপনার আশেপাশের মানুষের নতুন ও ব্যবহৃত পণ্য। প্রতিটি লিস্টিং আমাদের টিম যাচাই করে।',
    'Start shopping': 'কেনাকাটা শুরু করুন', '+ Sell an item': '+ একটি পণ্য বিক্রি করুন', 'Shop by category': 'ক্যাটাগরি অনুযায়ী কেনাকাটা',
    'Featured Products': 'ফিচার্ড পণ্য', 'Top picks promoted by our sellers': 'বিক্রেতাদের বাছাই করা সেরা পণ্য', 'Prices cut for a limited time': 'সীমিত সময়ের জন্য কম দাম',
    'Fresh listings from across Bangladesh': 'সারা বাংলাদেশ থেকে নতুন লিস্টিং', 'Pre-owned Deals': 'ব্যবহৃত পণ্যের ডিল', 'Pre-owned deals': 'ব্যবহৃত পণ্যের ডিল',
    'Quality second-hand items at great prices': 'ভালো দামে মানসম্মত পুরোনো পণ্য', 'Phones, laptops and more at second-hand prices': 'পুরোনো দামে ফোন, ল্যাপটপ ও আরও অনেক কিছু',
    "Have something you don't use?": 'ব্যবহার করেন না এমন কিছু আছে?',
    'Sell it on RGBKart for free. No account needed. Buyers message you here, or call you if you go Featured.': 'RGBKart-এ বিনামূল্যে বিক্রি করুন। অ্যাকাউন্ট লাগবে না। ক্রেতারা এখানে মেসেজ দেবেন, ফিচার্ড করলে কলও করবেন।',
    'No products yet. Be the first to sell something!': 'এখনো কোনো পণ্য নেই। প্রথম বিক্রেতা হোন!',
    // categories
    'Categories': 'ক্যাটাগরি', 'Pick a category, or jump straight to a sub-category.': 'একটি ক্যাটাগরি বাছুন, অথবা সরাসরি উপ-ক্যাটাগরিতে যান।', 'Breadcrumb': 'পথনির্দেশ',
    // browse
    'Filters': 'ফিল্টার', 'Categories and filters': 'ক্যাটাগরি ও ফিল্টার', '☰ Categories & filters': '☰ ক্যাটাগরি ও ফিল্টার', 'Close ✕': 'বন্ধ করুন ✕',
    'Condition': 'অবস্থা', 'Any': 'যেকোনো', 'District': 'জেলা', "Seller's district": 'বিক্রেতার জেলা', 'Anywhere in Bangladesh': 'বাংলাদেশের যেকোনো জায়গা',
    'Price (৳)': 'দাম (৳)', 'Min': 'সর্বনিম্ন', 'Max': 'সর্বোচ্চ', 'Minimum price': 'সর্বনিম্ন দাম', 'Maximum price': 'সর্বোচ্চ দাম', 'Apply price': 'দাম প্রয়োগ করুন',
    'On sale': 'অফারে আছে', 'Featured only': 'শুধু ফিচার্ড', '★ Featured only': '★ শুধু ফিচার্ড', '★ Featured products': '★ ফিচার্ড পণ্য', 'Clear all filters': 'সব ফিল্টার মুছুন',
    'Sort by': 'সাজান', 'Best match': 'সবচেয়ে মিল', 'Newest first': 'নতুন আগে', 'Price: low to high': 'দাম: কম থেকে বেশি', 'Price: high to low': 'দাম: বেশি থেকে কম',
    'Nothing here yet': 'এখানে এখনো কিছু নেই', 'Be the first to list something in this category.': 'এই ক্যাটাগরিতে প্রথম পণ্যটি আপনিই দিন।',
    'Try removing a filter or searching for something else.': 'একটি ফিল্টার সরিয়ে দেখুন বা অন্য কিছু খুঁজুন।',
    "Products couldn't load. Check your connection and try again.": 'পণ্য লোড হয়নি। ইন্টারনেট সংযোগ দেখে আবার চেষ্টা করুন।',
    '♥ Saved items': '♥ সংরক্ষিত পণ্য', 'Tap the ♡ on any product to save it here.': 'যেকোনো পণ্যের ♡ চাপুন, এখানে সংরক্ষিত থাকবে।', 'Products': 'পণ্য', 'Brand new': 'একদম নতুন', '‹ Previous': '‹ আগের পৃষ্ঠা', 'Next ›': 'পরের পৃষ্ঠা ›', 'Previous page': 'আগের পৃষ্ঠা', 'Next page': 'পরের পৃষ্ঠা', 'Pages': 'পৃষ্ঠা', 'any': 'যেকোনো',
    // product
    'Add to cart': 'কার্টে যোগ করুন', 'Buy now': 'এখনই কিনুন', 'Added to cart': 'কার্টে যোগ হয়েছে', 'Quantity': 'পরিমাণ', 'Less': 'কম', 'More': 'বেশি',
    'In stock': 'স্টকে আছে', 'Out of stock': 'স্টকে নেই', 'Available to order': 'অর্ডার করা যাবে', 'Description': 'বিবরণ', 'Details': 'বিস্তারিত',
    "The seller hasn't added a description.": 'বিক্রেতা কোনো বিবরণ দেননি।', 'Product code': 'পণ্য কোড', 'Weight': 'ওজন', 'Size': 'মাপ', 'Category': 'ক্যাটাগরি',
    'Sold by': 'বিক্রেতা', 'Listed by': 'লিস্ট করেছেন', 'Seller': 'বিক্রেতা', 'Individual seller': 'ব্যক্তিগত বিক্রেতা', 'Seller details unavailable': 'বিক্রেতার তথ্য পাওয়া যাচ্ছে না',
    'Contact': 'যোগাযোগ', 'Call': 'কল করুন', 'WhatsApp': 'হোয়াটসঅ্যাপ', 'Message': 'মেসেজ', '✉ Email': '✉ ইমেইল', 'Email': 'ইমেইল',
    '💬 Message seller': '💬 বিক্রেতাকে মেসেজ দিন', '📞 Contact seller': '📞 বিক্রেতার সাথে যোগাযোগ', '★ Featured seller: call, WhatsApp, email or message': '★ ফিচার্ড বিক্রেতা: কল, হোয়াটসঅ্যাপ, ইমেইল বা মেসেজ',
    "Contact options aren't available for this listing yet.": 'এই লিস্টিংয়ে এখনো যোগাযোগের সুযোগ নেই।',
    "This seller keeps their number private. Send them a message on RGBKart and they'll reply here.": 'এই বিক্রেতা নম্বর গোপন রাখেন। RGBKart-এ মেসেজ দিন, তিনি এখানেই উত্তর দেবেন।',
    'Message to': 'মেসেজ পাঠান', 'Your name': 'আপনার নাম', 'Write a message.': 'একটি মেসেজ লিখুন।', 'Send message': 'মেসেজ পাঠান', 'Sending…': 'পাঠানো হচ্ছে…',
    '✓ Message sent': '✓ মেসেজ পাঠানো হয়েছে', 'The seller will reply in your': 'বিক্রেতা উত্তর দেবেন আপনার', 'Replies appear in': 'উত্তর দেখা যাবে', 'on this phone or browser.': 'এই ফোন বা ব্রাউজারে।',
    "Couldn't send. Please try again.": 'পাঠানো যায়নি। আবার চেষ্টা করুন।', 'Enter your name so the seller knows who is asking.': 'আপনার নাম লিখুন, যাতে বিক্রেতা বুঝতে পারেন কে জানতে চাইছেন।',
    "Messaging isn't switched on yet. Please try again later.": 'মেসেজ এখনো চালু হয়নি। পরে আবার চেষ্টা করুন।', 'No internet connection. Try again.': 'ইন্টারনেট সংযোগ নেই। আবার চেষ্টা করুন।',
    "This is your listing. Buyers'll message you; see Messages.": 'এটি আপনার লিস্টিং। ক্রেতারা আপনাকে মেসেজ দেবেন; মেসেজ দেখুন।',
    'Meet in a safe public place and check the item before you pay.': 'নিরাপদ জনসমাগমের জায়গায় দেখা করুন এবং টাকা দেওয়ার আগে পণ্যটি দেখে নিন।',
    "Never send advance money to someone you haven't met.": 'যাকে চেনেন না তাকে কখনো আগাম টাকা পাঠাবেন না।',
    'Deal directly with the seller. RGBKart does not handle payment or delivery for this listing.': 'সরাসরি বিক্রেতার সাথে লেনদেন করুন। এই লিস্টিংয়ের পেমেন্ট বা ডেলিভারি RGBKart দেখে না।',
    'Price negotiable': 'দরদাম করা যাবে', 'Cash on delivery available': 'ক্যাশ অন ডেলিভারি আছে', 'Pay online (no cash on delivery)': 'অনলাইনে পেমেন্ট (ক্যাশ অন ডেলিভারি নেই)',
    'Pay in cash when your order arrives. Each shop delivers its own items.': 'পণ্য হাতে পেয়ে নগদ টাকা দিন। প্রতিটি দোকান নিজের পণ্য নিজেই পাঠায়।',
    'Delivers all over Bangladesh': 'সারা বাংলাদেশে ডেলিভারি', 'Delivers inside Dhaka only': 'শুধু ঢাকার ভিতরে ডেলিভারি', 'Delivers outside Dhaka only': 'শুধু ঢাকার বাইরে ডেলিভারি',
    'Available all over Bangladesh': 'সারা বাংলাদেশে পাওয়া যায়', 'Available inside Dhaka': 'ঢাকার ভিতরে পাওয়া যায়', 'Available outside Dhaka': 'ঢাকার বাইরে পাওয়া যায়',
    'Ships today': 'আজই পাঠানো হবে', 'Ships in 1–2 days': '১–২ দিনে পাঠানো হবে', 'Ships in 3–5 days': '৩–৫ দিনে পাঠানো হবে', 'Ships in 6–10 days': '৬–১০ দিনে পাঠানো হবে',
    'No returns': 'ফেরত নেওয়া হয় না', '3-day returns': '৩ দিনের মধ্যে ফেরত', '7-day returns': '৭ দিনের মধ্যে ফেরত', '15-day returns': '১৫ দিনের মধ্যে ফেরত', '30-day returns': '৩০ দিনের মধ্যে ফেরত',
    'Buy more, pay less': 'বেশি কিনুন, কম দিন', "You'll get": 'আপনি পাবেন', 'Total': 'মোট', 'Yes': 'হ্যাঁ', 'No': 'না',
    'Digital download': 'ডিজিটাল ডাউনলোড', 'Download link after payment': 'পেমেন্টের পর ডাউনলোড লিংক', 'Service': 'সার্ভিস', 'Gift card': 'গিফট কার্ড',
    'At your place': 'আপনার ঠিকানায়', "At the seller's shop": 'বিক্রেতার দোকানে', 'Half a day': 'আধা দিন', 'A full day': 'পুরো দিন', 'Several days': 'কয়েক দিন',
    "This product isn't available": 'এই পণ্যটি পাওয়া যাচ্ছে না', 'It may have been sold, removed, or is still being checked.': 'হয়তো বিক্রি হয়ে গেছে, সরানো হয়েছে, বা এখনো যাচাই চলছে।',
    'Back to RGBKart': 'RGBKart-এ ফিরে যান', 'Full payment when ordering': 'অর্ডারের সময় পুরো পেমেন্ট', 'this shop': 'এই দোকান', 'draft': 'খসড়া', 'waiting for review': 'যাচাইয়ের অপেক্ষায়', 'rejected': 'বাতিল', 'hidden': 'লুকানো', 'Shop on RGBKart': 'RGBKart-এ কেনাকাটা', 'not taking orders right now': 'এখন অর্ডার নিচ্ছে না', 'Shop is on holiday': 'দোকান ছুটিতে আছে',
    'Your cart': 'আপনার কার্ট', 'Your cart is empty.': 'আপনার কার্ট খালি।', 'View full cart': 'পুরো কার্ট দেখুন', 'Checkout': 'চেকআউট', 'Close cart': 'কার্ট বন্ধ করুন', 'the seller': 'বিক্রেতা',
    'Seller is in ': 'বিক্রেতা আছেন ', 'On holiday: ': 'ছুটিতে: ',
    // cart and checkout
    '1 Cart': '১ কার্ট', '2 Delivery & payment': '২ ডেলিভারি ও পেমেন্ট', '3 Done': '৩ সম্পন্ন', 'Checkout steps': 'চেকআউটের ধাপ',
    'Loading your cart…': 'আপনার কার্ট লোড হচ্ছে…', 'Loading…': 'লোড হচ্ছে…', 'Your cart is empty': 'আপনার কার্ট খালি',
    'Find something you like and tap "Add to cart".': 'পছন্দের কিছু খুঁজে "কার্টে যোগ করুন" চাপুন।', 'Remove': 'সরিয়ে দিন', 'Delivery': 'ডেলিভারি',
    'Inside Dhaka': 'ঢাকার ভিতরে', 'Outside Dhaka': 'ঢাকার বাইরে', 'Store pickup': 'দোকান থেকে সংগ্রহ', 'Agree with the seller': 'বিক্রেতার সাথে আলোচনা করে', 'Agree with shop': 'দোকানের সাথে আলোচনা করে',
    'Free': 'ফ্রি', 'From the shop': 'দোকান থেকে', '✓ Free delivery from this shop': '✓ এই দোকান থেকে ফ্রি ডেলিভারি', 'Order summary': 'অর্ডারের সারাংশ',
    'Pay in cash when your order arrives (Cash on Delivery).': 'পণ্য হাতে পেয়ে নগদ টাকা দিন (ক্যাশ অন ডেলিভারি)।',
    'Each shop packs and sends its own items, so you get one order per shop. You pay the shop in cash when it arrives.': 'প্রতিটি দোকান নিজের পণ্য প্যাক করে পাঠায়, তাই প্রতিটি দোকানের জন্য আলাদা অর্ডার হবে। পণ্য পৌঁছালে দোকানকে নগদ টাকা দেবেন।',
    "Can't be ordered": 'অর্ডার করা যাবে না', "Remove the items that can't be ordered to continue.": 'এগোতে যে পণ্যগুলো অর্ডার করা যাবে না সেগুলো সরিয়ে দিন।', '← Continue shopping': '← কেনাকাটা চালিয়ে যান',
    'Continue shopping': 'কেনাকাটা চালিয়ে যান', 'Contact the seller to buy this': 'এটি কিনতে বিক্রেতার সাথে যোগাযোগ করুন', 'No longer available': 'আর পাওয়া যাচ্ছে না',
    'This option is no longer available': 'এই অপশনটি আর নেই', "Digital products can't be ordered yet": 'ডিজিটাল পণ্য এখনো অর্ডার করা যায় না', 'Not available with Cash on Delivery': 'ক্যাশ অন ডেলিভারিতে পাওয়া যায় না',
    'Seller will call you': 'বিক্রেতা আপনাকে কল করবেন', 'Same day': 'একই দিন', '1–2 days': '১–২ দিন', '2–3 days': '২–৩ দিন', '3–5 days': '৩–৫ দিন', 'Checkout →': 'চেকআউট →',
    'Delivery details': 'ডেলিভারির তথ্য', 'Full name': 'পুরো নাম', 'Mobile number': 'মোবাইল নম্বর', 'Address (house, road, area)': 'ঠিকানা (বাসা, রোড, এলাকা)',
    'e.g. House 12, Road 5, Block C, Mirpur 10': 'যেমন: বাসা ১২, রোড ৫, ব্লক সি, মিরপুর ১০', 'Choose your district': 'আপনার জেলা বাছুন', 'Area / thana (optional)': 'এলাকা / থানা (ঐচ্ছিক)',
    'Email (optional)': 'ইমেইল (ঐচ্ছিক)', 'Note for the shop (optional)': 'দোকানের জন্য নোট (ঐচ্ছিক)', 'e.g. Call before delivery, gate code…': 'যেমন: ডেলিভারির আগে কল দিন, গেটের কোড…',
    'Payment': 'পেমেন্ট', 'Cash on Delivery': 'ক্যাশ অন ডেলিভারি', 'Pay the shop in cash when your order arrives. RGBKart never takes your money.': 'পণ্য পৌঁছালে দোকানকে নগদ টাকা দিন। RGBKart কখনো আপনার টাকা নেয় না।',
    'Have an account? ': 'অ্যাকাউন্ট আছে? ', ' to keep your orders in it. You can also order without signing in: your orders are kept on this phone or computer.': ' করুন, অর্ডারগুলো অ্যাকাউন্টে থাকবে। সাইন ইন ছাড়াও অর্ডার করা যায়: তখন অর্ডারগুলো এই ফোন বা কম্পিউটারে থাকবে।',
    'Your order': 'আপনার অর্ডার', 'Total to pay on delivery': 'ডেলিভারিতে মোট দিতে হবে', '← Back to cart (change delivery)': '← কার্টে ফিরুন (ডেলিভারি বদলান)', 'Placing your order…': 'অর্ডার দেওয়া হচ্ছে…',
    'your name': 'আপনার নাম', 'a valid mobile number like 01711000000': '01711000000-এর মতো সঠিক মোবাইল নম্বর', 'your full address': 'পুরো ঠিকানা', 'your district': 'আপনার জেলা',
    'a valid email (or leave it empty)': 'সঠিক ইমেইল (অথবা খালি রাখুন)', 'No internet connection. Please try again.': 'ইন্টারনেট সংযোগ নেই। আবার চেষ্টা করুন।',
    "Ordering isn't switched on yet. Please try again later.": 'অর্ডার এখনো চালু হয়নি। পরে আবার চেষ্টা করুন।', "Ordering without an account isn't switched on yet. Please sign in first.": 'অ্যাকাউন্ট ছাড়া অর্ডার এখনো চালু হয়নি। আগে সাইন ইন করুন।',
    'Something went wrong. Please try again.': 'কিছু একটা সমস্যা হয়েছে। আবার চেষ্টা করুন।', 'Thank you! Your order is placed.': 'ধন্যবাদ! আপনার অর্ডার দেওয়া হয়েছে।', 'Track my orders': 'আমার অর্ডার দেখুন',
    'You ordered without an account, so your orders are saved on this phone or computer. Keep using it to track them.': 'আপনি অ্যাকাউন্ট ছাড়া অর্ডার করেছেন, তাই অর্ডারগুলো এই ফোন বা কম্পিউটারে সংরক্ষিত আছে। ট্র্যাক করতে এটিই ব্যবহার করুন।',
    // orders
    'Track your orders. Each shop confirms, packs and delivers its own order, and you pay it in cash on delivery.': 'আপনার অর্ডার ট্র্যাক করুন। প্রতিটি দোকান নিজের অর্ডার নিশ্চিত করে, প্যাক করে ও পৌঁছে দেয়; আপনি ডেলিভারির সময় নগদ টাকা দেন।',
    'No orders on this device': 'এই ডিভাইসে কোনো অর্ডার নেই', 'Sign in to see orders in your account, or place an order to see it here.': 'অ্যাকাউন্টের অর্ডার দেখতে সাইন ইন করুন, অথবা অর্ডার দিলে এখানে দেখা যাবে।',
    'No orders yet': 'এখনো কোনো অর্ডার নেই', 'When you place an order, you can track it here.': 'অর্ডার দিলে এখানে ট্র্যাক করতে পারবেন।', "Orders aren't switched on yet.": 'অর্ডার এখনো চালু হয়নি।',
    'Placed': 'অর্ডার হয়েছে', 'Confirmed': 'নিশ্চিত', 'Packed': 'প্যাক করা হয়েছে', 'On the way': 'পথে আছে', 'Delivered': 'পৌঁছে গেছে', 'Cancelled': 'বাতিল', 'Waiting for shop': 'দোকানের অপেক্ষায়',
    'Order progress': 'অর্ডারের অগ্রগতি', 'Cancel order': 'অর্ডার বাতিল করুন', 'Yes, cancel order': 'হ্যাঁ, অর্ডার বাতিল করুন', 'Keep order': 'অর্ডার রাখুন',
    'Why are you cancelling? (optional)': 'কেন বাতিল করছেন? (ঐচ্ছিক)', 'Reason for cancelling': 'বাতিলের কারণ', 'Order cancelled': 'অর্ডার বাতিল হয়েছে', '📞 Call shop': '📞 দোকানে কল দিন',
    'Delivery info from the shop: ': 'দোকানের ডেলিভারি তথ্য: ', 'Pick up from: ': 'সংগ্রহ করুন: ',
    // messages and alerts
    "Chats with buyers and sellers. They're kept on this phone or browser, so keep using it to see replies.": 'ক্রেতা ও বিক্রেতার সাথে কথোপকথন। এগুলো এই ফোন বা ব্রাউজারে থাকে, তাই উত্তর দেখতে এটিই ব্যবহার করুন।',
    'You: ': 'আপনি: ', ' (removed)': ' (সরানো হয়েছে)', 'All': 'সব', 'Buying': 'কেনা', 'Selling': 'বিক্রি', 'Buyer': 'ক্রেতা', 'Pick a conversation': 'একটি কথোপকথন বাছুন', 'Back to all messages': 'সব মেসেজে ফিরুন',
    'Write a reply…': 'উত্তর লিখুন…', 'Reply': 'উত্তর দিন', 'Send': 'পাঠান', 'No messages yet': 'এখনো কোনো মেসেজ নেই', 'Browse products': 'পণ্য দেখুন', 'New message': 'নতুন মেসেজ',
    'When you message a seller, or a buyer messages you, the chat appears here.': 'আপনি বিক্রেতাকে মেসেজ দিলে, বা ক্রেতা আপনাকে মেসেজ দিলে, কথোপকথন এখানে দেখা যাবে।',
    "You haven't messaged any sellers yet.": 'আপনি এখনো কোনো বিক্রেতাকে মেসেজ দেননি।', 'No buyers have messaged you yet.': 'এখনো কোনো ক্রেতা মেসেজ দেননি।', 'Your messages appear here.': 'আপনার মেসেজ এখানে দেখা যাবে।',
    "Messages aren't ready yet": 'মেসেজ এখনো প্রস্তুত নয়',
    'News about your orders, payments, listings and messages. We also email them to you.': 'আপনার অর্ডার, পেমেন্ট, লিস্টিং ও মেসেজের খবর। আমরা ইমেইলেও পাঠাই।',
    'Email me my alerts': 'নোটিফিকেশন ইমেইলে পাঠান', 'Emails go to the address you gave us when ordering or listing.': 'অর্ডার বা লিস্টিংয়ের সময় যে ইমেইল দিয়েছিলেন সেখানে পাঠানো হয়।', 'Emails go to ': 'ইমেইল যাবে ',
    'Alert emails are on': 'নোটিফিকেশন ইমেইল চালু', 'Alert emails are off. You can still see alerts here.': 'নোটিফিকেশন ইমেইল বন্ধ। এখানে তবুও দেখতে পাবেন।',
    'No alerts yet': 'এখনো কোনো নোটিফিকেশন নেই', "When something happens with your orders, listings or messages, you'll see it here.": 'আপনার অর্ডার, লিস্টিং বা মেসেজে নতুন কিছু হলে এখানে দেখতে পাবেন।',
    'Sign in to see your alerts': 'নোটিফিকেশন দেখতে সাইন ইন করুন', "Alerts aren't switched on yet.": 'নোটিফিকেশন এখনো চালু হয়নি।', 'just now': 'এইমাত্র',
    // login
    'Sign in, or create an account to shop or sell.': 'কেনাকাটা বা বিক্রির জন্য সাইন ইন করুন অথবা অ্যাকাউন্ট খুলুন।', 'Continue with Google': 'গুগল দিয়ে চালিয়ে যান', 'Continue with Facebook': 'ফেসবুক দিয়ে চালিয়ে যান',
    'or use email': 'অথবা ইমেইল ব্যবহার করুন', 'Password': 'পাসওয়ার্ড', 'Show password': 'পাসওয়ার্ড দেখুন', 'Hide password': 'পাসওয়ার্ড লুকান', 'Forgot password?': 'পাসওয়ার্ড ভুলে গেছেন?',
    'No account yet?': 'এখনো অ্যাকাউন্ট নেই?', 'Create one': 'একটি খুলুন', 'Already have an account?': 'আগে থেকেই অ্যাকাউন্ট আছে?', 'Confirm password': 'পাসওয়ার্ড আবার লিখুন',
    'Confirm new password': 'নতুন পাসওয়ার্ড আবার লিখুন', 'New password': 'নতুন পাসওয়ার্ড', 'Passwords match': 'পাসওয়ার্ড মিলেছে', '✓ Passwords match': '✓ পাসওয়ার্ড মিলেছে',
    "✕ Passwords don't match yet": '✕ পাসওয়ার্ড এখনো মেলেনি', "The two passwords don't match. Type the same password in both boxes.": 'দুটি পাসওয়ার্ড মেলেনি। দুই ঘরে একই পাসওয়ার্ড লিখুন।',
    'Use at least 6 characters for the password.': 'পাসওয়ার্ডে অন্তত ৬টি অক্ষর দিন।', 'Send reset link': 'রিসেট লিংক পাঠান', 'Remembered it?': 'মনে পড়েছে?', 'Set a new password': 'নতুন পাসওয়ার্ড দিন',
    'Save password': 'পাসওয়ার্ড সংরক্ষণ করুন', 'If that email has an account, a reset link is on its way. Open it on this device.': 'ওই ইমেইলে অ্যাকাউন্ট থাকলে রিসেট লিংক যাচ্ছে। এই ডিভাইসেই খুলুন।',
    'Account created. Check your email for a confirmation link, then sign in here.': 'অ্যাকাউন্ট খোলা হয়েছে। ইমেইলে নিশ্চিতকরণ লিংক দেখে নিন, তারপর এখানে সাইন ইন করুন।',
    'Account type': 'অ্যাকাউন্টের ধরন', 'I want to buy': 'আমি কিনতে চাই', 'I want to sell': 'আমি বিক্রি করতে চাই', 'Customer': 'ক্রেতা', 'As Customer': 'ক্রেতা হিসেবে', 'As Seller': 'বিক্রেতা হিসেবে',
    'Create customer account': 'ক্রেতা অ্যাকাউন্ট খুলুন', 'Create seller account': 'বিক্রেতা অ্যাকাউন্ট খুলুন', 'About you': 'আপনার সম্পর্কে', 'Phone': 'ফোন', 'Login details': 'লগইন তথ্য',
    'Shop details': 'দোকানের তথ্য', 'Shop name': 'দোকানের নাম', 'Business address': 'ব্যবসার ঠিকানা', 'Trade license no. (optional)': 'ট্রেড লাইসেন্স নম্বর (ঐচ্ছিক)',
    'What do you sell? (optional)': 'আপনি কী বিক্রি করেন? (ঐচ্ছিক)', 'Delivery address': 'ডেলিভারির ঠিকানা', 'Postal code (optional)': 'পোস্ট কোড (ঐচ্ছিক)',
    'Finish setting up your account': 'আপনার অ্যাকাউন্ট সেটআপ শেষ করুন', "Tell us how you'll use RGBKart. You can't change this later.": 'আপনি RGBKart কীভাবে ব্যবহার করবেন জানান। পরে এটি বদলানো যাবে না।',
    'Save and continue': 'সংরক্ষণ করে এগিয়ে যান', 'Sign out': 'সাইন আউট', 'Approved': 'অনুমোদিত', 'Pending approval': 'অনুমোদনের অপেক্ষায়', 'Not approved': 'অনুমোদিত হয়নি',
    'Have something to sell?': 'বিক্রি করার মতো কিছু আছে?', 'List it free, no account needed. Live after a quick check.': 'বিনামূল্যে লিস্ট করুন, অ্যাকাউন্ট লাগবে না। দ্রুত যাচাইয়ের পর চালু হবে।',
    'Your orders, wishlist and addresses will appear here once checkout opens.': 'চেকআউট চালু হলে আপনার অর্ডার, পছন্দের তালিকা ও ঠিকানা এখানে দেখা যাবে।', 'Add': 'যোগ করুন',
    'Seller Center': 'সেলার সেন্টার',
    // sell (one-time sellers)
    'No account needed. Fill in three short steps. We check every listing, then buyers contact you. Choose a free listing or make it Featured to get more buyers.': 'অ্যাকাউন্ট লাগবে না। তিনটি ছোট ধাপ পূরণ করুন। আমরা প্রতিটি লিস্টিং যাচাই করি, তারপর ক্রেতারা আপনার সাথে যোগাযোগ করেন। ফ্রি লিস্টিং বেছে নিন, অথবা আরও ক্রেতা পেতে ফিচার্ড করুন।',
    'What are you selling?': 'আপনি কী বিক্রি করছেন?', 'e.g. iPhone 12, 128GB, Blue': 'যেমন: iPhone 12, 128GB, নীল', 'Choose a category': 'একটি ক্যাটাগরি বাছুন', 'Price': 'দাম',
    'Price is negotiable': 'দরদাম করা যাবে', 'Unused, in its box': 'অব্যবহৃত, বাক্সসহ', 'Pre-owned or refurbished': 'ব্যবহৃত বা রিফার্বিশড', 'About the item': 'পণ্য সম্পর্কে',
    "Condition, how long used, what's included, reason for selling…": 'অবস্থা, কতদিন ব্যবহার করেছেন, সাথে কী কী আছে, বিক্রির কারণ…', 'Photos': 'ছবি', 'Add photos': 'ছবি যোগ করুন', 'Add more': 'আরও যোগ করুন',
    'Up to 5 clear photos. The first one is the main photo buyers see.': 'সর্বোচ্চ ৫টি পরিষ্কার ছবি। প্রথম ছবিটিই ক্রেতারা প্রধান ছবি হিসেবে দেখবেন।', 'Main photo': 'প্রধান ছবি', 'Main': 'প্রধান', 'Remove photo': 'ছবি সরান',
    'Your contact': 'আপনার যোগাযোগ', 'Area': 'এলাকা', 'Type your area': 'আপনার এলাকা লিখুন', 'Choose district first': 'আগে জেলা বাছুন', 'Pick from the list or type a new one': 'তালিকা থেকে বাছুন অথবা নতুন লিখুন',
    'Same as mobile': 'মোবাইল নম্বরের মতোই', '(optional)': '(ঐচ্ছিক)', '(optional, kept private)': '(ঐচ্ছিক, গোপন থাকবে)', '(optional, shown to buyers)': '(ঐচ্ছিক, ক্রেতারা দেখবেন)',
    'Your phone number stays private': 'আপনার ফোন নম্বর গোপন থাকবে', 'Your number stays private. Buyers message you on RGBKart; we only use your number to reach you about your listing.': 'আপনার নম্বর গোপন থাকবে। ক্রেতারা RGBKart-এ মেসেজ দেবেন; আমরা শুধু আপনার লিস্টিং নিয়ে যোগাযোগ করতে নম্বরটি ব্যবহার করি।',
    'Listing type': 'লিস্টিংয়ের ধরন', 'Free listing': 'ফ্রি লিস্টিং', 'Keep it free': 'ফ্রি রাখুন', 'MORE BUYERS': 'আরও ক্রেতা', 'Normal position in search': 'সার্চে সাধারণ অবস্থান',
    'Buyers send you messages on RGBKart': 'ক্রেতারা RGBKart-এ আপনাকে মেসেজ দেবেন', "Buyers can't call, WhatsApp or email you": 'ক্রেতারা আপনাকে কল, হোয়াটসঅ্যাপ বা ইমেইল করতে পারবেন না',
    'Buyers can call, WhatsApp, email or message you': 'ক্রেতারা আপনাকে কল, হোয়াটসঅ্যাপ, ইমেইল বা মেসেজ করতে পারবেন', 'How long to be Featured': 'কতদিন ফিচার্ড থাকবে', 'Featured duration': 'ফিচার্ডের মেয়াদ',
    'Once Featured starts, buyers see your mobile, WhatsApp and email on this listing.': 'ফিচার্ড শুরু হলে ক্রেতারা এই লিস্টিংয়ে আপনার মোবাইল, হোয়াটসঅ্যাপ ও ইমেইল দেখতে পাবেন।',
    'Leave this empty': 'এটি খালি রাখুন', 'Submit for approval': 'অনুমোদনের জন্য পাঠান', 'RGBKart checks each listing, usually within 24 hours. Selling often?': 'RGBKart প্রতিটি লিস্টিং সাধারণত ২৪ ঘণ্টার মধ্যে যাচাই করে। প্রায়ই বিক্রি করেন?',
    'Open a free shop': 'ফ্রি দোকান খুলুন', 'Your listings': 'আপনার লিস্টিং', 'Sell another item': 'আরেকটি পণ্য বিক্রি করুন', 'Thanks! Your listing is waiting for approval.': 'ধন্যবাদ! আপনার লিস্টিং অনুমোদনের অপেক্ষায় আছে।',
    "We'll check it soon. Once approved, buyers can message you on RGBKart. Check Messages on this phone or browser.": 'আমরা শিগগিরই যাচাই করব। অনুমোদনের পর ক্রেতারা RGBKart-এ আপনাকে মেসেজ দিতে পারবেন। এই ফোন বা ব্রাউজারে মেসেজ দেখুন।',
    "We'll check it soon. Once approved, buyers can see it and contact you. Keep using this phone or browser to manage your listings.": 'আমরা শিগগিরই যাচাই করব। অনুমোদনের পর ক্রেতারা এটি দেখে আপনার সাথে যোগাযোগ করতে পারবেন। লিস্টিং পরিচালনা করতে এই ফোন বা ব্রাউজারই ব্যবহার করুন।',
    'Waiting for approval': 'অনুমোদনের অপেক্ষায়', 'Live': 'চালু', 'View': 'দেখুন', 'Mark as sold': 'বিক্রি হয়েছে চিহ্নিত করুন', 'Marked as sold': 'বিক্রি হয়েছে চিহ্নিত', 'Delete': 'মুছুন', 'Deleted': 'মুছে ফেলা হয়েছে',
    'Tap again to delete': 'মুছতে আবার চাপুন', 'Sold / hidden': 'বিক্রি হয়েছে / লুকানো', 'negotiable': 'দরদাম করা যাবে', 'Reason: ': 'কারণ: ', 'Name in Bangla (optional)': 'বাংলায় নাম (ঐচ্ছিক)', '★ Make Featured': '★ ফিচার্ড করুন', '★ Featured: waiting for payment': '★ ফিচার্ড: পেমেন্টের অপেক্ষায়', '★ Payment sent: checking': '★ পেমেন্ট পাঠানো হয়েছে: যাচাই চলছে',
    '★ Featured until ': '★ ফিচার্ড থাকবে ', 'Payment not accepted: ': 'পেমেন্ট গ্রহণ করা হয়নি: ', ' Please check and pay again.': ' অনুগ্রহ করে দেখে আবার পেমেন্ট করুন।', 'Not sent': 'পাঠানো হয়নি',
    'Featured requested. Our team will contact you about payment.': 'ফিচার্ডের অনুরোধ করা হয়েছে। পেমেন্টের বিষয়ে আমাদের টিম যোগাযোগ করবে।', 'Featured request cancelled': 'ফিচার্ডের অনুরোধ বাতিল হয়েছে',
    'Featured is already requested for this listing.': 'এই লিস্টিংয়ের জন্য আগেই ফিচার্ডের অনুরোধ করা হয়েছে।', '💬 Message': '💬 মেসেজ', '💬 Messages': '💬 মেসেজ', '📞 Call': '📞 কল', '🔔 Alerts': '🔔 নোটিফিকেশন',
    'Write what you are selling.': 'আপনি কী বিক্রি করছেন লিখুন।', 'Choose a category.': 'একটি ক্যাটাগরি বাছুন।', 'Enter a price.': 'দাম লিখুন।', 'Add at least one photo.': 'অন্তত একটি ছবি দিন।',
    'Enter your name.': 'আপনার নাম লিখুন।', 'Enter a valid mobile number, like 01711000000.': '01711000000-এর মতো সঠিক মোবাইল নম্বর দিন।', 'Choose your district.': 'আপনার জেলা বাছুন।',
    'Check the WhatsApp number.': 'হোয়াটসঅ্যাপ নম্বরটি দেখে নিন।', 'Check the email address.': 'ইমেইল ঠিকানাটি দেখে নিন।', 'Use JPG, PNG or WebP photos.': 'JPG, PNG বা WebP ছবি দিন।',
    'A photo is too large. Use smaller photos.': 'একটি ছবি খুব বড়। ছোট ছবি দিন।', 'No internet connection. Check your connection and try again.': 'ইন্টারনেট সংযোগ নেই। সংযোগ দেখে আবার চেষ্টা করুন।',
    "This listing couldn't be saved. Please reload the page and try again.": 'লিস্টিংটি সংরক্ষণ করা যায়নি। পেজটি রিলোড করে আবার চেষ্টা করুন।',
    "Selling without an account isn't switched on yet. Please try again later.": 'অ্যাকাউন্ট ছাড়া বিক্রি এখনো চালু হয়নি। পরে আবার চেষ্টা করুন।', 'Preview': 'প্রিভিউ',
    'You are signed in as a customer. To sell one item, ': 'আপনি ক্রেতা হিসেবে সাইন ইন করেছেন। একটি পণ্য বিক্রি করতে, ', 'sign out': 'সাইন আউট করুন',
    ' first, or open a shop from the sign-in page.': ' আগে, অথবা সাইন-ইন পেজ থেকে দোকান খুলুন।', 'You have a shop on RGBKart. Add products from ': 'RGBKart-এ আপনার দোকান আছে। পণ্য যোগ করুন ',
    // payments (pay.js)
    'Pay with': 'পেমেন্ট করুন', 'Loading payment options…': 'পেমেন্টের অপশন লোড হচ্ছে…', 'Copy': 'কপি', 'Agent number': 'এজেন্ট নম্বর', 'Transaction ID (TrxID)': 'ট্রানজেকশন আইডি (TrxID)',
    'Personal number: use “Send Money”': 'পার্সোনাল নম্বর: “সেন্ড মানি” ব্যবহার করুন', 'Merchant number: use “Payment”': 'মার্চেন্ট নম্বর: “পেমেন্ট” ব্যবহার করুন',
    'Then enter your number and the TrxID from the confirmation message below.': 'তারপর নিচে আপনার নম্বর ও কনফার্মেশন মেসেজের TrxID লিখুন।',
    'Each TrxID can be used only once. Featured or your ad starts as soon as we confirm the payment.': 'প্রতিটি TrxID একবারই ব্যবহার করা যায়। পেমেন্ট নিশ্চিত হলেই ফিচার্ড বা আপনার বিজ্ঞাপন শুরু হবে।',
    'Enter the mobile number you paid from, like 01711000000.': 'যে নম্বর থেকে পেমেন্ট করেছেন তা লিখুন, যেমন 01711000000।', 'Enter the Transaction ID (TrxID) from your payment message. It has 6 to 20 letters and numbers.': 'পেমেন্ট মেসেজের ট্রানজেকশন আইডি (TrxID) লিখুন। এতে ৬ থেকে ২০টি অক্ষর ও সংখ্যা থাকে।',
    "Payment numbers aren't set up yet. Our team will contact you about payment.": 'পেমেন্ট নম্বর এখনো ঠিক করা হয়নি। পেমেন্টের বিষয়ে আমাদের টিম যোগাযোগ করবে।', "Payments aren't switched on yet. Please try again later.": 'পেমেন্ট এখনো চালু হয়নি। পরে আবার চেষ্টা করুন।',
    // brand tagline in Bangla mode
    'Your Online Marketplace': 'আপনার অনলাইন মার্কেটপ্লেস',
    'Sign in to see your account': 'অ্যাকাউন্ট দেখতে সাইন ইন করুন', 'Save your addresses, follow your orders and keep your wishlist in one place.': 'ঠিকানা সংরক্ষণ, অর্ডার ট্র্যাক ও পছন্দের তালিকা — সব এক জায়গায়।',
    'Edit profile': 'প্রোফাইল সম্পাদনা', 'Save': 'সংরক্ষণ করুন', 'Cancel': 'বাতিল', 'Saved': 'সংরক্ষিত হয়েছে', 'Recent orders': 'সাম্প্রতিক অর্ডার', 'See all orders →': 'সব অর্ডার দেখুন →',
    'No orders yet. When you place an order, you can track it here.': 'এখনো কোনো অর্ডার নেই। অর্ডার দিলে এখানে ট্র্যাক করতে পারবেন।', 'Go to cart →': 'কার্টে যান →',
    'Saved addresses': 'সংরক্ষিত ঠিকানা', '+ Add address': '+ ঠিকানা যোগ করুন', 'Address': 'ঠিকানা', 'Default': 'ডিফল্ট', 'Edit': 'সম্পাদনা', 'Make default': 'ডিফল্ট করুন',
    "Saved addresses aren't switched on yet.": 'সংরক্ষিত ঠিকানা এখনো চালু হয়নি।', 'No saved addresses yet. Add one, or tick "Save this address" at checkout.': 'এখনো কোনো ঠিকানা সংরক্ষিত নেই। একটি যোগ করুন, অথবা চেকআউটে "এই ঠিকানা সংরক্ষণ করুন" টিক দিন।',
    'Label (e.g. Home, Office)': 'নাম (যেমন: বাসা, অফিস)', 'Home': 'হোম', 'Use as my default address': 'এটি আমার ডিফল্ট ঠিকানা', 'Save address': 'ঠিকানা সংরক্ষণ করুন', 'Address saved': 'ঠিকানা সংরক্ষিত হয়েছে',
    'Password': 'পাসওয়ার্ড', 'Change password': 'পাসওয়ার্ড বদলান', 'Password changed': 'পাসওয়ার্ড বদলানো হয়েছে',
    'Deliver to:': 'ডেলিভারি ঠিকানা:', '+ New address': '+ নতুন ঠিকানা', 'Save this address to my account': 'এই ঠিকানা আমার অ্যাকাউন্টে সংরক্ষণ করুন',
    'Store pickup available': 'দোকান থেকে সংগ্রহ করা যায়', 'This shop is on holiday and not taking orders right now.': 'এই দোকান এখন ছুটিতে, অর্ডার নিচ্ছে না।',
    'About the shop': 'দোকান সম্পর্কে', 'Search this shop': 'এই দোকানে খুঁজুন', 'Featured first': 'ফিচার্ড আগে', 'This shop has no products yet.': 'এই দোকানে এখনো কোনো পণ্য নেই।',
    "This shop isn't available": 'এই দোকানটি পাওয়া যাচ্ছে না', 'It may be closed or still waiting for approval.': 'হয়তো বন্ধ আছে বা এখনো অনুমোদনের অপেক্ষায়।',
    'Browse all products': 'সব পণ্য দেখুন', 'Visit shop →': 'দোকানে যান →', 'Previous shops': 'আগের দোকানগুলো', 'Next shops': 'পরের দোকানগুলো', 'Top Shops': 'সেরা দোকান', '🏪 Visit shop →': '🏪 দোকানে যান →', 'See all products from this seller →': 'এই বিক্রেতার সব পণ্য দেখুন →', 'Red & Green Basket, RGBKart home': 'রেড অ্যান্ড গ্রিন বাস্কেট, RGBKart হোম', 'Show': 'দেখুন',
    'RGBKart Categories': 'ক্যাটাগরি | RGBKart', 'RGBKart Sign In': 'সাইন ইন | RGBKart', 'RGBKart Products': 'পণ্য | RGBKart', 'RGBKart Product': 'পণ্য | RGBKart',
    '✓ Verified shop': '✓ যাচাইকৃত দোকান', "RGBKart checked this shop's ID or trade licence": 'RGBKart এই দোকানের পরিচয়পত্র বা ট্রেড লাইসেন্স যাচাই করেছে',
    // returns (0036)
    'Arrived damaged or broken': 'ভাঙা বা ক্ষতিগ্রস্ত অবস্থায় এসেছে', 'Wrong item or wrong size/colour sent': 'ভুল পণ্য বা ভুল সাইজ/রং পাঠানো হয়েছে', 'Not as described or shown': 'বর্ণনা বা ছবির সাথে মিল নেই',
    'Parts or accessories missing': 'যন্ত্রাংশ বা অ্যাকসেসরিজ নেই', 'Size or fit is not right': 'সাইজ বা মাপ ঠিক হয়নি', 'Poor quality or not working': 'মান খারাপ বা কাজ করে না', 'Changed my mind': 'মত বদলেছি',
    'Return requested: waiting for the shop': 'ফেরতের অনুরোধ করা হয়েছে: দোকানের অপেক্ষায়', 'Return accepted: the shop will contact you to collect it': 'ফেরত গ্রহণ করা হয়েছে: দোকান পণ্য নিতে যোগাযোগ করবে',
    'Return declined by the shop': 'দোকান ফেরত নেয়নি', 'Return completed: the shop received the item': 'ফেরত সম্পন্ন: দোকান পণ্য পেয়েছে', 'Return request cancelled': 'ফেরতের অনুরোধ বাতিল',
    'Shop: ': 'দোকান: ', 'Cancel return request': 'ফেরতের অনুরোধ বাতিল করুন', 'No returns for this item': 'এই পণ্য ফেরতযোগ্য নয়', 'How many': 'কয়টি', 'Choose a reason…': 'কারণ বেছে নিন…',
    'What do you want?': 'আপনি কী চান?', 'Money back (refund)': 'টাকা ফেরত', 'Exchange for another one': 'বদলে আরেকটি', 'Tell the shop what is wrong (helps them decide quickly)': 'কী সমস্যা দোকানকে জানান (দ্রুত সিদ্ধান্তে সাহায্য করবে)',
    'Photos (up to 3)': 'ছবি (সর্বোচ্চ ৩টি)', 'Photos (up to 3, recommended for damaged or wrong items)': 'ছবি (সর্বোচ্চ ৩টি, ভাঙা বা ভুল পণ্যের জন্য দিন)', 'Send return request': 'ফেরতের অনুরোধ পাঠান', 'Sending…': 'পাঠানো হচ্ছে…',
    'Please tell the shop what is wrong': 'কী সমস্যা দোকানকে লিখুন', 'Each photo must be under 5 MB': 'প্রতিটি ছবি ৫ MB-এর কম হতে হবে', 'Return request sent to the shop': 'ফেরতের অনুরোধ দোকানে পাঠানো হয়েছে',
    'The shop checks your request and contacts you to collect the item. Refunds and exchanges are settled directly with the shop (RGBKart does not hold money).': 'দোকান আপনার অনুরোধ দেখে পণ্য নিতে যোগাযোগ করবে। টাকা ফেরত বা বদল সরাসরি দোকানের সাথে হবে (RGBKart টাকা রাখে না)।',
    'You already asked to return this item': 'এই পণ্য ফেরতের অনুরোধ আগেই করেছেন', 'This return can no longer be cancelled': 'এই ফেরতের অনুরোধ আর বাতিল করা যাবে না',
    'Your return was accepted': 'আপনার ফেরত গ্রহণ করা হয়েছে', 'Your return was declined': 'আপনার ফেরত গ্রহণ করা হয়নি', 'The shop received your return': 'দোকান আপনার ফেরত পণ্য পেয়েছে',
    // coupons (0033)
    'Coupon code': 'কুপন কোড', 'Apply': 'প্রয়োগ করুন', 'This coupon code is not valid for this shop': 'এই কুপন কোডটি এই দোকানে চলবে না', 'This coupon has expired': 'এই কুপনের মেয়াদ শেষ',
    'This coupon has been fully used': 'এই কুপন আর ব্যবহার করা যাবে না', 'You have already used this coupon': 'আপনি এই কুপন আগেই ব্যবহার করেছেন', 'Type a coupon code': 'কুপন কোড লিখুন',
    // questions (0032)
    'Questions & answers': 'প্রশ্ন ও উত্তর', 'Guest': 'অতিথি', 'Seller': 'বিক্রেতা', 'Waiting for the seller to answer': 'বিক্রেতার উত্তরের অপেক্ষায়',
    'Write your answer. Everyone can see it.': 'উত্তর লিখুন। সবাই দেখতে পাবেন।', 'Your answer': 'আপনার উত্তর', 'Save answer': 'উত্তর সংরক্ষণ করুন', 'Send answer': 'উত্তর পাঠান',
    'Please write your answer': 'উত্তর লিখুন', 'Edit answer': 'উত্তর বদলান', 'Ask the seller about this product: size, colour, warranty, delivery…': 'পণ্যটি নিয়ে বিক্রেতাকে প্রশ্ন করুন: সাইজ, রং, ওয়ারেন্টি, ডেলিভারি…',
    'Your question': 'আপনার প্রশ্ন', 'Ask question': 'প্রশ্ন করুন', 'Please write your question': 'প্রশ্ন লিখুন',
    'Question sent. You will get an alert when the seller answers.': 'প্রশ্ন পাঠানো হয়েছে। বিক্রেতা উত্তর দিলে নোটিফিকেশন পাবেন।',
    'Answers are shown to everyone. Please do not write your phone number here.': 'উত্তর সবাই দেখতে পান। এখানে আপনার ফোন নম্বর লিখবেন না।',
    "This is your product. Answer buyers' questions here; answers are shown to everyone.": 'এটি আপনার পণ্য। ক্রেতাদের প্রশ্নের উত্তর এখানে দিন; উত্তর সবাই দেখতে পান।',
    'Answered': 'উত্তর দেওয়া হয়েছে', 'No questions yet.': 'এখনো কোনো প্রশ্ন নেই।', 'No questions yet. Be the first to ask.': 'এখনো কোনো প্রশ্ন নেই। প্রথম প্রশ্নটি করুন।', 'Your questions': 'আপনার প্রশ্ন',
    'The seller answered your question': 'বিক্রেতা আপনার প্রশ্নের উত্তর দিয়েছেন', 'You have already asked this question': 'এই প্রশ্নটি আগেই করেছেন',
    'You have asked many questions today. Please try again tomorrow.': 'আজ অনেক প্রশ্ন করেছেন। কাল আবার চেষ্টা করুন।', 'You cannot ask a question about your own product': 'নিজের পণ্য নিয়ে প্রশ্ন করা যায় না',
    'Please keep the question under 500 letters': 'প্রশ্ন ৫০০ অক্ষরের মধ্যে রাখুন',
    'Free listings cannot share a phone number, email or link in answers. Buyers can message you on RGBKart, or make the listing Featured to show your contact.': 'ফ্রি বিজ্ঞাপনের উত্তরে ফোন নম্বর, ইমেইল বা লিংক দেওয়া যায় না। ক্রেতারা RGBKart-এ মেসেজ করতে পারেন, অথবা যোগাযোগ দেখাতে বিজ্ঞাপনটি ফিচার্ড করুন।',
    // reports (0030)
    '⚑ Report this product': '⚑ পণ্যটি রিপোর্ট করুন', '⚑ Report this shop': '⚑ দোকানটি রিপোর্ট করুন', 'Report this product': 'পণ্যটি রিপোর্ট করুন', 'Report this shop': 'দোকানটি রিপোর্ট করুন',
    'Tell RGBKart staff what is wrong. The seller will not see your name.': 'কী সমস্যা RGBKart টিমকে জানান। বিক্রেতা আপনার নাম দেখতে পাবেন না।',
    'Reason': 'কারণ', 'Details': 'বিস্তারিত', 'Your phone or email': 'আপনার ফোন বা ইমেইল', 'Send report': 'রিপোর্ট পাঠান', 'Close': 'বন্ধ করুন',
    'Fake or copy product': 'নকল বা কপি পণ্য', 'Scam or fraud (asks for advance money, fake payment…)': 'প্রতারণা (অগ্রিম টাকা চায়, ভুয়া পেমেন্ট…)',
    'Ordered but never delivered': 'অর্ডার করেছি কিন্তু ডেলিভারি পাইনি', 'Wrong price, photos or information': 'ভুল দাম, ছবি বা তথ্য', 'Item not allowed for sale': 'বিক্রি নিষিদ্ধ পণ্য',
    'Rude or offensive': 'অভদ্র বা আপত্তিকর', 'Spam or repeated listing': 'স্প্যাম বা একই পণ্য বারবার', 'Something else': 'অন্য কিছু',
    'What happened? Order number, dates, what the seller said… (helps us check faster)': 'কী হয়েছে? অর্ডার নম্বর, তারিখ, বিক্রেতা কী বলেছেন… (দ্রুত যাচাইয়ে সাহায্য করবে)',
    'Your phone or email (optional, if we need to ask you)': 'আপনার ফোন বা ইমেইল (ঐচ্ছিক, প্রয়োজনে যোগাযোগের জন্য)', 'Please choose a reason.': 'একটি কারণ বেছে নিন।',
    'Please tell us what is wrong': 'কী সমস্যা তা লিখুন', 'Thank you. Our team will check it.': 'ধন্যবাদ। আমাদের টিম বিষয়টি দেখবে।',
    'If you placed an order, you can also call the shop or cancel it from My orders.': 'অর্ডার করে থাকলে দোকানে ফোন করতে পারেন অথবা আমার অর্ডার থেকে বাতিল করতে পারেন।',
    'You have already reported this. Our team is checking it.': 'আপনি এটি আগেই রিপোর্ট করেছেন। আমাদের টিম দেখছে।', 'You cannot report your own listing': 'নিজের পণ্য রিপোর্ট করা যায় না',
    'You have sent many reports today. Please try again tomorrow.': 'আজ অনেক রিপোর্ট পাঠিয়েছেন। কাল আবার চেষ্টা করুন।', 'Something went wrong. Please try again.': 'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।',
    'Thank you: we acted on your report': 'ধন্যবাদ: আপনার রিপোর্টের ভিত্তিতে ব্যবস্থা নেওয়া হয়েছে', 'We checked your report': 'আমরা আপনার রিপোর্ট যাচাই করেছি',
    // reviews & ratings (0029)
    'Your rating': 'আপনার রেটিং', 'Poor': 'খারাপ', 'Fair': 'মোটামুটি', 'Good': 'ভালো', 'Very good': 'খুব ভালো', 'Excellent': 'চমৎকার',
    'How was this order?': 'অর্ডারটি কেমন ছিল?', 'Your stars help other shoppers choose good shops.': 'আপনার রেটিং অন্য ক্রেতাদের ভালো দোকান বেছে নিতে সাহায্য করে।',
    '★ Rate this order': '★ অর্ডারটি রেটিং দিন', 'Rate this order': 'অর্ডারটি রেটিং দিন', 'Your rating for the shop: ': 'দোকানের জন্য আপনার রেটিং: ',
    'The shop replied: ': 'দোকানের উত্তর: ', 'Change my review': 'রিভিউ বদলান', 'Your review': 'আপনার রিভিউ', '(can no longer be changed)': '(আর বদলানো যাবে না)',
    'What did you like or not like about this product? (optional)': 'পণ্যটির কী ভালো লেগেছে বা লাগেনি? (ঐচ্ছিক)',
    'How was the shop: packing, speed, behaviour? (optional)': 'দোকানটি কেমন ছিল: প্যাকিং, গতি, ব্যবহার? (ঐচ্ছিক)',
    'Send review': 'রিভিউ পাঠান', 'Please give the shop 1 to 5 stars.': 'দোকানকে ১ থেকে ৫ স্টার দিন।', 'Thank you for your review!': 'রিভিউয়ের জন্য ধন্যবাদ!',
    'Only buyers who received the order can review. Your first name and the first letter of your last name are shown with the review.': 'শুধু অর্ডার হাতে পাওয়া ক্রেতারাই রিভিউ দিতে পারেন। রিভিউয়ের সাথে আপনার নামের প্রথম অংশ ও পদবির প্রথম অক্ষর দেখানো হবে।',
    'Rate the products (optional)': 'পণ্যগুলোর রেটিং দিন (ঐচ্ছিক)', 'Not now': 'এখন না', 'Customer reviews': 'ক্রেতাদের রিভিউ', 'Shop reviews': 'দোকানের রিভিউ',
    'No reviews yet. Buyers can rate this product after their order is delivered.': 'এখনো কোনো রিভিউ নেই। অর্ডার হাতে পাওয়ার পর ক্রেতারা এই পণ্যের রেটিং দিতে পারেন।',
    'No reviews yet. Buyers can rate the shop after their order is delivered.': 'এখনো কোনো রিভিউ নেই। অর্ডার হাতে পাওয়ার পর ক্রেতারা দোকানের রেটিং দিতে পারেন।',
    '✓ Verified buyer': '✓ যাচাইকৃত ক্রেতা', 'Reply from the shop': 'দোকানের উত্তর', 'No reviews with these stars.': 'এই স্টারের কোনো রিভিউ নেই।',
    'Top rated': 'সেরা রেটিং', '★ 4 & up': '★ ৪ ও তার বেশি', 'The shop replied to your review': 'দোকান আপনার রিভিউয়ের উত্তর দিয়েছে',
    'You can rate an order after it is delivered': 'অর্ডার ডেলিভারি হওয়ার পর রেটিং দেওয়া যাবে', 'Choose 1 to 5 stars': '১ থেকে ৫ স্টার বেছে নিন',
    'Reviews can be written up to 90 days after delivery': 'ডেলিভারির ৯০ দিনের মধ্যে রিভিউ লেখা যায়', 'Reviews can be changed for 30 days after writing': 'লেখার ৩০ দিনের মধ্যে রিভিউ বদলানো যায়',
    'Please keep the review under 1000 letters': 'রিভিউ ১০০০ অক্ষরের মধ্যে রাখুন',
  };
  // 64 districts
  const DIST = { Dhaka: 'ঢাকা', Faridpur: 'ফরিদপুর', Gazipur: 'গাজীপুর', Gopalganj: 'গোপালগঞ্জ', Kishoreganj: 'কিশোরগঞ্জ', Madaripur: 'মাদারীপুর', Manikganj: 'মানিকগঞ্জ', Munshiganj: 'মুন্সীগঞ্জ',
    Narayanganj: 'নারায়ণগঞ্জ', Narsingdi: 'নরসিংদী', Rajbari: 'রাজবাড়ী', Shariatpur: 'শরীয়তপুর', Tangail: 'টাঙ্গাইল', Chattogram: 'চট্টগ্রাম', Bandarban: 'বান্দরবান', Brahmanbaria: 'ব্রাহ্মণবাড়িয়া',
    Chandpur: 'চাঁদপুর', "Cox's Bazar": 'কক্সবাজার', Cumilla: 'কুমিল্লা', Feni: 'ফেনী', Khagrachhari: 'খাগড়াছড়ি', Lakshmipur: 'লক্ষ্মীপুর', Noakhali: 'নোয়াখালী', Rangamati: 'রাঙ্গামাটি',
    Rajshahi: 'রাজশাহী', Bogura: 'বগুড়া', 'Chapai Nawabganj': 'চাঁপাইনবাবগঞ্জ', Joypurhat: 'জয়পুরহাট', Naogaon: 'নওগাঁ', Natore: 'নাটোর', Pabna: 'পাবনা', Sirajganj: 'সিরাজগঞ্জ',
    Khulna: 'খুলনা', Bagerhat: 'বাগেরহাট', Chuadanga: 'চুয়াডাঙ্গা', Jashore: 'যশোর', Jhenaidah: 'ঝিনাইদহ', Kushtia: 'কুষ্টিয়া', Magura: 'মাগুরা', Meherpur: 'মেহেরপুর', Narail: 'নড়াইল', Satkhira: 'সাতক্ষীরা',
    Barishal: 'বরিশাল', Barguna: 'বরগুনা', Bhola: 'ভোলা', Jhalokathi: 'ঝালকাঠি', Patuakhali: 'পটুয়াখালী', Pirojpur: 'পিরোজপুর', Sylhet: 'সিলেট', Habiganj: 'হবিগঞ্জ', Moulvibazar: 'মৌলভীবাজার',
    Sunamganj: 'সুনামগঞ্জ', Rangpur: 'রংপুর', Dinajpur: 'দিনাজপুর', Gaibandha: 'গাইবান্ধা', Kurigram: 'কুড়িগ্রাম', Lalmonirhat: 'লালমনিরহাট', Nilphamari: 'নীলফামারী', Panchagarh: 'পঞ্চগড়',
    Thakurgaon: 'ঠাকুরগাঁও', Mymensingh: 'ময়মনসিংহ', Jamalpur: 'জামালপুর', Netrokona: 'নেত্রকোনা', Sherpur: 'শেরপুর' };
  Object.assign(D, DIST);
  // keys are matched without spaces at the ends
  for (const k of Object.keys(D)) { const t = k.replace(/\s+/g, ' ').trim(); if (t !== k) { D[t] = D[k].trim(); delete D[k]; } }

  // ---------------- texts with values: [English pattern, Bangla] — {x} is a value, numbers in it become Bangla digits ----------------
  const P = [
    ['{t} | RGBKart', '{t} | RGBKart'],
    ['Sale -{n}%', 'ছাড় -{n}%'], ['from {p}', '{p} থেকে'], ['All {n} →', 'সব {n}টি →'], ['{n} products', '{n}টি পণ্য'], ['{n} product', '{n}টি পণ্য'], ['{n} items', '{n}টি পণ্য'],
    ['Show more ({n} left)', 'আরও দেখুন ({n}টি বাকি)'], ['Results for “{q}”', '“{q}”-এর ফলাফল'], ['Results for “{q}” in {w}', '{w}-এ “{q}”-এর ফলাফল'], ['Search: {q}', 'খোঁজ: {q}'], ['Hide {c} sub-categories', '{c}-এর উপ-ক্যাটাগরি লুকান'], ['Show {c} sub-categories', '{c}-এর উপ-ক্যাটাগরি দেখুন'], ['Save: {t}', 'সংরক্ষণ করুন: {t}'], ['Remove from saved: {t}', 'সংরক্ষিত থেকে সরান: {t}'],
    ['Cart, {n} items', 'কার্ট, {n}টি পণ্য'], ['Cart, {n} item', 'কার্ট, {n}টি পণ্য'], ['Messages, {n} new', 'মেসেজ, {n}টি নতুন'], ['Alerts, {n} new', 'নোটিফিকেশন, {n}টি নতুন'],
    ['{a} categories and {b} sub-categories. Pick one to start browsing.', '{a}টি ক্যাটাগরি ও {b}টি উপ-ক্যাটাগরি। দেখা শুরু করতে একটি বাছুন।'],
    ['In stock ({n})', 'স্টকে আছে ({n})'], ['Only {n} left', 'মাত্র {n}টি বাকি'], ['Only {n} left in stock', 'স্টকে মাত্র {n}টি বাকি'],
    ['Place order · {p}', 'অর্ডার দিন · {p}'], ['Total {p}', 'মোট {p}'], ['Delivery from {s}', '{s} থেকে ডেলিভারি'], ['Checkout · {p}', 'চেকআউট · {p}'], ['Go to checkout · {p}', 'চেকআউটে যান · {p}'],
    ['This makes {n} orders, one for each shop. Each shop delivers and collects its own amount.', 'এতে {n}টি অর্ডার হবে, প্রতিটি দোকানের জন্য একটি। প্রতিটি দোকান নিজের পণ্য পৌঁছে দেবে ও নিজের টাকা নেবে।'],
    ['The shop will call you on {ph} to confirm. Pay {m} in cash when it arrives.', 'দোকান নিশ্চিত করতে {ph} নম্বরে কল দেবে। পণ্য পৌঁছালে {m} নগদ দিন।'],
    ['The shops will call you on {ph} to confirm. Pay {m} in cash when it arrives.', 'দোকানগুলো নিশ্চিত করতে {ph} নম্বরে কল দেবে। পণ্য পৌঁছালে {m} নগদ দিন।'],
    ['Please enter {x}.', 'অনুগ্রহ করে লিখুন: {x}।'],
    ['Cancelled by you: {r}', 'আপনি বাতিল করেছেন: {r}'], ['Cancelled by the shop: {r}', 'দোকান বাতিল করেছে: {r}'], ['Cancelled: {r}', 'বাতিল: {r}'], ['Cancelled by you', 'আপনি বাতিল করেছেন'], ['Cancelled by the shop', 'দোকান বাতিল করেছে'],
    ['Delivery: {d} · to {w}', 'ডেলিভারি: {d} · ঠিকানা {w}'], ['{n} min ago', '{n} মিনিট আগে'], ['{n} h ago', '{n} ঘণ্টা আগে'],
    ['Hi, about my RGBKart order {o}', 'আসসালামু আলাইকুম, আমার RGBKart অর্ডার {o} সম্পর্কে'],
    ['Preview only: this product is "{s}". Shoppers can\'t see it yet.', 'শুধু প্রিভিউ: এই পণ্যটি "{s}"। ক্রেতারা এখনো দেখতে পাচ্ছেন না।'],
    ['Pre-order · ships {d}', 'প্রি-অর্ডার · পাঠানো হবে {d}'], ['Pre-order · expected {d}', 'প্রি-অর্ডার · আসবে {d}'], ['{n}+ pieces', '{n}+ পিস'], ['{p} each', 'প্রতিটি {p}'],
    ['Seller is in {w}', 'বিক্রেতা আছেন {w}'], [' · {n} downloads', ' · {n} বার ডাউনলোড'], [' · link works {n} days', ' · লিংক {n} দিন চালু থাকবে'],
    ['Gift card code sent after payment · valid {n} months · use in {s}', 'পেমেন্টের পর গিফট কার্ড কোড পাঠানো হবে · {n} মাস মেয়াদ · {s}-এ ব্যবহারযোগ্য'], ['{n}% payment when ordering', 'অর্ডারের সময় {n}% পেমেন্ট'],
    ['since {n}', '{n} থেকে'], ['Hi, I\'m interested in "{t}" on RGBKart: {u}', 'আসসালামু আলাইকুম, RGBKart-এ "{t}" পণ্যটিতে আমি আগ্রহী: {u}'],
    ['Hi, is "{t}" still available?', 'আসসালামু আলাইকুম, "{t}" কি এখনো পাওয়া যাবে?'], ['Remove {t}', 'সরান: {t}'], ['Photo {n}', 'ছবি {n}'],
    ['Only {n} available', 'মাত্র {n}টি আছে'], ['From {s}', '{s} থেকে'], ['Items ({n})', 'পণ্য ({n})'],
    // alert titles (Alerts page)
    ['Order {o} is confirmed', 'অর্ডার {o} নিশ্চিত হয়েছে'], ['Order {o} is packed and ready to send', 'অর্ডার {o} প্যাক করা হয়েছে, পাঠানোর জন্য প্রস্তুত'], ['Order {o} is on the way', 'অর্ডার {o} পথে আছে'],
    ['Order {o} is delivered', 'অর্ডার {o} পৌঁছে গেছে'], ['Order {o} is cancelled', 'অর্ডার {o} বাতিল হয়েছে'], ['Order {o} placed with {s}', '{s}-এ অর্ডার {o} দেওয়া হয়েছে'],
    ['New order {o} · {p}', 'নতুন অর্ডার {o} · {p}'], ['Order {o} was cancelled by the customer', 'ক্রেতা অর্ডার {o} বাতিল করেছেন'], ['New message from {s}', '{s}-এর কাছ থেকে নতুন মেসেজ'],
    ['Payment received: Featured is now live', 'পেমেন্ট পাওয়া গেছে: ফিচার্ড চালু হয়েছে'], ['Payment received: your ad is now live', 'পেমেন্ট পাওয়া গেছে: আপনার বিজ্ঞাপন চালু হয়েছে'], ['Payment not accepted', 'পেমেন্ট গ্রহণ করা হয়নি'],
    ['Your listing is live: {t}', 'আপনার লিস্টিং চালু হয়েছে: {t}'], ['Listing not approved: {t}', 'লিস্টিং অনুমোদিত হয়নি: {t}'], ['Your shop {s} is approved', 'আপনার দোকান {s} অনুমোদিত হয়েছে'],
    ['Your shop {s} was not approved', 'আপনার দোকান {s} অনুমোদিত হয়নি'], ['Featured ends soon: {t}', 'ফিচার্ড শিগগিরই শেষ হবে: {t}'], ['Your ad ends soon: {t}', 'আপনার বিজ্ঞাপন শিগগিরই শেষ হবে: {t}'],
    ['{n} days', '{n} দিন'], ['{n} days Featured: ', '{n} দিন ফিচার্ড: '], ['Pay {p}', '{p} পেমেন্ট করুন'], ["Couldn't read {f}.", '{f} পড়া যায়নি।'],
    ['Price {p}. After you send the listing, pay by bKash, Nagad, Upay or Rocket from Your listings (Pay button) and enter the Transaction ID. Featured starts as soon as we confirm your payment (and approve the listing). Until then it shows as a free listing.',
     'দাম {p}। লিস্টিং পাঠানোর পর "আপনার লিস্টিং" থেকে (পেমেন্ট বাটন) বিকাশ, নগদ, উপায় বা রকেটে পেমেন্ট করে ট্রানজেকশন আইডি দিন। পেমেন্ট নিশ্চিত হলে (এবং লিস্টিং অনুমোদিত হলে) ফিচার্ড শুরু হবে। ততদিন এটি ফ্রি লিস্টিং হিসেবে দেখাবে।'],
    ['Page {n}', 'পৃষ্ঠা {n}'], ['Showing {a}–{b} of {n} products', '{n}টি পণ্যের মধ্যে {a}–{b} দেখানো হচ্ছে'],
    ['On RGBKart since {n}', '{n} থেকে RGBKart-এ'], ['Hi, I found your shop on RGBKart: {u}', 'আসসালামু আলাইকুম, RGBKart-এ আপনার দোকান দেখলাম: {u}'],
    ['★ {n} Featured', '★ {n}টি ফিচার্ড'],
    ['Coupon {c}', 'কুপন {c}'], ['↩ Return this item (until {d})', '↩ পণ্যটি ফেরত দিন ({d} পর্যন্ত)'], ['Return: {t}', 'ফেরত: {t}'], ['The return time for this item has ended ({n} days after delivery)', 'এই পণ্যের ফেরতের সময় শেষ (ডেলিভারির {n} দিন পর)'], ['Choose how many to return (1 to {n})', 'কয়টি ফেরত দেবেন বেছে নিন (১ থেকে {n})'], ['applied: you save {p}', 'প্রয়োগ হয়েছে: আপনি বাঁচালেন {p}'], ['Coupon code for {s}', '{s}-এর কুপন কোড'],
    ['This coupon needs an order of at least ৳{x} from this shop', 'এই কুপনের জন্য এই দোকান থেকে কমপক্ষে ৳{x}-এর অর্ডার লাগবে'], ['This coupon can be used from {d}', 'এই কুপন {d} থেকে ব্যবহার করা যাবে'],
    ['Waiting for your answer ({n})', 'আপনার উত্তরের অপেক্ষায় ({n})'], ['New question about {t}', '{t} নিয়ে নতুন প্রশ্ন'],
    ['Rated {a} out of 5', '৫-এর মধ্যে {a} রেটিং'], ['{n} stars', '{n} স্টার'], ['({n} review)', '({n}টি রিভিউ)'], ['({n} reviews)', '({n}টি রিভিউ)'], ['{n} review', '{n}টি রিভিউ'], ['{n} reviews', '{n}টি রিভিউ'], ['The shop: {s}', 'দোকান: {s}'],
    ['Customer since {d}', '{d} থেকে ক্রেতা'], ['{n} order', '{n}টি অর্ডার'], ['{n} orders', '{n}টি অর্ডার'], ['{n} item', '{n}টি পণ্য'], ['{n} new', '{n}টি নতুন'], ['You have {n} items in your cart.', 'আপনার কার্টে {n}টি পণ্য আছে।'], ['You have {n} item in your cart.', 'আপনার কার্টে {n}টি পণ্য আছে।'],
    ['Up to {n} photos.', 'সর্বোচ্চ {n}টি ছবি।'], ['Pick from {n} areas or type a new one', '{n}টি এলাকা থেকে বাছুন অথবা নতুন লিখুন'], ['I have paid {p}', 'আমি {p} পেমেন্ট করেছি'],
    ['Your {meth} number (you paid from)', 'আপনার {meth} নম্বর (যেটি থেকে পেমেন্ট করেছেন)'],
    ['✓ Payment sent ({meth}, TrxID {t}). Our team will check it soon, usually within a few hours.', '✓ পেমেন্ট পাঠানো হয়েছে ({meth}, TrxID {t})। আমাদের টিম শিগগিরই, সাধারণত কয়েক ঘণ্টার মধ্যে, যাচাই করবে।'],
  ];
  const PRE = P.map(([en, bn]) => {
    const names = [];
    // {n} {a} {b} = a number, {p} {m} = an amount in taka, anything else = any text
    const src = en.replace(/[.*+?^$()[\]\\|]/g, '\\$&').replace(/\\?\{(\w+)\\?\}/g, (_, k) => {
      names.push(k);
      return /^[nab]$/.test(k) ? '([0-9০-৯][0-9০-৯,.]*)' : /^[pm]$/.test(k) ? '(৳\\s?[0-9০-৯][0-9০-৯,.]*)' : '(.+?)';
    });
    return [new RegExp('^' + src + '$', 's'), names, bn];
  });
  // numbers and amounts ({n} {a} {b} {p} {m}) get Bangla digits; other values (names, search words, phone numbers) stay as they are
  const fill = (s, vars, raw) => s.replace(/\{(\w+)\}/g, (_, k) => vars[k] == null ? '' : (raw || !/^[nabpm]$/.test(k) ? String(vars[k]) : N(vars[k])));

  function tr(text) {
    if (lang !== 'bn' || !text) return text;
    const k = text.replace(/\s+/g, ' ').trim();
    if (!k || !/[A-Za-z]/.test(k)) return text;
    let r = D[k];
    if (r == null) {
      for (const [re, names, bn] of PRE) {
        const m = k.match(re); if (!m) continue;
        const v = {}; names.forEach((n, i) => { v[n] = tr(m[i + 1]); });
        r = fill(bn, v); break;
      }
    }
    if (r == null) return text;
    const lead = text.match(/^\s*/)[0], tail = text.match(/\s*$/)[0];
    return lead + r + tail;
  }

  // T('Show more ({n} left)', {n: 5}) — for texts built in page code
  function T(en, vars) {
    vars = vars || {};
    if (lang !== 'bn') return fill(en, vars, true);
    if (D[en] != null) return D[en];
    const p = P.find(x => x[0] === en);
    if (p) return fill(p[1], vars);
    return tr(fill(en, vars, true));
  }
  // L(row, 'name') → row.name_bn in Bangla mode when it exists
  const L = (row, f) => (row && lang === 'bn' && row[f + '_bn']) ? row[f + '_bn'] : (row ? row[f] : '');

  // ---------------- translate the page ----------------
  const ATTRS = ['placeholder', 'aria-label', 'title', 'alt'];
  const SKIP = 'script,style,textarea,code,[translate="no"]';
  function doText(n) {
    const p = n.parentElement; if (!p || p.closest(SKIP)) return;
    const v = n.nodeValue, t = tr(v); if (t !== v) n.nodeValue = t;
  }
  function doEl(e) {
    if (e.closest('[translate="no"]')) return;
    for (const a of ATTRS) { const v = e.getAttribute(a); if (v) { const t = tr(v); if (t !== v) e.setAttribute(a, t); } }
    if (e.tagName === 'INPUT' && (e.type === 'submit' || e.type === 'button') && e.value) { const t = tr(e.value); if (t !== e.value) e.value = t; }
  }
  function walk(root) {
    if (lang !== 'bn' || !root) return;
    if (root.nodeType === 3) return doText(root);
    if (root.nodeType !== 1) return;
    doEl(root);
    const it = document.createTreeWalker(root, NodeFilter.SHOW_ELEMENT | NodeFilter.SHOW_TEXT);
    for (let n = it.nextNode(); n; n = it.nextNode()) n.nodeType === 3 ? doText(n) : doEl(n);
  }
  function titleFix() { const t = tr(document.title); if (t !== document.title) document.title = t; }

  const CSS = `
    /* Bangla letters look smaller than Latin ones at the same size */
    html[lang="bn"] { font-size: 106.25%; }
    html[lang="bn"] body { line-height: 1.6; font-size: 1rem; }
    footer [data-lang-switch] { display: inline-flex; margin-right: 10px; vertical-align: middle; }
    .langbtn { flex: none; display: inline-flex; align-items: center; gap: 6px; border: 1.5px solid #00802B; color: #00802B; background: transparent; border-radius: 999px;
      padding: 5px 12px; font: 600 .86rem "Hind Siliguri", "Roboto", system-ui, sans-serif; cursor: pointer; white-space: nowrap; text-decoration: none; }
    .langbtn:hover { background: #00802B; color: #fff; }
    .langbtn .flag { width: 22px; height: 14px; flex: none; border-radius: 2px; box-shadow: 0 0 0 1px rgb(0 0 0 / .15); display: block; }
    .langbtn.on-dark .flag, footer .langbtn .flag { box-shadow: 0 0 0 1.5px rgb(255 255 255 / .85); }
    footer .langbtn, .on-dark .langbtn, .langbtn.on-dark { border-color: rgba(255,255,255,.6); color: #fff; }
    footer .langbtn:hover, .langbtn.on-dark:hover { background: #fff; color: #00802B; }
    @media (prefers-color-scheme: dark) { .langbtn { border-color: #49CC73; color: #49CC73; } }`;
  // Small flag pictures (drawn here, so they look the same on every phone and computer)
  let flagN = 0;
  const FLAG_BD = () => '<svg class="flag" viewBox="0 0 20 12" aria-hidden="true"><rect width="20" height="12" fill="#006A4E"/><circle cx="9" cy="6" r="4" fill="#F42A41"/></svg>';
  const FLAG_UK = () => { const k = 'uk' + (++flagN); return `<svg class="flag" viewBox="0 0 60 30" aria-hidden="true"><clipPath id="${k}t"><path d="M30,15 h30 v15 z v15 h-30 z h-30 v-15 z v-15 h30 z"/></clipPath>`
    + '<rect width="60" height="30" fill="#012169"/><path d="M0,0 L60,30 M60,0 L0,30" stroke="#fff" stroke-width="6"/>'
    + `<path d="M0,0 L60,30 M60,0 L0,30" clip-path="url(#${k}t)" stroke="#C8102E" stroke-width="4"/><path d="M30,0 v30 M0,15 h60" stroke="#fff" stroke-width="10"/><path d="M30,0 v30 M0,15 h60" stroke="#C8102E" stroke-width="6"/></svg>`; };
  function set(l) { try { localStorage.setItem(KEY, l); } catch (_) {} const u = new URL(location.href); u.searchParams.delete('lang'); location.replace(u.toString()); }
  // a button that switches to the other language
  function switcher(extraClass) {
    const b = document.createElement('button');
    b.type = 'button'; b.className = 'langbtn' + (extraClass ? ' ' + extraClass : ''); b.setAttribute('translate', 'no');
    b.innerHTML = lang === 'bn' ? FLAG_UK() + '<span lang="en">English</span>' : FLAG_BD() + '<span lang="bn">বাংলা</span>';
    b.setAttribute('aria-label', lang === 'bn' ? 'Switch to English' : 'বাংলায় দেখুন');
    b.onclick = () => set(lang === 'bn' ? 'en' : 'bn');
    return b;
  }
  // any element with data-lang-switch="extra-class" gets the button
  function mountSwitches() { document.querySelectorAll('[data-lang-switch]').forEach(x => { if (!x.querySelector('.langbtn')) x.append(switcher(x.dataset.langSwitch)); }); }
  const date = (t, opts) => new Date(t).toLocaleString(lang === 'bn' ? 'bn-BD' : 'en-GB', opts);

  function start() {
    if (!document.getElementById('langCss')) { const s = document.createElement('style'); s.id = 'langCss'; s.textContent = CSS; document.head.append(s); }
    mountSwitches();
    if (lang !== 'bn') return;
    document.documentElement.lang = 'bn';
    titleFix();
    walk(document.body);
    new MutationObserver(list => {
      for (const m of list) {
        if (m.type === 'childList') m.addedNodes.forEach(walk);
        else if (m.type === 'characterData') doText(m.target);
        else if (m.type === 'attributes') doEl(m.target);
      }
    }).observe(document.body, { childList: true, subtree: true, characterData: true, attributes: true, attributeFilter: ATTRS });
    const tt = document.querySelector('title'); if (tt) new MutationObserver(titleFix).observe(tt, { childList: true, characterData: true, subtree: true });
  }
  if (document.body) start(); else document.addEventListener('DOMContentLoaded', start);

  window.LANG = lang;
  window.T = T; window.L = L; window.N = N;
  window.RGBLang = { lang, set, switcher, mountSwitches, date, tr, walk, D, P };
})();
