// Replaced by seal_web.mjs with the exact built release, including all hashes.
const RELEASE = __DOCKET_RELEASE__;
const CACHE = `docket-shell-${RELEASE.id}`;
const paths = new Set(RELEASE.assets.map(asset => asset.path));
importScripts('/schema_marker.js');

async function compatible() {
  return await docketSchema.read('docket_foundation_fixture') <= RELEASE.fixtureSchema &&
    await docketSchema.read('docket_local') <= RELEASE.localSchema;
}
self.addEventListener('install', event => event.waitUntil((async () => {
  const cache = await caches.open(CACHE);
  try {
    for (const asset of RELEASE.assets) {
      const response = await fetch(asset.path, { cache: 'no-store', credentials: 'omit' });
      if (!response.ok || response.type === 'opaque') throw Error('Incomplete release');
      const hash = [...new Uint8Array(await crypto.subtle.digest('SHA-256', await response.clone().arrayBuffer()))]
        .map(byte => byte.toString(16).padStart(2, '0')).join('');
      if (hash !== asset.sha256) throw Error('Mixed or corrupt release');
      await cache.put(asset.path, response);
    }
    if (!await compatible()) throw Error('Database needs a newer shell');
    await cache.put('/.complete', new Response(RELEASE.id));
    // Deliberately no skipWaiting: live drafts keep their existing shell.
  } catch (error) { await caches.delete(CACHE); throw error; }
})()));
self.addEventListener('activate', event => event.waitUntil((async () => {
  if (!await compatible()) throw Error('Incompatible schema');
  const cache = await caches.open(CACHE);
  if (!await cache.match('/.complete')) throw Error('Incomplete shell');
  await clients.claim();
  // Retain the preceding complete release for diagnosis/recovery.
  const older = (await caches.keys()).filter(key => key.startsWith('docket-shell-') && key !== CACHE);
  for (const key of older.slice(0, -1)) await caches.delete(key);
})()));
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  if (event.request.method !== 'GET' || url.origin !== self.location.origin || url.search) return;
  const localRoute = event.request.mode === 'navigate' &&
    (url.pathname === '/' || url.pathname === '/lists' || url.pathname.startsWith('/lists/'));
  if (!localRoute && !paths.has(url.pathname)) return;
  event.respondWith((async () => {
    const cache = await caches.open(CACHE);
    return await cache.match(localRoute ? '/index.html' : url.pathname) ||
      new Response('Offline preparation incomplete. Reconnect to finish.', {status: 503});
  })());
});
self.addEventListener('message', event => {
  if (event.data === 'offline-status') event.waitUntil((async () => {
    const cache = await caches.open(CACHE);
    event.ports[0]?.postMessage({ready: Boolean(await cache.match('/.complete')), release: RELEASE.id});
  })());
});
