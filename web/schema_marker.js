/* Compatibility metadata only. Never contains records, credentials or tokens. */
globalThis.docketSchema = {
  async database() {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open('docket-shell-compatibility', 1);
      request.onupgradeneeded = () => request.result.createObjectStore('versions');
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  },
  async read(namespace) {
    const db = await this.database();
    try {
      return await new Promise((resolve, reject) => {
        const tx = db.transaction('versions');
        const request = tx.objectStore('versions').get(namespace);
        tx.oncomplete = () => resolve(request.result || 0);
        tx.onerror = () => reject(tx.error);
      });
    } finally { db.close(); }
  },
  async write(namespace, version) {
    const db = await this.database();
    try {
      await new Promise((resolve, reject) => {
        const tx = db.transaction('versions', 'readwrite');
        tx.objectStore('versions').put(version, namespace);
        tx.oncomplete = resolve;
        tx.onerror = () => reject(tx.error);
        tx.onabort = () => reject(tx.error);
      });
    } finally { db.close(); }
  },
};
