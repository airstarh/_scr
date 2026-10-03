const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const root = path.resolve(__dirname, '..');

test('package declares the standalone identity, languages, and configuration', () => {
  const manifest = JSON.parse(fs.readFileSync(path.join(root, 'package.json'), 'utf8'));
  assert.equal(manifest.publisher, 'local-alina');
  assert.equal(manifest.name, 'tree-sitter-smart-select-patched');
  assert.equal(manifest.version, '0.1.0');

  const expectedLanguages = [
    'typescript', 'typescriptreact', 'javascript', 'javascriptreact',
    'python', 'rust', 'go', 'c', 'cpp', 'java', 'ruby', 'html', 'css',
    'json', 'shellscript', 'php',
  ];
  assert.deepEqual(
    manifest.activationEvents.map(event => event.replace('onLanguage:', '')),
    expectedLanguages,
  );

  const properties = manifest.contributes.configuration.properties;
  assert.deepEqual(Object.keys(properties).sort(), [
    'treeSitterSmartSelect.additionalParsers',
    'treeSitterSmartSelect.enabledLanguages',
    'treeSitterSmartSelect.includeAnonymousNodes',
    'treeSitterSmartSelect.maxFileSize',
  ]);
  assert.equal(manifest.contributes.keybindings, undefined);
});
