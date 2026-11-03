<?php
// Product page with its search-engine and link-preview tags already in the HTML (3 Nov 2026).
// .htaccess sends product.html?id=… (and ?p=slug) here without changing the address. Facebook, WhatsApp and
// other link previews don't run JavaScript, so the title, description, canonical, robots, Open Graph and
// Product JSON-LD are written here, from public data only (publishable key, approved products).
// The rules are the same as site/seo-product.js (keep both in step); the page's JavaScript then updates the
// same tags in place. If Supabase can't be reached, the plain product.html is sent unchanged.
$SB   = 'https://qrzlsomuluglbslricaf.supabase.co';
$KEY  = 'sb_publishable_i-6QX7ObGzF4ykfrgkITsw_HnndqdNY';
$REST = "$SB/rest/v1";   // product data (photos stay on \$SB storage)
$SITE = '%%SITE%%';
$BRAND = 'DeshiBasket';

header('Content-Type: text/html; charset=utf-8');
header('Cache-Control: no-cache');
$html = @file_get_contents(__DIR__ . '/product.html');
if ($html === false) { http_response_code(500); exit('Page not found on the server.'); }

// ---------- helpers (same as seo-product.js) ----------
function seo_clean($s) { return trim(preg_replace('/\s+/u', ' ', (string)$s)); }
function seo_h($s) { return htmlspecialchars((string)$s, ENT_QUOTES, 'UTF-8'); }
function seo_len($s) { return mb_strlen($s, 'UTF-8'); }
function seo_taka($n) {
  $v = round((float)$n, 2);
  $parts = explode('.', (string)abs($v));
  $i = $parts[0]; $f = isset($parts[1]) ? $parts[1] : '';
  $last3 = substr($i, -3); $rest = substr($i, 0, -3);
  if ($rest !== '' && $rest !== false) $i = preg_replace('/\B(?=(\d{2})+(?!\d))/', ',', $rest) . ',' . $last3; else $i = $last3;
  return '৳' . ($v < 0 ? '-' : '') . $i . ($f !== '' ? '.' . $f : '');
}
function seo_cut($s, $max) {
  $s = seo_clean($s);
  if (seo_len($s) <= $max) return $s;
  $t = mb_substr($s, 0, $max - 1, 'UTF-8');
  $sp = mb_strrpos($t, ' ', 0, 'UTF-8');
  if ($sp !== false && $sp > $max * 0.6) $t = mb_substr($t, 0, $sp, 'UTF-8');
  return preg_replace('/[\s,;:.\-–·]+$/u', '', $t) . '…';
}
function seo_ended($s) { return (bool)preg_match('/[.!?…]$/u', $s); }
function seo_time($s) { return $s ? strtotime($s) : null; }
function seo_sale_on($p, $now) {
  if ($p['sale_price'] === null || (float)$p['sale_price'] <= 0) return false;
  if (!empty($p['sale_starts_at']) && seo_time($p['sale_starts_at']) > $now) return false;
  if (!empty($p['sale_ends_at']) && seo_time($p['sale_ends_at']) < $now) return false;
  return true;
}
function seo_active_vars($P) {
  return array_values(array_filter($P['product_variations'] ?: [], function ($v) { return !empty($v['is_active']); }));
}
function seo_prices($P, $now) {
  $vs = seo_active_vars($P);
  if ($P['product_type'] === 'variable' && $vs) return array_map(function ($v) { return (float)($v['sale_price'] ?: $v['price']); }, $vs);
  return [(float)(seo_sale_on($P, $now) ? $P['sale_price'] : $P['price'])];
}
function seo_availability($P) {
  $S = 'https://schema.org/';
  if (!empty($P['is_preorder'])) return $S . 'PreOrder';
  if (!empty($P['is_service']) || !empty($P['is_downloadable']) || !empty($P['is_gift_card'])) return $S . 'InStock';
  $back = !empty($P['backorders']) && $P['backorders'] !== 'no';
  $vs = seo_active_vars($P);
  if ($P['product_type'] === 'variable' && $vs) { $n = 0; foreach ($vs as $v) $n += max(0, (int)$v['stock']); }
  elseif (!empty($P['manage_stock'])) $n = (int)$P['stock'];
  else {
    if ($P['stock_status'] === 'out_of_stock') return $S . ($back ? 'BackOrder' : 'OutOfStock');
    return $S . ($P['stock_status'] === 'on_backorder' ? 'BackOrder' : 'InStock');
  }
  return $n > 0 ? $S . 'InStock' : $S . ($back ? 'BackOrder' : 'OutOfStock');
}
function seo_img($SB, $path) {
  return "$SB/storage/v1/object/public/product-images/" . str_replace('%2F', '/', rawurlencode($path));
}
function seo_fix($n) { return number_format((float)$n, 2, '.', ''); }

