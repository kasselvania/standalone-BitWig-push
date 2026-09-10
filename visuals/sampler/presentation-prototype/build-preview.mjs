#!/usr/bin/env node
// Generate a self-contained local HTML review artifact. No server, install, or background process.
import { readFileSync, writeFileSync, mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';

const root = new URL('.', import.meta.url);
const parts = ['geometry.mjs', 'fixture.mjs', 'presentation.mjs', 'demo.mjs'].map(name => readFileSync(new URL(name, root), 'utf8')
  .replace(/^import .*;\n/gm, '').replace(/^export /gm, ''));
const page = readFileSync(new URL('index.html', root), 'utf8').replace(
  '<script type="module" src="demo.mjs"></script>', `<script type="module">\n${parts.join('\n')}\n</script>`);
const directory = mkdtempSync(join(tmpdir(), 'pushwig-sampler-review-'));
const path = join(directory, 'sampler-preview.html');
writeFileSync(path, page, { mode: 0o600, flag: 'wx' });
console.log(JSON.stringify({ path, sha256: createHash('sha256').update(page).digest('hex'),
  sourceDirectory: fileURLToPath(root), scope: 'generated offline preview; no Bitwig/Push connection' }, null, 2));
if (process.argv.includes('--open')) execFileSync('open', [path]);
