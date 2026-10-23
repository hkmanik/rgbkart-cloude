<?php
// Link preview for Facebook, WhatsApp, Messenger and others (they do not run the page's JavaScript).
// share.php?id=123  → product preview (title, price, photo) then opens product.html?id=123
// share.php?s=slug  → shop preview (name, tagline, logo) then opens store.html?s=slug
// Reads only public data with the public (publishable) key, the same as the shop pages.
$SB  = 'https://qrzlsomuluglbslricaf.supabase.co';
$KEY = 'sb_publishable_i-6QX7ObGzF4ykfrgkITsw_HnndqdNY';
$SITE = '%%SITE%%';

function get_json($url, $key) {
  $headers = "apikey: $key\r\nAuthorization: Bearer $key\r\nAccept: application/json\r\n";
  if (function_exists('curl_init')) {
    $c = curl_init($url);
    curl_setopt_array($c, [CURLOPT_RETURNTRANSFER => true, CURLOPT_TIMEOUT => 6,
      CURLOPT_HTTPHEADER => ["apikey: $key", "Authorization: Bearer $key", "Accept: application/json"]]);
    $body = curl_exec($c); curl_close($c);
  } else {
    $body = @file_get_contents($url, false, stream_context_create(['http' => ['header' => $headers, 'timeout' => 6]]));
  }
  $data = $body ? json_decode($body, true) : null;
  return is_array($data) ? $data : [];
}
function h($s) { return htmlspecialchars((string)$s, ENT_QUOTES, 'UTF-8'); }

$title = 'RGBKart · Red & Green Basket';
$desc  = 'Buy and sell across all 64 districts of Bangladesh. Cash on Delivery.';
$image = "$SITE/assets/og/rgbkart-share.png";
$target = 'index.html';

$id = isset($_GET['id']) ? intval($_GET['id']) : 0;
$slug = isset($_GET['s']) ? preg_replace('/[^A-Za-z0-9_-]/', '', $_GET['s']) : '';

if ($id > 0) {
  $target = "product.html?id=$id";
  $rows = get_json("$SB/rest/v1/products?id=eq.$id&status=eq.approved&select=title,short_description,price,sale_price,sale_starts_at,sale_ends_at,product_type,product_images(storage_path,sort_order),product_variations(price,sale_price,is_active)", $KEY);
  if ($rows) {
    $p = $rows[0];
    $price = $p['price'];
    $now = time();
    $saleOn = $p['sale_price'] !== null && (!$p['sale_starts_at'] || strtotime($p['sale_starts_at']) <= $now) && (!$p['sale_ends_at'] || strtotime($p['sale_ends_at']) >= $now);
    if ($saleOn) $price = $p['sale_price'];
    if ($p['product_type'] === 'variable' && !empty($p['product_variations'])) {
      $vals = [];
      foreach ($p['product_variations'] as $v) if ($v['is_active']) $vals[] = $v['sale_price'] ?: $v['price'];
      if ($vals) $price = min($vals);
    }
    $title = $p['title'] . ($price ? ' · ৳' . number_format((float)$price) : '');
    $desc = trim(($p['short_description'] ?: '') . ' Order on RGBKart, pay in cash on delivery.');
    $imgs = $p['product_images'] ?: [];
    usort($imgs, function ($a, $b) { return $a['sort_order'] <=> $b['sort_order']; });
    if ($imgs) $image = "$SB/storage/v1/object/public/product-images/" . str_replace('%2F', '/', rawurlencode($imgs[0]['storage_path']));
  }
} elseif ($slug !== '') {
  $target = "store.html?s=" . rawurlencode($slug);
  $col = preg_match('/^[0-9a-f-]{36}$/i', $slug) ? 'user_id' : 'shop_slug';
  $rows = get_json("$SB/rest/v1/shops?$col=eq." . rawurlencode($slug) . "&select=shop_name,tagline,city,logo_path,banner_path", $KEY);
  if ($rows) {
    $s = $rows[0];
    $title = $s['shop_name'] . ' on RGBKart';
    $desc = trim(($s['tagline'] ?: 'A shop on RGBKart') . ($s['city'] ? ' · ' . $s['city'] : ''));
    $pic = $s['banner_path'] ?: $s['logo_path'];
    if ($pic) $image = "$SB/storage/v1/object/public/shop-assets/" . str_replace('%2F', '/', rawurlencode($pic));
  }
}
$url = "$SITE/$target";
header('Content-Type: text/html; charset=utf-8');
header('Cache-Control: public, max-age=600');
?><!doctype html>
<html lang="en"><head>
<meta charset="utf-8">
<title><?= h($title) ?></title>
<meta name="description" content="<?= h($desc) ?>">
<meta property="og:site_name" content="RGBKart · Red &amp; Green Basket">
<meta property="og:type" content="<?= $id > 0 ? 'product' : 'website' ?>">
<meta property="og:title" content="<?= h($title) ?>">
<meta property="og:description" content="<?= h($desc) ?>">
<meta property="og:image" content="<?= h($image) ?>">
<meta property="og:url" content="<?= h($url) ?>">
<meta name="twitter:card" content="summary_large_image">
<link rel="canonical" href="<?= h($url) ?>">
<meta http-equiv="refresh" content="0;url=<?= h($target) ?>">
<script>location.replace(<?= json_encode($target) ?>);</script>
</head><body><p><a href="<?= h($target) ?>">Open on RGBKart</a></p></body></html>
