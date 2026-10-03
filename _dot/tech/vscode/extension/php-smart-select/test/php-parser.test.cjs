const assert = require('node:assert/strict');
const path = require('node:path');
const test = require('node:test');
const { Parser, Language } = require('web-tree-sitter');

const root = path.resolve(process.env.EXTENSION_ROOT || path.join(__dirname, '..'));

test('PHP grammar loads and parses a PHP program', async () => {
  await Parser.init({
    locateFile: () => path.join(root, 'dist', 'wasm', 'tree-sitter.wasm'),
  });
  const language = await Language.load(path.join(root, 'dist', 'wasm', 'tree-sitter-php.wasm'));
  const parser = new Parser();
  parser.setLanguage(language);
  const tree = parser.parse('<?php $result = $items[0] + 1;');
  assert(tree);
  assert.equal(tree.rootNode.type, 'program');
  assert.equal(tree.rootNode.hasError, false);
  tree.delete();
  parser.delete();
});
