const assert = require('node:assert/strict');
const fs = require('node:fs');
const Module = require('node:module');
const path = require('node:path');
const test = require('node:test');

const root = path.resolve(__dirname, '..');
const fixture = fs.readFileSync(path.join(__dirname, 'fixtures', 'php', 'mixed.php'), 'utf8');

function createDocument(text) {
  const lines = text.split('\n');
  const offsetAt = position => {
    let offset = 0;
    for (let line = 0; line < position.line; line += 1) offset += lines[line].length + 1;
    return offset + position.character;
  };
  const positionAt = requestedOffset => {
    const offset = Math.max(0, Math.min(requestedOffset, text.length));
    let consumed = 0;
    for (let line = 0; line < lines.length; line += 1) {
      const end = consumed + lines[line].length;
      if (offset <= end) return new vscode.Position(line, offset - consumed);
      consumed = end + 1;
    }
    return new vscode.Position(lines.length - 1, lines.at(-1).length);
  };
  return {
    uri: { toString: () => 'file:///mixed.php' },
    languageId: 'php',
    version: 1,
    getText(range) {
      if (!range) return text;
      return text.slice(offsetAt(range.start), offsetAt(range.end));
    },
    offsetAt,
    positionAt,
  };
}

let vscode;

async function activateProvider(config = {}) {
  vscode = require('./mocks/vscode.cjs');
  vscode.__state.providers.length = 0;
  vscode.__state.warnings.length = 0;
  vscode.__state.config = { ...config };
  const originalLoad = Module._load;
  Module._load = function patchedLoad(request, parent, isMain) {
    if (request === 'vscode') return vscode;
    return originalLoad.call(this, request, parent, isMain);
  };
  try {
    const bundle = path.join(root, 'dist', 'extension.js');
    delete require.cache[bundle];
    const extension = require(bundle);
    await extension.activate({ extensionUri: { fsPath: root }, subscriptions: [] });
    return { extension, provider: vscode.__state.providers[0].provider };
  } finally {
    Module._load = originalLoad;
  }
}

function chainToArray(selectionRange) {
  const chain = [];
  for (let current = selectionRange; current; current = current.parent) chain.push(current.range);
  return chain;
}

test('mixed PHP produces strictly expanding AST ranges with string and bracket interiors', async () => {
  const { extension, provider } = await activateProvider({ includeAnonymousNodes: true });
  const document = createDocument(fixture);
  const itemPosition = new vscode.Position(7, 13);
  const stringPosition = new vscode.Position(8, 32);
  const results = await provider.provideSelectionRanges(document, [itemPosition, stringPosition], {});

  assert.equal(results.length, 2);
  for (const result of results) {
    const chain = chainToArray(result);
    assert(chain.length >= 5);
    for (let index = 1; index < chain.length; index += 1) {
      const previousLength = document.getText(chain[index - 1]).length;
      const currentLength = document.getText(chain[index]).length;
      assert(currentLength > previousLength, `range ${index} must expand`);
    }
    assert.equal(document.getText(chain.at(-1)), fixture);
  }

  const stringTexts = chainToArray(results[1]).map(range => document.getText(range));
  assert(stringTexts.includes('active'));
  assert(stringTexts.includes('"active"'));
  const itemTexts = chainToArray(results[0]).map(range => document.getText(range));
  assert(itemTexts.includes('$items[0]'));
  extension.deactivate();
});

test('documents beyond maxFileSize return no custom ranges', async () => {
  const { extension, provider } = await activateProvider({ maxFileSize: 10 });
  const document = createDocument(fixture);
  const results = await provider.provideSelectionRanges(
    document,
    [new vscode.Position(7, 13)],
    {},
  );
  assert.deepEqual(results, []);
  extension.deactivate();
});