function seo_build($P, $opt) {
  global $BRAND;
  $now = $opt['now'];
  $site = rtrim($opt['site'], '/');
  $title = seo_clean($P['title']);
  $canonical = "$site/product.html?id=" . rawurlencode((string)$P['id']);
  $imgs = $P['product_images'] ?: [];
  usort($imgs, function ($a, $b) { return $a['sort_order'] <=> $b['sort_order']; });
  $imgs = array_map(function ($i) use ($opt) { return seo_img($opt['sb'], $i['storage_path']); }, $imgs);
  $ps = seo_prices($P, $now); $low = min($ps); $high = max($ps);
  $used = $P['listing_type'] === 'pre_owned';
  $shop = seo_clean($opt['shopName']);

  $words = seo_clean($P['short_description']);
  if ($words === '' || $words === seo_clean($P['title_bn']) || $words === $title) $words = seo_clean($P['description']);
  if ($title !== '' && mb_stripos($words, $title, 0, 'UTF-8') === 0) $words = seo_clean(preg_replace('/^[\s:–\-·,]+/u', '', mb_substr($words, seo_len($title), null, 'UTF-8')));
  $priceTxt = ($low != $high ? 'from ' : '') . seo_taka($low) . (!empty($P['price_negotiable']) ? ' (negotiable)' : '');
  $head = "$title $priceTxt" . ($shop !== '' ? " at $shop" : '') . ($used ? ' (pre-owned)' : '') . '.';
  $tail = !empty($P['contact_only']) ? "Contact the seller on $BRAND." : "Cash on Delivery on $BRAND.";
  $description = $head;
  $room = 160 - seo_len($head) - seo_len($tail) - 2;
  if ($words !== '' && $room >= 25) { $w = seo_cut($words, $room); $description .= ' ' . $w . (seo_ended($w) ? '' : '.'); }
  $description = seo_cut($description . ' ' . $tail, 160);

  $pageTitle = "$title | $BRAND";
  $cond = $used ? 'https://schema.org/UsedCondition' : 'https://schema.org/NewCondition';
  $avail = seo_availability($P);
  $seller = $shop !== '' ? ['@type' => 'Organization', 'name' => $shop] : null;
  if ($low != $high) {
    $offers = ['@type' => 'AggregateOffer', 'priceCurrency' => 'BDT', 'lowPrice' => seo_fix($low), 'highPrice' => seo_fix($high), 'offerCount' => count($ps),
      'availability' => $avail, 'itemCondition' => $cond, 'url' => $canonical, 'seller' => $seller];
  } else {
    $offers = ['@type' => 'Offer', 'priceCurrency' => 'BDT', 'price' => seo_fix($low), 'availability' => $avail, 'itemCondition' => $cond, 'url' => $canonical, 'seller' => $seller];
    if ($P['product_type'] !== 'variable' && seo_sale_on($P, $now) && !empty($P['sale_ends_at'])) $offers['priceValidUntil'] = substr($P['sale_ends_at'], 0, 10);
  }
  $offers = array_filter($offers, function ($v) { return $v !== null; });
  $ld = ['@context' => 'https://schema.org', '@type' => 'Product', 'name' => $title, 'url' => $canonical];
  $d = seo_cut($P['description'] ?: ($P['short_description'] ?: ''), 1000);
  if ($d !== '') $ld['description'] = $d;
  if (seo_clean($P['sku']) !== '') $ld['sku'] = seo_clean($P['sku']);
  if ($imgs) $ld['image'] = array_slice($imgs, 0, 10);
  $ld['itemCondition'] = $cond;
  if (!empty($opt['brand'])) $ld['brand'] = ['@type' => 'Brand', 'name' => seo_clean($opt['brand'])];
  $ld['offers'] = $offers;
  if ((int)$P['rating_count'] > 0 && (float)$P['rating_avg'] > 0)
    $ld['aggregateRating'] = ['@type' => 'AggregateRating', 'ratingValue' => number_format((float)$P['rating_avg'], 1, '.', ''), 'reviewCount' => (int)$P['rating_count'], 'bestRating' => '5', 'worstRating' => '1'];

  $availTxt = substr($avail, -7) === 'InStock' ? 'in stock' : (substr($avail, -8) === 'PreOrder' ? 'preorder' : (substr($avail, -9) === 'BackOrder' ? 'available for order' : 'out of stock'));
  return ['title' => $pageTitle, 'description' => $description, 'canonical' => $canonical,
    'robots' => $P['status'] === 'approved' ? 'index, follow, max-image-preview:large' : 'noindex, nofollow',
    'image' => $imgs ? $imgs[0] : null, 'imageAlt' => $title,
    'og' => ['og:type' => 'product', 'og:title' => $pageTitle, 'og:description' => $description, 'og:url' => $canonical,
      'product:price:amount' => seo_fix($low), 'product:price:currency' => 'BDT', 'product:condition' => $used ? 'used' : 'new', 'product:availability' => $availTxt],
    'twitter' => ['twitter:card' => 'summary_large_image', 'twitter:title' => $pageTitle, 'twitter:description' => $description],
    'ld' => $ld];
}

