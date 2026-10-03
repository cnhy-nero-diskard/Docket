const status = document.getElementById('offline-status');
if ('serviceWorker' in navigator && window.isSecureContext) {
  navigator.serviceWorker.register('/docket_sw.js', { updateViaCache: 'none' }).then(registration => {
    function refresh() {
      if (registration.waiting) {
        status.textContent = 'Update prepared. Save drafts, then close all Docket tabs to install.';
      } else if (navigator.serviceWorker.controller) {
        const channel = new MessageChannel();
        channel.port1.onmessage = event => {
          status.textContent = event.data.ready ? 'Ready offline · local data stays in this browser'
            : 'Offline preparation incomplete. Reconnect to finish.';
        };
        navigator.serviceWorker.controller.postMessage('offline-status', [channel.port2]);
      }
    }
    registration.addEventListener('updatefound', () => {
      registration.installing?.addEventListener('statechange', refresh);
    });
    navigator.serviceWorker.addEventListener('controllerchange', refresh);
    refresh();
  }).catch(() => { status.textContent = 'Offline preparation incomplete. Reconnect to finish.'; });
} else { status.textContent = 'Offline shell unavailable. A secure supported browser is required.'; }
