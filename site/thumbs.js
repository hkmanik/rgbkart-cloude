// Small copies of product photos for cards and lists (audit, 29 Oct 2026).
// Product photos are up to 1600 px; a card shows them at about 200 px. Each upload now also saves a 480 px WebP copy
// next to the photo: "<shop>/<product>/123-abc.webp" → "<shop>/<product>/123-abc-t.webp". Cards load the small copy and
// fall back to the full photo when there is none (older photos).
//   RGBThumb.path(path)                     small-copy path for a photo path
//   RGBThumb.upload(db, bucket, path, blob)  make and upload the small copy (never throws; the photo itself is what matters)
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
    try { const t = await make(blob); await db.storage.from(bucket).upload(path(p), t, { contentType: t.type || 'image/webp', cacheControl: '31536000', upsert: true }); } catch (_) {}
  }
  window.RGBThumb = { path, make, upload };
})();
