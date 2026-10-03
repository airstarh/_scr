const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const root = path.resolve(__dirname, '..');

test('installation documentation covers replacement, verification, and rollback', () => {
  const text = [
    fs.readFileSync(path.join(root, 'README.md'), 'utf8'),
    fs.readFileSync(path.join(root, 'INSTALL.md'), 'utf8'),
  ].join('\n');
  for (const required of [
    'local-alina.tree-sitter-smart-select-patched',
    'awesometaro.tree-sitter-smart-select',
    'Install from VSIX',
    'code --install-extension',
    'Developer: Reload Window',
    'Ctrl+E',
    'Ctrl+Q',
    'tree-sitter-smart-select-patched-0.1.0.vsix',
    'rollback',
    'PHP',
  ]) {
    assert(text.includes(required), `documentation must include: ${required}`);
  }
});
