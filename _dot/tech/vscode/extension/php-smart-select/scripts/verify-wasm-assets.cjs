const fs = require('node:fs');
const path = require('node:path');

const root = path.resolve(__dirname, '..');
const wasmDir = path.join(root, 'dist', 'wasm');
const languageMapSource = fs.readFileSync(path.join(root, 'src', 'languageMap.ts'), 'utf8');
const grammarFiles = [...languageMapSource.matchAll(/wasmFile:\s*"([^"]+)"/g)].map(match => match[1]);
const required = ['tree-sitter.wasm', ...new Set(grammarFiles)];

const failures = required.filter(file => {
  const target = path.join(wasmDir, file);
  return !fs.existsSync(target) || fs.statSync(target).size === 0;
});

if (!required.includes('tree-sitter-php.wasm')) {
  failures.push('tree-sitter-php.wasm (not declared)');
}

if (failures.length) {
  console.error(`Missing or empty required WASM assets:\n${failures.join('\n')}`);
  process.exitCode = 1;
} else {
  console.log(`PASS: ${required.length} required WASM assets are present, including PHP`);
}