// Replace a tag in the page head (or remove it when $new is null); returns how many were found
function seo_swap(&$html, $pattern, $new) {
  $n = 0;
  $html = preg_replace_callback($pattern, function () use (&$n, $new) { $n++; return $n === 1 && $new !== null ? $new : ''; }, $html);
  return $n;
}
function seo_split($page) {   // only the <head> is ever changed
  $pos = stripos($page, '</head>');
  return $pos === false ? [$page, ''] : [substr($page, 0, $pos), substr($page, $pos)];
}
function seo_head($page, $s) {
  list($html, $body) = seo_split($page);
  seo_swap($html, '/<title>.*?<\/title>/s', '<title>' . seo_h($s['title']) . '</title>');
  $tags = [['name', 'description', $s['description']], ['name', 'robots', $s['robots']]];
  foreach ($s['og'] as $k => $v) $tags[] = ['property', $k, $v];
  foreach ($s['twitter'] as $k => $v) $tags[] = ['name', $k, $v];
  if ($s['image']) {
    $tags[] = ['property', 'og:image', $s['image']]; $tags[] = ['property', 'og:image:alt', $s['imageAlt']];
    $tags[] = ['property', 'og:image:width', null]; $tags[] = ['property', 'og:image:height', null];
    $tags[] = ['name', 'twitter:image', $s['image']];
  }
  $add = '';
  foreach ($tags as list($attr, $key, $val)) {
    $tag = $val === null ? null : '<meta ' . $attr . '="' . $key . '" content="' . seo_h($val) . '">';
    $found = seo_swap($html, '/<meta ' . $attr . '="' . preg_quote($key, '/') . '" content="[^"]*">\s*/', $tag === null ? null : $tag . "\n");
    if (!$found && $tag !== null) $add .= $tag . "\n";
  }
  seo_swap($html, '/<link rel="canonical"[^>]*>\s*/', null);
  seo_swap($html, '/<script type="application\/ld\+json"[^>]*>.*?<\/script>\s*/s', null);
  $add .= '<link rel="canonical" href="' . seo_h($s['canonical']) . '">' . "\n";
  $json = json_encode($s['ld'], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP);
  $add .= '<script type="application/ld+json" id="product-jsonld">' . $json . '</script>' . "\n";
  $pos = stripos($html, '</title>');
  return substr($html, 0, $pos + 8) . "\n" . $add . substr($html, $pos + 8) . $body;
}
function seo_noindex_head($page) {
  list($html, $body) = seo_split($page);
  $tag = '<meta name="robots" content="noindex, nofollow">';
  if (!seo_swap($html, '/<meta name="robots" content="[^"]*">/', $tag)) { $pos = stripos($html, '</title>'); $html = substr($html, 0, $pos + 8) . "\n" . $tag . substr($html, $pos + 8); }
  return $html . $body;
}

