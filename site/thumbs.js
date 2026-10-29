// Small copies of product photos for cards and lists (audit, 29 Oct 2026).
// Product photos are up to 1600 px; a card shows them at about 200 px. Each upload now also saves a 480 px WebP copy
// next to the photo: "<shop>/<product>/123-abc.webp" → "<shop>/<product>/123-abc-t.webp". Cards load the small copy and
// fall back to the full photo when there is none (older photos).
//   RGBThumb.path(path)                     small-copy path for a photo path
//   RGBThumb.upload(db, bucket, path, blob)  make and upload the small copy (never throws; the photo itself is what matters)
//   RGBThumb.flush(db)                      after the photo rows are saved: mark them has_thumb (0068_photo_thumbs.sql)
//   RGBThumb.backfill(db, onProgress)        admin: make copies for older photos that have none
(function () {
  const path = p => String(p || '').replace(/\.[A-Za-z0-9]+$/, '') + '-t.webp';
  function make(blob, max = 480) {
    return new Promise((resolve, reject) => {
      const img = new Image();
      img.onload = () => {
        const k = Math.min(1, max / Math.max(img.width, img.height));
        const c = document.createElement('canvas'); c.width = Math.round(img.width * k); c.height = Math.round(img.height * k);
        const ctx = c.getContext('2d'); ctx.fillStyle = '#fff'; ctx.fillRect(0, 0, c.width, c.height); ctx.drawImage(img, 0, 0, c.width, c.height);
        URL.revokeObjectURL(img.src);
        c.toBlob(b => b ? resolve(b) : reject(new Error('no thumb')), 'image/webp', .78);
      };
      img.onerror = reject;
      img.src = URL.createObjectURL(blob);
    });
  }
  async function upload(db, bucket, p, blob) {
    try {
      const t = await make(blob);
      const r = await db.storage.from(bucket).upload(path(p), t, { contentType: t.type || 'image/webp', cacheControl: '31536000', upsert: true });
      if (r.error) return false;
      pending.push(p); return true;
    } catch (_) { return false; }
  }
  const pending = [];
  async function flush(db) {
    if (!pending.length) return;
    const paths = pending.splice(0);
    try { await db.rpc('mark_thumbs', { p_paths: paths }); } catch (_) {}
  }
  // Older photos: download each full photo, make the copy, save it next to the photo, mark it. Admin only (storage rules).
  async function backfill(db, onProgress) {
    const r = await db.from('product_images').select('storage_path').eq('has_thumb', false).limit(2000);
    if (r.error) throw r.error;
    const list = r.data || []; let ok = 0, bad = 0;
    for (let i = 0; i < list.length; i++) {
      const p = list[i].storage_path;
      try {
        const url = db.storage.from('product-images').getPublicUrl(p).data.publicUrl;
        const res = await fetch(url); if (!res.ok) throw new Error('no photo');
        if (await upload(db, 'product-images', p, await res.blob())) ok++; else bad++;
      } catch (_) { bad++; }
      if (pending.length >= 20) await flush(db);
      if (onProgress) onProgress(i + 1, list.length, ok, bad);
    }
    await flush(db);
    return { total: list.length, ok, bad };
  }
  window.RGBThumb = { path, make, upload, flush, backfill };
})();
