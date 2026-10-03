import { createServer } from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import { resolve, extname, sep } from 'node:path';

const root = resolve(process.argv[2] || 'build/web');
const port = Number(process.env.PORT || 8787);
const isolation = process.env.ISOLATION !== 'off';
const mime = { '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript',
  '.wasm': 'application/wasm', '.json': 'application/json', '.png': 'image/png',
  '.woff2': 'font/woff2', '.ttf': 'font/ttf', '.ico': 'image/x-icon' };
createServer(async (req, res) => {
  try {
    const url = new URL(req.url, 'http://localhost');
    let file = resolve(root, '.' + decodeURIComponent(url.pathname));
    if (file !== root && !file.startsWith(root + sep)) { res.writeHead(403).end(); return; }
    try { if (!(await stat(file)).isFile()) throw new Error('not file'); }
    catch {
      if (extname(url.pathname)) { res.writeHead(404).end(); return; }
      file = resolve(root, 'index.html');
    }
    const headers = { 'Content-Type': mime[extname(file)] || 'application/octet-stream',
      'Cache-Control': 'no-store', 'Cross-Origin-Resource-Policy': 'same-origin',
      'X-Content-Type-Options': 'nosniff' };
    if (isolation) {
      headers['Cross-Origin-Opener-Policy'] = 'same-origin';
      headers['Cross-Origin-Embedder-Policy'] = 'require-corp';
    }
    // Same-origin assets need no permissive CORS. A named test origin is opt-in.
    if (process.env.CORS_ORIGIN) headers['Access-Control-Allow-Origin'] = process.env.CORS_ORIGIN;
    res.writeHead(200, headers).end(await readFile(file));
  } catch { res.writeHead(500).end('Static host error'); }
}).listen(port, '127.0.0.1', () => console.log(`Docket static host http://127.0.0.1:${port}; isolation=${isolation}`));
