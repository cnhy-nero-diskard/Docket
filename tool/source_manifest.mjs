import { execFileSync } from 'node:child_process';
import { readFile, writeFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
const paths = execFileSync('git', ['ls-files', '--cached', '--others', '--exclude-standard', '-z'], {encoding: 'utf8'})
  .split('\0').filter(Boolean).filter(path => !path.startsWith('docs/evidence/'));
const files = [];
for (const path of [...new Set(paths)].sort()) {
  files.push({path, sha256: createHash('sha256').update(await readFile(path)).digest('hex')});
}
await writeFile('docs/evidence/source-manifest.json', JSON.stringify({
  base: execFileSync('git', ['rev-parse', 'HEAD'], {encoding: 'utf8'}).trim(),
  branch: execFileSync('git', ['branch', '--show-current'], {encoding: 'utf8'}).trim(),
  state: 'Uncommitted implementation; hashes identify the retained source and planning files', files,
}, null, 2));
console.log(`Recorded ${files.length} source/configuration hashes`);
