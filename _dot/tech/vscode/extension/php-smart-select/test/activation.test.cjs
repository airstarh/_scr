const assert = require('node:assert/strict');
const fs = require('node:fs');
const Module = require('node:module');
const path = require('node:path');
const test = require('node:test');

const root = path.resolve(process.env.EXTENSION_ROOT || path.join(__dirname, '..'));
const vscode = require('./mocks/vscode.cjs');
const originalLoad = Module._load;

test('built extension initializes and registers all language providers', async () => {
  Module._load = function patchedLoad(request, parent, isMain) {
    if (request === 'vscode') return vscode;
    return originalLoad.call(this, request, parent, isMain);
  };
  try {
    const bundle = path.join(root, 'dist', 'extension.js');
    delete require.cache[bundle];
    const extension = require(bundle);
    await extension.activate({ extensionUri: { fsPath: root }, subscriptions: [] });
  } finally {
    Module._load = originalLoad;
  }

  assert.deepEqual(vscode.__state.warnings, []);
  assert.equal(vscode.__state.providers.length, 1);
  assert.equal(vscode.__state.providers[0].selector.length, 16);
  assert(vscode.__state.providers[0].selector.some(item => item.language === 'php'));
});

test('bundle does not pass an undefined placeholder URL to createRequire', () => {
  const source = fs.readFileSync(path.join(root, 'dist', 'extension.js'), 'utf8');
  assert.doesNotMatch(source, /createRequire.{0,100}\.url/s);
  assert.doesNotMatch(source, /createRequire\((?:void 0|undefined)\)/);
});
