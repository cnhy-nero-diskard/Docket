import { readdir, readFile, writeFile } from 'node:fs/promises';
import { resolve, relative } from 'node:path';
import { createHash } from 'node:crypto';
const root = resolve(process.argv[2] || 'build/web');
const sha256 = bytes => createHash('sha256').update(bytes).digest('hex');
for (const [asset, expected] of Object.entries({
  'sqlite3.wasm': 'fbcd2e8214f9231ea961e1b7706a22dd1194cfbfe6f26f13841b5aa7a0be1a1f',
  'drift_worker.js': 'fe5f13be0526f78293796aefb9a29d3823a2dbdbf1bccd3f0faeb90eaaafd72a',
})) {
  if (sha256(await readFile(resolve(root, asset))) !== expected) throw Error(`Unexpected ${asset} version/hash`);
}
async function walk(directory) {
  const paths = [];
  for (const entry of await readdir(directory, {withFileTypes: true})) {
    const path = resolve(directory, entry.name);
    if (entry.isDirectory()) paths.push(...await walk(path));
    else if (!['docket_sw.js', 'release.json', 'flutter_service_worker.js'].includes(entry.name)) paths.push(path);
  }
  return paths;
}
const assets = await Promise.all((await walk(root)).sort().map(async path => ({
  path: '/' + relative(root, path).replaceAll('\\', '/'), sha256: sha256(await readFile(path)),
})));
const release = { id: sha256(JSON.stringify(assets)).slice(0, 20), fixtureSchema: 2, localSchema: 1, assets };
const template = await readFile(new URL('service_worker.template.js', import.meta.url), 'utf8');
await writeFile(resolve(root, 'docket_sw.js'), template.replace('__DOCKET_RELEASE__', JSON.stringify(release)));
await writeFile(resolve(root, 'release.json'), JSON.stringify(release, null, 2));
console.log(`Sealed ${assets.length} assets, release ${release.id}`);
