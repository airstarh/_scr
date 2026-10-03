const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const vsix = process.argv[2];
if (!vsix || !fs.existsSync(vsix)) {
  console.error(`VSIX does not exist: ${vsix || '(missing argument)'}`);
  process.exit(1);
}

const listing = spawnSync('unzip', ['-Z1', vsix], { encoding: 'utf8' });
if (listing.status !== 0) {
  console.error(listing.stderr || listing.stdout);
  process.exit(listing.status || 1);
}

const entries = new Set(listing.stdout.trim().split('\n'));
const manifest = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'package.json'), 'utf8'));
const grammars = [...new Set(
  fs.readFileSync(path.join(__dirname, '..', 'src', 'languageMap.ts'), 'utf8')
    .matchAll(/wasmFile:\s*"([^"]+)"/g),
)].map(match => match[1]);
const required = [
  'extension/package.json',
  'extension/dist/extension.js',
  'extension/dist/wasm/tree-sitter.wasm',
  ...grammars.map(file => `extension/dist/wasm/${file}`),
  'extension/LICENSE.txt',
  'extension/readme.md',
  'extension/INSTALL.md',
  'extension/UPSTREAM.md',
];
const missing = required.filter(entry => !entries.has(entry));

if (manifest.publisher !== 'local-alina' || manifest.name !== 'tree-sitter-smart-select-patched') {
  console.error('Unexpected extension identity in package.json');
  process.exit(1);
}
if (missing.length) {
  console.error(`VSIX is missing required entries:\n${missing.join('\n')}`);
  process.exit(1);
}
console.log(`PASS: VSIX identity and ${required.length} required entries verified, including PHP`);
