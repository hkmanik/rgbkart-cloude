// RGBKart service worker (30 Oct 2026). Makes the site installable as an app ("Add to home screen").
// It does NOT cache the shop: pages and data always come fresh from the internet. Only when a page can't load
// because there is no connection does it show offline.html (kept in the cache).
const CACHE = 'rgbkart-offline-v1';
const OFFLINE = ['offline.html', 'assets/logo/rgb-basket-96.png'];
self.addEventListener('install', e => { e.waitUntil(caches.open(CACHE).then(c => c.addAll(OFFLINE)).then(() => self.skipWaiting())); });
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  const r = e.request;
  if (r.method !== 'GET') return;
  if (r.mode === 'navigate') {
    e.respondWith(fetch(r).catch(() => caches.match('offline.html')));
  } else if (new URL(r.url).pathname.endsWith('/assets/logo/rgb-basket-96.png')) {
    e.respondWith(fetch(r).catch(() => caches.match('assets/logo/rgb-basket-96.png')));
  }
});
