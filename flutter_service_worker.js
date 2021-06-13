'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "version.json": "e3beb588606c99420f0e67ad0d1f00de",
"main.dart.js": "47a66636b447974ed54a08aa37d35be5",
"index.html": "7d1f29ad01c4d2d301e86238fb60f63d",
"/": "7d1f29ad01c4d2d301e86238fb60f63d",
"assets/packages/storybook_flutter/assets/README.md": "fbaed1ae60d80596d99545ef45d72803",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "00bb2b684be61e89d1bc7d75dee30b58",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "dffd9504fcb1894620fa41c700172994",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "4b6a9b7c20913279a3ad3dd9c96e155b",
"assets/packages/auth_buttons/images/secondary/email_white.png": "5f57417e36ae055d6f9f525e04c51213",
"assets/packages/auth_buttons/images/secondary/microsoft.png": "8f8e4c2c6c1158fa0eb76c9dcca4a106",
"assets/packages/auth_buttons/images/secondary/facebook.png": "17bc7ce24f8be2338c0fe756bc91021a",
"assets/packages/auth_buttons/images/secondary/email.png": "5a8046651666ff2e14ebb87473d87177",
"assets/packages/auth_buttons/images/secondary/huawei.png": "2a9a4ae758b9ba527dc309de7f12706e",
"assets/packages/auth_buttons/images/secondary/apple.png": "c92e950ff74f3d0aed25eae8f2b625a3",
"assets/packages/auth_buttons/images/secondary/google.png": "f6e6e8105bf24721e61dd67a38d894ed",
"assets/packages/auth_buttons/images/default/huawei_white.png": "b5c5ab42a71d5dde71d8cd965db05009",
"assets/packages/auth_buttons/images/default/twitter_white.png": "0d4470494f8f7ed308ed1c0f59f13fa6",
"assets/packages/auth_buttons/images/default/facebook_white.png": "9377466f32681729736ca9347a2e4363",
"assets/packages/auth_buttons/images/default/github_white.png": "b69ee90f95f5baea1f6440b27d4d3d7f",
"assets/packages/auth_buttons/images/default/email_white.png": "b138a1aedb7f7f0891923b0121cc8520",
"assets/packages/auth_buttons/images/default/microsoft.png": "96da9d69ca3c3f18e9383d01075a4a39",
"assets/packages/auth_buttons/images/default/facebook.png": "7cf5256d509b37c5e023d0e3bf89ca33",
"assets/packages/auth_buttons/images/default/email.png": "220771d987f09a46b5ee470d7d1fe14f",
"assets/packages/auth_buttons/images/default/huawei.png": "0ca2ffbecc245b5793e865ed98087fa8",
"assets/packages/auth_buttons/images/default/apple_white.png": "fee7941657354ff5a6522fb270de6b50",
"assets/packages/auth_buttons/images/default/apple.png": "ebc6d25b2a5f85ac1c55fc8493a6933d",
"assets/packages/auth_buttons/images/default/twitter.png": "ce08a5ef8628e44e8f042f47d5df1661",
"assets/packages/auth_buttons/images/default/github_black.png": "d7670a9b94f89048f0aa78dd1f813bc1",
"assets/packages/auth_buttons/images/default/google.png": "6937ba6a7d2de8aa07701225859ae402",
"assets/packages/auth_buttons/images/outlined/huawei_white.png": "fba6b79ab27cb950b8dc65d70a350cfa",
"assets/packages/auth_buttons/images/outlined/twitter_white.png": "7e0f8d607a2fd2e431d48bdad71cb7f9",
"assets/packages/auth_buttons/images/outlined/facebook_white.png": "1148a3359d95ba55000798b3565d35ad",
"assets/packages/auth_buttons/images/outlined/email_white.png": "3eed4eeffc6338fb1db70926f75e5dda",
"assets/packages/auth_buttons/images/outlined/microsoft.png": "b74a53bdc17df88dd0ee39f302f8fb5a",
"assets/packages/auth_buttons/images/outlined/facebook.png": "1ff2150aebd4781a3e290a1cc7dc1e1c",
"assets/packages/auth_buttons/images/outlined/email.png": "4e322dbd031e5940d60ba4f82204d73d",
"assets/packages/auth_buttons/images/outlined/huawei.png": "596b8fc29dca10fb847162d8190ab922",
"assets/packages/auth_buttons/images/outlined/apple_white.png": "b53bfa858ef99ed1cdcba417f5911847",
"assets/packages/auth_buttons/images/outlined/apple.png": "982c4374fd8d68c835f51e1b218946c9",
"assets/packages/auth_buttons/images/outlined/twitter.png": "6cc42f4430ea2d28e6bcebe8caba835e",
"assets/packages/auth_buttons/images/outlined/google.png": "f16a82299f7fb65ad5b9fa493b4fdc79",
"assets/AssetManifest.json": "0c96e3dbfb2a0c7cfdc5c2e4b61bc454",
"assets/NOTICES": "bcc20d6a167a51a8a7f2e736e8ca4cf0",
"assets/fonts/MaterialIcons-Regular.otf": "4e6447691c9509f7acdbf8a931a85ca1",
"assets/assets/docs/terms.txt": "0502e1973dbc310c0dc56d447c8883b6",
"assets/assets/docs/privacy.txt": "aca6d8940a1ec8d2f2e1116247d0af82",
"assets/assets/fonts/OpenSans-Regular.ttf": "3ed9575dcc488c3e3a5bd66620bdf5a4",
"assets/assets/fonts/Roboto-Regular.ttf": "11eabca2251325cfc5589c9c6fb57b46",
"assets/assets/images/free.png": "e5a970a55ef16f35f7ba0d0b71ee4812",
"assets/assets/images/logo_tiny.png": "86165baf3808f74693ed5083d16ed196",
"assets/assets/images/open_source.png": "7344bc1f5bf38917ef9bd543ee8f32f1",
"assets/assets/images/logo.png": "3d6665ed1b9a2adc7762b478d4b36f42",
"assets/assets/images/cookie.png": "09885189023d66d903d32aa64b0447bf",
"assets/assets/images/no_folders.png": "dd281745dd2bf5a420a2833f5772388e",
"assets/assets/images/privacy.png": "b47161e54d4db1f5c4e76b6257abcd46",
"assets/assets/images/logo_no_text.png": "719149c578648815a8ce010eb8673cb6",
"assets/assets/images/bmc.png": "361d68c25e9adc775a441fd8d32d38a7",
"assets/assets/images/no_folder.png": "e7f06c180e8bc74cd486c9ab6f9a25c2",
"assets/assets/images/about.png": "2da52c99f5a1dcc61836e59a292f5329",
"assets/assets/images/error.png": "9cd2a987c1a6712dde16f31394b1d213",
"assets/assets/images/flow.png": "dc7b12fdb207382bdaf6f4d823fed7f5",
"assets/FontManifest.json": "c37a0cf64f34b8d2481e187e4f50e7d9",
"icons/Icon-512.png": "016f02854d4126dedbcf7bf4bbdcf729",
"icons/Icon-192.png": "b76196c154ac96ac10458acf348163ee",
"manifest.json": "1f566b509698542d126fbd8f162102f7",
"favicon.png": "8f98662fb2d6dabd1c2a5ff240cbf29c"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
