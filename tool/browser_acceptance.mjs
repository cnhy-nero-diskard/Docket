import { chromium } from 'playwright';
import { mkdir, mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import assert from 'node:assert/strict';

const origin = process.env.DOCKET_ORIGIN || 'http://127.0.0.1:8787';
const evidence = 'docs/evidence';
await mkdir(evidence, {recursive: true});
const profile = await mkdtemp(join(tmpdir(), 'docket-chromium-'));
const result = {date: '2026-10-03', base: '9c542bc',
  release: JSON.parse(await readFile('build/web/release.json', 'utf8')).id,
  evidenceType: 'real Chrome, built acceptance bundle; injected faults labeled', scenarios: []};
let browser;
const options = {channel: 'chrome', headless: true, viewport: {width: 1280, height: 900}};
async function launch() { browser = await chromium.launchPersistentContext(profile, options); }
async function ready(page) {
  page.on('pageerror', error => console.error('page error:', error.message));
  await page.waitForFunction(() => window.docketFixture, {timeout: 60000});
}
async function snapshot(page) { return JSON.parse(await page.evaluate(() => docketFixture.snapshot())); }
async function check(name, action) {
  const start = Date.now();
  try { const details = await action(); result.scenarios.push({name, outcome: 'PASS', ms: Date.now() - start, details}); console.log('PASS', name, details || ''); }
  catch (error) {
    await browser?.pages()[0]?.screenshot({path: join(evidence, 'browser-failure.png')}).catch(() => {});
    await writeFile(join(evidence, 'browser-failure-aria.txt'), await browser?.pages()[0]?.locator('body').ariaSnapshot().catch(() => '') || '');
    result.scenarios.push({name, outcome: 'FAIL', error: error.message}); throw error;
  }
  finally { await writeFile(join(evidence, 'chromium.json'), JSON.stringify(result, null, 2)); }
}
try {
  await launch();
  let page = browser.pages()[0];
  await page.goto(origin + '/lists'); await ready(page);
  result.browser = await page.evaluate(() => navigator.userAgent);
  result.browserVersion = browser.browser()?.version();
  await check('actual storage mode, headers, WASM MIME and complete cache', async () => {
    const mode = await page.evaluate(() => ({mode: docketFixture.mode, safe: docketFixture.safe,
      protected: docketFixture.protected, isolated: crossOriginIsolated}));
    assert(mode.safe); assert(mode.isolated);
    const response = await page.request.get(origin + '/sqlite3.wasm');
    assert.equal(response.headers()['content-type'], 'application/wasm');
    await page.getByText('Ready offline · local data stays in this browser').waitFor({timeout: 90000});
    await page.evaluate(() => docketFixture.seed()); return mode;
  });
  await check('committed value survives browser process restart', async () => {
    await page.evaluate(() => docketFixture.save('item-000', 'Chrome restart value'));
    await browser.close(); await launch(); page = browser.pages()[0];
    await page.goto(origin + '/lists/collection-a/items/item-000'); await ready(page);
    assert.equal((await snapshot(page)).items.find(x => x.id === 'item-000').title, 'Chrome restart value');
  });
  await check('offline detail reload and local commit', async () => {
    await browser.setOffline(true); await page.reload(); await ready(page);
    await page.evaluate(() => docketFixture.save('item-000', 'Offline committed'));
    assert.equal((await snapshot(page)).items.find(x => x.id === 'item-000').title, 'Offline committed');
    await browser.setOffline(false);
  });
  const second = await browser.newPage(); await second.goto(origin + '/lists'); await ready(second);
  await check('two compatible tabs retain independent edits', async () => {
    await Promise.all([
      page.evaluate(() => docketFixture.save('item-001', 'Tab A')),
      second.evaluate(() => docketFixture.save('item-002', 'Tab B')),
    ]);
    const data = await snapshot(second);
    assert.equal(data.items.find(x => x.id === 'item-001').title, 'Tab A');
    assert.equal(data.items.find(x => x.id === 'item-002').title, 'Tab B');
  });
  await check('tab crash releases browser-owned coordination and preserves committed data', async () => {
    await second.evaluate(() => {
      window.lockHeld = false;
      navigator.locks.request('docket_foundation_fixture:schema-and-access', async () => {
        window.lockHeld = true; await new Promise(() => {});
      });
    });
    await second.waitForFunction(() => window.lockHeld);
    const session = await browser.newCDPSession(second);
    const crashed = second.waitForEvent('crash', {timeout: 10000});
    session.send('Page.crash').catch(() => {});
    await crashed;
    await page.evaluate(() => docketFixture.save('item-003', 'After crashed tab'));
    assert.equal((await snapshot(page)).items.find(x => x.id === 'item-001').title, 'Tab A');
    await second.close();
    return 'Actual renderer crash while holding the application lock; no database reset';
  });
  await check('foundation screenshots at wide, intermediate, compact widths', async () => {
    await page.evaluate(() => docketFixture.route('/lists/collection-a/items/item-000'));
    for (const [name, width] of [['wide', 1280], ['intermediate', 800], ['compact', 390]]) {
      await page.setViewportSize({width, height: 900});
      await page.getByRole('textbox', {name: 'Title', exact: true}).waitFor();
      await page.screenshot({path: join(evidence, `foundation-${name}.png`)});
    }
  });
  await check('interrupted shell update keeps previous complete offline release', async () => {
    const workerPath = 'build/web/docket_sw.js';
    const original = await readFile(workerPath, 'utf8');
    const release = JSON.parse(await readFile('build/web/release.json', 'utf8'));
    const interrupted = {...release, id: release.id + '-interrupted', assets: [...release.assets,
      {path: '/intentionally-missing-update.wasm', sha256: '0'.repeat(64)}]};
    await writeFile(workerPath, original.replace(JSON.stringify(release), JSON.stringify(interrupted)));
    try {
      const state = await page.evaluate(async () => {
        const registration = await navigator.serviceWorker.getRegistration();
        let clearDeadline;
        const failed = new Promise((resolve, reject) => {
          const timer = setTimeout(() => reject(Error('Interrupted install did not settle')), 20000);
          clearDeadline = () => clearTimeout(timer);
          const observe = worker => {
            if (!worker) return;
            const changed = () => { if (worker.state === 'redundant') { clearTimeout(timer); resolve(worker.state); } };
            worker.addEventListener('statechange', changed); changed();
          };
          observe(registration.installing);
          registration.addEventListener('updatefound', () => observe(registration.installing), {once: true});
        });
        await registration.update();
        // register() on offline reload may already have attempted this exact
        // update before the explicit update() call; a failed candidate is gone.
        if (!registration.installing && !registration.waiting) { clearDeadline(); return 'redundant'; }
        return failed;
      });
      assert.equal(state, 'redundant');
      assert(!(await page.evaluate(() => caches.keys())).some(key => key.includes('interrupted')));
      await browser.setOffline(true); await page.reload(); await ready(page);
      assert.equal((await snapshot(page)).items.find(x => x.id === 'item-000').title, 'Offline committed');
      await browser.setOffline(false);
    } finally { await writeFile(workerPath, original); }
    return 'Injected missing asset in a candidate manifest; active shell reopened offline';
  });
  await check('complete update waits without reloading over a draft', async () => {
    await page.getByRole('textbox', {name: 'Title', exact: true}).click();
    await page.keyboard.press('Control+A'); await page.keyboard.insertText('draft during staged update');
    const workerPath = 'build/web/docket_sw.js';
    const original = await readFile(workerPath, 'utf8');
    const release = JSON.parse(await readFile('build/web/release.json', 'utf8'));
    await writeFile(workerPath, original.replace(JSON.stringify(release), JSON.stringify({...release, id: release.id + '-complete'})));
    try {
      await page.evaluate(async () => (await navigator.serviceWorker.getRegistration()).update());
      await page.waitForFunction(async () => Boolean((await navigator.serviceWorker.getRegistration()).waiting));
      assert.equal(await page.getByRole('textbox', {name: 'Title', exact: true}).inputValue(), 'draft during staged update');
      await page.getByText('Update prepared. Save drafts, then close all Docket tabs to install.').waitFor();
    } finally { await writeFile(workerPath, original); }
  });
  await check('stale tab rejects incompatible schema, retaining draft (injected future version)', async () => {
    await page.getByRole('textbox', {name: 'Title', exact: true}).click();
    await page.keyboard.press('Control+A');
    await page.keyboard.insertText('unsaved across upgrade');
    await page.getByText('Unsaved draft', {exact: true}).first().waitFor();
    const upgrade = await browser.newPage(); await upgrade.goto(origin + '/lists'); await ready(upgrade);
    await upgrade.evaluate(() => docketFixture.upgrade());
    await assert.rejects(page.evaluate(() => docketFixture.save('item-000', 'must not persist')));
    await page.getByText('Retry storage', {exact: true}).waitFor();
    assert.match(await page.locator('body').ariaSnapshot(), /unsaved across upgrade/);
    assert.equal(await page.evaluate(() => docketSchema.read('docket_foundation_fixture')), 99);
    await page.screenshot({path: join(evidence, 'stale-tab-preserved-draft.png')});
    await upgrade.close();
  });
  await browser.close();
  for (const mode of ['inMemory', 'unsafeIndexedDb']) {
    await check(`unsafe capability blocks writes (${mode}, injected selection)`, async () => {
      const directory = await mkdtemp(join(tmpdir(), 'docket-capability-'));
      browser = await chromium.launchPersistentContext(directory, options);
      const fallback = browser.pages()[0];
      await fallback.goto(origin + '/lists?storage=' + mode); await ready(fallback);
      assert.equal(await fallback.evaluate(() => docketFixture.safe), false);
      await assert.rejects(fallback.evaluate(() => docketFixture.seed()));
      await fallback.getByText(/Safe persistent storage is unavailable/).waitFor();
      await browser.close();
    });
  }
} finally {
  if (browser) await browser.close();
  await writeFile(join(evidence, 'chromium.json'), JSON.stringify(result, null, 2));
}