// ---------- read the product (public data only) ----------
function seo_get($url, $key) {
  if (function_exists('curl_init')) {
    $c = curl_init($url);
    curl_setopt_array($c, [CURLOPT_RETURNTRANSFER => true, CURLOPT_CONNECTTIMEOUT => 2, CURLOPT_TIMEOUT => 3,
      CURLOPT_HTTPHEADER => ["apikey: $key", "Authorization: Bearer $key", 'Accept: application/json']]);
    $body = curl_exec($c); $code = curl_getinfo($c, CURLINFO_HTTP_CODE); curl_close($c);
  } else {
    $ctx = stream_context_create(['http' => ['header' => "apikey: $key\r\nAuthorization: Bearer $key\r\nAccept: application/json\r\n", 'timeout' => 3]]);
    $body = @file_get_contents($url, false, $ctx); $code = $body === false ? 0 : 200;
  }
  if ($code !== 200 || $body === false) return null;           // null = couldn't ask; [] = no such public product
  $data = json_decode($body, true);
  return is_array($data) ? $data : null;
}

if (!defined('SEO_NO_RUN')) {
  $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
  $slug = isset($_GET['p']) ? preg_replace('/[^a-z0-9-]/', '', strtolower($_GET['p'])) : '';
  $FIELDS = 'id,title,title_bn,description,short_description,price,sale_price,sale_starts_at,sale_ends_at,product_type,listing_type,status,sku,stock,manage_stock,stock_status,backorders,is_preorder,is_service,is_downloadable,is_gift_card,contact_only,price_negotiable,rating_avg,rating_count,seller_id,product_images(storage_path,sort_order),product_variations(price,sale_price,stock,is_active),product_attribute_values(attributes(name),attribute_options(value))';
  $rows = null;
  if ($id > 0 || $slug !== '')
    $rows = seo_get("$REST/products?select=" . rawurlencode($FIELDS) . '&status=eq.approved&' . ($id > 0 ? "id=eq.$id" : 'slug=eq.' . rawurlencode($slug)), $KEY);
  if ($rows) {
    $P = $rows[0];
    $shops = seo_get("$REST/shops?select=shop_name&user_id=eq." . rawurlencode($P['seller_id']), $KEY);
    $brand = null;
    foreach ($P['product_attribute_values'] ?: [] as $v)
      if (!empty($v['attributes']['name']) && stripos($v['attributes']['name'], 'brand') !== false && !empty($v['attribute_options']['value'])) { $brand = $v['attribute_options']['value']; break; }
    $seo = seo_build($P, ['site' => $SITE, 'sb' => $SB, 'shopName' => $shops ? $shops[0]['shop_name'] : '', 'brand' => $brand, 'now' => time()]);
    $html = seo_head($html, $seo);
  } elseif (is_array($rows) || ($id <= 0 && $slug === '')) {
    // No such public product (missing, draft, pending, rejected, hidden): keep it out of search results.
    // The page still opens normally, so a seller can preview their own product after signing in.
    $html = seo_noindex_head($html);
    if (is_array($rows)) http_response_code(404);
  }
  echo $html;
}
