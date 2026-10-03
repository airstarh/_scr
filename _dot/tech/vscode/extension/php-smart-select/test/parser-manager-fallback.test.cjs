const assert = require('node:assert/strict');
const Module = require('node:module');
const path = require('node:path');
const test = require('node:test');

const root = path.resolve(__dirname, '..');
const vscode = require('./mocks/vscode.cjs');
const originalLoad = Module._load;

test('invalid custom PHP parser falls back to the bundled PHP grammar', async () => {
  Module._load = function patchedLoad(request, parent, isMain) {
    if (request === 'vscode') return vscode;
    return originalLoad.call(this, request, parent, isMain);
  };
  const warnings = [];
  const originalWarn = console.warn;
  console.warn = (...parts) => warnings.push(parts.join(' '));
  try {
    vscode.__state.config.additionalParsers = { php: '/missing/custom-php.wasm' };
    const extension = require(path.join(root, 'dist', 'extension.js'));
    assert.equal(typeof extension.ParserManager, 'function');
    const manager = new extension.ParserManager({ fsPath: root });
    await manager.initialize();
    const language = await manager.getLanguage('php');
    assert(language, 'bundled PHP grammar should be used as fallback');
    assert(warnings.some(message => message.includes('Failed to load custom parser for "php"')));
    manager.dispose();
  } finally {
    console.warn = originalWarn;
    Module._load = originalLoad;
    delete vscode.__state.config.additionalParsers;
  }
});
